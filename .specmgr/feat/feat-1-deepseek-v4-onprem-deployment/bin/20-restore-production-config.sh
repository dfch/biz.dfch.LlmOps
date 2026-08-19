#!/usr/bin/env bash
# Step 3 of the Task 1.4 unblock plan (2026-08-19T08:04:27Z session):
# restore the production serving configuration. RUN THIS ONLY AFTER a
# diagnostic (bin/17 non-fp8 kv-cache, or the bin/18/19 clean venv) has
# produced COHERENT output -- not while the degenerate signature is still
# present.
#
# It undoes the diagnostic-only config drift that accumulated during the
# Task 1.4 investigation and returns the unit to the real target shape:
#   * restore --max-model-len 370000 (was shrunk to 8192 for fast
#     diagnostics in bin/09; the 350-370K context target is REQ-003),
#   * remove the diagnostic --enforce-eager (bin/08 was diagnostic-only;
#     eager mode is much slower and not the production target),
#   * leave the kv-cache-dtype and TP-vs-DP+EP choices as the diagnostics
#     settled them (this script does NOT re-add --kv-cache-dtype fp8; if
#     bin/17's non-fp8 result was adopted, fp8 kv-cache stays off).
#
# After restart, this runs the REAL Task 1.4 acceptance checks (ACC-004):
# a tool-call smoke test and think / non-think / max-think reasoning-mode
# output -- not just "does it emit tokens".
#
# NOTE: at --max-model-len 370000 with non-fp8 KV cache, KV memory is
# roughly double the fp8 case. If start-up now OOMs on KV-cache allocation,
# that is the Task 1.6 headroom question surfacing early -- record it and
# decide (smaller context, back to fp8 kv-cache if it was proven safe, or a
# quant trim) rather than silently lowering the target.
#
# Run with: sudo bash 20-restore-production-config.sh

set -euo pipefail

UNIT=/etc/systemd/system/vllm-deepseek-v4-flash.service

echo "== 1. Stopping service =="
systemctl stop vllm-deepseek-v4-flash.service || true

echo "== 2. Killing any leftover VLLM:: processes =="
pkill -9 -f 'VLLM::' || true
sleep 2

echo "== 3. GPU memory after cleanup =="
nvidia-smi --query-gpu=index,memory.used,memory.free --format=csv

echo "== 4. Restoring --max-model-len 8192 -> 370000 =="
if grep -q -- '--max-model-len 8192' "$UNIT"; then
  sed -i 's/    --max-model-len 8192 \\/    --max-model-len 370000 \\/' "$UNIT"
  echo "   restored to 370000."
else
  echo "   (no --max-model-len 8192 line found; leaving as-is -- verify below)"
fi

echo "== 5. Removing the diagnostic --enforce-eager flag =="
if grep -q -- '--enforce-eager' "$UNIT"; then
  sed -i '/--enforce-eager \\$/d' "$UNIT"
  echo "   removed."
else
  echo "   (no --enforce-eager line found -- already absent)"
fi

echo "== 6. Resulting ExecStart block (review before starting) =="
sed -n '/^ExecStart=/,/^ExecReload=/p' "$UNIT" | head -n -1

echo "== 7. Reloading systemd daemon =="
systemctl daemon-reload

echo
echo "Done. Production config restored. Next:"
echo "  sudo systemctl start vllm-deepseek-v4-flash.service"
echo "  journalctl -u vllm-deepseek-v4-flash.service -f"
echo
echo "Then run the REAL Task 1.4 (ACC-004) checks against /v1/chat/completions:"
echo "  (a) a tool-call request -> verify a well-formed tool_calls response;"
echo "  (b) think / non-think / max-think reasoning modes -> verify the"
echo "      reasoning_content field behaves per mode."
echo
echo "If startup OOMs on KV-cache at 370000 with non-fp8 KV cache, that is the"
echo "Task 1.6 headroom question -- record it and decide explicitly; do not"
echo "silently lower the context target."
