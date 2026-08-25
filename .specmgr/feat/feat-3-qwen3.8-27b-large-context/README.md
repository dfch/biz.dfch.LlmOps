---
created: 2026-08-22
github_issue: 3
id: feat-3-qwen3.8-27b-large-context
status: planning
updated: 2026-08-24
version: 1.0.0
---

# Feature: On-prem Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI

## Plan

### Overview

Deploy `Qwen/Qwen3.8-27B` (dense causal LM + vision encoder, 27B params,
Apache-2.0) on the **new Dell GB10 (DGX Spark clone)** — arm64 DGX-class
box with a GB10 Grace-Blackwell SoC and a single unified
128 GB LPDDR5x CPU+GPU memory pool (exact size confirmed by user
2026-08-22) — behind an OpenAI-compatible API, for use as a
coding model via OpenCode and OpenWebUI, with its context window extended
well past the 262,144-token native limit via the vendor's documented YaRN
`rope_parameters` override. Target is a **768K-token floor** (786,432
tokens = native context x3), pushing toward the model's advertised
1,048,576-token (1M) ceiling if the unified-memory safety margin allows.

Unlike `feat-2`'s GLM-5.2 (744B MoE, forced into a lossy quant to fit that
box), Qwen3.8-27B is small enough at full BF16 precision (~54 GB weights)
to fit the GB10's 128 GB unified pool with meaningful headroom left over
for KV cache — so this feature does not start from a
quality-vs-capacity compromise. That said, the KV cache at 768K–1M tokens
is non-trivial, so the achievable context must be measured, not assumed.
Quantization (e.g. FP8) is not required and stays optional, considered
only if empirical data shows it meaningfully helps context headroom or
throughput without a demonstrated quality cost.

This feature is independent of `feat-1` (DeepSeek-V4) and `feat-2`
(GLM-5.2) — it deploys on a separate box and does not replace either.
Coexistence with the Dell-7960T deployments is not a constraint here
(different machine); a coexistence question does exist in the other
direction (could the 7960T pair run *on this* box in the future?),
recorded as informational in REQ-010.

Qwen3.8-27B is a native vision-language model (image + video
understanding), but this feature scopes that capability OUT: only
text/coding use via OpenCode is targeted and validated here.

### Requirements

- REQ-001: Serve Qwen3.8-27B via an OpenAI-compatible API
  (`/v1/chat/completions`) on the Dell GB10 (1x GB10 Grace-Blackwell,
  128GB unified LPDDR5x memory (shared CPU+GPU), NVIDIA DGX Spark clone)
- REQ-003: The endpoint must support a context length of at least
  **768,000 tokens** (floor). If the unified-memory safety margin
  allows, push higher in measured steps, up to the model's native
  ceiling of 1,048,576 tokens (1M) — do not stop at 768K if there is
  safe headroom to go further
- REQ-004: The endpoint must support tool-calling (required for OpenCode
  agentic use) and correctly expose Qwen3.8's thinking controls:
  `enable_thinking` (on by default), `reasoning_effort`
  (`xhigh`/`medium`/`low`), and `preserve_thinking`
- REQ-005: Run at full BF16 precision by default (the model fits VRAM
  comfortably at this precision). Quantization (e.g. FP8) is acceptable
  ONLY if empirically justified — i.e. it demonstrably improves context
  headroom or throughput without a documented quality regression; it must
  not be adopted purely by default the way `feat-2` had to for GLM-5.2
- REQ-006: Engine = vLLM as the primary/default path — it is the engine
  the vendor's model card documents the YaRN long-context override for,
  and it matches `feat-1`'s default engine. Two additional checks vs
  `feat-1`/`feat-2`, both before committing to the YaRN extension work:
  (a) the GB10 is an arm64 Grace-Blackwell (SM121) target, so the vLLM
  build must be an arm64/GB10-supported one (DGX Spark class support was
  only recent as of 2026) — not assumed, checked in Phase 0; (b) an early
  native-context smoke test (Phase 1) is still done, since neither the
  `qwen3_5` Gated DeltaNet + Gated Attention architecture nor the GB10
  platform has been validated for this model yet — cheap insurance
  before the YaRN work
- REQ-007: Pin `Qwen/Qwen3.8-27B` to a specific Hugging Face revision/
  commit (not "latest") for reproducibility across redeploys. Latest
  `main` commit at feature-creation time: `1d4bf0f` (README-only change;
  weights landed at `72a217a`/initial commit `6714f56`) — to be
  re-confirmed and pinned from the box itself at download time (Task 0.4)
- REQ-008: The endpoint runs unauthenticated (anonymous, no API-key/auth
  layer) — accepted risk, internal network only (same posture as
  `feat-1`/`feat-2`)
- REQ-009: The engine runs as a managed service (systemd unit, `--user`
  - lingering following `feat-2`'s pattern unless a reason emerges to
    deviate) — no ad-hoc foreground processes, including during testing
- REQ-010: Determine Qwen3.8-27B's actual memory footprint (weights + KV
  cache at the target context) within the GB10's unified pool, and record
  how much headroom remains at the chosen production context — i.e.
  whether anything else could be co-located on the same box, or whether
  Qwen3.8-27B effectively owns the pool at the chosen context
