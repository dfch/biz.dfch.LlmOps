#!/usr/bin/env bash
# Dumps Python-level stack traces for the vLLM EngineCore + 4 TP workers,
# to figure out exactly where the process is stuck during startup.
#
# Run with: sudo bash 01-dump-vllm-stacks.sh
#
# If the PIDs below are stale (process restarted since this script was
# written), find current ones first with:
#   systemctl status vllm-deepseek-v4-flash.service --no-pager
# and edit the PIDS= line accordingly.

set -uo pipefail

PY_SPY=/data/vllm/.venv/bin/py-spy

# EngineCore, Worker_TP0, Worker_TP1, Worker_TP2, Worker_TP3 (as of 18:18:18 start)
PIDS="35386 35583 35584 35585 35586"

OUT=/tmp/vllm-stack-dump-$(date +%Y%m%d-%H%M%S).txt

{
  echo "=== $(date) ==="
  echo "=== GPU state ==="
  nvidia-smi --query-gpu=index,temperature.gpu,clocks.current.sm,power.draw,pstate,utilization.gpu,memory.used --format=csv
  echo

  for p in $PIDS; do
    echo "======================= PID $p ======================="
    if [ -d "/proc/$p" ]; then
      "$PY_SPY" dump --pid "$p" 2>&1
    else
      echo "(pid $p no longer exists)"
    fi
    echo
  done
} | tee "$OUT"

echo
echo "Full dump saved to: $OUT"
echo "Please paste the contents back so it can be analyzed."
