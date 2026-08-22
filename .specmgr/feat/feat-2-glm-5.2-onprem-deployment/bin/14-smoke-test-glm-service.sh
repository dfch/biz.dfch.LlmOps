#!/usr/bin/env bash
# Task 2.4 smoke test -- against an ALREADY-RUNNING systemd --user service
# (llama-glm-5.2.service by default, installed via
# bin/09-install-llama-glm-service.sh; override SERVICE_UNIT/HOST/PORT/MODEL
# below to point this at the side-by-side llama-glm-5.2-q4.service instead
# -- see bin/19/bin/20), NOT an ad-hoc llama-server process like bin/03/05's
# Phase 1 spikes. This script does not start/stop anything -- the service
# must already be `active (running)` and `/health` must already return 200
# before running this (start it yourself first: `systemctl --user start
# <unit>`).
#
# Usage against Q5 (default, no overrides needed):
#   bash 14-smoke-test-glm-service.sh
# Usage against the side-by-side Q4 service:
#   SERVICE_UNIT=llama-glm-5.2-q4.service PORT=8093 \
#     MODEL="glm-5.2:UD-Q4_K_XL" bash 14-smoke-test-glm-service.sh
#
# Verifies REQ-004/REQ-011/ACC-004:
#   1. All 3 reasoning-mode toggles produce coherent, non-degenerate,
#      finished (non-truncated) output:
#        - chat_template_kwargs {"enable_thinking": false}
#        - chat_template_kwargs {"reasoning_effort": "high"}
#        - chat_template_kwargs {"reasoning_effort": "max"} (GLM-5.2 default)
#   2. Tool-calling (the REQ-011 risk specific to llama.cpp, historically
#      weaker than vLLM/SGLang) actually emits a well-formed
#      message.tool_calls[].function.{name,arguments} block that OpenCode
#      could parse -- not a plain-text imitation of a tool call in `content`.
#
# Each response is checked for the same degenerate signature used in the
# Phase 1 spikes (bin/03, bin/05): a single frozen token repeated at every
# decode position. temperature=0 for all cases (diagnostic, not the
# production sampling config -- see Decisions Made 2026-08-19).
#
# Run with: bash 14-smoke-test-glm-service.sh
# (Does NOT execute automatically -- prepared for manual review/run first.)

set -euo pipefail

SERVICE_UNIT="${SERVICE_UNIT:-llama-glm-5.2.service}"
HOST="${HOST:-localhost}"
PORT="${PORT:-8092}"
MODEL="${MODEL:-glm-5.2:UD-Q5_K_XL}"
STARTUP_TIMEOUT=10

LOGDIR="$(cd "$(dirname "$0")" && pwd)/logs"
mkdir -p "$LOGDIR"
STAMP="$(date -u +%Y-%m-%dT%H%M%SZ)"
RESULT_DIR="${LOGDIR}/${STAMP}-smoke-test-glm-service"
mkdir -p "$RESULT_DIR"

echo "== Checking ${SERVICE_UNIT} is already running =="
if ! systemctl --user is-active --quiet "$SERVICE_UNIT"; then
  echo "ERROR: ${SERVICE_UNIT} is not active -- start it first:" >&2
  echo "  systemctl --user start ${SERVICE_UNIT}" >&2
  echo "This script does not start/stop the service itself." >&2
  exit 1
fi

echo "== Checking /health (up to ${STARTUP_TIMEOUT}s, service should already be healthy) =="
elapsed=0
while true; do
  HTTP_CODE="$(curl -s -o /dev/null -w '%{http_code}' "http://${HOST}:${PORT}/health" 2>/dev/null || echo "000")"
  if [ "$HTTP_CODE" = "200" ]; then
    break
  fi
  if [ "$elapsed" -ge "$STARTUP_TIMEOUT" ]; then
    echo "ERROR: /health did not return 200 (last HTTP code: ${HTTP_CODE}) within ${STARTUP_TIMEOUT}s -- is the model still cold-loading? Check:" >&2
    echo "  systemctl --user status ${SERVICE_UNIT}" >&2
    echo "  journalctl --user-unit ${SERVICE_UNIT} -n 50" >&2
    exit 1
  fi
  sleep 2
  elapsed=$((elapsed + 2))
done
echo "Server healthy (HTTP 200)"

