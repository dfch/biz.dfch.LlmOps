#!/usr/bin/env bash
# Corrected copy of bin/16-benchmark-q4-vs-q5.sh -- same purpose (A/B
# decode-throughput benchmark between UD-Q5_K_XL and UD-Q4_K_XL), same
# use of bin/15-measure-pcie-vs-throughput.sh for the actual measurement,
# same trap-guarded restart-on-exit safety design. See bin/16's header
# for the full rationale/motivation; not repeated here.
#
# WHY THIS COPY EXISTS (bug found 2026-08-22): bin/16 hardcodes
# `PROD_SERVICE=llama-glm-5.2.service` (Q5, port 8092) as "the thing to
# benchmark first / stop / restart at the end," and `AD_HOC_PORT=8093`
# for its ad-hoc Q4 load -- written before Task 3.4 installed
# llama-glm-5.2-q4.service as a real side-by-side systemd unit
# permanently bound to port 8093. With Q4 now the live
# production-equivalent service (not Q5): Phase A would silently SKIP
# (it only benchmarks if llama-glm-5.2.service is active), Phase B would
# either fail to bind port 8093 (already held by the real Q4 service) or,
# if that check somehow passed, try to cudaMalloc a whole second ~467 GB
# model on top of GPU memory the real Q4 service never released (bin/16
# never stops/knows about llama-glm-5.2-q4.service) -- the same OOM
# failure mode bin/17 hit in practice (see bin/23-tune-q4-placement-v2.sh
# header for that incident). Cleanup would then also always restart Q5,
# regardless of which service was actually running before.
#
# THE FIX: this script auto-detects whichever of the two GLM services
# (Q5 or Q4) is actually active when it starts, benchmarks THAT one
# directly (already running -- no ad-hoc load needed for Phase A), then
# stops it, ad-hoc cold-loads the OTHER quant (using that quant's own
# known-safe placement: Q5 always 54,9,8,8; Q4 defaults to the same
# 54,9,8,8 reuse until bin/23-tune-q4-placement-v2.sh has validated a
# better Q4-specific split -- update Q4_NCMOE/Q4_TENSOR_SPLIT below if
# so), benchmarks it, and restarts THE SAME service that was active at
# the start -- instead of hardcoding Q5 in either direction. No
# parameters or env vars needed; the detection and role assignment
# (which quant is "before"/live vs. "after"/ad-hoc) is automatic. The
# ad-hoc port is also moved to 8095 to avoid colliding with either
# service's permanently-assigned port (8092 Q5 / 8093 Q4).
#
# ============================================================================
# THIS SCRIPT STOPS AND RESTARTS WHICHEVER GLM SERVICE (Q5 or Q4) IS
# CURRENTLY ACTIVE. It is disruptive: that service is unavailable for
# roughly the time of ONE cold-load of the OTHER quant + benchmark + ONE
# cold-load to restart the original (likely 1-1.5+ hours total, cold
# loads historically 20-45+ min each). It is deliberately NOT run
# automatically -- read this header, confirm no one else needs the
# endpoint right now (check `ss -tnp | grep -E ':(8092|8093) '`), and run
# it manually when ready: bash 24-benchmark-q4-vs-q5-v2.sh
# ============================================================================
#
# Safety design (identical to bin/16):
#   - A single `cleanup` trap (EXIT) is responsible for BOTH killing the
#     ad-hoc llama-server (if still running) AND restarting the service
#     that was active before this script started -- this runs on normal
#     completion, on any `set -e` failure, and on Ctrl-C, so a mid-script
#     error should never leave the box with neither model loaded.
#   - The original service is only ever stopped/started via
#     `systemctl --user {stop,start}` -- never killed by PID -- consistent
#     with REQ-009 (systemd-only operation) and this feature's existing
#     scripts.
#   - The ad-hoc server binds 127.0.0.1 only (not 0.0.0.0) and uses port
#     8095 (8090=Phase-1 spikes, 8091=Task 2.1/2.2 measurement scripts,
#     8092=Q5 prod, 8093=Q4 prod, 8094=bin/17/bin/23 tuning ad-hoc,
#     8095=this script's ad-hoc port) so it is never reachable from the
#     network as an accidental second endpoint, and never collides with
#     either real service's port.
#   - Reuses bin/15-measure-pcie-vs-throughput.sh for the actual
#     measurement (both the "before" pass against the live original
#     service, and the "after" pass against the ad-hoc port), so the
#     exact same prompt/max_tokens/analysis logic is applied to both
#     quants -- avoiding a subtly-different benchmark methodology being
#     the reason for any observed difference.
#
# Usage: bash 24-benchmark-q4-vs-q5-v2.sh
# (Not executed automatically -- prepared for manual review/run first.)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

