#!/usr/bin/env bash
# feat-3-qwen3.8-27b-large-context — build/setup script for a NEW system
#
# Reproduces the environment work behind the CHOSEN PRODUCTION deployment
# (NVFP4 weights, 896K context via YaRN factor 3.5, MTP speculative
# decoding, FP8 KV cache) on a fresh GB10-class box (arm64,
# Grace-Blackwell/SM121, ~120 GB unified CPU+GPU memory pool) or
# equivalent hardware with enough VRAM/unified memory for the same
# config. See the feature README's Phase 0/1 and Phase 6 (Task 6.2/6.3)
# for the full narrative behind every step and fix below.
#
# Idempotent: safe to re-run; skips steps whose result already exists.
# Read/write to $HOME only -- no sudo/root required anywhere (every fix
# below was deliberately chosen to avoid needing interactive sudo, since
# it was unavailable on the box this was developed on).
#
# Does NOT install the systemd service -- run 02-install-service.sh
# after this succeeds.
#
# Env vars (all optional, defaults match this feature's own deployment):
#   VENV_DIR       venv location for vLLM        (default: $HOME/venvs/vllm)
#   MODEL_DIR      NVFP4 checkpoint destination   (default: $HOME/models/qwen3.8-27b-nvfp4)
#   VLLM_PIN       pinned vLLM PyPI version       (default: 0.27.1)
#   HF_TOKEN       Hugging Face token (only needed if the repo ever
#                  becomes gated -- it was NOT gated as of 2026-08-23)
set -euo pipefail

MODEL_REPO="unsloth/Qwen3.8-27B-NVFP4"
MODEL_REVISION="7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108"
VENV_DIR="${VENV_DIR:-$HOME/venvs/vllm}"
MODEL_DIR="${MODEL_DIR:-$HOME/models/qwen3.8-27b-nvfp4}"
VLLM_PIN="${VLLM_PIN:-0.27.1}"

echo "=== Sanity: platform ==="
uname -m
nvidia-smi -L || { echo "ERROR: no NVIDIA GPU visible -- install/verify the driver first (see 00-check-env.sh)."; exit 1; }
echo

echo "=== Step 1: uv (used for both Python tooling and the vLLM venv) ==="
if ! command -v uv >/dev/null 2>&1; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi
uv --version
echo

echo "=== Step 2: standalone Python 3.12 headers (Python.h) ==="
# Why: vLLM's Triton JIT step shells out to gcc to inspect the model
# architecture; gcc needs Python.h. python3.12-dev is often not
# installed system-wide and apt requires sudo, which may not be
# available non-interactively. uv's standalone CPython build ships
# headers with no sudo needed. Only the MINOR version (3.12) needs to
# match the venv's interpreter to avoid a C-API ABI mismatch -- the
# exact patch version does not matter.
if ! uv python list 2>/dev/null | grep -q 'cpython-3\.12.*linux'; then
  uv python install 3.12
fi
PYHDR="$(find "$HOME/.local/share/uv/python" -maxdepth 4 -path '*cpython-3.12*/include/python3.12/Python.h' 2>/dev/null | head -1)"
if [ -z "${PYHDR}" ]; then
  echo "ERROR: could not locate uv-installed CPython 3.12 headers (Python.h)." >&2
  exit 1
fi
export CPATH="$(dirname "${PYHDR}")"
echo "Python.h headers: ${CPATH}"
echo

echo "=== Step 3: vLLM venv (pinned to ${VLLM_PIN}, aarch64) ==="
if [ ! -x "${VENV_DIR}/bin/vllm" ]; then
  uv venv "${VENV_DIR}" --python 3.12
  uv pip install --python "${VENV_DIR}/bin/python" "vllm==${VLLM_PIN}" hf-transfer
else
  INSTALLED="$("${VENV_DIR}/bin/python" -c 'import vllm; print(vllm.__version__)' 2>/dev/null || echo unknown)"
  echo "vLLM already installed at ${VENV_DIR} (version ${INSTALLED})"
  if [ "${INSTALLED}" != "${VLLM_PIN}" ]; then
    echo "WARNING: installed version (${INSTALLED}) != pinned version (${VLLM_PIN})."
    echo "This feature's NVFP4/GB10 (SM121) kernel findings (Task 6.2 step 1) were"
    echo "verified specifically on ${VLLM_PIN} -- re-verify the kernel check in Step 5"
    echo "below on a different version before trusting the production config as-is."
  fi
