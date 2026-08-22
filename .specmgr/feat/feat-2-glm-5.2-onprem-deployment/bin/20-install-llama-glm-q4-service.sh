#!/usr/bin/env bash
# Install (copy + daemon-reload) the draft 19-llama-glm-5.2-q4.service as a
# systemd --USER unit, side-by-side with the already-installed
# llama-glm-5.2.service (Q5 production) -- mirrors
# bin/09-install-llama-glm-service.sh exactly, just for the Q4 unit.
#
# ============================================================================
# REMINDER (see 19-llama-glm-5.2-q4.service's header for the full
# investigation): Q4 and Q5 CANNOT be loaded/running at the same time on
# this box -- their combined weight size (~1029 GB) exceeds the 896 GB
# total pool by ~133 GB. This script only INSTALLS the Q4 unit (loaded,
# not started) so it can be quickly swapped in later
# (`systemctl --user stop llama-glm-5.2 && systemctl --user start
# llama-glm-5.2-q4`) -- it does not start anything, and does not touch
# the already-running Q5 service.
# ============================================================================
#
# Deliberately does NOT `systemctl --user enable` and does NOT
# `systemctl --user start` -- same rationale as bin/09:
#   - No `enable`: lingering is already on for this user (see
#     bin/13-enable-user-lingering.sh); enabling this unit too would let
#     BOTH units autostart at next boot, which would immediately violate
#     the "never run both at once" rule right after a reboot. Leave
#     disabled; `systemctl --user enable` is a conscious, separate choice
#     to make later if wanted.
#   - No `start`: starting this service (even briefly, to smoke-test it)
#     would need Q5 stopped first -- that is a deliberate operational
#     decision for whoever is at the keyboard, not something this
#     installer should do on your behalf.
#
# No sudo required -- systemd --user operations run entirely as the
# invoking user. Run manually:
#   bash 20-install-llama-glm-q4-service.sh
set -euo pipefail

UNIT_SRC="$(cd "$(dirname "$0")" && pwd)/19-llama-glm-5.2-q4.service"
UNIT_NAME="llama-glm-5.2-q4.service"
UNIT_DIR="${HOME}/.config/systemd/user"
UNIT_DST="${UNIT_DIR}/${UNIT_NAME}"

Q5_UNIT_NAME="llama-glm-5.2.service"

if [ ! -f "$UNIT_SRC" ]; then
  echo "ERROR: ${UNIT_SRC} not found" >&2
  exit 1
fi

echo "== Pre-flight: checking Q5 production service state (informational only) =="
if systemctl --user is-active --quiet "$Q5_UNIT_NAME"; then
  echo "NOTE: ${Q5_UNIT_NAME} is currently ACTIVE. That is fine for INSTALLING"
  echo "  this Q4 unit (install does not start anything) -- but remember you"
  echo "  must stop ${Q5_UNIT_NAME} before ever starting ${UNIT_NAME}, the two"
  echo "  cannot run loaded at the same time (see this unit's header)."
else
  echo "${Q5_UNIT_NAME} is not currently active."
fi

echo
echo "Installing ${UNIT_NAME} (user service) from ${UNIT_SRC} to ${UNIT_DST}"
mkdir -p "$UNIT_DIR"
cp "$UNIT_SRC" "$UNIT_DST"
systemctl --user daemon-reload

# Defensive, same as bin/09: undo any previous accidental `enable`.
if systemctl --user is-enabled "$UNIT_NAME" >/dev/null 2>&1; then
  echo "NOTE: ${UNIT_NAME} was enabled from a previous run -- disabling it"
  echo "      again (autostart-at-boot is an explicit opt-in, and enabling"
  echo "      BOTH this unit and ${Q5_UNIT_NAME} would risk both starting"
  echo "      together at next boot -- see this unit's header)."
  systemctl --user disable "$UNIT_NAME"
fi

echo
echo "Installed as a systemd --user unit: loaded, NOT enabled, NOT started."
echo "  - Will NOT autostart at boot (deliberate)."
echo "  - WILL keep running after you log out, once started, as long as"
echo "    lingering stays enabled (bin/13-enable-user-lingering.sh)."
echo
echo "To SWITCH from Q5 to Q4 (never run both at once):"
echo "  systemctl --user stop ${Q5_UNIT_NAME}"
echo "  systemctl --user start ${UNIT_NAME}"
echo "  curl http://localhost:8093/health   # port 8093, not Q5's 8092"
echo
echo "To switch back:"
echo "  systemctl --user stop ${UNIT_NAME}"
echo "  systemctl --user start ${Q5_UNIT_NAME}"
echo "  curl http://localhost:8092/health"
echo
echo "journalctl --user-unit ${UNIT_NAME} -f   -- to follow logs during first load"
echo "(cold load has historically taken 20-45+ min for this quant/size --"
echo " do not assume a hang)"
