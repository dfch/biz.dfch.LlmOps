#!/usr/bin/env bash
# UD-Q4_K_XL equivalent of bin/07-measure-kv-cache-768-896.sh: same
# methodology (real llama-server load, real per-GPU memory-breakdown
# measurement, no bisection), same 2 context sizes (768,000 and 896,000),
# same --n-cpu-moe/--tensor-split placement (54,9,8,8) -- reused because
# it is ALREADY PROVEN SAFE for this quant family: every UD-Q4_K_XL tensor
# is <= its UD-Q5_K_XL counterpart (measured: Q4 averages 5.468 GiB/MoE
# block vs Q5's 6.635 GiB, ~82.4% of Q5's size, from actual GGUF tensor
# metadata -- see session notes), so a split that fit Q5 is guaranteed to
# fit Q4 on a clean 4-GPU set. This script measures the REAL numbers
# rather than assuming the ~82.4% ratio carries through uniformly.
#
# ============================================================================
# WHY THIS BRIEFLY STOPS PRODUCTION (unlike bin/15/16's "stay online" scripts):
# investigation during this session found that UD-Q4_K_XL (467 GB) and
# UD-Q5_K_XL (562 GB) combined (~1029 GB) EXCEED this box's total 896 GB
# pool (384 GB VRAM + 512 GB RAM) by ~133 GB even before KV-cache/compute --
# confirmed against live numbers (only ~116 GiB combined GPU free and ~131
# GiB RAM "available" while Q5 runs, nowhere near Q4's ~467 GB own weight
# requirement). True concurrent residency of both quants is NOT possible on
# this hardware, regardless of placement -- this is a raw capacity ceiling,
# not a tuning problem. Per explicit user decision, Q4 and Q5 will be
# installed as separate systemd services that are swapped (stop one, start
# the other), never run loaded simultaneously. This script therefore
# measures Q4 the same way bin/07 measured Q5: on a CLEAN GPU set, briefly
# stopping the production Q5 service for the duration of these 2 probes,
# then restarting it via a trap-guarded cleanup that runs no matter how
# this script exits.
# ============================================================================
#
# Run manually (not by the assistant, same as bin/06/07), under tmux:
#   tmux new -s glm-q4-kv-768-896
#   bash 18-tune-q4-kv-cache-768-896.sh
#   (Ctrl-b d to detach, `tmux attach -t glm-q4-kv-768-896` to check back in)
#
# Prereqs:
#   - bin/00-download-glm-quants.sh has fully downloaded UD-Q4_K_XL (confirm
#     via bin/04-dl-status.sh)
#   - llama-glm-5.2.service (Q5 production) may be running or stopped --
#     this script handles either starting state and restores whichever it
#     found (see cleanup() below)

set -uo pipefail  # NOT -e: a single failed probe must not abort the script

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

BIN=/data/llama.cpp-dsa/build/bin/llama-server
MODEL_DIR=/data/llama_cpp/models/GLM-5.2-GGUF/UD-Q4_K_XL
QUANT_LABEL="UD-Q4_K_XL"
PORT=8091
HOST=127.0.0.1
STARTUP_TIMEOUT=5400   # 90 min -- generous for a cold ~467 GB load
DRAIN_TIMEOUT=120       # seconds to wait for GPU memory to clear after stop

PROD_SERVICE=llama-glm-5.2.service

# Reused unchanged from Q5's validated placement (bin/06/07) -- see header
# for why this is guaranteed safe for Q4 too. NOT re-optimized for Q4 here
# on purpose -- this script's job is a like-for-like measurement at the
# SAME placement Q5 uses, for direct comparability; a more aggressive
# Q4-specific rebalance is a separate, later exercise if wanted.
NCMOE=54
TENSOR_SPLIT="54,9,8,8"

# FIXED mode only, hardcoded -- exactly these two sizes, per request.
FIXED_CTX_SIZES=(768000 896000)

LOGDIR="${SCRIPT_DIR}/logs"
mkdir -p "$LOGDIR"
STAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"
SUMMARY_JSON="${LOGDIR}/${STAMP}-q4-kv-cache-768-896.json"
SUMMARY_TXT="${LOGDIR}/${STAMP}-q4-kv-cache-768-896.txt"

MODEL_FIRST_SHARD="$(ls "${MODEL_DIR}"/*-00001-of-*.gguf 2>/dev/null | head -1)"
if [ -z "$MODEL_FIRST_SHARD" ]; then
  echo "ERROR: no GGUF shards found under ${MODEL_DIR} -- run bin/04-dl-status.sh to check the download." >&2
  exit 1
fi

echo "== GLM-5.2 UD-Q4_K_XL KV-cache probe: 768K/896K (Q4 equivalent of bin/07) =="
echo "ctx sizes:  ${FIXED_CTX_SIZES[*]}"
echo "model:      ${MODEL_FIRST_SHARD}"
echo "quant:      ${QUANT_LABEL}"
echo "n-cpu-moe:  ${NCMOE}, tensor-split: ${TENSOR_SPLIT} (reused from Q5, guaranteed safe -- see header)"
echo "summary ->  ${SUMMARY_TXT}"
echo "            ${SUMMARY_JSON}"
echo

