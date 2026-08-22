#!/usr/bin/env bash
# Finds a good --n-cpu-moe/--tensor-split placement for UD-Q4_K_XL, rather
# than blindly reusing UD-Q5_K_XL's validated 54,9,8,8 (which is SAFE for
# Q4 -- every Q4 tensor is <= its Q5 counterpart, so if it fit for Q5 it
# fits for Q4 -- but leaves real headroom unused, since Q4's MoE-expert
# blocks are measurably smaller: ~5.468 GiB avg vs Q5's ~6.635 GiB, ~82.4%
# of Q5's size, from actual GGUF tensor metadata, not an estimate).
#
# Key technique this exploits: llama-server validates whether a given
# placement fits in VRAM within under a SECOND at startup (see
# `common_params_fit_impl`/`common_fit_params` in any existing cold-load
# log, e.g. bin/logs/*-kv-ctx768000.log: "fitting params to free memory
# took 0.60 seconds") -- this happens right after reading GGUF metadata,
# WAY before the ~30-45 min tensor-copy phase begins. So each candidate
# placement can be evaluated in seconds (start, capture the early
# breakdown, kill before the expensive load), not a full cold-load per
# candidate -- turning what looked like a multi-hour tuning exercise into
# a few-minutes one.
#
# IMPORTANT: `--n-cpu-moe N` keeps the MoE weights of the FIRST N layers
# on CPU (confirmed via `llama-server --help`), and this project's own
# history (Task 2.1 incident 2) shows that changing --n-cpu-moe WITHOUT
# retuning --tensor-split in lockstep can shift full-weight layers onto a
# GPU that was expected to stay "cheap" (e.g. GPU0, which currently only
# holds attention/norm weight and depends on that headroom for its large
# KV-cache share) -- so candidates below change BOTH together, and the
# empirical fit-check (not hand-calculation) is the actual arbiter of
# whether each candidate is safe/better, exactly like Q5's own tuning.
#
# ============================================================================
# THIS SCRIPT STOPS THE PRODUCTION SERVICE (llama-glm-5.2.service) for the
# duration of the trials (expected: seconds to low minutes total, NOT a
# full cold load, since every candidate is killed right after its fit
# diagnostic prints) and restarts it afterward via a trap-guarded cleanup
# that runs on any exit path. Still not fully risk-free (a candidate could
# behave unexpectedly), so this is deliberately NOT run automatically --
# read this header, confirm no one else needs the endpoint right now
# (`ss -tnp | grep 8092`), then run manually: bash 17-tune-q4-placement.sh
# ============================================================================
#
# What it does, per candidate (n_cpu_moe, tensor_split) pair:
#   1. Starts llama-server against UD-Q4_K_XL on an ad-hoc port (127.0.0.1
#      only), with --ctx-size matching production (768000) so the
#      resulting numbers are directly comparable to Q5's known 768K
#      breakdown.
#   2. Tails its log for up to FIT_CHECK_TIMEOUT seconds, watching for the
#      "common_fit_params: successfully fit params" line (or an early
#      failure/OOM) -- NOT for full startup/health.
#   3. Kills the process immediately once that line (or a failure) is
#      seen, or once the timeout elapses (treated as inconclusive, not a
#      pass) -- long before any real tensor data would be copied.
#   4. Parses the captured `common_memory_breakdown_print` block for
#      per-GPU model/context/compute/free MiB.
#   5. Prints a comparison table across all candidates (plus the reused
#      Q5 baseline numbers, hardcoded from bin/logs/*-kv-ctx768000.log,
#      for direct reference) so a winner can be picked by inspection.
#
# This script does NOT do a full cold-load validation of the winning
# candidate -- that is a deliberate follow-up step (either as a dedicated
# full run of this script's winning config, or folded into
# bin/16-benchmark-q4-vs-q5.sh once it's updated to take the tuned
# placement as parameters instead of hardcoding Q5's values).
#
# Usage: bash 17-tune-q4-placement.sh
# (Not executed automatically -- prepared for manual review/run first.)

