#!/usr/bin/env bash
# Task 0.4: starts TokenSpeed's official `tokenspeed-runner` dev container
# and installs the three editable packages from the pinned checkout
# (03-clone-tokenspeed.sh), per TokenSpeed's own "Getting Started" guide
# (lightseek.org/tokenspeed/guides/getting-started).
#
# Isolation (REQ-001): named container is dedicated to this feature; the
# shared, read-only HF cache is bind-mounted from /data/nvidia/hf_cache
# (same convention as feat-1/feat-2/feat-4's HF_HOME); no other feature's
# venv/build tree is touched.
#
# Docker is available on this box without sudo (confirmed 2026-08-27).
#
# GPU selection (2026-08-27 finding): explicitly scopes to GPU0/GPU2/GPU3
# via `--gpus '"device=0,2,3"'`, NOT `--gpus all`. GPU1 is currently
# faulted (see README Decisions Made) and `--gpus all` makes the NVIDIA
# Container Toolkit's CDI generator enumerate every device by index
# *before* the container starts, which aborts container creation entirely
# the moment index 1 fails to hand back a valid handle -- even though the
# workload itself never asked for GPU1. Scoping explicitly avoids that
# abort. This does NOT fix the deeper, box-wide CUDA-context-creation
# fault also discovered today (torch.cuda.is_available() still returns
# False inside a container scoped this way) -- that needs the underlying
# GPU1 hardware/driver issue resolved first; this flag only gets a
# container to actually start.
#
# Safe to re-run: if the container already exists, this script just
# (re)starts it and re-runs the installs instead of erroring.
#
# Run with: bash 04-run-tokenspeed-container.sh
# The package installs (esp. tokenspeed-kernel, which compiles Triton/CUDA
# kernels) can take a while -- background it:
#   tmux new -s tokenspeed-build
#   bash 04-run-tokenspeed-container.sh

set -euo pipefail

SRC=/data/qwen3.8-flash-next/tokenspeed/src
HF_CACHE=/data/nvidia/hf_cache
CONTAINER=tokenspeed-qwen4exp
IMAGE=lightseekorg/tokenspeed-runner:latest

if [ ! -d "${SRC}/.git" ]; then
  echo "ERROR: ${SRC} not found -- run 03-clone-tokenspeed.sh first." >&2
  exit 1
fi

LOGDIR="$(cd "$(dirname "$0")" && pwd)/logs"
mkdir -p "$LOGDIR"
LOG="${LOGDIR}/$(date -u +%Y-%m-%dT%H%M%SZ)-build-tokenspeed.log"

echo "== 1. Pull the runner image =="
docker pull "$IMAGE" 2>&1 | tee "$LOG"

if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  echo "== 2. Container ${CONTAINER} already exists -- (re)starting it =="
  docker start "$CONTAINER" >>"$LOG" 2>&1
else
  echo "== 2. Creating container ${CONTAINER} =="
  # FLASHINFER_DISABLE_VERSION_CHECK=1 baked in at container-create time
  # (2026-08-27 follow-up finding): the earlier fix only passed this env
  # var to the one-off `docker exec` that ran the pip installs (step 4
  # below), so it never applied to later `docker exec`/`tokenspeed serve`
  # invocations against the *running* container -- a fresh `docker exec`
  # without it still hit the exact
  # "flashinfer-jit-cache version (0.6.17+cu130) does not match
  # flashinfer version (0.6.16)" RuntimeError at import time, which in
  # turn masked as what looked like a recurrence of the box-wide
  # CUDA-context fault. Setting it via `-e` on `docker run` makes it part
  # of the container's persistent environment for every future
  # `docker exec`, not just this script's own install step.
  docker run -itd \
    --shm-size 32g \
    --gpus '"device=0,2,3"' \
    -e FLASHINFER_DISABLE_VERSION_CHECK=1 \
    -v "${SRC}:/workspace/tokenspeed" \
    -v "${HF_CACHE}:/home/runner/.cache/huggingface:ro" \
    --ipc=host \
    --network=host \
    --pid=host \
    --privileged \
    --name "$CONTAINER" \
    "$IMAGE" \
    /bin/bash 2>&1 | tee -a "$LOG"
fi

echo
echo "== 3. Fix /home/runner/.cache ownership (2026-08-27 finding) ==" | tee -a "$LOG"
# Docker auto-creates a bind mount's target PARENT directory as root when
# it doesn't already exist in the image -- our -v ...:/home/runner/.cache/
# huggingface:ro mount above did exactly that to /home/runner/.cache
# itself (root:root, 755), even though the actual huggingface/ mount
# point underneath is fine. That blocks the `runner` user from creating
# sibling cache dirs there (e.g. FlashInfer's own
# /home/runner/.cache/flashinfer AOT/JIT cache), which previously failed
# the tokenspeed-kernel build with "PermissionError: [Errno 13]
# Permission denied: '/home/runner/.cache/flashinfer'". `runner` has
# passwordless sudo in this image, so fix it every run (idempotent,
# harmless if already correct).
docker exec "$CONTAINER" sudo chown runner:runner /home/runner/.cache 2>&1 | tee -a "$LOG"

echo
echo "== 4. Installing the Python runtime, kernel, and scheduler packages (editable) ==" | tee -a "$LOG"
# FLASHINFER_DISABLE_VERSION_CHECK=1 (2026-08-27 finding, first attempt
# without it failed): the tokenspeed-runner base image ships
# flashinfer-jit-cache==0.6.17+cu130 pre-installed, but
# tokenspeed-kernel/python/requirements/cuda.txt hard-pins
# flashinfer-python==0.6.16 -- FlashInfer's own strict version-match
# check then refuses to import at build time
# ("RuntimeError: flashinfer-jit-cache version (0.6.17+cu130) does not
# match flashinfer version (0.6.16)"). This is a rough edge in an
# hours-old `main` branch (see README Decisions Made), not something to
# silently work around forever -- flagged here, not hidden. The bypass
# is the exact one FlashInfer's own error message documents.
docker exec -e FLASHINFER_DISABLE_VERSION_CHECK=1 "$CONTAINER" bash -lc '
  set -euo pipefail
  cd /workspace/tokenspeed
  export PIP_BREAK_SYSTEM_PACKAGES=1
  echo "-- runtime --"
  pip install -e "./python" --no-build-isolation
  echo "-- kernel (compiles Triton/CUDA kernels -- the slow step) --"
  pip install -e tokenspeed-kernel/python/ --no-build-isolation
  echo "-- scheduler --"
  pip install -e tokenspeed-scheduler/
' 2>&1 | tee -a "$LOG"

echo
echo "== 5. Verify =="
docker exec "$CONTAINER" bash -lc 'tokenspeed env' 2>&1 | tee -a "$LOG"
docker exec "$CONTAINER" bash -lc 'tokenspeed serve --help' 2>&1 | grep -iE "qwen4|ple_embed_dtype|index_share_for_mtp" \
  || echo "NOTE: qwen4_exp isn't a top-level --help flag; arch registration is verified at model-load time instead (Task 1.1)."

echo
echo "Done. Container: ${CONTAINER}"
echo "Log: ${LOG}"
echo "Next: Task 0.5 (pin + download checkpoint), then Task 1.1 inside this container."
