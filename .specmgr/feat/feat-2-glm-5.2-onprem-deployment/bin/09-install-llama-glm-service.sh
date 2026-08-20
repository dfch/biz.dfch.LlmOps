#!/usr/bin/env bash
# Task 2.3: install (copy + daemon-reload) the draft
# 08-llama-glm-5.2.service as a systemd --USER unit (installed under
# ~/.config/systemd/user/, NOT /etc/systemd/system/ -- see the feature
# README, Decisions Made 2026-08-20 "user-level systemd for Task 2.3" /
# "lingering + no autostart", and bin/08's own header).
#
# Deliberately does NOT `systemctl --user enable` and does NOT
# `systemctl --user start`:
#   - No `enable`: this box has lingering enabled (see
#     bin/13-enable-user-lingering.sh), and lingering + an ENABLED unit
#     together means the unit auto-starts at every boot (the user
#     manager reaches default.target on its own once lingering is on,
#     which pulls in anything in default.target.wants). We deliberately
#     do NOT want autostart yet -- the unit is left loaded-but-disabled
#     so it can only run when explicitly started. Run `systemctl --user
#     enable llama-glm-5.2.service` yourself later if/when autostart-at-
#     boot becomes the desired behavior; nothing else needs to change.
#   - No `start`: that is Task 2.4, done right after with an immediate
#     curl /health + /v1/chat/completions smoke test, not bundled into
#     "install".
#
# Prerequisite (one-time, separate steps, NOT run by this script):
#   1. bin/12-setup-user-systemd-groups.sh (adds `user` to video/render)
#      -- log out/back in afterward, see that script's header for why.
#   2. bin/13-enable-user-lingering.sh (so the service can keep running
#      after you log out, once started) -- see that script's header.
#
# No sudo required for this script itself -- systemd --user operations
# run entirely as the invoking user. Run manually:
#   bash 09-install-llama-glm-service.sh
set -euo pipefail

UNIT_SRC="$(cd "$(dirname "$0")" && pwd)/08-llama-glm-5.2.service"
UNIT_NAME="llama-glm-5.2.service"
UNIT_DIR="${HOME}/.config/systemd/user"
UNIT_DST="${UNIT_DIR}/${UNIT_NAME}"

if [ ! -f "$UNIT_SRC" ]; then
  echo "ERROR: ${UNIT_SRC} not found" >&2
  exit 1
fi

echo "Installing ${UNIT_NAME} (user service) from ${UNIT_SRC} to ${UNIT_DST}"
mkdir -p "$UNIT_DIR"
cp "$UNIT_SRC" "$UNIT_DST"
systemctl --user daemon-reload

# Defensive: if a previous run of this script (or a manual `enable`)
# already enabled the unit, undo that -- autostart-at-boot must be an
# explicit, separate decision, not a side effect of re-running this
# installer.
if systemctl --user is-enabled "$UNIT_NAME" >/dev/null 2>&1; then
  echo "NOTE: ${UNIT_NAME} was enabled from a previous run -- disabling it"
  echo "      again (autostart-at-boot is an explicit opt-in, not the default)."
  systemctl --user disable "$UNIT_NAME"
fi

echo
echo "Installed as a systemd --user unit: loaded, NOT enabled, NOT started."
echo "  - Will NOT autostart at boot (deliberate -- see this script's header)."
echo "  - WILL keep running after you log out, once started, as long as"
echo "    lingering stays enabled (bin/13-enable-user-lingering.sh)."
echo
echo "Next steps:"
echo "  - Task 2.4: systemctl --user start ${UNIT_NAME}, then curl smoke test"
echo "    against http://<host>:8092/health and /v1/chat/completions"
echo "  - journalctl --user-unit ${UNIT_NAME} -f   -- to follow logs during first load"
echo "    (cold load has historically taken 20-45+ min for this quant/size,"
echo "    see bin/06-measure-kv-cache.sh header -- do not assume a hang)"
echo
echo "Reminder: after a reboot, this unit will NOT come back on its own --"
echo "you must run 'systemctl --user start ${UNIT_NAME}' again manually"
echo "(that start can come from any session, including a fresh SSH login,"
echo "and the service will then persist even if you log out again)."
