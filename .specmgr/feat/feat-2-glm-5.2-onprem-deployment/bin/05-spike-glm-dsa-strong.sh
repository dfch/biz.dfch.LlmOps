#!/usr/bin/env bash
# Strengthened follow-up to bin/03-spike-glm-dsa.sh's Task 1.2 spike, before
# considering the REQ-010 evidence solid enough to cite anywhere (e.g. as a
# comment on upstream vLLM issue #52938 -- NOT done by this script, left for
# a deliberate follow-up decision).
#
# Weaknesses of the first spike this addresses:
#   1. Truncated response -- hit max_tokens=20 mid-thought, never saw a
#      finished answer.
#   2. Single sample -- no repeat run to confirm determinism at temperature=0.
#   3. Short generation -- only 20 decode steps; some sparse-attention/KV-cache
#      bugs only surface deeper into a sequence.
#   4. Single prompt -- "say hello" doesn't exercise factual/code content.
#
# This script: starts llama-server once (same as bin/03), then runs several
# test cases through the SAME session (not restarted between cases, so later
# cases also exercise a non-trivial KV cache / more decode steps overall):
#   - hello_no_think / fact_no_think / code_no_think: chat_template_kwargs
#     {"enable_thinking": false} (per REQ-004's documented toggle) with a
#     generous max_tokens, run TWICE each at temperature=0 to check
#     determinism, so a truncation-free, checkable final answer is produced
#     every time.
#   - hello_thinking: default thinking mode, large max_tokens, single run,
#     to confirm a full (non-truncated) reasoning trace + final answer.
#
# For every response: checks the degenerate signature (same token/logprob at
# every position), and for the repeated cases, checks the two runs are
# byte-identical (temperature=0 should be deterministic).
#
# Run with: bash 05-spike-glm-dsa-strong.sh

set -euo pipefail

BIN=/data/llama.cpp-dsa/build/bin/llama-server
MODEL_DIR=/data/llama_cpp/models/GLM-5.2-GGUF/UD-IQ1_S
PORT=8090
HOST=127.0.0.1
CTX_SIZE=4096
STARTUP_TIMEOUT=1800

LOGDIR="$(cd "$(dirname "$0")" && pwd)/logs"
mkdir -p "$LOGDIR"
STAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"
SERVER_LOG="${LOGDIR}/${STAMP}-spike-strong-server.log"
RESULT_DIR="${LOGDIR}/${STAMP}-spike-strong-results"
mkdir -p "$RESULT_DIR"

MODEL_FIRST_SHARD="$(ls "${MODEL_DIR}"/*-00001-of-*.gguf 2>/dev/null | head -1)"
if [ -z "$MODEL_FIRST_SHARD" ]; then
  echo "ERROR: no GGUF shards found under ${MODEL_DIR} -- has the download finished?" >&2
  exit 1
fi

echo "== GPU state before load =="
nvidia-smi --query-gpu=index,memory.used,memory.total --format=csv

echo
echo "== Starting llama-server (model: ${MODEL_FIRST_SHARD}) =="
echo "   log: ${SERVER_LOG}"
"$BIN" \
  --model "$MODEL_FIRST_SHARD" \
  --host "$HOST" --port "$PORT" \
  --ctx-size "$CTX_SIZE" \
  --n-gpu-layers 999 \
  --jinja \
  > "$SERVER_LOG" 2>&1 &
SERVER_PID=$!

cleanup() {
  echo
  echo "== Stopping llama-server (pid ${SERVER_PID}) =="
  kill "$SERVER_PID" 2>/dev/null || true
  wait "$SERVER_PID" 2>/dev/null || true
}
trap cleanup EXIT

echo "== Waiting for server to become healthy (up to ${STARTUP_TIMEOUT}s) =="
elapsed=0
while true; do
  HTTP_CODE="$(curl -s -o /dev/null -w '%{http_code}' "http://${HOST}:${PORT}/health" 2>/dev/null || echo "000")"
  if [ "$HTTP_CODE" = "200" ]; then
    break
  fi
  if ! kill -0 "$SERVER_PID" 2>/dev/null; then
    echo "ERROR: llama-server exited early -- see ${SERVER_LOG}" >&2
    tail -n 60 "$SERVER_LOG" >&2
    exit 1
  fi
  if [ "$elapsed" -ge "$STARTUP_TIMEOUT" ]; then
    echo "ERROR: server did not become healthy (last HTTP code: ${HTTP_CODE}) within ${STARTUP_TIMEOUT}s" >&2
    exit 1
  fi
  sleep 5
  elapsed=$((elapsed + 5))
done
echo "Server healthy (HTTP 200) after ~${elapsed}s"

echo
echo "== GPU state after load =="
nvidia-smi --query-gpu=index,memory.used,memory.total --format=csv