LLAMA_BIN=/data/llama.cpp-dsa/build/bin/llama-server

Q5_SERVICE=llama-glm-5.2.service
Q5_PORT=8092
Q5_MODEL_DIR=/data/llama_cpp/models/GLM-5.2-GGUF/UD-Q5_K_XL
Q5_ALIAS="glm-5.2:UD-Q5_K_XL"
Q5_NCMOE=54
Q5_TENSOR_SPLIT="54,9,8,8"

Q4_SERVICE=llama-glm-5.2-q4.service
Q4_PORT=8093
Q4_MODEL_DIR=/data/llama_cpp/models/GLM-5.2-GGUF/UD-Q4_K_XL
Q4_ALIAS="glm-5.2:UD-Q4_K_XL"
Q4_NCMOE=54                      # default: reuse Q5's validated placement -- update after bin/23-tune-q4-placement-v2.sh finds a better Q4-specific split
Q4_TENSOR_SPLIT="54,9,8,8"       # ditto

AD_HOC_HOST=127.0.0.1
AD_HOC_PORT=8095                 # deliberately distinct from 8092 (Q5)/8093 (Q4)/8094 (bin/17/bin/23 tuning) -- see header
CTX_SIZE=768000                  # match production -- see bin/08-llama-glm-5.2.service / bin/19-llama-glm-5.2-q4.service
STARTUP_TIMEOUT=5400             # 90 min -- generous for a cold ~467-562 GB load

LOGDIR="${SCRIPT_DIR}/logs"
mkdir -p "$LOGDIR"
STAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"
RUN_DIR="${LOGDIR}/${STAMP}-q4-vs-q5-benchmark-v2"
mkdir -p "$RUN_DIR"
AD_HOC_SERVER_LOG="${RUN_DIR}/ad-hoc-server.log"

echo "== Pre-flight checks =="

# Auto-detect whichever GLM service is actually active right now -- do NOT
# assume it's Q5. This is the core fix over bin/16.
ACTIVE=""
if systemctl --user is-active --quiet "$Q5_SERVICE"; then
  ACTIVE="Q5"
elif systemctl --user is-active --quiet "$Q4_SERVICE"; then
  ACTIVE="Q4"
fi

if [ -z "$ACTIVE" ]; then
  echo "ERROR: neither ${Q5_SERVICE} nor ${Q4_SERVICE} is currently active." >&2
  echo "This script needs one of them running to (a) benchmark as the" >&2
  echo "'before'/live pass and (b) know what to restore afterward. Start" >&2
  echo "one first, e.g.: systemctl --user start ${Q4_SERVICE}" >&2
  exit 1
fi

if [ "$ACTIVE" = "Q5" ]; then
  ACTIVE_SERVICE="$Q5_SERVICE"; ACTIVE_PORT="$Q5_PORT"; ACTIVE_ALIAS="$Q5_ALIAS"
  OTHER_LABEL="Q4"; OTHER_MODEL_DIR="$Q4_MODEL_DIR"; OTHER_ALIAS="$Q4_ALIAS"
  OTHER_NCMOE="$Q4_NCMOE"; OTHER_TENSOR_SPLIT="$Q4_TENSOR_SPLIT"
