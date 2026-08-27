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
  inference framework (vLLM, SGLang, KTransformers, or llama.cpp —
  none preferred by default; a GGUF conversion, `unsloth/Qwen3.8-Flash-Next-GGUF`, already exists as of feature creation, making
  llama.cpp a real candidate, not a longshot) actually supports this
  model's architecture (`qwen4_exp` tag: Gated DeltaNet, QSA, Gated
  Residual, N-gram Embedding, this MoE config) and exposes the flags its
  own model card documents — treated as a hard gate, not assumed
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
  extends this model to 1,048,576 via the identical `rope_parameters`
  mechanism as Qwen3.8-27B — but QSA's real per-token
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
  SGLang, KTransformers, and llama.cpp before any other work
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
  GPUs); a framework version that actually supports `qwen4_exp`
  (unconfirmed — REQ-002); sufficient disk headroom for the checkpoint(s)
  actually pulled (BF16 base ~360GB, FP8 ~180GB, NVFP4 ~90-100GB — not
  all three need downloading at once; check current `/data` free space
  fresh, since `feat-4`'s last measurement (6.9TB free) predates this
  feature's own downloads)
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
  Context: 262,144 native, extensible to 1,048,576 via YaRN (identical
  `rope_parameters` shape to Qwen3.8-27B/Qwen3.8-Flash-Next family).
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
- **Framework choice is genuinely open.** vLLM 0.26.0 (this box's
  validated version) almost certainly predates `qwen4_exp` support. The
  model card points at vLLM/SGLang/KTransformers "latest" recipes without
  a pinned minimum version in what's been reviewed so far — Phase 0 must
  check the actual linked recipe pages, not assume parity with
  Qwen3.8-27B's requirements. A GGUF conversion
  (`unsloth/Qwen3.8-Flash-Next-GGUF`) already exists, making llama.cpp a
  real candidate — worth checking given `feat-2`'s precedent that
  llama.cpp's decode path avoided the SM120 sparse-attention bug class
  that blocks `feat-1`'s vLLM deployment.
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

- [ ] Task 0.1: Confirm disk headroom under `/data` for whichever
  checkpoint(s) are pulled first (start with FP8 ~180GB and/or NVFP4
  ~90-100GB; BF16 base ~360GB only if/when Phase B is reached) — depends
  on: none — status: not-started
- [ ] Task 0.2: For each of vLLM (this box's existing 0.26.0, and latest
  stable), SGLang, KTransformers, and llama.cpp: check whether it
  registers this model's architecture tag and exposes the serving flags
  the model card documents (QSA, Gated Residual, N-gram Embedding, this
  MoE config) — depends on: none — status: not-started
- [ ] Task 0.3: If no stable release supports it, evaluate the risk/
  effort of a nightly/dev build vs. treating this feature as blocked
  pending upstream support — depends on: Task 0.2 — status: not-started
- [ ] Task 0.4: Build a fully isolated venv/install tree
  (`/data/qwen3.8-flash-next/`), independent of `feat-1`/`feat-2`/
  `feat-4`'s trees — depends on: Task 0.3 — status: not-started
- [ ] Task 0.5: Pin and download the checkpoint(s) needed for Phase 2
  (FP8 and/or NVFP4) to a specific HF revision — depends on: Task 0.1 —
  status: not-started
- [ ] Task 0.6: Confirm `feat-1`/`feat-2`/`feat-4`'s current live state
  (to avoid GPU contention during this feature's own testing) — depends
  on: none — status: not-started
- [ ] Task 0.7: Confirm via config-arithmetic (no GPU test) that TP=3 is
  invalid (Gated DeltaNet's 16 QK heads and QSA's 2 KV heads are both
  not divisible by 3); confirm the chosen framework supports TP=4's
  required KV-head replication (2 heads across 4 ranks) — depends on:
  Task 0.2 — status: not-started

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

### Current Status

**As of 2026-08-27**: Feature scaffolded and planned. No environment work
started yet.

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
- Next: begin Phase 0 (framework/architecture support verification).

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
  3) and will be confirmed via config arithmetic, not a live GPU test —
  precedent: `feat-4` found the same class of exclusion for Qwen3.8-27B's
  4 KV heads.
- **2026-08-27**: Phase 3 (hybrid offload) must never stop another
  feature's running production service — if one is running when Phase 3
  work is ready to start, wait for it to be stopped by its owner, then
  proceed immediately once all GPUs are confirmed free.

### Related PRs / Commits

- [Issue #5](https://github.com/dfch/biz.dfch.LlmOps/issues/5): On-prem
  Qwen3.8-Flash-Next serving on the Dell 7960T
</content>
