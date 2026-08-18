#!/usr/bin/env bash
# Third fix for vllm-deepseek-v4-flash.service: fall back to native
# FP4+FP8 mixed expert quantization (drop the FP8-expert override).
#
# Root cause (confirmed via journalctl on the 18:46:52 attempt, after the
# offline-mode fix from 02-fix-vllm-flash-offline.sh resolved the earlier
# network hang):
#   All 4 TP workers now fail fast and deterministically with:
#     RuntimeError: The size of tensor a (32) must match the size of
#     tensor b (128) at non-singleton dimension 1
#   inside vllm/model_executor/layers/fused_moe/routed_experts.py
#   (_load_w13 -> expert_data.copy_(loaded_weight)), while loading MoE
#   expert weights under --hf-overrides '{"expert_dtype": "fp8"}' with
#   --tensor-parallel-size 4. 128 / tp_size(4) = 32, pointing at a
#   TP-sharding bug in vLLM's fp8 expert-dtype override path for this
#   model/version -- not a host or config mistake on our side.
#
# This is exactly the contingency already documented in the feature
# README's Design Notes: "fallback to native FP4+FP8 mixed if vLLM's
# loader doesn't expose the override". This script removes the
# --hf-overrides flag (and the forced --kv-cache-dtype fp8, since that
# pairing was tied to the fp8-expert path) so the model loads at its
# native mixed precision instead.
#
# Run with: sudo bash 03-fallback-native-quant.sh

set -euo pipefail

UNIT=/etc/systemd/system/vllm-deepseek-v4-flash.service

echo "== 1. Stopping the crash-looping service =="
systemctl stop vllm-deepseek-v4-flash.service || true

echo "== 2. Killing any leftover VLLM:: processes =="
pkill -9 -f 'VLLM::' || true
sleep 2

echo "== 3. GPU memory after cleanup (expect ~2 MiB used, ~97.8 GB free on all 4) =="
nvidia-smi --query-gpu=index,memory.used,memory.free --format=csv

echo "== 4. Removing --hf-overrides '{\"expert_dtype\": \"fp8\"}' line from ExecStart =="
sed -i "/--hf-overrides '{\"expert_dtype\": \"fp8\"}' \\\\$/d" "$UNIT"

echo "== 5. Resulting ExecStart block =="
sed -n '/^ExecStart=/,/^ExecReload=/p' "$UNIT" | head -n -1

echo "== 6. Reloading systemd daemon =="
systemctl daemon-reload

echo
echo "Done. Service is stopped, GPUs are clean, override removed. Next steps:"
echo "  sudo systemctl start vllm-deepseek-v4-flash.service"
echo "  journalctl -u vllm-deepseek-v4-flash.service -f"
echo
echo "This now loads DeepSeek-V4-Flash at its native FP4+FP8 mixed expert"
echo "precision (no override). Per the design notes this trades some of the"
echo "targeted ~284GB FP8-expert footprint for the native footprint -- still"
echo "expected to fit comfortably in 384GB VRAM, but re-check headroom for"
echo "the 350-370K context target (Task 1.6) once it's up."
