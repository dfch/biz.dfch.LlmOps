# DRAFT — upstream vLLM issue (NOT POSTED)

Track B of the Task 1.4 unblock plan (2026-08-19T08:04:27Z session). This is
a **draft only** — do not post it until:

1. Track B's dedup search confirms it does NOT duplicate an existing open
   issue (closest known: vLLM #47528 TP-path, #50720 spec-decode dispatch,
   #50773 fusion passes — this repro is distinct from all three; see
   "Why this is not a duplicate" below).
2. The `<FILL FROM DELL BOX>` placeholders are filled with exact values
   captured by `bin/16-snapshot-baseline.sh` (versions, full ExecStart,
   `nvidia-smi`, the verbatim JSON response).

Post target: https://github.com/vllm-project/vllm/issues (Bug report).
Also worth cross-checking FlashInfer: https://github.com/flashinfer-ai/flashinfer/issues

---

## Title

[Bug]: DeepSeek-V4-Flash on RTX PRO 6000 Blackwell (SM120) emits degenerate output — identical argmax token + identical logprob at every decode position, TP and DP+EP alike (FLASHINFER_MLA_SPARSE_DSV4)

## Your current environment

<details>
<summary>Environment (fill from the Dell 7960T)</summary>

```
# `bin/16-snapshot-baseline.sh` captures all of this. Paste verbatim:

vLLM version:            0.26.0
flashinfer-python:       0.6.14
torch:                   <FILL FROM DELL BOX>
GPU:                     4x NVIDIA RTX PRO 6000 Blackwell Max-Q (96 GB each, 384 GB total)
Compute capability:      12.0 (SM120 / sm_120)
Driver Version:          610.57.04
CUDA Version (nvidia-smi): 13.3
OS:                      Ubuntu 22.04 LTS
Kernel:                  6.8.0-117-generic
nvidia-cuda-* wheels:    <FILL FROM DELL BOX — all on the 13.3.x line>

# Full `python -m vllm.collect_env` output:
<FILL FROM DELL BOX>
```

</details>

## Model

- `deepseek-ai/DeepSeek-V4-Flash`, pinned HF revision
  `60d8d70770c6776ff598c94bb586a859a38244f1` (main, dated 2026-06-22).
- Loaded directly from official HF weights (no GGUF/community requant).
- MoE experts at the model's native FP4+FP8 mixed precision (the
  `--hf-overrides '{"expert_dtype":"fp8"}'` path hits a separate TP-sharding
  bug — `tensor a (32) != tensor b (128)`, i.e. `128 experts / tp_size 4` —
  so we fall back to native mixed, which is what this report is about).

## 🐛 Describe the bug

DeepSeek-V4-Flash loads, captures CUDA graphs, and serves HTTP 200 on
`/v1/chat/completions` with `finish_reason: length`, but the generated text
is **degenerate**, not a crash:

- **temperature=1**: token noise mixing many scripts/languages.
- **temperature=0 (greedy)**: every single decode position returns the exact
  same special token `<|begin▁of▁sentence|>` with the **exact identical
  logprob `-11.769736289978027`**, independent of position or context.

An identical argmax token *and* identical logprob at every position is a
broken-forward-pass signature (context appears to reach the decode step as
zeroed/garbage), not a sampling or tokenizer problem.

### Isolation already done (all reproduce the identical frozen token+logprob)

| Hypothesis | Test | Result |
|---|---|---|
| CUDA-graph capture | `--enforce-eager` | Identical degenerate output — ruled out |
| TP execution path (cf. #47528) | `--data-parallel-size 4 --enable-expert-parallel` instead of `--tensor-parallel-size 4` | Identical degenerate output, byte-for-byte same logprob — ruled out |
| torch.compile fusion passes (cf. #50773) | Confirmed inactive under `--enforce-eager` (startup log: "optimizations ... only active during inductor compilation will be ignored") | Not the cause |
| Stale vLLM/flashinfer | Upgrade to 0.27.1 / 0.6.17 | Hard, unrelated SM120/DeepGEMM **`Unsupported architecture`** in `tf32_hc_prenorm_gemm` (DeepSeek-V4 mHC layers); never reaches serving. Rolled back to 0.26.0/0.6.14, which reproduces the original signature exactly. |

Remaining suspects we could not rule out locally: the
`FLASHINFER_MLA_SPARSE_DSV4` SM120 sparse-MLA **decode** kernel path itself,
and/or missing FP8 KV-cache scaling factors (vLLM logs
"may cause accuracy drop without a proper scaling factor" for
`--kv-cache-dtype fp8`). We are separately testing the latter by dropping
`--kv-cache-dtype fp8`; result will be added here.

Note on attention backend: `FLASHMLA_SPARSE_DSV4` is unusable on SM120 in
this build — its tile-scheduler builder
(`build_tile_scheduler`, `sparse_swa.py`) intentionally returns all-`None`
when `is_device_capability_family(120)`, but the FlashMLA decode path
asserts the metadata is non-`None`. So we are forced onto
`FLASHINFER_MLA_SPARSE_DSV4`, which is where the degenerate output appears.

### Reproduction

ExecStart (systemd), diagnostic shape (`--max-model-len 8192` and
`--enforce-eager` are diagnostic-only; the bug also reproduces at the full
`--max-model-len 370000` without `--enforce-eager`):

```
<FILL FROM DELL BOX — paste the exact ExecStart block from bin/16 output>
```

Request:

```bash
curl -s http://127.0.0.1:8000/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "deepseek-ai/DeepSeek-V4-Flash",
    "messages": [{"role": "user", "content": "Say hello in one short sentence."}],
    "temperature": 0,
    "max_tokens": 10,
    "logprobs": true,
    "top_logprobs": 1
  }'
```

Observed response (temperature=0):

```
<FILL FROM DELL BOX — paste the verbatim JSON; all 10 tokens are
<|begin▁of▁sentence|> at logprob -11.769736289978027>
```

Expected: a coherent one-sentence greeting.

### Why this is not a duplicate

- **#47528** (DeepSeek-V4-Pro garbled under TP, correct under DP+EP): our
  failure is **identical under DP+EP**, so it is not the TP-specific path
  that issue describes.
- **#50720** (FlashInfer SM120 sparse-MLA decode dispatch): reported as
  **spec-decode-specific**; we run no speculative decoding.
- **#50773** (fuse_norm_quant/fuse_act_quant garbling on SM120): those
  fusions are **inactive under `--enforce-eager`** in our repro (confirmed
  via startup log), yet the bug persists.

The distinguishing fingerprint here is the **identical logprob to 15 decimal
places at every position under both TP and DP+EP**, on native FP4+FP8 mixed
experts with `FLASHINFER_MLA_SPARSE_DSV4`, model DeepSeek-V4-Flash, vLLM
0.26.0 / flashinfer-python 0.6.14, SM120.

### Before submitting a new issue

- [ ] Searched open+closed issues for this exact signature (identical-token /
      identical-logprob-every-position, SM120, DeepSeek-V4-Flash,
      `FLASHINFER_MLA_SPARSE_DSV4`) — confirmed novel vs #47528/#50720/#50773.
- [ ] Filled all `<FILL FROM DELL BOX>` placeholders from `bin/16` output.
- [ ] Confirmed with maintainers-facing detail (collect_env, exact repro).