set -uo pipefail   # NOT -e: individual candidate failures must not abort the whole sweep

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

LLAMA_BIN=/data/llama.cpp-dsa/build/bin/llama-server
Q4_MODEL_DIR=/data/llama_cpp/models/GLM-5.2-GGUF/UD-Q4_K_XL
PROD_SERVICE=llama-glm-5.2.service
AD_HOC_HOST=127.0.0.1
AD_HOC_PORT=8094         # 8090=Phase1 spikes, 8091=Task2.1/2.2, 8092=production, 8093=bin/16's Q4 benchmark, 8094=this tuning sweep
CTX_SIZE=768000           # match production target so results are directly comparable
FIT_CHECK_TIMEOUT=60      # seconds -- generous; the fit-check itself historically takes <1s

# Candidates: "label|n_cpu_moe|tensor_split". Baseline is the known-safe
# direct Q5 reuse; A/B are progressively more aggressive shifts of blocks
# off CPU-offload, informed by (but not fully derived from) the measured
# ~28 GiB combined freed headroom on GPU1-3 if Q4 reused Q5's split
# unchanged -- see session notes for the derivation. Real answer comes
# from the fit-check output below, not this table.
declare -a CANDIDATES=(
  "baseline-reuse-q5|54|54,9,8,8"
  "candidate-A-modest|50|50,11,9,9"
  "candidate-B-aggressive|46|46,13,10,10"
)

LOGDIR="${SCRIPT_DIR}/logs"
mkdir -p "$LOGDIR"
STAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"
RUN_DIR="${LOGDIR}/${STAMP}-tune-q4-placement"
mkdir -p "$RUN_DIR"

Q4_MODEL_FIRST_SHARD="$(ls "${Q4_MODEL_DIR}"/*-00001-of-*.gguf 2>/dev/null | head -1)"
if [ -z "$Q4_MODEL_FIRST_SHARD" ]; then
  echo "ERROR: no GGUF shards found under ${Q4_MODEL_DIR} -- run bin/04-dl-status.sh to check the download." >&2
  exit 1
fi

echo "== Pre-flight checks =="
echo "Q4 model: ${Q4_MODEL_FIRST_SHARD}"
echo -n "Production service state: "
if systemctl --user is-active --quiet "$PROD_SERVICE"; then
  echo "active"
else
  echo "NOT active"
fi
OTHER_CONN="$(ss -tnp 2>/dev/null | grep ":8092 " || true)"
if [ -n "$OTHER_CONN" ]; then
  echo
  echo "WARNING: existing connection(s) on production port 8092:"
  echo "$OTHER_CONN"
  echo "Stopping the service now will interrupt that session. Ctrl-C now to"
  echo "abort if that is not acceptable; continuing in 10s..."
  sleep 10
fi

CURRENT_PID=""

cleanup() {
  local exit_code=$?
  echo
  echo "== Cleanup (exit code ${exit_code}) =="
  if [ -n "$CURRENT_PID" ] && kill -0 "$CURRENT_PID" 2>/dev/null; then
    kill -9 "$CURRENT_PID" 2>/dev/null || true
    wait "$CURRENT_PID" 2>/dev/null || true
  fi
  echo "Ensuring production service (${PROD_SERVICE}) is running..."
  if ! systemctl --user is-active --quiet "$PROD_SERVICE"; then
    systemctl --user start "$PROD_SERVICE" || echo "WARNING: failed to start ${PROD_SERVICE} -- start it manually and check journalctl." >&2
  fi
  echo "Done. Verify with: systemctl --user status ${PROD_SERVICE} ; curl http://localhost:8092/health"
}
trap cleanup EXIT

