#!/usr/bin/env bash
# feat-3-qwen3.8-27b-large-context — Phase 0 environment check
#
# Covers Task 0.1 (disk headroom), Task 0.2 (GB10/driver/CUDA + vLLM
# arm64 build version + Qwen3.8 architecture support), Task 0.3 (HF
# tooling).
#
# Read-only: does not download weights, does not modify anything.
# Run this ON THE DELL GB10 (DGX Spark clone), not on any other box.

set -euo pipefail

echo "=== Sanity: is this actually the Dell GB10? ==="
uname -m
grep -m1 'model name' /proc/cpuinfo || true
hostnamectl 2>/dev/null || hostname
echo

echo "=== Task 0.1: disk headroom ==="
df -h /
df -h "$HOME" 2>/dev/null || true
echo

echo "=== Task 0.2: GPUs (GB10 = 1x Grace-Blackwell, unified memory) ==="
nvidia-smi -L || echo "WARNING: nvidia-smi not found or no GPUs visible — GB10 driver not installed?"
echo
nvidia-smi --query-gpu=index,name,driver_version,memory.total,memory.free --format=csv || true
echo

echo "=== Task 0.2: CUDA toolkit ==="
nvcc --version 2>/dev/null || echo "nvcc not on PATH (may still be fine if only the driver/runtime matters)"
echo

echo "=== Task 0.2: vLLM version (must be an arm64 build for the GB10) ==="
VLLM_VERSION="$(python3 -c 'import vllm; print(vllm.__version__)' 2>&1)" || true
echo "vllm.__version__ = ${VLLM_VERSION}"
echo

echo "=== Task 0.2: does this vLLM build know about Qwen3.8 / qwen3_5 / Gated DeltaNet? ==="
python3 - <<'PYEOF' 2>&1 || true
import sys
try:
    from vllm.model_executor.models.registry import ModelRegistry
    names = sorted(ModelRegistry.get_supported_archs())
    hits = [n for n in names if "qwen3" in n.lower() or "deltanet" in n.lower() or "qwen3_5" in n.lower()]
    print("Qwen3.x / DeltaNet-related architectures registered:")
    for h in hits:
        print(" -", h)
    if not hits:
        print("NONE FOUND — this vLLM build likely does NOT support Qwen3.8-27B yet.")
except Exception as e:
    print(f"Could not introspect vLLM model registry: {e!r}")
    sys.exit(0)
PYEOF
echo

echo "=== Task 0.3: HF CLI / token ==="
hf --version 2>/dev/null || huggingface-cli --version 2>/dev/null || echo "hf/huggingface-cli not found on PATH"
hf auth whoami 2>/dev/null || huggingface-cli whoami 2>/dev/null || echo "Not logged in to Hugging Face (or CLI subcommand differs by version)"
echo

echo "=== Task 0.3: hf_transfer ==="
python3 -c "import hf_transfer; print('hf_transfer OK')" 2>&1 || echo "hf_transfer not installed"
echo

echo "=== Done. Paste this whole output back for review. ==="
