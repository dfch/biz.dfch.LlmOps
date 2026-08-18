#!/usr/bin/env bash
# Upgrade vLLM and FlashInfer as a candidate fix for the Task 1.4
# correctness bug (degenerate/garbage generation from
# deepseek-ai/DeepSeek-V4-Flash under vLLM 0.26.0 + flashinfer-python
# 0.6.14).
#
# Rationale (verified via direct GitHub/PyPI checks, 2026-08-18):
#   - vLLM v0.27.0's real release notes (github.com/vllm-project/vllm/
#     releases/tag/v0.27.0) list a "DeepSeek-V4 performance push" including
#     "removal of sparse-MLA q-head padding on FlashInfer >= 0.6.14"
#     (PR #48047) -- i.e. 0.6.14 (our current flashinfer) is the stated
#     floor for that fix, not a version confirmed fully correct for SM120
#     sparse-MLA decode specifically.
#   - flashinfer-python 0.6.17 (github.com/flashinfer-ai/flashinfer/
#     releases/tag/v0.6.17) lists "Blackwell SM12x fused MoE refreshed,
#     with an FP4 accuracy fix" and sparse-MLA decode geometry-handling
#     changes (PR #4178) -- both postdate and directly target our exact
#     hardware (SM120) and kernel family
#     (FLASHINFER_MLA_SPARSE_DSV4/trtllm_batch_decode_sparse_mla_dsv4).
#   - This is NOT a confirmed fix -- no upstream issue we found claims
#     0.27.1/0.6.17 resolves the identical-token/identical-logprob
#     signature we hit. It is the next reasonable diagnostic after ruling
#     out CUDA graphs (bin/08), the TP-vs-DP+EP execution path (bin/09,
#     vLLM #47528's pattern), and torch.compile fusion passes (vLLM
#     #50773, ruled out via startup log inspection during the bin/09 run).
#
# This script only touches the venv (pip packages); it does NOT modify
# the systemd unit. Run bin/11-revert-diag-and-test.sh (or equivalent)
# separately to restore the unit to its TP=4/370K production config
# before restarting the service.
#
# Run with: bash 10-upgrade-vllm-flashinfer.sh   (no sudo needed --
# /data/vllm/.venv is user-owned)

set -euo pipefail

cd /data/vllm

echo "== 1. Current versions =="
.venv/bin/pip show vllm flashinfer-python 2>&1 | grep -E "^(Name|Version):"

echo
echo "== 2. Upgrading vllm 0.26.0 -> 0.27.1 =="
.venv/bin/pip install --upgrade 'vllm==0.27.1'

echo
echo "== 3. Upgrading flashinfer-python 0.6.14 -> 0.6.17 =="
.venv/bin/pip install --upgrade 'flashinfer-python==0.6.17'

echo
echo "== 4. Resulting versions =="
.venv/bin/pip show vllm flashinfer-python 2>&1 | grep -E "^(Name|Version):"

echo
echo "Done. This does NOT touch the systemd unit or restart the service."
echo "Next: revert bin/09's diagnostic unit changes (TP=4, 370K context),"
echo "then sudo systemctl restart vllm-deepseek-v4-flash.service and"
echo "re-run the temperature=0 smoke test."
