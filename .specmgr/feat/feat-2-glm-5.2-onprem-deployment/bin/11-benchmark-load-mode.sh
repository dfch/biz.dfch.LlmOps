#!/usr/bin/env bash
# Task 2.2.1: benchmark `--load-mode none` (direct/eager read) against the
# `mmap` default for UD-Q5_K_XL cold-load wall-clock time. See the feat
# README, Decisions Made 2026-08-20 "load-mode/cold-load-time discussion"
# and "swap policy", for the full rationale:
#   - This box is power-cycled at the start of each ~8.4h working day (not
#     left running long-term), so the observed ~45min mmap cold load
#     (bin/logs/2026-08-20T055618Z-kv-ctx768000.log) is a RECURRING daily
#     cost (~9% of the working day), not a rare/one-time restart cost.
#   - `--load-mode none` trades mmap's lazy CPU-RAM residency (only
#     actively-routed MoE experts get faulted in -- see the ~11.6-11.8 GiB
#     actually-resident figure from Task 2.1 vs. the ~350 GiB logically
#     mapped) for a faster, eager, sequential disk read at startup. That
#     trade is judged acceptable here specifically because this box runs
#     GLM-5.2 EXCLUSIVELY once in production use (no other RAM consumers).
#   - No hard number exists yet for the actual speedup (depends on this
#     storage medium's random-vs-sequential I/O characteristics) -- this
#     script exists to replace that reasoning with a real measurement.
#
# Sequenced BEFORE Task 2.3's systemd install (not after Task 2.4 start):
# the winning `--load-mode` is an input to bin/08-llama-glm-5.2.service,
# same as the finalized --ctx-size/--tensor-split values, so it should be
# resolved before the service is installed, not after.
#
# Context size: fixed at 896,000 tokens per explicit instruction (NOT the
# small ctx=4096 shape originally suggested in the task description). This
# is deliberate: the --load-mode difference is about the tensor-LOADING
# phase (reading/mapping the ~524 GiB GGUF file), which is essentially
# independent of --ctx-size -- KV-cache allocation is a separate, fast
# step afterward -- so a small context would have been sufficient. Using
# 896,000 instead (the larger of Task 2.3's own Track A gray-zone probes)
# means this run's "mmap-default" probe also incidentally re-exercises
# that exact context size, as a bonus cross-check -- NOT a replacement for
# Track A's own bin/07-measure-kv-cache-768-896.sh pass/fail per-GPU
# margin analysis, which is the authoritative result for that question.
#
# Two probes, same quant/placement (--n-cpu-moe 54 --tensor-split
# 54,9,8,8) as validated in Task 2.1/2.2, differing ONLY in --load-mode:
#   1. mmap-default   -- llama.cpp's default, no extra flag
#   2. load-mode-none  -- --load-mode none
# For each: start llama-server, wait for /health, record wall-clock load
# time (the deciding metric) plus GPU/RAM memory used as a secondary
# cross-check. `load-mode-none` is expected to show much higher resident
# RAM (close to the full ~350 GiB CPU-side portion) than `mmap-default`
# (which only pages in what this cold-start/health-check actually
# touches) -- that RAM difference is informational, not the deciding
# metric; wall-clock load time is.
#
# Whichever mode loads faster should be fed into Task 2.3's
# bin/08-llama-glm-5.2.service --load-mode flag before install.
#
# Loading this quant (~562 GB) from disk is slow (~150-230 MB/s observed
# on this box) -- each probe can take 30-45+ min, so this whole script can
# run over an hour. Run under tmux, same as bin/06/07:
#   tmux new -s glm-load-mode-bench
#   bash 11-benchmark-load-mode.sh
#   (Ctrl-b d to detach, `tmux attach -t glm-load-mode-bench` to check back in)
#
# Prereqs: same as bin/06/07 -- llama.cpp built (bin/01/02), UD-Q5_K_XL
# fully downloaded (bin/00/04), GPUs free (check: nvidia-smi).
#
# Run with: bash 11-benchmark-load-mode.sh
set -uo pipefail  # NOT -e: a single failed probe must not abort the script

