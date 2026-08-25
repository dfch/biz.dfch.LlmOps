#!/usr/bin/env bash
# Task 0.3: build the fully isolated /data/qwen3.8-27b/.venv (vLLM 0.26.0),
# independent of feat-1's /data/vllm/.venv, then re-run Task 0.2's
# qwen3_5-registry / NVFP4-kernel / CLI-flag checks inside this new venv.
#
# Why a minimal-resolve strategy (user decision, 2026-08-25): feat-1's
# clean-venv build (bin/18-build-clean-venv.sh in feat-1's bin/) force-pins
# several extra packages -- fastokens==0.3.1 (only needed if
# VLLM_USE_FASTOKENS=1 is set, a DeepSeek-unit-level choice this feature
# never makes), quack-kernels==0.6.1 (a genuine transitive vllm dependency),
# and ml_dtypes==0.5.4 (needed by tilelang, which is used for DeepSeek-V4's
# mHC layers -- Qwen3.8-27B's Gated DeltaNet + Gated Attention layout has no
# such layer). Rather than blindly reproduce DeepSeek-specific pins into a
# venv meant to serve a structurally different model, this script installs
# only `vllm==0.26.0` + `flashinfer-python==0.6.14` and lets uv/pip resolve
# the rest naturally, then applies ONLY the two fixes feat-1 proved to be
# hardware/toolchain-level (i.e. not model-specific):
#   1. Pin the nvidia-cuda-* wheels to a single 13.3.x line (feat-1 Task 1.3
#      fix #4 / bin/04, re-confirmed by bin/15) -- avoids a version skew
#      that breaks JIT-compiled CUDA extensions (TileLang/FlashInfer).
#   2. Bake in the cudart lib64 + unversioned-.so symlinks (feat-1 Task 1.3
#      fix #7 / bin/07) -- FlashInfer's JIT linker expects a classic
#      toolkit layout, not the pip wheel's lib/-only, versioned-only layout.
# A pip-freeze diff against /data/vllm/.venv is produced at the end so any
# other divergence is visible and recorded, not silently assumed away.
#
# Run with: bash 01-build-venv.sh
#   (no sudo -- writes only under /data/qwen3.8-27b, owned by the invoking
#   user, same precedent as feat-1's bin/18)

set -euo pipefail

VENV=/data/qwen3.8-27b/.venv
VLLM_VERSION=0.26.0
FLASHINFER_VERSION=0.6.14
PYTHON_VERSION=3.12

echo "== 1. Guard: refuse to clobber an existing venv =="
if [ -e "$VENV" ]; then
  echo "ERROR: $VENV already exists. Remove or rename it first if a rebuild" >&2
  echo "       is intended. Refusing to overwrite." >&2
  exit 1
fi

echo "== 2. Create the isolated venv with uv (REQ-005/REQ-009 isolation) =="
# Matches production's interpreter minor version (3.12); patch version is
# whatever uv already has cached (3.12.13 at the time this script was
# written) -- not pinned to the exact patch, since no bug in this feature's
# history has ever been traced to a CPython patch release.
uv venv "$VENV" --python "$PYTHON_VERSION"
PY=("$VENV/bin/python")
PIP=("$VENV/bin/python" -m pip)
"${PY[@]}" -m ensurepip --upgrade || true
"${PIP[@]}" install --upgrade pip

echo "== 3. Install pinned vLLM + flashinfer, let uv/pip resolve the rest =="
"${PIP[@]}" install "vllm==${VLLM_VERSION}" "flashinfer-python==${FLASHINFER_VERSION}"

