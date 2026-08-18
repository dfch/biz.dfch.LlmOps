#!/usr/bin/env bash
# Fifth fix for vllm-deepseek-v4-flash.service: add the vLLM venv's bin/ to
# the unit's PATH so subprocesses vllm spawns by bare name (e.g. `ninja` for
# JIT-compiling CUDA extensions) can actually be found.
#
# Root cause (confirmed via journalctl on the 19:11:32 attempt, after
# 04-fix-cuda-toolkit-skew.sh resolved the earlier tilelang/nvcc CUDA
# toolkit version-skew error):
#   RuntimeError: Worker failed with error '[Errno 2] No such file or
#   directory: 'ninja''
#   `ninja` IS installed (pip package + working binary at
#   /data/vllm/.venv/bin/ninja -- confirmed runnable directly), but the
#   systemd unit has no Environment=PATH= entry, so the service falls back
#   to systemd's bare default PATH (/usr/local/sbin:/usr/local/bin:
#   /usr/sbin:/usr/bin:/sbin:/bin), which does not include the venv's bin/.
#   ExecStart itself uses an absolute path to vllm so it still launches, but
#   any subprocess vllm spawns by bare command name (like `ninja`) fails to
#   resolve.
#
# Run with: sudo bash 05-fix-missing-venv-path.sh

set -euo pipefail

UNIT=/etc/systemd/system/vllm-deepseek-v4-flash.service
VENV_BIN=/data/vllm/.venv/bin
DEFAULT_PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "== 1. Stopping service =="
systemctl stop vllm-deepseek-v4-flash.service || true

echo "== 2. Killing any leftover VLLM:: processes =="
pkill -9 -f 'VLLM::' || true
sleep 2

echo "== 3. GPU memory after cleanup (expect ~2 MiB used, ~97.8 GB free on all 4) =="
nvidia-smi --query-gpu=index,memory.used,memory.free --format=csv

echo "== 4. Adding PATH env var to the unit (idempotent) =="
grep -q '^Environment=PATH=' "$UNIT" || \
  sed -i "/^Environment=HF_HOME=/i Environment=PATH=${VENV_BIN}:${DEFAULT_PATH}" "$UNIT"

echo "== 5. Resulting Environment= lines =="
grep '^Environment=' "$UNIT"

echo "== 6. Reloading systemd daemon =="
systemctl daemon-reload

echo
echo "Done. Service is stopped and GPUs are clean. Next steps:"
echo "  sudo systemctl start vllm-deepseek-v4-flash.service"
echo "  journalctl -u vllm-deepseek-v4-flash.service -f"
