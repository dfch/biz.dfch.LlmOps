#!/usr/bin/env bash
# Builds the /data/llama.cpp-dsa checkout (cloned by 01-clone-llama-cpp-dsa.sh)
# with CUDA enabled, for the feat-2 Phase 1 SM120 spike (Task 1.1/1.2).
#
# CUDA toolkit on this box is 13.2 (/usr/local/cuda-13.2, nvcc not on PATH by
# default). llama.cpp's own CMakeLists.txt (ggml/src/ggml-cuda/CMakeLists.txt)
# already auto-appends the "120a-real" architecture (Blackwell) whenever
# CUDAToolkit_VERSION >= 12.8 and CMAKE_CUDA_ARCHITECTURES is left undefined
# on a non-"native"-capable CMake (this box has CMake 3.22, below the 3.24
# floor for native-arch detection) -- so we deliberately do NOT pass
# -DCMAKE_CUDA_ARCHITECTURES ourselves and let it do the right thing for the
# RTX Pro 6000 Blackwell GPUs.
#
# This is a pure CPU/compiler job -- it does not touch the GPUs, so it is
# safe to run while GPUs are fully loaded by feat-1's service and while the
# GGUF download is still in progress.
#
# Only builds the two binaries this feature actually needs (llama-server,
# llama-cli) rather than the full target set, to keep the build shorter.
#
# Run with: bash 02-build-llama-cpp-dsa.sh
# This can take a while (CUDA kernel compilation is slow) -- background it:
#   tmux new -s llama-build
#   bash 02-build-llama-cpp-dsa.sh

set -euo pipefail

SRC=/data/llama.cpp-dsa
BUILD="${SRC}/build"
CUDA_HOME=/usr/local/cuda-13.2

if [ ! -d "${SRC}/.git" ]; then
  echo "ERROR: ${SRC} not found -- run 01-clone-llama-cpp-dsa.sh first." >&2
  exit 1
fi

export PATH="${CUDA_HOME}/bin:${PATH}"
export CUDACXX="${CUDA_HOME}/bin/nvcc"

LOGDIR="$(cd "$(dirname "$0")" && pwd)/logs"
mkdir -p "$LOGDIR"
LOG="${LOGDIR}/$(date -u +%Y-%m-%dT%H%M%SZ)-build-llama-cpp-dsa.log"

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
echo "Done. Binaries at ${BUILD}/bin/llama-server, ${BUILD}/bin/llama-cli"
echo "Log: ${LOG}"
