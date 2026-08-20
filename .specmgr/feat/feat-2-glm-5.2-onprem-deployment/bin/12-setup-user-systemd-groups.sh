#!/usr/bin/env bash
# Task 2.3.2: add the `user` account to the `video`/`render` groups, as
# defense-in-depth for GPU device access under a systemd --user service
# (see feat README, Decisions Made 2026-08-20 "user-level systemd for
# Task 2.3").
#
# Why this is needed even though it may not be strictly required today:
# on this box /dev/nvidia* are currently world-writable (`crw-rw-rw-`),
# so a plain user process (including one launched by `systemctl --user`)
# can already open them without any group membership. That is a
# permissive, possibly driver-default or admin-set condition, not
# something this feature should rely on staying true forever (e.g. a
# driver update or a stricter udev rule could tighten those permissions
# back to root:video 0660 at any point). Adding `user` to `video`/`render`
# now is the standard, portable way to guarantee GPU access regardless of
# that detail, and costs nothing while the world-writable permissions
# remain in place.
#
# Idempotent: safe to re-run; does nothing if `user` is already in both
# groups. Does NOT take effect for already-open sessions/processes --
# group membership changes only apply to NEW login sessions, so the user
# must log out and back in (or start a new login shell) afterward for
# `id`/`groups` to reflect it and for `systemctl --user` services
# launched from a fresh session to inherit it.
#
# Requires sudo (interactive password on this box, same as bin/09,
# bin/10). Run manually:
#   bash 12-setup-user-systemd-groups.sh [target-user]
#   # target-user defaults to 'user' if not given -- do NOT rely on
#   # $USER here: if this script itself is invoked via `sudo` (e.g.
#   # `sudo bash 12-setup-user-systemd-groups.sh`), $USER may resolve to
#   # `root` rather than the account that actually needs GPU group
#   # access, silently modifying the wrong account's groups (this bug
#   # was hit live on 2026-08-20 -- see feature README, Decisions Made).
#   # Prefer running as: bash 12-setup-user-systemd-groups.sh user
#   # (the script internally uses `sudo` only for the `usermod` call).
set -euo pipefail

TARGET_USER="${1:-user}"
GROUPS_NEEDED=(video render)

echo "Target user: ${TARGET_USER}"
echo "Groups needed: ${GROUPS_NEEDED[*]}"
echo

MISSING=()
for grp in "${GROUPS_NEEDED[@]}"; do
  if ! getent group "$grp" >/dev/null 2>&1; then
    echo "NOTE: group '${grp}' does not exist on this system -- skipping it"
    continue
  fi
  if id -nG "$TARGET_USER" | tr ' ' '\n' | grep -qx "$grp"; then
    echo "Already a member of '${grp}' -- nothing to do"
  else
    MISSING+=("$grp")
  fi
done

if [ "${#MISSING[@]}" -eq 0 ]; then
  echo
  echo "Nothing to change -- ${TARGET_USER} is already in all required/available groups."
  exit 0
fi

JOIN_MISSING="$(IFS=,; echo "${MISSING[*]}")"
echo
echo "Will add ${TARGET_USER} to: ${JOIN_MISSING} -- will prompt for sudo password."
sudo usermod -a -G "$JOIN_MISSING" "$TARGET_USER"

echo
echo "Done. Verify with: id ${TARGET_USER}"
echo "IMPORTANT: this does NOT take effect for the current session --"
echo "log out and back in (new login shell / new SSH session / tmux"
echo "attach after re-login) before relying on it, then re-check with:"
echo "  groups"
echo "Existing shells/tmux panes will keep showing the OLD group list"
echo "until you start a fresh login session."
