#!/usr/bin/env bash
# Task 1.2: minimal short-context bring-up of GLM-5.2 on llama.cpp (the lead
# Phase 1 spike candidate, see Task 1.1), at the small UD-IQ1_S quant, with a
# temperature=0 greedy smoke test -- checking specifically for the feat-1
# Task 1.4 degenerate signature (a single token frozen at every decode
# position) on these SM120 (RTX Pro 6000 Blackwell) GPUs (REQ-010).
#
# This starts llama-server in the background, waits for it to report ready,
# fires one greedy chat-completion request with logprobs, checks the
# response for the degenerate signature, then stops the server again
# (this is a correctness spike, not the Phase 2 systemd deployment).
#
# Prereqs:
#   - bin/01-clone-llama-cpp-dsa.sh + bin/02-build-llama-cpp-dsa.sh already run
#   - bin/00-download-glm-quants.sh has fully downloaded UD-IQ1_S
#   - GPUs free (check: nvidia-smi)
#
# Run with: bash 03-spike-glm-dsa.sh

set -euo pipefail

BIN=/data/llama.cpp-dsa/build/bin/llama-server
MODEL_DIR=/data/llama_cpp/models/GLM-5.2-GGUF/UD-IQ1_S
PORT=8090
HOST=127.0.0.1
CTX_SIZE=4096      # short-context bring-up only, not the 350-370K target (Task 2.5)
STARTUP_TIMEOUT=1800  # 217 GB to load off disk; generous, adjust if needed

LOGDIR="$(cd "$(dirname "$0")" && pwd)/logs"
mkdir -p "$LOGDIR"
STAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"
SERVER_LOG="${LOGDIR}/${STAMP}-spike-server.log"
RESULT_LOG="${LOGDIR}/${STAMP}-spike-result.json"

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
# /health responds even while the model is still loading (HTTP 503, body
# {"error":{"message":"Loading model", ...}}) -- require an actual HTTP 200,
# not just "curl got a response", or the smoke test below fires too early.
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

echo
echo "== Temperature=0 greedy smoke test (logprobs) =="
REQUEST='{
  "model": "GLM-5.2-UD-IQ1_S",
  "messages": [{"role": "user", "content": "Say hello in one short sentence."}],
  "temperature": 0,
  "max_tokens": 20,
  "logprobs": true,
  "top_logprobs": 1
}'
echo "-- request --"
echo "$REQUEST"

curl -s "http://${HOST}:${PORT}/v1/chat/completions" \
  -H 'Content-Type: application/json' \
  -d "$REQUEST" | tee "$RESULT_LOG" | python3 -m json.tool

echo
echo "== Degenerate-signature check =="
python3 - "$RESULT_LOG" <<'PYEOF'
import json, sys

path = sys.argv[1]
with open(path) as f:
    data = json.load(f)

try:
    choice = data["choices"][0]
    message = choice["message"]
    content = message.get("content", "") or ""
    reasoning = message.get("reasoning_content", "") or ""
    finish_reason = choice.get("finish_reason")
    lp = choice.get("logprobs", {}) or {}
    tokens = [t["token"] for t in lp.get("content", [])] if lp else []
except (KeyError, IndexError, TypeError) as e:
    print(f"Could not parse response for degenerate check ({e}); inspect {path} manually.")
    sys.exit(0)

print(f"content: {content!r}")
print(f"reasoning_content: {reasoning!r}")
print(f"finish_reason: {finish_reason!r}")
print(f"tokens: {tokens}")

# GLM-5.2 defaults to thinking mode: a short max_tokens budget can be spent
# entirely on reasoning_content (finish_reason "length") with `content` still
# empty -- that is NOT the degenerate signature, just an unfinished thought.
# Only flag "empty" as suspicious if BOTH content and reasoning_content are
# empty.
if not content.strip() and not reasoning.strip():
    print("VERDICT: SUSPICIOUS -- both content and reasoning_content are empty.")
elif tokens and len(set(tokens)) == 1 and len(tokens) > 1:
    print(f"VERDICT: DEGENERATE -- every decode position produced the same token {tokens[0]!r},")
    print("matching the feat-1 Task 1.4 failure signature (frozen token repeated at every position).")
else:
    print("VERDICT: looks coherent (no single frozen token repeated at every position).")
    print("Still eyeball the content above for gibberish before declaring REQ-010 satisfied.")
PYEOF

echo
echo "Full result JSON: ${RESULT_LOG}"
echo "Server log: ${SERVER_LOG}"
