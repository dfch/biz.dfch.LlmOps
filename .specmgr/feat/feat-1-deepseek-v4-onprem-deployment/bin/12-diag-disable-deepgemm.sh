#!/usr/bin/env bash
# Diagnostic for a NEW regression introduced by bin/10's vLLM 0.27.1 +
# flashinfer-python 0.6.17 upgrade: the service now hard-crashes on every
# restart (deterministic, confirmed across 3 consecutive restarts) during
# weight post-processing, before ever reaching generation:
#
#   RuntimeError: Assertion error
#   (/workspace/.deps/deepgemm-src/csrc/apis/layout.hpp:60):
#   Unknown SF transformation
#
# raised from vllm/model_executor/layers/quantization/utils/fp8_utils.py
# (deepgemm_post_process_weight_scale_block ->
# transform_sf_into_required_layout) while loading DeepSeek-V4-Flash's
# native FP4+FP8 mixed weights under vLLM 0.27.1's DeepGEMM-based FP8
# scaled-mm path. This is worse than the original Task 1.4 bug (that one
# at least served HTTP with degenerate output; this one never starts).
#
# This script tries the cheapest workaround first: force-disable DeepGEMM
# via VLLM_USE_DEEP_GEMM=0, falling back to vLLM's non-DeepGEMM FP8
# scaled-mm kernel path. NOT guaranteed to work -- vLLM issue #47528 (see
# Task 1.4 note) reports VLLM_USE_DEEP_GEMM=0 crashing differently (a
# CUTLASS dispatch gap) for a *different* model/quant combo
# (DeepSeek-V4-Pro, scale_fmt=ue8m0 FP4 MoE) -- ours is DeepSeek-V4-Flash
# native FP4+FP8 mixed, so the outcome here may differ.
#
# If this also fails, the next step is rolling vLLM/flashinfer back to
# 0.26.0/0.6.14 (the last confirmed-running, if degenerate-output,
# configuration) via:
#   /data/vllm/.venv/bin/pip install --upgrade 'vllm==0.26.0' 'flashinfer-python==0.6.14'
#
# Run with: sudo bash 12-diag-disable-deepgemm.sh

set -euo pipefail

UNIT=/etc/systemd/system/vllm-deepseek-v4-flash.service

echo "== 1. Stopping the crash-looping service =="
systemctl stop vllm-deepseek-v4-flash.service || true

echo "== 2. Killing any leftover VLLM:: processes =="
pkill -9 -f 'VLLM::' || true
sleep 2

echo "== 3. GPU memory after cleanup =="
nvidia-smi --query-gpu=index,memory.used,memory.free --format=csv

echo "== 4. Adding Environment=VLLM_USE_DEEP_GEMM=0 (idempotent) =="
grep -q '^Environment=VLLM_USE_DEEP_GEMM=0$' "$UNIT" || \
  sed -i '/^Environment=VLLM_USE_FASTOKENS=1$/a Environment=VLLM_USE_DEEP_GEMM=0' "$UNIT"

echo "== 5. Resulting Environment= lines =="
grep '^Environment=' "$UNIT"

echo "== 6. Reloading systemd daemon =="
systemctl daemon-reload

echo
echo "Done. Service is stopped and GPUs are clean. Next steps:"
echo "  sudo systemctl start vllm-deepseek-v4-flash.service"
echo "  journalctl -u vllm-deepseek-v4-flash.service -f"
echo
echo "If this crashes differently (e.g. a CUTLASS scaled_mm dispatch"
echo "error), DeepGEMM is not optional for this checkpoint under 0.27.1"
echo "and the next move is rolling vLLM/flashinfer back to 0.26.0/0.6.14."
