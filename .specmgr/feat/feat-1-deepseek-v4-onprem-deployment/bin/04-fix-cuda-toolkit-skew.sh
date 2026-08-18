#!/usr/bin/env bash
# Fourth fix for vllm-deepseek-v4-flash.service: align mismatched pip-installed
# CUDA toolkit component versions inside the vLLM venv.
#
# Root cause (confirmed via journalctl on the 18:58:41 attempt, after
# 03-fallback-native-quant.sh got the model past weight loading and into
# profile_run() / CUDA-graph warmup):
#   TileLang JIT-compiles a CUDA kernel (mhc_pre_big_fuse_broadcast_with_
#   norm_tilelang_kernel, part of DeepSeek-V4's "MHC" layer) via nvcc, and it
#   failed with:
#     .../nvidia/cu13/include/cccl/cuda/std/__cccl/cuda_toolkit.h:41:8:
#     error: #error "CUDA compiler and CUDA toolkit headers are
#     incompatible, please check your include paths"
#   nvidia-cuda-nvcc/-crt/-cccl were on 13.3.x, but nvidia-cuda-runtime
#   (13.0.96), nvidia-cuda-nvrtc (13.0.88) and nvidia-cuda-cupti (13.0.85)
#   were still on the 13.0.x line. CCCL's cuda_toolkit.h hard-fails on any
#   compiler/runtime-header minor-version mismatch.
#
# This is a plain venv pip package skew, not a systemd/config issue -- no
# sudo required, since /data/vllm/.venv is user-owned.
#
# Run with: bash 04-fix-cuda-toolkit-skew.sh
# (Already applied once interactively on 2026-08-18 ~19:10 CEST; this script
# just documents/reproduces that fix.)

set -euo pipefail

VENV_PIP=/data/vllm/.venv/bin/pip

echo "== 1. Versions before =="
"$VENV_PIP" list 2>/dev/null | grep -iE "nvidia-cuda-(runtime|nvcc|nvrtc|cupti|cccl|crt)"

echo "== 2. Upgrading nvidia-cuda-runtime / -nvrtc / -cupti to the 13.3.x line =="
"$VENV_PIP" install --upgrade \
  "nvidia-cuda-runtime==13.3.29" \
  "nvidia-cuda-nvrtc==13.3.33" \
  "nvidia-cuda-cupti==13.3.75"

echo "== 3. Versions after (all should read 13.3.x) =="
"$VENV_PIP" list 2>/dev/null | grep -iE "nvidia-cuda-(runtime|nvcc|nvrtc|cupti|cccl|crt)"

echo
echo "Done -- no service restart needed by this script itself, but the"
echo "running vllm-deepseek-v4-flash.service (if any) should be restarted"
echo "to pick up the new venv packages:"
echo "  sudo systemctl restart vllm-deepseek-v4-flash.service"
echo "  journalctl -u vllm-deepseek-v4-flash.service -f"