if systemctl --user is-active --quiet "$PROD_SERVICE"; then
  echo
  echo "Stopping ${PROD_SERVICE} for the duration of the trials..."
  systemctl --user stop "$PROD_SERVICE"
  echo "Waiting for GPU memory to drain..."
  for _ in $(seq 1 30); do
    USED_TOTAL="$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits | paste -sd+ | bc)"
    if [ "$USED_TOTAL" -lt 5000 ]; then
      break
    fi
    sleep 2
  done
fi

RESULT_FILES=()

for entry in "${CANDIDATES[@]}"; do
  IFS='|' read -r label ncmoe tsplit <<< "$entry"
  echo
  echo "=============================================================="
  echo "Candidate: ${label}  (--n-cpu-moe ${ncmoe} --tensor-split ${tsplit})"
  echo "=============================================================="

  CAND_LOG="${RUN_DIR}/${label}.log"

  "$LLAMA_BIN" \
    --model "$Q4_MODEL_FIRST_SHARD" \
    --alias "glm-5.2:UD-Q4_K_XL-tune" \
    --host "$AD_HOC_HOST" --port "$AD_HOC_PORT" \
    --ctx-size "$CTX_SIZE" \
    --n-gpu-layers 999 \
    --n-cpu-moe "$ncmoe" \
    --tensor-split "$tsplit" \
    --load-mode none \
    --parallel 1 \
    --jinja \
    > "$CAND_LOG" 2>&1 &
  CURRENT_PID=$!

  echo "Started pid ${CURRENT_PID}, watching for the fit-check (up to ${FIT_CHECK_TIMEOUT}s)..."
  elapsed=0
  seen_result=""
  while [ "$elapsed" -lt "$FIT_CHECK_TIMEOUT" ]; do
    if grep -q "common_fit_params: successfully fit params" "$CAND_LOG" 2>/dev/null; then
      seen_result="fit-ok"
      break
    fi
    if grep -qE "out of memory|cudaMalloc failed|error" "$CAND_LOG" 2>/dev/null; then
      seen_result="failed"
      break
    fi
    if ! kill -0 "$CURRENT_PID" 2>/dev/null; then
      seen_result="exited-early"
      break
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done

  # Kill immediately regardless of outcome -- we only need the early
  # diagnostic, never the full multi-hundred-GB tensor copy.
  kill -9 "$CURRENT_PID" 2>/dev/null || true
  wait "$CURRENT_PID" 2>/dev/null || true
  CURRENT_PID=""

  case "$seen_result" in
    fit-ok)
      echo "Result: fit-check PASSED after ~${elapsed}s (see breakdown below)" ;;
    failed)
      echo "Result: FAILED / error detected after ~${elapsed}s -- see ${CAND_LOG}" ;;
    exited-early)
      echo "Result: process exited before a fit result was seen -- see ${CAND_LOG}" ;;
    *)
      echo "Result: INCONCLUSIVE -- no fit-check result within ${FIT_CHECK_TIMEOUT}s -- see ${CAND_LOG}" ;;
  esac

  RESULT_FILES+=("${label}|${CAND_LOG}")

  # Brief pause between candidates to let GPU memory fully release.
  sleep 3
done

echo
echo "=============================================================="
echo "Comparison across all candidates"
echo "=============================================================="
python3 - "${RESULT_FILES[@]}" <<'PYEOF'
import re
import sys

entries = [e.split("|", 1) for e in sys.argv[1:]]

