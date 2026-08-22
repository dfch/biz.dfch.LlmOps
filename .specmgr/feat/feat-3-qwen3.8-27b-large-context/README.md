---
created: 2026-08-22
github_issue: 3
id: feat-3-qwen3.8-27b-large-context
status: planning
updated: 2026-08-22
version: 1.0.0
---

# Feature: On-prem Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI

## Plan

### Overview

Deploy `Qwen/Qwen3.8-27B` (dense causal LM + vision encoder, 27B params,
Apache-2.0) on the existing on-prem Dell 7960T behind an OpenAI-compatible
API, for use as a coding model via OpenCode and OpenWebUI, with its context
window extended well past the 262,144-token native limit via the vendor's
documented YaRN `rope_parameters` override. Target is a **768K-token floor**
(786,432 tokens = native context x3), pushing toward the model's advertised
1,048,576-token (1M) ceiling if per-GPU VRAM safety margin allows.

Unlike `feat-2`'s GLM-5.2 (744B MoE, forced into a lossy quant to fit this
box), Qwen3.8-27B is small enough at full BF16 precision (~54GB weights)
to fit the 384GB VRAM pool with enormous headroom left over for KV cache —
so this feature does not start from a quality-vs-capacity compromise.
Quantization (e.g. FP8) is not required and stays optional, considered only
if empirical data shows it meaningfully helps context headroom or
throughput without a demonstrated quality cost.

This feature is independent of `feat-1` (DeepSeek-V4) and `feat-2`
(GLM-5.2) — it does not replace either, and given Qwen3.8-27B's much
smaller footprint it may be able to run concurrently alongside them on a
GPU subset rather than needing an exclusive swap (to be determined
empirically, see Design Notes).

Qwen3.8-27B is a native vision-language model (image + video
understanding), but this feature scopes that capability OUT: only
text/coding use via OpenCode is targeted and validated here.

### Requirements

- REQ-001: Serve Qwen3.8-27B via an OpenAI-compatible API
  (`/v1/chat/completions`) on the Dell 7960T (4x RTX Pro 6000 Blackwell
  Max-Q, 96GB each = 384GB VRAM; 512GB system RAM)
- REQ-002: No new hardware; DGX Spark explicitly excluded (same posture as
  `feat-1`/`feat-2`)
- REQ-003: The endpoint must support a context length of at least
  **768,000 tokens** (floor). If per-GPU VRAM safety margin allows, push
  higher in measured steps, up to the model's native ceiling of
  1,048,576 tokens (1M) — do not stop at 768K if there is safe headroom to
  go further
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
  and it matches `feat-1`'s default engine. Qwen3.8's hybrid Gated
  DeltaNet + Gated Attention architecture is a different kernel class
  from the DSA/sparse-MLA path that caused `feat-1`/`feat-2`'s SM120
  vLLM bug (`vllm-project/vllm#52938`), so no mandatory full spike-phase
  is required up front — but an early native-context smoke test (Phase 1)
  is still done as cheap insurance before committing to the YaRN
  extension work
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
- REQ-010: Determine Qwen3.8-27B's actual VRAM footprint (weights + KV
  cache at the target context) and record whether it can run
  CONCURRENTLY alongside `feat-1`/`feat-2`'s existing services on shared
  GPUs, or needs reserved GPU(s)/a time-sliced swap like GLM-5.2's
  Q4/Q5 pair
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

- [ ] ACC-001: Verifies REQ-001/REQ-002 — Qwen3.8-27B running via vLLM on
  the Dell 7960T, reachable via `/v1/chat/completions`, no new hardware,
  DGX Spark unused
- [ ] ACC-002: Verifies REQ-003 — empirical per-GPU VRAM/KV-cache
  measurement confirms the endpoint handles at least a 768K-token prompt
  without OOM, with the measured safety margin recorded per GPU; if a
  higher context (896K, 1M) also clears the adopted safety-margin policy
  (>=15% free VRAM per GPU, or >=10 GiB absolute, whichever is greater —
  reused from `feat-2`), the highest safely-supported context is chosen
  as the production value instead of stopping at 768K
- [ ] ACC-003: Verifies REQ-004 — tool-call and all three thinking-control
  modes (`enable_thinking: false`, `reasoning_effort: medium`,
  `reasoning_effort: xhigh`) verified via curl smoke test, then via a
  real OpenCode agentic session
