---
created: 2026-08-19
id: feat-2-glm-5.2-onprem-deployment
status: planning
updated: 2026-08-19
version: 1.0.0
---

# Feature: On-prem GLM-5.2 serving for OpenCode + OpenWebUI

## Plan

### Overview

Deploy GLM-5.2 (`zai-org/GLM-5.2`, MIT) on the existing on-prem Dell 7960T
behind an OpenAI-compatible API, for use as a coding model via OpenCode and
OpenWebUI. This is the alternative/fallback model deferred from `feat-1`
(DeepSeek-V4). Quality is the priority over speed. GLM-5.2 is a 744B-param
MoE (40B active), 1M context; official Z.ai weights are BF16 (~1.5 TB),
which does NOT fit in the box's 384 GB VRAM nor in the 896 GB VRAM+RAM pool
at native precision — so a quantized build is required. Because no native
sub-BF16 checkpoint exists, GGUF requantization is explicitly accepted for
this model (the `feat-1` "no requant" rule is DeepSeek-only and does not
apply here); unsloth ships day-zero Dynamic GGUFs at `unsloth/GLM-5.2-GGUF`.

Crucially, this box is heavily over-provisioned relative to unsloth's stated
minimums (their reference config runs the 2-bit quant on a single 24 GB GPU

- 256 GB RAM). With 896 GB total (384 VRAM + 512 RAM), the **near-lossless
  4-bit (`UD-Q4_K_XL`, 372-475 GB) and 5-bit (`UD-Q5_K_XL`, 570 GB)** quants
  both fit comfortably — so, unlike DeepSeek-V4-Pro, GLM-5.2 does NOT force a
  lossy precision compromise. The model repo and the chosen quant are both
  pinned to a specific revision for reproducibility.

### Requirements

- REQ-001: Serve GLM-5.2 via an OpenAI-compatible API
  (`/v1/chat/completions`) on the Dell 7960T (4x RTX Pro 6000 Blackwell
  Max-Q, 96GB each = 384GB VRAM; 512GB system RAM)
- REQ-002: Serve GLM-5.2 without adding new hardware and without networking
  in the DGX Spark
- REQ-003: The endpoint must support real coding workloads reaching at
  least 350-370K tokens of context (GLM-5.2 advertises a solid 1M-token
  context; 350-370K is the minimum bar for parity with `feat-1`)
- REQ-004: The endpoint must support tool-calling (required for OpenCode
  agentic use) and expose GLM-5.2's flexible thinking-effort/reasoning
  modes correctly. GLM-5.2 has 3 modes — non-thinking, thinking-high,
  thinking-max — toggled via `--chat-template-kwargs`:
  `'{"reasoning_effort":"max"}'`, `'{"reasoning_effort":"high"}'`, or
  `'{"enable_thinking":false}'` to disable
- REQ-005: Maximize model quality within the hardware envelope; inference
  speed is explicitly secondary. Because this box fits the near-lossless
  4-bit/5-bit quants (see Design Notes), the target is `UD-Q5_K_XL`
  (preferred) or `UD-Q4_K_XL` (fallback) — NOT the lossy 1-2 bit levels
- REQ-006: GGUF requantization is ACCEPTED for GLM-5.2 (carried over from
  the 2026-08-19 `feat-1` decision, scoped to this model only). GLM-5.2 has
  no native sub-BF16 checkpoint that fits this hardware, so a quantized
  build (GGUF, e.g. unsloth Dynamic GGUF, or an equivalent FP8/FP4
  checkpoint) is required, not merely tolerated. Prefer the highest-quality
  quant that fits the context target — the box's memory allows near-lossless
  4-bit/5-bit, so there is no need to drop to a lossy level.
- REQ-007: Pin GLM-5.2 (and any quantized derivative) to a specific
  Hugging Face revision/commit (not "latest") for reproducibility across
  redeploys
- REQ-008: The endpoint runs unauthenticated (anonymous, no API-key/auth
  layer) — accepted risk, internal network only (same posture as `feat-1`)
- REQ-009: The engine runs as a managed service (systemd unit or
  equivalent), started/stopped via the service manager — no ad-hoc
  foreground processes, including during testing
