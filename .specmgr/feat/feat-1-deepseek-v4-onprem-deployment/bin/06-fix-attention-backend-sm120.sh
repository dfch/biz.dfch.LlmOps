#!/usr/bin/env bash
# Sixth fix for vllm-deepseek-v4-flash.service: switch to the SM120-capable
# FlashInfer sparse-MLA attention backend, and extend PATH so FlashInfer can
# find nvcc to enable it.
#
# Root cause (confirmed via journalctl on the 19:15:39/19:18:25 attempts,
# after 05-fix-missing-venv-path.sh resolved the earlier `ninja` PATH issue):
#   AssertionError: swa_metadata missing tile_sched entry for
#   compress_ratio=1; DeepseekSparseSWAMetadataBuilder.build_tile_scheduler
#   did not allocate one for this layer type.
#
#   Traced to vllm/v1/attention/backends/mla/sparse_swa.py
#   build_tile_scheduler(): it intentionally returns all-None tile-scheduler
#   metadata when current_platform.is_device_capability_family(120) is True
#   -- i.e. on our exact GPU (RTX PRO 6000 Blackwell Max-Q = compute
#   capability 12.0, "SM120"). But the FlashMLA-based decode path in
#   vllm/models/deepseek_v4/nvidia/flashmla.py (used by our explicitly
#   selected --attention-backend FLASHMLA_SPARSE_DSV4) unconditionally
#   requires that metadata to be non-None -- a genuine, unconditional gap in
#   this vLLM build's FlashMLA support for SM120.
#
#   The registry (vllm/v1/attention/backends/registry.py) has a dedicated
#   SM120-aware sibling backend for DeepSeek V4:
#   FLASHINFER_MLA_SPARSE_DSV4 (vllm/models/deepseek_v4/nvidia/
#   flashinfer_sparse.py), which auto-dispatches to
#   DeepseekV4FlashInferSM120Attention on SM120 and does not hit the
#   FlashMLA tile-scheduler gap. It requires FlashInfer's sparse MLA decode
#   API (has_flashinfer_sparse_mla_sm120()), which in turn requires `nvcc`
#   to be discoverable via `shutil.which("nvcc")` for has_flashinfer() to
#   return True. nvcc lives under
#   .venv/lib/python3.12/site-packages/nvidia/cu13/bin/, which the PATH set
#   by 05-fix-missing-venv-path.sh (venv bin/ only) does not cover.
#
#   Verified interactively: with both directories on PATH,
#   has_flashinfer() and has_flashinfer_sparse_mla_sm120() both return True.
#
# Run with: sudo bash 06-fix-attention-backend-sm120.sh

set -euo pipefail

UNIT=/etc/systemd/system/vllm-deepseek-v4-flash.service
NVCC_DIR=/data/vllm/.venv/lib/python3.12/site-packages/nvidia/cu13/bin

echo "== 1. Stopping service =="
systemctl stop vllm-deepseek-v4-flash.service || true

echo "== 2. Killing any leftover VLLM:: processes =="
pkill -9 -f 'VLLM::' || true
sleep 2

echo "== 3. GPU memory after cleanup (expect ~2 MiB used, ~97.8 GB free on all 4) =="
nvidia-smi --query-gpu=index,memory.used,memory.free --format=csv

echo "== 4. Extending PATH with the nvcc directory (idempotent) =="
if ! grep -q "$NVCC_DIR" "$UNIT"; then
  sed -i "s|^Environment=PATH=\(.*\)\$|Environment=PATH=\1:${NVCC_DIR}|" "$UNIT"
fi

echo "== 5. Switching attention backend to the SM120-capable FlashInfer DSV4 backend =="
sed -i \
  "s/--attention-backend FLASHMLA_SPARSE_DSV4/--attention-backend FLASHINFER_MLA_SPARSE_DSV4/" \
  "$UNIT"

echo "== 6. Resulting unit (PATH + ExecStart) =="
grep '^Environment=PATH=' "$UNIT"
sed -n '/^ExecStart=/,/^ExecReload=/p' "$UNIT" | head -n -1

echo "== 7. Reloading systemd daemon =="
systemctl daemon-reload

echo
echo "Done. Service is stopped and GPUs are clean. Next steps:"
echo "  sudo systemctl start vllm-deepseek-v4-flash.service"
echo "  journalctl -u vllm-deepseek-v4-flash.service -f"