BIN=/data/llama.cpp-dsa/build/bin/llama-server
MODEL_DIR=/data/llama_cpp/models/GLM-5.2-GGUF/UD-Q5_K_XL
QUANT_LABEL="UD-Q5_K_XL"
PORT=8091
HOST=127.0.0.1
STARTUP_TIMEOUT=5400   # 90 min -- generous for a cold ~562 GB load
DRAIN_TIMEOUT=120      # seconds to wait for GPU memory to clear after stop

# --n-cpu-moe + --tensor-split: unchanged from the validated Task 2.1/2.2
# placement (see bin/06-measure-kv-cache.sh header for the full incident
# history). Only --load-mode varies between the two probes below.
NCMOE=54
TENSOR_SPLIT="54,9,8,8"

CTX=896000   # fixed, per explicit instruction -- see header

# Modes to compare, in order: (label, extra llama-server flags)
MODE_LABELS=("mmap-default" "load-mode-none")
MODE_FLAGS=("" "--load-mode none")

LOGDIR="$(cd "$(dirname "$0")" && pwd)/logs"
mkdir -p "$LOGDIR"
STAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"
SUMMARY_JSON="${LOGDIR}/${STAMP}-load-mode-bench.json"
SUMMARY_TXT="${LOGDIR}/${STAMP}-load-mode-bench.txt"

MODEL_FIRST_SHARD="$(ls "${MODEL_DIR}"/*-00001-of-*.gguf 2>/dev/null | head -1)"
if [ -z "$MODEL_FIRST_SHARD" ]; then
  echo "ERROR: no GGUF shards found under ${MODEL_DIR} -- has the download finished?" >&2
  exit 1
fi

echo "== GLM-5.2 --load-mode benchmark: mmap (default) vs none (Task 2.2.1) =="
echo "ctx size:   ${CTX} (fixed, per explicit instruction)"
echo "model:      ${MODEL_FIRST_SHARD}"
echo "quant:      ${QUANT_LABEL}"
echo "n-cpu-moe:  ${NCMOE}, tensor-split: ${TENSOR_SPLIT}"
echo "modes:      ${MODE_LABELS[*]}"
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
  echo "GLM-5.2 --load-mode benchmark -- Task 2.2.1"
  echo "ctx: ${CTX}"
  echo "model: ${MODEL_FIRST_SHARD}"
  echo "quant: ${QUANT_LABEL}"
  echo "started (UTC): ${STAMP}"
  echo
  printf '%-16s %-8s %10s %10s %14s\n' "mode" "status" "gpu_mib" "ram_kib" "load_secs"
} | tee "$SUMMARY_TXT"

BASELINE_GPU_MIB="$(gpu_mem_used_mib)"
BASELINE_RAM_KIB="$(ram_used_kib)"
echo "baseline (idle): gpu=${BASELINE_GPU_MIB} MiB, ram=${BASELINE_RAM_KIB} KiB" | tee -a "$SUMMARY_TXT"
echo >> "$SUMMARY_TXT"

