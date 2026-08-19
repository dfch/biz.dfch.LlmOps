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

echo "== 5. Enforce a single CUDA-toolkit line (${CUDA_LINE}.x) to avoid the"
echo "      Task 1.3 fix #4 / bin/15 wheel skew =="
# Pin the six CUDA component wheels that previously drifted apart to the same
# ${CUDA_LINE} line. Exact patch is resolved by pip within that minor.
"${PIP[@]}" install --upgrade \
  "nvidia-cuda-nvcc-cu13~=${CUDA_LINE}.0" \
  "nvidia-cuda-crt-cu13~=${CUDA_LINE}.0" \
  "nvidia-cuda-cccl-cu13~=${CUDA_LINE}.0" \
  "nvidia-cuda-runtime-cu13~=${CUDA_LINE}.0" \
  "nvidia-cuda-nvrtc-cu13~=${CUDA_LINE}.0" \
  "nvidia-cuda-cupti-cu13~=${CUDA_LINE}.0" || \
  echo "WARN: pin step reported an issue -- verify wheel lines manually with pip freeze before starting the service."

echo "== 6. Bake in the cudart symlinks (Task 1.3 fix #7 / bin/07) =="
CU13_LIB="$CLEAN_VENV/lib/python3.12/site-packages/nvidia/cu13/lib"
if [ -d "$CU13_LIB" ]; then
  ( cd "$CU13_LIB"
    [ -e lib64 ] || ln -s . lib64
    if [ -e libcudart.so.13 ] && [ ! -e libcudart.so ]; then
      ln -s libcudart.so.13 libcudart.so
    fi
  )
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