- REQ-010: Establish whether GLM-5.2's DSA (DeepSeek Sparse Attention /
  IndexShare) decode path produces correct output on this box's SM120
  (RTX Pro 6000 Blackwell) GPUs before committing to a full deployment —
  this is the same *class* of sparse-attention kernel that blocks
  `feat-1` Task 1.4, so it must be de-risked early, not assumed working
- REQ-011: If llama.cpp/`llama-server` is chosen as the engine (its GGUF
  CUDA path is separate from vLLM's broken SM120 sparse-attention kernels,
  making it a strong Plan B), its OpenAI-compatible tool-calling must be
  explicitly verified against OpenCode's agentic use before commit —
  llama.cpp tool-calling is historically weaker than vLLM/SGLang and is a
  known risk against REQ-004

### Acceptance Criteria

- [ ] ACC-001: Verifies REQ-001/REQ-002 — GLM-5.2 running on the Dell 7960T,
  reachable via `/v1/chat/completions`, no new hardware, DGX Spark unused
- [ ] ACC-002: Verifies REQ-010 — a short smoke test at temperature=0
  produces coherent, non-degenerate output on SM120 (explicitly checked
  against the `feat-1` Task 1.4 failure signature: NOT a single frozen
  token repeated at every decode position)
- [ ] ACC-003: Verifies REQ-003 — empirical test confirms the endpoint
  handles a 350-370K-token coding prompt without OOM
- [ ] ACC-004: Verifies REQ-004/REQ-011 — tool-call verified via curl smoke
  test then a real OpenCode agentic session; all 3 reasoning modes
  (`reasoning_effort` max/high and `enable_thinking:false`) confirmed to
  toggle correctly. If the engine is llama.cpp, tool-calling is explicitly
  re-verified (REQ-011 risk)
