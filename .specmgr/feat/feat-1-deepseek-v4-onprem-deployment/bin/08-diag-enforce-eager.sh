#!/usr/bin/env bash
# Diagnostic (not a confirmed fix) for vllm-deepseek-v4-flash.service:
# add --enforce-eager to rule out CUDA-graph capture as the source of the
# garbage/empty model output observed after the 19:48:15 attempt came up
# successfully (HTTP 200, but decoded content is garbage at temperature=1
# and an empty string at temperature=0 despite generating max_tokens each
# time).
#
# Rationale: --enforce-eager disables CUDA-graph capture entirely, forcing
# every forward pass through the plain eager PyTorch/kernel path. If output
# becomes coherent with this flag, the bug is in the (heavily-patched
# tonight) CUDA-graph capture path for the custom TileLang/FlashInfer SM120
# kernels. If output is still garbage, the bug is elsewhere (quantization,
# attention backend numerics, fp8 kv-cache scaling, etc).
#
# This is a TEMPORARY diagnostic change. Revert it (remove --enforce-eager)
# once the experiment's result is known, regardless of outcome -- eager
# mode is much slower and is not the target production configuration.
#
# Run with: sudo bash 08-diag-enforce-eager.sh

set -euo pipefail

UNIT=/etc/systemd/system/vllm-deepseek-v4-flash.service

echo "== 1. Stopping service =="
systemctl stop vllm-deepseek-v4-flash.service || true

echo "== 2. Killing any leftover VLLM:: processes =="
pkill -9 -f 'VLLM::' || true
sleep 2

echo "== 3. GPU memory after cleanup =="
nvidia-smi --query-gpu=index,memory.used,memory.free --format=csv

echo "== 4. Adding --enforce-eager to ExecStart (idempotent) =="
grep -q -- '--enforce-eager' "$UNIT" || \
  sed -i "s/    --max-model-len 370000 \\\\/    --max-model-len 370000 \\\\\n    --enforce-eager \\\\/" "$UNIT"

echo "== 5. Resulting ExecStart block =="
sed -n '/^ExecStart=/,/^ExecReload=/p' "$UNIT" | head -n -1

echo "== 6. Reloading systemd daemon =="
systemctl daemon-reload

echo
echo "Done. Service is stopped and GPUs are clean. Next steps:"
echo "  sudo systemctl start vllm-deepseek-v4-flash.service"
echo "  journalctl -u vllm-deepseek-v4-flash.service -f"
echo
echo "Once up, re-run the same temp=0 smoke test and compare output."
echo "Remember to remove --enforce-eager afterwards regardless of outcome."
