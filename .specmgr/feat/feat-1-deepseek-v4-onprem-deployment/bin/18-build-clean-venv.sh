#!/usr/bin/env bash
# Step 2 (fallback) of the Task 1.4 unblock plan (2026-08-19T08:04:27Z
# session): build a clean, side-by-side vLLM venv from scratch to rule out
# accumulated in-place-patch contamination as the cause of the degenerate
# output.
#
# Why: /data/vllm/.venv has been patched in place many times across the
# crash-loop debugging sessions (Task 1.3 fixes #4/#5/#7, the 0.27.1 upgrade
# and rollback, the bin/15 CUDA-toolkit-skew re-fix, plus repeated
# flashinfer/TileLang JIT cache rebuilds). That history is a plausible
# source of a stale JIT cache or a subtly mismatched wheel set that a clean
# build would not have. This script builds a pristine environment at the
# SAME pinned versions known to at least serve HTTP (vLLM 0.26.0 /
# flashinfer-python 0.6.14), with the hard-won environment fixes baked in
# from the start rather than patched in afterwards.
#
# IMPORTANT: this does NOT touch the existing /data/vllm/.venv. It builds a
# separate /data/vllm/.venv-clean and leaves the original fully intact as a
# rollback. The clean venv is wired into a *copy* of the systemd unit by the
# companion script bin/19-diag-clean-venv-unit.sh -- this script only builds
# the environment.
#
# Baked-in fixes (so the clean venv never reproduces the earlier bugs):
#   * Task 1.3 fix #4 / bin/15: keep all nvidia-cuda-* wheels on the SAME
#     13.3.x line (no runtime/nvrtc/cupti vs nvcc/crt/cccl skew).
#   * Task 1.3 fix #7 / bin/07: cudart lib64 + unversioned .so symlinks for
#     FlashInfer's JIT linker.
#   (PATH and offline-mode env are unit-level, applied by bin/19.)
#
# Run with: bash 18-build-clean-venv.sh
#   (no sudo -- writes only under /data/vllm, owned by the serving user)

set -euo pipefail

CLEAN_VENV=/data/vllm/.venv-clean
VLLM_VERSION=0.26.0
FLASHINFER_VERSION=0.6.14
CUDA_LINE=13.3   # keep every nvidia-cuda-* wheel on this major.minor line

echo "== 1. Guard: refuse to clobber an existing clean venv =="
if [ -e "$CLEAN_VENV" ]; then
  echo "ERROR: $CLEAN_VENV already exists. Remove or rename it first if you"
  echo "       intend to rebuild. Refusing to overwrite." >&2
  exit 1
fi

echo "== 2. Confirm the original venv is left untouched =="
echo "   original venv: /data/vllm/.venv (NOT modified by this script)"
echo "   clean venv:    $CLEAN_VENV (created fresh below)"

echo "== 3. Create the clean venv with uv =="
# uv is already the project's tooling (Task 0.3). Fall back to python -m venv
# if uv is unavailable.
if command -v uv >/dev/null 2>&1; then
  uv venv "$CLEAN_VENV" --python 3.12
  PIP=("$CLEAN_VENV/bin/python" -m pip)
  "$CLEAN_VENV/bin/python" -m ensurepip --upgrade || true
else
  python3.12 -m venv "$CLEAN_VENV"
  PIP=("$CLEAN_VENV/bin/python" -m pip)
fi
"${PIP[@]}" install --upgrade pip

echo "== 4. Install pinned vLLM + flashinfer (same versions as the baseline) =="
"${PIP[@]}" install "vllm==${VLLM_VERSION}" "flashinfer-python==${FLASHINFER_VERSION}"

echo "== 4b. Install packages that are runtime dependencies but NOT pulled in"
echo "       automatically by vllm/flashinfer's own metadata, plus two"
echo "       transitively-resolved packages pinned to match production"
echo "       exactly because they sit close to the actual compute path =="
# fastokens: the unit sets VLLM_USE_FASTOKENS=1; vllm hard-requires
# fastokens>=0.2.0 to be importable when that's set (fatal ImportError at
# tokenizer/renderer construction otherwise -- confirmed the hard way when
# bin/19's first clean-venv test crashed before even reaching model load).
# transformers: fastokens patches transformers internals directly
# ("successfully patched transformers v5.14.1" in the production log) --
# pin the exact version it was verified against, not whatever's newest.
# quack-kernels: Required-by: vllm (an actual CUDA-kernel package vLLM
# depends on, not a bystander) -- pin to match production exactly.
# IMPORTANT: install these BEFORE the CUDA-toolkit pin step below.
# quack-kernels' own dependency resolution pulls nvidia-cuda-runtime/
# -nvrtc/-cupti back down to a stale 13.0.x line if installed afterward --
# confirmed by reproducing the skew live during this script's own
# debugging. The CUDA-toolkit pin step below must run LAST so it's the one
# that wins.
"${PIP[@]}" install "fastokens==0.3.1" "transformers==5.14.1" "quack-kernels==0.6.1"

