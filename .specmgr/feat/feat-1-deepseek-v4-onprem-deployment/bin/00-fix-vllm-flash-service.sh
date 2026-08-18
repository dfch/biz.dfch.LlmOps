#!/usr/bin/env bash
# Fix for vllm-deepseek-v4-flash.service crash-loop
#
# Root cause:
#   1. Cold-start weight load (186 GB across 4x GPU) + CUDA-graph capture for
#      the 370K-context config exceeded TimeoutStartSec=1800 (30 min); systemd
#      killed the start attempt right around when the workers had already
#      finished loading weights into GPU memory (~71.5 GB/GPU).
#   2. KillMode=process only signals the main PID, not the EngineCore/Worker
#      subprocesses it forked -- so those 4 workers were orphaned but kept
#      running, permanently holding ~71.5 GB/GPU. Every subsequent restart
#      attempt then fails with "Free memory ... is less than desired" because
#      the orphans never released their memory, and Restart=on-failure just
#      repeats this forever.
#
# This script: stops the service, kills the orphaned GPU processes, patches
# the unit (KillMode=control-group, TimeoutStartSec=3600), reloads systemd,
# and leaves the service stopped so you can start it manually and watch logs.
#
# Run with: sudo bash 00-fix-vllm-flash-service.sh

set -euo pipefail

echo "== 1. Stopping service =="
systemctl stop vllm-deepseek-v4-flash.service || true

echo "== 2. Killing any leftover VLLM:: processes =="
pkill -9 -f 'VLLM::' || true

echo "== 3. Killing known orphaned PIDs from this boot (if still present) =="
kill -9 5885 5886 6776 6777 6841 6842 2>/dev/null || true

sleep 2

echo "== 4. GPU memory after cleanup (expect ~2 MiB used, ~97.8 GB free on all 4) =="
nvidia-smi --query-gpu=index,memory.used,memory.free --format=csv

echo "== 5. Patching unit file: KillMode=control-group, TimeoutStartSec=3600 =="
sed -i \
  -e 's/^KillMode=process/KillMode=control-group/' \
  -e 's/^TimeoutStartSec=1800/TimeoutStartSec=3600/' \
  /etc/systemd/system/vllm-deepseek-v4-flash.service

echo "== 6. Resulting [Service] KillMode/TimeoutStartSec lines =="
grep -E '^(KillMode|TimeoutStartSec)=' /etc/systemd/system/vllm-deepseek-v4-flash.service

echo "== 7. Reloading systemd daemon =="
systemctl daemon-reload

echo
echo "Done. Service is stopped and GPUs are clean. Next steps:"
echo "  sudo systemctl start vllm-deepseek-v4-flash.service"
echo "  journalctl -u vllm-deepseek-v4-flash.service -f"
echo
echo "Be patient -- cold start can legitimately take up to ~30-45 min."
echo "Once it's up, smoke test with:"
echo '  curl -s http://localhost:8000/v1/chat/completions -H "Content-Type: application/json" \'
echo '    -d '"'"'{"model":"deepseek-ai/DeepSeek-V4-Flash","messages":[{"role":"user","content":"test"}]}'"'"
