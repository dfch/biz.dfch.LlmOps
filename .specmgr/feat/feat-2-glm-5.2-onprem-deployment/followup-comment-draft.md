# Draft follow-up comment for vllm-project/vllm#52938

Status: **DRAFT ONLY — not posted** (user instruction, 2026-08-19). Same
draft-until-explicitly-approved convention as `bin/upstream-issue-draft.md`.

This is a candidate comment to add to the already-filed issue
https://github.com/vllm-project/vllm/issues/52938, offering a corroborating
(not conclusive) cross-check from a separate, parallel deployment effort
(`feat-2-glm-5.2-onprem-deployment` in this same repo) that ran on the
identical hardware.

---

## Why this might be worth adding

- It's a genuine, independent data point on the *same 4 GPUs* distinguishing
  "SM120 hardware/driver can't do this class of kernel at all" from "this
  specific vLLM/FlashInfer implementation has a bug" — useful triage signal
  either way.
- Low cost, and it's public information that might help someone else
  searching for the same symptom.

## Why it's explicitly hedged, not framed as proof

- Different model (GLM-5.2, not DeepSeek-V4-Flash).
- Different attention implementation entirely: `llama.cpp`'s DSA decode is a
  separate, custom CUDA kernel, not FlashInfer's `fp8_ds_mla` fused layout
  that this issue's decode path uses.
- Different quantization (GGUF, 1-bit `UD-IQ1_S`) vs. this issue's FP8
  setup.
- GLM-5.2's "DSA" and DeepSeek-V4's MLA/sparse-attention are related in
  lineage, not the same algorithm/kernel — so this does not reproduce the
  reported bug, only tests a related kernel class on the same silicon.

---

## Draft comment text

> FWIW, a possibly-useful data point from a **different model/engine on the
> identical GPU class**, offered as corroborating-but-not-conclusive
> evidence, not a reproduction of this exact bug:
>
> On the same hardware class (4x RTX Pro 6000 Blackwell Max-Q, SM120,
> driver 610.57.04, CUDA 13.2), I ran GLM-5.2 (`zai-org/GLM-5.2`, arch
> `glm_moe_dsa` — DeepSeek Sparse Attention, related in lineage to
> DeepSeek-V4's MLA but a distinct kernel/implementation) via `llama.cpp`
> (commit `ee4c505a4`, built with `-DGGML_CUDA=ON`, targeting
> `120a-real`), serving the `unsloth/GLM-5.2-GGUF` `UD-IQ1_S` (1-bit) quant.
>
> At temperature=0, across several prompts (chit-chat, a factual question,
> a code-generation request) with `enable_thinking:false`, each run twice:
> output was coherent, factually correct where applicable (e.g. "Paris"),
> and byte-identical across repeated runs — no sign of the frozen-token/
> identical-logprob-at-every-position signature described here.
>
> This is **not** a reproduction of this issue — different model, different
> quantization (GGUF vs FP8), and critically a completely different
> attention kernel implementation (`llama.cpp`'s own DSA CUDA kernels, not
> FlashInfer's `fp8_ds_mla` fused layout that `FLASHINFER_MLA_SPARSE_DSV4`
> uses here). But since it's a related sparse-attention/DSA-style kernel
> class running correctly on the exact same GPU/driver/CUDA combination,
> it seemed worth flagging in case it helps narrow down whether this is
> SM120-hardware-fundamental vs. specific to this decode path/kernel.
>
> Happy to share more detail (build flags, exact prompts/responses) if
> useful.

---

## Open questions before this would be ready to post

- Confirm CUDA version to cite — this repo's `feat-2` box reports CUDA
  13.2 (`nvcc --version`), double-check that's the version actually
  exercised by the `llama.cpp` CUDA build, not a different toolkit found
  earlier on the path.
- Consider whether to link back to `feat-2`'s repo/README, or keep it
  fully anonymized/standalone (current draft has no links, self-contained).
- Decide whether to also mention the strengthened multi-prompt/determinism
  test (`bin/05-spike-glm-dsa-strong.sh` in `feat-2`) explicitly, or keep
  the comment shorter as drafted.
