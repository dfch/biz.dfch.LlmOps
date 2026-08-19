#!/usr/bin/env bash
# Read-only smoke test for Task 1.4: hits the live service's
# /v1/chat/completions with the same temperature=0 request used by
# bin/16/bin/21, then automatically compares the result against the known
# frozen degenerate signature (`<|begin_of_sentence|>` at logprob
# -11.769736289978027 for every one of the 10 requested decode positions)
# instead of requiring a human to eyeball two JSON blobs.
#
# Does not touch the service or systemd unit in any way -- safe to run at
# any time, as often as you like, no sudo required.
#
# Exit code: 0 in all cases where the request succeeds (this is a report,
# not a gate); 1 only if the service could not be reached at all.
#
# Run with: bash 22-verify-against-baseline.sh

set -euo pipefail

ENDPOINT=http://127.0.0.1:8000/v1/chat/completions
HEALTH=http://127.0.0.1:8000/health
MODEL=deepseek-ai/DeepSeek-V4-Flash

EXPECTED_TOKEN='<｜begin▁of▁sentence｜>'
EXPECTED_LOGPROB='-11.769736289978027'

echo "== 1. Health check =="
if ! curl -s -o /dev/null -m 10 -w 'HTTP %{http_code}\n' "$HEALTH"; then
  echo "Service unreachable at $HEALTH -- is it running?"
  echo "  systemctl status vllm-deepseek-v4-flash.service"
  exit 1
fi

echo "== 2. temperature=0 smoke test (10 tokens, logprobs) =="
RESPONSE="$(curl -s -m 60 "$ENDPOINT" \
  -H 'Content-Type: application/json' \
  -d "{
    \"model\": \"${MODEL}\",
    \"messages\": [{\"role\": \"user\", \"content\": \"Say hello in one short sentence.\"}],
    \"temperature\": 0,
    \"max_tokens\": 10,
    \"logprobs\": true,
    \"top_logprobs\": 1
  }")"

if [ -z "$RESPONSE" ]; then
  echo "Empty response from $ENDPOINT -- is the service up?"
  echo "  systemctl status vllm-deepseek-v4-flash.service"
  exit 1
fi

echo "-- raw response --"
echo "$RESPONSE"
echo

echo "== 3. Verdict =="

# Every "logprob":<value> occurrence in the response (content + nested
# top_logprobs), in order.
LOGPROB_VALUES="$(grep -oE '"logprob":-?[0-9]+\.[0-9]+' <<<"$RESPONSE" | cut -d: -f2)"
LOGPROB_COUNT="$(echo "$LOGPROB_VALUES" | grep -c . || true)"
UNIQUE_LOGPROBS="$(echo "$LOGPROB_VALUES" | sort -u)"
UNIQUE_COUNT="$(echo "$UNIQUE_LOGPROBS" | grep -c . || true)"

# Every "token":"<value>" occurrence.
TOKEN_VALUES="$(grep -oE '"token":"[^"]*"' <<<"$RESPONSE" | sed -E 's/"token":"(.*)"/\1/')"
UNIQUE_TOKENS="$(echo "$TOKEN_VALUES" | sort -u)"
UNIQUE_TOKEN_COUNT="$(echo "$UNIQUE_TOKENS" | grep -c . || true)"

echo "Found $LOGPROB_COUNT logprob value(s), $UNIQUE_COUNT distinct."
echo "Found $UNIQUE_TOKEN_COUNT distinct token(s): $UNIQUE_TOKENS"

if [ "$LOGPROB_COUNT" -gt 0 ] \
  && [ "$UNIQUE_COUNT" -eq 1 ] \
  && [ "$UNIQUE_TOKEN_COUNT" -eq 1 ] \
  && [ "$UNIQUE_LOGPROBS" = "$EXPECTED_LOGPROB" ] \
  && [ "$UNIQUE_TOKENS" = "$EXPECTED_TOKEN" ]; then
  echo
  echo "==> MATCHES the frozen degenerate baseline exactly:"
  echo "    every decode position returns '$EXPECTED_TOKEN' at logprob $EXPECTED_LOGPROB."
  echo "    Task 1.4's bug is still present -- no change."
elif [ "$LOGPROB_COUNT" -gt 0 ] && [ "$UNIQUE_COUNT" -eq 1 ] && [ "$UNIQUE_TOKEN_COUNT" -eq 1 ]; then
  echo
  echo "==> Still a single frozen token+logprob repeated at every position,"
  echo "    but it DIFFERS from the known baseline ('$UNIQUE_TOKENS' @ $UNIQUE_LOGPROBS"
  echo "    vs. expected '$EXPECTED_TOKEN' @ $EXPECTED_LOGPROB)."
  echo "    Same class of bug (frozen/degenerate), different signature -- investigate."
elif [ "$LOGPROB_COUNT" -gt 0 ]; then
  echo
  echo "==> DIFFERS from the frozen degenerate baseline: output is NOT a single"
  echo "    repeated token/logprob across all positions. This may indicate the"
  echo "    bug is fixed (or behaving differently) -- do not assume success"
  echo "    without also checking the actual decoded text/tool-calls per"
  echo "    Task 1.4's real acceptance check (ACC-004)."
else
  echo
  echo "==> Could not find any logprob fields in the response -- check the"
  echo "    raw response above for an error payload instead of a completion."
fi