run_case() {
  local name="$1" prompt="$2" max_tokens="$3" extra_kwargs="$4" run_no="$5"
  local out="${RESULT_DIR}/${name}-run${run_no}.json"
  local req
  # extra_kwargs is a JSON string (e.g. '{"enable_thinking": false}') --
  # parse it with json.loads, do NOT embed it as Python source (its
  # lowercase true/false/null are not valid Python literals).
  req=$(PROMPT="$prompt" MAX_TOKENS="$max_tokens" EXTRA_KWARGS="$extra_kwargs" python3 -c "
import json, os
print(json.dumps({
    'model': 'GLM-5.2-UD-IQ1_S',
    'messages': [{'role': 'user', 'content': os.environ['PROMPT']}],
    'temperature': 0,
    'max_tokens': int(os.environ['MAX_TOKENS']),
    'logprobs': True,
    'top_logprobs': 1,
    'chat_template_kwargs': json.loads(os.environ['EXTRA_KWARGS']),
}))
")
  if [ -z "$req" ]; then
    echo "ERROR: failed to build request JSON for case '${name}' run ${run_no}" >&2
    echo '{}' > "$out"
    echo "$out"
    return
  fi
  curl -s "http://${HOST}:${PORT}/v1/chat/completions" \
    -H 'Content-Type: application/json' \
    -d "$req" > "$out"
  echo "$out"
}

declare -a CASES=(
  "hello_no_think|Say hello in one short sentence.|300|{\"enable_thinking\": false}|2"
  "fact_no_think|What is the capital of France? Reply with just the city name.|300|{\"enable_thinking\": false}|2"
  "code_no_think|Write a Python function that returns the factorial of n. Only output the code, no explanation.|300|{\"enable_thinking\": false}|2"
  "hello_thinking|Say hello in one short sentence.|600|{}|1"
)

RESULT_FILES=()
for case_def in "${CASES[@]}"; do
  IFS='|' read -r name prompt max_tokens kwargs repeats <<< "$case_def"
  echo
  echo "=============================================================="
  echo "Case: ${name}  (max_tokens=${max_tokens}, chat_template_kwargs=${kwargs}, runs=${repeats})"
  echo "=============================================================="
  for run_no in $(seq 1 "$repeats"); do
    out="$(run_case "$name" "$prompt" "$max_tokens" "$kwargs" "$run_no")"
    echo "-- run ${run_no} -> ${out} --"
    RESULT_FILES+=("$out")
  done
done

echo
echo "== GPU state after all cases =="
nvidia-smi --query-gpu=index,memory.used,memory.total --format=csv

echo
echo "== Analysis =="
python3 - "$RESULT_DIR" <<'PYEOF'
import glob
import json
import os
import sys
from collections import defaultdict

result_dir = sys.argv[1]
by_case = defaultdict(list)

for path in sorted(glob.glob(os.path.join(result_dir, "*.json"))):
    base = os.path.basename(path)[:-len(".json")]
    name, _, run = base.rpartition("-run")
    by_case[name].append((int(run), path))

overall_ok = True

for name in sorted(by_case):
    print(f"\n--- {name} ---")
    runs = sorted(by_case[name])
    contents = []
    for run_no, path in runs:
        with open(path) as f:
            data = json.load(f)
        try:
            choice = data["choices"][0]
            message = choice["message"]
            content = (message.get("content") or "").strip()
            reasoning = (message.get("reasoning_content") or "").strip()
            finish_reason = choice.get("finish_reason")
            lp = choice.get("logprobs", {}) or {}
            tokens = [t["token"] for t in lp.get("content", [])] if lp else []
        except (KeyError, IndexError, TypeError) as e:
            print(f"  run {run_no}: could not parse ({e}); inspect {path} manually")
            overall_ok = False
            continue

        degenerate = bool(tokens) and len(set(tokens)) == 1 and len(tokens) > 1
        both_empty = not content and not reasoning

        print(f"  run {run_no}: finish_reason={finish_reason!r}")
        print(f"    content: {content[:200]!r}")
        if reasoning:
            print(f"    reasoning_content: {reasoning[:200]!r}")
        print(f"    tokens (n={len(tokens)}, unique={len(set(tokens))})")

        if degenerate:
            print(f"    VERDICT: DEGENERATE -- frozen token {tokens[0]!r} at every position")
            overall_ok = False
        elif both_empty:
            print("    VERDICT: SUSPICIOUS -- both content and reasoning_content empty")
            overall_ok = False
        else:
            print("    VERDICT: coherent")

        contents.append((run_no, content, reasoning, tuple(tokens)))

    if len(contents) > 1:
        first = contents[0][1:]
        deterministic = all(c[1:] == first for c in contents)
        print(f"  determinism across {len(contents)} runs: {'IDENTICAL' if deterministic else 'DIFFERED'}")
        if not deterministic:
            overall_ok = False

print()
print("=============================================================")
print("OVERALL:", "no degenerate/suspicious/non-deterministic results found"
      if overall_ok else "SEE ABOVE -- at least one case flagged")
print("=============================================================")
PYEOF

echo
echo "Result files: ${RESULT_DIR}/"
echo "Server log: ${SERVER_LOG}"
