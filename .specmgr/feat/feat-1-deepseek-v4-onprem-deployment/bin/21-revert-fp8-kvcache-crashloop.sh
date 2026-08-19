#!/usr/bin/env bash
# Revert bin/17-diag-no-fp8-kvcache.sh's change and stop the resulting
# crash loop (2026-08-19T09:1x session).
#
# Finding: dropping --kv-cache-dtype fp8 did NOT produce a usable A/B test.
# It made every worker fail at model-init time with:
#
#   AssertionError: DeepseekV4 fp8_ds_mla layout only supports fp8
#   kv-cache, got auto
#   (vllm/models/deepseek_v4/attention.py:83, raised from
#    flashinfer_sparse.py:578 -> attention.py:290
#    _resolve_dsv4_kv_cache_dtype)
#
# i.e. fp8 KV-cache is a hard architectural requirement of the fp8_ds_mla
# attention layout used by --attention-backend FLASHINFER_MLA_SPARSE_DSV4
# on this vLLM build, not a tunable precision knob. The model never reaches
# inference with it removed, so Track A's hypothesis ("fp8 kv-cache scaling
# factors cause the degenerate output") cannot be isolated via this
# backend at all -- it is ruled out by construction, not by a clean test.
#
# With --kv-cache-dtype fp8 removed and no revert step in bin/17 itself,
# the unit was stuck in an infinite Restart=on-failure / RestartSec=10
# crash loop (7+ restarts observed) burning CPU and filling the journal.
#
# This script:
#   1. stops the crash-looping service and kills any leftover VLLM::
#      worker processes,
#   2. restores --kv-cache-dtype fp8 to its original position in the
#      ExecStart block (idempotent -- a no-op if already present),
#   3. reloads systemd and starts the service,
#   4. polls until the API is reachable (model load takes a few minutes),
#   5. re-runs the same temperature=0 smoke test as bin/16 so the result
#      can be diffed against the frozen degenerate baseline
#      (bin/baselines/2026-08-19T09:10:23Z-degenerate.txt) to confirm the
#      service is back to the known-bad-but-stable state before deciding
#      on the next diagnostic (bin/18 clean-venv path).
#
# Run with: sudo bash 21-revert-fp8-kvcache-crashloop.sh

set -euo pipefail

UNIT=/etc/systemd/system/vllm-deepseek-v4-flash.service
ENDPOINT=http://127.0.0.1:8000/v1/chat/completions
MODEL=deepseek-ai/DeepSeek-V4-Flash
SERVICE=vllm-deepseek-v4-flash.service

echo "== 1. Stopping the crash-looping service =="
systemctl stop "$SERVICE" || true

echo "== 2. Killing any leftover VLLM:: processes =="
pkill -9 -f 'VLLM::' || true
sleep 2

echo "== 3. GPU memory after cleanup (expect ~2 MiB used, ~97.8 GB free on all 4) =="
nvidia-smi --query-gpu=index,memory.used,memory.free --format=csv

echo "== 4. Restoring --kv-cache-dtype fp8 to ExecStart =="
if grep -q -- '--kv-cache-dtype fp8 \\$' "$UNIT"; then
  echo "   already present -- nothing to do."
else
  sed -i \
    's/^\(\s*\)--tokenizer-mode deepseek_v4 \\$/\1--tokenizer-mode deepseek_v4 \\\n\1--kv-cache-dtype fp8 \\/' \
    "$UNIT"
  echo "   restored."
fi

echo "== 5. Resulting ExecStart block =="
sed -n '/^ExecStart=/,/^ExecReload=/p' "$UNIT" | head -n -1

echo "== 6. Reloading systemd daemon =="
systemctl daemon-reload

echo "== 7. Starting service (non-blocking) =="
# NOTE: this unit is Type=notify with TimeoutStartSec=3600. A plain
# `systemctl start` blocks the CALLER (this script) until vLLM sends the
# sd_notify READY=1 signal, fails, or that hour elapses -- and in practice
# vLLM has been observed serving real HTTP traffic successfully for
# minutes while systemd still reports ActiveState=activating/start (it
# does not appear to send READY=1 promptly, if at all, under
# --enforce-eager). Waiting on the systemctl call itself is therefore
# unreliable as a readiness signal. Use --no-block so this script's own
# timeout/health-check loop below (which checks the actual HTTP endpoint,
# the thing we actually care about) is what governs progress -- and so
# Ctrl+C-ing this script never has to kill a long-blocked systemctl call
# (systemd manages the unit independently either way; interrupting a
# blocking `systemctl start` would never have stopped the service, but
# --no-block avoids the confusing hang entirely).
systemctl start --no-block "$SERVICE"

echo "== 8. Waiting for the API to come up (up to 10 minutes, polling actual HTTP health, not systemd's ActiveState) =="
DEADLINE=$(( $(date +%s) + 600 ))
until curl -s -o /dev/null -m 5 -w '' "http://127.0.0.1:8000/health" 2>/dev/null; do
  if [ "$(date +%s)" -ge "$DEADLINE" ]; then
    echo "   TIMEOUT waiting for API. Check: systemctl status $SERVICE"
    echo "                                    journalctl -u $SERVICE -n 200 --no-pager"
    exit 1
  fi
  ACTIVE_STATE="$(systemctl is-active "$SERVICE" || true)"
  if [ "$ACTIVE_STATE" = "failed" ]; then
    echo "   Service reports 'failed' -- not waiting further."
    systemctl status "$SERVICE" --no-pager -l | head -30
    exit 1
  fi
  sleep 5
done
echo "   API is reachable (systemd ActiveState may still show 'activating' -- that's expected/harmless)."

echo "== 9. temperature=0 smoke test (10 tokens, logprobs) =="
curl -s "$ENDPOINT" \
  -H 'Content-Type: application/json' \
  -d "{
    \"model\": \"${MODEL}\",
    \"messages\": [{\"role\": \"user\", \"content\": \"Say hello in one short sentence.\"}],
    \"temperature\": 0,
    \"max_tokens\": 10,
    \"logprobs\": true,
    \"top_logprobs\": 1
  }"
echo

echo
echo "Done. Service restored with --kv-cache-dtype fp8 and confirmed serving."
echo "Compare the response above against the frozen baseline:"
echo "  bin/baselines/2026-08-19T09:10:23Z-degenerate.txt"
echo "Expect an identical match (same frozen token + logprob"
echo "-11.769736289978027 at every position) -- confirming we are back to"
echo "the known-bad-but-stable state."
echo
echo "Next: since fp8 kv-cache is now confirmed non-negotiable for this"
echo "attention backend, Track A is closed. Proceed to bin/18-build-clean-venv.sh"
echo "(clean side-by-side venv, isolates in-place-patch contamination) as the"
echo "next diagnostic."
