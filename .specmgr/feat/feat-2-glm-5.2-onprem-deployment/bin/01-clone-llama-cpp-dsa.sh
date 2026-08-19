#!/usr/bin/env bash
# Clones a fresh, dedicated llama.cpp checkout for the feat-2 GLM-5.2 Phase 1
# SM120 spike (Task 1.1), separate from any other llama.cpp checkout on this
# box (e.g. ~/src/llama.cpp) so nothing there gets touched/rebuilt.
#
# This only clones -- it does not build. A follow-up script handles the
# CUDA/SM120 (-DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=120) build once this
# is done.
#
# Safe to re-run: if DEST already exists, it just fetches/fast-forwards
# instead of re-cloning from scratch.
#
# Run with: bash 01-clone-llama-cpp-dsa.sh
# For a large/slow network, background it like the download, e.g.:
#   tmux new -s llama-clone
#   bash 01-clone-llama-cpp-dsa.sh

set -euo pipefail

REPO_URL=https://github.com/ggml-org/llama.cpp.git
DEST=/data/llama.cpp-dsa

if [ -d "$DEST/.git" ]; then
  echo "== ${DEST} already a git checkout, fetching latest instead of cloning =="
  git -C "$DEST" fetch --progress origin
  git -C "$DEST" log -1 --format="now at: %H %ci %s"
else
  echo "== Cloning ${REPO_URL} -> ${DEST} =="
  git clone --progress "$REPO_URL" "$DEST"
  git -C "$DEST" log -1 --format="cloned: %H %ci %s"
fi

echo
echo "Done. Checkout is at ${DEST}."