fi
# ninja ships as a pip dependency of vllm, but torch.compile only finds
# it at RUNTIME if the venv's bin/ is on PATH (baked into the launch
# script by 02-install-service.sh, not needed here) -- just confirm it
# actually got installed.
"${VENV_DIR}/bin/python" -c "import ninja" 2>/dev/null && echo "ninja: OK (inside venv)" || echo "WARNING: ninja not found inside the venv -- torch.compile will fail at launch time."
echo

echo "=== Step 4: confirm this vLLM build recognizes Qwen3.8's architecture (qwen3_5) ==="
CPATH="${CPATH}" PATH="${VENV_DIR}/bin:$PATH" "${VENV_DIR}/bin/python" - <<'PYEOF'
from vllm.model_executor.models.registry import ModelRegistry
names = sorted(ModelRegistry.get_supported_archs())
hits = [n for n in names if "qwen3_5" in n.lower()]
print("qwen3_5 architectures registered:", hits or "NONE FOUND")
if not hits:
    raise SystemExit("ERROR: this vLLM build does not support Qwen3.8-27B's architecture")
PYEOF
echo

echo "=== Step 5: confirm NVFP4 GEMM kernel support for this GPU (Task 6.2 step 1 check) ==="
# NOTE: a community report (see README Phase 6, Task 6.2 step 1) found
# stock vllm/vllm-openai lacking NVFP4 kernels for Blackwell sm_121a on
# an older nightly build -- this feature's own stock PyPI 0.27.1 release
# DOES have them. Re-verify on whatever vLLM version actually installs
# here; if this fails, either pin back to a known-good version or treat
# NVFP4 as blocked on this hardware (see README for the fallback
# discussion, e.g. a community GB10-specific build).
CPATH="${CPATH}" PATH="${VENV_DIR}/bin:$PATH" "${VENV_DIR}/bin/python" - <<'PYEOF' || echo "WARNING: could not confirm NVFP4 kernel support -- inspect manually before trusting the production launch script."
try:
    from vllm._custom_ops import cutlass_scaled_mm_supports_fp4
    import torch
    cc = torch.cuda.get_device_capability(0)
    cc_int = cc[0] * 10 + cc[1]
    print(f"GPU compute capability: {cc} ({cc_int})")
    print("cutlass_scaled_mm_supports_fp4:", cutlass_scaled_mm_supports_fp4(cc_int))
except Exception as e:
    print(f"Could not run the kernel check: {e!r}")
    raise
PYEOF
echo

echo "=== Step 6: HF CLI + hf_transfer (inside the venv) ==="
"${VENV_DIR}/bin/hf" --version
if ! "${VENV_DIR}/bin/hf" auth whoami >/dev/null 2>&1; then
  echo "Not logged in to Hugging Face."
  if [ -n "${HF_TOKEN:-}" ]; then
    "${VENV_DIR}/bin/hf" auth login --token "${HF_TOKEN}"
  else
    echo "${MODEL_REPO} is NOT gated as of 2026-08-23, so an anonymous download"
    echo "should still work; set HF_TOKEN and re-run if it doesn't."
  fi
fi
echo

echo "=== Step 7: download ${MODEL_REPO} @ ${MODEL_REVISION} ==="
if [ -f "${MODEL_DIR}/config.json" ]; then
  echo "Model directory already exists at ${MODEL_DIR} -- skipping download."
  echo "Delete it first if you need to re-pull a different revision."
else
  mkdir -p "${MODEL_DIR}"
  HF_HUB_ENABLE_HF_TRANSFER=1 "${VENV_DIR}/bin/hf" download "${MODEL_REPO}" \
    --revision "${MODEL_REVISION}" \
    --local-dir "${MODEL_DIR}"
fi
echo

echo "=== Step 8: verify the tokenizer-truncation bug (fixed upstream 2026-08-15) is NOT present ==="
TRUNC="$("${VENV_DIR}/bin/python" -c "import json; print(json.load(open('${MODEL_DIR}/tokenizer.json'))['truncation'])")"
if [ "${TRUNC}" != "None" ]; then
  echo "ERROR: tokenizer.json 'truncation' field is '${TRUNC}', expected null/None." >&2
  echo "This is the community-reported bug described in the README's Phase 6" >&2
  echo "references -- do not use this checkpoint revision as-is if it recurs." >&2
  exit 1
fi
echo "tokenizer.json truncation field is null -- OK"
echo

echo "=== BUILD COMPLETE ==="
echo "venv:      ${VENV_DIR} (vLLM ${VLLM_PIN})"
echo "model:     ${MODEL_DIR} (revision ${MODEL_REVISION})"
echo "Next: run 02-install-service.sh to deploy the launch script + systemd service."
