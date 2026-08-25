#!/usr/bin/env python3
"""
Task 0.6: pin and download Qwen/Qwen3.8-27B (BF16) and
unsloth/Qwen3.8-27B-NVFP4 (NVFP4) into the shared /data/nvidia/hf_cache
(HF_HOME, matching feat-1's convention).

Revisions:
  - Qwen/Qwen3.8-27B (BF16): 1d4bf0f2ff6012fd82039f2fa52739d0dd7c60c0
    Pinned fresh at download time (2026-08-25), per REQ-006.
  - unsloth/Qwen3.8-27B-NVFP4: 7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108
    Reused verbatim from feat-3 (already-vetted revision). Re-checked
    2026-08-25: the repo's main branch has since moved to
    9e3d73c76eddb75f795cc24ccfbc5affe41c66bd, but the only commit between
    the two is a README.md-only edit (`Update README.md`, 2026-08-25,
    no weight/config changes per the commit history) -- so the pinned
    revision is still current in every way that matters. The
    tokenizer-truncation fix was independently re-verified against this
    exact pinned revision (tokenizer.json's `truncation` field confirmed
    `null` via a direct HTTP fetch, before this script was ever run).

Deliberate deviation from feat-1's download_flash.py/download_pro.py
pattern: those scripts pass `local_dir=<HF_HOME>/hub/models--org--repo`
directly, which (confirmed by inspecting the resulting
/data/nvidia/hf_cache/hub/models--deepseek-ai--DeepSeek-V4-Flash on this
box) makes huggingface_hub write the weights TWICE -- once as real files
directly under that local_dir, and once more under its own
snapshots/<revision>/ cache layout (270 GB on disk for a checkpoint whose
own weights are ~135 GB) -- because local_dir download mode does not
hardlink into the blob cache the way the default (no local_dir) cache
mode does. Both `feat-1`'s systemd unit (`vllm serve
deepseek-ai/DeepSeek-V4-Flash`) and this feature's launch scripts resolve
models purely by repo_id, relying on the standard
snapshots/<revision>/-symlinks-into-blobs/ cache huggingface_hub builds
under HF_HOME regardless of local_dir. So this script omits local_dir
entirely: `snapshot_download(repo_id=..., revision=...)` with no
local_dir/cache_dir override (falls back to HF_HOME=/data/nvidia/hf_cache,
already exported globally in ~/.bashrc) reproduces the exact same
resolvable-by-repo_id result feat-1 relies on, at roughly half the disk
footprint.

Run with: python3 02-download-weights.py [bf16|nvfp4|all]
  (defaults to "all"; HF_HUB_ENABLE_HF_TRANSFER=1 is set programmatically
  below so the already-installed hf_transfer accelerator is used without
  needing it exported by the caller)
"""

import os
import sys

os.environ.setdefault("HF_HUB_ENABLE_HF_TRANSFER", "1")

from huggingface_hub import snapshot_download  # noqa: E402

TARGETS = {
    "bf16": dict(
        repo_id="Qwen/Qwen3.8-27B",
        revision="1d4bf0f2ff6012fd82039f2fa52739d0dd7c60c0",
    ),
    "nvfp4": dict(
        repo_id="unsloth/Qwen3.8-27B-NVFP4",
        revision="7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108",
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
