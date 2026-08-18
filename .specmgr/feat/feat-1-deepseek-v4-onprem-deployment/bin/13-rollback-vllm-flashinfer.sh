#!/usr/bin/env bash
# Roll back vLLM/flashinfer-python from the bin/10 upgrade (0.27.1/0.6.17)
# to the last confirmed-running (if degenerate-output) configuration
# (0.26.0/0.6.14).
#
# Root cause for the rollback: vLLM 0.27.1's DeepSeek-V4 support routes
# the model's mHC (Manifold-Constrained Hyper-Connections) layers through
# a vendored DeepGEMM kernel (vllm/utils/deep_gemm.py ->
# tf32_hc_prenorm_gemm -> DeepGEMM's hyperconnection.hpp) that hard-
# asserts "Unsupported architecture" on our SM120 (RTX PRO 6000 Blackwell)
# GPUs. Setting VLLM_USE_DEEP_GEMM=0 (bin/12) does NOT avoid this -- that
# env var only affects the FP8 linear-layer scaled-mm path
# (model_executor/layers/quantization/fp8.py), not the mHC-specific
# tilelang/DeepGEMM call, which is unconditional. This is a real,
# hardcoded architecture-support gap in vLLM 0.27.1's DeepGEMM build for
# DeepSeek-V4's mHC layers, not a flag we can work around -- confirmed via
# two consecutive deterministic crashes (bin/10's "Unknown SF
# transformation" and bin/12's "Unsupported architecture", both in
# DeepGEMM C++ code, both new regressions vs. 0.26.0 which never hit
# either).
#
# This script only touches the venv (pip packages); run
# bin/14-revert-to-baseline.sh (or equivalent) separately to remove the
# VLLM_USE_DEEP_GEMM=0 env line from the unit and restart.
#
# Run with: bash 13-rollback-vllm-flashinfer.sh   (no sudo needed --
# /data/vllm/.venv is user-owned)

set -euo pipefail

cd /data/vllm

echo "== 1. Current versions =="
.venv/bin/pip show vllm flashinfer-python 2>&1 | grep -E "^(Name|Version):"

echo
echo "== 2. Rolling back vllm 0.27.1 -> 0.26.0 =="
.venv/bin/pip install --upgrade 'vllm==0.26.0'

echo
echo "== 3. Rolling back flashinfer-python 0.6.17 -> 0.6.14 =="
.venv/bin/pip install --upgrade 'flashinfer-python==0.6.14'

echo
echo "== 4. Resulting versions =="
.venv/bin/pip show vllm flashinfer-python 2>&1 | grep -E "^(Name|Version):"

echo
echo "Done. This does NOT touch the systemd unit or restart the service."
echo "Next: remove Environment=VLLM_USE_DEEP_GEMM=0 from the unit (added"
echo "by bin/12, no longer needed/relevant on 0.26.0), then"
echo "sudo systemctl restart vllm-deepseek-v4-flash.service and confirm"
echo "we're back to the known degenerate-output-but-running baseline."
