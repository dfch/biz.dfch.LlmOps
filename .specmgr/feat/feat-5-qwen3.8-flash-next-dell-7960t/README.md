---
created: 2026-08-27
github_issue: 5
id: feat-5-qwen3.8-flash-next-dell-7960t
status: planning
updated: 2026-08-27
version: 1.0.0
---

# Feature: On-prem Qwen3.8-Flash-Next serving on the Dell 7960T

## Plan

### Overview

Deploy `Qwen/Qwen3.8-Flash-Next` — Qwen's experimental preview of the
architecture underpinning Qwen4 (Gated DeltaNet + Qwen Sparse Attention
(QSA), Gated Residual, a 51B-param N-gram Embedding, and a 512-expert MoE
with 10 routed + 1 shared active; 125B total language-model params (6B
activated) + 51B N-gram Embedding + 4B MTP = 180B total resident params)
— on the Dell 7960T, behind an OpenAI-compatible API, for use as a coding
model via OpenCode and OpenWebUI, and as a benchmark comparison point
against `feat-1`'s DeepSeek-V4 and `feat-4`'s Qwen3.8-27B on the same box.

This is a standalone, isolated feature that coexists with `feat-1`
(DeepSeek-V4), `feat-2` (GLM-5.2), and `feat-4` (Qwen3.8-27B) on the same
Dell 7960T — it does not replace or modify any of them, including
`feat-1`'s still-unstarted DeepSeek-V4-Pro slot (which this model is
architecturally comparable to as a "hybrid GPU+RAM MoE-class" candidate,
but that comparison is discussion only, not scope here).

Qwen3.8-Flash-Next ships under `qwen-community-1.0`, not Apache-2.0 like
every other model on this box — reviewed and explicitly accepted
(2026-08-27): this repo's existing anonymous/internal-network-only
posture satisfies the license's "Model as a Service"/"AI Work Assistant"
carve-out, since the model, its outputs, and its capabilities are never
exposed to a third party.

Unlike `feat-3`/`feat-4`'s Qwen3.8-27B, capacity is not the binding
constraint here — at FP8 or NVFP4 the model comfortably fits the Dell
7960T's 384GB discrete VRAM. The open questions are (a) whether any
available inference framework supports this brand-new architecture at
all yet, (b) whether QSA — a novel sparse-attention decode kernel —
reproduces the exact degenerate-output bug class `feat-1` already hit and
escalated upstream on this same SM120 GPU family, and (c) which
precision/placement strategy (GPU-only quantized vs. a hybrid placement
that offloads the N-gram Embedding to system RAM to allow full BF16 for
the rest) gives the best quality/throughput/context tradeoff.

### Requirements

- REQ-001: Serve Qwen3.8-Flash-Next via an OpenAI-compatible API
  (`/v1/chat/completions`) on the Dell 7960T, fully isolated from
  `feat-1`/`feat-2`/`feat-4`'s install trees and systemd units (dedicated
  `/data/qwen3.8-flash-next/` tree, own venv/build, only the read-only HF
  cache shared)
- REQ-002: Confirm, before any deployment work, that an available
  inference framework (vLLM, SGLang, KTransformers, llama.cpp, or
  TokenSpeed — added 2026-08-27, the model's own card names it
  alongside vLLM/SGLang with a dedicated YaRN command; none preferred by
  default; a GGUF conversion, `unsloth/Qwen3.8-Flash-Next-GGUF`, already
  exists as of feature creation, making llama.cpp a real candidate, not a
  longshot) actually supports this model's architecture (`qwen4_exp` tag:
  Gated DeltaNet, QSA, Gated Residual, N-gram Embedding, this MoE config)
  and exposes the flags its own model card documents — treated as a hard
  gate, not assumed
