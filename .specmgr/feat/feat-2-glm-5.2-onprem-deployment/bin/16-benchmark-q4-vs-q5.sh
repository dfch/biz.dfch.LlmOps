#!/usr/bin/env bash
# A/B decode-throughput benchmark: UD-Q5_K_XL (current production quant)
# vs. UD-Q4_K_XL (fallback, fully downloaded -- see bin/04-dl-status.sh).
#
# IMPORTANT: by default this reuses Q5's IDENTICAL --n-cpu-moe/--tensor-split
# placement (54,9,8,8) -- this is guaranteed SAFE for Q4 (every Q4 tensor is
# <= its Q5 counterpart) but is NOT necessarily Q4's best placement: Q4's
# MoE-expert blocks measure ~82.4% of Q5's size (5.468 vs 6.635 GiB avg,
# from actual GGUF metadata), so the same VRAM budget could likely support
# MORE GPU-resident (fewer CPU-offloaded) blocks under Q4, which -- if
# decode is genuinely PCIe-bound (see below) -- would mean an EVEN BIGGER
# speedup than a pure bit-width comparison shows. Run
# bin/17-tune-q4-placement.sh FIRST to find a better Q4-specific placement
# (it uses llama.cpp's own sub-second startup fit-check to test several
# candidates quickly, without a full cold load per candidate), then override
# NCMOE/TENSOR_SPLIT below (env vars) with its winning candidate before
# running this script, for a fair "best Q4 config" vs "best Q5 config"
# comparison rather than "Q5's config forced onto Q4".
#
# Motivated by a user report that decode felt slow in real use, plus a
# live spot-check during this feature's work showing GPU0 (PCIe 5.0 x16
# bus) sustaining ~46-60 GB/s PCIe RX at 100% SM utilization -- suggesting
# decode may be PCIe-transfer-bound in this --n-cpu-moe hybrid config, in
# which case Q4's ~17% smaller footprint (467 GB vs Q5's 562 GB, see
# Design Notes) could plausibly yield a meaningfully higher tok/s. This
# script MEASURES that instead of relying on the theoretical estimate
# (see this feature's README/session notes for the estimate's derivation
# and caveats -- same "measure, don't extrapolate" discipline as Task
# 2.1/2.2's quant-headroom work).
#
# ============================================================================
# THIS SCRIPT STOPS AND RESTARTS THE PRODUCTION SERVICE
# (llama-glm-5.2.service). It is disruptive: production is unavailable for
# roughly the time of ONE Q4 cold-load + benchmark + ONE Q5 cold-load
# (likely 1-1.5+ hours total, cold loads historically 20-45+ min each).
# It is deliberately NOT run automatically -- read this header, confirm no
# one else needs the endpoint right now (check `ss -tnp | grep 8092`), and
# run it manually when ready: bash 16-benchmark-q4-vs-q5.sh
# ============================================================================
#
# Safety design:
#   - A single `cleanup` trap (EXIT) is responsible for BOTH killing the
#     ad-hoc Q4 llama-server (if still running) AND restarting the
#     production systemd unit -- this runs on normal completion, on any
#     `set -e` failure, and on Ctrl-C, so a mid-script error should never
#     leave the box with neither model loaded.
#   - The production unit is only ever stopped/started via
#     `systemctl --user {stop,start}` -- never killed by PID -- consistent
#     with REQ-009 (systemd-only operation) and this feature's existing
#     scripts.
#   - The ad-hoc Q4 server binds 127.0.0.1 only (not 0.0.0.0) and uses port
#     8093 (8090=Phase-1 spikes, 8091=Task 2.1/2.2 measurement scripts,
#     8092=production -- 8093 avoids all three) so it is never reachable
#     from the network as an accidental second endpoint.
#   - Reuses bin/15-measure-pcie-vs-throughput.sh for the actual
#     measurement (both the Q5 "before" pass against the live production
#     port, and the Q4 "after" pass against the ad-hoc port), so the exact
#     same prompt/max_tokens/analysis logic is applied to both quants --
#     avoiding a subtly-different benchmark methodology being the reason
#     for any observed difference. NOTE: the Q5 pass doubles as a proper
#     Task 2.5.1 throughput measurement (the smoke test in bin/14 was
#     short-context and not meant as a throughput benchmark).
#
# Usage: bash 16-benchmark-q4-vs-q5.sh
# (Not executed automatically -- prepared for manual review/run first.)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