else
  ACTIVE_SERVICE="$Q4_SERVICE"; ACTIVE_PORT="$Q4_PORT"; ACTIVE_ALIAS="$Q4_ALIAS"
  OTHER_LABEL="Q5"; OTHER_MODEL_DIR="$Q5_MODEL_DIR"; OTHER_ALIAS="$Q5_ALIAS"
  OTHER_NCMOE="$Q5_NCMOE"; OTHER_TENSOR_SPLIT="$Q5_TENSOR_SPLIT"
fi

echo "Active service right now: ${ACTIVE_SERVICE} (${ACTIVE}, port ${ACTIVE_PORT})"
echo "Will benchmark it live first, then swap to ${OTHER_LABEL} ad-hoc"
echo "  (--n-cpu-moe ${OTHER_NCMOE} --tensor-split ${OTHER_TENSOR_SPLIT}),"
echo "  then restore ${ACTIVE_SERVICE} at the end."
if [ "$OTHER_LABEL" = "Q4" ] && [ "$OTHER_NCMOE" = "54" ] && [ "$OTHER_TENSOR_SPLIT" = "54,9,8,8" ]; then
  echo "  (Q4 placement is Q5's reused default -- run"
  echo "   bin/23-tune-q4-placement-v2.sh first and edit Q4_NCMOE/"
  echo "   Q4_TENSOR_SPLIT above for a tuned comparison.)"
fi

OTHER_MODEL_FIRST_SHARD="$(ls "${OTHER_MODEL_DIR}"/*-00001-of-*.gguf 2>/dev/null | head -1)"
if [ -z "$OTHER_MODEL_FIRST_SHARD" ]; then
  echo "ERROR: no GGUF shards found under ${OTHER_MODEL_DIR} -- run bin/04-dl-status.sh to check the download." >&2
  exit 1
fi

OTHER_CONN="$(ss -tnp 2>/dev/null | grep ":${ACTIVE_PORT} " || true)"
if [ -n "$OTHER_CONN" ]; then
  echo
  echo "WARNING: existing connection(s) on ${ACTIVE_SERVICE}'s port ${ACTIVE_PORT}:"
  echo "$OTHER_CONN"
  echo "Stopping the service later will interrupt that session. Ctrl-C now to"
  echo "abort if that is not acceptable; continuing in 10s..."
  sleep 10
fi

AD_HOC_PID=""