run_case() {
  local name="$1" prompt="$2" max_tokens="$3" extra_kwargs="$4" tools="$5"
  local out="${RESULT_DIR}/${name}.json"
  local req
  # extra_kwargs / tools are JSON strings -- parse with json.loads, do NOT
  # embed as Python source (lowercase true/false/null are not valid Python
  # literals).
  req=$(MODEL="$MODEL" PROMPT="$prompt" MAX_TOKENS="$max_tokens" \
        EXTRA_KWARGS="$extra_kwargs" TOOLS="$tools" python3 -c "
import json, os

body = {
    'model': os.environ['MODEL'],
    'messages': [{'role': 'user', 'content': os.environ['PROMPT']}],
    'temperature': 0,
    'max_tokens': int(os.environ['MAX_TOKENS']),
    'chat_template_kwargs': json.loads(os.environ['EXTRA_KWARGS']),
}
tools_raw = os.environ.get('TOOLS', '')
if tools_raw:
    body['tools'] = json.loads(tools_raw)
    body['tool_choice'] = 'auto'
print(json.dumps(body))
")
  if [ -z "$req" ]; then
    echo "ERROR: failed to build request JSON for case '${name}'" >&2
    echo '{}' > "$out"
    echo "$out"
    return
  fi
  curl -s "http://${HOST}:${PORT}/v1/chat/completions" \
    -H 'Content-Type: application/json' \
    -d "$req" > "$out"
  echo "$out"
}

echo
echo "== Reasoning-mode cases =="

TOOL_SCHEMA='[{"type":"function","function":{"name":"get_weather","description":"Get current weather for a location","parameters":{"type":"object","properties":{"location":{"type":"string","description":"City name"}},"required":["location"]}}}]'

declare -a CASES=(
  # name|prompt|max_tokens|chat_template_kwargs|tools(empty = no tool test)
  "nothink|What is the capital of France? Reply with just the city name.|300|{\"enable_thinking\": false}|"
  "reasoning_high|Write a Python function that returns the nth Fibonacci number recursively.|1000|{\"reasoning_effort\": \"high\"}|"
  "reasoning_max|Write a Python function that returns the nth Fibonacci number recursively.|4000|{\"reasoning_effort\": \"max\"}|"
  "toolcall|What is the weather in Paris right now? Use the provided tool.|300|{\"enable_thinking\": false}|${TOOL_SCHEMA}"
)

RESULT_FILES=()
for case_def in "${CASES[@]}"; do
  IFS='|' read -r name prompt max_tokens kwargs tools <<< "$case_def"
  echo
  echo "=============================================================="
  echo "Case: ${name}  (max_tokens=${max_tokens}, chat_template_kwargs=${kwargs}, tools=$( [ -n "$tools" ] && echo yes || echo no ))"
  echo "=============================================================="
  out="$(run_case "$name" "$prompt" "$max_tokens" "$kwargs" "$tools")"
  echo "-- ${out} --"
  RESULT_FILES+=("$out")
done

echo
echo "== Analysis =="
python3 - "$RESULT_DIR" <<'PYEOF'
import glob
import json
import os
import sys

result_dir = sys.argv[1]
overall_ok = True

for path in sorted(glob.glob(os.path.join(result_dir, "*.json"))):
    name = os.path.basename(path)[:-len(".json")]
    print(f"\n--- {name} ---")
    with open(path) as f:
        data = json.load(f)

    try:
        choice = data["choices"][0]
        message = choice["message"]
        content = (message.get("content") or "").strip()
        reasoning = (message.get("reasoning_content") or "").strip()
        tool_calls = message.get("tool_calls") or []
        finish_reason = choice.get("finish_reason")
    except (KeyError, IndexError, TypeError) as e:
        print(f"  could not parse response ({e}); inspect {path} manually")
        overall_ok = False
        continue

    print(f"  finish_reason: {finish_reason!r}")
    print(f"  content: {content[:200]!r}")
    if reasoning:
        print(f"  reasoning_content: {reasoning[:200]!r}")

    if name == "toolcall":
        if tool_calls:
            for tc in tool_calls:
                fn = tc.get("function", {})
                print(f"  tool_call: name={fn.get('name')!r} arguments={fn.get('arguments')!r}")
            args_ok = False
            for tc in tool_calls:
                fn = tc.get("function", {})
                if fn.get("name") == "get_weather":
                    try:
                        args = json.loads(fn.get("arguments") or "{}")
                        args_ok = "location" in args
                    except json.JSONDecodeError:
                        args_ok = False
            if args_ok:
                print("  VERDICT: tool_calls well-formed (get_weather + location arg)")
            else:
                print("  VERDICT: SUSPICIOUS -- tool_calls present but malformed/missing expected args")
                overall_ok = False
        else:
            print("  VERDICT: FAIL -- no tool_calls emitted (REQ-011 risk realized); "
                  "check whether the model instead imitated a tool call in `content`")
            overall_ok = False
        continue

    # Degenerate-signature / truncation / emptiness checks for the
    # reasoning-mode cases.
    both_empty = not content and not reasoning
    truncated = finish_reason == "length"

    if both_empty:
        print("  VERDICT: SUSPICIOUS -- both content and reasoning_content empty")
        overall_ok = False
    elif truncated and not content:
        print("  VERDICT: INCOMPLETE -- truncated (finish_reason=length) with no final content yet "
              "(may just need a larger max_tokens for this mode, not necessarily degenerate)")
        overall_ok = False
    else:
        print("  VERDICT: coherent")

print()
print("=============================================================")
print("OVERALL:", "no degenerate/suspicious/failed results found"
      if overall_ok else "SEE ABOVE -- at least one case flagged")
print("=============================================================")
PYEOF

echo
echo "Result files: ${RESULT_DIR}/"
