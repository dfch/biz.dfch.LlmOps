#!/usr/bin/env python3
"""Build a real ~899,067-token prompt using the model's own tokenizer
(not a synthetic estimate), matching feat-3's Task 4.3 technique."""

import os

os.environ.setdefault("HF_HOME", "/data/nvidia/hf_cache")
os.environ.setdefault("HF_HUB_OFFLINE", "1")
os.environ.setdefault("TRANSFORMERS_OFFLINE", "1")

from transformers import AutoTokenizer

TARGET_TOKENS = 899_067
# BPE re-tokenization after decode() shrinks the count a bit (measured
# ~1.2% on a first pass) -- inflate the initial slice to compensate so the
# FINAL re-encoded prompt lands close to TARGET_TOKENS, not short of it.
INITIAL_SLICE_TOKENS = int(TARGET_TOKENS * 1.02)
tok = AutoTokenizer.from_pretrained(
    "Qwen/Qwen3.8-27B",
    revision="1d4bf0f2ff6012fd82039f2fa52739d0dd7c60c0",
)

paragraph = (
    "The Dell 7960T workstation hosts four RTX PRO 6000 Blackwell Max-Q "
    "GPUs connected only through PCIe Gen5, with no NVLink bridge between "
    "any pair. This document describes a long-context validation exercise "
    "for the Qwen3.8-27B model served through vLLM with a YaRN rope scaling "
    "override targeting a fixed 896K token context window. "
)

# Tokenize the paragraph once, compute repeat count directly (avoids
# O(n^2) re-encoding from scratch on every doubling iteration).
para_ids = tok.encode(paragraph)
repeats = INITIAL_SLICE_TOKENS // len(para_ids) + 2
ids = para_ids * repeats
ids = ids[:INITIAL_SLICE_TOKENS]
final_text = tok.decode(ids)
final_ids = tok.encode(final_text)
final_len = len(final_ids)
# If still short, pad with extra paragraphs and re-trim to just under the
# hard 917,504 cap (leave headroom for at least a few output tokens).
while final_len < TARGET_TOKENS and final_len < 917_000:
    final_text += paragraph
    final_ids = tok.encode(final_text)
    final_len = len(final_ids)
if final_len > 917_000:
    final_ids = final_ids[:917_000]
    final_text = tok.decode(final_ids)
    final_len = len(tok.encode(final_text))

out_path = "/tmp/prompt-896k.txt"
with open(out_path, "w") as f:
    f.write(final_text)

print(f"target tokens: {TARGET_TOKENS}")
print(f"encoded length of trimmed ids: {len(ids)}")
print(f"re-encoded length after decode round-trip: {final_len}")
print(f"written to: {out_path}")
print(f"file size: {os.path.getsize(out_path)} bytes")