- REQ-003: Before any long-context or precision work, run a native/short-
  context correctness smoke test that explicitly checks for `feat-1`'s
  known degenerate-output signature (single frozen token / identical
  logprob at every decode position). QSA is a novel sparse-attention
  decode kernel being run on the exact GPU family (SM120) where a
  different sparse-attention decode kernel (vLLM's
  `FLASHINFER_MLA_SPARSE_DSV4`) is already known-broken and escalated
  upstream (vllm-project/vllm#52938) — this is a hard gate, not a
  formality
- REQ-004: Target a **896K-token context**, falling back to **768K** if
  896K does not clear the adopted safety-margin policy (reused from
  `feat-3`/`feat-4`: >=15% free or >=10 GiB absolute, whichever is
  greater). No architectural reason is known to prevent 768K-896K — YaRN
  extends this model to 1,000,000 via the identical `rope_parameters`
  mechanism as Qwen3.8-27B (corrected 2026-08-27: the model card states
  1,000,000, not 1,048,576 as originally noted here) — but QSA's real
  per-token
  memory/state cost is completely unmeasured anywhere and must be
  measured, not assumed, before committing to a context size
- REQ-005: The endpoint must support tool-calling (required for OpenCode
  agentic use) and Qwen3.8-Flash-Next's thinking controls
  (`enable_thinking`, `reasoning_effort`: xhigh/medium/low,
  `preserve_thinking`)
- REQ-006: Evaluate precision/placement in two distinct phases, in this
  order (user decision 2026-08-27):
  1. **GPU-only, quantized** (official `Qwen/Qwen3.8-Flash-Next-FP8` and/
     or a community NVFP4 checkpoint, e.g. `RadixArk/Qwen3.8-Flash-Next-NVFP4`) — straight BF16 GPU-only is
     excluded from this phase: the full 180B model at BF16 (360GB) does
     not leave usable KV-cache headroom even across all 4 GPUs (384GB)
  2. **Hybrid offload for higher precision**: offload the 51B N-gram
     Embedding to system RAM (exploiting its documented
     offload-friendly design), running the remaining 129B
     (main model + MTP) at full BF16 on GPU (258GB, fits 4 GPUs'
     384GB with ~126GB headroom). This is the path that makes BF16
     viable at all on this hardware.
     Compare quality/throughput/headroom between the two phases; no
     precision is adopted as default before this comparison
- REQ-007: Determine empirically (not assumed) the GPU count/placement,
  in this preference order (user decision 2026-08-27):
  1. For REQ-006 phase 1 (GPU-only quantized): try **GPU0+GPU2** (2 GPUs,
     the box's two PCIe Gen5 x16 cards per `feat-4`'s finding) first;
     escalate to all 4 GPUs (adding GPU1+GPU3) only if VRAM/headroom at
     2 GPUs proves insufficient
  2. For REQ-006 phase 2 (hybrid offload + BF16): **4 GPUs from the
     start** — 258GB of GPU-resident BF16 weights does not fit in 2
     GPUs' 192GB regardless of context/KV-cache headroom, so 2 GPUs is
     arithmetically excluded here, not just empirically deprioritized
  3. **TP=3 is treated as architecturally invalid, not merely
     deprioritized**: confirmed via head-count arithmetic (cheap,
     config-only check, no GPU test needed) before any GPU work —
     Gated DeltaNet's 16 QK linear-attention heads are not divisible by
     3, and QSA's 2 KV heads are not divisible by 3 either. Only TP=1,
     2, and 4 are expected to be valid; TP=4 requires the framework to
     support KV-head replication (2 KV heads across 4 ranks), which must
     still be confirmed, not assumed
- REQ-008: Pin `Qwen/Qwen3.8-Flash-Next` (and whichever quantized
  checkpoint(s) are used) to specific Hugging Face revisions/commits (not
  "latest") for reproducibility
- REQ-009: The endpoint runs unauthenticated (anonymous, no API-key/auth
  layer), internal network only — same posture as `feat-1`/`feat-2`/
  `feat-4`. Confirmed (2026-08-27, user decision) to satisfy the
  `qwen-community-1.0` license's internal-use carve-out
- REQ-010: The engine runs as a **standalone, manually-started systemd
  `--user` service** (lingering enabled, never auto-started at boot, no
  variant auto-promoted to "the" production default) — matching
  `feat-4`'s on-demand posture, given this model's large GPU footprint
  makes always-on coexistence with `feat-1`/`feat-2`/`feat-4` impractical
- REQ-011: Record the model's actual per-GPU/system-RAM memory footprint
  at each tested precision/placement/context, and whether any headroom
  remains for coexistence with the box's other features
- REQ-012: Before any Phase 3 (hybrid offload) testing that needs 4
  GPUs, check whether another feature's production service
  (`feat-1`/`feat-2`/`feat-4`) is currently running. If one is, **wait
  for it to be stopped by its owner — never stop another feature's
  running service from this feature's tooling/scripts.** Proceed
  immediately once all GPUs are confirmed free; do not add any artificial
  delay beyond that check

### Acceptance Criteria

- [ ] ACC-001: Verifies REQ-002 — a specific framework + version is
  confirmed (via direct inspection, not assumption) to register this
  model's architecture and expose its required serving flags; if none do,
  this is recorded as a blocking finding, not silently worked around
- [ ] ACC-002: Verifies REQ-003 — native-context smoke test does NOT
  reproduce `feat-1`'s degenerate-output signature; if it does, treated as
  a blocking finding requiring escalation before any further work
- [ ] ACC-003: Verifies REQ-001/REQ-009 — service reachable via
  `/v1/chat/completions`, confirmed fully isolated from `feat-1`/`feat-2`/
  `feat-4` (their services/GPUs untouched), confirmed unauthenticated/
  internal-only by design
- [ ] ACC-004: Verifies REQ-004 — empirical test confirms the chosen
  context target (896K, or 768K fallback) works without OOM on a real
  filled-context prompt
- [ ] ACC-005: Verifies REQ-005 — tool-call and all three thinking-control
  modes verified via curl, then via a real OpenCode agentic session
- [ ] ACC-006: Verifies REQ-006/REQ-007 — both the GPU-only-quantized
  phase and the hybrid-offload-BF16 phase are measured and recorded (not
  skipped), with a final comparison and one-line rationale for whichever
  configuration is kept as the primary reference, even if both remain
  available on-demand
- [ ] ACC-007: Verifies REQ-007's TP=3 exclusion — recorded as a
  config-arithmetic finding (head-count divisibility), not an
  unexplained gap in the tested TP sizes
- [ ] ACC-008: Verifies REQ-008 — deployment config records the exact HF
  revision/commit hash used for every checkpoint (base BF16, FP8, and/or
  NVFP4) actually used
- [ ] ACC-009: Verifies REQ-010 — service is a disabled, manually-started
  `systemctl --user` unit throughout testing and use; no variant
  auto-started or auto-promoted
- [ ] ACC-010: Verifies REQ-011 — a recorded decision on remaining
  headroom / coexistence feasibility with the box's other features, for
  each tested configuration
- [ ] ACC-011: Verifies REQ-012 — Phase 3 work is confirmed to have
  waited for GPU availability where needed, with no incident of another
  feature's running service being stopped by this feature's work
- [ ] ACC-012: User runs the same coding-task examples used for `feat-1`/
  `feat-2`/`feat-4` against this endpoint, for a direct quality/throughput
  comparison

### Scope

What is included:

- Framework/architecture support verification (hard gate) across vLLM,
  SGLang, KTransformers, llama.cpp, and TokenSpeed before any other work
- A dedicated, isolated install tree, venv/build, and systemd unit(s)
- Native-context degenerate-output smoke test (hard gate, mirroring
  `feat-1`/`feat-2`/`feat-4`)
- Phase A: GPU-only quantized (FP8 and/or NVFP4) placement and throughput
  measurement, starting at GPU0+GPU2
- Phase B: hybrid offload (N-gram Embedding to system RAM) enabling full
  BF16 for the remaining 129B, at 4 GPUs
- Config-arithmetic confirmation that TP=3 is architecturally invalid
- YaRN-based context extension targeting 896K (768K fallback)
- OpenWebUI/OpenCode wiring
- License-posture confirmation (internal-use carve-out) — already
  resolved, recorded here for the record

What is explicitly out of scope:

- Any modification to `feat-1`/`feat-2`/`feat-4`'s deployments, venvs,
  systemd units, or GPU allocation — including never stopping another
  feature's running production service from this feature's tooling
- Vision/video capability testing (text/coding only, matching this
  repo's precedent for other native VLMs)
- Treating this as a replacement for `feat-1`'s DeepSeek-V4-Pro slot —
  that remains a separate, independent decision
- Any production/always-on promotion — this stays on-demand,
  manually-started only
- Acquiring additional hardware

### Dependencies

- Depends on: the Dell 7960T's existing driver/CUDA stack (validated by
  `feat-1`/`feat-2`/`feat-4` — driver 610.57.04, CUDA 13.3, 4x SM120
  GPUs; **GPU1 currently faulted as of 2026-08-27, see Decisions Made**);
  a framework version that actually supports `qwen4_exp` (confirmed
  2026-08-27 — **no stable release of any candidate supports it**; only
  an unmerged llama.cpp PR and TokenSpeed's unreleased `main` branch do,
  see Design Notes/Task 0.2); sufficient disk headroom for the
  checkpoint(s) actually pulled (BF16 base ~360GB, FP8 ~180GB, NVFP4
  ~90-100GB — not all three need downloading at once; `/data` reconfirmed
  fresh 2026-08-27: 6.9TB free, unchanged since `feat-4`'s last
  measurement)
- Related (not a hard dependency): `feat-1`'s open, unresolved SM120
  sparse-attention-decode bug (vllm-project/vllm#52938) — directly
  relevant given QSA is also a sparse-attention decode kernel; `feat-2`'s
  finding that llama.cpp's DSA decode path is correct on this hardware
  while vLLM's is broken — suggests engine choice, not SM120 hardware
  itself, may again be the discriminator here; `feat-4`'s TP=3-invalid
  finding for a different model (Qwen3.8-27B, num_kv_heads=4) is the
  precedent for this feature's own TP=3 exclusion (num_kv_heads=2 here)
- Blocks: none

### Design Notes

- **Model facts (verified from HF 2026-08-27)**: `Qwen/Qwen3.8-Flash-Next`,
  `qwen-community-1.0`, native VLM, 125B total language-model params (6B
  activated) + 51B N-gram Embedding + 4B MTP = 180B total resident.
  Hybrid layout: 12x (3x (Gated DeltaNet -> MoE) -> 1x (QSA -> MoE)), 48
  layers. QSA: 24 Q heads / **2 KV heads**, head dim 256, MQA-style
  indexer (4 query heads, 1 shared key head), budget 512 blocks / 2048
  tokens. Gated DeltaNet: **16 QK heads**, 48 V heads, head dim 128. MoE:
  512 experts, 10 routed + 1 shared active, expert intermediate dim 640.
  Context: 262,144 native, extensible to 1,000,000 via YaRN (identical
  `rope_parameters` shape to Qwen3.8-27B/Qwen3.8-Flash-Next family;
  corrected 2026-08-27 from an earlier 1,048,576 note — 1,000,000 is
  what the model card actually states). All head-count/config facts
  re-verified 2026-08-27 directly against the live `config.json`
  (`architectures: ["Qwen4ExpForConditionalGeneration"]`,
  `model_type: "qwen4_exp"`): `num_attention_heads=24`,
  `num_key_value_heads=2` (QSA), `linear_num_key_heads=16`,
  `linear_num_value_heads=48` (Gated DeltaNet), `num_experts=512`,
  `num_experts_per_tok=10`, `num_hidden_layers=48`, `hc_count=4`/
  `hc_lowrank=320` (Gated Residual) — no discrepancies found against the
  model card or this document's earlier notes. Also notable:
  `transformers_version: "5.8.0.dev0"` is the minimum the config was
  authored against; both existing on-box venvs already run newer
  (5.14.1/5.15.1), and PyPI's latest (5.16.1) clears it too, so
  `transformers` itself is not expected to be the blocker.

- **Footprint arithmetic (why Phase A excludes BF16 and Phase B needs 4
  GPUs)**:

  | Configuration | Footprint | Fits 2 GPUs (192GB)? | Fits 4 GPUs (384GB)? |
  |---|---|---|---|
  | Full model (180B) BF16 | 360GB | No | Barely (~24GB left — not enough for 768K+) |
  | Full model (180B) FP8 | 180GB | Barely (~12GB left) | Yes (~204GB headroom) |
  | Full model (180B) NVFP4 | ~99GB | Yes (~93GB headroom) | Yes (~285GB headroom) |
  | 129B (offload N-gram Embedding) BF16 | 258GB | **No (258GB > 192GB)** | Yes (~126GB headroom) |

  This table drives REQ-006/REQ-007's phase ordering directly: Phase A
  (GPU-only) most likely only works well at NVFP4 on 2 GPUs, with FP8 as
  the 2-GPU stretch case and the reliable fallback at 4 GPUs; Phase B
  (offload + BF16) is only attempted at 4 GPUs since 2 is arithmetically
  ruled out, not just empirically deprioritized.

- **TP=3 exclusion, precedent from `feat-4`**: `feat-4` found Qwen3.8-27B
  could not run at TP=3 because its `num_key_value_heads=4` doesn't
  divide by 3. This feature's QSA has only 2 KV heads (also not divisible
  by 3) AND Gated DeltaNet has 16 QK heads (also not divisible by 3) —
  two independent architectural reasons TP=3 is expected to be invalid,
  not one. Confirm via config inspection before any GPU time is spent;
  do not attempt a live TP=3 test. TP=4 needs the framework to support KV
  -head replication (2 heads across 4 ranks) — a common, well-supported
  GQA pattern, but must be confirmed for this specific framework/model
  combination, not assumed from precedent alone.

- **QSA is the single largest unvalidated risk in this plan.** It is a
  brand-new sparse-attention decode kernel with no production track
  record anywhere, being tested on the exact GPU family where a
  different sparse-attention decode kernel (vLLM's
  `FLASHINFER_MLA_SPARSE_DSV4`) is already known-broken and escalated
  upstream. Phase 1's smoke test is a hard gate, not a formality.

- **Task 0.2 findings (2026-08-27, direct source inspection — not
  assumption)**: none of the four originally-listed frameworks support
  `qwen4_exp`/`Qwen4ExpForConditionalGeneration` in any **stable**
  release, checked against both the latest tagged release and the
  unreleased `main`/dev branch of each:

  - **vLLM**: absent from `registry.py` in v0.28.0 (latest stable, this
    box runs v0.26.0) *and* on current `main` — no support anywhere yet,
    not even in-flight.
  - **SGLang**: absent from v0.5.18 (latest stable) and `main` (highest
    registered Qwen family member on `main` is `qwen3_5`).
  - **KTransformers**: absent from v0.7.0 (latest stable) and `main`
    (highest is `qwen3_next`/`Qwen3.5`).
  - **llama.cpp**: absent from mainline (`llama-arch.cpp` tops out at
    `qwen35`/`qwen35moe`). The GGUF conversion
    (`unsloth/Qwen3.8-Flash-Next-GGUF`) explicitly depends on an
    **unmerged, open PR** (ggml-org/llama.cpp#27742, "model: add
    Qwen3.8-Flash-Next (qwen4exp)", opened 2026-08-26, 54 commits, still
    updated as of 2026-08-27, `mergeable_state: unstable`) — not usable
    via any released/mainline llama.cpp build.
  - **TokenSpeed** (added to REQ-002 today as a result of this check):
    the PyPI release (v0.1.0) has no `qwen4_exp` support, but its GitHub
    `main` branch gained full support **today**, 2026-08-27, via PR #1257
    ("feat: add Qwen3.8-flash-next support") — a dedicated config
    (`qwen4_exp_config.py`, with `hc_count`/`hc_lowrank` for Gated
    Residual and `ngram_size`/`heads_per_ngram`/`ngram_vocab_size_base`
    for the N-gram Embedding, matching the live `config.json` field names
    exactly), a dedicated QSA Triton kernel
    (`tokenspeed_kernel/.../qwen4_exp_qsa.py`), dedicated KV-cache
    backend/recipes, and a test file. **Correction to this document's own
    initial framing**: this is not an obscure/speculative branch —
    TokenSpeed's own project README lists "Qwen3.8 Flash Next ... at
    Day 0" under News, linking an NVIDIA developer blog
    ("Experiment with Qwen3.8-Flash-Next on NVIDIA GB300 NVL72 for
    agentic coding"), and TokenSpeed's published docs
    (lightseek.org/tokenspeed/recipes/models) carry a dedicated,
    officially-documented "Qwen3.8 Flash Next" recipe with a concrete
    serve command:
    `ts serve --model Qwen/Qwen3.8-Flash-Next-FP8 --trust-remote-code --tensor-parallel-size 4 --quantization fp8 --moe-backend flashinfer_trtllm --disable-kvstore --speculative-algorithm MTP --speculative-num-steps 3`, plus an optional `--hf-overrides` for
    `ple_embed_dtype` (store the N-gram/"PLE" embedding table in FP8) and
    `index_share_for_mtp_iteration` (reuse QSA top-k selection across MTP
    steps). Install is Docker-first per TokenSpeed's own "Getting
    Started" guide (`lightseekorg/tokenspeed-runner:latest`, then
    `pip install -e` the `python`/`tokenspeed-kernel/python`/
    `tokenspeed-scheduler` packages inside it) — Docker is available and
    usable without sudo on this box. TP=4 matches REQ-007's Phase A
    escalation path, not the GPU0+GPU2-first preference, so the box's
    current GPU1 fault (see Decisions Made) directly blocks trying this
    exact recipe as documented until GPU1 recovers or the recipe is
    adapted to TP=2.
  - **Net result**: REQ-002's hard gate is **not clearable by any stable
    release today**, but it is materially *less* risky than a first pass
    suggested: TokenSpeed's support is a coordinated, documented,
    Day-0 vendor recipe (published today), not merely source files that
    happen to exist. llama.cpp's path remains the community/Unsloth-
    backed GGUF route via an unmerged PR. This is exactly the fork in the
    road Task 0.3 anticipated — see Decisions Made for how to proceed.

- **License posture (resolved 2026-08-27)**: `qwen-community-1.0` permits
  internal use freely; the "Model as a Service"/"AI Work Assistant"
  carve-out requires a separate Qwen license only if the model, its
  outputs, or its capabilities are exposed to a third party. This repo's
  anonymous-but-internal-network-only posture clears this — explicitly
  confirmed by the user, not silently inherited from the auth-risk
  precedent.

- **Phase 3 (hybrid offload) GPU-coordination rule (user decision
  2026-08-27)**: before starting any 4-GPU Phase 3 work, check whether
  `feat-1`/`feat-2`/`feat-4` has a production service currently running.
  If so, **wait — do not stop it.** Proceed the moment all GPUs are
  confirmed free, with no added delay beyond that check. This mirrors
  `feat-4`'s Task 0.5 pre-flight check, but adds an explicit
  non-interference guarantee since this feature is more likely to need
  the whole box at once.

### Related ADRs

- None (infrastructure/deployment work, tracked using this repo's
  feature-folder convention, same as `feat-1`-`feat-4`)

### Task List

#### Phase 0: Framework/architecture support verification (hard gate)

- [x] Task 0.1: Confirm disk headroom under `/data` for whichever
  checkpoint(s) are pulled first (start with FP8 ~180GB and/or NVFP4
  ~90-100GB; BF16 base ~360GB only if/when Phase B is reached) — depends
  on: none — status: done (2026-08-27: `/data` on `/dev/md126` has 6.9TB
  free of 15TB — unchanged since `feat-4`'s last measurement, confirmed
  fresh, not stale. Comfortably covers FP8/NVFP4; will re-check before
  any BF16 pull)
- [x] Task 0.2: For each of vLLM (this box's existing 0.26.0, and latest
  stable), SGLang, KTransformers, llama.cpp, and TokenSpeed: check
  whether it registers this model's architecture tag and exposes the
  serving flags the model card documents (QSA, Gated Residual, N-gram
  Embedding, this MoE config) — depends on: none — status: done
  (2026-08-27, via direct source inspection of each project's latest
  stable release and its `main`/dev branch — see Design Notes for full
  detail. Result: **no stable release of any candidate supports
  `qwen4_exp`**. Two unreleased implementations exist: llama.cpp PR
  #27742 (open, unmerged, GGUF-oriented) and TokenSpeed's `main` branch
  (support merged 2026-08-27, same day as this check, most
  architecturally complete). This clears the "not assumed" bar REQ-002
  demands but does **not** clear the gate itself — no stable release
  passes. Proceeds to Task 0.3.)
- [x] Task 0.3: If no stable release supports it, evaluate the risk/
  effort of a nightly/dev build vs. treating this feature as blocked
  pending upstream support — depends on: Task 0.2 — status: done
  (2026-08-27, user decision: **pursue both unreleased candidates in
  parallel** — TokenSpeed `main` and llama.cpp PR #27742 — each in its
  own isolated tree, run each through Phase 1's smoke test, and let
  empirical results, not project reputation, decide which (if either)
  becomes the production engine. See Decisions Made.)
- [x] Task 0.4: Build fully isolated venv/install trees under
  `/data/qwen3.8-flash-next/`, independent of `feat-1`/`feat-2`/
  `feat-4`'s trees — **two trees, per Task 0.3's parallel-candidate
  decision**: `/data/qwen3.8-flash-next/tokenspeed/src` (TokenSpeed
  `main`, built from source in a container) and
  `/data/qwen3.8-flash-next/llama.cpp-qwen4exp/` (llama.cpp built from PR
  #27742's branch) — depends on: Task 0.3 — status: **both built
  successfully** (2026-08-27). llama.cpp: `llama-server`/`llama-cli`
  compiled with `-DGGML_CUDA=ON`, correctly linked against
  `libcudart`/`libcublas`/`libggml-cuda`, `CMAKE_CUDA_ARCHITECTURES`
  correctly includes `120a-real` for this box's Blackwell SM120 GPUs.
  TokenSpeed: took 3 attempts, two real bugs found and fixed along the
  way (both now baked permanently into `bin/04-run-tokenspeed-container.sh`):
  (1) `docker run --gpus all` fails outright at container-*creation* time
  (CDI enumeration hits GPU1's fault before the container even starts) —
  fixed with `--gpus '"device=0,2,3"'`; (2) `tokenspeed-kernel`'s build
  failed with a real version mismatch (base image ships
  `flashinfer-jit-cache==0.6.17+cu130`, but `requirements/cuda.txt`
  hard-pins `flashinfer-python==0.6.16`) — fixed with
  `FLASHINFER_DISABLE_VERSION_CHECK=1` (FlashInfer's own documented
  bypass); (3) the build then failed again with `PermissionError: /home/runner/.cache/flashinfer` — Docker auto-creates a bind mount's
  target *parent* directory as root when absent from the image, which is
  exactly what happened to `/home/runner/.cache` because of the
  `-v .../hf_cache:/home/runner/.cache/huggingface:ro` mount — fixed with
  a `sudo chown runner:runner /home/runner/.cache` step (passwordless
  sudo works in this image). Third attempt succeeded end-to-end:
  `tokenspeed --help`/`tokenspeed env` work, all three packages
  (`./python`, `tokenspeed-kernel`, `tokenspeed-scheduler`) installed.
  **Neither can be verified to actually *run* yet**: `llama-server --version` fails with `ggml_cuda_init: failed to initialize CUDA: unknown error`, and `import tokenspeed_kernel` fails with
  `RuntimeError: tokenspeed-kernel requires an NVIDIA CUDA or AMD ROCm GPU` (its platform-detection runs eagerly at import time) — both are
  the same box-wide CUDA-context fault (see Decisions Made), not build
  defects. Task 0.4 is complete; what's left is entirely gated on GPU1.)
- [x] Task 0.5 (FP8 half): Pin and download the checkpoint(s) needed for
  Phase 2 (FP8 and/or NVFP4) to a specific HF revision — depends on: Task
  0.1 — status: FP8 done (2026-08-27: `Qwen/Qwen3.8-Flash-Next-FP8` @
  `970c569adaca6b35532111fd6b27351b2baefe50` downloaded successfully into
  the shared `/data/nvidia/hf_cache`
  (`.../snapshots/970c569adaca6b35532111fd6b27351b2baefe50`), ~173GB on
  disk, took 2h12m at an average ~24 MB/s. This is the exact checkpoint
  named in both vLLM's and TokenSpeed's official recipes. `/data` still
  has 6.7TB free. `RadixArk/Qwen3.8-Flash-Next-NVFP4` @
  `7b719225242aacd3dbd3f9407468c2ee9a9d2594` remains pinned and scripted
  (`bin/05-download-weights.py nvfp4`) but **not started** — not needed
  for Task 1.1's FP8-based smoke test, start it when next convenient)
- [x] Task 0.6: Confirm `feat-1`/`feat-2`/`feat-4`'s current live state
  (to avoid GPU contention during this feature's own testing) — depends
  on: none — status: done (2026-08-27: only `feat-4`'s
  `qwen3.8-27b-bf16-896k.service` is running, actively serving on
  GPU0+GPU2, `systemctl --user` confirmed active since 2026-08-25.
  `feat-1` (system-wide) and `feat-2` (`--user`) have no running
  services. GPU3 is idle. GPU1 is not usable at all right now — see
  Decisions Made. Net: feat-5's first GPU-touching work must either use
  GPU1+GPU3 once GPU1 recovers, or wait for `feat-4`'s owner to stop
  their service — never stopped by feat-5's own tooling, per REQ-012)
- [x] Task 0.7: Confirm via config-arithmetic (no GPU test) that TP=3 is
  invalid (Gated DeltaNet's 16 QK heads and QSA's 2 KV heads are both
  not divisible by 3); confirm the chosen framework supports TP=4's
  required KV-head replication (2 heads across 4 ranks) — depends on:
  Task 0.2 — status: partially done (2026-08-27: TP=3-invalid arithmetic
  reconfirmed directly against the live `config.json`
  \[`num_key_value_heads=2`, `linear_num_key_heads=16`, neither divisible
  by 3\] — this half of the task is closed, no live TP=3 test needed. The
  TP=4 KV-head-replication confirmation remains genuinely blocked on
  Task 0.3's framework choice, since it's framework-specific)

#### Phase 1: Native-context correctness smoke test (hard gate)

- [ ] Task 1.1: Bring up the model at short/native context, no YaRN
  override yet — depends on: Task 0.4, Task 0.5 — status: not-started
- [ ] Task 1.2: Temperature=0 smoke test — explicitly check for `feat-1`'s
  exact degenerate-output signature; verify tool-calling and thinking-
  control modes — depends on: Task 1.1 — status: not-started
- [ ] Task 1.3: Record the outcome — if degenerate, this is a blocking
  finding requiring escalation before any further work — depends on:
  Task 1.2 — status: not-started

#### Phase 2: GPU-only quantized placement (FP8 / NVFP4)

- [ ] Task 2.1: Benchmark NVFP4 at GPU0+GPU2 (TP=2) first — depends on:
  Task 1.3, Task 0.7 — status: not-started
- [ ] Task 2.2: Benchmark FP8 at GPU0+GPU2 (TP=2); expected to be tight
  per the footprint table — depends on: Task 2.1 — status: not-started
- [ ] Task 2.3: If either precision's headroom is insufficient at 2 GPUs,
  escalate to all 4 GPUs (TP=4) and re-measure — depends on: Task 2.2 —
  status: not-started
- [ ] Task 2.4: Record the chosen GPU-only production config (precision +
  GPU count) with measured data — depends on: Task 2.3 — status:
  not-started

#### Phase 3: Hybrid offload for full BF16 (N-gram Embedding -> system RAM)

- [ ] Task 3.0: **Pre-flight GPU-availability check** — confirm whether
  `feat-1`/`feat-2`/`feat-4` has a production service currently running.
  If yes, wait — do not stop it. Proceed the moment all 4 GPUs are
  confirmed free, with no added delay — depends on: Task 2.4 — status:
  not-started
- [ ] Task 3.1: Determine whether the chosen framework supports placing
  only the N-gram Embedding on system RAM while keeping the rest
  GPU-resident (KTransformers-style, or llama.cpp's `--n-cpu-moe`/
  `--tensor-split`-style placement, per `feat-2`'s precedent) — depends
  on: Task 3.0 — status: not-started
- [ ] Task 3.2: Bring up the 129B (main + MTP) at BF16 across all 4 GPUs
  with the N-gram Embedding offloaded to system RAM — depends on: Task
  3.1 — status: not-started
- [ ] Task 3.3: Benchmark throughput/quality and compare against Phase
  2's chosen quantized config — depends on: Task 3.2 — status:
  not-started
- [ ] Task 3.4: Record the comparison and a one-line rationale for
  whichever configuration(s) remain available on-demand — depends on:
  Task 3.3 — status: not-started

#### Phase 4: Context extension (896K target, 768K fallback)

- [ ] Task 4.1: Apply YaRN override targeting 896K; measure headroom on
  whichever configuration(s) Phase 2/3 kept — depends on: Task 2.4,
  Task 3.4 — status: not-started
- [ ] Task 4.2: If 896K does not clear the safety-margin policy, step
  down to 768K and re-measure — depends on: Task 4.1 — status:
  not-started
- [ ] Task 4.3: Validate with a real filled-context request (built from
  the model's own tokenizer) — depends on: Task 4.2 — status: not-started

#### Phase 5: Deployment + integration

- [ ] Task 5.1: Install as a standalone, manually-started, disabled
  `systemctl --user` service (or one per kept configuration) — depends
  on: Task 4.3 — status: not-started
- [ ] Task 5.2: Curl smoke test against production config(s) — depends
  on: Task 5.1 — status: not-started
- [ ] Task 5.3: Connect OpenCode/OpenWebUI — depends on: Task 5.2 —
  status: not-started
- [ ] Task 5.4: User runs the same coding-task examples as `feat-1`/
  `feat-2`/`feat-4` for comparison — depends on: Task 5.3 — status:
  not-started

**Note:** If a task's scope changes mid-flight, edit its description in place;
rely on git history (`git log -p` on this file) to recover what was
originally planned, rather than keeping a second copy of the task around.

## Progress

### Handover (resume here in a fresh session)

Updated 2026-08-27, end of session: **everything that doesn't need a
live GPU is done.** Both build trees are complete and verified-as-far-as-
possible; the FP8 checkpoint is fully downloaded. The *only* remaining
blocker is the GPU1/CUDA-context fault. Read this first, in order.

1. **Confirm the hardware fix landed**:
   ```bash
   nvidia-smi   # must show all 4 GPUs cleanly -- no "Unable to determine
                # the device handle for GPU1: 0000:34:00.0: Unknown Error"
   ```
   If GPU1 still errors, stop here and hand back to the user — nothing
   below will work yet.
2. **Confirm the fix is more than skin-deep** — last session found the
   fault had disturbed the driver's ability to create *any* new CUDA
   context box-wide, not just GPU1's own enumeration (see Decisions Made,
   "escalation" entry). A clean `nvidia-smi` alone is not sufficient
   proof; re-run the same checks that found the box-wide problem:
   ```bash
   # 1. bare-metal CUDA init (should print a normal llama.cpp version banner,
   #    no "ggml_cuda_init: failed to initialize CUDA" line)
   /data/qwen3.8-flash-next/llama.cpp-qwen4exp/build/bin/llama-server --version

   # 2. TokenSpeed's own platform check (should NOT raise
   #    "RuntimeError: tokenspeed-kernel requires an NVIDIA CUDA or AMD
   #    ROCm GPU")
   docker exec tokenspeed-qwen4exp bash -lc \
     "python3 -c 'import tokenspeed_kernel; print(\"OK\")'"
   ```
   Both must pass before any Phase 1 work starts. If either still fails,
   the fault is still live -- go back to the user, don't work around it
   again (the `--gpus '"device=0,2,3"'` GPU-scoping fix already applied
   only gets Docker containers to *start*, it does not fix the
   underlying CUDA-context problem).
3. **Everything else needed for Task 1.1 is already in place** -- no
   re-download or rebuild should be needed:
   - FP8 checkpoint: `/data/nvidia/hf_cache/hub/models--Qwen--Qwen3.8-Flash-Next-FP8/snapshots/970c569adaca6b35532111fd6b27351b2baefe50`
   - llama.cpp-qwen4exp binaries: `/data/qwen3.8-flash-next/llama.cpp-qwen4exp/build/bin/{llama-server,llama-cli}`
   - TokenSpeed: container `tokenspeed-qwen4exp` (check
     `docker ps -a --filter name=tokenspeed-qwen4exp`; if it's gone,
     `bash .specmgr/feat/feat-5-qwen3.8-flash-next-dell-7960t/bin/04-run-tokenspeed-container.sh`
     is fully idempotent and fast now that everything's cached)
4. **Once step 2 passes**, resume at **Task 1.1** (bring up the model at
   native/short context, no YaRN yet) for *both* candidates in parallel
   per Task 0.3's decision -- TokenSpeed first (its official recipe:
   `ts serve --model Qwen/Qwen3.8-Flash-Next-FP8 --trust-remote-code --tensor-parallel-size 4 --quantization fp8 --moe-backend flashinfer_trtllm --disable-kvstore --speculative-algorithm MTP --speculative-num-steps 3`, see Design Notes -- run it via
   `docker exec tokenspeed-qwen4exp ...`) and llama.cpp-qwen4exp second
   (no known serve recipe yet -- work out `--hf-overrides`-equivalent
   flags from `llama-server --help` against the GGUF conversion, since
   this session never downloaded `unsloth/Qwen3.8-Flash-Next-GGUF`).
   **Check REQ-012 first**: TokenSpeed's TP=4 recipe needs all 4 GPUs --
   confirm `systemctl --user status qwen3.8-27b-bf16-896k.service`
   (feat-4's production service) before claiming GPU0/GPU2; wait for its
   owner to stop it, never stop it from feat-5's own tooling.
5. **Not yet started, still open**: the NVFP4 checkpoint download
   (`RadixArk/Qwen3.8-Flash-Next-NVFP4`, pinned revision already recorded
   in `bin/05-download-weights.py`'s `nvfp4` target) -- not a blocker for
   Task 1.1's FP8-based smoke test, start whenever convenient.

### Current Status

**As of 2026-08-27**: **All of Phase 0 that doesn't require a live GPU is
done.** Tasks 0.1, 0.2, 0.3, 0.4, 0.6, and (partially) 0.7 are done.
Task 0.5's FP8 half is **done** (`Qwen/Qwen3.8-Flash-Next-FP8`
downloaded, 2h12m, ~173GB); its NVFP4 half is still pending, not urgent.
Task 0.4 (both isolated build trees) is now **fully done**:
llama.cpp-qwen4exp built successfully first try; TokenSpeed took 3
attempts but is now fully installed and working (`tokenspeed --help`/
`tokenspeed env` succeed), after finding and permanently fixing two real
bugs along the way (a FlashInfer version mismatch, a Docker bind-mount
ownership gotcha) — see Decisions Made. **The only thing left blocking
any further progress is the GPU1/CUDA-context fault**, confirmed
box-wide (not GPU1-only): no new CUDA context can be created on this box
at all right now (bare metal or Docker, any GPU) — both `llama-server --version` and `tokenspeed_kernel`'s import-time platform check fail with
the identical underlying error. The user is leaving `feat-4`'s GPU0+GPU2
production service running until this feature's own downloads/builds
finish (now the case) and will address GPU1 next. This affects more than
just feat-5 (no feature on this box can start new GPU work until it's
fixed).

### Recent Updates

#### 2026-08-27

- Completed: researched Qwen3.8-Flash-Next's architecture (QSA, Gated
  Residual, N-gram Embedding, MoE config), confirmed license
  (`qwen-community-1.0`) and its internal-use carve-out, confirmed
  official FP8 and community NVFP4/GGUF checkpoints already exist,
  resolved footprint arithmetic driving the two-phase precision plan
  (GPU-only quantized vs. hybrid-offload BF16), resolved GPU-count
  preference order and the TP=3 architectural exclusion, resolved the
  Phase 3 GPU-coordination rule (wait, never stop another feature's
  running service) through discussion with user; feature folder
  scaffolded and GitHub issue #5 created.
- Completed (same day, start-of-implementation pass): re-verified all
  model architecture facts directly against the live `config.json`
  (no discrepancies except the 1,048,576 → 1,000,000 context-figure
  correction); ran Task 0.1 (disk: 6.9TB free, fresh), Task 0.6 (only
  `feat-4`'s service is live, on GPU0+GPU2), and Task 0.7's
  config-arithmetic half; ran the full Task 0.2 framework survey via
  direct source inspection (stable release + `main`/dev branch) of
  vLLM, SGLang, KTransformers, llama.cpp, and a newly-added 5th
  candidate, TokenSpeed — result: no stable release of any candidate
  supports `qwen4_exp`, only two unreleased dev efforts do (llama.cpp
  PR #27742, TokenSpeed `main` as of today). Also discovered, via live
  `nvidia-smi`, that GPU1 is currently faulted (same signature as the
  documented 2026-08-25 incident, but this is a new, undocumented
  recurrence after a later reboot) — flagged to the user, who is
  handling recovery in parallel; this does not block Phase 0's
  remaining no-GPU tasks.
- Next: user decision on Task 0.3 (which unreleased framework to use, or
  wait); once resolved, Task 0.4 (isolated venv) and Task 0.5 (pinned
  checkpoint download) can proceed without needing any GPU.

### Decisions Made

- **2026-08-27**: `qwen-community-1.0` license accepted — this repo's
  anonymous/internal-network-only posture satisfies the "Model as a
  Service"/"AI Work Assistant" carve-out (no third-party exposure of the
  model, its outputs, or its capabilities).
- **2026-08-27**: QSA's status as a novel, unvalidated sparse-attention
  decode kernel on the same SM120 GPU family where `feat-1` already hit
  an unresolved sparse-attention decode bug is noted and accepted as a
  known risk — Phase 1's smoke test is the mitigation, not a guarantee.
- **2026-08-27**: No engine preference — vLLM, SGLang, KTransformers, and
  llama.cpp are co-equal Phase 0 candidates; llama.cpp is elevated from
  "unlikely" to a real candidate given `unsloth/Qwen3.8-Flash-Next-GGUF`
  already exists and `feat-2`'s precedent that llama.cpp avoided the
  SM120 sparse-attention bug class that blocks `feat-1`.
- **2026-08-27**: Precision/placement evaluated in two ordered phases —
  GPU-only quantized (FP8/NVFP4) first, then a hybrid offload of the
  N-gram Embedding to system RAM specifically to enable full BF16 for
  the remaining 129B — rather than picking one precision by default.
- **2026-08-27**: GPU preference order — GPU0+GPU2 first for the
  GPU-only-quantized phase (escalate to all 4 only if needed); the
  hybrid-offload-BF16 phase starts directly at 4 GPUs since 2 GPUs
  (192GB) cannot fit 258GB of BF16-resident weights regardless of
  context headroom.
- **2026-08-27**: TP=3 is treated as architecturally invalid (Gated
  DeltaNet's 16 QK heads and QSA's 2 KV heads are both not divisible by
  3\) and will be confirmed via config arithmetic, not a live GPU test —
  precedent: `feat-4` found the same class of exclusion for Qwen3.8-27B's
  4 KV heads.
- **2026-08-27**: Phase 3 (hybrid offload) must never stop another
  feature's running production service — if one is running when Phase 3
  work is ready to start, wait for it to be stopped by its owner, then
  proceed immediately once all GPUs are confirmed free.
- **2026-08-27 (start-of-implementation findings)**: TokenSpeed added as
  a 5th REQ-002/Task 0.2 candidate — the model card names it explicitly,
  alongside vLLM/SGLang, with its own YaRN command syntax.
- **2026-08-27**: Design Notes' context-extension figure corrected from
  1,048,576 to 1,000,000 (the model card's actual stated ceiling); does
  not affect the 896K/768K targets, both well under either figure.
- **2026-08-27**: Task 0.2 closed with a confirmed **no-stable-support**
  finding across all 5 candidates (direct source inspection of each
  project's latest release and `main`/dev branch — not assumption, per
  REQ-002). Two unreleased implementations exist (llama.cpp PR #27742,
  open/unmerged; TokenSpeed `main`, support merged the same day as this
  check). Task 0.3's dev-build-vs-wait decision is **pending user input**
  — not decided unilaterally, given REQ-002/ACC-001 explicitly treat this
  as a hard gate and call out "if none do, record as a blocking finding,
  not silently worked around."
- **2026-08-27**: Task 0.3 resolved — pursue **both** unreleased
  candidates in parallel (TokenSpeed `main` and llama.cpp PR #27742),
  each in its own isolated build tree, rather than betting on one or
  waiting for a stable release. Whichever clears Phase 1's degenerate-
  output smoke test first (or both, if both do) carries forward into
  Phase 2; this doubles Task 0.4's build effort but removes the risk of
  picking the wrong unreleased dependency on reputation alone.
- **2026-08-27**: A GPU1 hardware fault was found live on the box during
  Task 0.6 (same `nvidia-smi` "Unknown Error" signature as the documented
  2026-08-25 incident in `hardware/dell-7960t/recovery.md`, but occurring
  after a later reboot than that incident's recorded resolution — an
  undocumented recurrence, not a stale read). No non-interactive `sudo`
  is available in this session to attempt recovery. User will handle
  physical/driver recovery in parallel; Phase 0's remaining no-GPU tasks
  (0.4, 0.5) proceed independently, and no GPU-touching feat-5 work
  (Phase 1+) starts until GPU1 is confirmed healthy again or the user
  explicitly accepts a 3-working-GPU posture.
- **2026-08-27 (escalation of the above)**: the GPU1 fault is **not
  isolated to GPU1**, confirmed three independent ways: (1) bare-metal
  `llama-server --version` fails with `ggml_cuda_init: failed to initialize CUDA: unknown error` even with `CUDA_VISIBLE_DEVICES=0,2,3`
  explicitly excluding GPU1; (2) Docker's `--gpus all` fails outright at
  container-*creation* time (`failed to get full GPU device editors: error getting device handle for index '1': Unknown Error` — NVIDIA
  Container Toolkit's CDI generation enumerates every device by index
  before any workload runs, so it aborts even when the workload itself
  would never touch GPU1); (3) explicitly scoping Docker to the healthy
  GPUs (`--gpus '"device=0,2,3"'`) *does* let a container start and
  `nvidia-smi` succeeds inside it (correctly showing 3 GPUs, with
  `feat-4`'s real load on two of them), but `torch.cuda.is_available()`
  still returns `False` with `CUDA unknown error` inside that same
  container. So `nvidia-smi`-style device *enumeration* still works for
  the 3 healthy GPUs, but **no new CUDA context can be created on this
  box at all, on any GPU, by any new process** — while `feat-4`'s
  already-running process (its CUDA context established before whatever
  triggered this) keeps working undisturbed. This matches `recovery.md`'s
  own note from the 2026-08-25 incident that a GPU1 fault can leave the
  *driver's global state* disturbed, not just GPU1 itself, and likely
  needs the same fix (physical inspection + reboot) to clear. Net effect:
  **no new GPU-touching work of any kind — not just feat-5's — can start
  on this box until this is resolved**, which raises the urgency of the
  user's parallel recovery effort well beyond feat-5's own scope. The
  `--gpus '"device=0,2,3"'` workaround is recorded here for TokenSpeed's
  container going forward regardless (avoids Docker's own CDI-enumeration
  abort once the underlying CUDA-context issue is fixed).
- **2026-08-27**: Task 0.4 completed for both parallel candidates despite
  the GPU1 blocker -- llama.cpp-qwen4exp built cleanly on the first try;
  TokenSpeed needed 3 attempts, surfacing two real, fixable bugs (a
  `flashinfer`/`flashinfer-jit-cache` version mismatch, worked around with
  `FLASHINFER_DISABLE_VERSION_CHECK=1`; and a Docker bind-mount ownership
  gotcha on `/home/runner/.cache`, fixed with a `sudo chown`), both now
  permanently baked into `bin/04-run-tokenspeed-container.sh` rather than
  documented-only. Both fixes are recorded as genuine findings, not
  papered-over workarounds -- the version-check bypass is FlashInfer's
  own documented escape hatch, and the chown fix addresses a Docker
  mechanic (parent-dir auto-creation on bind mount) unrelated to either
  framework's own code quality. With both trees built, Task 0.4 is fully
  closed; only Phase 1 (actually running either) remains gated on GPU1.

### Related PRs / Commits

- [Issue #5](https://github.com/dfch/biz.dfch.LlmOps/issues/5): On-prem
  Qwen3.8-Flash-Next serving on the Dell 7960T
  </content>
