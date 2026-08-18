#!/usr/bin/env bash
# Seventh fix for vllm-deepseek-v4-flash.service: add missing lib64/libcudart.so
# symlinks so FlashInfer's JIT-compiled kernels can link against the pip-
# installed CUDA runtime.
#
# Root cause (confirmed via journalctl on the 19:46:38 attempt, after
# 06-fix-attention-backend-sm120.sh switched to the SM120-capable
# FlashInfer attention backend and got past the earlier tile-scheduler gap):
#   /usr/bin/ld: cannot find -lcudart: No such file or directory
#   (during FlashInfer's JIT build of its `sampling` op, needed for
#   _dummy_sampler_run() during profile_run()).
#
#   FlashInfer's build script (flashinfer/jit/cpp_ext.py) derives
#   `cuda_home` from the resolved `nvcc` path as
#   dirname(dirname(which nvcc)) -- i.e.
#   .venv/lib/python3.12/site-packages/nvidia/cu13 -- then links with
#   `-L$cuda_home/lib64 -lcudart`, assuming the classic NVIDIA-installer
#   CUDA toolkit layout. But the pip-installed nvidia-cuda-runtime wheel
#   places its .so files under nvidia/cu13/lib/ (not lib64/), and only
#   ships the versioned libcudart.so.13 -- no unversioned dev symlink,
#   since that's normally provided by the installer, not the runtime
#   wheel. Both the directory name and the missing symlink caused the
#   link to fail.
#
#   This is a plain venv layout/packaging quirk, not a version issue -- no
#   sudo required, since /data/vllm/.venv is user-owned. Verified
#   interactively: after adding both symlinks, a standalone reproduction
#   of the exact failing `c++ -shared -L.../lib64 -lcudart -lcuda ...`
#   command links successfully.
#
# Run with: bash 07-fix-cudart-symlinks.sh

set -euo pipefail

CU13=/data/vllm/.venv/lib/python3.12/site-packages/nvidia/cu13

echo "== 1. Before =="
ls -la "$CU13" | grep -E "lib|^d"

echo "== 2. Creating lib64 -> lib symlink (idempotent) =="
[ -e "$CU13/lib64" ] || ln -s lib "$CU13/lib64"

echo "== 3. Creating libcudart.so -> libcudart.so.13 symlink (idempotent) =="
[ -e "$CU13/lib/libcudart.so" ] || ln -s libcudart.so.13 "$CU13/lib/libcudart.so"

echo "== 4. After =="
ls -la "$CU13/lib64"
ls -la "$CU13/lib/libcudart.so"

echo
echo "Done -- no service restart needed by this script itself, but the"
echo "running vllm-deepseek-v4-flash.service (if any) should be restarted"
echo "to pick up the new symlinks:"
echo "  sudo systemctl restart vllm-deepseek-v4-flash.service"
echo "  journalctl -u vllm-deepseek-v4-flash.service -f"