# Reference: Q5's actual measured 768K breakdown (bin/logs/2026-08-20T055618Z-kv-ctx768000.log),
# for side-by-side context. Fields: total/used/free are from that log's
# authoritative `common_params_fit_impl` line; model/ctx/compute are the
# `self` breakdown from the same log's `common_memory_breakdown_print` line
# (self = model + context + compute; free-after-load = total - self, which
# is close to but not identical to the fit_impl "free" figure -- a small
# ~0.5 GiB gap, presumably reserved/driver overhead not itemized here).
print(f"{'label':>22} {'GPU':>5} {'model MiB':>10} {'ctx MiB':>9} {'compute MiB':>12} {'used MiB':>9} {'free MiB':>9} {'free %':>7}")
Q5_REF = [
    ("CUDA0", 19486, 49406, 5124, 74016, 22710, 97288),
    ("CUDA1", 62690,  7968, 3252, 73910, 22816, 97288),
    ("CUDA2", 55725,  7125, 3244, 66093, 30617, 97279),
    ("CUDA3", 44990,  5250, 3236, 53475, 43251, 97288),
]
for gpu, model, ctx, compute, used, free, total in Q5_REF:
    print(f"{'(Q5 reference)':>22} {gpu:>5} {model:>10} {ctx:>9} {compute:>12} {used:>9} {free:>9} {free/total*100:>6.1f}%")
print()

# Primary, authoritative per-GPU total/used/free: the fit-check's own
# stated numbers (NOT hand-derived from the breakdown line, which uses a
# different, easy-to-mislabel "pre-load baseline free" field -- verified
# against a known-good log before trusting this format).
fit_re = re.compile(
    r"common_params_fit_impl:\s+- CUDA(\d).*?:\s*(\d+)\s*total,\s*(\d+)\s*used,\s*(\d+)\s*free"
)
# Supplementary model/ctx/compute breakdown (self = model+ctx+compute).
breakdown_re = re.compile(
    r"common_memory_breakdown_print:.*CUDA(\d).*\|\s*(\d+)\s*=\s*(\d+)\s*\+\s*\(\s*(\d+)\s*=\s*(\d+)\s*\+\s*(\d+)\s*\+\s*(\d+)\s*\)"
)

for label, log_path in entries:
    try:
        with open(log_path) as f:
            text = f.read()
    except OSError as e:
        print(f"{label}: could not read log ({e})")
        continue

    fit_by_gpu = {}
    for line in text.splitlines():
        m = fit_re.search(line)
        if m:
            gpu, total, used, free = (int(x) for x in m.groups())
            fit_by_gpu[gpu] = (total, used, free)

    breakdown_by_gpu = {}
    for line in text.splitlines():
        m = breakdown_re.search(line)
        if m:
            gpu, total, pre_free, self_used, model, ctx, compute = (int(x) for x in m.groups())
            breakdown_by_gpu[gpu] = (model, ctx, compute)

    if not fit_by_gpu:
        if "out of memory" in text or "cudaMalloc failed" in text or re.search(r"\berror\b", text, re.I):
            print(f"{label}: FAILED / error before a fit result was captured -- see {log_path}")
        else:
            print(f"{label}: no fit-check result found (candidate may need a longer FIT_CHECK_TIMEOUT) -- see {log_path}")
        print()
        continue

    for gpu in sorted(fit_by_gpu):
        total, used, free = fit_by_gpu[gpu]
        model, ctx, compute = breakdown_by_gpu.get(gpu, (None, None, None))
        model_s = f"{model:>10}" if model is not None else f"{'?':>10}"
        ctx_s = f"{ctx:>9}" if ctx is not None else f"{'?':>9}"
        compute_s = f"{compute:>12}" if compute is not None else f"{'?':>12}"
        print(f"{label:>22} {'CUDA'+str(gpu):>5} {model_s} {ctx_s} {compute_s} {used:>9} {free:>9} {free/total*100:>6.1f}%")
    print()
PYEOF

echo "Raw logs: ${RUN_DIR}/"
echo
echo "Pick the best candidate that keeps every GPU's free%/free-GiB clearing"
echo "the adopted >=15%-or->=10GiB safety-margin policy at ctx=${CTX_SIZE}, then"
echo "either re-run this script with just that candidate for a final check,"
echo "or feed it directly into bin/16-benchmark-q4-vs-q5.sh (update its"
echo "NCMOE/TENSOR_SPLIT variables) for the full cold-load throughput A/B."
