#!/usr/bin/env bash
# Corrected copy of bin/17-tune-q4-placement.sh -- same purpose (finds a
# good --n-cpu-moe/--tensor-split placement for UD-Q4_K_XL rather than
# blindly reusing UD-Q5_K_XL's validated 54,9,8,8), same candidate list,
# same "kill right after the sub-second fit-check" technique. See bin/17's
# header for the full rationale; not repeated here.
#
# WHY THIS COPY EXISTS (bug found 2026-08-22): bin/17 hardcodes
# `PROD_SERVICE=llama-glm-5.2.service` (Q5) as "the thing to stop before
# probing" and "the thing to restart in cleanup" -- written before Task
# 3.4 installed llama-glm-5.2-q4.service as a real side-by-side systemd
# unit. When bin/17 was actually run with Q4 (not Q5) as the live
# production-equivalent service, it saw Q5 already inactive, concluded
# "nothing to stop," and launched all 3 candidates straight into a GPU
# state Q4 had already mostly filled -- every candidate OOM'd on CUDA1
# (see bin/logs/2026-08-22T121941Z-tune-q4-placement/*.log). Its cleanup
# trap then made things worse: it unconditionally started Q5 regardless
# of whether Q5 was the one running before, which fought over the same
# GPU memory Q4 was still holding and put Q5 into a `Restart=on-failure`
# crash loop (caught and stopped manually the same session).
#
# THE FIX: this script auto-detects whichever of the two GLM services
# (Q5 or Q4) is actually active when it starts, stops THAT one for the
# duration of the trials, and restarts THAT SAME one in cleanup --
# instead of hardcoding Q5 in either direction. No parameters or env vars
# needed either way; the detection is automatic.
#
# ============================================================================
# THIS SCRIPT STOPS WHICHEVER GLM SERVICE (Q5 or Q4) IS CURRENTLY ACTIVE for
# the duration of the trials (expected: seconds to low minutes total, NOT a
# full cold load, since every candidate is killed right after its fit
# diagnostic prints) and restarts THAT SAME service afterward via a
# trap-guarded cleanup that runs on any exit path. Still not fully
# risk-free (a candidate could behave unexpectedly), so this is
# deliberately NOT run automatically -- read this header, confirm no one
# else needs the endpoint right now (`ss -tnp | grep -E ':(8092|8093) '`),
# then run manually: bash 23-tune-q4-placement-v2.sh
# ============================================================================
#
# What it does, per candidate (n_cpu_moe, tensor_split) pair -- identical
# to bin/17:
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
# bin/24-benchmark-q4-vs-q5-v2.sh once updated to take the tuned placement
# as parameters instead of hardcoding Q5's values).
#
# Usage: bash 23-tune-q4-placement-v2.sh
# (Not executed automatically -- prepared for manual review/run first.)

set -uo pipefail   # NOT -e: individual candidate failures must not abort the whole sweep

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

LLAMA_BIN=/data/llama.cpp-dsa/build/bin/llama-server
Q4_MODEL_DIR=/data/llama_cpp/models/GLM-5.2-GGUF/UD-Q4_K_XL
Q5_SERVICE=llama-glm-5.2.service
Q4_SERVICE=llama-glm-5.2-q4.service
AD_HOC_HOST=127.0.0.1
AD_HOC_PORT=8094         # 8090=Phase1 spikes, 8091=Task2.1/2.2, 8092=Q5 prod, 8093=Q4 prod, 8094=this tuning sweep (bin/17 and this copy both use it, never concurrently)
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
RUN_DIR="${LOGDIR}/${STAMP}-tune-q4-placement-v2"
mkdir -p "$RUN_DIR"

Q4_MODEL_FIRST_SHARD="$(ls "${Q4_MODEL_DIR}"/*-00001-of-*.gguf 2>/dev/null | head -1)"
if [ -z "$Q4_MODEL_FIRST_SHARD" ]; then
  echo "ERROR: no GGUF shards found under ${Q4_MODEL_DIR} -- run bin/04-dl-status.sh to check the download." >&2
  exit 1
fi

echo "== Pre-flight checks =="
echo "Q4 model: ${Q4_MODEL_FIRST_SHARD}"

# Auto-detect whichever GLM service is actually active right now -- do NOT
# assume it's Q5. This is the core fix over bin/17.
ACTIVE_SERVICE=""
ACTIVE_PORT=""
if systemctl --user is-active --quiet "$Q5_SERVICE"; then
  ACTIVE_SERVICE="$Q5_SERVICE"
  ACTIVE_PORT=8092
elif systemctl --user is-active --quiet "$Q4_SERVICE"; then
  ACTIVE_SERVICE="$Q4_SERVICE"
  ACTIVE_PORT=8093
fi

echo -n "Active GLM service: "
if [ -n "$ACTIVE_SERVICE" ]; then
  echo "${ACTIVE_SERVICE} (port ${ACTIVE_PORT})"