WAS_PROD_ACTIVE=0
if systemctl --user is-active --quiet "$PROD_SERVICE"; then
  WAS_PROD_ACTIVE=1
fi
echo "Production service (${PROD_SERVICE}) currently active: $([ "$WAS_PROD_ACTIVE" -eq 1 ] && echo yes || echo no)"

OTHER_CONN="$(ss -tnp 2>/dev/null | grep ":8092 " || true)"
if [ -n "$OTHER_CONN" ]; then
  echo
  echo "WARNING: existing connection(s) on production port 8092:"
  echo "$OTHER_CONN"
  echo "This script needs to stop production for a clean-GPU measurement of Q4."
  echo "Stopping it now will interrupt that session. Ctrl-C now to abort if"
  echo "that is not acceptable; continuing in 10s..."
  sleep 10
fi

cleanup() {
  local exit_code=$?
  echo
  echo "== Cleanup (exit code ${exit_code}) =="
  if [ "$WAS_PROD_ACTIVE" -eq 1 ]; then
    echo "Restoring production service (${PROD_SERVICE}) to its prior 'active' state..."
    if ! systemctl --user is-active --quiet "$PROD_SERVICE"; then
      systemctl --user start "$PROD_SERVICE" || echo "WARNING: failed to start ${PROD_SERVICE} -- start it manually and check journalctl." >&2
    fi
  else
    echo "Production service was NOT active before this script ran -- leaving it as-is (not starting it)."
  fi
  echo "Done. Verify with: systemctl --user status ${PROD_SERVICE} ; curl http://localhost:8092/health"
}
trap cleanup EXIT

if [ "$WAS_PROD_ACTIVE" -eq 1 ]; then
  echo
  echo "Stopping ${PROD_SERVICE} for a clean-GPU Q4 measurement..."
  systemctl --user stop "$PROD_SERVICE"
fi

gpu_mem_used_mib() {
  nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits | awk '{s+=$1} END {print s+0}'
}

ram_used_kib() {
  free -k | awk '/^Mem:/ {print $3}'
}

wait_for_gpu_drain() {
  local baseline="$1" elapsed=0 now
  while [ "$elapsed" -lt "$DRAIN_TIMEOUT" ]; do
    now="$(gpu_mem_used_mib)"
    if [ "$((now - baseline))" -lt 500 ]; then
      return 0
    fi
    sleep 3
    elapsed=$((elapsed + 3))
  done
  echo "WARNING: GPU memory did not fully drain within ${DRAIN_TIMEOUT}s (still ~${now} MiB used, baseline ~${baseline} MiB) -- continuing anyway" >&2
  return 0
}

echo "== Waiting for GPU memory to reach a clean baseline =="
elapsed=0
while [ "$elapsed" -lt "$DRAIN_TIMEOUT" ]; do
  USED_TOTAL="$(gpu_mem_used_mib)"
  if [ "$USED_TOTAL" -lt 5000 ]; then
    break
  fi
  sleep 3
  elapsed=$((elapsed + 3))
done
echo "GPU memory now: ${USED_TOTAL} MiB total across all GPUs"

echo "[" > "$SUMMARY_JSON"
FIRST_RESULT=1

{
  echo "GLM-5.2 UD-Q4_K_XL KV-cache probe -- 768K/896K"
  echo "model: ${MODEL_FIRST_SHARD}"
  echo "quant: ${QUANT_LABEL}"
  echo "n-cpu-moe: ${NCMOE}, tensor-split: ${TENSOR_SPLIT}"
  echo "started (UTC): ${STAMP}"
  echo
  printf '%-10s %-8s %10s %10s %14s\n' "ctx" "status" "gpu_mib" "ram_kib" "load_secs"
} | tee "$SUMMARY_TXT"

BASELINE_GPU_MIB="$(gpu_mem_used_mib)"
BASELINE_RAM_KIB="$(ram_used_kib)"
echo "baseline (clean): gpu=${BASELINE_GPU_MIB} MiB, ram=${BASELINE_RAM_KIB} KiB" | tee -a "$SUMMARY_TXT"
echo >> "$SUMMARY_TXT"