echo "== 4. Enforce a single CUDA-toolkit line (13.3.x), matching production =="
# Same exact versions as feat-1's production /data/vllm/.venv (confirmed via
# pip freeze on 2026-08-25) -- these six wheels previously drifted apart
# (nvidia-cuda-nvcc/-crt/-cccl on 13.3.x vs -runtime/-nvrtc/-cupti on stale
# 13.0.x) and broke TileLang/FlashInfer JIT compiles. Pinning exact versions
# (not a `~=` range) removes any dependence on the resolver picking matching
# transitive versions on a future rebuild.
"${PIP[@]}" install --upgrade \
  "nvidia-cuda-nvcc==13.3.73" \
  "nvidia-cuda-crt==13.3.73" \
  "nvidia-cuda-cccl==13.3.3.4.1" \
  "nvidia-cuda-runtime==13.3.29" \
  "nvidia-cuda-nvrtc==13.3.33" \
  "nvidia-cuda-cupti==13.3.75" \
  "nvidia-cuda-nvdisasm==13.3.73" || \
  echo "WARN: pin step reported an issue -- verify wheel lines manually with pip freeze before trusting JIT-compiled kernels."

echo "== 5. Bake in the cudart symlinks (feat-1 Task 1.3 fix #7 / bin/07) =="
CU13="$VENV/lib/python${PYTHON_VERSION}/site-packages/nvidia/cu13"
CU13_LIB="$CU13/lib"
if [ -d "$CU13_LIB" ]; then
  [ -e "$CU13/lib64" ] || ln -s lib "$CU13/lib64"
  if [ -e "$CU13_LIB/libcudart.so.13" ] && [ ! -e "$CU13_LIB/libcudart.so" ]; then
    ln -s libcudart.so.13 "$CU13_LIB/libcudart.so"
  fi
  echo "   symlinks ensured under $CU13_LIB"
else
  echo "WARN: expected CUDA lib dir not found at $CU13_LIB -- layout may differ;"
  echo "      verify FlashInfer's JIT linker can find libcudart before serving (Phase 1)."
fi

echo "== 6. Re-run Task 0.2's qwen3_5 registry / NVFP4 kernel checks, inside THIS venv =="
"${PY[@]}" -c "
from vllm.model_executor.models.registry import ModelRegistry
archs = ModelRegistry.get_supported_archs()
print('Qwen3_5ForConditionalGeneration registered:', 'Qwen3_5ForConditionalGeneration' in archs)
print('Qwen3_5MTP registered:', 'Qwen3_5MTP' in archs)
"
"${PY[@]}" -c "
from vllm._custom_ops import cutlass_scaled_mm_supports_fp4
print('cutlass_scaled_mm_supports_fp4(120):', cutlass_scaled_mm_supports_fp4(120))
"

echo "== 7. Re-run Task 0.2's CLI-flag check =="
"$VENV/bin/vllm" serve --help=all 2>&1 | grep -E -- \
  "--kv-cache-dtype|--kv-cache-memory-bytes|--hf-overrides|--speculative-config|--tensor-parallel-size|--served-model-name|--tool-call-parser|--reasoning-parser|--enable-auto-tool-choice|--linear-backend" \
  || echo "WARN: one or more expected CLI flags not found -- inspect full --help=all output."

echo "== 8. Record installed versions, and diff against production for visibility =="
# Written into this feature's tracked bin/baselines/ (not /tmp) so the
# snapshot survives as a permanent, version-controlled audit artifact --
# same precedent as feat-1's bin/16-snapshot-baseline.sh -> bin/baselines/.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASELINE_DIR="$SCRIPT_DIR/baselines"
mkdir -p "$BASELINE_DIR"
FREEZE_FILE="$BASELINE_DIR/$(date -u +%F)-task-0.3-venv-freeze.txt"
"${PIP[@]}" freeze > "$FREEZE_FILE"
echo "-- key versions in the new venv --"
grep -E "^vllm|^flashinfer|^torch==|^transformers|^nvidia-cuda" "$FREEZE_FILE"
echo "-- diff vs /data/vllm/.venv (production), '<' = new venv only, '>' = production only --"
diff <(sort "$FREEZE_FILE") <(/data/vllm/.venv/bin/pip freeze | sort) || true

echo
echo "Done. Isolated venv built at: $VENV"
echo "Next: Task 0.6 (pin + download BF16/NVFP4 weights) into the shared HF cache."
