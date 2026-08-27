#!/usr/bin/env bash
# Task 0.4: builds the /data/qwen3.8-flash-next/llama.cpp-qwen4exp checkout
# (cloned by 01-clone-llama-cpp-qwen4exp.sh) with CUDA enabled.
#
# Mirrors feat-2's proven bin/02-build-llama-cpp-dsa.sh approach exactly
# (same box, same CUDA toolkit, same SM120 auto-detection behavior) --
# see that script's comments for the full rationale on why
# -DCMAKE_CUDA_ARCHITECTURES is deliberately left unset.
#
# CUDA toolkit on this box is 13.2 (/usr/local/cuda-13.2, nvcc not on PATH
# by default).
#
# This is a pure CPU/compiler job -- it does not touch the GPUs, so it is
# safe to run regardless of feat-4's production service or GPU1's current
# fault (Task 0.6 finding, 2026-08-27).
#
# Run with: bash 02-build-llama-cpp-qwen4exp.sh
# This can take a while (CUDA kernel compilation is slow) -- background it:
#   tmux new -s llama-qwen4exp-build
#   bash 02-build-llama-cpp-qwen4exp.sh

set -euo pipefail

SRC=/data/qwen3.8-flash-next/llama.cpp-qwen4exp
BUILD="${SRC}/build"
CUDA_HOME=/usr/local/cuda-13.2

if [ ! -d "${SRC}/.git" ]; then
  echo "ERROR: ${SRC} not found -- run 01-clone-llama-cpp-qwen4exp.sh first." >&2
  exit 1
fi

export PATH="${CUDA_HOME}/bin:${PATH}"
export CUDACXX="${CUDA_HOME}/bin/nvcc"

LOGDIR="$(cd "$(dirname "$0")" && pwd)/logs"
mkdir -p "$LOGDIR"
LOG="${LOGDIR}/$(date -u +%Y-%m-%dT%H%M%SZ)-build-llama-cpp-qwen4exp.log"

echo "== nvcc =="
"${CUDACXX}" --version

{
  echo "== 1. Configuring (cmake) =="
  cmake -B "$BUILD" -S "$SRC" \
    -DCMAKE_BUILD_TYPE=Release \
    -DGGML_CUDA=ON

  echo
  echo "== 2. Building llama-server + llama-cli (-j$(nproc)) =="
  cmake --build "$BUILD" --config Release -j"$(nproc)" --target llama-server llama-cli
} 2>&1 | tee "$LOG"

echo
echo "== 3. Verifying the build =="
"${BUILD}/bin/llama-server" --version
echo
echo "-- linked CUDA libs --"
ldd "${BUILD}/bin/llama-server" | grep -i cuda || echo "WARNING: no CUDA libs linked -- GGML_CUDA build failed to take effect"
echo
echo "-- CUDA architectures actually used (from configure log) --"
grep "Using CMAKE_CUDA_ARCHITECTURES" "$LOG" || true
echo
echo "-- confirm qwen4exp architecture is registered in this build --"
"${BUILD}/bin/llama-server" --help 2>&1 | grep -qi "qwen4" && echo "qwen4 mentioned in --help" || echo "NOTE: arch registration isn't a --help flag; verified at load time instead (Task 1.1)."

echo
echo "Done. Binaries at ${BUILD}/bin/llama-server, ${BUILD}/bin/llama-cli"
echo "Log: ${LOG}"