- [ ] ACC-004: Verifies REQ-005 — BF16 is confirmed as the production
  precision, with a one-line rationale recorded; if a quantized variant
  is adopted instead, the empirical justification (headroom/throughput
  data, quality-impact check) is recorded alongside it
- [ ] ACC-005: Verifies REQ-006 — vLLM is confirmed as the deployment
  engine, with the version used recorded; if vLLM fails the Phase 1
  native-context smoke test, the fallback engine actually used (SGLang)
  is recorded instead, along with why
- [ ] ACC-006: Verifies REQ-007 — deployment config records the exact HF
  revision/commit hash used
- [ ] ACC-007: Verifies REQ-008 — endpoint reachable without credentials
  from the internal network, confirmed intentional (not an oversight)
- [ ] ACC-008: Verifies REQ-009 — engine installed as a systemd service;
  started/stopped/restarted exclusively via `systemctl`
  (`systemctl --user ...` if following `feat-2`'s pattern) throughout
  testing and production use
- [ ] ACC-009: Verifies REQ-010 — a recorded decision on whether
  Qwen3.8-27B runs concurrently with `feat-1`/`feat-2` services or
  requires exclusive/reserved GPU access, backed by measured VRAM
  numbers (not assumed)
- [ ] ACC-010: Verifies REQ-011 — the exact YaRN `rope_parameters` config
  used for the chosen production context size is recorded in the
  systemd unit/deployment config
- [ ] ACC-011: User runs the SAME coding-task examples used for `feat-1`/
  `feat-2` (see `feat-1` ACC-010, `feat-2` ACC-009) against this
  endpoint, for a direct three-way quality comparison

### Scope

What is included in this feature:

- A lightweight native-context (256K) correctness smoke test on vLLM/
  SM120 BEFORE attempting the YaRN extension (Phase 1) — not a full
  multi-engine spike like `feat-2`'s Phase 1, since this model's kernel
  class differs from the known SM120 bug, but still verified rather than
  assumed
- Configuring and validating YaRN-based context extension per the
  vendor's documented `rope_parameters` override
- Empirical per-GPU KV-cache/VRAM measurement at 768K and, if headroom
  allows, at higher context sizes up to 1M
- A concurrency/coexistence check against `feat-1`/`feat-2`'s existing
  services on the same box
- Deployment of Qwen3.8-27B on the Dell 7960T as a systemd service
- Pinning the model to a fixed HF revision
- OpenWebUI and OpenCode configured against the endpoint
- Direct quality comparison against `feat-1`'s DeepSeek-V4 and `feat-2`'s
  GLM-5.2 using the same coding-task examples

What is explicitly out of scope:

- Any use of the DGX Spark for this deployment (excluded per the same
  user decision as `feat-1`/`feat-2`)
- Acquiring additional hardware
- Authentication/access-control layer (explicitly accepted as anonymous)
- Fine-tuning or training Qwen3.8-27B (serving only)
- Testing or validating vision-language (image/video) capability (REQ-012)
- Retiring or changing the `feat-1`/`feat-2` deployments — all three are
  intended to coexist; this feature does not depend on either succeeding
- Ollama/llama.cpp/GGUF as the serving path — the vendor's own
  documentation only covers the YaRN long-context extension for vLLM,
  SGLang, and TokenSpeed; Qwen3.8's hybrid Gated DeltaNet + partial-
  rotary/mrope architecture is non-standard enough that an unofficial
  llama.cpp YaRN override is judged too high-risk for this feature's
  goals (see the source chat session that preceded this feature for the
  detailed reasoning)

### Dependencies

- Depends on: a vLLM release with confirmed support for Qwen3.8-27B's
  architecture (`qwen3_5` tag, hybrid Gated DeltaNet + Gated Attention
  layout) — this is a brand-new architecture, support is NOT assumed and
  must be checked (Task 0.2); GPU driver/CUDA compatibility already
  validated in `feat-1` Task 0.2 (driver 610.57.04, CUDA 13.3); HF
  access/token/download tooling already validated in `feat-1` Task 0.3;
  sufficient local disk on the Dell 7960T (`feat-1` Task 0.1: 9.3 TB free
  at last check, re-verify remaining headroom after `feat-1`/`feat-2`
  downloads)
- Related (not a hard dependency): `feat-1`'s and `feat-2`'s SM120
  sparse-attention-decode findings (`vllm-project/vllm#52938`) — informs
  Phase 1's risk assessment but does not block it, since Qwen3.8-27B does
  not use the same DSA/sparse-MLA kernel path
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
  BF16 is ~54GB of weights — comfortably inside the 384GB VRAM pool even
  before accounting for KV cache, unlike GLM-5.2's 744B MoE which could
  not fit VRAM+RAM at any near-lossless precision without a quant. There
  is no a priori reason to trade quality for capacity here; quantization
  is opportunistic (Task 3.x), not load-bearing.

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

- **Concurrency/coexistence is a real, not rhetorical, question here**:
  because Qwen3.8-27B is so much smaller than DeepSeek-V4-Flash/Pro and
  GLM-5.2, it may be able to run on 1-2 GPUs while `feat-1`/`feat-2`
  occupy the others, rather than needing the box exclusively or a manual
  swap. This must be measured (actual free VRAM while `feat-1`/`feat-2`
  services are live), not assumed from paper VRAM math alone, since KV
  cache at 768K-1M tokens is non-trivial even for a 27B model.

- **Reuse `feat-1`/`feat-2` environment prep.** Disk, GPU/driver/CUDA,
  and HF tooling are already validated on this same box; do not repeat
  them, just reference them (Phase 0 tasks are mostly confirmation, not
  new setup work) — EXCEPT the vLLM-version-supports-this-architecture
  check, which is new and must not be skipped.

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

#### Phase 0: Environment prep (mostly inherited from feat-1/feat-2)

- [ ] Task 0.1: Confirm remaining disk headroom on `/data` for
  Qwen3.8-27B weights (~54GB BF16) after `feat-1`/`feat-2` downloads —
  depends on: none — status: in-progress — `bin/00-check-env.sh` drafted
  2026-08-22, to be run on the Dell 7960T (this session's shell is a
  different machine — hostname `nxt`, single RTX PRO 5000 Blackwell
  laptop GPU, no `/data` — confirmed NOT the target box)
- [ ] Task 0.2: Confirm the installed/available vLLM version actually
  supports Qwen3.8-27B's architecture (`qwen3_5` tag, hybrid Gated
  DeltaNet + Gated Attention). This is a brand-new architecture as of
  this feature's creation date (2026-08-22) — do NOT assume support,
  check the changelog/release notes and, if needed, upgrade vLLM —
  depends on: none — status: in-progress — `bin/00-check-env.sh`
  includes a vLLM `ModelRegistry` introspection check, to be run on the
  box
