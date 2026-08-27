#!/usr/bin/env bash
# Task 0.4: clones the unslothai/llama.cpp fork branch backing the open,
# unmerged upstream PR ggml-org/llama.cpp#27742 ("model: add
# Qwen3.8-Flash-Next (qwen4exp)"), into a fully isolated checkout under
# /data/qwen3.8-flash-next/ -- independent of feat-2's own llama.cpp-dsa
# checkout at /data/llama.cpp-dsa (different fork, different feature).
#
# This is one of TWO parallel Task 0.3 candidates (user decision,
# 2026-08-27: try both, let Phase 1's empirical smoke test decide) -- see
# 03-clone-tokenspeed.sh for the other.
#
# Pinned to a specific commit (REQ-008-style reproducibility), NOT the
# floating branch head -- the PR was still being updated as of
# 2026-08-27, so pin now and re-sync deliberately, not accidentally.
#
# Run with: bash 01-clone-llama-cpp-qwen4exp.sh
# For a large/slow network, background it, e.g.:
#   tmux new -s llama-qwen4exp-clone
#   bash 01-clone-llama-cpp-qwen4exp.sh

set -euo pipefail

REPO_URL=https://github.com/unslothai/llama.cpp.git
BRANCH=qwen4exp/qwen3.8-flash-next
PIN_SHA=250b61446efc91e3a179c8677956f2667c8fbda0
DEST=/data/qwen3.8-flash-next/llama.cpp-qwen4exp

if [ -d "$DEST/.git" ]; then
  echo "== ${DEST} already a git checkout, fetching latest instead of cloning =="
  git -C "$DEST" fetch --progress origin "$BRANCH"
else
  echo "== Cloning ${REPO_URL} (branch ${BRANCH}) -> ${DEST} =="
  git clone --progress --branch "$BRANCH" --single-branch "$REPO_URL" "$DEST"
fi

echo "== Pinning to ${PIN_SHA} (reproducibility -- this PR was still being updated as of 2026-08-27) =="
git -C "$DEST" checkout "$PIN_SHA"
git -C "$DEST" log -1 --format="now at: %H %ci %s"

echo
echo "Done. Checkout is at ${DEST}, pinned to ${PIN_SHA}."
echo "Upstream PR (unmerged as of 2026-08-27): https://github.com/ggml-org/llama.cpp/pull/27742"
echo "Next: 02-build-llama-cpp-qwen4exp.sh"