- REQ-011: YaRN rope scaling must be configured per the vendor's
  documented `rope_parameters` override (`mrope_interleaved`,
  `mrope_section`, `rope_type: yarn`, `rope_theta`,
  `partial_rotary_factor: 0.25`, `factor`, `original_max_position_embeddings: 262144`), with `factor` computed as
  `target_context / 262144` (e.g. 768K -> 3.0, 1M -> 4.0, matching the
  vendor's own worked example)
- REQ-012: Vision/video (image+video understanding) capability is
  explicitly OUT of scope for testing/validation in this feature — text/
  coding only

### Acceptance Criteria

- [x] ACC-001: Verifies REQ-001/REQ-002 — Qwen3.8-27B running via vLLM on
  the Dell GB10 (DGX Spark clone), reachable via `/v1/chat/completions`,
  deployment confined to the GB10 (Dell 7960T untouched) — DONE, checkbox
  caught up 2026-08-24: has been true and verified since Phase 4
  (Task 4.2/4.3), reconfirmed live throughout Phase 6 — never touched
  simply not checked off until this pass. `qwen3.8-27b-nvfp4-896k.service`
  is the current live proof (`/v1/models`, `/v1/chat/completions` both
  responding); the Dell 7960T (`feat-1`/`feat-2`) was never touched by
  this feature's work.
- [x] ACC-002: Verifies REQ-003 — empirical memory/KV-cache
  measurement confirms the endpoint handles at least a 768K-token prompt
  without OOM, with the measured safety margin recorded against the
  unified pool; if a higher context (896K, 1M) also clears the adopted
  safety-margin policy (>=15% free, or >=10 GiB absolute, whichever is
  greater — reused from `feat-2`, applied to the GB10's unified pool),
  the highest safely-supported context is chosen as the production value
  instead of stopping at 768K — DONE 2026-08-23: **896K chosen as the
  production context** (BF16 weights + FP8 KV cache). Full step-up
  results in Task 2.1/2.2/2.3; 768K passed comfortably (19.8% free), 896K
  passed narrowly (16.1% free, just above the 15% floor), 1M failed
  (12.9% free, below the 15% floor) — step-up correctly stopped at 896K
  per policy.
- [ ] ACC-003: Verifies REQ-004 — tool-call and all three thinking-control
  modes (`enable_thinking: false`, `reasoning_effort: medium`,
  `reasoning_effort: xhigh`) verified via curl smoke test, then via a
  real OpenCode agentic session — CURL LEG DONE 2026-08-23 (Task 4.2):
  tool-calling and all 3 modes verified against the live production
  systemd service (`qwen3.8-27b-vllm.service`, 896K context) — correct
  answers, correctly-scaled reasoning length, clean tool-call. The
  OpenCode agentic session leg was done in Task 5.2 (2026-08-23), but
  ONLY against the (since-superseded) BF16 production service. **Since
  Task 6.2 replaced BF16 with NVFP4 as production (2026-08-24), the
  curl leg was re-verified against the new
  `qwen3.8-27b-nvfp4-896k.service`** (coherent output, clean tool-call,
  all 3 thinking-control modes, correct 17×24=408 answer throughout —
  see Task 6.2's step 6-7 results), **but the OpenCode agentic session
  itself has NOT been re-run against NVFP4** — still open, tracked as a
  follow-up rather than reopening this criterion's curl-verified state.
- [x] ACC-004: Verifies REQ-005 — BF16 is confirmed as the production
  precision, with a one-line rationale recorded; if a quantized variant
  is adopted instead, the empirical justification (headroom/throughput
  data, quality-impact check) is recorded alongside it — DONE
  2026-08-23: BF16 weights confirmed as production precision — the
  896K launch script (`/home/admin/launch-phase2-896k-fp8kv.sh`) sets
  no `--dtype`/`--quantization` flag, the model's `config.json` has no
  `quantization_config`, and the on-disk safetensors total (55.56 GB)
  matches BF16 for a 27B-param dense LM; Phase 2's FP8 change was
  KV-cache dtype only and never touched weights. **SUPERSEDED
  2026-08-24 (Task 6.2 steps 6-7)**: NVFP4 is now the adopted
  production precision instead of BF16 — this is exactly the
  quantized-variant path this criterion anticipated, satisfied with
  its own empirical justification: 2.54x-7.7x decode speedup over BF16
  (Task 6.1) plus a user-judged quality-impact check via their own
  coding-task examples on OpenCode ("NVFP4 quality is fine, adopt it,"
  Task 6.2 step 6) with no reported regression. BF16 remains on disk,
  disabled, as a documented fallback.
- [x] ACC-005: Verifies REQ-006 — vLLM is confirmed as the deployment
  engine, with the version used recorded; if vLLM fails the Phase 1
  native-context smoke test, the fallback engine actually used (SGLang)
  is recorded instead, along with why — DONE 2026-08-23: vLLM 0.27.1
  (aarch64) passed Phase 1 cleanly (Task 1.1–1.3), no SGLang fallback
  needed
- [x] ACC-006: Verifies REQ-007 — deployment config records the exact HF
  revision/commit hash used — DONE, checkbox caught up 2026-08-24: the
  NVFP4 checkpoint's pinned revision
  (`7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108`) is recorded in the README
  (Task 6.2 prep work) and now also baked directly into
  `bin/01-build.sh`'s `MODEL_REVISION` variable, so a fresh install
  reproduces the exact same pinned checkpoint, not "latest".
- [x] ACC-007: Verifies REQ-008 — endpoint reachable without credentials
  from the internal network, confirmed intentional (not an oversight) —
  DONE, checkbox caught up 2026-08-24: true throughout (no auth layer on
  any of this feature's services), and explicitly recorded as an
  accepted-risk decision in Decisions Made (2026-08-22), matching
  `feat-1`/`feat-2`'s posture.
- [x] ACC-008: Verifies REQ-009 — engine installed as a systemd service;
  started/stopped/restarted exclusively via `systemctl`
  (`systemctl --user ...` if following `feat-2`'s pattern) throughout
  testing and production use — DONE, checkbox caught up 2026-08-24: true
  since Task 4.1, and the discipline held throughout every subsequent
  cutover (BF16 → NVFP4 896K → NVFP4 1M candidate → back to NVFP4 896K
  - MTP) — every start/stop went through `systemctl --user`, no ad-hoc
    `nohup` process was ever left running as "production".
- [x] ACC-009: Verifies REQ-010 — a recorded decision on Qwen3.8-27B's
  memory footprint within the GB10's unified pool at the chosen
  production context, backed by measured numbers (not assumed), stating
  the remaining headroom explicitly — DONE, checkbox caught up
  2026-08-24: recorded at every precision/context change (Task 2.3 for
  BF16 896K: 19.28 GiB/16.1% free; Task 6.2 step 4 for NVFP4 896K:
  ~48 GiB/40.1% free; Task 6.3 for NVFP4+MTP 896K, the FINAL production
  config: ~46 GiB/~39% free, KV-cache margin 1.07x). The GB10
  effectively owns its pool at this context regardless of precision —
  no meaningful coexistence headroom for another model.
- [x] ACC-010: Verifies REQ-011 — the exact YaRN `rope_parameters` config
  used for the chosen production context size is recorded in the
  systemd unit/deployment config — DONE, checkbox caught up 2026-08-24:
  the full `--hf-overrides` block (factor 3.5, `mrope_interleaved`,
  `mrope_section`, `rope_theta`, `partial_rotary_factor`,
  `original_max_position_embeddings`) is baked into the production
  launch script (`qwen3.8-27b-nvfp4-896k.sh`), which the systemd unit's
  `ExecStart` runs directly, and is also reproduced verbatim by
  `bin/02-install-service.sh` for fresh installs.
- [ ] ACC-011: User runs the SAME coding-task examples used for `feat-1`/
  `feat-2` (see `feat-1` ACC-010, `feat-2` ACC-009) against this
  endpoint, for a direct three-way quality comparison — STILL OPEN as of
  2026-08-24: Task 5.2 (2026-08-23) executed this exact methodology, but
  ONLY against the since-superseded BF16 production service — the same
  gap already flagged on ACC-003. Production is now NVFP4 (Task 6.2);
  the formal three-way comparison record has not been repeated/
  reconfirmed against it. Not blocking (Task 5.2's BF16-era result is a
  reasonable first pass), but the accurate, fully-closed answer requires
  one more OpenCode session against `qwen3.8:27b-nvfp4-896k`.

### Scope

What is included in this feature:

- A lightweight native-context (256K) correctness smoke test on vLLM/
  GB10 (SM121) BEFORE attempting the YaRN extension (Phase 1) — not a
  full multi-engine spike like `feat-2`'s Phase 1, but still verified
  rather than assumed, since platform (arm64/GB10) AND architecture
  (`qwen3_5`) are both unvalidated for this model
- Configuring and validating YaRN-based context extension per the
  vendor's documented `rope_parameters` override
- Empirical memory/KV-cache measurement at 768K and, if headroom allows,
  at higher context sizes up to 1M
- Phase 0 arm64 setup: OS/driver/CUDA/vLLM-arm64/HF tooling verified on
  the GB10 itself (new box — nothing inherited from `feat-1`/`feat-2`)
- Deployment of Qwen3.8-27B on the Dell GB10 as a systemd service
- Pinning the model to a fixed HF revision
- OpenWebUI and OpenCode configured against the endpoint
- Direct quality comparison against `feat-1`'s DeepSeek-V4 and `feat-2`'s
  GLM-5.2 using the same coding-task examples

What is explicitly out of scope:

- Any modification to the Dell 7960T or its `feat-1`/`feat-2`
  deployments — this feature runs only on the GB10 and does not touch
  the other box
- Acquiring additional hardware beyond the GB10
- Authentication/access-control layer (explicitly accepted as anonymous)
- Fine-tuning or training Qwen3.8-27B (serving only)
- Testing or validating vision-language (image/video) capability (REQ-012)
- Retiring or changing the `feat-1`/`feat-2` deployments — all three
  features coexist (on separate boxes); this feature does not depend on
  either succeeding
- Ollama/llama.cpp/GGUF as the serving path — the vendor's own
  documentation only covers the YaRN long-context extension for vLLM,
  SGLang, and TokenSpeed; Qwen3.8's hybrid Gated DeltaNet + partial-
  rotary/mrope architecture is non-standard enough that an unofficial
  llama.cpp YaRN override is judged too high-risk for this feature's
  goals (see the source chat session that preceded this feature for the
  detailed reasoning)

### Dependencies

- Depends on: the Dell GB10 being physically present and bootable with a
  working NVIDIA driver + CUDA + vLLM arm64 stack (fresh setup — Task
  0.2/0.3, nothing is inherited from `feat-1`/`feat-2`'s x86 box); a vLLM
  release whose arm64 build supports BOTH the GB10 (SM121/Grace-Blackwell)
  AND Qwen3.8-27B's architecture (`qwen3_5` tag, hybrid Gated DeltaNet +
  Gated Attention layout) — both are new as of this feature's creation
  date (2026-08-22), support is NOT assumed, must be checked (Task 0.2);
  HF access/token/download tooling installed on the GB10 (Task 0.3);
  sufficient local disk on the GB10 for weights (~54GB BF16) (Task 0.1)
- Related (not a hard dependency): `feat-1`'s and `feat-2`'s SM120
  sparse-attention-decode findings (`vllm-project/vllm#52938`) — the GB10
  has no SM120 GPUs, so that specific bug likely cannot recur here, but
  the general lesson (smoke-test the new platform before committing to
  extension work) still applies
- Blocks: none

### Design Notes

- **Model facts (verified from HF 2026-08-22)**: `Qwen/Qwen3.8-27B`,
  Apache-2.0, dense causal LM + vision encoder, 27B language-model params
  (28B total on disk, BF16 safetensors). Hybrid layout: 16x (3x (Gated
  DeltaNet -> FFN) -> 1x (Gated Attention -> FFN)), 64 layers total.
  Gated Attention: 24 Q heads / 4 KV heads, head dim 256, but only a
  `partial_rotary_factor` of 0.25 (64 of 256 dims) actually gets RoPE.
  Context: 262,144 native, extensible to 1,048,576 via YaRN per the
  vendor card. Successor generation after Qwen3.6/3.7.

- **Why BF16, not a forced quant (contrast with `feat-2`)**: 27B dense at
  BF16 is ~54GB of weights — inside the GB10's 128GB unified pool before
  accounting for KV cache, unlike GLM-5.2's 744B MoE which could not fit
  on its box at any near-lossless precision without a quant. There is no
  a priori reason to trade quality for capacity here; quantization is
  opportunistic (Task 3.x), not load-bearing. Caveat specific to the
  GB10: weights and KV cache share ONE memory pool with the CPU (no
  separate system-RAM fallback like the 7960T's 512GB), so the ceiling on
  achievable context is set by the free fraction of that single 128GB
  pool — measure it (Phase 2), don't model it.

- **YaRN factor table** (native = 262,144; vendor's own worked example:
  524,288 -> factor 2.0):

  | target context | factor |
  |---|---|
  | 524,288 (512K) | 2.0 |
  | 786,432 (768K) | 3.0 |
  | 917,504 (896K) | 3.5 |
  | 1,048,576 (1M, native ceiling) | 4.0 |

  Full override block (vendor-documented):
  `{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": <see table>, "original_max_position_embeddings": 262144}}}`
  passed via `--hf-overrides` (vLLM, needs
  `VLLM_ALLOW_LONG_MAX_MODEL_LEN=1`) or the equivalent SGLang
  `--json-model-override-args`.

- **Static YaRN caveat (from the vendor card, carried over verbatim)**:
  all current open-source frameworks implement static YaRN — the scaling
  factor is fixed regardless of actual input length, which can hurt
  short-prompt performance once a large factor is set. Only worth setting
  if 768K+ is the genuinely typical working context for this deployment,
  not just a ceiling to have available.

- **FP8 KV cache (not weight quantization) was required to get real OS
  headroom at 768K+ on the GB10's unified pool** (found in Task 2.1):
  `--gpu-memory-utilization` sizes vLLM's TOTAL memory footprint as a
  fixed fraction of the pool regardless of how much KV-cache token
  capacity that buys. On a discrete-VRAM box (`feat-1`/`feat-2`) that
  just trades away request concurrency; on the GB10's single unified
  pool it silently starves the OS itself (measured: only ~1.7-3.5 GiB
  system-wide free at 768K/BF16-KV/util=0.92, vs. a ~17.9 GiB policy
  floor). The fix is `--kv-cache-dtype fp8` (KV cache precision only —
  model weights stay BF16, REQ-005 untouched) combined with an EXPLICIT
  `--kv-cache-memory-bytes` sized just above what the target context
  needs (not the full `gpu_memory_utilization` budget) — this frees the
  difference as genuine, measured OS headroom. This is now a required
  flag pair for every Phase 2+/Phase 4 launch on this box, not optional.

- **Coexistence is a different shape of question here than on the 7960T**:
  `feat-1`/`feat-2` run on the Dell 7960T, a different box — so the
  question is no longer "can Qwen3.8-27B share GPUs with them" (trivially
  no, it's not on that box). The relevant questions are: (a) at the chosen
  production context, how much of the GB10's unified pool is free (Task
  2.3/REQ-010)? (b) does the endpoint even clear the 768K floor given
  weights + KV cache all live in that one 128GB pool? Both are measured,
  not assumed. Note the box already runs an Ollama stack (including a
  llama-server with a live 256K context holding ~4 GB of the pool as of
  2026-08-22) and OpenWebUI — their memory state must be included in
  Phase 2 measurements, and the running Ollama model should be stopped
  before the capacity tests to get a clean baseline.

- **NO environment inheritance from `feat-1`/`feat-2`.** The GB10 is a
  new, arm64 box: driver, CUDA, vLLM (the correct arm64/GB10-compatible
  build), and HF tooling all need to be verified/installed on it (Phase 0
  is real setup work, not confirmation of an inherited state). The only
  things inherited are practice (systemd `--user`-lingering pattern,
  HF-pin discipline, no-auth internal posture) and this repo.

- **Same non-negotiables as `feat-1`/`feat-2`**: pinned HF revision
  (REQ-007), anonymous internal-only endpoint (REQ-008), systemd-only
  operation (REQ-009).

- **Comparison is the point.** ACC-011 reuses the exact `feat-1`/`feat-2`
  coding-task examples so Qwen3.8-27B's quality (and its much larger
  context ceiling) can be judged head-to-head against DeepSeek-V4 and
  GLM-5.2 on the user's real workloads.

- **Why Ollama/llama.cpp was ruled out for this feature** (from the
  chat session preceding this feature's creation): the vendor card only
  documents the YaRN extension for vLLM/SGLang/TokenSpeed. GGUF/Ollama
  quantizations do exist for this model, but Qwen3.8-27B's hybrid
  Gated DeltaNet linear-attention blocks plus its unusual
  `partial_rotary_factor`/`mrope_section` rotary setup make it materially
  more likely that llama.cpp's independent YaRN implementation would
  silently diverge from the vendor-validated behavior, versus a standard
  dense-attention model. This can be revisited later as a separate
  feature if a specific need for an Ollama-served path emerges.

### Related ADRs

- None (infrastructure/deployment work, tracked in this repo using the
  feature-folder convention, same as `feat-1`/`feat-2`)

### Task List

#### Phase 0: Environment prep (new box — real setup, not confirmation)

- [x] Task 0.1: Confirm disk headroom on the GB10 is sufficient for
  Qwen3.8-27B weights (~54GB BF16) plus tooling/swap — depends on:
  none — status: done 2026-08-22 — 1.9 TB NVMe, 152 GB free at check
  time (92% used, mostly prior model stores under `/data`); 54 GB
  download fits with ~100 GB to spare, no cleanup required
- [x] Task 0.2: Verify the GB10's NVIDIA driver + CUDA are installed and
  working, AND confirm an arm64 vLLM build supports Qwen3.8-27B's
  architecture (`qwen3_5` tag, hybrid Gated DeltaNet + Gated Attention) —
  depends on: none — status: done 2026-08-22 — driver 580.173.02 +
  CUDA 13.0.88 present and working (nvidia-smi sees the GB10); vLLM
  0.27.1 (aarch64, venv `/home/admin/venvs/vllm`) registers
  `Qwen3_5ForConditionalGeneration`/`Qwen3_5ForCausalLM` in its
  ModelRegistry and implements `mrope_interleaved` — both the platform
  and architecture checks pass
- [x] Task 0.3: Install/verify HF CLI + token + `hf_transfer` on the GB10 —
  depends on: none — status: done 2026-08-22 — no system-wide HF CLI,
  but the `admin` HF token is present and working; downloads run via the
  `hf` CLI from the vLLM venv (`/home/admin/venvs/vllm/bin/hf`,
  hf_transfer enabled). NOTE: `/data` is root-owned and not writable by
  `admin`, so weights go under `/home/admin/models/`
- [x] Task 0.4: Choose and record the pinned HF revision/commit for
  `Qwen/Qwen3.8-27B` — depends on: Task 0.3 — status: done 2026-08-22 —
  pinned to full commit hash `1d4bf0f2ff6012fd82039f2fa52739d0dd7c60c0`
  (matches the `1d4bf0f` short hash recorded at feature-creation; model
  is not gated, last modified 2026-08-14, architecture tag `qwen3_5`) —
  download COMPLETE, 55.6 GB (18 safetensors shards + configs) at
  `/home/admin/models/qwen3.8-27b`

#### Phase 1: Baseline correctness smoke test (native context, before YaRN)

- [x] Task 1.1: Bring up Qwen3.8-27B on vLLM at native context (262,144 or
  smaller for a quick check) on the GB10, no YaRN override yet —
  depends on: Task 0.2, Task 0.4 — status: done 2026-08-23 — brought up
  at `--max-model-len 32768` on port 8000 (Ollama's prior 65 GB
  reservation was already clear — `free -h` showed ~114 GiB available,
  `nvidia-smi` showed 0 processes, before starting). Two NEW Phase-0-
  class environment gaps surfaced and were fixed, both without sudo/
  root:
  1. **Missing `Python.h`**: Triton's JIT step (used to inspect the
     `Qwen3_5ForConditionalGeneration` architecture) shells out to
     `gcc`, which failed with `fatal error: Python.h: No such file or directory` — `python3.12-dev` is not installed system-wide and
     apt requires sudo (not available non-interactively). Fixed with
     `uv python install 3.12` (downloads a standalone CPython 3.12.13
     build with headers under
     `~/.local/share/uv/python/cpython-3.12.13-linux-aarch64-gnu/`,
     no sudo) plus `export CPATH=.../include/python3.12` so `gcc`
     finds it. Same 3.12 minor version as the venv's interpreter
     (3.12.3), so no Python C-API ABI risk.
  2. **`ninja` unreachable**: `torch.compile`/inductor shells out to a
     bare `ninja` on `$PATH`; it IS installed inside the venv
     (`/home/admin/venvs/vllm/bin/ninja`, pulled in as a pip dependency)
     but the venv's `bin/` was not on `PATH` for a plain `nohup vllm serve ...` invocation, causing `FileNotFoundError: [Errno 2] No such file or directory: 'ninja'` deep in engine-core init. Fixed
     with `export PATH=/home/admin/venvs/vllm/bin:$PATH` before
     launching.
     Final working launch command (both fixes applied):
     `CPATH=/home/admin/.local/share/uv/python/cpython-3.12.13-linux-aarch64-gnu/include/python3.12 PATH=/home/admin/venvs/vllm/bin:$PATH /home/admin/venvs/vllm/bin/vllm serve /home/admin/models/qwen3.8-27b --port 8000 --trust-remote-code --no-enable-prefix-caching --max-model-len 32768 --enable-auto-tool-choice --tool-call-parser qwen3_xml --reasoning-parser qwen3` (tool/
     reasoning parser choice explained in Task 1.2). Startup took ~9 min
     total (weight load ~5m47s of 51.75 GiB checkpoint off local NVMe +
     torch.compile/CUDA-graph capture ~3m); no OOM; `gpu_worker.py`
     reported 51.7 GiB available for KV cache at this (deliberately small)
     32768 max-model-len — real capacity measurement is Phase 2's job, not
     this one. Server shut down cleanly after Task 1.2/1.3 (no leftover
     process, GPU back to 0 processes / ~114 GiB free) so Phase 2 starts
     from a clean baseline.
- [x] Task 1.2: Temperature=0 smoke test — verify coherent, non-degenerate
  output (explicitly check against the `feat-1`/`feat-2` degenerate
  signature: a single frozen token repeated at every decode position),
  and verify tool-calling + `enable_thinking`/`reasoning_effort` work at
  native context — depends on: Task 1.1 — status: done 2026-08-23 —
  ALL checks pass:
  - **Non-degenerate output**: a plain coding prompt (fib w/ memoization)
    produced coherent, varied text (not the `feat-1`/`feat-2` single-
    frozen-token signature). Generation throughput measured at only
    ~4.6 tokens/s in this initial run (unquantized BF16, no batching,
    32768 max-model-len) — noted as a throughput observation for later
    phases, not a correctness blocker.
  - **Tool-calling**: required explicit `--enable-auto-tool-choice --tool-call-parser <name>` (off by default; first attempt without it
    correctly errored rather than silently ignoring `tool_choice: "auto"`). Parser choice `qwen3_xml` was picked by inspecting the
    model's own `chat_template.jinja`, which emits tool calls as
    `<tool_call><function=NAME><parameter=...>...</parameter></function></tool_call>`
    — vLLM's registered `qwen3_engine_tool_parser` (aliased as both
    `qwen3_coder` and `qwen3_xml`) matches this format; `qwen3_xml` was
    used as the non-coder-specific name. A `get_weather("Paris")`
    tool-call test returned a clean, correctly-typed
    `tool_calls[0].function.arguments = {"location": "Paris"}` with
    `finish_reason: "tool_calls"` and `content: null`.
  - **Thinking controls**: also required an explicit `--reasoning-parser qwen3` (found via `vllm.reasoning.__init__` registry) to split
    `<think>`-style reasoning out of `content` into the OpenAI-style
    `message.reasoning` field — without it, reasoning text and the
    final answer are concatenated in `content` with `reasoning: null`.
    With the parser enabled, verified per ACC-003's exact 3 modes on a
    17\*24 arithmetic prompt (correct answer=408 in every case):
    `enable_thinking: false` -> no reasoning field populated, direct
    tool-call/answer; `reasoning_effort: low/medium/xhigh` (all with
    `enable_thinking: true`) -> each produced a populated `reasoning`
    field with a correctly-scaled amount of visible reasoning text and
    a correct final answer in `content`.
- [x] Task 1.3: Record the outcome. If vLLM produces degenerate output
  (unexpected given the different kernel class, but not impossible),
  fall back to spiking SGLang next, mirroring `feat-2`'s Phase 1
  approach — depends on: Task 1.2 — status: done 2026-08-23 — **vLLM
  passes cleanly, no SGLang fallback needed.** REQ-006/ACC-005 resolved:
  vLLM 0.27.1 (aarch64) is confirmed as the deployment engine for this
  feature. The `qwen3_5` Gated DeltaNet + Gated Attention architecture
  and the GB10 (SM121) platform are both validated at native context.
  Carry-forward flags for Phase 2/4 deployment configs: always launch
  with `CPATH`/`PATH` set as in Task 1.1, plus
  `--enable-auto-tool-choice --tool-call-parser qwen3_xml --reasoning-parser qwen3`.

#### Phase 2: Context extension + capacity measurement

- [x] Task 2.1: Apply the YaRN `rope_parameters` override (see Design
  Notes table) targeting 768K context; measure unified-pool memory +
  KV-cache usage and free headroom at that context size — depends on:
  Task 1.3 — status: done 2026-08-23 — two sub-attempts, the first of
  which surfaced a real problem before the second succeeded:

  1. **First attempt (default `--gpu-memory-utilization 0.92`, BF16 KV
     cache)**: hit a NEW environment gap — the default
     `VLLM_ENGINE_READY_TIMEOUT_S=600` was too short for this box (weight
     load alone took ~5.7 min because "Auto-prefetch is disabled" — the
     51.75 GiB checkpoint exceeds available page-cacheable RAM on EXT4 —
     plus KV-cache profiling/compile on a 786,432 max-model-len engine),
     so the engine core was killed as a false-timeout before finishing.
     Fixed with `VLLM_ENGINE_READY_TIMEOUT_S=3600`; carry this forward to
     every Phase 2+ launch (native-context Task 1.1 never needed it
     because its 32768 max-model-len profiled fast enough to clear the
     600s default).
  2. **Re-run with the fix**: server started cleanly and a REAL
     768,567-token prompt (built by encoding/trimming with the model's
     own tokenizer, not a synthetic token-count estimate) was POSTed to
     `/v1/chat/completions` end-to-end — HTTP 200, no OOM, ~36 min wall
     time (2166s) for the full prefill+decode. So the raw 768K capability
     bar is cleared. BUT the memory accounting exposed a real problem:
     KV cache capacity was only 820,013 tokens against the 786,432
     needed (1.04x margin — barely fits one full-length request), and
     system-wide `free -h` "available" during serving was only
     **~1.7-3.5 GiB** out of 119.63 GiB total — nowhere near the adopted
     safety-margin policy (needs at least 15% of 119.63 GiB, i.e. ~17.9
     GiB, or at least 10 GiB, whichever is greater). Root cause:
     `--gpu-memory-utilization 0.92` fixes vLLM's TOTAL footprint budget
     (weights 55.99 GiB + activation 3.78 GiB + CUDA graph 0.94 GiB + KV
     cache 50.29 GiB = ~111.0 GiB of the 119.63 GiB pool) regardless of
     how much KV-cache *capacity* that buys — on a discrete-VRAM box
     this just means "less concurrency headroom"; on the GB10's unified
     pool it means "the OS itself is left with almost nothing," a
     materially different risk.
  3. **Fix: `--kv-cache-dtype fp8` + explicit `--kv-cache-memory-bytes`**
     (KV cache precision only — model weights stay BF16, REQ-005
     unaffected). FP8 KV cache roughly halves bytes/token (~65.8 KB/token
     BF16 -> ~33.0 KB/token FP8, measured empirically, not just the
     nominal 2x), so the same 786,432-token requirement can be met with
     a much smaller, explicitly-sized KV-cache reservation instead of
     vLLM automatically consuming the full `gpu_memory_utilization`
     budget. Re-ran with `--kv-cache-dtype fp8 --kv-cache-memory-bytes 32212254720` (30 GiB, sized for ~1.24x margin over 786,432 tokens):
     KV cache capacity **974,864 tokens** (1.24x margin, up from 1.04x),
     system `free -h` available **23.73 GiB (19.8% of the 119.63 GiB
     pool)** — clears the safety-margin policy with real room to spare.
     Re-ran the SAME real 768,567-token prompt end-to-end: HTTP 200, no
     OOM, ~45 min wall time (2693s) — slower than the BF16 KV-cache run
     (likely FP8 dequant overhead on this platform's FlashInfer path,
     not yet tuned for GB10; flagged as a throughput observation, not a
     blocker, same bucket as Task 1.2's low-throughput note). **Adopted
     for production: FP8 KV cache + explicit `--kv-cache-memory-bytes`,
     NOT the default `--gpu-memory-utilization`-driven auto-sizing, is
     required on this box to get real OS headroom at 768K+.**

- [x] Task 2.2: If Task 2.1's margin clears the adopted safety-margin
  policy (>=15% free of the unified pool, or >=10 GiB absolute, whichever
  is greater) with room to spare, step upward (896K, then 1M) and
  re-measure at each step until the policy is no longer cleared — choose
  the highest context size that still clears it as the production target
  (may be 768K, may be higher) — depends on: Task 2.1 —
  status: done 2026-08-23 — stepped up using the same FP8-KV-cache
  approach (load-time capacity/headroom measurement at each step, per
  the plan's Task 4.3 being the place reserved for a full real-prompt
  end-to-end check at the FINAL chosen production context; 768K already
  got a real-prompt check in Task 2.1):

  | Context | Factor | `--kv-cache-memory-bytes` | KV cache capacity | Concurrency margin | Free memory | % free | Policy (>=15% or >=10 GiB) |
  |---|---|---|---|---|---|---|---|
  | 768K (786,432) | 3.0 | 30 GiB | 974,864 tokens | 1.24x | 23.73 GiB | 19.8% | **PASS** |
  | 896K (917,504) | 3.5 | 33 GiB | 1,073,277 tokens | 1.17x | 19.28 GiB | 16.1% | **PASS (thin — only ~1.1pp above the 15% floor)** |
  | 1M (1,048,576) | 4.0 | 37.11 GiB | 1,209,295 tokens | 1.15x | 15.39 GiB | 12.9% | **FAIL** (below the 15% floor, despite being above the 10 GiB absolute floor — the policy takes the greater/stricter of the two) |

  Step-up correctly stopped at 1M per the policy. **896K is the highest
  context that clears the policy and is the chosen production context**
  — clearly ahead of the 768K floor from REQ-003, but not the full 1M
  ceiling. **896K reconfirmed as final 2026-08-24**: even though NVFP4
  (adopted as production precision in Task 6.2, see ACC-004) also
  clears the full 1M ceiling with room to spare (36.2% free), the user
  explicitly chose to stay at 896K after testing — "the ctx is large
  enough with that size" — so 896K, not 1M, is the actual deployed
  production context regardless of precision. All three sizes loaded
  and served `/v1/models` successfully
  (200 OK) with no OOM at load time; only 768K got the full real-prompt
  end-to-end POST (Task 2.1) — 896K's real-prompt end-to-end validation
  is carried forward as Task 4.3 against the finalized systemd
  deployment, per the original plan.

- [x] Task 2.3: Record the remaining free headroom of the GB10's unified
  pool at the chosen production context, i.e. answer REQ-010's "what
  else could share this box, or is the pool effectively consumed"
  question with real measured numbers — depends on: Task 2.2 —
  status: done 2026-08-23 — at the chosen production context (896K,
  factor 3.5, FP8 KV cache, `--kv-cache-memory-bytes` 33 GiB): **19.28
  GiB (16.1%) of the GB10's 119.63 GiB unified pool remains free**,
  measured via `free -h`/`free -b` while the server was actively serving.
  This clears the adopted safety-margin policy but only just (the 15%
  floor is ~17.9 GiB; this is ~1.3 GiB above it) — answer to REQ-010:
  **the GB10 effectively owns the pool at 896K**; ~19 GiB is not enough
  to co-locate another meaningful model or service (e.g. the prior
  Ollama stack alone reserved ~65 GiB per the 2026-08-22 note), though it
  is enough headroom for the OS/desktop/monitoring tools to keep
  operating without instability. If more coexistence headroom is ever
  needed, the 768K step (23.73 GiB / 19.8% free) is the more
  conservative fallback, still comfortably above the 768K floor from
  REQ-003.

#### Phase 3: Precision decision

- [x] Task 3.1: Confirm BF16 as the production precision by default
  (expected outcome given Design Notes) — depends on: Task 2.3 —
  status: done 2026-08-23 — confirmed via live shell on the GB10 (no
  new serving run needed): the 896K launch script
  (`/home/admin/launch-phase2-896k-fp8kv.sh`) passes no
  `--dtype`/`--quantization` flag (only `--kv-cache-dtype fp8`, a
  KV-cache-only setting), `config.json` has no `quantization_config`,
  and the checkpoint's total safetensors size (55.56 GB) matches BF16
  for ~27B params. REQ-005/ACC-004 closed: BF16 is the production
  weight precision, unaffected by Phase 2's KV-cache FP8 decision.
- [ ] Task 3.2: (Optional, only if Task 2.2/2.3 data suggests a benefit)
  Evaluate an FP8 (or similar) variant for throughput or additional
  context/coexistence headroom, with an explicit quality-impact check
  before adopting it over BF16 — depends on: Task 3.1 — status: not-started

#### Phase 4: Full deployment

- [x] Task 4.1: Install vLLM + Qwen3.8-27B as a systemd service (`--user`
  - lingering, following `feat-2`'s pattern unless GB10-specific needs
    dictate a system-wide unit instead) with the chosen production context,
    YaRN config, and precision on the GB10 — depends on: Task 3.1 —
    status: done 2026-08-23 — followed `feat-2`'s pattern exactly
    (systemd `--user` unit + lingering, unit deliberately left disabled
    so it does NOT autostart at boot):
    1. Created `/home/admin/scripts/qwen3.8-27b-vllm-896k.sh`, a
       production copy of the already-tested Phase 2 script
       (`/home/admin/launch-phase2-896k-fp8kv.sh`) — flags byte-for-byte
       identical (only header comments added): 896K/917,504
       `--max-model-len`, YaRN factor 3.5 `--hf-overrides`, BF16 weights
       (no `--dtype`/`--quantization`, per Task 3.1), `--kv-cache-dtype fp8 --kv-cache-memory-bytes 35433480192`, `CPATH`/`PATH` fixes
       (Task 1.1), `VLLM_ENGINE_READY_TIMEOUT_S=3600` (Task 2.1),
       `--enable-auto-tool-choice --tool-call-parser qwen3_xml --reasoning-parser qwen3` (Task 1.3).
    2. Created `/home/admin/.config/systemd/user/qwen3.8-27b-vllm.service`
       (`Type=simple`, `ExecStart=` the script above, `Restart=on-failure`,
       `TimeoutStartSec=4200` — longer than the script's own 3600s
       engine-ready timeout so systemd never kills it mid-startup,
       `LimitNOFILE=1048576`).
    3. Enabled lingering: `loginctl enable-linger admin` succeeded
       without sudo/a password prompt (`Linger=yes` confirmed) — lets
       the service survive logout without autostarting at boot, same
       as `feat-2`'s "lingering + NOT enabled" combination.
    4. Installed: `systemctl --user daemon-reload`; confirmed via
       `systemctl --user status`: `Loaded: loaded (...; disabled; preset: enabled)`, `Active: inactive (dead)` — exactly the
       intended state, ready for an explicit start (Task 4.2).
    5. Skipped (not required here): `feat-2`'s Task 2.3.2 video/render
       group defense-in-depth — `/dev/nvidia*` on the GB10 are already
       world-writable (`crw-rw-rw-`), same underlying condition as
       `feat-2`'s box, and non-interactive `sudo` is unavailable on
       this box anyway (consistent with every other Phase 0-3 fix on
       this feature being sudo-free).
       GB10 confirmed clean afterward: port 8000 free, 0 GPU compute
       processes, ~100 GiB free/114 GiB available.
- [x] Task 4.2: Start the service; curl smoke test against
  `/v1/chat/completions` at the production context size — verify
  tool-calls and all thinking-control modes — depends on: Task 4.1 —
  status: done 2026-08-23 — `systemctl --user start qwen3.8-27b-vllm.service` issued; cold load completed in ~7m43s
  (18:02:58 → 18:10:41 UTC, `Application startup complete`), matching
  Phase 2's timing. Confirmed via `systemctl --user status`
  (`active (running)`), `/health` (200 OK), and `/v1/models`
  (`max_model_len: 917504`, i.e. the 896K production context). Ran the
  same smoke-test shape as Task 1.2, this time against the actual
  production systemd service rather than an ad-hoc launch — **all
  checks passed**:
  - **Coherent output** (temperature=0, fib-with-memoization prompt):
    correct, non-degenerate Python code — not the `feat-1`/`feat-2`
    frozen-token signature.
  - **Tool-calling**: `get_weather("Paris")` returned a clean
    `tool_calls[0].function.arguments = {"location": "Paris"}` with
    `finish_reason: "tool_calls"`, `content: null`.
  - **ACC-003's exact 3 thinking-control modes** (17×24 arithmetic,
    correct answer=408 every time): `enable_thinking: false` →
    `reasoning: null`, direct `content: "408"`; `reasoning_effort: medium` → 44-char reasoning, correct answer; `reasoning_effort: xhigh` → 161-char reasoning (visibly more elaborate than medium,
    correctly scaled), correct answer.
    Post-test health check: service still `active (running)`, no
    errors/warnings in the journal, `free -h` showed ~19 GiB
    available/1.6 GiB free — consistent with Task 2.3's measured 896K
    headroom (19.28 GiB). **Service left running** (not stopped) so
    Task 4.3 can reuse it for the real filled-context request. ACC-003's
    curl portion is satisfied; its "real OpenCode agentic session" leg
    remains for Phase 5.
- [x] Task 4.3: Validate the finalized production context size end-to-end
  (a real filled-context request, not just a load-time VRAM probe)
  works without OOM — depends on: Task 4.2 — status: done 2026-08-23 —
  built a REAL 899,067-token prompt with the model's own tokenizer
  (`/home/admin/build_prompt_896k.py` → `/home/admin/prompt-896k.txt`,
  same technique as Task 2.1's 768K test, not a synthetic estimate) and
  POSTed it to the live, already-running production
  `qwen3.8-27b-vllm.service` from Task 4.2 (not a fresh ad-hoc launch).
  **Result: HTTP 200, no OOM**, `usage.total_tokens: 899,117`
  (899,067 prompt + 50 completion) — comfortably within the 917,504
  max-model-len with ~18.4K tokens of headroom to spare, matching the
  margin design from Task 2.1/2.2. Wall time: 3582s (~59.7 min) — for
  scale, 768K took 45 min (FP8 KV cache, Task 2.1); the extra ~15 min
  for +131K tokens (17% more context) is directionally consistent, not
  a red flag on its own, but is folded into the existing throughput
  observation (see Phase 1/2's non-blocking note) rather than treated
  as a new finding. Service confirmed still `active (running)`, no
  errors/OOM-kills in the journal, `free -h` showing ~1.9 GiB free /
  18 GiB available afterward — consistent with (not degraded from)
  Task 2.3's measured 896K headroom (19.28 GiB free).
  **Caveat honestly flagged, not swept under the rug:** the test
  payload set `enable_thinking: false` as a top-level JSON field
  (copied from Task 2.1's own payload shape, written before Task 1.2
  established the correct `chat_template_kwargs: {"enable_thinking": false}` form) — this did NOT suppress thinking here: the response
  came back `finish_reason: "length"` with a non-empty, truncated
  `reasoning` field and `content: null` (ran out of the intentionally
  tiny `max_tokens: 50` mid-thought). This is a test-payload
  parameter-shape artifact, not evidence of a service defect — Task
  4.2 already separately verified the correct `chat_template_kwargs`
  form disables thinking correctly on this exact service. Task 4.3's
  actual acceptance bar (a real filled-context request completes
  without OOM) is unaffected and cleared regardless of the
  completion's content.

#### Phase 5: Integration

- [x] Task 5.1: Connect OpenCode to the Qwen3.8-27B endpoint as a separate
  model entry — depends on: Task 4.3 — status: done 2026-08-23 (OpenCode
  leg only; OpenWebUI wiring explicitly deferred/out of scope for this
  task per user decision — no OpenWebUI deployment/config details were
  available to act on) —
  1. Added `--served-model-name qwen3.8:27b-bf16` to
     `/home/admin/scripts/qwen3.8-27b-vllm-896k.sh` (mirrors `feat-2`'s
     `--alias` fix): before this change `/v1/models` reported the raw
     checkpoint path (`/home/admin/models/qwen3.8-27b`) as the model id;
     confirmed via a live `curl` before the change.
  2. Restarted `qwen3.8-27b-vllm.service` (`systemctl --user restart`);
     cold load ~9 min, consistent with prior Task 4.2/1.1 timings.
     Confirmed `active (running)`, `/health` 200 OK, and `/v1/models` now
     reports the clean id `qwen3.8:27b-bf16` (`max_model_len: 917504`
     unchanged). Re-ran a `chat_template_kwargs: {"enable_thinking": false}` smoke request against the new served name — correct answer,
     `finish_reason: "stop"` — service unaffected by the rename.
  3. Produced the OpenCode provider snippet (GB10 LAN IP
     `192.168.1.46`, port 8000, matching the box's `hostname -I`
     output) for the user to paste into their own `opencode.jsonc`
     `provider` object — NOT written into any config on this box, same
     "standalone snippet" precedent as `feat-2`:
     ```jsonc
     "vllm-dgx": {
         "npm": "@ai-sdk/openai-compatible",
         "name": "vllm (DGX)",
         "options": { "baseURL": "http://192.168.1.46:8000/v1" },
         "models": {
             "qwen3.8:27b-bf16": {
                 "name": "qwen3.8:27b-bf16",
                 "limit": { "context": 917504, "output": 65536 }
             }
         }
     }
     ```
     `limit.context` set to 917504 (the actual deployed 896K
     `max_model_len`), not the 768000 floor from REQ-003 — flagged to
     the user as a deliberate deviation from their initial draft value.
     Unauthenticated-endpoint caveat carried forward from `feat-2`: if
     OpenCode's `@ai-sdk/openai-compatible` provider errors on a missing
     key, add `"apiKey": "not-needed"` under `"options"`.
  4. **OpenWebUI wiring is NOT covered by this task's `done` status** —
     user explicitly chose to skip it for now (no OpenWebUI
     deployment/connection-mechanism details were available in this
     session, same gap noted as unresolved in both `feat-1` and
     `feat-2`). If OpenWebUI integration is needed later, it should be
     scoped as a follow-up task with its own dependency info gathered
     first (is it a separate service, env-var-driven, or admin-UI
     "Add Connection").
- [x] Task 5.2: User runs the same coding-task examples from `feat-1`/
  `feat-2` against this endpoint for a direct three-way quality
  comparison — depends on: Task 5.1 — status: DONE 2026-08-23 (checkbox
  fixed 2026-08-24 — Progress already recorded this as complete but the
  checkbox itself was never flipped, a documentation bug caught during
  this session's wrap-up). User ran their coding-task examples via
  OpenCode against the production BF16 endpoint at the time. **Caveat
  carried into ACC-011**: this was run against BF16, since superseded by
  NVFP4 (Task 6.2) — not re-run against the current NVFP4 production
  endpoint, so ACC-011's formal three-way comparison record is still
  open pending that re-run.

#### Phase 6: Compare with Qwen3.8-27B-NVFP4 (community benchmark cross-check)

Reference sources (both from the NVIDIA DGX Spark/GB10 forum, added
2026-08-23; same hardware class as our GB10 — 121.63 GiB unified memory
vs. our measured 119.63 GiB pool — and the SAME `qwen3_5`-family hybrid
layout our Design Notes already record: 48 linear-attention + 16
full-attention layers, matching our 16×(3×Gated DeltaNet→FFN)→1×(Gated
Attention→FFN)):

- Source A: <https://forums.developer.nvidia.com/t/qwen3-8-27b-nvfp4-on-a-single-dgx-spark-up-to-1m-context-vllm-mtp-measurements/380244>
  — single DGX Spark, `unsloth/Qwen3.8-27B-NVFP4`, vLLM
  `0.26.1rc1.dev244+gd6a593feb` nightly + MTP speculative decoding
  (built-in draft head, no separate model needed)
- Source B: <https://forums.developer.nvidia.com/t/qwen3-8-27b-on-dual-sparks/380350>
  — dual-Spark TP=2 (vLLM+MTP and SGLang+DFlash2 variants); not
  directly comparable to our single-GB10 deployment, kept as an
  upper-bound/different-engine reference only

Key reference numbers preserved here for continuity (avoids re-fetching
the threads in a future session):

| Config (Source) | Decode | Prefill | Notes |
|---|---|---|---|
| Single Spark, vLLM+MTP `num_speculative_tokens=5`, native 262144 ctx (A) | 24.0 tok/s (thinking) / 26.0 tok/s (no-thinking) | — | Bubblesort prompt, temp=0, streaming, median of 5 |
| Single Spark, vLLM, `num_speculative_tokens=0` (no spec decode) (A) | **11.4 tok/s** | — | **Cleanest same-engine, no-spec-decode NVFP4 baseline — the direct precision-only comparison point** |
| Single Spark, vLLM, unique-prefix prefill (A) | — | 4,566 tok @ 1,734 tok/s; 11,988 tok @ 1,153 tok/s; 24,015 tok @ 1,014 tok/s; 47,857 tok @ 853 tok/s | Must use a distinct prefix per request — prefix caching otherwise inflates the number (A's own "three ways I fooled myself" section) |
| KV-cache cost, native 262144 ctx, fp8 KV (A) | — | — | 37,169 bytes/token measured (12% above the 32,768 B naive calc); 777,645-token KV capacity at `--gpu-memory-utilization 0.45`; 1M context needs >=0.53, 0.60 recommended for headroom |
| Dual Spark, vLLM+MTP `num_speculative_tokens=2` (stability tradeoff) (B) | 22.6 tok/s (1 session) → 75.0 tok/s (4 sessions, aggregate) → 116.1 tok/s (8 sessions, aggregate) | — | ~5x aggregate throughput at 8-way concurrency vs. 1 session on 1 Spark |
| Single/Dual Spark, SGLang+DFlash2 (B, different engine) | 52-61 / 87 tok/s (code); 26 / 41 tok/s (prose); 34-49 / 49 tok/s (thinking chat) | ~10K tok/s | HumanEval pass@1 159/164 (97.0%); tool-eval-bench 92/100 (★★★★★); DFlash2 is lossless (greedy output matches target model) but incompatible with YaRN >262K on that build |

- [x] Task 6.1: Compare the performance of our production BF16
  installation (`qwen3.8-27b-vllm.service`) against the published
  NVFP4 data above — depends on: Task 4.3 — status: done 2026-08-23 —
  see RESULTS below; BF16 vs. NVFP4 performance is very different,
  Task 6.2 is warranted. Apples-to-apples plan:

  1. Reproduce Source A's exact decode benchmark (the Bubblesort
     prompt, `temperature=0`, streaming, median of 5 runs after
     warmup) against our live BF16 service, thinking on and off.
  2. Reproduce Source A's four unique-prefix prefill measurements
     (4,566 / 11,988 / 24,015 / 47,857 tokens, distinct prefix per
     request — no prefix-cache reuse) against our live BF16 service.
  3. Record our own already-measured FP8-KV-cache cost (~33.0 KB/token,
     BF16 weights, Task 2.1) next to Source A's 37,169 bytes/token
     (FP8 KV, NVFP4 weights) — since the architecture is confirmed
     equivalent, any material delta here is attributable to weight
     precision/packing, not architecture.
  4. Compute the throughput ratio between our BF16 result and Source
     A's `num_speculative_tokens=0` NVFP4 baseline specifically (11.4
     tok/s) — the only same-engine, no-speculative-decoding data point
     in either thread — to isolate the pure BF16-vs-NVFP4 precision
     effect from the separate, additive effect of speculative decoding
     (MTP/DFlash2).
  5. Explicitly record whether most of Source A/B's headline speedup
     (24-26 tok/s single-Spark MTP, up to 87 tok/s SGLang+DFlash2) comes
     from precision (BF16→NVFP4) or from speculative decoding (none→
     MTP/DFlash2) — if the latter dominates, adding MTP-style
     speculative decoding to our EXISTING BF16 deployment may be a
     lower-risk lever than a full NVFP4 requant, and should be
     considered as an alternative outcome of this task, not just
     "NVFP4 or nothing."

  **RESULTS (2026-08-23, executed live)** — ran all four planned
  measurements with a coordinated maintenance window: stopped the 896K
  BF16 production service, ran the NVFP4 checkpoint at native 262144
  context (`--gpu-memory-utilization 0.45`, reproducing Source A's exact
  recipe) in both `MTP=0` and `MTP=5` configurations, then restarted
  the BF16 production service and re-ran the SAME decode benchmark
  script against it for a rigorous, identically-methodology BF16
  baseline (superseding the rougher ~4.6 tok/s note from Task 1.2). All
  three configs passed the same tool-calling/thinking-mode/coherent-
  output smoke checks (Task 1.2/4.2 style) before benchmarking.

  | Config | Decode (thinking) | Decode (no-thinking) | Kernel used |
  |---|---|---|---|
  | Our BF16 production (896K ctx, FP8 KV, no spec decode) | 4.41 tok/s | 4.40 tok/s | n/a (BF16 GEMM) |
  | Our NVFP4, `MTP=0` (native 262144 ctx, FP8 KV) | 11.21 tok/s | 11.21 tok/s | `FlashInferCutlassNvFp4LinearKernel` (auto-selected) |
  | Our NVFP4, `MTP=5` (native 262144 ctx, FP8 KV) | 31.04 tok/s | 34.03 tok/s | same, + MTP draft head |
  | Source A reference, `num_speculative_tokens=0` | — | 11.4 tok/s | (their nightly build) |
  | Source A reference, `num_speculative_tokens=5` | 24.0 tok/s | 26.0 tok/s | (their nightly build) |

  Decomposed effects (median of 5 runs each, Bubblesort prompt,
  temperature=0, streaming — Source A's exact methodology):

  - **Precision-only effect, isolated (NVFP4 vs BF16, neither using
    speculative decoding)**: **2.54x** (11.21 / 4.405 tok/s avg).
  - **Speculative-decoding-only effect, isolated (MTP vs no-MTP, both
    NVFP4)**: **2.77x** (thinking) / **3.04x** (no-thinking).
  - **Combined effect (what a naive before/after would report)**:
    **7.05x** (thinking) / **7.73x** (no-thinking).
  - Our `MTP=0` result (11.21 tok/s) reproduces Source A's own
    no-spec-decode baseline (11.4 tok/s) within ~2% — validates the
    reproduction is sound and our stack behaves consistently with
    theirs at matched settings.
  - Our `MTP=5` result (31.04-34.03 tok/s) BEATS Source A's own
    `num_speculative_tokens=5` headline (24.0-26.0 tok/s) by **~29-31%**
    — attributed to our newer, stock vLLM 0.27.1 + FlashInfer
    0.6.16.post3 release vs. their August nightly dev build
    (`0.26.1rc1.dev244+...`), consistent with Task 6.2's kernel-check
    finding that our stock release closed real gaps present in their
    build.
  - **Prefill**: our unique-prefix measurements (2,388 / 2,316 / 2,136 /
    1,804 tok/s at 4,578 / 12,000 / 24,027 / 47,869 tokens) are
    meaningfully HIGHER than Source A's (1,734 / 1,153 / 1,014 /
    853 tok/s at closely-matching lengths) — same newer-stack
    explanation likely applies; no chunked-prefill flags were set
    explicitly on either side of our A/B, so this isn't a config
    artifact on our end.
  - **KV-cache efficiency**: our measured 33,571 bytes/token (27.56 GiB
    / 881,478 tokens, FP8 KV, native 262144 ctx — the 27.56 GiB figure
    matches Source A's exactly) is tighter than Source A's 37,169
    bytes/token — only 2.5% overhead above the 32,768-byte naive
    calculation vs. their 13.4% — another data point consistent with a
    more optimized build.
  - Conclusion for Task 6.2's decision criterion (adopt only if
    > =1.5-2x and it survives isolating speculative decoding): **BF16
    > performance is very different from NVFP4 — both YES independently**
    > (2.54x from precision alone clears the bar on its own) **and
    > combined with MTP** (7-7.7x). Task 6.2 is warranted and should
    > proceed. Still open before a final adoption decision: NVFP4 at our
    > actual production context (768K-1M via YaRN, not yet tested — Task
    > 6.2 step 4) and the REQ-005-mandated quality-impact check (Task 6.2
    > step 6, needs Task 5.2's coding-task examples).
  - Housekeeping: benchmark scripts left at `/home/admin/bench_decode.py`
    and `/home/admin/bench_prefill.py` for reuse in Task 6.2's
    long-context re-test once YaRN is applied to the NVFP4 checkpoint.
    Production BF16 service confirmed restored and healthy (896K
    context, `qwen3.8:27b-bf16`) at the end of this session — no net
    change to the running production state.

- [x] Task 6.2: Set up an NVFP4 deployment if Task 6.1 shows the BF16
  installation's performance is very different (materially slower)
  from the reference data, once the speculative-decoding contribution
  from Task 6.1.5 is accounted for — depends on: Task 6.1 —
  status: DONE 2026-08-24. Steps 1-5 done 2026-08-23 (kernel check
  passed, checkpoint pinned/downloaded, MTP decision deferred, YaRN
  capacity step-up complete — see step 4 RESULTS below: **NVFP4 clears
  all of 768K/896K/1M, including the full 1M ceiling BF16 failed at**;
  step 5 built/validated a production-candidate NVFP4+YaRN systemd
  service at 1M). **Steps 6-7 closed 2026-08-24: user's quality
  verdict via OpenCode was "NVFP4 quality is fine, adopt it" (step 6);
  final decision (step 7) is to ADOPT NVFP4 as production, replacing
  BF16 — but at a chosen production context of 896K, not the 1M
  candidate step 5 built**, per a separate user decision that 896K is
  "large enough" for real usage after testing (see STEP 6-7 RESULTS /
  PRODUCTION CUTOVER below for the full record, including the
  resulting deployment change from the 1M candidate to a new 896K
  production service). Decision
  criterion: only adopt NVFP4 (optionally
  with MTP) as production if it clears a large (e.g. >=1.5-2x)
  decode/prefill improvement that survives isolating speculative
  decoding, AND passes an empirical quality-impact check — per REQ-005,
  it must not be adopted by default. Required pre-work, in order:

  1. **Blocking check, do FIRST**: verify our installed vLLM 0.27.1
     (stock PyPI wheel, aarch64) actually has NVFP4 GEMM kernels for
     GB10/SM121a. Source B's community recipe explicitly warns: "Stock
     `vllm/vllm-openai` has NO NVFP4 kernels for Blackwell sm_121a
     (GB10). Every stock-vLLM attempt crashed" and required a custom
     community-built image
     (`ghcr.io/drowzeys/keys-vllm-027-gb10-qwen38` or
     `eugr/spark-vllm-b12x`, providing
     `FlashInferCutlassNvFp4LinearKernel`). Check this BEFORE any
     download/setup work, same discipline as Phase 0/Task 0.2's
     platform-support verification. If our stock vLLM build lacks
     NVFP4 kernel support, either find/validate an equivalent
     GB10-NVFP4-capable build, or treat NVFP4 as blocked and stop at
     Task 6.1's findings.
  2. Pin and download `unsloth/Qwen3.8-27B-NVFP4` (or an alternative
     NVFP4 repo, e.g. RadixArk's, if quality/compatibility differs) to
     a specific HF revision (REQ-007 discipline carried forward);
     re-verify the pinned revision doesn't have Source A's
     since-fixed tokenizer-truncation bug
     (`tokenizer.json`'s `truncation` field must be `null`).
  3. Decide whether to add MTP speculative decoding
     (`--speculative-config '{"method":"mtp","num_speculative_tokens":5}'`
     — the draft head ships inside the NVFP4 checkpoint, no separate
     model needed) — stays on our existing engine (vLLM), so REQ-006's
     engine decision is unaffected. SGLang+DFlash2 (Source B) is
     explicitly out of scope for this task unless MTP alone doesn't
     close the gap, since it is a different serving engine and would
     reopen the REQ-006 engine decision.
  4. Re-run the SAME Task 2.1-2.3 capacity/headroom step-up methodology
     (768K → 896K → 1M, >=15% free or >=10 GiB absolute policy) with
     NVFP4 weights. Explicitly named goal: NVFP4's much smaller
     resident weight footprint (~22.6-23.4 GB vs. BF16's ~55.6 GB)
     frees roughly 32 GB of the unified pool, which may be enough to
     clear the 1M-context policy floor that BF16 failed at (Task 2.2:
     1M measured 12.9% free, below the 15% floor) — re-measuring 1M
     with NVFP4 is a specific goal here, not just re-confirming 896K.
  5. Re-verify tool-calling and all three thinking-control modes
     (mirroring Task 1.2/4.2's exact checks) against the NVFP4(+MTP)
     service before calling it production-equivalent.
  6. Quality-impact check (REQ-005's bar): at minimum, re-run ACC-011's
     coding-task examples (once available from Task 5.2) against both
     BF16 and NVFP4 side by side; do not just trust Source A/B's own
     NVFP4 quality numbers (HumanEval 97.0%, tool-eval-bench 92/100),
     since those measured DIFFERENT NVFP4 checkpoints (unsloth vs.
     RadixArk) and a different draft/spec-decode stack (MTP vs.
     DFlash2) than whatever ends up deployed here.
  7. Record the outcome either way: adopt NVFP4 (± MTP) as the new
     production precision (replacing BF16, with the same
     one-line-rationale discipline as ACC-004), OR keep BF16 as
     production and record NVFP4 as evaluated-but-not-adopted with the
     reason (insufficient throughput gain once speculative decoding is
     isolated, unacceptable quality regression, or no GB10-compatible
     NVFP4 vLLM kernel available). "Not very different" is a valid,
     complete answer to this task, not a failure. Supersedes/closes the
     still-open Task 3.2 (optional FP8/quant weight eval) either way.

  **Step 4 RESULTS (2026-08-23, executed live, maintenance window)** —
  stopped the 896K BF16 production service (`systemctl --user stop qwen3.8-27b-vllm.service`, confirmed 0 GPU processes / clean pool
  before starting), created a parameterized YaRN-enabled NVFP4 launch
  script (`/home/admin/scripts/qwen3.8-27b-nvfp4-yarn-vllm.sh`, `CTX=768k|896k|1m` toggle, same YaRN `rope_parameters` override shape as
  BF16's, same per-context `--kv-cache-memory-bytes` values as the
  BF16 `launch-phase2-*-fp8kv.sh` scripts since KV-cache size is a
  function of architecture, not weight precision), then ran the full
  768K → 896K → 1M step-up, one context at a time (stop/measure/stop
  between each — the pool cannot hold two instances at once):

  | Context | Factor | `--kv-cache-memory-bytes` | KV cache capacity | Concurrency margin | Available memory | % free | Policy (>=15% or >=10 GiB) |
  |---|---|---|---|---|---|---|---|
  | 768K (786,432) | 3.0 | 30 GiB | 974,864 tokens | 1.24x | 51.61 GiB | 43.1% | **PASS** |
  | 896K (917,504) | 3.5 | 33 GiB | 1,073,277 tokens | 1.17x | 48.00 GiB | 40.1% | **PASS** |
  | 1M (1,048,576) | 4.0 | 37.11 GiB | 1,209,295 tokens | 1.15x | 43.34 GiB | 36.2% | **PASS** |

  Key findings:

  - **KV-cache token capacity and concurrency margin are IDENTICAL to
    the BF16 measurements at every context size** (974,864 / 1,073,277
    / 1,209,295 tokens at 768K/896K/1M, same 1.24x/1.17x/1.15x
    margins) — confirms KV-cache sizing is driven by model architecture
    (hidden dim, KV heads, layer count), not weight quantization, exactly
    as expected since NVFP4 only quantizes MLP weights (+FP8 attention),
    not the KV-cache-relevant attention shape.
  - **NVFP4 clears ALL THREE context sizes, including the full 1M
    native ceiling that BF16 failed (12.9% free, below the 15%
    floor)** — at 1M, NVFP4 leaves 36.2% of the unified pool free,
    more than double the 15% policy floor and nearly 3x BF16's
    899K-max/12.9%-at-1M result. This directly confirms the Design
    Notes' hypothesis: NVFP4's ~33 GB smaller resident weight footprint
    (21.59 GiB vs. BF16's ~55.99 GiB, measured at load time) is enough
    to fully absorb the difference.
  - Smoke-tested (coherent non-degenerate output, clean
    `get_weather("Paris")` tool-call, all three ACC-003 thinking-control
    modes on the 17×24=408 arithmetic prompt) at all three context
    sizes — all passed at every size: correct answers, correctly-scaled
    reasoning length by effort level (768K: n/a run only for
    correctness/tool-call; 896K: medium=44-char/xhigh=156-char
    reasoning; 1M: medium=124-char/xhigh=175-char reasoning), clean
    tool-calls, no degenerate output at any size.
  - All three test instances shut down cleanly after their
    measurements (0 GPU processes, port 8000 free, ~114 GiB available
    between each step and at the end).
  - **Per your maintenance-window instruction, the BF16 production
    service was intentionally left stopped (not restarted)** at the
    end of this run — `qwen3.8-27b-vllm.service` is `inactive (dead)`.
    Restarting it (`systemctl --user start qwen3.8-27b-vllm.service`)
    is a one-line action whenever normal production serving needs to
    resume; nothing else on the box needs cleanup.
  - **Still open before final adoption (Task 6.2 steps 5-7)**: step 5
    (re-verify tool-calling/thinking at whichever size is chosen as
    NVFP4's production context — informally done above at all three,
    but not yet against a finalized systemd deployment); step 6 (the
    REQ-005-mandated quality-impact check, BF16 vs. NVFP4 side by side
    on Task 5.2's coding-task examples — not yet run); step 7 (the
    final adopt-NVFP4-or-keep-BF16 recorded decision). Given NVFP4 now
    clears the full 1M ceiling (vs. BF16's 896K cap) AND is 2.54x-7.7x
    faster (Task 6.1), 1M is the natural candidate production context
    for NVFP4 if step 6's quality check clears the bar — but that
    decision is explicitly not made yet.

  **Prep work done ahead of time (2026-08-23, in parallel with Task
  5.2, no GPU/memory impact on the running BF16 production service)**:

  - **Step 1's blocking check is RESOLVED, and the outcome differs from
    the forum's warning**: verified live on this box (no test server
    needed) that our stock vLLM 0.27.1 + FlashInfer 0.6.16.post3
    (aarch64, PyPI release) DOES have working NVFP4 GEMM kernels for
    GB10/SM121a — `cutlass_scaled_mm_supports_fp4(121)` returns `True`,
    and `has_flashinfer_b12x_gemm()` (the exact `Sm120B12xBlockScaledDenseGemmKernel`
    the forum's custom community image added) is also `True`. This
    contradicts Source B's "stock vllm/vllm-openai has NO NVFP4 kernels
    for Blackwell sm_121a" claim — that was true for the August nightly
    dev build (`0.26.1rc1.dev244+...`) the forum posters used; our
    newer stock 0.27.1 release has since closed that gap.
  - One real caveat found in the kernel-selection source itself
    (`vllm/model_executor/kernels/linear/__init__.py`): vLLM's
    auto-selection deliberately EXCLUDES the fastest b12x kernel by
    default — code comment: *"FlashInferB12xNvFp4LinearKernel excluded
    from auto-selection until upstream CUTLASS SM121 MMA op guard is
    resolved; use `--linear-backend flashinfer_b12x` to opt in
    explicitly."* Auto-selection order on this box resolves to
    `FlashInferCutlassNvFp4LinearKernel` (confirmed `is_supported() -> True`) — a solid, supported default, just not the fastest possible
    path. `--linear-backend flashinfer_b12x` is available as an
    explicit, opt-in experiment, not the baseline comparison config.
  - Pinned and downloaded `unsloth/Qwen3.8-27B-NVFP4` to HF revision
    `7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108` (2026-08-17, i.e. after
    the 2026-08-15 tokenizer-truncation fix mentioned in Source A) —
    verified `tokenizer.json`'s `truncation` field is `null` BEFORE
    committing to the full 23.4 GB download (fetched that one file
    first), then re-verified after — confirmed fixed both times.
    22.6 GB `model.safetensors` + 0.85 GB `model_mtp.safetensors`
    (1968 tensors total, 15 of them the MTP head, all registered in one
    `model.safetensors.index.json` — matches Source A's finding that no
    separate `--speculative-config "model"` field is needed) landed at
    `/home/admin/models/qwen3.8-27b-nvfp4`. 345 GB still free on
    `/home/admin` afterward — no disk pressure.
  - `config.json` confirms `Qwen3_5ForConditionalGeneration` (same
    registry entry the BF16 checkpoint uses) and a compressed-tensors
    mixed quantization config: NVFP4 for most MLPs, FP8 for
    attention/`lm_head`/the last 8 layers' MLPs — matches Source A's
    "MLP in NVFP4, attention in FP8" description exactly. `rope_type: "default"` (no scaling) with `max_position_embeddings: 262144` in
    `text_config` — same YaRN-override shape (REQ-011) as our BF16
    deployment, just needs applying to this checkpoint when context
    extension is tested.
  - Drafted (not yet run) `/home/admin/scripts/qwen3.8-27b-nvfp4-vllm.sh`
    — two modes via `MTP=0` (default, no speculative decoding — the
    apples-to-apples comparison point for Task 6.1.4 against Source A's
    `num_speculative_tokens=0` baseline) or `MTP=1` (adds
    `--speculative-config '{"method":"mtp","num_speculative_tokens":5}'`,
    matching Source A's headline config), both at native 262144 context
    and `--gpu-memory-utilization 0.45` (reproducing Source A's exact
    recipe). **Deliberately NOT started**: the unified 128 GB pool
    cannot hold both this and the running 896K BF16 production service
    at once (BF16 alone already uses ~111 GiB at 896K) — running it
    requires a coordinated maintenance window (`systemctl --user stop qwen3.8-27b-vllm.service` first, restart after), left for whenever
    Task 6.1's actual benchmark run is scheduled, so as not to disrupt
    Task 5.2's live user testing.

  **Step 6-7 RESULTS / PRODUCTION CUTOVER (2026-08-24)**:

  1. **Step 6 (quality verdict)**: user ran their coding-task examples
     via OpenCode against the NVFP4 1M candidate service
     (`qwen3.8-27b-nvfp4-1m.service`, left running from step 5) and
     reported: **"NVFP4 quality is fine, adopt it."** This is the
     REQ-005-mandated quality-impact check, satisfied per the same
     "user's own judgment on their own examples" precedent as `feat-1`
     ACC-010 and this feature's own Task 5.2.
  2. **Separate context decision**: in the same follow-up, the user
     concluded from their testing that **896K context is "large
     enough"** for real usage and explicitly chose it over the 1M
     ceiling that step 4/5 had qualified and built a candidate for.
     This is independent of the precision decision — NVFP4 at 896K
     (Task 6.2 step 4's table) has even more headroom (40.1% free) than
     NVFP4 at 1M (36.2% free), so dropping to 896K is a strictly safer
     choice on top of being the user's stated preference.
  3. **Step 7 (final decision, recorded)**: **ADOPT NVFP4 as the
     production precision, replacing BF16, at 896K context (not
     1M).** Rationale (one-line, per ACC-004's precedent): NVFP4 gives
     a 2.54x-7.7x decode speedup over BF16 (Task 6.1) with no quality
     regression per the user's own coding-task judgment (step 6 above),
     clearing REQ-005's bar for adopting a quantized variant over BF16
     ("not adopted by default... only if empirically justified").
     REQ-003/ACC-002's already-chosen 896K production context is
     unaffected by the precision change (KV-cache sizing at 896K is
     architecture-driven and identical for BF16/NVFP4 per Task 6.2 step
     4's table) — only the weight precision changes.
  4. **Deployment cutover performed** (live, this session, directly on
     `dgx`): the 1M NVFP4 candidate no longer matches the chosen
     production context, so it was retired rather than promoted as-is.
     Built a NEW production script/unit at 896K instead:
     - `/home/admin/scripts/qwen3.8-27b-nvfp4-896k.sh` — derived from
       the validated `qwen3.8-27b-nvfp4-1m.sh` (same
       `VLLM_DISABLE_COMPILE_CACHE=1` fix from step 5, deliberately NO
       `--linear-backend` pin per step 5's finding), with 896K params
       (`--max-model-len 917504`, YaRN factor 3.5, `--kv-cache-memory-bytes 35433480192` / 33 GiB — identical KV-cache sizing to the
       BF16 896K script), `--served-model-name qwen3.8:27b-nvfp4-896k`.
     - `/home/admin/.config/systemd/user/qwen3.8-27b-nvfp4-896k.service`
       — mirrors the existing unit pattern (`--user`, disabled/
       no-autostart, `TimeoutStartSec=4200`, `LimitNOFILE=1048576`).
     - Stopped `qwen3.8-27b-nvfp4-1m.service` (confirmed `inactive`,
       port 8000 free, 0 GPU processes) and `qwen3.8-27b-vllm.service`
       (BF16, already stopped from the maintenance window) before
       starting the new unit — both retained on disk, disabled, as
       fallback/reference, not deleted.
  5. **Real environment gap found and fixed during cutover**: the first
     two start attempts of `qwen3.8-27b-nvfp4-896k.service` failed with
     `ValueError: Free memory on device cuda:0 (65.52-65.74/119.63 GiB) on startup is less than desired GPU memory utilization` — NOT a
     script/config bug. Root cause: a **resident Ollama-served model**
     (`qwen3.8:27b-q8_0`, 46 GB, via the `ollama` Docker container,
     `--restart always`) was loaded and holding ~43-46 GiB of the
     unified pool, evidently left over from unrelated testing (possibly
     the same Ollama quant used informally for comparison outside this
     feature). This is the exact contention class the Design Notes
     already warned about for capacity *testing* — new finding here is
     that it also blocks *production service restarts*, not just
     measurement runs. Fixed with `docker exec ollama ollama stop qwen3.8:27b-q8_0` (unloads the model, does NOT stop the
     always-restarting container itself) — pool returned to a clean
     ~114 GiB available baseline immediately. **Operational risk now
     recorded, not just fixed once**: if any Ollama model is loaded
     (via OpenWebUI or the Ollama API directly) while the NVFP4
     production service is running, the shared unified pool has thin
     enough headroom (40.1% / ~48 GiB at 896K) that a large concurrent
     Ollama load could still cause runtime memory pressure even though
     it won't crash an already-started vLLM engine outright (unlike a
     cold start, which re-checks free memory against
     `--gpu-memory-utilization` and fails fast, as observed here). No
     guard/quota is implemented for this coexistence risk — flagged as
     an open operational caveat, not solved by this feature.
  6. **Full re-verification passed** against the new
     `qwen3.8-27b-nvfp4-896k.service` (cold start ~3m45s after the
     Ollama fix): `/v1/models` reports `qwen3.8:27b-nvfp4-896k` /
     `max_model_len: 917504`; memory measured at ~48 GiB available /
     119Gi total (~40.1% free), matching step 4's table exactly;
     coherent non-degenerate output (fib-with-memoization prompt); clean
     `get_weather("Paris")` tool-call (`finish_reason: "tool_calls"`);
     all three ACC-003 thinking-control modes on the 17×24=408 prompt
     (`enable_thinking: false` → 0-length reasoning, direct "408";
     `reasoning_effort: medium` → 44-char reasoning, correct answer;
     `reasoning_effort: xhigh` → 120-char reasoning, correctly more
     elaborate, correct answer). Service left `active (running)` as the
     new production service.
  7. **Not yet re-run**: Task 5.2's exact OpenCode-agentic-session leg
     of ACC-003 (the curl leg above is done, but the full agentic
     session was previously only run against the now-superseded BF16
     production service — see the caveat added to ACC-003 below).
     Also not yet done: updating the user's actual `opencode.jsonc`
     provider entry to the new `qwen3.8:27b-nvfp4-896k` model id (the
     user manages that file, not this repo — an updated snippet is
     provided in Progress below).
  8. Housekeeping: `qwen3.8-27b-nvfp4-1m.service`/`.sh` and
     `qwen3.8-27b-vllm.service`/`.sh` (BF16) are both left on disk,
     `disabled`, `inactive` — kept as documented fallback paths (1M
     NVFP4 if more context is ever needed and headroom allows re-
     confirming it; BF16 if a future finding reverses the NVFP4
     adoption) rather than deleted.

- [x] Task 6.3 (follow-up, same day): Test MTP speculative decoding
  combined with YaRN long-context extension at the actual 896K
  production context — depends on: Task 6.2 — status: DONE 2026-08-24.
  Context: Task 6.1's MTP benchmarks were only ever run at NVFP4's
  NATIVE 262144 context; the 896K production cutover (Task 6.2 step 7)
  deliberately left MTP OUT pending this dedicated test, since
  YaRN-long-context + MTP-draft-head behavior together were unvalidated.
  User asked to test and, if it clears the bar, activate it.

  **Method**: maintenance window (production service stopped), ran an
  ad-hoc MTP+YaRN-896K instance
  (`--speculative-config '{"method":"mtp","num_speculative_tokens":5}'`
  added to an otherwise-identical copy of the production 896K script),
  then a same-context non-MTP instance for a true apples-to-apples
  comparison (not just reusing Task 6.1's native-context numbers).

  **Results**:

  - **Capacity**: KV-cache capacity drops from 1,073,277 to 984,829
    tokens with MTP enabled (margin 1.17x → 1.07x, still clears the
    917,504-token requirement); pool free drops from 40.1% to ~38.5-39.2%
    — still comfortably above the 15%/10 GiB safety-margin policy floor.

  - **Correctness**: byte-identical greedy (temperature=0) output vs.
    the non-MTP run on the same prompt — confirms lossless speculative
    decoding at this context (the acceptance/verification step is
    exact, not just "didn't crash"). Tool-calling and all three
    ACC-003 thinking-control modes also verified unaffected.

  - **Throughput** (median of 5, `bench_decode.py`, Bubblesort prompt,
    same methodology as Task 6.1), same 896K/YaRN context both runs:

    | Config | Decode (thinking) | Decode (no-thinking) |
    |---|---|---|
    | NVFP4, 896K/YaRN, no MTP | 11.27 tok/s | 11.27 tok/s |
    | NVFP4, 896K/YaRN, MTP (num_speculative_tokens=5) | 29.93 tok/s | 35.17 tok/s |

    **Speedup: 2.66x (thinking) / 3.12x (no-thinking)** — closely
    matches Task 6.1's native-context MTP-alone finding (2.77x/3.04x),
    confirming the gain carries over cleanly to YaRN-extended context.

  - **Decision: MTP clears the bar (capacity, correctness, and
    throughput all pass) — adopted into production.** Promoted directly
    into `qwen3.8-27b-nvfp4-896k.sh` (same served-model-name
    `qwen3.8:27b-nvfp4-896k`, no OpenCode config change needed) rather
    than a separate model id, since it's a strict throughput
    improvement over the same-day 896K cutover with no observed
    downside. The pre-MTP version is preserved as
    `qwen3.8-27b-nvfp4-896k-no-mtp.sh`, a documented rollback path if
    MTP ever misbehaves in real extended usage despite passing these
    checks. Production systemd service restarted with the new script
    and fully re-verified (coherent output, tool-call, correct
    `/v1/models`, 984,829-token KV capacity, ~39% pool free).

## Progress

### Current Status

**As of 2026-08-23**: Phase 0 and Phase 1 COMPLETE. The prior session's
Ollama-contention blocker was already cleared by the time this session
started (Ollama no longer resident; GB10 GPU/unified-pool fully free)
— no unload step was needed. vLLM 0.27.1 was brought up successfully
at native context (32768 max-model-len, no YaRN), producing coherent
non-degenerate output, with tool-calling and all three thinking-control
modes (`enable_thinking: false`, `reasoning_effort: low/medium/xhigh`)
verified via curl. Two new non-root-fixable environment gaps were found
and fixed without sudo (missing `Python.h` via `uv python install` +
`CPATH`; `ninja` unreachable via `PATH`) — see Task 1.1 for the full
fix. vLLM is confirmed as the deployment engine (REQ-006/ACC-005); no
SGLang fallback needed. The test server was shut down cleanly after
Phase 1 so the GB10 is back to a clean, fully-free baseline.

**As of 2026-08-23 (later this date)**: Phase 2 COMPLETE (Tasks 2.1-2.3).
Two real findings, not just confirmations: (1) the default
`VLLM_ENGINE_READY_TIMEOUT_S=600` is too short for this box at large
`--max-model-len` and had to be raised to 3600; (2) the default
`--gpu-memory-utilization`-driven KV cache sizing leaves the GB10's OS
with almost no memory at 768K+ (measured ~1.7-3.5 GiB free, vs. a
~17.9 GiB policy floor) — fixed by switching to `--kv-cache-dtype fp8`
with an explicit, right-sized `--kv-cache-memory-bytes` instead (KV
cache precision only, BF16 weights unaffected). With that fix, stepped
768K -> 896K -> 1M: 768K passed comfortably (19.8% free), 896K passed
narrowly (16.1% free), 1M failed (12.9% free, below the 15% policy
floor). **896K (YaRN factor 3.5) is the chosen production context**,
with 19.28 GiB (16.1%) of the pool remaining free — the GB10
effectively owns its pool at this context; no meaningful coexistence
headroom remains (REQ-010/Task 2.3).

**Phase 3 Task 3.1 COMPLETE** (2026-08-23, same session as this update):
BF16 confirmed as the production model *weight* precision via a live
shell on the GB10 — no `--dtype`/`--quantization` flag in the 896K
launch script, no `quantization_config` in `config.json`, safetensors
total (55.56 GB) matches BF16 for ~27B params. REQ-005/ACC-004 closed.

**Phase 4 Task 4.1 COMPLETE** (2026-08-23, same session): vLLM +
Qwen3.8-27B installed as a systemd `--user` service on the GB10
(`qwen3.8-27b-vllm.service`, `ExecStart=/home/admin/scripts/qwen3.8-27b-vllm-896k.sh`
— a byte-for-byte-flags production copy of the tested 896K Phase 2
script). Lingering enabled (`Linger=yes`, no sudo needed); unit
deliberately left `disabled` (won't autostart at boot), `inactive`
(not started yet — Task 4.2 does that). GB10 confirmed clean after
install (port 8000 free, 0 GPU processes).

**Phase 4 Task 4.2 COMPLETE** (2026-08-23, same session): started
`qwen3.8-27b-vllm.service` — cold load ~7m43s, matching Phase 2's
timing. Curl smoke tests against the live production service (896K,
confirmed via `/v1/models`) all passed: coherent non-degenerate
output, clean tool-call, and ACC-003's exact 3 thinking-control modes
(`enable_thinking: false`, `reasoning_effort: medium`,
`reasoning_effort: xhigh`) all returned the correct 17×24=408 answer
with correctly-scaled reasoning length. Service left running (not
stopped) for Task 4.3 to reuse.

**Phase 4 Task 4.3 COMPLETE** (2026-08-23, same session) — **Phase 4 is
now fully COMPLETE.** Built a real 899,067-token prompt (model's own
tokenizer) and POSTed it to the live, already-running production
service from Task 4.2: HTTP 200, no OOM, `usage.total_tokens: 899,117`
(within the 917,504 max-model-len, ~18.4K headroom to spare), 3582s
(~59.7 min) wall time. Service confirmed still healthy afterward
(active, no errors, ~18 GiB available — matching Task 2.3's measured
headroom). One caveat honestly flagged: the test payload's top-level
`enable_thinking: false` field didn't actually suppress thinking here
(a payload-shape artifact from reusing Task 2.1's older format, not a
service defect — Task 4.2 already separately confirmed the correct
`chat_template_kwargs` form works) — response hit `finish_reason: "length"` with truncated reasoning and null content, but this does not
affect Task 4.3's actual pass/fail bar (completes without OOM).

**Phase 5 Task 5.1 COMPLETE** (2026-08-23, later session): OpenCode
wired to the production endpoint. Added `--served-model-name qwen3.8:27b-bf16` to the launch script (mirrors `feat-2`'s `--alias`
fix; `/v1/models` previously leaked the raw checkpoint path), restarted
the service, and re-verified health + a thinking-disabled chat
completion post-rename. Produced a standalone OpenCode provider
snippet (`baseURL: http://192.168.1.46:8000/v1`, `limit.context: 917504` matching the real 896K deployment) for the user to paste into
their own `opencode.jsonc` — not written into any config on this box,
same precedent as `feat-2`. OpenWebUI wiring explicitly deferred/out of
scope per user decision (no OpenWebUI deployment details were
available). Remaining: Task 5.2 (user runs the comparison coding-task
examples via OpenCode).

**Phase 6 ADDED** (2026-08-23): "Compare with Qwen3.8-27B-NVFP4" —
cross-checks our BF16 production install against two NVIDIA DGX
Spark/GB10 forum threads with real NVFP4+MTP/DFlash2 throughput and
quality numbers on matching hardware/architecture (Task 6.1), then
conditionally sets up an NVFP4 deployment only if the gap is large and
survives isolating the separate speculative-decoding effect, with an
explicit quality-impact check before adoption (Task 6.2, subsumes the
still-open Task 3.2). Not started — depends on Task 4.3, so it can run
independently of/in parallel with Phase 5.

**Phase 6 prep work COMPLETE** (2026-08-23, run in parallel with the
user's Task 5.2 session — no GPU/memory impact on the live BF16
service): Task 6.2's blocking kernel check resolved (our stock vLLM
0.27.1 + FlashInfer 0.6.16.post3 DOES support NVFP4 GEMM on
GB10/SM121a, contrary to the forum's stock-vLLM warning — see Task 6.2
notes for the exact `is_supported()` evidence and the one real caveat,
an upstream SM121 guard that excludes the fastest b12x kernel from
auto-selection). `unsloth/Qwen3.8-27B-NVFP4` downloaded and pinned
(revision `7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108`, tokenizer fix
verified before AND after download), `/home/admin/scripts/qwen3.8-27b-nvfp4-vllm.sh`
drafted (native 262144 context, `MTP=0`/`MTP=1` toggle) but
deliberately not started — running it needs a maintenance window
(BF16 production service stopped first), left for Task 6.1's actual
benchmark run.

**Task 5.2 COMPLETE** (user confirmed, 2026-08-23) — user ran their
coding-task comparison via OpenCode against the production BF16
endpoint.

**Phase 6 Task 6.1 COMPLETE** (2026-08-23, same session): with a
coordinated maintenance window (user's go-ahead after finishing Task
5.2), stopped the 896K BF16 production service, benchmarked the
downloaded NVFP4 checkpoint at native 262144 context in both `MTP=0`
and `MTP=5` configs (tool-calling/thinking-mode/coherent-output smoke
checks all passed on both), then restarted BF16 production and
re-ran the identical decode-benchmark script against it for a rigorous
same-methodology baseline. Headline results: **precision alone (NVFP4
vs. BF16, no spec decode either side) is 2.54x**; **speculative
decoding alone (MTP vs. no-MTP, both NVFP4) is 2.77-3.04x**; combined,
NVFP4+MTP is **7.05-7.73x** faster decode than our BF16 production
service. Our `MTP=0`/`MTP=5` numbers reproduce Source A's own
reference points closely (within ~2% for the no-spec baseline) and
BEAT their MTP=5 headline by ~29-31%, plus meaningfully better prefill
throughput and KV-cache byte/token efficiency — both attributed to our
newer stock vLLM/FlashInfer release vs. their nightly dev build.
**Conclusion: BF16 vs. NVFP4 performance is very different by Task
6.2's own decision criterion (>=1.5-2x) — proceeding to Task 6.2 is
warranted.** Production BF16 service confirmed restored and healthy
(896K context) at the end of this run — net state unchanged.

**Task 6.2 steps 6-7 COMPLETE, PRODUCTION CUTOVER DONE** (2026-08-24) —
**Phase 6 (Task 6.2) is now fully COMPLETE.** User's quality verdict
(step 6, via OpenCode against the NVFP4 1M candidate): "NVFP4 quality
is fine, adopt it." Separate user decision: production context is
**896K, not 1M** — "the ctx is large enough with that size." Final
adoption (step 7): **NVFP4 replaces BF16 as the production precision,
served at 896K context.** Executed the cutover live on `dgx`: retired
`qwen3.8-27b-nvfp4-1m.service` and `qwen3.8-27b-vllm.service` (both
stopped, left disabled/on-disk as fallbacks), built and started
`qwen3.8-27b-nvfp4-896k.service` (new script derived from the
validated 1M one, same context/KV-cache sizing as the existing 896K
BF16 script). Found and fixed a real environment gap during the
cutover: a resident Ollama-served model (`qwen3.8:27b-q8_0`, 46 GB, via
the always-restarting `ollama` Docker container) was holding enough of
the unified pool that the new service failed its startup free-memory
check twice before the Ollama model was unloaded (`docker exec ollama ollama stop qwen3.8:27b-q8_0`) — a genuine coexistence risk beyond
what earlier capacity-testing sessions accounted for, now flagged as an
open operational caveat (no guard/quota exists to prevent it recurring
during normal operation). After the fix, full re-verification passed:
`/v1/models` confirms `qwen3.8:27b-nvfp4-896k` / `max_model_len: 917504`, ~40.1% pool free (matching Task 6.2 step 4's table), coherent
output, clean tool-call, all three thinking-control modes correct.
Updated ACC-004 (superseded — NVFP4 now the empirically-justified
quantized production precision, satisfying REQ-005's bar). Full record
in Task 6.2's "Step 6-7 RESULTS / PRODUCTION CUTOVER" block in the Task
List. Remaining open items: the OpenCode-agentic-session leg of ACC-003
has not been re-run against the new NVFP4 896K service (only against
the superseded BF16 one, Task 5.2); the user's own `opencode.jsonc`
needs updating to the new `qwen3.8:27b-nvfp4-896k`
model id (snippet provided above, in the resolved SESSION HANDOFF
section).

**Task 6.3 COMPLETE, MTP ACTIVATED IN PRODUCTION** (2026-08-24, same
session, follow-up requested by user): tested MTP speculative decoding
combined with YaRN long-context extension at the real 896K production
context (previously untested — Task 6.1's MTP numbers were all at
NVFP4's native 262144 context). Capacity still clears the policy
(KV-cache capacity 1,073,277 → 984,829 tokens, margin 1.17x → 1.07x,
pool free 40.1% → ~39%), correctness is lossless (byte-identical greedy
output vs. non-MTP at the same prompt), and throughput at the actual
896K/YaRN context improves **2.66x (thinking) / 3.12x (no-thinking)** —
closely matching Task 6.1's native-context finding. **Promoted directly
into the production script** (`qwen3.8-27b-nvfp4-896k.sh`, same served
model id, no OpenCode config change needed); the pre-MTP version is
preserved as `qwen3.8-27b-nvfp4-896k-no-mtp.sh` for rollback. Production
systemd service restarted and fully re-verified. Full record in Task
6.3 in the Task List.

**Task 6.2 step 4 COMPLETE** (2026-08-23, same session, maintenance
window): stopped the BF16 production service and ran the full
768K→896K→1M YaRN capacity step-up against NVFP4 using a new
parameterized script (`/home/admin/scripts/qwen3.8-27b-nvfp4-yarn-vllm.sh`).
**All three context sizes PASS the safety-margin policy, including the
full 1M native ceiling that BF16 failed at** (BF16: 12.9% free at 1M,
below the 15% floor; NVFP4: 36.2% free at 1M, well above it). KV-cache
token capacity/concurrency margins are identical to BF16's at every
size (confirms KV-cache sizing is architecture-driven, not
precision-driven). Tool-calling and all three thinking-control modes
verified at every size. Full results in Task 6.2's step-4 notes above.
**Per your maintenance-window instruction, the BF16 production service
was intentionally left stopped, not restarted.**

**Task 6.2 step 5 COMPLETE** (2026-08-23, same session, maintenance
window continued): built a production-candidate NVFP4+YaRN systemd
service at the 1M native ceiling (`qwen3.8-27b-nvfp4-1m.service`,
`ExecStart=/home/admin/scripts/qwen3.8-27b-nvfp4-1m.sh`, mirroring the
BF16 `qwen3.8-27b-vllm.service` pattern -- `--user` unit, lingering
already enabled from Task 4.1, left `disabled` so it won't autostart).
1M chosen over 768K/896K as the candidate context since it clears the
safety-margin policy with the most headroom of the three AND is the
model's full native ceiling (Task 6.2 step 4).

Hit and fixed a real environment gap while bringing this up as a
systemd service (not present in step 4's ad-hoc `nohup` runs): vLLM's
NVFP4/FP8 kernel auto-selection is **not stable run-to-run** on this
box -- observed switching between `CutlassNvFp4LinearKernel` and
`FlashInferCutlassNvFp4LinearKernel` across otherwise-identical
launches, and the on-disk `torch.compile` AOT cache under
`~/.cache/vllm/torch_compile_cache/` does not key on which kernel was
selected. A run that auto-selects a different kernel than a prior run
against the same model directory can load a stale, incompatible
cached graph and crash-loop
(`AttributeError: '_OpNamespace' 'vllm' object has no attribute 'flashinfer_mm_fp4'`). Explicitly pinning `--linear-backend flashinfer_cutlass` was tried first but broke a DIFFERENT kernel
choice (the FP8 W8A8 scaled-mm kernel for attention/lm_head/last-8-
layers-MLP then failed with `FlashInferFP8ScaledMMLinearKernel requires FlashInfer to be installed`) -- `--linear-backend` applies
too broadly across this checkpoint's mixed NVFP4+FP8 quantization
scheme. **Fix: `VLLM_DISABLE_COMPILE_CACHE=1`**, forcing a fresh
compile every launch against whichever kernel gets auto-selected that
run, at the cost of a slightly longer cold start (no AOT-artifact
reuse) -- this is now baked into `qwen3.8-27b-nvfp4-1m.sh` and should
be carried into any future NVFP4 production script derived from it.

With that fix, the service started cleanly (`CutlassNvFp4LinearKernel`
auto-selected this run) and passed the full re-verification: KV cache
1,209,295 tokens (1.15x margin, matching step 4's measurement exactly),
39.0% pool free, `/v1/models` reports `qwen3.8:27b-nvfp4-1m` /
`max_model_len: 1048576`. Coherent non-degenerate output, clean
`get_weather("Paris")` tool-call, and all three thinking-control modes
(`enable_thinking: false` -> null reasoning; `reasoning_effort: medium`
-> 71-char reasoning; `reasoning_effort: xhigh` -> 95-char reasoning,
correctly more elaborate) all passed, correct 17x24=408 answer
throughout. **Service left running** (not stopped) so you can point
OpenCode at it directly for Task 6.2 step 6.

**RESOLVED 2026-08-24 — Task 6.2 steps 6-7 are CLOSED and the production
cutover is DONE.** (This section previously handed off an in-progress
quality test; kept below, struck through in spirit but left as history,
followed by what actually happened.)

**Final outcome**: user's quality verdict (step 6) was "NVFP4 quality is
fine, adopt it." Separately, the user decided **896K context is "large
enough"**, not the 1M candidate this handoff was originally about — so
step 7's adoption applied NVFP4 at **896K**, not 1M. The production
cutover was executed live this session:

- Retired `qwen3.8-27b-nvfp4-1m.service` (stopped, left disabled/on-disk
  as a documented fallback if 1M is ever wanted again).
- Retired `qwen3.8-27b-vllm.service` (BF16, stopped, left disabled/
  on-disk as a documented fallback if BF16 is ever needed again).
- Built and started the new production service:
  `qwen3.8-27b-nvfp4-896k.service` -> `qwen3.8-27b-nvfp4-896k.sh`
  (896K/917,504 context, YaRN factor 3.5, NVFP4 weights, FP8 KV cache,
  `--served-model-name qwen3.8:27b-nvfp4-896k`). Full re-verification
  passed (coherent output, tool-call, all 3 thinking-control modes,
  ~40.1% pool free matching Task 6.2 step 4's table). See Task 6.2's
  "Step 6-7 RESULTS / PRODUCTION CUTOVER" block in the Task List above
  for the complete record, including a real environment gap found and
  fixed during the cutover (a resident Ollama-served model was
  competing for the unified pool and had to be unloaded first).

**Current production OpenCode provider snippet** (supersedes the
1M-context one originally in this handoff, and Task 5.1's original
BF16 one — update your `opencode.jsonc` accordingly):

```jsonc
"vllm-dgx": {
    "npm": "@ai-sdk/openai-compatible",
    "name": "vllm (DGX, NVFP4 896K)",
    "options": { "baseURL": "http://192.168.1.46:8000/v1" },
    "models": {
        "qwen3.8:27b-nvfp4-896k": {
            "name": "qwen3.8:27b-nvfp4-896k",
            "limit": { "context": 917504, "output": 65536 }
        }
    }
}
```

Same unauthenticated-endpoint caveat as before: add
`"apiKey": "not-needed"` under `"options"` if the provider errors on a
missing key.

**What remains (not part of Task 6.2, tracked as open follow-ups)**:

1. The OpenCode-agentic-session leg of ACC-003 was only run against the
   now-superseded BF16 service (Task 5.2) — not yet re-run against the
   new NVFP4 896K production service. The curl leg of ACC-003 HAS been
   re-verified against NVFP4 896K (this session).
2. MTP-at-long-context (YaRN + speculative decoding together) was the
   OPEN follow-up as of this note -- **RESOLVED 2026-08-24 (Task 6.3):
   tested and adopted into production**, see the session handoff block
   immediately below for the full outcome.
3. The Ollama-vLLM unified-pool coexistence risk found during the
   cutover (see Task 6.2's step 5 in the results block) has no
   guard/quota — an operational caveat to keep in mind, not a task.

**Known non-blocking observation from Phase 1/2**: generation
throughput was only ~4.6 tokens/s in the Phase 1 small-context smoke
test (unquantized BF16, single request, no prefix caching), and the
768K real-prompt end-to-end requests took ~36 min (BF16 KV cache) /
~45 min (FP8 KV cache) wall time in Phase 2 — FP8 KV cache appears
slower here, likely un-tuned FlashInfer FP8 dequant on this new
GB10/SM121 platform. Worth a closer look during Phase 4 once serving
flags are closer to final production shape; flagged so it is not
forgotten (may matter for real interactive/agentic use over OpenCode).

______________________________________________________________________

**>>> SESSION HANDOFF (2026-08-24, session end) — start here for the
NEXT session. This block supersedes all earlier handoff notes above in
this file (kept for history, but this is the current state):**

**Live production state, verified at session end:**

- `qwen3.8-27b-nvfp4-896k.service` is `active (running)` —
  `qwen3.8:27b-nvfp4-896k`, `max_model_len: 917504`, port 8000, NVFP4
  weights, YaRN factor 3.5, FP8 KV cache, **MTP speculative decoding
  enabled** (`num_speculative_tokens=5`). ~46 GiB available / ~39% of
  the 119.63 GiB unified pool free.
- `qwen3.8-27b-nvfp4-1m.service` and `qwen3.8-27b-vllm.service` (BF16)
  are both `inactive`/`disabled` — intentionally retained on disk as
  documented rollback paths, not deleted.
- `/home/admin/scripts/qwen3.8-27b-nvfp4-896k-no-mtp.sh` is the
  pre-MTP fallback launch script if MTP ever needs to be backed out.
- No Ollama model is currently loaded (checked — the coexistence issue
  from earlier this session is not currently active, but has no
  permanent guard; see the open caveat above).

**What happened this session** (in order): closed out Task 6.2 steps
6-7 (NVFP4 adopted as production precision, at 896K not 1M per your
own testing/decision); did the production cutover live (retired the 1M
NVFP4 candidate and BF16, stood up `qwen3.8-27b-nvfp4-896k.service`,
hit and fixed a real Ollama-pool-contention bug along the way); you
asked whether MTP was enabled — it wasn't, so Task 6.3 tested it
combined with YaRN-896K (previously never validated together),
confirmed correctness/capacity/a 2.66x-3.12x throughput gain, and
promoted it into production; answered how to control thinking mode
from OpenCode (`chat_template_kwargs.enable_thinking` +
`reasoningEffort`, via model `options`/`variants` in `opencode.jsonc`
— NOT independently verified end-to-end through an actual OpenCode
client on this box, since none runs here); built
`bin/01-build.sh`/`bin/02-install-service.sh` for reproducing this
deployment on a new system, added a `TP` (tensor-parallel-size) env
var defaulting to 1 after you asked about multi-GPU spanning (GB10 only
has 1 GPU; TP>1 is accepted but explicitly flagged as unvalidated by
this feature) — **caught and fixed a real bug in the same edit** (a
doubled `CPATH` path suffix that would have broken a fresh cold start;
the live running process was unaffected since it predated the bug, but
the regenerated file on disk was wrong until fixed); finally, did a
documentation-accuracy pass over the whole Task List/Acceptance
Criteria (found and fixed a stale Task 5.2 checkbox that contradicted
its own Progress notes; closed out ACC-001/006/007/008/009/010, which
were all already factually satisfied but never checked off).

**What's actually still open (the real remaining work on this
feature)**:

1. **ACC-003 / ACC-011 (the same underlying gap, twice)**: the OpenCode
   *agentic session* leg was only ever run against the now-superseded
   BF16 production service (Task 5.2, 2026-08-23). It has NOT been
   re-run against the current NVFP4+MTP 896K production service. This
   is the single most concrete "redo this against production" item
   left. Needs you, not automatable (same precedent as `feat-1`
   ACC-010).
2. **Your own `opencode.jsonc`** needs updating to the current model id
   `qwen3.8:27b-nvfp4-896k` if it isn't already — snippet is earlier in
   this Progress section (search "Current production OpenCode provider
   snippet").
3. **Thinking-mode control via OpenCode** was explained (this session)
   but not empirically verified end-to-end through an actual OpenCode
   client — worth a quick sanity check the first time you use it
   (confirm the request that hits the server actually carries
   `chat_template_kwargs`/`reasoning_effort` as expected, e.g. via the
   service's journal).
4. **Task 3.2** (optional FP8/quant weight eval) — explicitly left open
   by earlier user decision; effectively superseded/moot now that NVFP4
   is production, but never formally closed.
5. **MTP-at-long-context on a DIFFERENT context size or the 1M
   ceiling** was never tested (only 896K) — not needed unless the
   896K-vs-1M decision is revisited.
6. Everything else on the Task List / Acceptance Criteria is closed
   (Phases 0-6 all done; see the individual ACC-\* entries above for the
   detailed evidence behind each).

**Housekeeping**: this session's changes are NOT yet committed to git
(`git status` shows the README + the two new `bin/` scripts as
modified/untracked, plus some session-log markdown files). Nothing
was force-pushed or committed without being asked; a future session (or
you directly) should commit these when ready — see the repo's AGENTS.md
for the commit-only-when-asked policy this assistant follows.

### Recent Updates

#### 2026-08-24 (continued — Phase 6, Task 6.3 — MTP activated in production)

- User asked whether MTP speculative decoding was enabled and, after an
  explanation that it had been deliberately deferred (Task 6.1's MTP
  data was native-context-only, never tested combined with YaRN),
  requested it be tested now.
- Method: maintenance window, ad-hoc MTP+YaRN-896K instance (production
  896K script + `--speculative-config '{"method":"mtp","num_speculative_tokens":5}'`), then a same-context non-MTP instance for a true
  apples-to-apples comparison at the actual production context (not
  just reusing Task 6.1's native-context numbers).
- Results: KV-cache capacity 1,073,277 → 984,829 tokens (margin 1.17x →
  1.07x, still clears 917,504); pool free 40.1% → ~39% (still clears
  the 15% policy floor); byte-identical greedy output vs. non-MTP
  (lossless); tool-calling/thinking-modes unaffected; decode throughput
  **2.66x (thinking) / 3.12x (no-thinking) faster** with MTP at this
  exact 896K/YaRN context (11.27 tok/s → 29.93/35.17 tok/s), closely
  matching Task 6.1's native-context finding (2.77x/3.04x).
- Decision: adopt MTP into production. Promoted directly into
  `qwen3.8-27b-nvfp4-896k.sh` (same served-model-name
  `qwen3.8:27b-nvfp4-896k`, no OpenCode config change needed); preserved
  the pre-MTP script as `qwen3.8-27b-nvfp4-896k-no-mtp.sh` for rollback.
- Restarted the production systemd service with the updated script;
  re-verified `/v1/models`, KV-cache capacity/headroom, coherent output,
  and tool-calling against the live service.
- Next: none blocking — the OpenCode-agentic-session leg of ACC-003 and
  updating the user's own `opencode.jsonc` remain open follow-ups from
  Task 6.2, unaffected by this change (same model id/context).

#### 2026-08-24 (Phase 6, Task 6.2 steps 6-7 — production cutover, Phase 6 COMPLETE)

- Completed: Task 6.2 steps 6-7, closing out Phase 6. User's quality
  verdict (step 6, via OpenCode against the NVFP4 1M candidate service
  left running from the prior session): "NVFP4 quality is fine, adopt
  it." Separately, the user decided production context should be
  **896K, not 1M** ("the ctx is large enough with that size").
- Decision (step 7): **adopt NVFP4 as production, replacing BF16, at
  896K context** — not the 1M the candidate service was built at.
- Executed the cutover live on `dgx`:
  1. Verified live state first (both services' `systemctl --user is-active`, `nvidia-smi`, `free -h`) before touching anything, per the
     prior session's handoff caution.
  2. Stopped `qwen3.8-27b-nvfp4-1m.service` (retired, left disabled/
     on-disk as a fallback).
  3. Created `/home/admin/scripts/qwen3.8-27b-nvfp4-896k.sh` and
     `/home/admin/.config/systemd/user/qwen3.8-27b-nvfp4-896k.service`
     — derived from the validated 1M script (same
     `VLLM_DISABLE_COMPILE_CACHE=1` fix, deliberately no
     `--linear-backend` pin per step 5's finding), 896K params matching
     the existing BF16 896K script's KV-cache sizing exactly (33 GiB,
     YaRN factor 3.5).
  4. First two start attempts FAILED: `ValueError: Free memory on device cuda:0 (65.5-65.7/119.63 GiB)... less than desired GPU memory utilization`. Root cause: a **resident Ollama-served model**
     (`qwen3.8:27b-q8_0`, 46 GB, via the always-restarting `ollama`
     Docker container) was loaded and holding the pool — left over from
     unrelated testing, not something this feature's services caused.
     Fixed with `docker exec ollama ollama stop qwen3.8:27b-q8_0`
     (unloads the model without stopping the container) — pool returned
     to a clean ~114 GiB available baseline.
  5. Third start succeeded (~3m45s cold start): `/v1/models` confirmed
     `qwen3.8:27b-nvfp4-896k` / `max_model_len: 917504`; memory measured
     at ~40.1% pool free, matching Task 6.2 step 4's table exactly.
  6. Re-ran the full smoke-test suite (coherent output, clean
     `get_weather("Paris")` tool-call, all three ACC-003 thinking-control
     modes on the 17×24=408 prompt) — all passed.
- Updated ACC-002 (896K reconfirmed as final despite NVFP4 clearing 1M),
  ACC-003 (curl leg re-verified against NVFP4 896K; OpenCode-agentic
  leg still only done against the now-superseded BF16 service — flagged
  open), and ACC-004 (superseded — NVFP4 is now the empirically-justified
  quantized production precision, satisfying REQ-005's bar).
- Recorded a new open operational caveat: the Ollama/vLLM unified-pool
  coexistence risk found above has no guard/quota — an Ollama model load
  during normal operation could still pressure the production service's
  thin headroom (40.1% at 896K), even though it won't crash an
  already-running vLLM engine outright (only blocks fresh cold starts).
- `qwen3.8-27b-nvfp4-1m.service`/`.sh` and `qwen3.8-27b-vllm.service`/
  `.sh` (BF16) are both retained on disk, disabled, as documented
  fallback paths.
- Next: update the user's own `opencode.jsonc` to the new
  `qwen3.8:27b-nvfp4-896k` model id (snippet in the resolved SESSION
  HANDOFF section of Progress); optionally re-run the OpenCode-agentic
  leg of ACC-003 against the new production service (open, not
  blocking); MTP-at-long-context remains an unscoped future follow-up.

#### 2026-08-23 (continued — Phase 6, Task 6.2 step 5)

- Completed: Task 6.2 step 5 — built and validated a production-
  candidate NVFP4+YaRN systemd deployment at the 1M native ceiling
  (chosen over 768K/896K since it clears the safety-margin policy with
  the most headroom AND is the model's full context ceiling).
- Created `/home/admin/scripts/qwen3.8-27b-nvfp4-1m.sh` and
  `/home/admin/.config/systemd/user/qwen3.8-27b-nvfp4-1m.service`
  (mirroring the BF16 `qwen3.8-27b-vllm.service` pattern: `--user`
  unit, disabled/no-autostart, reusing existing lingering).
- Found and fixed a NEW environment gap while bringing this up as a
  systemd service: vLLM's NVFP4/FP8 kernel auto-selection is not
  stable run-to-run on this box, and a run that auto-selects a
  different kernel than a prior run against the same model directory
  can load a stale, incompatible `torch.compile` AOT cache artifact
  and crash-loop. An explicit `--linear-backend flashinfer_cutlass`
  pin was tried first but broke a DIFFERENT kernel choice (FP8 W8A8
  for attention/lm_head). **Fix: `VLLM_DISABLE_COMPILE_CACHE=1`**,
  forcing a fresh compile every launch — now baked into the script.
- With the fix, the service started cleanly and passed full
  re-verification: KV cache 1,209,295 tokens (1.15x margin, matching
  step 4 exactly), 39.0% pool free, `/v1/models` reports
  `qwen3.8:27b-nvfp4-1m` / `max_model_len: 1048576`. Coherent output,
  clean tool-call, and all three thinking-control modes all passed
  (correct 17×24=408 answer throughout, correctly-scaled reasoning
  length).
- Service left running (not stopped) so OpenCode can be pointed at it
  directly. Produced an OpenCode provider snippet (mirroring Task
  5.1's) for the user to add alongside the existing BF16 entry.
- Next (user-driven): Task 6.2 step 6 — run the same coding-task
  examples used for Task 5.2 against this NVFP4 endpoint via OpenCode
  and report a quality assessment vs. BF16 (this is the REQ-005
  quality-impact check, and is inherently the user's own judgment call,
  same as Task 5.2/feat-1's ACC-010 precedent). Step 7 (final
  adopt/keep-BF16 decision) follows once step 6's verdict is in.

#### 2026-08-23 (continued — Phase 6, Task 6.2 step 4)

- Completed: Task 6.2 step 4 — YaRN long-context capacity step-up
  against the NVFP4 checkpoint, in a maintenance window (production
  BF16 service stopped for the duration, per user instruction not
  restored afterward).
- Created `/home/admin/scripts/qwen3.8-27b-nvfp4-yarn-vllm.sh`, a
  parameterized (`CTX=768k|896k|1m`) launch script applying the same
  YaRN `rope_parameters` override shape (REQ-011) used for BF16 to the
  NVFP4 checkpoint's `text_config`, reusing the same per-context
  `--kv-cache-memory-bytes` values as the BF16 `launch-phase2-*-fp8kv.sh`
  scripts.
- Stepped through 768K → 896K → 1M (one instance at a time, stop
  between each — the pool cannot hold two instances concurrently):
  KV-cache token capacity/concurrency margins at every size were
  **identical** to the BF16 measurements (974,864 / 1,073,277 /
  1,209,295 tokens, 1.24x/1.17x/1.15x) — confirms KV-cache sizing is
  architecture-driven, not precision-driven.
- **Result: all three sizes PASS the safety-margin policy** (43.1% /
  40.1% / 36.2% free respectively) — most notably, **NVFP4 clears the
  full 1M native ceiling that BF16 failed** (BF16: 12.9% free at 1M,
  below the 15% floor; NVFP4: 36.2% free, comfortably above it),
  confirming the Design Notes' hypothesis that NVFP4's ~33 GB smaller
  resident weight footprint (21.59 GiB vs. BF16's ~55.99 GiB) is
  enough to absorb the difference.
- Smoke-tested (coherent output, clean tool-call, all three
  ACC-003-style thinking-control modes) at all three sizes — all
  passed, correct answers throughout.
- Cleanup: all three test instances shut down cleanly; GB10 back to a
  clean baseline (0 GPU processes, ~114 GiB available). **BF16
  production service intentionally left stopped** (not restarted) per
  the maintenance-window instruction — one-line restart when needed.
- Next: Task 6.2 steps 5-7 — production-equivalent re-verification at
  a chosen NVFP4 context (1M is the natural candidate), the REQ-005
  quality-impact check (BF16 vs. NVFP4 on Task 5.2's coding examples),
  and the final adopt/keep-BF16 decision. Full detail in the
  SESSION HANDOFF block above.

#### 2026-08-23 (continued — Phase 4, Task 4.3 — Phase 4 COMPLETE)

- Completed: Task 4.3 — final task of Phase 4. Built a real
  899,067-token prompt with the model's own tokenizer
  (`build_prompt_896k.py`, same technique as Task 2.1's 768K test) and
  POSTed it to the live, already-running production
  `qwen3.8-27b-vllm.service` (not a fresh ad-hoc launch — reused the
  service left running after Task 4.2).
- Result: **HTTP 200, no OOM.** `usage.total_tokens: 899,117`
  (899,067 prompt + 50 completion), well within the 917,504
  max-model-len (~18.4K tokens headroom, matching the margin design
  from Task 2.1/2.2). Wall time 3582s (~59.7 min) — proportionally
  consistent with 768K's 45 min (Task 2.1, FP8 KV cache) for ~17% more
  context.
- Verified post-request: service still `active (running)`, no
  errors/OOM-kills in the journal, `free -h` showed ~18 GiB
  available — consistent with Task 2.3's measured 896K headroom
  (19.28 GiB), i.e. no memory degradation from repeated use.
- Found and flagged honestly (not swept under the rug): the test
  payload used a top-level `enable_thinking: false` JSON field (copied
  from Task 2.1's older payload shape) instead of the correct
  `chat_template_kwargs: {"enable_thinking": false}` form established
  in Task 1.2/4.2 — this did NOT suppress thinking, so the response hit
  `finish_reason: "length"` with a truncated `reasoning` field and
  `content: null` (the intentionally tiny `max_tokens: 50` ran out
  mid-thought). This is a test-payload artifact, not a service defect
  — Task 4.2 already separately confirmed the correct parameter form
  works on this exact service — and does not affect Task 4.3's actual
  pass/fail criterion (completes without OOM).
- **Phase 4 (Tasks 4.1-4.3) is now fully COMPLETE.** Qwen3.8-27B is
  live in production on the GB10 as a systemd `--user` service at 896K
  context, validated end-to-end with a real filled-context request.
- Next: Phase 5 (Task 5.1) — connect OpenWebUI/OpenCode to the running
  endpoint.

#### 2026-08-23 (continued — Phase 4, Task 4.2)

- Completed: Task 4.2 — started the newly-installed
  `qwen3.8-27b-vllm.service` (`systemctl --user start`) and ran curl
  smoke tests against it.
- Cold load took ~7m43s (18:02:58 → 18:10:41 UTC to
  `Application startup complete`), consistent with Phase 2's timing
  for this same 896K config — much faster than the 36-45 min figures
  from Task 2.1, which were full-context prompt processing time, not
  startup time.
- Confirmed via `/v1/models`: `max_model_len: 917504` (896K), serving
  from the production systemd unit rather than an ad-hoc launch.
- Smoke tests (mirroring Task 1.2's shape, same checks, now against
  the production service): coherent non-degenerate Python output;
  clean `get_weather("Paris")` tool-call
  (`finish_reason: "tool_calls"`); all 3 of ACC-003's exact
  thinking-control modes on a 17×24 prompt (correct answer=408 every
  time) — `enable_thinking: false` (no reasoning field),
  `reasoning_effort: medium` (44-char reasoning),
  `reasoning_effort: xhigh` (161-char reasoning, correctly more
  elaborate than medium). All HTTP 200, all correct.
- Verified service stayed healthy post-test: `active (running)`, no
  errors/warnings in the journal, `free -h` showed ~19 GiB
  available — consistent with Task 2.3's measured 896K headroom
  (19.28 GiB).
- Left the service running (did not stop it) so Task 4.3 can reuse it
  directly for the real filled-context request.
- Next: Task 4.3 — real filled-context (896K-token) end-to-end request
  against the now-running production service, using the same
  tokenizer-built-real-prompt approach as Task 2.1's 768K test.

#### 2026-08-23 (continued — Phase 4, Task 4.1)

- Completed: Task 4.1 — installed vLLM + Qwen3.8-27B as a systemd
  `--user` service on the GB10, following `feat-2`'s pattern (lingering
  - unit NOT enabled, so it survives logout without autostarting at
    boot).
- Created `/home/admin/scripts/qwen3.8-27b-vllm-896k.sh` — a production
  copy of `/home/admin/launch-phase2-896k-fp8kv.sh` (896K/YaRN-3.5/BF16
  weights/FP8-KV-cache), flags unchanged from the already-tested Phase
  2 script, only header comments added.
- Created `/home/admin/.config/systemd/user/qwen3.8-27b-vllm.service`
  (`ExecStart=` the script above, `Restart=on-failure`,
  `TimeoutStartSec=4200`, `LimitNOFILE=1048576`).
- Enabled lingering for `admin` (`loginctl enable-linger`, succeeded
  without sudo); installed the unit (`systemctl --user daemon-reload`)
  and confirmed it is `loaded`/`disabled`/`inactive` — ready to start
  (Task 4.2) but will not autostart at boot.
- Skipped the `feat-2`-style video/render group defense-in-depth step —
  not needed (`/dev/nvidia*` already world-writable on this box) and
  non-interactive sudo is unavailable here anyway.
- Verified GB10 stayed clean throughout (port 8000 free, 0 GPU compute
  processes, ~100 GiB free / 114 GiB available).
- Next: Task 4.2 — `systemctl --user start`, then curl smoke test
  (tool-calls + all three thinking-control modes) against the live
  production service.

#### 2026-08-23 (continued — Phase 3, Task 3.1)

- Completed: Task 3.1 — confirmed BF16 as the production model *weight*
  precision, via a live shell on the GB10 (session has direct access to
  `dgx`). No new serving run was needed: inspected the existing 896K
  launch script (`/home/admin/launch-phase2-896k-fp8kv.sh`, no
  `--dtype`/`--quantization` flag, only `--kv-cache-dtype fp8` which is
  KV-cache-only), the model's `config.json` (no `quantization_config`
  key), and the on-disk safetensors total (55.56 GB, matching BF16 for
  ~27B params). GB10 confirmed idle/clean at check time (0 GPU
  processes, ~100-114 GiB free).
- Closed: REQ-005/ACC-004 and Task 3.1.
- Left open (by user decision): Task 3.2 (optional FP8/quant weight
  eval) — not decided now, to be revisited explicitly in a later pass
  (e.g. once Phase 4 throughput data exists) rather than closed
  silently.
- Next: Phase 4 (Task 4.1) — install vLLM + Qwen3.8-27B as a systemd
  service using the 896K production config (derive from
  `/home/admin/launch-phase2-896k-fp8kv.sh`).

#### 2026-08-23 (continued — Phase 2)

- Completed: Phase 2 (Tasks 2.1-2.3), run directly on the GB10 (this
  session had a live shell on `dgx` itself, not remote).
- Found and fixed: default `VLLM_ENGINE_READY_TIMEOUT_S=600` was too
  short for a 786,432 max-model-len launch on this box (weight load +
  KV-cache profiling/compile exceeded it, killing the engine core with
  a false-timeout on the first 768K attempt) — fixed with
  `VLLM_ENGINE_READY_TIMEOUT_S=3600`, now required for every Phase 2+
  launch.
- Found and fixed: `--gpu-memory-utilization 0.92` (the vLLM default,
  reused from `feat-1`/`feat-2`) leaves the GB10's OS with almost no
  memory at 768K — measured ~1.7-3.5 GiB free system-wide (KV cache
  820,013-token capacity vs. 786,432 needed, only 1.04x margin) — vs. a
  ~17.9 GiB policy floor. Fixed with `--kv-cache-dtype fp8` (KV cache
  precision only, BF16 weights unaffected -- REQ-005 untouched) plus an
  explicit, right-sized `--kv-cache-memory-bytes` instead of letting
  `gpu_memory_utilization` auto-consume the whole budget.
- Verified end-to-end (not just at load time): built a REAL
  768,567-token prompt with the model's own tokenizer and POSTed it to
  `/v1/chat/completions` -- twice (BF16 KV cache: HTTP 200, ~36 min;
  FP8 KV cache: HTTP 200, ~45 min) -- both succeeded with no OOM.
- Stepped up 768K -> 896K -> 1M (FP8 KV cache, load-time capacity checks
  at each step): 768K passed comfortably (19.8% free), 896K passed
  narrowly (16.1% free, ~1.1pp above the 15% floor), 1M failed (12.9%
  free). Per the safety-margin policy, stopped at 896K.
- Decision: **896K (YaRN factor 3.5) is the chosen production context**
  (REQ-003/ACC-002), not the full 1M ceiling and not just the 768K
  floor -- with 19.28 GiB (16.1%) of the GB10's unified pool remaining
  free at that context (REQ-010/Task 2.3). No meaningful coexistence
  headroom remains at 896K; if more headroom is ever needed later, 768K
  (23.73 GiB / 19.8% free) is the documented, more conservative
  fallback.
- Cleanup: all three test vLLM instances (768K BF16-KV, 768K FP8-KV,
  896K, 1M) were shut down cleanly after their measurements; GB10
  confirmed back to a clean baseline (0 GPU processes, ~101-115 GiB
  free depending on page-cache state) after each and at session end.
- Next: Phase 3 (Task 3.1) -- confirm BF16 as the production model
  *weight* precision (expected outcome, unaffected by the FP8 KV-cache
  decision above, which is a separate axis).

#### 2026-08-23

- Completed: Phase 1 (Tasks 1.1–1.3), fully unblocked — the Ollama
  memory-contention blocker from 2026-08-22 was already gone at session
  start (confirmed via `nvidia-smi`/`free -h`: 0 GPU processes, ~114 GiB
  free); no unload step was needed this time.
- Completed: Brought up vLLM 0.27.1 serving Qwen3.8-27B at native
  context (`--max-model-len 32768`, no YaRN). Hit and fixed two new,
  non-root-fixable environment gaps along the way: missing `Python.h`
  (fixed via `uv python install 3.12` + `CPATH`, no sudo) and an
  unreachable `ninja` binary (fixed via `PATH` including the venv's
  `bin/`). Full details and the final working launch command are in
  Task 1.1.
- Completed: Smoke-tested correctness (coherent non-degenerate output),
  tool-calling (`--enable-auto-tool-choice --tool-call-parser qwen3_xml`, verified against the model's own chat template format),
  and all three thinking-control modes from ACC-003
  (`enable_thinking: false`, `reasoning_effort: low/medium/xhigh` with
  `--reasoning-parser qwen3`) — all passed. Details in Task 1.2.
- Decision: vLLM confirmed as the deployment engine (REQ-006/ACC-005) —
  no SGLang fallback spike needed, unlike what Task 1.3 left open as a
  contingency. Task 1.3.
- Observation (non-blocking): generation throughput was low (~4.6
  tokens/s) in this small-context/no-batching/no-prefix-caching smoke
  test — flagged for a closer look during Phase 2/4, not a blocker for
  Phase 1's correctness goal.
- Cleanup: shut the Phase 1 test vLLM instance down cleanly; GB10 GPU/
  unified pool confirmed back to a clean baseline (0 processes) before
  ending the session.
- Next: Phase 2 (Task 2.1) — apply the YaRN `rope_parameters` override
  targeting 768K context and measure unified-pool memory/KV-cache
  headroom, carrying forward Task 1.1's `CPATH`/`PATH` fixes and Task
  1.3's tool/reasoning-parser flags into the launch command.

#### 2026-08-22

- Completed: Feature scoped and drafted, following the `feat-2` structure
  and template. Key decisions captured from the preceding chat session
  (production-serving goal, 768K floor with stretch to 1M, vLLM as
  primary engine, BF16-first precision, vision/video explicitly out of
  scope).
- Completed (later this date): Target hardware changed per user decision
  from "Dell 7960T, no new hardware, DGX Spark excluded" to "Dell GB10
  (DGX Spark clone)". This flips several things: the deployment is now
  on a NEW arm64 box (Phase 0 is real setup, not confirmation), the
  "can we share GPUs with feat-1/feat-2" question is replaced by a
  "unified-pool headroom" question (REQ-010/Task 2.3), and a new risk
  class is added (arm64/SM121 vLLM build support — REQ-006/Task 0.2).
  REQ-001/REQ-002, ACC-001/002/009, Scope, Dependencies, Design Notes,
  and the Task List were all re-pointed accordingly.
- Next: Phase 1 — bring up Qwen3.8-27B on vLLM 0.27.1 (venv
  `/home/admin/venvs/vllm`) at native context. BLOCKED on unloading the
  resident Ollama model first (see Current Status) — must start from a
  session not served by Ollama. Ready-to-run commands are in Task 1.1.
- Notes: Latest `main` commit on `Qwen/Qwen3.8-27B` at feature-creation
  time was `1d4bf0f` (README-only); actual weights are unchanged since
  the initial upload (`72a217a`/`6714f56`).
- Done later this date: ran `bin/00-check-env.sh` on `dgx` itself —
  confirmed GB10 (Dell "Pro Max with GB10 FCM1253", aarch64, Ubuntu
  24.04.4, driver 580.173.02, CUDA 13.0.88, 1.9 TB NVMe, 128 GB unified
  pool). vLLM 0.27.1 (aarch64, venv `/home/admin/venvs/vllm`) installed
  and passes both the platform check and the `qwen3_5` ModelRegistry
  check including `mrope_interleaved`. HF commit pinned to
  `1d4bf0f2ff6012fd82039f2fa52739d0dd7c60c0`; weight download to
  `/home/admin/models/qwen3.8-27b` COMPLETED (55.6 GB, 18 shards +
  configs). Phase 0 closed out; Phase 1 blocked on the existing Ollama
  stack holding ~65 GB of the unified pool (see Current Status /
  Blocker as of that date — resolved 2026-08-23, see that date's
  entries above).

### Decisions Made

- **2026-08-22**: Feature goal is production serving (systemd service +
  OpenCode/OpenWebUI wiring + quality comparison), not just an evaluation
  spike — matching the bar set by `feat-1`/`feat-2`.
- **2026-08-22**: Context target is a 768K floor, not a hard ceiling —
  push higher (up to the model's 1M native max) if the unified-memory
  safety margin allows, rather than stopping at 768K by default.
- **2026-08-22**: This feature is independent of `feat-1`/`feat-2` and
  does NOT share a box with them (they stay on the Dell 7960T);
  the question of what (if anything) else runs alongside Qwen3.8-27B is
  about this box's own unified-pool headroom, to be confirmed empirically
  (Task 2.3), not assumed.
- **2026-08-22 (user decision)**: Target hardware changed to **Dell GB10
  (DGX Spark clone)** — a single SoC, 128GB unified LPDDR5x memory
  shared between CPU and GPU (arm64, SM121), replacing the "existing
  Dell 7960T only" constraint from the original plan. Consequences:
  (a) Phase 0 becomes real environment setup on a new arm64 machine,
  nothing is inherited from `feat-1`/`feat-2`'s x86 box; (b) the vLLM
  build must be an arm64/GB10-compatible one — new risk, checked in
  Task 0.2, NOT assumed; (c) single unified memory pool means no
  multi-GPU placement and no separate CPU-RAM fallback for the KV cache,
  so the 768K context floor is a genuine capability question that Task
  2.x must measure, not assume.
- **2026-08-22**: vLLM is the starting engine (matches the vendor's
  documented YaRN path and `feat-1`'s default), with a lightweight
  native-context smoke test (Phase 1) as insurance before the YaRN
  work. On the GB10 the risk profile differs from `feat-1`/`feat-2`: the
  relevant unvalidated variables are the arm64/SM121 build AND the
  `qwen3_5` Gated DeltaNet architecture, not the SM120
  DSA/sparse-MLA bug that hit `feat-1`/`feat-2`
  (`vllm-project/vllm#52938`) — which likely cannot recur on a box with
  no SM120 GPUs.
- **2026-08-22**: Vision-language (image/video) capability is explicitly
  out of scope for this feature — text/coding use only.
- **2026-08-22**: Full BF16 precision is the default target (the model
  fits VRAM comfortably); quantization is opportunistic, adopted only if
  empirically justified — NOT a forced compromise like `feat-2`'s GLM-5.2
  quant decision.
- **2026-08-22**: Ollama/llama.cpp (GGUF) was explicitly ruled out as the
  serving path for this feature — the vendor only documents the YaRN
  long-context extension for vLLM/SGLang/TokenSpeed, and Qwen3.8-27B's
  non-standard hybrid/partial-rotary rotary setup makes an unofficial
  llama.cpp YaRN override judged too high-risk versus the officially
  validated frameworks.
- **2026-08-23**: vLLM 0.27.1 confirmed as the deployment engine
  (REQ-006/ACC-005) after Phase 1's native-context smoke test passed
  cleanly (coherent output, tool-calling, all three thinking-control
  modes) — no SGLang fallback spike required.
- **2026-08-23**: Missing system packages needed by vLLM's runtime
  JIT/compile path (`python3.12-dev` for `Python.h`, needed by Triton's
  architecture-inspection step; `ninja`, needed by `torch.compile`) are
  worked around WITHOUT sudo/root — `uv python install 3.12` provides a
  standalone-build `Python.h` (exposed via `CPATH`), and `ninja` (already
  a venv pip dependency) is exposed via `PATH` including the venv's
  `bin/`. Chosen over asking for `apt-get install python3.12-dev`
  because sudo is not available non-interactively in this environment;
  matching the venv's Python 3.12.x minor version for the `uv`-installed
  headers avoids any C-API ABI mismatch risk. This is now a required
  step in every vLLM launch command for this feature (Phase 2 onward),
  not a one-time fix.
- **2026-08-23**: `VLLM_ENGINE_READY_TIMEOUT_S` must be raised from
  vLLM's 600s default to 3600 for any Phase 2+ launch on this box —
  the 786,432+ max-model-len engine-core startup (weight load without
  auto-prefetch + KV-cache profiling/compile) exceeds 600s and the
  APIServer kills the engine core as a false-timeout otherwise. Task
  1.1's native-context (32768) launch never hit this because it
  profiled fast enough to clear the 600s default. This is now a
  required env var for every Phase 2/4 launch command for this feature.
- **2026-08-23**: `--gpu-memory-utilization` (vLLM's default KV-cache
  sizing mechanism, reused as-is from `feat-1`/`feat-2`) is UNSAFE on
  the GB10's unified pool at 768K+ context — it sizes vLLM's total
  footprint as a fixed fraction of the WHOLE pool regardless of the
  resulting KV-cache token capacity, which starves the OS itself
  (measured ~1.7-3.5 GiB system-wide free at util=0.92/768K, against a
  ~17.9 GiB safety-margin-policy floor). **`--kv-cache-dtype fp8` with
  an explicit, right-sized `--kv-cache-memory-bytes` is required for
  production on this box instead** — this only changes KV-cache
  precision (model weights stay BF16, REQ-005 unaffected) and gives
  direct, measured control over how much of the pool is actually
  reserved, leaving the rest as real OS headroom. Empirically verified
  via two full real-768K-token-prompt end-to-end requests (BF16 KV:
  36 min; FP8 KV: 45 min; both HTTP 200, no OOM).
- **2026-08-23**: **896K (YaRN factor 3.5) chosen as the production
  context** for REQ-003/ACC-002, not the 768K floor and not the 1M
  ceiling — measured step-up (FP8 KV cache): 768K = 19.8% free (PASS),
  896K = 16.1% free (PASS, narrowly — only ~1.1pp above the adopted 15%
  policy floor), 1M = 12.9% free (FAIL). Per the adopted safety-margin
  policy (>=15% free or >=10 GiB, whichever greater — the 15% floor is
  the binding one here), the step-up correctly stops at 896K. At 896K,
  19.28 GiB (16.1%) of the GB10's 119.63 GiB unified pool remains free
  — answering REQ-010, the GB10 effectively owns its pool at this
  context; the 768K step (23.73 GiB / 19.8% free) remains documented as
  a more conservative fallback if headroom needs ever outweigh the
  extra 896K-768K=131,072 tokens of context in the future.
- **2026-08-23**: Tool-call parser `qwen3_xml` and reasoning parser
  `qwen3` are the correct vLLM flags for Qwen3.8-27B's `qwen3_5`
  architecture — determined by inspecting the model's own
  `chat_template.jinja` (XML-style `<tool_call><function=...>` format)
  and vLLM's `vllm.reasoning`/`vllm.tool_parsers` registries, not
  assumed from the model name alone (there is no plain `qwen3` tool-call
  parser; `qwen3_xml`/`qwen3_coder` both map to the same underlying
  `qwen3_engine_tool_parser`, and `qwen3_xml` matches this non-coder
  model's chat template). These flags are required for ACC-003 and must
  be carried into the Phase 4 systemd unit.
- **2026-08-23**: **BF16 confirmed as the production model weight
  precision** (REQ-005/ACC-004/Task 3.1) — verified via a live shell on
  the GB10: the 896K production launch script sets no
  `--dtype`/`--quantization` flag (only `--kv-cache-dtype fp8`, a
  KV-cache-only setting from Task 2.1), the model's `config.json` has
  no `quantization_config`, and the checkpoint's total safetensors size
  (55.56 GB) matches BF16 for ~27B params. Task 3.2 (optional FP8/quant
  weight eval) is left open/not-started by explicit user decision,
  rather than closed now, to be revisited later (e.g. after Phase 4
  throughput data).
- **2026-08-23**: **Qwen3.8-27B installed as a systemd `--user` service**
  (Task 4.1) on the GB10, mirroring `feat-2`'s "lingering enabled + unit
  NOT enabled" pattern rather than a system-wide unit — no GB10-specific
  reason emerged to deviate. `loginctl enable-linger` succeeded without
  sudo (same sudo-free posture as every other environment fix on this
  feature). The `feat-2`-style video/render group defense-in-depth step
  was explicitly skipped: `/dev/nvidia*` is already world-writable on
  this box (same condition that made it non-essential on `feat-2`'s
  box), and non-interactive sudo isn't available here to add it anyway.
- **2026-08-23**: **Task 4.2 curl smoke tests all passed against the
  live production `qwen3.8-27b-vllm.service`** (896K context,
  confirmed via `/v1/models`) — coherent output, clean tool-call, and
  all 3 of ACC-003's exact thinking-control modes
  (`enable_thinking: false`/`reasoning_effort: medium`/`reasoning_effort: xhigh`) gave the correct 17×24=408 answer with correctly-scaled
  reasoning length. Cold load measured at ~7m43s, matching Phase 2's
  timing for this exact config — confirms the 36-45 min figures from
  Task 2.1 were full-context prompt processing time, not startup
  latency. Service intentionally left running for Task 4.3 to reuse.
  ACC-003's curl leg is done; its OpenCode-agentic-session leg is
  deferred to Phase 5.
- **2026-08-23**: **Task 4.3 passed — real 899,067-token filled-context
  request against the production `qwen3.8-27b-vllm.service` completed
  with HTTP 200 and no OOM** (`usage.total_tokens: 899,117`, ~18.4K
  headroom under the 917,504 max-model-len), 3582s wall time. Service
  confirmed healthy afterward (no degradation from Task 2.3's measured
  headroom). A test-payload artifact (wrong `enable_thinking` field
  shape, truncated reasoning in the response) was found and recorded
  honestly but does not affect the OOM-free pass/fail bar Task 4.3
  actually measures. **Phase 4 (Tasks 4.1-4.3) is now fully COMPLETE**
  — Qwen3.8-27B is live in production on the GB10 at 896K context.
- **2026-08-23**: **NVFP4 clears the full 1M native-ceiling context
  (Task 6.2 step 4)** — the same 768K→896K→1M YaRN capacity step-up
  methodology from Task 2.1-2.3, re-run against the NVFP4 checkpoint,
  passes at all three sizes (43.1% / 40.1% / 36.2% free), including 1M
  where BF16 failed (12.9% free, below the 15% floor). KV-cache token
  capacity is identical to BF16's at every size, confirming the
  headroom gain comes entirely from NVFP4's smaller resident weight
  footprint (~21.6 GiB vs. BF16's ~56 GiB). This does not by itself
  decide NVFP4 adoption (Task 6.2 steps 5-7, especially the REQ-005
  quality-impact check, remain open) but establishes 1M as NVFP4's
  natural production-context candidate if quality clears the bar. Per
  explicit instruction, the BF16 production service was stopped for
  this maintenance-window test and intentionally left stopped
  afterward (not restored) — restart is a one-line `systemctl --user start qwen3.8-27b-vllm.service` whenever normal production serving
  needs to resume.
- **2026-08-23**: **`VLLM_DISABLE_COMPILE_CACHE=1` is required for any
  NVFP4 systemd deployment of `Qwen/Qwen3.8-27B-NVFP4` on this box**
  (Task 6.2 step 5) — vLLM's NVFP4/FP8 kernel auto-selection is not
  stable run-to-run (observed switching between `CutlassNvFp4LinearKernel` and `FlashInferCutlassNvFp4LinearKernel`
  across otherwise-identical launches against the same model
  directory), and the on-disk `torch.compile` AOT cache does not key on
  which kernel was selected — a run that auto-selects a different
  kernel than a cached compile can crash-loop with an `AttributeError`
  on a missing op. An explicit `--linear-backend flashinfer_cutlass`
  pin was tried and rejected: it broke the checkpoint's SEPARATE FP8
  W8A8 kernel selection (used for attention/lm_head/last-8-layers-MLP),
  since `--linear-backend` applies across this checkpoint's mixed
  NVFP4+FP8 quantization scheme rather than to NVFP4 GEMM alone.
  Disabling the compile cache instead forces a fresh, self-consistent
  compile every launch (slightly longer cold start, no AOT-artifact
  reuse) and is now baked into
  `/home/admin/scripts/qwen3.8-27b-nvfp4-1m.sh`.
- **2026-08-23**: **Built and validated
  `qwen3.8-27b-nvfp4-1m.service`** (Task 6.2 step 5) — a production-
  candidate NVFP4+YaRN systemd deployment at the 1M native ceiling,
  mirroring the BF16 `qwen3.8-27b-vllm.service` pattern (`--user` unit,
  disabled/no-autostart). Passed the full re-verification: KV cache
  1,209,295 tokens (1.15x margin, matches step 4's measurement
  exactly), 39.0% pool free, coherent output, clean tool-call, all
  three thinking-control modes correct. Left running (not stopped) so
  OpenCode can be pointed at it for Task 6.2 step 6 (the REQ-005
  quality-impact check) — explicitly a user-judgment task, not
  automatable, per feat-1 ACC-010's "user's own existing coding-task
  examples" precedent. The BF16 and NVFP4 services cannot run
  simultaneously (shared port 8000, unified-pool constraint) — exactly
  one should be active at a time.
- **2026-08-24**: **NVFP4 adopted as the production precision,
  replacing BF16** (Task 6.2 steps 6-7, REQ-005/ACC-004) — the user's
  own coding-task quality check via OpenCode against the NVFP4
  candidate returned "quality is fine, adopt it," clearing REQ-005's
  bar for adopting a quantized variant over BF16 by default, backed by
  Task 6.1's already-measured 2.54x-7.7x decode speedup. BF16 is kept
  on disk, disabled, as a documented fallback rather than deleted.
- **2026-08-24**: **Production context stays at 896K, not the 1M
  ceiling**, even though NVFP4 clears 1M with more headroom (36.2%
  free) than BF16 ever cleared 896K (16.1% free) — independent user
  decision after testing ("the ctx is large enough with that size").
  This meant retiring the already-built 1M NVFP4 candidate service
  rather than promoting it, and building a new 896K NVFP4 production
  service instead (`qwen3.8-27b-nvfp4-896k.service`).
- **2026-08-24**: **Discovered a real Ollama/vLLM unified-pool
  coexistence risk beyond what earlier capacity-testing sessions
  accounted for**: a resident Ollama-served model can silently persist
  across sessions (Docker `--restart always`, model held loaded via the
  Ollama API) and block a fresh vLLM engine's startup free-memory check
  even when no vLLM instance was previously running. Fixed operationally
  (`docker exec ollama ollama stop <model>`) but not solved
  structurally — no guard/quota prevents an Ollama load during normal
  operation from pressuring the production vLLM service's already-thin
  headroom (40.1% free at 896K). Recorded as an open operational
  caveat, not a task.
- **2026-08-24**: **MTP speculative decoding activated in production**
  (Task 6.3, same-day follow-up) — previously deferred out of the
  initial NVFP4 896K cutover because Task 6.1's MTP benchmarks were
  only ever run at native 262144 context, never combined with YaRN.
  Tested and adopted after clearing all three bars: capacity (KV-cache
  margin drops from 1.17x to 1.07x but stays >1.0x, pool free ~39%,
  still above the 15% policy floor), correctness (byte-identical greedy
  output vs. non-MTP at the same context), and throughput (2.66x/3.12x
  decode speedup at 896K/YaRN, matching Task 6.1's native-context
  finding). Promoted into the same production script/service (no model
  id change); the pre-MTP script is kept as a rollback path.

### Related PRs / Commits

- [Issue #3](https://github.com/dfch/biz.dfch.LlmOps/issues/3): On-prem
  Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI —
  description mirrors this README's Overview section. (Issue #2 was an
  accidental duplicate, created moments earlier with identical title/
  body — closed in favor of #3.)