- [ ] Task 0.3: Reuse `feat-1`/`feat-2`'s validated GPU/driver/CUDA
  (driver 610.57.04, CUDA 13.3, 4x SM120 GPUs) and HF access/token/
  download tooling (`hf` CLI, `hf_transfer`) — no new work unless Task
  0.2 requires a toolchain change — depends on: none — status: in-progress
  — same `bin/00-check-env.sh` run covers this
- [ ] Task 0.4: Choose and record the pinned HF revision/commit for
  `Qwen/Qwen3.8-27B` (latest `main` as of 2026-08-22 model-card review:
  `1d4bf0f`; re-confirm and pin the actual full commit hash from the box
  at download time) — depends on: Task 0.3 — status: not-started

#### Phase 1: Baseline correctness smoke test (native context, before YaRN)

- [ ] Task 1.1: Bring up Qwen3.8-27B on vLLM at native context (262,144 or
  smaller for a quick check) on the Dell 7960T's SM120 GPUs, no YaRN
  override yet — depends on: Task 0.2, Task 0.4 — status: not-started
- [ ] Task 1.2: Temperature=0 smoke test — verify coherent, non-degenerate
  output (explicitly check against the `feat-1`/`feat-2` degenerate
  signature: a single frozen token repeated at every decode position),
  and verify tool-calling + `enable_thinking`/`reasoning_effort` work at
  native context — depends on: Task 1.1 — status: not-started
- [ ] Task 1.3: Record the outcome. If vLLM produces degenerate output
  (unexpected given the different kernel class, but not impossible),
  fall back to spiking SGLang next, mirroring `feat-2`'s Phase 1
  approach — depends on: Task 1.2 — status: not-started

#### Phase 2: Context extension + capacity/coexistence measurement

- [ ] Task 2.1: Apply the YaRN `rope_parameters` override (see Design
  Notes table) targeting 768K context; measure per-GPU VRAM/KV-cache
  usage and free headroom at that context size — depends on: Task 1.3 —
  status: not-started