- [ ] ACC-005: Verifies REQ-005/REQ-006 — the chosen quant is recorded
  (target `UD-Q5_K_XL`, else `UD-Q4_K_XL`), with a one-line rationale for
  why it is the highest-quality option that still meets REQ-003's context
  target on this hardware (both are near-lossless per unsloth's KLD data)
- [ ] ACC-006: Verifies REQ-007 — deployment config records the exact HF
  revision/commit hash used for the base model and for the quant used
- [ ] ACC-007: Verifies REQ-008 — endpoint reachable without credentials
  from the internal network, confirmed intentional (not an oversight)
- [ ] ACC-008: Verifies REQ-009 — engine installed as a systemd service;
  started/stopped/restarted exclusively via `systemctl` throughout testing
  and production use
- [ ] ACC-009: User runs the SAME coding-task examples used for `feat-1`
  (see `feat-1` ACC-010 / Task 1.7) against this endpoint, to compare
  GLM-5.2 quality directly against DeepSeek-V4 on identical inputs

### Scope

What is included in this feature:

- An SM120 correctness spike for GLM-5.2's DSA decode path BEFORE full
  deployment (REQ-010) — reusing `feat-1`'s hard-won SM120 diagnostics
- Deployment of GLM-5.2 on the Dell 7960T as a systemd service, using a
  quantized + GPU/CPU-RAM-hybrid configuration
- Choosing and pinning a specific quant (GGUF or FP8/FP4 checkpoint) at a
  fixed HF revision
- OpenWebUI and OpenCode configured against the endpoint
- Empirical KV-cache/context validation at 350-370K tokens
- Direct quality comparison against `feat-1`'s DeepSeek-V4 using the same
  coding-task examples

What is explicitly out of scope:

- Any use of the DGX Spark for this deployment (excluded per the same
  user decision as `feat-1`)
- Acquiring additional hardware
- Authentication/access-control layer (explicitly accepted as anonymous)
- Fine-tuning or training GLM-5.2 (serving only)
- Retiring or changing the `feat-1` DeepSeek-V4 deployment — the two
  coexist; this feature does not depend on `feat-1` succeeding

### Dependencies

- Depends on: a serving engine with confirmed GLM-5.2 (`glm_moe_dsa`)
  support AND a working SM120 code path for its DSA sparse-attention
  decode — candidates per the vendor card: vLLM v0.23.0+, SGLang
  v0.5.13.post1+, KTransformers v0.5.12+; GPU driver/CUDA compatibility for
  RTX Pro 6000 Blackwell (already validated in `feat-1` Task 0.2: driver
  610.57.04, CUDA 13.3); sufficient local disk on the Dell 7960T for the
  weight set + quant (`feat-1` Task 0.1: /data has 9.3 TB free)
- Related (not a hard dependency): `feat-1`'s in-flight SM120
  sparse-attention-decode diagnostic (Task 1.4). If `feat-1` establishes
  that the SM120 sparse-attention problem is engine-specific (e.g. vLLM
  fails but SGLang works), that finding directly informs REQ-010 here and
  may let this feature skip its own spike.
- Blocks: none

### Design Notes

- **Model facts (verified from HF + unsloth docs 2026-08-19)**:
  `zai-org/GLM-5.2`, MIT license, **744B params / 40B active** (MoE),
  tensor type BF16/F32, architecture tag `glm_moe_dsa` (MoE with DeepSeek
  Sparse Attention). Advertises a "solid 1M-token context" (max
  `1,048,576`), flexible coding thinking-effort levels, and IndexShare
  (reuses one indexer across every four sparse-attention layers, ~2.9x
  fewer per-token FLOPs at 1M context) plus an improved MTP layer for
  speculative decoding. `unsloth/GLM-5.2` is a repackage of the same base
  (`base_model: zai-org/GLM-5.2`), BF16; `unsloth/GLM-5.2-GGUF` holds the
  Dynamic GGUF quants.
- **Quant memory table (unsloth, total = VRAM + RAM or unified)**:
  1-bit `UD-IQ1_S` 223 GB · 2-bit `UD-IQ2_M` 245 GB · 3-bit 290-360 GB ·
  4-bit `UD-Q4_K_XL` 372-475 GB · 5-bit `UD-Q5_K_XL` 570 GB · 8-bit
  `UD-Q8_K_XL` 810 GB. Full BF16 is ~1.5 TB.
- **Quant quality (unsloth KLD / top-1 analysis)**: 4-bit and 5-bit are
  "mostly lossless" (99.9% KLD); 2-bit ≈ 82% top-1, 1-bit ≈ 76% top-1
  (and explicitly NOT "24% gibberish" — mostly filler/stop-word
  distribution shift). Larger quality uplift kicks in from 4-bit onward.
- **Why quantization is required (but NOT a painful compromise here)**:
  744B BF16 (~1.5 TB) exceeds both 384 GB VRAM and the 896 GB VRAM+RAM
  pool, so a quant is mandatory. BUT this box is far larger than unsloth's
  reference (single 24 GB GPU + 256 GB RAM runs 2-bit). At 896 GB total the
  near-lossless **5-bit `UD-Q5_K_XL` (570 GB)** fits with a VRAM+RAM hybrid
  split, and **4-bit `UD-Q4_K_XL` (372-475 GB)** fits even more comfortably
  (low end may fit VRAM-mostly). Target `UD-Q5_K_XL`, fall back to
  `UD-Q4_K_XL`; only drop lower if the 350-370K KV cache forces it. This is
  the opposite of DeepSeek-V4-Pro, which could not avoid a lossy trim.
- **Engine left open until the REQ-010 spike — now THREE candidates**:
  (1) **vLLM** — default (matches `feat-1` runbook), but `feat-1` has an
  OPEN SM120 sparse-attention decode bug (Task 1.4) and GLM-5.2's DSA path
  is the same kernel class, so NOT assumed to work; needs an FP8/FP4
  checkpoint, not GGUF. (2) **SGLang** — distinct SM120 code path, primary
  vLLM alternative. (3) **llama.cpp / `llama-server`** — the strongest
  SM120 Plan B: its GGUF CUDA kernels are a **completely separate codebase**
  from vLLM's FlashInfer sparse-MLA path, so it does not inherit the
  `feat-1` bug at all, and it directly consumes the unsloth Dynamic GGUFs.
  Its risk is weaker OpenAI-compatible tool-calling (REQ-011). KTransformers
  remains a hybrid-size option but is lower priority now that llama.cpp
  covers the GGUF-hybrid case with a simpler path.
- **This is a Pro-class deployment, not a Flash-class one** (quantized +
  VRAM/RAM hybrid), but — unlike `feat-1` Pro — the hardware headroom keeps
  it near-lossless. Reuse Phase 2 thinking from `feat-1`, not Phase 1.
- **Sampling settings (unsloth)**: default `temperature=1.0, top_p=0.95, min_p=0.01`; SWE-Bench-style `temperature=1.0, top_p=1.0`. Note the
  temp=0 greedy smoke test for ACC-002 is a diagnostic for the degenerate
  signature, not the production sampling config.
- **Reuse `feat-1` environment prep.** Disk (Task 0.1), GPU/driver/CUDA
  (Task 0.2), and HF tooling/token (Task 0.3) are already validated on this
  same box; do not repeat them, just reference them.
- **Same non-negotiables as `feat-1`**: pinned HF revision (REQ-007),
  anonymous internal-only endpoint (REQ-008), systemd-only operation
  (REQ-009).
- **Comparison is the point.** ACC-009 reuses the exact `feat-1`
  coding-task examples so GLM-5.2 vs DeepSeek-V4 is an apples-to-apples
  quality call on the user's real workloads.

### Related ADRs

- None (infrastructure/deployment work, tracked in this repo using the
  feature-folder convention, same as `feat-1`)

### Task List

#### Phase 0: Environment prep (mostly inherited from feat-1)

- [ ] Task 0.1: Confirm disk headroom for GLM-5.2 weights + quant on /data (feat-1 Task 0.1 already showed 9.3 TB free; re-check remaining after feat-1's DeepSeek downloads) — depends on: none — status: not-started
- [ ] Task 0.2: Reuse feat-1's validated GPU/driver/CUDA (driver 610.57.04, CUDA 13.3, 4x SM120 GPUs) — no new work unless a different engine needs a different toolchain — depends on: none — status: not-started
- [ ] Task 0.3: Reuse feat-1's HF access/token + download tooling (hf CLI, hf_transfer) — depends on: none — status: not-started
- [ ] Task 0.4: Choose and record pinned HF revision/commit for `zai-org/GLM-5.2` (base) — depends on: Task 0.3 — status: not-started
- [ ] Task 0.5: Select the quant strategy + source and record its pinned revision. Default: unsloth Dynamic GGUF `UD-Q5_K_XL` (target) / `UD-Q4_K_XL` (fallback) from `unsloth/GLM-5.2-GGUF` for a llama.cpp/SGLang path; or an FP8/FP4 checkpoint if vLLM is chosen (vLLM does not consume GGUF) — depends on: Task 0.4 — status: not-started

#### Phase 1: SM120 correctness spike (de-risk REQ-010 BEFORE full deploy)

- [ ] Task 1.1: Pick the engine(s) to spike and their GLM-5.2-supporting versions. Candidates in order of SM120-risk: llama.cpp/llama-server (separate GGUF CUDA path, does NOT inherit feat-1's vLLM sparse-attention bug — strongest Plan B), SGLang (distinct SM120 path), vLLM (default runbook but same broken kernel class as feat-1) — depends on: Task 0.4 — status: not-started
- [ ] Task 1.2: Minimal short-context bring-up of GLM-5.2 on ONE engine at a small quant, temperature=0 greedy smoke test — check specifically for the feat-1 Task 1.4 degenerate signature (single frozen token at every decode position) — depends on: Task 1.1, Task 0.5 — status: not-started
- [ ] Task 1.3: If output is degenerate on the first engine, repeat Task 1.2 on the next engine (llama.cpp vs SGLang vs vLLM is the SM120 sparse-attention discriminator that also informs feat-1) — depends on: Task 1.2 — status: not-started
- [ ] Task 1.4: Record the outcome: which engine(s) produce coherent GLM-5.2 output on SM120, and whether the sparse-attention problem is engine-specific or SM120-fundamental (feed this back into feat-1 Task 1.4) — depends on: Task 1.2, Task 1.3 — status: not-started

#### Phase 2: Full deployment (only if Phase 1 yields a working engine)

- [ ] Task 2.1: Measure actual KV-cache memory per 1K tokens at real context shapes on the chosen engine/quant — depends on: Task 1.4 — status: not-started
- [ ] Task 2.2: Confirm the highest-quality quant that reliably supports 350-370K context with safe margin, based on Task 2.1 (start from UD-Q5_K_XL @ 570 GB in the 896 GB pool; step to UD-Q4_K_XL only if KV headroom demands) — depends on: Task 2.1 — status: not-started
- [ ] Task 2.3: Install the engine + GLM-5.2 as a systemd service with the chosen quant and GPU/CPU-RAM placement — depends on: Task 2.2 — status: not-started
- [ ] Task 2.4: `systemctl start` the service; curl smoke test against `/v1/chat/completions`, verify tool-calls and all 3 reasoning modes (reasoning_effort max/high, enable_thinking:false). If engine is llama.cpp, explicitly verify OpenAI-compatible tool-calling works for OpenCode (REQ-011 risk) — depends on: Task 2.3 — status: not-started
- [ ] Task 2.5: Validate 350-370K-token context works without OOM — depends on: Task 2.4 — status: not-started
- [ ] Task 2.6: Connect OpenWebUI and OpenCode to the GLM-5.2 endpoint as a separate model entry — depends on: Task 2.5 — status: not-started
- [ ] Task 2.7: User runs the SAME coding-task examples from feat-1 (Task 1.7 / ACC-010) against this endpoint for a direct quality comparison — depends on: Task 2.6 — status: not-started

**Note:** If a task's scope changes mid-flight, edit its description in place;
rely on git history (`git log -p` on this file) to recover what was
originally planned, rather than keeping a second copy of the task around.

## Progress

### Current Status

**As of 2026-08-19**: Feature scaffolded in planning phase, not started.
Created as the alternative/fallback model deferred from `feat-1`, after
confirming GLM-5.2 is real on Hugging Face (`zai-org/GLM-5.2`, MIT, 753B
BF16, `glm_moe_dsa`). The critical open question is REQ-010: whether
GLM-5.2's DSA sparse-attention decode path works on this box's SM120 GPUs,
given `feat-1` Task 1.4 is currently blocked on exactly that class of
kernel. Phase 1 is a deliberate spike to answer that before investing in a
full quantized + hybrid deployment. The user is running `feat-1`'s
remaining diagnostic steps (bin/16-bin/20, SGLang test) in parallel; those
results feed directly into Task 1.4 here. Capacity is NOT a concern:
unsloth's data confirms the near-lossless 5-bit quant (570 GB) fits this
box's 896 GB pool, so the only real risk is SM120 correctness — and
llama.cpp offers a Plan B on a separate CUDA code path if vLLM/SGLang fail.

### Next Steps

1. Run the Phase 1 SM120 correctness spike (Task 1.1-1.4) — this gates
   everything else. Do NOT start the ~1.5 TB base download or invest in
   quant selection until at least one engine is shown to produce coherent
   GLM-5.2 output on SM120.
2. Fold in any finding from `feat-1`'s parallel SM120/SGLang work — if that
   already proves vLLM-vs-SGLang behaviour on SM120 sparse attention, Task
   1.3 here may be skippable.
3. Only after Phase 1 passes: Phase 0.4/0.5 pinning, then Phase 2 full
   deployment.

### Blockers

- [ ] **REQ-010 unproven: GLM-5.2 DSA decode on SM120 is unverified** —
  impact: the whole feature depends on it; GLM-5.2 uses the same class of
  sparse-attention kernel that blocks `feat-1` Task 1.4 on these exact
  SM120 GPUs. Mitigation: Phase 1 spike de-risks this before any large
  download or quant work; `feat-1`'s parallel SGLang/SM120 diagnostic may
  resolve it first.

### Recent Updates

#### 2026-08-19

- Completed: Confirmed GLM-5.2 exists on HF (`zai-org/GLM-5.2`, MIT, 753B
  BF16, arch `glm_moe_dsa` = MoE + DeepSeek Sparse Attention; `unsloth/GLM-5.2`
  is a repackage of the same base). Reviewed vendor engine support (vLLM
  v0.23.0+, SGLang v0.5.13.post1+, KTransformers v0.5.12+) and coding
  benchmarks (SWE-bench Pro 62.1, Terminal Bench 2.1 81.0, DeepSWE 46.2 —
  ahead of DeepSeek-V4-Pro on most coding/agentic rows).
- Completed: Created this feature folder from the deferred `feat-1` GLM-5.2
  fallback, with REQ-006 relaxed (GGUF requant accepted) scoped to GLM-5.2
  only, per the 2026-08-19 `feat-1` decision.
- Completed: Reviewed unsloth's "How to Run Locally" guide. Corrected model
  size to 744B/40B-active. Captured the quant memory table + KLD quality
  data: 4-bit/5-bit are near-lossless, and at 896 GB total this box fits
  `UD-Q5_K_XL` (570 GB) / `UD-Q4_K_XL` (372-475 GB) with room — so GLM-5.2
  needs NO lossy compromise (opposite of DeepSeek-V4-Pro). Added llama.cpp
  as a first-class third engine candidate (separate GGUF CUDA path that does
  not inherit feat-1's vLLM SM120 sparse-attention bug), with its weaker
  tool-calling logged as REQ-011. Captured unsloth's sampling +
  reasoning-mode flags for REQ-004/ACC-004.
- Next: Phase 1 SM120 correctness spike (lead with llama.cpp — lowest SM120
  risk + directly consumes the unsloth GGUF).
- Notes: This feature intentionally leads with a correctness spike, not
  environment prep, because the dominant risk is SM120 sparse-attention
  correctness, not capacity.

### Decisions Made

- **2026-08-19**: Created as a standalone feature (`feat-2`), separate from
  `feat-1`'s DeepSeek-V4 work — the GLM-5.2 fallback was explicitly
  deferred to a future feature in `feat-1`, and the two models coexist
  rather than one replacing the other.
- **2026-08-19**: GGUF requant accepted for GLM-5.2 (REQ-006), scoped to
  this model only — carried over from the `feat-1` decision. GLM-5.2 has no
  native sub-BF16 checkpoint that fits this hardware, so a quantized build
  is required, not merely tolerated. DeepSeek-V4 in `feat-1` stays
  native-weights-only.
- **2026-08-19**: Lead with an SM120 correctness spike (Phase 1, REQ-010)
  BEFORE environment prep / large downloads / quant selection. GLM-5.2's
  DSA sparse-attention decode is the same class of kernel currently
  blocking `feat-1` Task 1.4 on these SM120 GPUs; a GLM pivot does not
  automatically escape that risk, so it must be proven first.
- **2026-08-19**: Treat GLM-5.2 as a Pro-class quantized + GPU/CPU-RAM
  hybrid deployment (like `feat-1` Pro/ktransformers), NOT a Flash-class
  VRAM-only one — dictated by the 753B BF16 (~1.5 TB) footprint vs 384 GB
  VRAM / 896 GB total pool.
- **2026-08-19**: Engine left open pending the Phase 1 spike — vLLM default
  (operational familiarity + existing runbook), SGLang primary alternative
  (distinct SM120 code path), KTransformers the hybrid-size candidate.
- **2026-08-19**: Reuse `feat-1`'s already-validated environment prep
  (disk, GPU/driver/CUDA, HF tooling) rather than repeating it — same box.
- **2026-08-19**: Carry over `feat-1`'s non-negotiables — pinned HF
  revision (REQ-007), anonymous internal-only endpoint (REQ-008),
  systemd-only operation (REQ-009).
- **2026-08-19**: Quality comparison against DeepSeek-V4 uses the exact
  same coding-task examples as `feat-1` (ACC-009 mirrors `feat-1`
  ACC-010 / Task 1.7) for an apples-to-apples call.
- **2026-08-19 (post unsloth review)**: Quant target set to near-lossless
  `UD-Q5_K_XL` (570 GB), fallback `UD-Q4_K_XL` (372-475 GB) — both fit the
  896 GB pool per unsloth's memory table, and both are ~99.9% KLD (mostly
  lossless). No lossy 1-2 bit level needed; GLM-5.2 does NOT force the
  precision compromise DeepSeek-V4-Pro did. Corrected model size to
  744B/40B-active (was 753B).
- **2026-08-19 (post unsloth review)**: Added llama.cpp/`llama-server` as a
  first-class engine candidate and the preferred Phase 1 spike target — its
  GGUF CUDA kernels are a separate codebase from vLLM's FlashInfer
  sparse-MLA path, so it does NOT inherit `feat-1`'s SM120 sparse-attention
  bug, and it consumes the unsloth Dynamic GGUFs directly. Its one risk
  (weaker OpenAI-compatible tool-calling for OpenCode) is captured as
  REQ-011 and re-verified in ACC-004 if that engine is chosen.
- **2026-08-19 (post unsloth review)**: Reasoning modes are driven by
  `--chat-template-kwargs` (`reasoning_effort` max/high, or
  `enable_thinking:false`); production sampling is `temperature=1.0, top_p=0.95, min_p=0.01` (unsloth defaults). The ACC-002 temp=0 test is a
  degenerate-signature diagnostic only, not the production config.

### Related PRs / Commits

- None yet
  </content>
  </invoke>