cleanup() {
  local exit_code=$?
  echo
  echo "== Cleanup (exit code ${exit_code}) =="
  if [ -n "$AD_HOC_PID" ] && kill -0 "$AD_HOC_PID" 2>/dev/null; then
    echo "Stopping ad-hoc ${OTHER_LABEL} llama-server (pid ${AD_HOC_PID})..."
    kill "$AD_HOC_PID" 2>/dev/null || true
    wait "$AD_HOC_PID" 2>/dev/null || true
  fi
  echo "Ensuring ${ACTIVE_SERVICE} (the service that was active before this script ran) is running..."
  if ! systemctl --user is-active --quiet "$ACTIVE_SERVICE"; then
    systemctl --user start "$ACTIVE_SERVICE" || echo "WARNING: failed to start ${ACTIVE_SERVICE} -- start it manually and check journalctl." >&2
  fi
  echo "Done. Verify with: systemctl --user status ${ACTIVE_SERVICE} ; curl http://localhost:${ACTIVE_PORT}/health"
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Phase A: benchmark the CURRENTLY RUNNING service directly -- it's already
# up, so no ad-hoc load is needed for this half.
#
# NOTE: `systemctl is-active` (used above to pick ACTIVE_SERVICE) only
# means the unit's process is running -- for these services that is true
# for the ENTIRE 20-45+ min cold-load window, long before /health ever
# returns 200. Found live 2026-08-22: running this script while Q4 was
# still mid-cold-load (restarted by bin/23's own cleanup) made Phase A
# fail immediately with a 503 from bin/15's own health check. Wait for
# real health here, the same way Phase B already waits for its ad-hoc
# load, instead of assuming "active" means "ready".
# ---------------------------------------------------------------------------
echo
echo "=============================================================="
echo "Phase A: wait for LIVE ${ACTIVE_SERVICE} to be healthy, then benchmark via bin/15"
echo "=============================================================="
echo "Waiting for ${ACTIVE_SERVICE} (localhost:${ACTIVE_PORT}) to become healthy (up to ${STARTUP_TIMEOUT}s -- may still be cold-loading)..."
elapsed=0
while true; do
  HTTP_CODE="$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:${ACTIVE_PORT}/health" 2>/dev/null || echo "000")"
  if [ "$HTTP_CODE" = "200" ]; then
    break
  fi
  if ! systemctl --user is-active --quiet "$ACTIVE_SERVICE"; then
    echo "ERROR: ${ACTIVE_SERVICE} is no longer active -- check journalctl --user-unit ${ACTIVE_SERVICE}" >&2
    exit 1
  fi
  if [ "$elapsed" -ge "$STARTUP_TIMEOUT" ]; then
    echo "ERROR: ${ACTIVE_SERVICE} did not become healthy within ${STARTUP_TIMEOUT}s" >&2
    exit 1
  fi
  sleep 15
  elapsed=$((elapsed + 15))
  if [ $((elapsed % 300)) -eq 0 ]; then
    echo "  ... still waiting, ${elapsed}s elapsed (this is expected during a cold load, do not assume a hang -- see AGENTS.md long-job guidance)"
  fi
done
echo "${ACTIVE_SERVICE} healthy after ~${elapsed}s wait"

echo
echo "=============================================================="
echo "Phase A: benchmark LIVE ${ACTIVE_SERVICE} (${ACTIVE_ALIAS}) via bin/15"
echo "=============================================================="
ACTIVE_RESULT_DIR_MARKER="${RUN_DIR}/active-result-dir.txt"
HOST=localhost PORT="$ACTIVE_PORT" MODEL="$ACTIVE_ALIAS" \
  bash "${SCRIPT_DIR}/15-measure-pcie-vs-throughput.sh" 2>&1 | tee "${RUN_DIR}/active-benchmark.log"
grep -oE '/[^ ]*-pcie-vs-throughput' "${RUN_DIR}/active-benchmark.log" | tail -1 > "$ACTIVE_RESULT_DIR_MARKER" || true

# ---------------------------------------------------------------------------
# Phase B: stop the active service, load the OTHER quant ad-hoc, benchmark,
# tear down.
# ---------------------------------------------------------------------------
echo
echo "=============================================================="
echo "Phase B: stop ${ACTIVE_SERVICE}, load ${OTHER_LABEL} ad-hoc, benchmark"
echo "=============================================================="
echo "Stopping ${ACTIVE_SERVICE}..."
systemctl --user stop "$ACTIVE_SERVICE"

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
echo "Starting ad-hoc ${OTHER_LABEL} llama-server on ${AD_HOC_HOST}:${AD_HOC_PORT}..."
echo "  log: ${AD_HOC_SERVER_LOG}"
"$LLAMA_BIN" \
  --model "$OTHER_MODEL_FIRST_SHARD" \
  --alias "$OTHER_ALIAS" \
  --host "$AD_HOC_HOST" --port "$AD_HOC_PORT" \
  --ctx-size "$CTX_SIZE" \
  --n-gpu-layers 999 \
  --n-cpu-moe "$OTHER_NCMOE" \
  --tensor-split "$OTHER_TENSOR_SPLIT" \
  --load-mode none \
  --parallel 1 \
  --jinja \
  > "$AD_HOC_SERVER_LOG" 2>&1 &
AD_HOC_PID=$!

