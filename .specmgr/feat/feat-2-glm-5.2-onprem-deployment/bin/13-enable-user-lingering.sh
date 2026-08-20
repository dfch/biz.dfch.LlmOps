#!/usr/bin/env bash
# Task 2.3.3: enable lingering for `user` (`loginctl enable-linger`), so
# `llama-glm-5.2.service` (a systemd --user unit, see bin/08/bin/09) can
# keep running after `user` logs out -- see feature README, Decisions
# Made 2026-08-20 "lingering + no autostart" for the full rationale.
#
# What lingering does and does NOT do (do not confuse the two):
#   - DOES: keeps `user`'s systemd --user manager instance alive/running
#     even with zero active login sessions (and starts it at boot, ahead
#     of any login), so a service started under it does not get killed
#     the moment the last SSH session/terminal closes.
#   - Does NOT by itself autostart any unit. Autostart-at-boot is a
#     property of the unit being `systemctl --user enable`d (which adds
#     it to default.target.wants); lingering just means default.target
#     gets reached without needing an interactive login first. This
#     feature deliberately installs llama-glm-5.2.service WITHOUT
#     enabling it (see bin/09) specifically so that turning lingering on
#     here does NOT cause autostart-at-boot -- the unit only ever runs
#     when someone explicitly runs `systemctl --user start
#     llama-glm-5.2`.
#
# No sudo needed: `loginctl enable-linger` (no username argument) targets
# the invoking user and is permitted without root on this box (verified
# 2026-08-20 -- ran successfully as a plain user, no polkit prompt).
#
# Idempotent: safe to re-run; does nothing if lingering is already on.
#
# Run manually:
#   bash 13-enable-user-lingering.sh
set -euo pipefail

CURRENT="$(loginctl show-user "${USER:-user}" -p Linger --value 2>/dev/null || echo "unknown")"
echo "Current lingering state for ${USER:-user}: Linger=${CURRENT}"

if [ "$CURRENT" = "yes" ]; then
  echo "Already enabled -- nothing to do."
  exit 0
fi

echo "Enabling lingering..."
loginctl enable-linger

NEW="$(loginctl show-user "${USER:-user}" -p Linger --value)"
echo "Lingering now: Linger=${NEW}"
if [ "$NEW" != "yes" ]; then
  echo "WARNING: lingering does not show as enabled after the call -- check manually with:" >&2
  echo "  loginctl show-user ${USER:-user} -p Linger" >&2
  exit 1
fi

echo
echo "Done. ${USER:-user}'s systemd --user instance will now stay running"
echo "(and start at boot) independent of any login session. This does NOT"
echo "by itself start or autostart llama-glm-5.2.service -- that unit is"
echo "installed disabled on purpose (see bin/09's header); it only runs"
echo "when explicitly started via 'systemctl --user start llama-glm-5.2'."
echo
echo "Sanity check any time: systemctl --user status llama-glm-5.2"
echo "should show 'disabled' until you deliberately choose autostart."
