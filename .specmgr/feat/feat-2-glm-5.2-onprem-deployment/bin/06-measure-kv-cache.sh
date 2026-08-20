#!/usr/bin/env bash
# Task 2.1: find the actual max context size GLM-5.2 supports on llama.cpp
# (Phase 1's confirmed-working SM120 engine) + UD-Q5_K_XL (Phase 2 target
# quant, fully downloaded as of 2026-08-19), and measure KV-cache memory
# cost along the way -- to feed Task 2.2's decision of whether UD-Q5_K_XL
# reliably supports the 350-370K REQ-003 context target with safe margin,
# or whether the UD-Q4_K_XL fallback is needed instead.
#
# Two modes:
#   - No arguments (default): ADAPTIVE mode. Ramp up through a fixed list
#     of round context sizes (4K, 32K, 128K, 256K, 512K), stopping at the
#     first failure (crash/OOM/timeout). If a failure occurs, binary-search
#     between the last known-good size and the first known-failing size
#     until the gap narrows to BISECT_MIN_GAP tokens -- directly pinpointing
#     the real ceiling instead of just extrapolating past it. This is more
#     decision-useful for Task 2.2 than a fixed sweep: it answers "what is
#     the actual max context that works" rather than "here's a guess based
#     on a slope."
#   - Arguments given: FIXED mode (unchanged from before) -- tests exactly
#     the given list of --ctx-size values, in order, no bisection. Useful
#     for a quick manual check, e.g.:
#       bash 06-measure-kv-cache.sh 4096 32768
#
# Method: llama.cpp allocates the KV cache buffer(s) once at server startup,
# sized directly from --ctx-size -- it is not grown per-request. So each
# probe starts llama-server at one context size, waits for it to become
# healthy (guaranteeing the KV buffers are already allocated) or to fail,
# records:
#   (a) total GPU memory used (sum across all 4 GPUs, nvidia-smi) and
#       system RAM used (free -h), as the primary, implementation-agnostic
#       measurement -- this is what actually answers "does it fit in the
#       896 GB pool", regardless of internal llama.cpp buffer naming.
#   (b) any KV-cache-related buffer-size lines llama.cpp prints in its own
#       log (grepped heuristically -- exact log strings are a llama.cpp
#       internal implementation detail and may not match cleanly, so this
#       is a diagnostic cross-check only, not the primary result).
# ...then stops the server, waits for GPU memory to clear, before the next
# probe. Because everything else (model, quant, --n-cpu-moe, --n-gpu-layers,
# --parallel) is held constant across runs, the model weights' contribution
# to (a) is a constant offset -- so all successful data points collected
# (ramp + bisection, or the fixed list) are also used to fit a
# GB-per-1K-tokens slope, same as a pure sweep would.
#
# GPU/CPU MoE placement (--n-cpu-moe N, NOT --cpu-moe):
# GLM-5.2 is 744B total / 40B active -- nearly all its parameters are MoE
# experts. A first attempt at this script used --cpu-moe (ALL MoE weights
# on CPU RAM), on the assumption that this would free up VRAM for the KV
# cache under test without affecting the true KV-cache-per-token cost
# (which is purely a function of attention architecture, not of where FFN/
# MoE weights live -- that reasoning was correct). What was NOT accounted
# for: --cpu-moe pushes ~500 GiB of this ~562 GiB quant onto CPU RAM alone
# (79 blocks total, 3 leading dense + 76 MoE-bearing blocks per the GGUF
# metadata, ~6.6 GiB of expert weight per MoE block) -- landing right at
# the edge of this box's 512 GiB system RAM and triggering real swapping
# during a live run (2026-08-19: swap climbed from ~0 to ~1.4 GiB in under
# a minute while RSS approached ~500/502 GiB, forcing the probe to be
# killed as a precaution against an OOM-kill).
#
# NCMOE below instead keeps only a portion of the MoE-bearing blocks on
# CPU and offloads the rest to GPU.
#
# A SECOND attempt (still 2026-08-19) used NCMOE=41 alone (no explicit
# --tensor-split), on the assumption that llama.cpp would spread the
# ~250 GiB of GPU-offloaded MoE blocks evenly across all 4 GPUs
# (~62 GiB/GPU). It does NOT: llama.cpp assigns blocks to GPUs in
# contiguous chunks (~20 blocks each, e.g. GPU0~0-19, GPU1~20-39,
# GPU2~40-59, GPU3~60-78) *before* --n-cpu-moe is applied. Since the
# cutoff (41) landed inside GPU2's chunk, GPU2 ended up owning ~19 blocks
# that are *entirely* above the cutoff -- i.e. their FULL, undiminished
# MoE weight (~132 GiB), not a fair 1/4 share -- and blew past its 96 GiB
# VRAM: "cudaMalloc failed: out of memory ... failed to allocate CUDA2
# buffer of size 138774596736" (~129 GiB attempted on one device). GPU3
# (also entirely above the cutoff) would have hit the same wall.
#
# The fix: pair --n-cpu-moe with an explicit --tensor-split so the
# CPU-side (cheap, MoE-stripped) blocks are concentrated on device0 --
# their block COUNT there doesn't matter since --n-cpu-moe already
# stripped their expert weight, leaving only small attention/embedding
# tensors -- while the GPU-offloaded (expensive, full-MoE-weight) blocks
# are explicitly, evenly spread across devices 1-3 only, at a
# deliberately conservative per-device target (well under 96 GiB, leaving
# real headroom for compute buffers + KV cache growth up to 360K
# context). Calibrated 2026-08-19 from this quant's own GGUF metadata
# (block_count=79, leading_dense_block_count=3, ~6.6 GiB of expert weight
# per MoE block, confirmed against the CUDA2 failure's own byte count):
#   NCMOE=54          -- blocks 0-53 (3 dense + 51 MoE) stay on CPU
#   TENSOR_SPLIT=54,9,8,8 -- device0 gets all 54 cheap blocks (~12.5 GiB,
#                            trivial); devices 1/2/3 get 9/8/8 of the 25
#                            GPU-offloaded MoE blocks (~59/53/53 GiB each,
#                            leaving ~37-43 GiB/GPU headroom)
# Estimated CPU RAM for MoE weights: ~336 GiB of 512 GiB total system RAM
# (down from ~500 GiB with plain --cpu-moe, but with a real safety margin
# this time rather than the ~250 GiB target that turned out to rely on an
# even-split assumption that doesn't hold). Production tuning of the
# final GPU/CPU-RAM split (Task 2.2/2.3) is a separate, later step -- this
# value is calibrated only to make the Task 2.1 measurement itself safe
# to run unattended.
#
# This is a measurement spike, not the Phase 2 systemd deployment -- each
# probe stops the server again once its data point is captured.
#
# Loading this quant (~562 GB) from disk is slow (observed ~150-230 MB/s on
# this box => ~30-45 min per cold-ish load); the adaptive sweep can involve
# 5-8+ probes and take HOURS. This is expected -- run it under
# tmux/screen/nohup:
#   tmux new -s glm-kv-sweep
#   bash 06-measure-kv-cache.sh
#   (Ctrl-b d to detach, `tmux attach -t glm-kv-sweep` to check back in)
#
# A single failed/OOM probe does not abort the run in FIXED mode; in
# ADAPTIVE mode a failure is exactly what triggers the bisection (it is the
# expected way the ceiling gets found), not an error condition.
#
# Prereqs:
#   - bin/01-clone-llama-cpp-dsa.sh + bin/02-build-llama-cpp-dsa.sh already run
#   - bin/00-download-glm-quants.sh has fully downloaded UD-Q5_K_XL
#   - GPUs free (check: nvidia-smi)
#
# Run with: bash 06-measure-kv-cache.sh
# Or, for a fixed quick check:            bash 06-measure-kv-cache.sh 4096 32768

