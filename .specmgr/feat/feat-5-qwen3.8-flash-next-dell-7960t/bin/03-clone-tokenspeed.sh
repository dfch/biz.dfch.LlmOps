#!/usr/bin/env bash
# Task 0.4: clones TokenSpeed (lightseekorg/tokenspeed) at its `main`
# branch into a fully isolated checkout under /data/qwen3.8-flash-next/ --
# `qwen4_exp` support merged there today (2026-08-27, PR #1257), well
# after the last tagged release (v0.1.0), so `main` is the only usable
# ref. Pinned to a specific commit for reproducibility (REQ-008-style),
# not the floating branch head.
#
# This is one of TWO parallel Task 0.3 candidates (user decision,
# 2026-08-27: try both, let Phase 1's empirical smoke test decide) -- see
# 01-clone-llama-cpp-qwen4exp.sh for the other.
#
# Run with: bash 03-clone-tokenspeed.sh
# For a large/slow network, background it, e.g.:
#   tmux new -s tokenspeed-clone
#   bash 03-clone-tokenspeed.sh

set -euo pipefail

REPO_URL=https://github.com/lightseekorg/tokenspeed.git
# Pin to the commit that landed qwen4_exp support (PR #1257), confirmed
# 2026-08-27 -- newer `main` commits are fine to re-sync to deliberately,
# but should not be picked up silently by re-running this script.
PIN_SHA=4cb771487f2a070bc3a39c36b6dc8d959a36a92f
DEST=/data/qwen3.8-flash-next/tokenspeed/src

mkdir -p "$(dirname "$DEST")"

if [ -d "$DEST/.git" ]; then
  echo "== ${DEST} already a git checkout, fetching latest instead of cloning =="
  git -C "$DEST" fetch --progress origin main
else
  echo "== Cloning ${REPO_URL} -> ${DEST} =="
  git clone --progress "$REPO_URL" "$DEST"
fi

echo "== Pinning to ${PIN_SHA} =="
git -C "$DEST" checkout "$PIN_SHA"
git -C "$DEST" log -1 --format="now at: %H %ci %s"

echo
echo "Done. Checkout is at ${DEST}, pinned to ${PIN_SHA}."
echo "Next: 04-run-tokenspeed-container.sh"
