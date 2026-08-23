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

- [ ] ACC-001: Verifies REQ-001/REQ-002 — Qwen3.8-27B running via vLLM on
  the Dell GB10 (DGX Spark clone), reachable via `/v1/chat/completions`,
  deployment confined to the GB10 (Dell 7960T untouched)
- [ ] ACC-002: Verifies REQ-003 — empirical memory/KV-cache
  measurement confirms the endpoint handles at least a 768K-token prompt
  without OOM, with the measured safety margin recorded against the
  unified pool; if a higher context (896K, 1M) also clears the adopted
  safety-margin policy (>=15% free, or >=10 GiB absolute, whichever is
  greater — reused from `feat-2`, applied to the GB10's unified pool),
  the highest safely-supported context is chosen as the production value
  instead of stopping at 768K
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
- [ ] ACC-009: Verifies REQ-010 — a recorded decision on Qwen3.8-27B's
  memory footprint within the GB10's unified pool at the chosen
  production context, backed by measured numbers (not assumed), stating
  the remaining headroom explicitly
- [ ] ACC-010: Verifies REQ-011 — the exact YaRN `rope_parameters` config
  used for the chosen production context size is recorded in the
  systemd unit/deployment config
- [ ] ACC-011: User runs the SAME coding-task examples used for `feat-1`/
  `feat-2` (see `feat-1` ACC-010, `feat-2` ACC-009) against this
  endpoint, for a direct three-way quality comparison

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

- [ ] Task 1.1: Bring up Qwen3.8-27B on vLLM at native context (262,144 or
  smaller for a quick check) on the GB10, no YaRN override yet —
  depends on: Task 0.2, Task 0.4 — status: blocked (see Current Status)
  — **ready-to-run notes for the next session** (2026-08-22):
  weights at `/home/admin/models/qwen3.8-27b`; venv
  `/home/admin/venvs/vllm` (vLLM 0.27.1, aarch64, `Qwen3_5` arch +
  `mrope_interleaved` support confirmed in its registry); free ports —
  8080 taken (OpenWebUI), use **8000**; first step: unload the Ollama
  model to reclaim ~65 GB (`curl -s http://127.0.0.1:11434/api/chat
  -d '{"model":"qwen3.8:27b-bf16","messages":[{"role":"user",
  "content":"hi"}],"keep_alive":0}'` — must be issued from a session
  NOT served by that model, else the issuing opencode session dies mid-
  turn); then
  `/home/admin/venvs/vllm/bin/vllm serve /home/admin/models/qwen3.8-27b
  --port 8000 --trust-remote-code --no-enable-prefix-caching` (start
  with a modest `--max-model-len` like 32768 to keep KV tiny, native
  262144 optional) — run via `systemd --user` from Task 4.1 onwards,
  plain `nohup` is acceptable for this Phase 1 probe only. The unload
  step also works over SSH from another host — the only requirement is
  that the issuing session is not itself served by that Ollama model.
- [ ] Task 1.2: Temperature=0 smoke test — verify coherent, non-degenerate
  output (explicitly check against the `feat-1`/`feat-2` degenerate
  signature: a single frozen token repeated at every decode position),
  and verify tool-calling + `enable_thinking`/`reasoning_effort` work at
  native context — depends on: Task 1.1 — status: not-started
- [ ] Task 1.3: Record the outcome. If vLLM produces degenerate output
  (unexpected given the different kernel class, but not impossible),
  fall back to spiking SGLang next, mirroring `feat-2`'s Phase 1
  approach — depends on: Task 1.2 — status: not-started

#### Phase 2: Context extension + capacity measurement

- [ ] Task 2.1: Apply the YaRN `rope_parameters` override (see Design
  Notes table) targeting 768K context; measure unified-pool memory +
  KV-cache usage and free headroom at that context size — depends on:
  Task 1.3 — status: not-started
- [ ] Task 2.2: If Task 2.1's margin clears the adopted safety-margin
  policy (>=15% free of the unified pool, or >=10 GiB absolute, whichever
  is greater) with room to spare, step upward (896K, then 1M) and
  re-measure at each step until the policy is no longer cleared — choose
  the highest context size that still clears it as the production target
  (may be 768K, may be higher) — depends on: Task 2.1 —
  status: not-started
- [ ] Task 2.3: Record the remaining free headroom of the GB10's unified
  pool at the chosen production context, i.e. answer REQ-010's "what
  else could share this box, or is the pool effectively consumed"
  question with real measured numbers — depends on: Task 2.2 —
  status: not-started

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
  - lingering, following `feat-2`'s pattern unless GB10-specific needs
  dictate a system-wide unit instead) with the chosen production context,
  YaRN config, and precision on the GB10 — depends on: Task 3.1 —
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

**As of 2026-08-22**: Phase 0 COMPLETE (Tasks 0.1–0.4 done on host
`dgx`, the GB10 itself). Weights fully downloaded (55.6 GB, 18
safetensors shards + configs) to `/home/admin/models/qwen3.8-27b`.
vLLM 0.27.1 (aarch64, venv `/home/admin/venvs/vllm`) installed and
verified. Phase 1 NOT started yet — blocked by a memory-contention
problem that requires the existing Ollama stack to be unloaded first
(see Blocker below); to be picked up in a fresh session.

**BLOCKER for Phase 1 (documented 2026-08-22 session close):** the box
currently holds ~75 GiB in use; the dominant consumer is Ollama's
`qwen3.8:27b-bf16` model (65 GB resident, incl. a live 256K-context
llama-server) that the local OpenCode session itself is served by —
unloading it stops that session. vLLM loading the same 27B at BF16
(~55 GB weights + KV cache + runtime) cannot fit alongside it in the
128 GB pool. Phase 1 therefore needs the Ollama model unloaded by
issuing the Ollama API `keep_alive: 0` call (Task 1.1 notes below, no
root needed), from a session NOT served by that model (fresh session on
the DGX or the other hardware), then starting vLLM from the venv.

### Recent Updates

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
  Blocker).

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

### Related PRs / Commits

- [Issue #3](https://github.com/dfch/biz.dfch.LlmOps/issues/3): On-prem
  Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI —
  description mirrors this README's Overview section. (Issue #2 was an
  accidental duplicate, created moments earlier with identical title/
  body — closed in favor of #3.)
