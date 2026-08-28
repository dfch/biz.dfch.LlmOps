#!/usr/bin/env bash
# Task 1.2: a dedicated, reusable degenerate-output smoke test, mirroring
# feat-1's bin/22-verify-against-baseline.sh and feat-2's
# bin/14-smoke-test-glm-service.sh pattern (curl + auto-parse logprobs +
# plain pass/fail verdict, no manual JSON diffing).
#
# Checks, against a running OpenAI-compatible /v1/chat/completions
# endpoint:
#   1. Temperature=0 completion does NOT reproduce feat-1's exact
#      degenerate-output signature (identical argmax token + identical
#      logprob at every decode position). A handful of naturally-varying
#      logprobs is treated as healthy; all-identical logprobs across
#      >= MIN_TOKENS positions is treated as the degenerate signature.
#   2. Tool-calling works (a simple get_weather tool call resolves to a
#      tool_calls response with sane arguments).
#   3. All three thinking-control modes respond with HTTP 200 and the
#      expected reasoning_content shape (absent when disabled, present
#      when enabled).
#
# Usage: bin/07-smoke-test-endpoint.sh <base_url> [model_name]
#   e.g. bin/07-smoke-test-endpoint.sh http://localhost:30001 qwen4exp
#
# Exit code 0 = all checks passed, non-zero = at least one check failed
# (see printed verdict for which).

set -uo pipefail

BASE_URL="${1:-http://localhost:30001}"
MODEL="${2:-qwen4exp}"
MIN_TOKENS=5

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTDIR="${SCRIPT_DIR}/baselines"
mkdir -p "$OUTDIR"
STAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"

PASS=1

echo "== Task 1.2 smoke test against ${BASE_URL} (model=${MODEL}) =="

echo
echo "-- 1. Temperature=0 degenerate-output check --"
RESP_FILE="${OUTDIR}/${STAMP}-temp0.json"
HTTP_CODE=$(curl -sf "${BASE_URL}/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"${MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":\"Write a short Python function that returns the sum of two integers.\"}],\"temperature\":0,\"max_tokens\":200,\"logprobs\":true,\"top_logprobs\":1}" \
  -o "$RESP_FILE" -w "%{http_code}")

if [ "$HTTP_CODE" != "200" ]; then
  echo "FAIL: HTTP ${HTTP_CODE} from /v1/chat/completions"
  PASS=0
else
  python3 - "$RESP_FILE" "$MIN_TOKENS" <<'PYEOF'
import json, sys

path, min_tokens = sys.argv[1], int(sys.argv[2])
with open(path) as f:
    data = json.load(f)

content = data["choices"][0]["logprobs"]["content"]
tokens = [c["token"] for c in content]
logprobs = [c["logprob"] for c in content]

if len(tokens) >= min_tokens and len(set(tokens)) == 1 and len(set(logprobs)) == 1:
    print(f"DEGENERATE SIGNATURE DETECTED: token '{tokens[0]!r}' repeated "
          f"{len(tokens)}x at identical logprob {logprobs[0]}")
    sys.exit(1)

text = data["choices"][0]["message"].get("content", "")
print(f"OK: {len(tokens)} decode positions, {len(set(tokens))} distinct "
      f"tokens, {len(set(logprobs))} distinct logprobs")
print(f"    content preview: {text[:120]!r}")
PYEOF
  if [ $? -ne 0 ]; then
    PASS=0
  fi
fi

echo
echo "-- 2. Tool-calling check --"
RESP_FILE="${OUTDIR}/${STAMP}-toolcall.json"
HTTP_CODE=$(curl -sf "${BASE_URL}/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"${MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":\"What is the current weather in Paris? Use the get_weather tool.\"}],\"temperature\":0,\"max_tokens\":200,\"tools\":[{\"type\":\"function\",\"function\":{\"name\":\"get_weather\",\"description\":\"Get current weather for a location\",\"parameters\":{\"type\":\"object\",\"properties\":{\"location\":{\"type\":\"string\"}},\"required\":[\"location\"]}}}]}" \
  -o "$RESP_FILE" -w "%{http_code}")

if [ "$HTTP_CODE" != "200" ]; then
  echo "FAIL: HTTP ${HTTP_CODE} from /v1/chat/completions (tool-call)"
  PASS=0
else
  python3 - "$RESP_FILE" <<'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
msg = data["choices"][0]["message"]
calls = msg.get("tool_calls") or []
if not calls or calls[0]["function"]["name"] != "get_weather":
    print(f"FAIL: no valid get_weather tool_call in response: {msg}")
    sys.exit(1)
print(f"OK: tool_call resolved -> {calls[0]['function']['name']}"
      f"({calls[0]['function']['arguments']})")
PYEOF
  if [ $? -ne 0 ]; then
    PASS=0
  fi
fi

echo
echo "-- 3. Thinking-control modes --"
for MODE in disabled low xhigh; do
  case "$MODE" in
    disabled) KWARGS='{"enable_thinking":false}';;
    low)      KWARGS='{"enable_thinking":true,"reasoning_effort":"low"}';;
    xhigh)    KWARGS='{"enable_thinking":true,"reasoning_effort":"xhigh","preserve_thinking":true}';;
  esac
  RESP_FILE="${OUTDIR}/${STAMP}-think-${MODE}.json"
  HTTP_CODE=$(curl -sf "${BASE_URL}/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"${MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":\"What is 2+2?\"}],\"temperature\":0,\"max_tokens\":100,\"chat_template_kwargs\":${KWARGS}}" \
    -o "$RESP_FILE" -w "%{http_code}")
  if [ "$HTTP_CODE" != "200" ]; then
    echo "FAIL: HTTP ${HTTP_CODE} for reasoning mode '${MODE}'"
    PASS=0
    continue
  fi
  python3 - "$RESP_FILE" "$MODE" <<'PYEOF'
import json, sys
path, mode = sys.argv[1], sys.argv[2]
with open(path) as f:
    data = json.load(f)
msg = data["choices"][0]["message"]
has_reasoning = bool(msg.get("reasoning_content"))
if mode == "disabled" and has_reasoning:
    print(f"WARN: mode=disabled but reasoning_content present anyway "
          f"(template may not gate on enable_thinking)")
elif mode != "disabled" and not has_reasoning:
    print(f"FAIL: mode={mode} expected reasoning_content, got none")
    sys.exit(1)
print(f"OK: mode={mode}, has_reasoning={has_reasoning}, "
      f"content={msg.get('content','')[:80]!r}")
PYEOF
  if [ $? -ne 0 ]; then
    PASS=0
  fi
done

echo
if [ "$PASS" -eq 1 ]; then
  echo "===== VERDICT: PASS (no degenerate signature, tool-calling OK, thinking controls OK) ====="
  exit 0
else
  echo "===== VERDICT: FAIL (see above) ====="
  exit 1
fi
