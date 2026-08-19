#!/usr/bin/env bash
# Step 1 / Track A of the Task 1.4 unblock plan (2026-08-19T08:04:27Z
# session): test whether the degenerate output is caused by fp8 KV-cache
# used WITHOUT proper scaling factors.
#
# Rationale: vLLM logs its own warning on this deployment --
#   "may cause accuracy drop without a proper scaling factor"
# for --kv-cache-dtype fp8. Of the remaining live suspects for the
# identical-token-every-position degenerate signature (fp8 kv-cache scaling,
# the FLASHINFER_MLA_SPARSE_DSV4 SM120 decode kernel, native FP4+FP8 quant
# numerics), fp8 kv-cache is the cheapest to isolate: a single flag change,
# no rebuild.
#
# This is a DIAGNOSTIC, not a confirmed fix. It removes --kv-cache-dtype fp8
# so the KV cache falls back to `auto` (fp16/bf16), keeping everything else
# identical to the current baseline (TP=4, native FP4+FP8 mixed experts,
# FLASHINFER_MLA_SPARSE_DSV4, --enforce-eager, --max-model-len 8192).
#
# Decision gate after running:
#   * Coherent output  -> fp8 kv-cache scaling was the cause. Per user
#     decision (2026-08-19), adopt non-fp8 kv-cache as the working fix and
#     proceed to bin/20-restore-production-config.sh; re-check Task 1.6
#     context headroom since non-fp8 KV cache ~doubles KV memory.
#   * Identical degenerate output (same frozen token + logprob as the
#     bin/16 baseline) -> fp8 kv-cache ruled out. Proceed to the fresh
#     side-by-side venv path (bin/18 / bin/19).
#
# Revert (restore --kv-cache-dtype fp8) is only needed if the eventual real
# fix is not "drop fp8 kv-cache" -- otherwise this change stays.
#
# Run with: sudo bash 17-diag-no-fp8-kvcache.sh

set -euo pipefail

UNIT=/etc/systemd/system/vllm-deepseek-v4-flash.service

echo "== 1. Stopping service =="
systemctl stop vllm-deepseek-v4-flash.service || true

echo "== 2. Killing any leftover VLLM:: processes =="
pkill -9 -f 'VLLM::' || true
sleep 2

echo "== 3. GPU memory after cleanup (expect ~2 MiB used, ~97.8 GB free on all 4) =="
nvidia-smi --query-gpu=index,memory.used,memory.free --format=csv

echo "== 4. Removing the --kv-cache-dtype fp8 line from ExecStart =="
if grep -q -- '--kv-cache-dtype fp8' "$UNIT"; then
  sed -i '/--kv-cache-dtype fp8 \\$/d' "$UNIT"
  echo "   removed."
else
  echo "   (no --kv-cache-dtype fp8 line found -- already absent, nothing to do)"
fi

echo "== 5. Resulting ExecStart block =="
sed -n '/^ExecStart=/,/^ExecReload=/p' "$UNIT" | head -n -1

echo "== 6. Reloading systemd daemon =="
systemctl daemon-reload

echo
echo "Done. Service is stopped, GPUs are clean, fp8 kv-cache disabled. Next:"
echo "  sudo systemctl start vllm-deepseek-v4-flash.service"
echo "  journalctl -u vllm-deepseek-v4-flash.service -f"
echo
echo "Once up, re-run bin/16-snapshot-baseline.sh (it will write a new"
echo "timestamped file) and diff its temp=0 response against the frozen"
echo "degenerate baseline:"
echo "  * different / coherent -> fp8 kv-cache was the cause (adopt as fix,"
echo "    then bin/20; re-check Task 1.6 context headroom)."
echo "  * identical frozen token + logprob -> fp8 kv-cache ruled out;"
echo "    proceed to bin/18 (clean side-by-side venv)."
