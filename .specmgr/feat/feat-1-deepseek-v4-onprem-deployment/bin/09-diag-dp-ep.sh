#!/usr/bin/env bash
# Diagnostic (not a confirmed fix) for vllm-deepseek-v4-flash.service's
# Task 1.4 correctness bug: switch from tensor-parallelism to
# data-parallelism + expert-parallelism to test whether the degenerate/
# garbage output is specific to the TP execution path.
#
# Rationale: upstream vLLM GitHub issue #47528 ("[Bug]: DeepSeek-V4-Pro
# (DeepseekV4ForCausalLM, scale_fmt=ue8m0 / FP4 MoE) produces garbled /
# degenerate output under tensor parallelism (TP), while data parallelism
# + expert parallelism (DP+EP) works correctly",
# https://github.com/vllm-project/vllm/issues/47528, confirmed real and
# open as of 2026-08-18) reports the *exact* failure signature we saw in
# Task 1.4: HTTP 200, no NaN/error/warning in logs, every prompt collapses
# into confident-argmax garbage under TP (TP16, TP8+PP2 both tried), while
# switching to DP+EP with the identical weights produces fully correct
# output. That report is for DeepSeek-V4-Pro's native FP4 MoE experts; our
# Flash deployment also runs its MoE experts at native (FP4+FP8 mixed)
# precision under --tensor-parallel-size 4, so the same TP-path bug class
# is plausible here.
#
# This script is a *diagnostic*, not a fix: it swaps
#   --tensor-parallel-size 4
# for
#   --data-parallel-size 4 --enable-expert-parallel
# and temporarily shrinks --max-model-len from 370000 to 8192 (to keep
# the smoke-test startup/KV-cache-allocation fast -- NOT the production
# context target). If output is coherent under DP+EP, the bug is
# TP-path-specific (matching #47528) and we have an immediate workaround
# to build on. If output is still degenerate, the bug is elsewhere
# (attention backend, quantization, kv-cache scaling) and DP+EP is ruled
# out.
#
# Revert this (restore --tensor-parallel-size 4, remove
# --data-parallel-size/--enable-expert-parallel, restore
# --max-model-len 370000) once the experiment's result is known, if the
# eventual real fix is not "switch to DP+EP permanently".
#
# Run with: sudo bash 09-diag-dp-ep.sh

set -euo pipefail

UNIT=/etc/systemd/system/vllm-deepseek-v4-flash.service

echo "== 1. Stopping service =="
systemctl stop vllm-deepseek-v4-flash.service || true

echo "== 2. Killing any leftover VLLM:: processes =="
pkill -9 -f 'VLLM::' || true
sleep 2

echo "== 3. GPU memory after cleanup =="
nvidia-smi --query-gpu=index,memory.used,memory.free --format=csv

echo "== 4. Swapping --tensor-parallel-size 4 for --data-parallel-size 4 --enable-expert-parallel =="
sed -i \
  -e 's/    --tensor-parallel-size 4 \\/    --data-parallel-size 4 \\\n    --enable-expert-parallel \\/' \
  "$UNIT"

echo "== 5. Shrinking --max-model-len 370000 -> 8192 for a fast diagnostic run =="
sed -i 's/    --max-model-len 370000 \\/    --max-model-len 8192 \\/' "$UNIT"

echo "== 6. Resulting ExecStart block =="
sed -n '/^ExecStart=/,/^ExecReload=/p' "$UNIT" | head -n -1

echo "== 7. Reloading systemd daemon =="
systemctl daemon-reload

echo
echo "Done. Service is stopped and GPUs are clean. Next steps:"
echo "  sudo systemctl start vllm-deepseek-v4-flash.service"
echo "  journalctl -u vllm-deepseek-v4-flash.service -f"
echo
echo "Once up, re-run the same temp=0 smoke test used in Task 1.4 and"
echo "compare output. Remember: --max-model-len 8192 here is diagnostic-"
echo "only, not the 350-370K production target -- restore it (and decide"
echo "on TP vs DP+EP permanently) once the correctness result is known."