probe_ctx() {
  local ctx="$1"
  local run_log="${LOGDIR}/${STAMP}-q4-kv-ctx${ctx}.log"
  echo "== ctx=${ctx} -- starting llama-server (log: ${run_log}) =="

  "$BIN" \
    --model "$MODEL_FIRST_SHARD" \
    --host "$HOST" --port "$PORT" \
    --ctx-size "$ctx" \
    --n-gpu-layers 999 \
    --n-cpu-moe "$NCMOE" \
    --tensor-split "$TENSOR_SPLIT" \
    --load-mode none \
    --parallel 1 \
    --jinja \
    -lv 4 \
    > "$run_log" 2>&1 < /dev/null &
  local server_pid=$!

  local start_ts status elapsed http_code
  start_ts=$(date +%s)
  status="unknown"
  elapsed=0
  while true; do
    http_code="$(curl -s -o /dev/null -w '%{http_code}' "http://${HOST}:${PORT}/health" 2>/dev/null || echo "000")"
    if [ "$http_code" = "200" ]; then
      status="ok"
      break
    fi
    if ! kill -0 "$server_pid" 2>/dev/null; then
      status="crashed"
      break
    fi
    if [ "$elapsed" -ge "$STARTUP_TIMEOUT" ]; then
      status="timeout"
      break
    fi
    sleep 10
    elapsed=$((elapsed + 10))
  done
  local load_secs=$(( $(date +%s) - start_ts ))

  local gpu_mib=0 ram_kib=0
  if [ "$status" = "ok" ]; then
    gpu_mib="$(gpu_mem_used_mib)"
    ram_kib="$(ram_used_kib)"
    echo "  healthy after ~${load_secs}s -- gpu=${gpu_mib} MiB, ram=${ram_kib} KiB"
  else
    echo "  FAILED (status=${status}) after ~${load_secs}s -- see ${run_log}" >&2
    tail -n 40 "$run_log" >&2 || true
  fi

  local kv_log_lines
  kv_log_lines="$(grep -iE 'kv buffer size|state buffer size|common_memory_breakdown_print|common_params_fit_impl' "$run_log" 2>/dev/null || true)"
  P_KV_LOG_LINES="$kv_log_lines"

  echo "  stopping llama-server (pid ${server_pid})"
  kill "$server_pid" 2>/dev/null || true
  wait "$server_pid" 2>/dev/null || true
  wait_for_gpu_drain "$BASELINE_GPU_MIB"
  echo

  P_STATUS="$status"
  P_GPU_MIB="$gpu_mib"
  P_RAM_KIB="$ram_kib"
  P_LOAD_SECS="$load_secs"
  P_RUN_LOG="$run_log"
}

record_result() {
  local ctx="$1"

  printf '%-10s %-8s %10s %10s %14s\n' "$ctx" "$P_STATUS" "$P_GPU_MIB" "$P_RAM_KIB" "$P_LOAD_SECS" | tee -a "$SUMMARY_TXT"
  if [ -n "$P_KV_LOG_LINES" ]; then
    echo "  -- memory/fit-check log lines (diagnostic) --" | tee -a "$SUMMARY_TXT"
    echo "$P_KV_LOG_LINES" | sed 's/^/    /' | tee -a "$SUMMARY_TXT"
  fi

  if [ "$FIRST_RESULT" -eq 0 ]; then
    echo "," >> "$SUMMARY_JSON"
  fi
  FIRST_RESULT=0
  python3 - "$ctx" "$P_STATUS" "$P_GPU_MIB" "$P_RAM_KIB" "$P_LOAD_SECS" "$P_RUN_LOG" <<'PYEOF' >> "$SUMMARY_JSON"
import json, sys
_, ctx, status, gpu_mib, ram_kib, load_secs, run_log = sys.argv
print(json.dumps({
    "ctx_size": int(ctx),
    "status": status,
    "gpu_mem_used_mib": int(gpu_mib),
    "ram_used_kib": int(ram_kib),
    "load_secs": int(load_secs),
    "log": run_log,
}, indent=2), end="")
PYEOF
}

for CTX in "${FIXED_CTX_SIZES[@]}"; do
  probe_ctx "$CTX"
  record_result "$CTX"
done

echo "]" >> "$SUMMARY_JSON"

echo | tee -a "$SUMMARY_TXT"
echo "== Per-GPU breakdown (see each *-q4-kv-ctx*.log's common_params_fit_impl lines for authoritative used/free per GPU) ==" | tee -a "$SUMMARY_TXT"
echo "Compare against the adopted safety-margin policy (>=15% free VRAM per" | tee -a "$SUMMARY_TXT"
echo "GPU, or >=10 GiB absolute, whichever is greater) and against Q5's own" | tee -a "$SUMMARY_TXT"
echo "768K reference (CUDA0 22,710/23.3%, CUDA1 22,816/23.5%, CUDA2 30,617/31.5%," | tee -a "$SUMMARY_TXT"
echo "CUDA3 43,251/44.5% free -- bin/logs/2026-08-20T055618Z-kv-ctx768000.log)." | tee -a "$SUMMARY_TXT"

echo
echo "Full summary: ${SUMMARY_TXT}"
echo "Raw JSON:     ${SUMMARY_JSON}"
echo "Per-run logs: ${LOGDIR}/${STAMP}-q4-kv-ctx*.log"
echo
echo "(Production Q5 restart happens next, in cleanup, restoring whatever"
echo "state it was in before this script ran.)"