LLAMA_BIN=/data/llama.cpp-dsa/build/bin/llama-server
Q4_MODEL_DIR=/data/llama_cpp/models/GLM-5.2-GGUF/UD-Q4_K_XL
PROD_SERVICE=llama-glm-5.2.service
PROD_HOST=localhost
PROD_PORT=8092
AD_HOC_HOST=127.0.0.1
AD_HOC_PORT=8093
CTX_SIZE=768000                        # match production -- see bin/08-llama-glm-5.2.service
NCMOE="${NCMOE:-54}"                   # default: reuse Q5's validated placement (safe, not necessarily optimal for Q4 -- see header)
TENSOR_SPLIT="${TENSOR_SPLIT:-54,9,8,8}"  # override both together with bin/17-tune-q4-placement.sh's winning candidate for a fairer comparison
STARTUP_TIMEOUT=5400                   # 90 min -- generous for a cold ~467 GB load

LOGDIR="${SCRIPT_DIR}/logs"
mkdir -p "$LOGDIR"
STAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"
RUN_DIR="${LOGDIR}/${STAMP}-q4-vs-q5-benchmark"
mkdir -p "$RUN_DIR"
AD_HOC_SERVER_LOG="${RUN_DIR}/q4-adhoc-server.log"

Q4_MODEL_FIRST_SHARD="$(ls "${Q4_MODEL_DIR}"/*-00001-of-*.gguf 2>/dev/null | head -1)"
if [ -z "$Q4_MODEL_FIRST_SHARD" ]; then
  echo "ERROR: no GGUF shards found under ${Q4_MODEL_DIR} -- run bin/04-dl-status.sh to check the download." >&2
  exit 1
fi

echo "== Pre-flight checks =="
echo "Q4 model: ${Q4_MODEL_FIRST_SHARD}"
echo "Q4 placement: --n-cpu-moe ${NCMOE} --tensor-split ${TENSOR_SPLIT}"
if [ "$NCMOE" = "54" ] && [ "$TENSOR_SPLIT" = "54,9,8,8" ]; then
  echo "  (default -- this is Q5's placement reused as-is, known-safe but"
  echo "   possibly not optimal for Q4; run bin/17-tune-q4-placement.sh first"
  echo "   and re-invoke with NCMOE=... TENSOR_SPLIT=... for a tuned comparison)"
fi

echo -n "Production service state: "
if systemctl --user is-active --quiet "$PROD_SERVICE"; then
  echo "active"
else
  echo "NOT active -- this script assumes Q5 is currently running so it has a"
  echo "  known-good state to restore. Start it first if you want the 'before'"
  echo "  (Q5) measurement; otherwise this script will still work for the Q4"
  echo "  side but there is nothing to restore to at the end." >&2
fi

OTHER_CONN="$(ss -tnp 2>/dev/null | grep ":${PROD_PORT} " || true)"
if [ -n "$OTHER_CONN" ]; then
  echo
  echo "WARNING: existing connection(s) on production port ${PROD_PORT}:"
  echo "$OTHER_CONN"
  echo "Stopping the service now will interrupt that session. Ctrl-C now to"
  echo "abort if that is not acceptable; continuing in 10s..."
  sleep 10
fi

AD_HOC_PID=""

