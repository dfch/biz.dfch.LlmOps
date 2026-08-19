#!/usr/bin/env bash
# Step 2 (fallback), part 2, of the Task 1.4 unblock plan
# (2026-08-19T08:04:27Z session): create a side-by-side systemd unit that
# runs the SAME ExecStart args against the clean venv built by
# bin/18-build-clean-venv.sh, so the contamination hypothesis can be tested
# without disturbing the existing baseline service.
#
# What it does:
#   * Copies /etc/systemd/system/vllm-deepseek-v4-flash.service to
#     /etc/systemd/system/vllm-deepseek-v4-flash-clean.service.
#   * Rewrites the venv path in the copy from /data/vllm/.venv to
#     /data/vllm/.venv-clean (in ExecStart and in the PATH Environment line).
#   * Leaves the original unit and its .venv completely untouched (rollback).
#
# The two services MUST NOT run simultaneously -- they both bind the same
# port and both want all 4 GPUs. This script stops the original before
# enabling the clean one; swap back by stopping the clean unit and starting
# the original.
#
# Decision gate after running the clean unit + temp=0 smoke test:
#   * Coherent output -> the original .venv was contaminated. Promote the
#     clean venv: repoint the real unit at .venv-clean (or rename venvs) and
#     proceed to bin/20.
#   * Still the identical degenerate signature -> environment contamination
#     ruled out; the bug is genuinely in vLLM 0.26.0's SM120 sparse-MLA
#     decode path for this model. Escalate the Track B upstream-issue draft
#     as the primary blocker resolution and reassess with the user.
#
# Run with: sudo bash 19-diag-clean-venv-unit.sh

set -euo pipefail

SRC=/etc/systemd/system/vllm-deepseek-v4-flash.service
DST=/etc/systemd/system/vllm-deepseek-v4-flash-clean.service
OLD_VENV=/data/vllm/.venv
NEW_VENV=/data/vllm/.venv-clean

echo "== 1. Preconditions =="
[ -f "$SRC" ] || { echo "ERROR: source unit $SRC not found" >&2; exit 1; }
[ -d "$NEW_VENV" ] || { echo "ERROR: clean venv $NEW_VENV not found -- run bin/18 first" >&2; exit 1; }

echo "== 2. Stopping the original service (both units share port + GPUs) =="
systemctl stop vllm-deepseek-v4-flash.service || true

echo "== 3. Killing any leftover VLLM:: processes =="
pkill -9 -f 'VLLM::' || true
sleep 2

echo "== 4. GPU memory after cleanup =="
nvidia-smi --query-gpu=index,memory.used,memory.free --format=csv

echo "== 5. Creating the clean-venv unit copy =="
cp "$SRC" "$DST"
# Repoint every occurrence of the old venv path to the clean one (covers
# ExecStart's python path and the PATH= Environment line).
sed -i "s|${OLD_VENV}|${NEW_VENV}|g" "$DST"

echo "== 6. Sanity: paths in the new unit now point at the clean venv =="
grep -n "$NEW_VENV" "$DST" || {
  echo "ERROR: no reference to $NEW_VENV in $DST after rewrite" >&2
  exit 1
}
if grep -q "$OLD_VENV" "$DST"; then
  echo "WARN: $DST still references $OLD_VENV -- inspect manually:" >&2
  grep -n "$OLD_VENV" "$DST" >&2
fi

echo "== 7. Reloading systemd daemon =="
systemctl daemon-reload

echo
echo "Done. Original unit stopped and untouched; clean-venv unit created at:"
echo "  $DST"
echo
echo "Next:"
echo "  sudo systemctl start vllm-deepseek-v4-flash-clean.service"
echo "  journalctl -u vllm-deepseek-v4-flash-clean.service -f"
echo "  # once up, run bin/16-snapshot-baseline.sh against it and diff the"
echo "  # temp=0 response vs the frozen degenerate baseline."
echo
echo "To roll back to the original at any time:"
echo "  sudo systemctl stop vllm-deepseek-v4-flash-clean.service"
echo "  sudo systemctl start vllm-deepseek-v4-flash.service"
