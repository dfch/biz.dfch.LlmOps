#!/usr/bin/env bash
# Re-apply the Task 1.3 fix #4 pattern (bin/04-fix-cuda-toolkit-skew.sh),
# reintroduced by the bin/10 upgrade / bin/13 rollback round trip.
#
# Root cause: bin/10 upgraded to vLLM 0.27.1 (needs torch 2.13.0), which
# pulled nvidia-cuda-nvcc/-crt/-cccl up to the 13.3.x line. bin/13 rolled
# vllm/torch back down to 0.26.0/2.11.0, but pip's resolver doesn't
# proactively downgrade transitive deps that still satisfy the new
# requirement's version constraints -- so nvcc/-crt/-cccl were left on
# 13.3.x while nvidia-cuda-runtime/-nvrtc/-cupti came back down to 13.0.x
# with the torch 2.11.0 reinstall. Same skew, same fix direction as
# bin/04: bring runtime/-nvrtc/-cupti back up to 13.3.x to match
# nvcc/-crt/-cccl.
#
# Confirmed via journalctl on the first post-rollback restart attempt
# (23:23 CEST): flashinfer's JIT-compiled "sampling" op failed ninja build
# with the exact same CCCL error as Task 1.3 fix #4:
#   cuda_toolkit.h:41:8: error: #error "CUDA compiler and CUDA toolkit
#   headers are incompatible, please check your include paths"
#
# This is a plain venv pip package skew, not a systemd/config issue -- no
# sudo required, since /data/vllm/.venv is user-owned.
#
# Run with: bash 15-fix-cuda-toolkit-skew-again.sh

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
echo "== 4. Clearing flashinfer's stale JIT cache (built against the =="
echo "==    mismatched toolkit, referenced by the failing ninja build) =="
rm -rf /home/user/.cache/flashinfer/0.6.14

echo
echo "Done -- restart the service to pick up the fixed venv + cleared cache:"
echo "  sudo systemctl restart vllm-deepseek-v4-flash.service"
echo "  journalctl -u vllm-deepseek-v4-flash.service -f"
