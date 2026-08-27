#!/usr/bin/env python3
"""
Task 0.5: pin and download the Phase 2 (REQ-006 GPU-only quantized)
checkpoints for Qwen3.8-Flash-Next into the shared /data/nvidia/hf_cache
(HF_HOME, matching feat-1/feat-2/feat-4's convention) -- the base BF16
checkpoint (~360GB) is deliberately NOT included here; it is only needed
for Phase 3 (hybrid offload) and will get its own pinned download then.

Revisions (pinned fresh 2026-08-27, via direct HF API `sha` lookup, not
"latest"):
  - Qwen/Qwen3.8-Flash-Next-FP8 (official): 970c569adaca6b35532111fd6b27351b2baefe50
    ~185.6GB (144 files, summed via the repo tree API). This is the exact
    checkpoint named in both vLLM's and TokenSpeed's own official
    Qwen3.8-Flash-Next recipes.
  - RadixArk/Qwen3.8-Flash-Next-NVFP4 (community): 7b719225242aacd3dbd3f9407468c2ee9a9d2594

Same deliberate deviation from feat-1's download_flash.py/download_pro.py
pattern that feat-4 already adopted: no `local_dir=` override, so
huggingface_hub's default snapshots/<revision>/-symlinks-into-blobs/
cache layout under HF_HOME is used (resolvable purely by repo_id, no
double-writing weights) -- see feat-4's bin/02-download-weights.py for
the full rationale.

Run with: python3 05-download-weights.py [fp8|nvfp4|all]
  (defaults to "all"; HF_HUB_ENABLE_HF_TRANSFER=1 is set programmatically
  below so the already-installed hf_transfer accelerator is used without
  needing it exported by the caller)
"""

import os
import sys

os.environ.setdefault("HF_HUB_ENABLE_HF_TRANSFER", "1")

from huggingface_hub import snapshot_download  # noqa: E402

TARGETS = {
    "fp8": dict(
        repo_id="Qwen/Qwen3.8-Flash-Next-FP8",
        revision="970c569adaca6b35532111fd6b27351b2baefe50",
    ),
    "nvfp4": dict(
        repo_id="RadixArk/Qwen3.8-Flash-Next-NVFP4",
        revision="7b719225242aacd3dbd3f9407468c2ee9a9d2594",
    ),
}


def download(name: str) -> None:
    spec = TARGETS[name]
    print(f"== Downloading {name}: {spec['repo_id']} @ {spec['revision']} ==")
    print(f"HF_HOME: {os.environ.get('HF_HOME', 'not set')}")
    path = snapshot_download(
        repo_id=spec["repo_id"],
        revision=spec["revision"],
        max_workers=8,
    )
    print(f"== {name} done -> {path} ==")


if __name__ == "__main__":
    which = sys.argv[1] if len(sys.argv) > 1 else "all"
    names = list(TARGETS) if which == "all" else [which]
    for n in names:
        download(n)
    print("All requested downloads complete.")