cleanup() {
  local exit_code=$?
  echo
  echo "== Cleanup (exit code ${exit_code}) =="
  if [ -n "$AD_HOC_PID" ] && kill -0 "$AD_HOC_PID" 2>/dev/null; then
    echo "Stopping ad-hoc Q4 llama-server (pid ${AD_HOC_PID})..."
    kill "$AD_HOC_PID" 2>/dev/null || true
    wait "$AD_HOC_PID" 2>/dev/null || true
  fi
  echo "Ensuring production service (${PROD_SERVICE}) is running..."
  if ! systemctl --user is-active --quiet "$PROD_SERVICE"; then
    systemctl --user start "$PROD_SERVICE" || echo "WARNING: failed to start ${PROD_SERVICE} -- start it manually and check journalctl." >&2
  fi
  echo "Done. Verify with: systemctl --user status ${PROD_SERVICE} ; curl http://${PROD_HOST}:${PROD_PORT}/health"
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Phase A: benchmark the CURRENTLY RUNNING production Q5 service (this also
# serves as Task 2.5.1's proper throughput measurement, not just bin/14's
# short-context smoke test).
# ---------------------------------------------------------------------------
echo
echo "=============================================================="
echo "Phase A: benchmark PRODUCTION (UD-Q5_K_XL) via bin/15"
echo "=============================================================="
if systemctl --user is-active --quiet "$PROD_SERVICE"; then
  Q5_RESULT_DIR_MARKER="${RUN_DIR}/q5-result-dir.txt"
  HOST="$PROD_HOST" PORT="$PROD_PORT" \
    bash "${SCRIPT_DIR}/15-measure-pcie-vs-throughput.sh" 2>&1 | tee "${RUN_DIR}/q5-benchmark.log"
  # bin/15 prints its own result dir path at the end of its log; pull it out
  # for the final comparison step below.
  grep -oE '/[^ ]*-pcie-vs-throughput' "${RUN_DIR}/q5-benchmark.log" | tail -1 > "$Q5_RESULT_DIR_MARKER" || true
else
  echo "SKIPPED -- production service is not currently active, nothing to benchmark."
fi

# ---------------------------------------------------------------------------
# Phase B: stop production, load Q4 ad-hoc, benchmark, tear down.
# ---------------------------------------------------------------------------
echo
echo "=============================================================="
echo "Phase B: stop production, load UD-Q4_K_XL ad-hoc, benchmark"
echo "=============================================================="
echo "Stopping ${PROD_SERVICE}..."
systemctl --user stop "$PROD_SERVICE"

echo "Waiting for GPU memory to drain to idle..."
for _ in $(seq 1 30); do
  USED_TOTAL="$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits | paste -sd+ | bc)"
  if [ "$USED_TOTAL" -lt 5000 ]; then
    break
  fi
  sleep 2
done
echo "GPU memory now (MiB per GPU):"
nvidia-smi --query-gpu=index,memory.used --format=csv

echo
echo "Starting ad-hoc Q4 llama-server on ${AD_HOC_HOST}:${AD_HOC_PORT}..."
echo "  log: ${AD_HOC_SERVER_LOG}"
"$LLAMA_BIN" \
  --model "$Q4_MODEL_FIRST_SHARD" \
  --alias "glm-5.2:UD-Q4_K_XL" \
  --host "$AD_HOC_HOST" --port "$AD_HOC_PORT" \
  --ctx-size "$CTX_SIZE" \
  --n-gpu-layers 999 \
  --n-cpu-moe "$NCMOE" \
  --tensor-split "$TENSOR_SPLIT" \
  --load-mode none \
  --parallel 1 \
  --jinja \
  > "$AD_HOC_SERVER_LOG" 2>&1 &
AD_HOC_PID=$!

echo "Waiting for ad-hoc Q4 server to become healthy (up to ${STARTUP_TIMEOUT}s -- cold load, expect 20-45+ min)..."
elapsed=0
while true; do
  HTTP_CODE="$(curl -s -o /dev/null -w '%{http_code}' "http://${AD_HOC_HOST}:${AD_HOC_PORT}/health" 2>/dev/null || echo "000")"
  if [ "$HTTP_CODE" = "200" ]; then
    break
  fi
  if ! kill -0 "$AD_HOC_PID" 2>/dev/null; then
    echo "ERROR: ad-hoc Q4 llama-server exited early -- see ${AD_HOC_SERVER_LOG}" >&2
    tail -n 60 "$AD_HOC_SERVER_LOG" >&2
    exit 1
  fi
  if [ "$elapsed" -ge "$STARTUP_TIMEOUT" ]; then
    echo "ERROR: ad-hoc Q4 server did not become healthy within ${STARTUP_TIMEOUT}s" >&2
    exit 1
  fi
  sleep 15
  elapsed=$((elapsed + 15))
  if [ $((elapsed % 300)) -eq 0 ]; then
    echo "  ... still loading, ${elapsed}s elapsed (this is expected, do not assume a hang -- see AGENTS.md long-job guidance)"
  fi
done
echo "Ad-hoc Q4 server healthy after ~${elapsed}s"

echo
echo "=============================================================="
echo "Phase B: benchmark AD-HOC (UD-Q4_K_XL) via bin/15"
echo "=============================================================="
Q4_RESULT_DIR_MARKER="${RUN_DIR}/q4-result-dir.txt"
HOST="$AD_HOC_HOST" PORT="$AD_HOC_PORT" MODEL="glm-5.2:UD-Q4_K_XL" \
  bash "${SCRIPT_DIR}/15-measure-pcie-vs-throughput.sh" 2>&1 | tee "${RUN_DIR}/q4-benchmark.log"
grep -oE '/[^ ]*-pcie-vs-throughput' "${RUN_DIR}/q4-benchmark.log" | tail -1 > "$Q4_RESULT_DIR_MARKER" || true

echo
echo "Stopping ad-hoc Q4 llama-server (pid ${AD_HOC_PID})..."
kill "$AD_HOC_PID" 2>/dev/null || true
wait "$AD_HOC_PID" 2>/dev/null || true
AD_HOC_PID=""

# ---------------------------------------------------------------------------
# Final comparison (production restart happens in the `cleanup` trap below,
# after this point, regardless of how the script exits).
# ---------------------------------------------------------------------------
echo
echo "=============================================================="
echo "Q4 vs Q5 comparison"
echo "=============================================================="
python3 - "$RUN_DIR" <<'PYEOF'
import json
import os
import sys

run_dir = sys.argv[1]

def load_marker(name):
    marker = os.path.join(run_dir, name)
    if not os.path.exists(marker):
        return None
    with open(marker) as f:
        path = f.read().strip()
    resp = os.path.join(path, "response.json")
    if not os.path.exists(resp):
        return None
    with open(resp) as f:
        return json.load(f)

q5 = load_marker("q5-result-dir.txt")
q4 = load_marker("q4-result-dir.txt")

def summarize(label, data):
    if data is None:
        print(f"{label}: no result (skipped or failed)")
        return None
    t = data.get("timings", {})
    tok_s = t.get("predicted_per_second")
    n = data.get("usage", {}).get("completion_tokens")
    finish = data["choices"][0].get("finish_reason")
    print(f"{label}: {tok_s:.2f} tok/s over {n} completion tokens (finish_reason={finish!r})")
    return tok_s

print()
q5_tok_s = summarize("UD-Q5_K_XL (production, 'before')", q5)
q4_tok_s = summarize("UD-Q4_K_XL (ad-hoc, 'after')", q4)

if q5_tok_s and q4_tok_s:
    delta_pct = (q4_tok_s - q5_tok_s) / q5_tok_s * 100.0
    print()
    print(f"Q4 vs Q5: {delta_pct:+.1f}% tok/s "
          f"({'faster' if delta_pct > 0 else 'slower'} at Q4)")
    print("(Compare this measured figure against this feature's theoretical")
    print(" estimate -- ~15-30% faster expected from the file-size ratio and")
    print(" the PCIe-bound hypothesis -- see session notes/README for the")
    print(" full derivation and caveats.)")
PYEOF

echo
echo "Full logs under: ${RUN_DIR}/"
echo "(Production service restart happens next, in cleanup.)"