- [ ] Task 2.2: If Task 2.1's per-GPU margin clears the adopted
  safety-margin policy (>=15% free VRAM per GPU, or >=10 GiB absolute,
  whichever is greater) with room to spare, step upward (896K, then 1M)
  and re-measure at each step until the policy is no longer cleared —
  choose the highest context size that still clears it as the production
  target (may be 768K, may be higher) — depends on: Task 2.1 —
  status: not-started
- [ ] Task 2.3: Determine minimum GPU/tensor-parallel count needed for
  the chosen production context size, and measure actual free VRAM
  WHILE `feat-1`/`feat-2`'s services are concurrently running, to decide
  REQ-010's coexistence-vs-exclusive question with real numbers —
  depends on: Task 2.2 — status: not-started

#### Phase 3: Precision decision

- [ ] Task 3.1: Confirm BF16 as the production precision by default
  (expected outcome given Design Notes) — depends on: Task 2.3 —
  status: not-started
- [ ] Task 3.2: (Optional, only if Task 2.2/2.3 data suggests a benefit)
  Evaluate an FP8 (or similar) variant for throughput or additional
  context/coexistence headroom, with an explicit quality-impact check
  before adopting it over BF16 — depends on: Task 3.1 — status: not-started

#### Phase 4: Full deployment

- [ ] Task 4.1: Install vLLM + Qwen3.8-27B as a systemd service (`--user`
  - lingering, following `feat-2`'s pattern unless Task 2.3 dictates a
    system-wide unit instead) with the chosen production context, YaRN
    config, precision, and GPU placement — depends on: Task 3.1 —
    status: not-started
- [ ] Task 4.2: Start the service; curl smoke test against
  `/v1/chat/completions` at the production context size — verify
  tool-calls and all thinking-control modes — depends on: Task 4.1 —
  status: not-started
- [ ] Task 4.3: Validate the finalized production context size end-to-end
  (a real filled-context request, not just a load-time VRAM probe)
  works without OOM — depends on: Task 4.2 — status: not-started

#### Phase 5: Integration

- [ ] Task 5.1: Connect OpenWebUI and OpenCode to the Qwen3.8-27B endpoint
  as a separate model entry — depends on: Task 4.3 — status: not-started
- [ ] Task 5.2: User runs the same coding-task examples from `feat-1`/
  `feat-2` against this endpoint for a direct three-way quality
  comparison — depends on: Task 5.1 — status: not-started

## Progress

### Current Status

**As of 2026-08-22**: Feature created, planning stage. No tasks started
yet.

### Recent Updates

#### 2026-08-22

- Completed: Feature scoped and drafted, following the `feat-2` structure
  and template. Key decisions captured from the preceding chat session
  (production-serving goal, 768K floor with stretch to 1M, independent/
  possibly-concurrent relationship to `feat-1`/`feat-2`, vLLM as primary
  engine, BF16-first precision, vision/video explicitly out of scope).
- Next: Start Phase 0 (disk headroom check, vLLM version/architecture
  support check, HF revision pin).
- Notes: Latest `main` commit on `Qwen/Qwen3.8-27B` at feature-creation
  time was `1d4bf0f` (README-only); actual weights are unchanged since
  the initial upload (`72a217a`/`6714f56`).

### Decisions Made

- **2026-08-22**: Feature goal is production serving (systemd service +
  OpenCode/OpenWebUI wiring + quality comparison), not just an evaluation
  spike — matching the bar set by `feat-1`/`feat-2`.
- **2026-08-22**: Context target is a 768K floor, not a hard ceiling —
  push higher (up to the model's 1M native max) if per-GPU VRAM safety
  margin allows, rather than stopping at 768K by default.
- **2026-08-22**: This feature is independent of `feat-1`/`feat-2` and
  may run concurrently with them on shared GPUs, given Qwen3.8-27B's much
  smaller footprint — to be confirmed empirically (Task 2.3), not
  assumed.
- **2026-08-22**: vLLM is the starting engine (matches the vendor's
  documented YaRN path and `feat-1`'s default), with only a lightweight
  native-context smoke test as insurance — no mandatory full multi-engine
  SM120 spike phase, since Qwen3.8's Gated DeltaNet architecture is a
  different kernel class from the DSA/sparse-MLA bug that hit
  `feat-1`/`feat-2` (`vllm-project/vllm#52938`).
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

### Related PRs / Commits

- [Issue #3](https://github.com/dfch/biz.dfch.LlmOps/issues/3): On-prem
  Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI —
  description mirrors this README's Overview section. (Issue #2 was an
  accidental duplicate, created moments earlier with identical title/
  body — closed in favor of #3.)