echo "== 4c. Pin ml_dtypes to match production =="
# Required-by: tilelang, which runs live JIT kernels during inference for
# DeepSeek-V4's mHC layers (confirmed in production logs: "TileLang JIT
# compilation during inference: mhc_fused_tilelang") -- close enough to the
# actual compute path to pin exactly rather than let it drift.
"${PIP[@]}" install "ml_dtypes==0.5.4"

echo "== 5. Enforce a single CUDA-toolkit line (${CUDA_LINE}.x) to avoid the"
echo "      Task 1.3 fix #4 / bin/15 wheel skew =="
# Pin the six CUDA component wheels that previously drifted apart to the
# EXACT versions confirmed working in the production baseline
# (bin/baselines/2026-08-19T09:10:23Z-degenerate.txt's pip freeze). Prior
# attempt used incorrect package names (a spurious "-cu13" suffix that does
# not exist on PyPI for these packages -- only nvidia-cuda-nvcc,
# nvidia-cuda-crt, etc., no suffix), which silently failed and left
# nvidia-cuda-runtime/-nvrtc/-cupti on a stale 13.0.x line while
# nvidia-cuda-nvcc/-crt/-cccl (pulled in transitively by vllm/flashinfer)
# resolved to 13.3.x -- reproducing the exact skew this step exists to
# prevent. Pinning exact versions (not just the ${CUDA_LINE} line via ~=)
# removes any dependence on pip's resolver picking the same transitive
# versions on a future rebuild.
"${PIP[@]}" install --upgrade \
  "nvidia-cuda-nvcc==13.3.73" \
  "nvidia-cuda-crt==13.3.73" \
  "nvidia-cuda-cccl==13.3.3.4.1" \
  "nvidia-cuda-runtime==13.3.29" \
  "nvidia-cuda-nvrtc==13.3.33" \
  "nvidia-cuda-cupti==13.3.75" \
  "nvidia-cuda-nvdisasm==13.3.73" || \
  echo "WARN: pin step reported an issue -- verify wheel lines manually with pip freeze before starting the service."

echo "== 6. Bake in the cudart symlinks (Task 1.3 fix #7 / bin/07) =="
# Must match bin/07-fix-cudart-symlinks.sh's actual layout exactly:
#   cu13/lib64 -> lib          (sibling-level symlink, NOT a self-link
#                                inside lib/ itself -- FlashInfer's JIT
#                                linker resolves cuda_home as
#                                dirname(dirname(which nvcc)) == cu13, then
#                                links -L$cuda_home/lib64 -lcudart, so
#                                cu13/lib64 must exist as its own entry)
#   cu13/lib/libcudart.so -> libcudart.so.13   (inside lib/, unversioned
#                                                dev symlink the runtime
#                                                wheel doesn't ship)
# A previous version of this script created a useless self-referential
# cu13/lib/lib64 -> . (i.e. inside lib/, pointing at itself) instead --
# wrong location AND wrong target, which does not satisfy the linker at
# all and silently reproduces the original bin/07 bug.
CU13="$CLEAN_VENV/lib/python3.12/site-packages/nvidia/cu13"
CU13_LIB="$CU13/lib"
if [ -d "$CU13_LIB" ]; then
  [ -e "$CU13/lib64" ] || ln -s lib "$CU13/lib64"
  if [ -e "$CU13_LIB/libcudart.so.13" ] && [ ! -e "$CU13_LIB/libcudart.so" ]; then
    ln -s libcudart.so.13 "$CU13_LIB/libcudart.so"
  fi
  echo "   symlinks ensured under $CU13_LIB"
else
  echo "WARN: expected CUDA lib dir not found at $CU13_LIB -- layout may differ;"
  echo "      verify FlashInfer's JIT linker can find libcudart before serving."
fi

echo "== 7. Verify the pinned versions actually installed =="
"${PIP[@]}" freeze | grep -Ei 'vllm|flashinfer|^torch|nvidia-cuda' || true

echo
echo "Done. Clean venv built at: $CLEAN_VENV (original .venv untouched)."
echo "Next: bin/19-diag-clean-venv-unit.sh to point a COPY of the unit at it"
echo "and run the temp=0 smoke test."
