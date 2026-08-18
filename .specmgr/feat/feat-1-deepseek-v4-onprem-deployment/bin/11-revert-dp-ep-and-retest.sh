#!/usr/bin/env bash
# Revert bin/09-diag-dp-ep.sh's diagnostic changes now that the DP+EP
# hypothesis (vLLM #47528's TP-vs-DP+EP pattern) has been ruled out for
# Task 1.4 (identical degenerate output under both). Restores the unit to
# its TP=4 production parallelism, but keeps --max-model-len at a smaller
# diagnostic value for now (this script sets it to 8192, matching the
# DP+EP test, for a fast retest after the vLLM 0.27.1 / flashinfer-python
# 0.6.17 upgrade done in bin/10-upgrade-vllm-flashinfer.sh) -- restore
# --max-model-len 370000 separately once Task 1.4 is actually unblocked.
#
# Run with: sudo bash 11-revert-dp-ep-and-retest.sh

set -euo pipefail

UNIT=/etc/systemd/system/vllm-deepseek-v4-flash.service

echo "== 1. Stopping service =="
systemctl stop vllm-deepseek-v4-flash.service || true

echo "== 2. Killing any leftover VLLM:: processes =="
pkill -9 -f 'VLLM::' || true
sleep 2

echo "== 3. GPU memory after cleanup =="
nvidia-smi --query-gpu=index,memory.used,memory.free --format=csv

echo "== 4. Restoring --tensor-parallel-size 4 (removing --data-parallel-size / --enable-expert-parallel) =="
sed -i \
  -e 's/    --data-parallel-size 4 \\/    --tensor-parallel-size 4 \\/' \
  -e '/^    --enable-expert-parallel \\$/d' \
  "$UNIT"

echo "== 5. Resulting ExecStart block =="
sed -n '/^ExecStart=/,/^ExecReload=/p' "$UNIT" | head -n -1

echo "== 6. Reloading systemd daemon =="
systemctl daemon-reload

echo
echo "Done. Service is stopped, GPUs are clean, TP=4 restored (context"
echo "still at the 8192 diagnostic value, not yet 370000). Next steps:"
echo "  sudo systemctl start vllm-deepseek-v4-flash.service"
echo "  journalctl -u vllm-deepseek-v4-flash.service -f"
echo
echo "This now runs vLLM 0.27.1 + flashinfer-python 0.6.17 (upgraded from"
echo "0.26.0 / 0.6.14) with the same TP=4 config that showed degenerate"
echo "output before the upgrade -- re-run the temperature=0 smoke test to"
echo "see whether the version upgrade changed anything."
