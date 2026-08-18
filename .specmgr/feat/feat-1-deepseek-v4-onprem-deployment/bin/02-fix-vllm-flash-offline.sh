#!/usr/bin/env bash
# Second fix for vllm-deepseek-v4-flash.service: force fully offline HF loading.
#
# Root cause (found via py-spy stack dumps on the hung 18:18:18 attempt):
#   - EngineCore waits for all 4 TP workers to finish __init__.
#   - Workers TP0/TP1/TP2 are blocked acquiring a filelock inside
#     download_weights_from_hf().
#   - Worker TP3 is holding that lock, stuck inside
#     huggingface_hub.snapshot_download() -> 8 threads all blocked in
#     `xet_get` (HF's Xet chunk-storage backend) -- i.e. an outbound network
#     call to Hugging Face that never returns on this internal-only network.
#   - Since the model is already fully downloaded locally at the pinned
#     revision (config.json, tokenizer files, generation_config.json, and all
#     safetensors shards confirmed present), this network round-trip on every
#     `vllm serve` startup is unnecessary -- it should load 100% from the
#     local HF cache. Forcing offline mode removes the network call (and the
#     resulting hang) entirely, and is also more correct for a pinned,
#     reproducible deployment (no drift-checking against the Hub at all).
#
# This script: stops the (still-hung) service, cleans up its stuck GPU
# processes, adds HF_HUB_OFFLINE=1 / TRANSFORMERS_OFFLINE=1 to the unit,
# reloads systemd, and leaves the service stopped so you can start it
# manually and watch logs.
#
# Run with: sudo bash 02-fix-vllm-flash-offline.sh

set -euo pipefail

UNIT=/etc/systemd/system/vllm-deepseek-v4-flash.service

echo "== 1. Stopping service =="
systemctl stop vllm-deepseek-v4-flash.service || true

echo "== 2. Killing any leftover VLLM:: processes =="
pkill -9 -f 'VLLM::' || true
sleep 2

echo "== 3. GPU memory after cleanup (expect ~2 MiB used, ~97.8 GB free on all 4) =="
nvidia-smi --query-gpu=index,memory.used,memory.free --format=csv

echo "== 4. Adding offline-mode env vars to the unit (idempotent) =="
grep -q '^Environment=HF_HUB_OFFLINE=' "$UNIT" || \
  sed -i '/^Environment=HF_HOME=/a Environment=HF_HUB_OFFLINE=1\nEnvironment=TRANSFORMERS_OFFLINE=1' "$UNIT"

echo "== 5. Resulting Environment= lines =="
grep '^Environment=' "$UNIT"

echo "== 6. Reloading systemd daemon =="
systemctl daemon-reload

echo
echo "Done. Service is stopped and GPUs are clean. Next steps:"
echo "  sudo systemctl start vllm-deepseek-v4-flash.service"
echo "  journalctl -u vllm-deepseek-v4-flash.service -f"
echo
echo "This should now load entirely from local cache -- no network calls,"
echo "so the previous multi-minute stall/hang should be gone. If a file is"
echo "genuinely missing from the local snapshot, it will now fail fast with"
echo "a clear file-not-found error instead of hanging silently."
