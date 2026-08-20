#!/usr/bin/env bash
# Task 2.3.1: tune vm.swappiness down (target 1, NOT 0) via /etc/sysctl.d/,
# persisted across reboots. Explicitly does NOT disable swap -- swap stays
# enabled as a last-resort safety net for genuine memory-pressure
# emergencies (see feat README, Decisions Made 2026-08-20 "swap policy").
#
# Rationale (full discussion in the README): this box's default
# swappiness (60, a general-purpose default) lets the kernel proactively
# swap out anonymous pages even when there is no real memory pressure --
# wasted cycles for a workload that is deliberately sized to fit its
# 512 GiB RAM pool. Lowering swappiness to 1 stops that proactive
# swapping during normal operation, while still leaving swap itself in
# place as a safety net: a hard OOM-kill of llama-server is worse for
# this box's actual goal (avoiding the recurring ~45min daily cold-load,
# see Task 2.2.1) than a slow-but-survivable swap episode, and the
# gradual swap growth seen during Task 2.1's incidents already served as
# a useful early-warning canary that a hard OOM-kill would not give.
#
# Note: the mmap'd GGUF weight pages (the bulk of this workload's memory
# footprint) are file-backed and cleanly reclaimable regardless of swap --
# they were never actually depending on swap in the first place. If swap
# usage grows again during a real load, that is a sign of *some other*
# anonymous-memory consumer, worth investigating on its own merits, not
# proof that swap needs to be even more aggressive or removed outright.
#
# Idempotent: safe to re-run; does nothing if already at target and
# already persisted.
#
# Requires sudo (interactive password on this box, same as bin/09). Run
# manually:
#   bash 10-tune-vm-swappiness.sh
set -euo pipefail

TARGET_SWAPPINESS=1
SYSCTL_FILE="/etc/sysctl.d/99-glm-swappiness.conf"

CURRENT="$(cat /proc/sys/vm/swappiness)"
echo "Current vm.swappiness: ${CURRENT}"
echo "Target  vm.swappiness: ${TARGET_SWAPPINESS} (persisted via ${SYSCTL_FILE})"
echo

echo "Current swap devices (left untouched -- swap stays ENABLED, only swappiness changes):"
swapon --show || echo "  (swapon --show reported no active swap -- verify this is expected before continuing)"
echo

if [ "$CURRENT" = "$TARGET_SWAPPINESS" ] \
  && [ -f "$SYSCTL_FILE" ] \
  && grep -qx "vm.swappiness *= *${TARGET_SWAPPINESS}" "$SYSCTL_FILE" 2>/dev/null; then
  echo "Already at target and already persisted in ${SYSCTL_FILE} -- nothing to do."
  exit 0
fi

echo "Writing ${SYSCTL_FILE} -- will prompt for sudo password."
printf 'vm.swappiness = %s\n' "$TARGET_SWAPPINESS" | sudo tee "$SYSCTL_FILE" > /dev/null

echo "Applying immediately (sudo sysctl --system) so a reboot is not required to take effect..."
sudo sysctl --system > /dev/null

NEW="$(cat /proc/sys/vm/swappiness)"
echo
echo "vm.swappiness is now: ${NEW}"
if [ "$NEW" != "$TARGET_SWAPPINESS" ]; then
  echo "WARNING: expected ${TARGET_SWAPPINESS}, got ${NEW} -- check for a" >&2
  echo "conflicting /etc/sysctl.d/ file or /etc/sysctl.conf override" >&2
  echo "('sysctl --system' applies files in lexical order; a" >&2
  echo "later-sorting file can win over 99-glm-swappiness.conf)." >&2
  exit 1
fi

echo
echo "Swap remains ENABLED (see swapon --show above) -- this change only"
echo "affects how eagerly the kernel proactively swaps under normal"
echo "conditions, not whether swap exists as an emergency safety net."
echo "Persisted at ${SYSCTL_FILE}; survives reboot."