set -uo pipefail  # NOT -e: a single failed probe must not abort the script

BIN=/data/llama.cpp-dsa/build/bin/llama-server
MODEL_DIR=/data/llama_cpp/models/GLM-5.2-GGUF/UD-Q5_K_XL
QUANT_LABEL="UD-Q5_K_XL"
PORT=8091
HOST=127.0.0.1
STARTUP_TIMEOUT=5400   # 90 min -- generous for a cold ~562 GB load
DRAIN_TIMEOUT=120      # seconds to wait for GPU memory to clear after stop

# --n-cpu-moe + --tensor-split: see the full incident/rationale in the
# NCMOE comment block above. NCMOE keeps blocks 0-53 on CPU; TENSOR_SPLIT
# forces devices 1-3 to each get a small, explicit, safe share of the
# remaining 25 GPU-offloaded MoE blocks (device0 absorbs all the cheap
# CPU-side blocks, which cost it almost nothing since their expert weight
# was already stripped to CPU).
NCMOE=54
TENSOR_SPLIT="54,9,8,8"

# ADAPTIVE mode config: 4K, 32K, 128K, 256K, 512K ramp -- round numbers,
# each roughly doubling, span from negligible-KV to comfortably past the
# 350-370K REQ-003 target. If a step fails, bisect between the last good
# and first failing size until the gap is <= BISECT_MIN_GAP tokens (or
# MAX_BISECT_ITERS is hit, as a safety cap against pathological rounding).
RAMP_CTX_SIZES=(4096 32768 131072 262144 524288)
BISECT_MIN_GAP=16384
MAX_BISECT_ITERS=8

