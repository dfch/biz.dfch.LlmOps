#!/usr/bin/env bash
# Correlates CPU<->GPU PCIe traffic with measured decode throughput against
# an ALREADY-RUNNING llama-server endpoint (production port 8092 by default,
# but HOST/PORT are overridable so bin/16-benchmark-q4-vs-q5.sh can point
# this at an ad-hoc port for a second quant). Does NOT start/stop the
# server itself.
#
# Motivation: a live spot-check during this feature's work found GPU0
# (the PCIe 5.0 x16 bus per Task 2.3's topology finding) sustaining
# ~46-60 GB/s PCIe RX at 100% SM utilization while GPUs 1-3 sat idle,
# during real generation traffic -- a strong signal that decode in this
# --n-cpu-moe hybrid config may be PCIe-transfer-bound (the CPU-offloaded
# MoE-expert weight rows being streamed to GPU every decode step), not
# purely compute-bound. This script turns that opportunistic spot-check
# into a repeatable measurement, doubling as Task 2.5.1's throughput
# benchmark when run against the production port with the service
# otherwise idle (no concurrent traffic -- see the note below).
#
# What it does:
#   1. Checks HOST:PORT/health is already 200 (does not start the server).
#   2. Starts `nvidia-smi dmon -s ut -o T` logging to a file in the
#      background (per-GPU sm%/mem%/rxpci/txpci, 1 Hz).
#   3. Sends ONE chat/completions request (temperature=0, a deterministic
#      code-gen prompt with a generous max_tokens for a real steady-state
#      decode sample -- short single-word answers like the ACC-002/Task
#      2.4 "Paris" case are too brief to be useful here).
#   4. Stops the dmon log once the response arrives.
#   5. Parses the response's own `timings` block (predicted_per_second,
#      predicted_n, prompt_per_second) AND the dmon log restricted to the
#      request's wall-clock window, computing per-GPU avg/max rxpci/txpci
#      and avg sm% during generation.
#   6. Prints a combined summary: tok/s next to per-GPU PCIe/SM figures,
#      so throughput and transfer load can be read together.
#
# IMPORTANT CAVEAT: if something ELSE is also hitting the same endpoint
# concurrently (as happened during this feature's live spot-check, from a
# separate client), the PCIe/SM figures captured here will include that
# other traffic too and the tok/s number won't be a clean single-request
# measurement. Check `ss -tnp | grep <port>` first and prefer a quiet
# window for a trustworthy result.
#
# Usage:
#   bash 15-measure-pcie-vs-throughput.sh
#   HOST=127.0.0.1 PORT=8093 MODEL="glm-5.2:UD-Q4_K_XL" bash 15-measure-pcie-vs-throughput.sh
#
# Env overrides: HOST, PORT, MODEL (auto-detected from /v1/models if
# unset), PROMPT, MAX_TOKENS, CHAT_KWARGS, DMON_MAX_SAMPLES (safety cap on
# background dmon samples so it can't run forever if something hangs).

set -euo pipefail

HOST="${HOST:-localhost}"
PORT="${PORT:-8092}"
PROMPT="${PROMPT:-Write a Python function that implements merge sort, with a short docstring explaining the algorithm.}"
MAX_TOKENS="${MAX_TOKENS:-1500}"
CHAT_KWARGS="${CHAT_KWARGS:-{\"reasoning_effort\": \"max\"}}"
DMON_MAX_SAMPLES="${DMON_MAX_SAMPLES:-900}"   # 15 min safety cap @ 1Hz

LOGDIR="$(cd "$(dirname "$0")" && pwd)/logs"
mkdir -p "$LOGDIR"
STAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"
RESULT_DIR="${LOGDIR}/${STAMP}-pcie-vs-throughput"
mkdir -p "$RESULT_DIR"
DMON_LOG="${RESULT_DIR}/dmon.log"
RESPONSE_JSON="${RESULT_DIR}/response.json"

echo "== Checking ${HOST}:${PORT}/health =="
HTTP_CODE="$(curl -s -o /dev/null -w '%{http_code}' "http://${HOST}:${PORT}/health" 2>/dev/null || echo "000")"
if [ "$HTTP_CODE" != "200" ]; then
  echo "ERROR: ${HOST}:${PORT}/health returned ${HTTP_CODE}, not 200 -- is the server running and finished loading?" >&2
  exit 1
fi

MODEL="${MODEL:-}"
if [ -z "$MODEL" ]; then
  MODEL="$(curl -s "http://${HOST}:${PORT}/v1/models" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['data'][0]['id'])" 2>/dev/null || true)"
fi
if [ -z "$MODEL" ]; then
  echo "ERROR: could not auto-detect model id from /v1/models -- set MODEL= explicitly" >&2
  exit 1
fi
echo "Model: ${MODEL}"

echo
echo "== Checking for other active connections on port ${PORT} (informational only) =="
OTHER_CONN="$(ss -tnp 2>/dev/null | grep ":${PORT} " || true)"
if [ -n "$OTHER_CONN" ]; then
  echo "NOTE: existing connection(s) found -- if something else is generating"
  echo "concurrently, the PCIe/tok-s figures below will include that traffic too:"
  echo "$OTHER_CONN"
else
  echo "No pre-existing connections found."
fi

echo
echo "== Starting background PCIe/utilization sampling (nvidia-smi dmon -s ut -o T) =="
echo "   log: ${DMON_LOG}"
nvidia-smi dmon -s ut -o T -c "$DMON_MAX_SAMPLES" > "$DMON_LOG" 2>&1 &
DMON_PID=$!