echo "Waiting for ad-hoc ${OTHER_LABEL} server to become healthy (up to ${STARTUP_TIMEOUT}s -- cold load, expect 20-45+ min)..."
elapsed=0
while true; do
  HTTP_CODE="$(curl -s -o /dev/null -w '%{http_code}' "http://${AD_HOC_HOST}:${AD_HOC_PORT}/health" 2>/dev/null || echo "000")"
  if [ "$HTTP_CODE" = "200" ]; then
    break
  fi
  if ! kill -0 "$AD_HOC_PID" 2>/dev/null; then
    echo "ERROR: ad-hoc ${OTHER_LABEL} llama-server exited early -- see ${AD_HOC_SERVER_LOG}" >&2
    tail -n 60 "$AD_HOC_SERVER_LOG" >&2
    exit 1
  fi
  if [ "$elapsed" -ge "$STARTUP_TIMEOUT" ]; then
    echo "ERROR: ad-hoc ${OTHER_LABEL} server did not become healthy within ${STARTUP_TIMEOUT}s" >&2
    exit 1
  fi
  sleep 15
  elapsed=$((elapsed + 15))
  if [ $((elapsed % 300)) -eq 0 ]; then
    echo "  ... still loading, ${elapsed}s elapsed (this is expected, do not assume a hang -- see AGENTS.md long-job guidance)"
  fi
done
echo "Ad-hoc ${OTHER_LABEL} server healthy after ~${elapsed}s"

echo
echo "=============================================================="
echo "Phase B: benchmark AD-HOC ${OTHER_LABEL} (${OTHER_ALIAS}) via bin/15"
echo "=============================================================="
OTHER_RESULT_DIR_MARKER="${RUN_DIR}/other-result-dir.txt"
HOST="$AD_HOC_HOST" PORT="$AD_HOC_PORT" MODEL="$OTHER_ALIAS" \
  bash "${SCRIPT_DIR}/15-measure-pcie-vs-throughput.sh" 2>&1 | tee "${RUN_DIR}/other-benchmark.log"
grep -oE '/[^ ]*-pcie-vs-throughput' "${RUN_DIR}/other-benchmark.log" | tail -1 > "$OTHER_RESULT_DIR_MARKER" || true

echo
echo "Stopping ad-hoc ${OTHER_LABEL} llama-server (pid ${AD_HOC_PID})..."
kill "$AD_HOC_PID" 2>/dev/null || true
wait "$AD_HOC_PID" 2>/dev/null || true
AD_HOC_PID=""

# ---------------------------------------------------------------------------
# Final comparison (original service restart happens in the `cleanup` trap
# below, after this point, regardless of how the script exits).
# ---------------------------------------------------------------------------
echo
echo "=============================================================="
echo "${ACTIVE} (live) vs ${OTHER_LABEL} (ad-hoc) comparison"
echo "=============================================================="
python3 - "$RUN_DIR" "$ACTIVE_ALIAS" "$OTHER_ALIAS" <<'PYEOF'
import json
import os
import sys

run_dir, active_alias, other_alias = sys.argv[1:4]

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

active = load_marker("active-result-dir.txt")
other = load_marker("other-result-dir.txt")

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
active_tok_s = summarize(f"{active_alias} (live, 'before')", active)
other_tok_s = summarize(f"{other_alias} (ad-hoc, 'after')", other)

if active_tok_s and other_tok_s:
    delta_pct = (other_tok_s - active_tok_s) / active_tok_s * 100.0
    print()
    print(f"{other_alias} vs {active_alias}: {delta_pct:+.1f}% tok/s "
          f"({'faster' if delta_pct > 0 else 'slower'})")
    print("(Compare this measured figure against this feature's theoretical")
    print(" estimate -- ~15-30% faster expected from the file-size ratio and")
    print(" the PCIe-bound hypothesis -- see session notes/README for the")
    print(" full derivation and caveats.)")
PYEOF

echo
echo "Full logs under: ${RUN_DIR}/"
echo "(Original service restart happens next, in cleanup.)"