MODE="adaptive"
if [ "$#" -gt 0 ]; then
  MODE="fixed"
  FIXED_CTX_SIZES=("$@")
fi

LOGDIR="$(cd "$(dirname "$0")" && pwd)/logs"
mkdir -p "$LOGDIR"
STAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"
SUMMARY_JSON="${LOGDIR}/${STAMP}-kv-cache-sweep.json"
SUMMARY_TXT="${LOGDIR}/${STAMP}-kv-cache-sweep.txt"

MODEL_FIRST_SHARD="$(ls "${MODEL_DIR}"/*-00001-of-*.gguf 2>/dev/null | head -1)"
if [ -z "$MODEL_FIRST_SHARD" ]; then
  echo "ERROR: no GGUF shards found under ${MODEL_DIR} -- has the download finished?" >&2
  exit 1
fi

echo "== GLM-5.2 KV-cache / max-context probe (Task 2.1) =="
echo "mode:       ${MODE}"
if [ "$MODE" = "adaptive" ]; then
  echo "ramp:       ${RAMP_CTX_SIZES[*]}"
  echo "bisect to:  ${BISECT_MIN_GAP} tokens resolution (max ${MAX_BISECT_ITERS} iterations)"
else
  echo "ctx sizes:  ${FIXED_CTX_SIZES[*]}"
fi
echo "model:      ${MODEL_FIRST_SHARD}"
echo "quant:      ${QUANT_LABEL}"
echo "n-cpu-moe:  ${NCMOE}, tensor-split: ${TENSOR_SPLIT} (~336 GiB CPU / conservative per-GPU MoE split, see script header)"
echo "summary ->  ${SUMMARY_TXT}"
echo "            ${SUMMARY_JSON}"
echo

gpu_mem_used_mib() {
  # Sum of memory.used across all GPUs, in MiB (integer).
  nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits | awk '{s+=$1} END {print s+0}'
}