# probe_mode LABEL EXTRA_FLAGS -- starts llama-server at --ctx-size $CTX
# with the given extra flags (e.g. "--load-mode none"), waits for it to
# become healthy or fail, records wall-clock load time + memory usage,
# stops it again. Sets globals: P_STATUS (ok|crashed|timeout), P_GPU_MIB,
# P_RAM_KIB, P_LOAD_SECS, P_RUN_LOG.
probe_mode() {
  local label="$1" extra_flags="$2"
  local run_log="${LOGDIR}/${STAMP}-load-mode-${label}.log"
  echo "== mode=${label} (flags: '${extra_flags}') -- starting llama-server (log: ${run_log}) =="

  # shellcheck disable=SC2086 -- extra_flags is intentionally word-split
  # (empty for mmap-default, "--load-mode none" for the other probe)
  "$BIN" \
    --model "$MODEL_FIRST_SHARD" \
    --host "$HOST" --port "$PORT" \
    --ctx-size "$CTX" \
    --n-gpu-layers 999 \
    --n-cpu-moe "$NCMOE" \
    --tensor-split "$TENSOR_SPLIT" \
    --parallel 1 \
    --jinja \
    -lv 4 \
    $extra_flags \
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
    echo "  healthy after ~${load_secs}s (~$((load_secs / 60))m) -- gpu=${gpu_mib} MiB, ram=${ram_kib} KiB"
  else
    echo "  FAILED (status=${status}) after ~${load_secs}s -- see ${run_log}" >&2
    tail -n 40 "$run_log" >&2 || true
  fi

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

# record_result LABEL -- appends the P_* globals (set by the preceding
# probe_mode call) as one JSON object to SUMMARY_JSON, and a row to
# SUMMARY_TXT.
record_result() {
  local label="$1"

  printf '%-16s %-8s %10s %10s %14s\n' "$label" "$P_STATUS" "$P_GPU_MIB" "$P_RAM_KIB" "$P_LOAD_SECS" | tee -a "$SUMMARY_TXT"

  if [ "$FIRST_RESULT" -eq 0 ]; then
    echo "," >> "$SUMMARY_JSON"
  fi
  FIRST_RESULT=0
  python3 - "$label" "$P_STATUS" "$P_GPU_MIB" "$P_RAM_KIB" "$P_LOAD_SECS" "$P_RUN_LOG" <<'PYEOF' >> "$SUMMARY_JSON"
import json, sys
_, label, status, gpu_mib, ram_kib, load_secs, run_log = sys.argv
print(json.dumps({
    "mode": label,
    "status": status,
    "gpu_mem_used_mib": int(gpu_mib),
    "ram_used_kib": int(ram_kib),
    "load_secs": int(load_secs),
    "log": run_log,
}, indent=2), end="")
PYEOF
}

for i in "${!MODE_LABELS[@]}"; do
  probe_mode "${MODE_LABELS[$i]}" "${MODE_FLAGS[$i]}"
  record_result "${MODE_LABELS[$i]}"
done

echo "]" >> "$SUMMARY_JSON"

echo | tee -a "$SUMMARY_TXT"
echo "== Comparison ==" | tee -a "$SUMMARY_TXT"
python3 - "$SUMMARY_JSON" "$SUMMARY_TXT" <<'PYEOF'
import json, sys

summary_json, summary_txt = sys.argv[1], sys.argv[2]
with open(summary_json) as f:
    results = json.load(f)

lines = []
ok = [r for r in results if r["status"] == "ok"]

if len(ok) < 2:
    lines.append(f"Only {len(ok)}/{len(results)} mode(s) loaded successfully -- cannot compare.")
    for r in results:
        lines.append(f"  {r['mode']}: status={r['status']} (see {r['log']})")
else:
    ok_sorted = sorted(ok, key=lambda r: r["load_secs"])
    fastest = ok_sorted[0]
    for r in ok_sorted:
        mins = r["load_secs"] / 60.0
        ram_gib = r["ram_used_kib"] / (1024.0 * 1024.0)
        lines.append(f"  {r['mode']:<16} load={r['load_secs']}s (~{mins:.1f}m)  ram_used=~{ram_gib:.1f} GiB")
    slower = ok_sorted[-1]
    if slower["load_secs"] > 0:
        pct = 100.0 * (slower["load_secs"] - fastest["load_secs"]) / slower["load_secs"]
        lines.append("")
        lines.append(f"Fastest: {fastest['mode']} ({fastest['load_secs']}s) -- "
                      f"{pct:.0f}% faster than {slower['mode']} ({slower['load_secs']}s)")
    lines.append("")
    lines.append(f"RECOMMENDATION: adopt --load-mode matching '{fastest['mode']}' in "
                 f"bin/08-llama-glm-5.2.service before Task 2.3 install.")
    lines.append("Note: RAM-used figures above are a secondary cross-check, not the deciding")
    lines.append("metric -- 'load-mode-none' is expected to show much higher resident RAM")
    lines.append("(close to the full ~350 GiB CPU-side portion) than 'mmap-default' (which")
    lines.append("only pages in what this specific cold-start/health-check actually touches),")
    lines.append("per the mmap-laziness discussion in the README's Decisions Made.")

for line in lines:
    print(line)

with open(summary_txt, "a") as f:
    f.write("\n".join(lines) + "\n")
PYEOF

echo
echo "Full summary:  ${SUMMARY_TXT}"
echo "Raw JSON:      ${SUMMARY_JSON}"
echo "Per-mode logs: ${LOGDIR}/${STAMP}-load-mode-*.log"