cleanup() {
  kill "$DMON_PID" 2>/dev/null || true
  wait "$DMON_PID" 2>/dev/null || true
}
trap cleanup EXIT

# Small settle delay so the dmon log has at least one baseline sample
# before the request starts.
sleep 1

REQ_START_EPOCH="$(date -u +%s)"
REQ_START_HMS="$(date -u +%H:%M:%S)"
echo
echo "== Sending request (max_tokens=${MAX_TOKENS}, chat_template_kwargs=${CHAT_KWARGS}) at ${REQ_START_HMS} UTC =="

REQ_BODY=$(MODEL="$MODEL" PROMPT="$PROMPT" MAX_TOKENS="$MAX_TOKENS" CHAT_KWARGS="$CHAT_KWARGS" python3 -c "
import json, os
print(json.dumps({
    'model': os.environ['MODEL'],
    'messages': [{'role': 'user', 'content': os.environ['PROMPT']}],
    'temperature': 0,
    'max_tokens': int(os.environ['MAX_TOKENS']),
    'chat_template_kwargs': json.loads(os.environ['CHAT_KWARGS']),
}))
")

curl -s "http://${HOST}:${PORT}/v1/chat/completions" \
  -H 'Content-Type: application/json' \
  -d "$REQ_BODY" > "$RESPONSE_JSON"

REQ_END_EPOCH="$(date -u +%s)"
REQ_END_HMS="$(date -u +%H:%M:%S)"
echo "Response received at ${REQ_END_HMS} UTC (elapsed ~$((REQ_END_EPOCH - REQ_START_EPOCH))s)"

# Let the dmon log capture a couple more samples past the response before
# stopping it, then tear it down.
sleep 2
kill "$DMON_PID" 2>/dev/null || true
wait "$DMON_PID" 2>/dev/null || true
trap - EXIT

echo
echo "== Analysis =="
python3 - "$RESPONSE_JSON" "$DMON_LOG" "$REQ_START_HMS" "$REQ_END_HMS" <<'PYEOF'
import json
import sys

response_path, dmon_path, start_hms, end_hms = sys.argv[1:5]

with open(response_path) as f:
    data = json.load(f)

choice = data["choices"][0]
message = choice["message"]
content = (message.get("content") or "").strip()
finish_reason = choice.get("finish_reason")
usage = data.get("usage", {})
timings = data.get("timings", {})

print(f"finish_reason: {finish_reason!r}")
print(f"completion_tokens: {usage.get('completion_tokens')}")
print(f"prompt_tokens: {usage.get('prompt_tokens')}")
print(f"predicted_per_second (tok/s): {timings.get('predicted_per_second')}")
print(f"prompt_per_second (tok/s): {timings.get('prompt_per_second')}")
print(f"content preview: {content[:150]!r}")
if finish_reason == "length":
    print("NOTE: truncated (finish_reason=length) -- still a valid steady-state")
    print("      decode sample, just didn't finish the answer; consider a larger")
    print("      MAX_TOKENS next run if a finished answer is also wanted.")

def hms_to_seconds(hms):
    h, m, s = (int(x) for x in hms.split(":"))
    return h * 3600 + m * 60 + s

start_s = hms_to_seconds(start_hms)
end_s = hms_to_seconds(end_hms)

per_gpu = {}
with open(dmon_path) as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split()
        # Columns: Time gpu sm mem enc dec jpg ofa rxpci txpci
        if len(parts) < 10:
            continue
        t_hms = parts[0]
        try:
            gpu_idx = int(parts[1])
            sm = int(parts[2])
            rxpci = int(parts[8])
            txpci = int(parts[9])
        except ValueError:
            continue
        t_s = hms_to_seconds(t_hms)
        # Keep a small margin on both sides since the request start/end
        # timestamps and the 1Hz sampling won't align exactly.
        if not (start_s - 1 <= t_s <= end_s + 1):
            continue
        bucket = per_gpu.setdefault(gpu_idx, {"sm": [], "rxpci": [], "txpci": []})
        bucket["sm"].append(sm)
        bucket["rxpci"].append(rxpci)
        bucket["txpci"].append(txpci)

print()
print("Per-GPU during the request window (from nvidia-smi dmon):")
print(f"{'GPU':>3} {'avg sm%':>8} {'avg rxpci MB/s':>15} {'max rxpci MB/s':>15} {'avg txpci MB/s':>15}")
for gpu_idx in sorted(per_gpu):
    b = per_gpu[gpu_idx]
    n = len(b["sm"]) or 1
    avg_sm = sum(b["sm"]) / n
    avg_rx = sum(b["rxpci"]) / n
    max_rx = max(b["rxpci"]) if b["rxpci"] else 0
    avg_tx = sum(b["txpci"]) / n
    print(f"{gpu_idx:>3} {avg_sm:>8.1f} {avg_rx:>15.0f} {max_rx:>15.0f} {avg_tx:>15.0f}")

if not per_gpu:
    print("(no dmon samples fell inside the request window -- request may have")
    print(" been too short for the 1Hz sampling interval to catch, or the")
    print(" HH:MM:SS window crossed midnight UTC; inspect the raw log instead)")
PYEOF

echo
echo "Response: ${RESPONSE_JSON}"
echo "PCIe/utilization log: ${DMON_LOG}"