ram_used_kib() {
  # "used" column from `free`, in KiB.
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

# JSON array accumulated across the run; written incrementally so a Ctrl-C
# or crash mid-run still leaves earlier results on disk.
echo "[" > "$SUMMARY_JSON"
FIRST_RESULT=1

{
  echo "GLM-5.2 KV-cache / max-context probe -- Task 2.1"
  echo "mode: ${MODE}"
  echo "model: ${MODEL_FIRST_SHARD}"
  echo "quant: ${QUANT_LABEL}"
  echo "started (UTC): ${STAMP}"
  echo
  printf '%-10s %-8s %10s %10s %14s\n' "ctx" "status" "gpu_mib" "ram_kib" "load_secs"
} | tee "$SUMMARY_TXT"

BASELINE_GPU_MIB="$(gpu_mem_used_mib)"
BASELINE_RAM_KIB="$(ram_used_kib)"
echo "baseline (idle): gpu=${BASELINE_GPU_MIB} MiB, ram=${BASELINE_RAM_KIB} KiB" | tee -a "$SUMMARY_TXT"
echo >> "$SUMMARY_TXT"

# probe_ctx CTX -- starts llama-server at --ctx-size CTX, waits for it to
# become healthy or fail, records memory usage, stops it again, and sets
# the globals: P_STATUS (ok|crashed|timeout), P_GPU_MIB, P_RAM_KIB,
# P_LOAD_SECS, P_RUN_LOG.
probe_ctx() {
  local ctx="$1"
  local run_log="${LOGDIR}/${STAMP}-kv-ctx${ctx}.log"
  echo "== ctx=${ctx} -- starting llama-server (log: ${run_log}) =="

  "$BIN" \
    --model "$MODEL_FIRST_SHARD" \
    --host "$HOST" --port "$PORT" \
    --ctx-size "$ctx" \
    --n-gpu-layers 999 \
    --n-cpu-moe "$NCMOE" \
    --tensor-split "$TENSOR_SPLIT" \
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

  # Diagnostic-only: heuristically grep the log for any KV/state buffer
  # size lines llama.cpp printed (format is an internal detail and may not
  # match every version -- absence of a match is not an error).
  local kv_log_lines
  kv_log_lines="$(grep -iE 'kv buffer size|state buffer size|creating (main|indexer|DSV4)[^=]*(size|cells)' "$run_log" 2>/dev/null || true)"
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

# record_result CTX -- appends the P_* globals (set by the preceding
# probe_ctx call) as one JSON object to SUMMARY_JSON, and a row to
# SUMMARY_TXT.
record_result() {
  local ctx="$1"

  printf '%-10s %-8s %10s %10s %14s\n' "$ctx" "$P_STATUS" "$P_GPU_MIB" "$P_RAM_KIB" "$P_LOAD_SECS" | tee -a "$SUMMARY_TXT"
  if [ -n "$P_KV_LOG_LINES" ]; then
    echo "  -- KV-related log lines (diagnostic only) --" | tee -a "$SUMMARY_TXT"
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

LAST_OK=""       # largest context size confirmed working so far
FIRST_FAIL=""    # smallest context size confirmed failing so far

if [ "$MODE" = "fixed" ]; then
  for CTX in "${FIXED_CTX_SIZES[@]}"; do
    probe_ctx "$CTX"
    record_result "$CTX"
  done
else
  echo "== Ramp phase =="
  for CTX in "${RAMP_CTX_SIZES[@]}"; do
    probe_ctx "$CTX"
    record_result "$CTX"
    if [ "$P_STATUS" = "ok" ]; then
      LAST_OK="$CTX"
    else
      FIRST_FAIL="$CTX"
      echo "Ramp stopped: ctx=${CTX} failed (status=${P_STATUS})."
      break
    fi
  done

  if [ -z "$FIRST_FAIL" ]; then
    echo "All ramp sizes succeeded up to ${RAMP_CTX_SIZES[-1]} -- no ceiling found in the tested range." | tee -a "$SUMMARY_TXT"
  elif [ -z "$LAST_OK" ]; then
    echo "Even the smallest ramp size (${RAMP_CTX_SIZES[0]}) failed -- investigate before re-running (see log above); skipping bisection." | tee -a "$SUMMARY_TXT"
  else
    echo | tee -a "$SUMMARY_TXT"
    echo "== Bisection phase: narrowing between last-good=${LAST_OK} and first-failing=${FIRST_FAIL} ==" | tee -a "$SUMMARY_TXT"
    iter=0
    while [ "$((FIRST_FAIL - LAST_OK))" -gt "$BISECT_MIN_GAP" ] && [ "$iter" -lt "$MAX_BISECT_ITERS" ]; do
      iter=$((iter + 1))
      MID=$(( LAST_OK + (FIRST_FAIL - LAST_OK) / 2 ))
      echo "-- bisection iteration ${iter}: trying ctx=${MID} (between ${LAST_OK} ok and ${FIRST_FAIL} failing) --"
      probe_ctx "$MID"
      record_result "$MID"
      if [ "$P_STATUS" = "ok" ]; then
        LAST_OK="$MID"
      else
        FIRST_FAIL="$MID"
      fi
    done
    echo | tee -a "$SUMMARY_TXT"
    echo "== Bisection result ==" | tee -a "$SUMMARY_TXT"
    echo "Max verified working context size: ${LAST_OK}" | tee -a "$SUMMARY_TXT"
    echo "Smallest known-failing context size: ${FIRST_FAIL}" | tee -a "$SUMMARY_TXT"
    echo "(gap narrowed to ${BISECT_MIN_GAP} tokens or ${MAX_BISECT_ITERS} iterations, whichever came first)" | tee -a "$SUMMARY_TXT"
  fi
fi

echo "]" >> "$SUMMARY_JSON"

echo | tee -a "$SUMMARY_TXT"
echo "== Deriving GB-per-1K-tokens from all successful data points ==" | tee -a "$SUMMARY_TXT"
python3 - "$SUMMARY_JSON" "$SUMMARY_TXT" <<'PYEOF'
import json, sys

summary_json, summary_txt = sys.argv[1], sys.argv[2]
with open(summary_json) as f:
    results = json.load(f)

ok = [r for r in results if r["status"] == "ok"]
lines = []

if len(ok) < 2:
    lines.append(f"Only {len(ok)} successful data point(s) -- need at least 2 to derive a slope.")
    lines.append("Re-run with more/different context sizes, or check the failures above.")
else:
    ok.sort(key=lambda r: r["ctx_size"])
    # total "footprint" = GPU used + RAM used, in GiB, per context size
    def total_gib(r):
        return (r["gpu_mem_used_mib"] / 1024.0) + (r["ram_used_kib"] / (1024.0 * 1024.0))

    # Simple least-squares fit: total_gib = intercept (weights) + slope * ctx_size
    xs = [r["ctx_size"] for r in ok]
    ys = [total_gib(r) for r in ok]
    n = len(xs)
    mean_x = sum(xs) / n
    mean_y = sum(ys) / n
    num = sum((x - mean_x) * (y - mean_y) for x, y in zip(xs, ys))
    den = sum((x - mean_x) ** 2 for x in xs)
    if den == 0:
        lines.append("All data points have the same ctx_size -- cannot fit a slope.")
    else:
        slope = num / den          # GiB per context token
        intercept = mean_y - slope * mean_x  # GiB, ~constant weights/runtime footprint
        gib_per_1k = slope * 1024

        lines.append(f"Linear fit over {n} points: total_gib ~= {intercept:.1f} + {slope:.6f} * ctx_size")
        lines.append(f"=> KV cache cost: ~{gib_per_1k:.3f} GiB per 1K context tokens")
        lines.append(f"=> Estimated fixed footprint (weights/runtime, ctx-independent): ~{intercept:.1f} GiB")
        lines.append("")
        lines.append("Extrapolation to REQ-003 targets (fixed footprint + KV cache only, no safety margin):")
        for target in (350_000, 370_000):
            est = intercept + slope * target
            lines.append(f"  ctx={target:>7,}: ~{est:.1f} GiB total")
        lines.append("")
        lines.append("Compare against the 896 GB pool (384 GB VRAM + 512 GB RAM) with a safety")
        lines.append("margin for OS/other overhead, AND against the directly-verified max working")
        lines.append("context size (bisection result above, if adaptive mode was used) -- together")
        lines.append("these feed Task 2.2's UD-Q5_K_XL vs UD-Q4_K_XL call.")

for line in lines:
    print(line)

with open(summary_txt, "a") as f:
    f.write("\n".join(lines) + "\n")
PYEOF

echo
echo "Full summary: ${SUMMARY_TXT}"
echo "Raw JSON:     ${SUMMARY_JSON}"
echo "Per-run logs: ${LOGDIR}/${STAMP}-kv-ctx*.log"
