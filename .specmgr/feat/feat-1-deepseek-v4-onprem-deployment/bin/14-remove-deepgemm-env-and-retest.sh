#!/usr/bin/env bash
# Clean up after the vLLM 0.27.1/flashinfer 0.6.17 upgrade attempt
# (bin/10) and its DeepGEMM workaround (bin/12), now that both have been
# ruled out and vllm/flashinfer-python have been rolled back to
# 0.26.0/0.6.14 (bin/13): remove the now-irrelevant
# Environment=VLLM_USE_DEEP_GEMM=0 line from the unit so the service
# returns to its exact pre-upgrade baseline configuration (TP=4, native
# FP4+FP8 mixed experts, FLASHINFER_MLA_SPARSE_DSV4, fp8 kv-cache,
# --enforce-eager, --max-model-len 8192 diagnostic value).
#
# Run with: sudo bash 14-remove-deepgemm-env-and-retest.sh

set -euo pipefail

UNIT=/etc/systemd/system/vllm-deepseek-v4-flash.service

echo "== 1. Stopping service (if running) =="
systemctl stop vllm-deepseek-v4-flash.service || true

echo "== 2. Killing any leftover VLLM:: processes =="
pkill -9 -f 'VLLM::' || true
sleep 2

echo "== 3. GPU memory after cleanup =="
nvidia-smi --query-gpu=index,memory.used,memory.free --format=csv

echo "== 4. Removing Environment=VLLM_USE_DEEP_GEMM=0 =="
sed -i '/^Environment=VLLM_USE_DEEP_GEMM=0$/d' "$UNIT"

echo "== 5. Resulting Environment= lines =="
grep '^Environment=' "$UNIT"

echo "== 6. Resulting ExecStart block =="
sed -n '/^ExecStart=/,/^ExecReload=/p' "$UNIT" | head -n -1

echo "== 7. Reloading systemd daemon =="
systemctl daemon-reload

echo
echo "Done. Service is stopped, GPUs are clean, unit restored to the"
echo "pre-upgrade baseline (vllm 0.26.0 / flashinfer-python 0.6.14, TP=4,"
echo "8192-token diagnostic context). Next steps:"
echo "  sudo systemctl start vllm-deepseek-v4-flash.service"
echo "  journalctl -u vllm-deepseek-v4-flash.service -f"