else
  echo "none (neither ${Q5_SERVICE} nor ${Q4_SERVICE} is currently running)"
fi

if [ -n "$ACTIVE_PORT" ]; then
  OTHER_CONN="$(ss -tnp 2>/dev/null | grep ":${ACTIVE_PORT} " || true)"
  if [ -n "$OTHER_CONN" ]; then
    echo
    echo "WARNING: existing connection(s) on ${ACTIVE_SERVICE}'s port ${ACTIVE_PORT}:"
    echo "$OTHER_CONN"
    echo "Stopping the service now will interrupt that session. Ctrl-C now to"
    echo "abort if that is not acceptable; continuing in 10s..."
    sleep 10
  fi
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
  if [ -n "$ACTIVE_SERVICE" ]; then
    echo "Ensuring ${ACTIVE_SERVICE} (the service that was active before this script ran) is running..."
    if ! systemctl --user is-active --quiet "$ACTIVE_SERVICE"; then
      systemctl --user start "$ACTIVE_SERVICE" || echo "WARNING: failed to start ${ACTIVE_SERVICE} -- start it manually and check journalctl." >&2
    fi
    echo "Done. Verify with: systemctl --user status ${ACTIVE_SERVICE}"
  else
    echo "No GLM service was active before this script ran -- nothing to restart."
  fi
}
trap cleanup EXIT

if [ -n "$ACTIVE_SERVICE" ]; then
  echo
  echo "Stopping ${ACTIVE_SERVICE} for the duration of the trials..."
  systemctl --user stop "$ACTIVE_SERVICE"
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

  # NOTE: `stdbuf -oL` forces line-buffered stdout. Without it, glibc
  # fully-buffers stdout when it's not a TTY (our redirect to $CAND_LOG
  # triggers this) -- llama-server's INFO-level "successfully fit params"
  # line sits in that buffer and is lost forever on SIGKILL (which skips
  # any atexit/stdio flush), since we deliberately kill the process within
  # seconds, long before the buffer would fill or the process would exit
  # normally. Discovered 2026-08-22: every one of this script's first run's
  # 3 candidate logs stopped at an identical ~3445 bytes (just under
  # glibc's default 4096-byte block-buffer size), always right before
  # where the fit-check line should appear -- confirming the buffer was
  # never flushed, not that the fit-check never ran. (Fatal/OOM errors
  # were unaffected by this bug since glibc's stderr is unbuffered by
  # default -- that's why bin/17's original run still SHOWED its OOM
  # failures correctly, even though it could never have shown a success.)
  #
  # SECOND BUG found 2026-08-22 (later, after the stdbuf fix above still
  # produced 3 more identical ~3445-byte/35-line truncations across 3
  # separate clean runs, none reaching the fit-check line): missing
  # `-lv 4`. `common_fit_params: successfully fit params to free device
  # memory` is an INFO-level line, suppressed at the default verbosity 3
  # this script (and bin/17 before it) always ran at -- so the target
  # string could never appear, success or not, regardless of the stdbuf
  # fix. Confirmed by comparing against bin/07-measure-kv-cache-768-896.sh
  # (which DID capture this line for Task 2.1/2.2/3.4) and found it
  # explicitly passes `-lv 4`; the only occurrence of a
  # `common_fit_params` line anywhere in this script's own logs was the
  # WARNING-level "abort" variant in bin/17's original pre-fix run
  # (warnings print regardless of verbosity, unlike the INFO-level
  # success line). Fixed by adding `-lv 4` below, matching bin/07/bin/18's
  # proven recipe.
  stdbuf -oL "$LLAMA_BIN" \
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
    -lv 4 \
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

  # Terminate regardless of outcome -- we only need the early diagnostic,
  # never the full multi-hundred-GB tensor copy. Prefer a graceful
  # SIGTERM first (brief grace period) over an immediate SIGKILL: even
  # with `stdbuf -oL` above, a hard SIGKILL skips the process's normal
  # exit path entirely, which could still drop any not-yet-flushed
  # buffered output (e.g. the multi-line `common_memory_breakdown_print`
  # block this script's own analysis below parses) -- a graceful
  # shutdown gives it a chance to flush before it actually exits.
  if kill -0 "$CURRENT_PID" 2>/dev/null; then
    kill "$CURRENT_PID" 2>/dev/null || true
    term_wait=0
    while [ "$term_wait" -lt 5 ] && kill -0 "$CURRENT_PID" 2>/dev/null; do
      sleep 1
      term_wait=$((term_wait + 1))
    done
    kill -9 "$CURRENT_PID" 2>/dev/null || true
  fi
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
echo "or feed it directly into bin/24-benchmark-q4-vs-q5-v2.sh (update its"
echo "Q4_NCMOE/Q4_TENSOR_SPLIT variables) for the full cold-load throughput A/B."
