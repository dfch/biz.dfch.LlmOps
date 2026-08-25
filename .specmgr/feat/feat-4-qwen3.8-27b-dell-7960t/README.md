---
created: 2026-08-25
github_issue: 4
id: feat-4-qwen3.8-27b-dell-7960t
status: planning
updated: 2026-08-25
version: 1.0.0
---

# Feature: On-prem Qwen3.8-27B serving with extended context on the Dell 7960T

## Plan

### Overview

Deploy `Qwen/Qwen3.8-27B` (the same model as `feat-3`, dense causal LM + vision
encoder, 27B params, Apache-2.0) via vLLM on the **Dell 7960T** — the box
already hosting `feat-1` (DeepSeek-V4-Flash) and `feat-2` (GLM-5.2) — as a
**dedicated, on-demand** service pinned to a single GPU, at a **fixed 896K
(917,504-token) context** via the vendor's documented YaRN `rope_parameters`
override.

This is explicitly a re-deployment of a model `feat-3` already fully
validated on different hardware (a GB10/DGX-Spark-clone with one **unified**
128GB CPU+GPU memory pool, arm64). The Dell 7960T is a fundamentally
different shape of box: x86_64, **4x RTX PRO 6000 Blackwell Max-Q, 96GB
*discrete* VRAM each (384GB total)**, plus a fully separate 512GB system RAM
pool, and **no NVLink between any of the 4 GPUs** (confirmed via
`nvidia-smi topo -m`: every GPU pair shows `NODE`, i.e. PCIe-through-host-
-bridge only). That changes which of `feat-3`'s hard-won findings transfer
and which don't:

- `feat-3`'s core Phase 2 problem — `--gpu-memory-utilization` silently
  starving the *OS* because VRAM and system RAM share one pool — **cannot
  happen on this box**: VRAM (per-GPU) and system RAM are physically
  separate pools here. Still good practice to size KV cache explicitly, but
  it is not the load-bearing fix it was on the GB10.
- Qwen3.8-27B (~54GB BF16 weights) fits comfortably inside a **single 96GB
  GPU**, unlike `feat-1`'s DeepSeek-V4-Flash, which needs `--tensor-parallel- -size 4` to fit at all. There is no a priori need to span multiple GPUs
  here, and — since none of the 4 GPUs have an NVLink interconnect between
  them — spanning GPUs via tensor-parallel is expected to *add* PCIe
  communication overhead for no capacity benefit, not help throughput. This
  must be measured (Phase 2), not assumed, but the working hypothesis is
  TP=1 wins.
- `feat-1` already found and is currently blocked by an **open, unresolved
  SM120-specific bug** (`vllm-project/vllm#52938`): DeepSeek-V4-Flash on
  these exact RTX PRO 6000 Blackwell GPUs produces degenerate output
  (frozen token / identical logprob at every decode position). `feat-3`'s
  Design Notes assumed this class of bug could not recur on the GB10
  because it uses different GPUs (SM121a, not SM120) — that assumption does
  **not** hold here, since this box has the exact GPU family the bug was
  found on. Qwen3.8-27B's hybrid Gated DeltaNet + Gated Attention layout is
  architecturally different from DeepSeek's sparse MLA attention, but this
  must be **verified, not assumed safe**, before any long-context work —
  hence Phase 1 is a hard gate here, not a formality.
- `feat-1` also already tried upgrading to vLLM 0.27.1 (the version `feat-3`
  pinned on the GB10) and had to **roll it back** — a hard "unsupported
  architecture" DeepGEMM gap for SM120. This feature stays on the box's
  already-working **vLLM 0.26.0** instead of adopting `feat-3`'s 0.27.1 pin.
  Live checks against the box's existing (feat-1) 0.26.0 venv on
  2026-08-25 already confirm this version registers `Qwen3_5ForConditional- Generation`/`Qwen3_5MTP` and has working NVFP4 GEMM kernels
  (`cutlass_scaled_mm_supports_fp4(120)` -> `True`) — see Task 0.2.

Unlike `feat-3`'s BF16-first-then-empirically-evaluate-NVFP4 journey, this
feature goes straight to comparing **BF16 vs NVFP4 vs NVFP4+MTP** at the
fixed 896K context, since `feat-3` already established (on the identical
model) that NVFP4 and MTP both give large, quality-neutral speedups — the
open question here is only how large the effect is on *this* hardware's
different bottleneck profile (dedicated GPU, no shared-pool contention,
different FlashInfer kernel path on SM120 vs. the GB10's SM121a), not
whether to try them at all.

**Isolation is a hard requirement, not a preference**: this feature's
install (venv, launch scripts, systemd units) must be fully independent of
`feat-1`'s `/data/vllm/.venv` — changing or upgrading anything in this
feature's dedicated `/data/qwen3.8-27b/` tree must never have side effects
on `feat-1` or `feat-2`, and vice versa. The only shared state is the
read-only Hugging Face download cache (`/data/nvidia/hf_cache`), which
carries no such coupling risk.

Every service this feature installs is **on-demand only** — started and
stopped exclusively by the user via `systemctl --user`, never auto-started
at boot, and with no single service auto-promoted to "the" production
default the way `feat-3` ended up doing after its own precision journey.
The user decides which variant (BF16 or NVFP4[+MTP]) runs at any given
time.

### Requirements

- REQ-001: Serve Qwen3.8-27B via an OpenAI-compatible API
  (`/v1/chat/completions`) on the Dell 7960T, using vLLM, pinned to a single
  dedicated GPU (GPU2, by UUID) by default. If TP=2 (GPU2+GPU0, the box's
  two PCIe Gen5 x16 cards) is empirically shown to be faster (Phase 2),
  that becomes the pinned config instead — TP=4 (spanning all 4 GPUs, as
  `feat-1` does) is out of scope, since the model does not need the extra
  VRAM and doing so would prevent any coexistence with `feat-1`/`feat-2`
- REQ-002: The endpoint(s) must support a **fixed** context length of
  917,504 tokens (896K) via the vendor's documented YaRN `rope_parameters`
  override (factor 3.5) — no 768K-floor/1M-ceiling step-up exploration is
  in scope; 896K is the sole target, already proven sufficient and working
  on this exact model architecture by `feat-3`
- REQ-003: The endpoint(s) must support tool-calling (required for OpenCode
  agentic use) and correctly expose Qwen3.8's thinking controls:
  `enable_thinking` (on by default), `reasoning_effort`
  (`xhigh`/`medium`/`low`), and `preserve_thinking` — identical bar to
  `feat-3` REQ-004
- REQ-004: Empirically compare **BF16**, **NVFP4**, and **NVFP4 + MTP
  speculative decoding** at the fixed 896K/YaRN context, on this hardware.
  Adopt NVFP4 (optionally +MTP) as an available on-demand option only if it
  clears a measurable throughput improvement with no observed correctness
  regression (MTP's acceptance/verification step must be lossless —
  byte-identical greedy output vs. the non-MTP run at temperature=0, same
  bar `feat-3` Task 6.3 used) — mirrors `feat-3` REQ-005's "not adopted by
  default" bar, but MTP is explicitly requested up front for this feature
  (not gated behind a separate "is it worth it" decision the way it was
  for `feat-3`)
- REQ-005: Engine = vLLM, pinned to **0.26.0** (the version already
  installed and validated on this box's SM120 GPUs by `feat-1`) — **not**
  `feat-3`'s 0.27.1 pin, since `feat-1` already found that version regresses
  on this exact hardware (DeepGEMM/architecture-support gap for SM120).
  Installed in a **fully separate, dedicated venv**
  (`/data/qwen3.8-27b/.venv`), isolated from `feat-1`'s `/data/vllm/.venv`
- REQ-006: Pin `Qwen/Qwen3.8-27B` (BF16) and `unsloth/Qwen3.8-27B-NVFP4` to
  specific Hugging Face revisions/commits (not "latest") for reproducibility
  — reuse `feat-3`'s already-vetted NVFP4 revision
  (`7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108`) if still current at download
  time, re-verify the tokenizer-truncation fix is present either way; pin
  the BF16 revision fresh at download time
- REQ-007: The endpoint(s) run unauthenticated (anonymous, no API-key/auth
  layer) — accepted risk, internal network only (same posture as
  `feat-1`/`feat-2`/`feat-3`)
- REQ-008: Every engine variant runs exclusively as an **on-demand**
  systemd `--user` service (lingering enabled) — never auto-started at
  boot, never run as an ad-hoc foreground process, including during
  testing. The user starts/stops each variant explicitly via `systemctl --user`; no variant is ever auto-selected as "production" by default
- REQ-009: This feature's deployment must be **fully isolated** from
  `feat-1` (DeepSeek-V4) and `feat-2` (GLM-5.2): separate venv, separate
  launch scripts, separate systemd unit files, under a dedicated
  `/data/qwen3.8-27b/` tree — so that installing, upgrading, restarting, or
  debugging this feature's services has zero side effects on the other two
  features' services, and vice versa. The only permitted shared state is
  the read-only Hugging Face download cache (`/data/nvidia/hf_cache`), by
  explicit choice (it carries no code/package coupling risk)
- REQ-010: Before any long-context or precision work, run a native/short-
  context correctness smoke test that **explicitly checks for the exact
  degenerate-output signature** (a single frozen token / identical logprob
  repeated at every decode position) found on this same GPU family by
  `feat-1`'s open, unresolved bug (`vllm-project/vllm#52938`). This is a
  **hard gate**, not a formality — unlike `feat-3`'s GB10 (a different GPU
  family where this specific bug class does not apply), this box has the
  exact hardware the bug was found on
- REQ-011: Determine empirically (not assumed) whether GPU2-only (TP=1) or
  GPU2+GPU0 (TP=2, the box's two PCIe Gen5 x16 cards) gives better decode
  throughput. Since `nvidia-smi topo -m` confirms **no NVLink between any
  of the 4 GPUs** (every pair shows `NODE`, PCIe-through-host-bridge only),
  TP>1 is expected to add communication overhead without a capacity
  benefit — pin production to **GPU2-only (TP=1)** unless TP=2 is
  measurably faster
- REQ-012: YaRN `rope_parameters` override configured exactly per the
  vendor's documented shape, reused verbatim from `feat-3` REQ-011 (it is
  model-specific, not hardware-specific): `mrope_interleaved`,
  `mrope_section`, `rope_type: yarn`, `rope_theta`,
  `partial_rotary_factor: 0.25`, `factor: 3.5` (fixed, since REQ-002 fixes
  the target context at 896K), `original_max_position_embeddings: 262144`
- REQ-013: Vision/video (image+video understanding) capability is
  explicitly OUT of scope for testing/validation in this feature — text/
  coding only (same as `feat-3` REQ-012)

### Acceptance Criteria

- [x] ACC-001: Verifies REQ-001/REQ-011 — Qwen3.8-27B running via vLLM on
  the Dell 7960T, reachable via `/v1/chat/completions`, pinned to GPU2 (or
  GPU2+GPU0 if TP=2 is empirically chosen instead), with the GPU-pinning
  decision backed by measured decode-throughput numbers, not assumed;
  `feat-1`/`feat-2`'s existing services and GPUs untouched — **done
  2026-08-25**: TP=2 (GPU2+GPU0) confirmed via Task 2.1's measured
  +64%/-31%/-41% numbers (Task 2.2); production unit
  `qwen3.8-27b-bf16-896k.service` reachable via `/v1/chat/completions`
  (Task 5.2); `feat-1`/`feat-2` confirmed untouched throughout (Task 0.5
  baseline, no shared state beyond the read-only HF cache)
- [x] ACC-002: Verifies REQ-002/REQ-012 — the endpoint serves the fixed
  917,504-token (896K) context via the exact YaRN `rope_parameters`
  override (factor 3.5), validated with a real filled-context request
  (built from the model's own tokenizer, not a synthetic estimate) that
  completes without OOM — **done 2026-08-25**: Task 3.3's real
  906,159-token request completed with `content: "Dell"` (correct fact
  recall), `finish_reason: "stop"`, no OOM; `/v1/models` on the
  production unit confirms `max_model_len: 917504`
- [x] ACC-003: Verifies REQ-003 — tool-calling and all three thinking-
  control modes (`enable_thinking: false`, `reasoning_effort: medium`,
  `reasoning_effort: xhigh`) verified via curl smoke test against every
  on-demand service variant that is ultimately installed (BF16, and
  NVFP4[+MTP] if adopted) — **done 2026-08-25**: only BF16 was ultimately
  installed (Task 4.5's decision), and Task 5.2 ran the full smoke test
  against that exact production unit: clean tool-call, all three
  thinking modes correctly scaled (0/44/125-char reasoning), all
  producing the correct answer
- [x] ACC-004: Verifies REQ-004 — a recorded BF16 vs. NVFP4 vs. NVFP4+MTP
  throughput comparison at the fixed 896K/YaRN context, with the final
  precision/MTP decision and its one-line rationale recorded; if MTP is
  adopted, its output is confirmed byte-identical (lossless) vs. the
  non-MTP run at temperature=0 on the same prompt — **done 2026-08-25**:
  Task 4.1 recorded the BF16-vs-NVFP4 comparison (both cheap-context and
  real-896K, exact absolute numbers); Task 4.5 recorded the final
  decision (BF16 only) and its rationale. The MTP leg was never run
  (explicit user decision after reviewing Task 4.1's numbers, before
  Task 4.2 was attempted) — the "if MTP is adopted" clause is therefore
  vacuously satisfied, not skipped: MTP was not adopted, so no
  byte-identical check was required
- [x] ACC-005: Verifies REQ-005 — vLLM 0.26.0 confirmed as the deployment
  engine version, installed in the dedicated `/data/qwen3.8-27b/.venv`,
  with the `qwen3_5` architecture and NVFP4 kernel support re-verified
  inside that specific venv (not just inferred from `feat-1`'s venv) —
  **done 2026-08-25**: Task 0.3 re-verified all three checks
  (`Qwen3_5ForConditionalGeneration`/`Qwen3_5MTP` registry,
  `cutlass_scaled_mm_supports_fp4(120)`, full CLI flag set) inside this
  feature's own dedicated venv, not `feat-1`'s
- [x] ACC-006: Verifies REQ-006 — deployment config records the exact HF
  revision/commit hash used for both the BF16 and NVFP4 checkpoints —
  **done 2026-08-25**: Task 0.6 recorded
  `Qwen/Qwen3.8-27B@1d4bf0f2ff6012fd82039f2fa52739d0dd7c60c0` (BF16) and
  `unsloth/Qwen3.8-27B-NVFP4@7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108`
  (NVFP4, reused verbatim from `feat-3` after re-verification); the
  production unit's `ExecStart --revision` flag pins the BF16 one
  explicitly
- [ ] ACC-007: Verifies REQ-007 — endpoint(s) reachable without credentials
  from the internal network, confirmed intentional (not an oversight) —
  **partially confirmed**: no `--api-key`/auth flag exists in any
  service unit this feature installed (by design, matching REQ-007's
  accepted-risk posture, same as `feat-1`/`feat-2`/`feat-3`), and every
  curl smoke test in this feature (Task 1.2, Task 5.2) succeeded without
  credentials — but those tests were all run from the box itself
  (`localhost`); reachability from a genuinely separate host on the
  internal network has not been separately tested, since this session
  only had shell access on the Dell 7960T itself, not a second client
  machine
- [x] ACC-008: Verifies REQ-008/REQ-009 — every installed service is a
  `systemctl --user` unit, left `disabled` (never auto-starts at boot),
  started/stopped exclusively via `systemctl --user` throughout testing;
  the dedicated `/data/qwen3.8-27b/` install tree is confirmed independent
  of `/data/vllm/.venv` (`feat-1`) and `feat-2`'s install tree — **done
  2026-08-25**: Task 5.1/5.2 confirm the production unit is `disabled`
  with no `default.target.wants/` symlink; Task 0.3 confirms the isolated
  venv tree
- [x] ACC-009: Verifies REQ-010 — the native/short-context smoke test
  explicitly checked for and did not reproduce `feat-1`'s SM120 degenerate-
  output signature, before any YaRN/precision work began — **done
  2026-08-25**: Task 1.2/1.3, confirmed NOT reproduced, hard gate cleared
  before Phase 2 started
- [x] ACC-010: Verifies REQ-013 — vision/video capability explicitly not
  tested/validated in this feature (scope confirmation, not a functional
  check)

### Scope

What is included in this feature:

- A dedicated, fully isolated Phase 0 environment build on the Dell
  7960T (`/data/qwen3.8-27b/.venv`, vLLM 0.26.0) — independent of `feat-1`'s
  existing `/data/vllm/.venv`
- A native-context correctness smoke test explicitly checking for
  `feat-1`'s known SM120 degenerate-output signature, before any long-
  -context or precision work (hard gate, per REQ-010)
- An empirical TP=1 (GPU2-only) vs. TP=2 (GPU2+GPU0) decode-throughput
  comparison, to decide GPU pinning (REQ-011)
- Applying and validating the YaRN-based 896K context extension (fixed
  target, no step-up/down sweep) per the vendor's documented
  `rope_parameters` override
- An empirical BF16 vs. NVFP4 throughput comparison at both a cheap
  sanity context and the fixed 896K/YaRN context (Task 4.1) — this
  comparison is what decided NOT to pursue NVFP4/MTP further, per REQ-004
  (see Task 4.5)
- One on-demand, disabled `systemctl --user` service — BF16 at 896K, the
  sole adopted variant — that the user starts/stops manually
- Pinning both the BF16 and NVFP4 checkpoints to fixed HF revisions (the
  NVFP4 checkpoint was downloaded and benchmarked per Task 0.6/Task 4.1
  even though it was ultimately not adopted as a service)
- An OpenCode provider snippet for the installed BF16 896K service

What is explicitly out of scope:

- Any modification to `feat-1` (DeepSeek-V4) or `feat-2` (GLM-5.2)'s
  deployments, venvs, systemd units, or GPU allocation beyond GPU2 (and
  GPU0, only if TP=2 is chosen) — this feature runs only on GPU2 (+GPU0 if
  needed) and does not touch the other two features
- 768K or 1M context sizes — REQ-002 fixes the target at 896K only, no
  step-up/down exploration (explicit user decision, given 896K is already
  proven sufficient and working on this model by `feat-3`)
- A Q8/FP8 weight-quantization comparison leg — explicitly dropped in
  favor of BF16 vs. NVFP4(+MTP) only (explicit user decision)
- NVFP4 and NVFP4+MTP as installed/adopted service variants — Task 4.1's
  measurement at the fixed 896K/YaRN context showed no throughput
  advantage over BF16 there (despite a real +54% win at a cheap 8192
  context), and the user made an explicit 2026-08-25 decision to stop
  investing in the NVFP4 branch entirely on that basis, without running
  Task 4.2's MTP leg — BF16 is the sole production precision (see Task
  4.5)
- Any single service being auto-promoted to "the" production default —
  the one adopted BF16 variant stays on-demand and user-started (unlike
  `feat-3`, which ended up cutting BF16 over to a single always-adopted
  NVFP4+MTP production service)
- Testing or validating vision-language (image/video) capability (REQ-013)
- Fine-tuning or training Qwen3.8-27B (serving only)
- Authentication/access-control layer (explicitly accepted as anonymous)
- OpenWebUI wiring (deferred/optional, same precedent as `feat-3`)
- Ollama/llama.cpp/GGUF as the serving path — same rationale as `feat-3`:
  the vendor's YaRN long-context documentation only covers vLLM, SGLang,
  and TokenSpeed, and Qwen3.8-27B's hybrid Gated DeltaNet + partial-rotary/
  mrope architecture is judged too high-risk for an independent llama.cpp
  YaRN re-implementation

### Dependencies

- Depends on: the Dell 7960T's existing driver/CUDA stack (already
  installed and validated by `feat-1`/`feat-2` — driver 610.57.04, CUDA
  13.3, 4x RTX PRO 6000 Blackwell Max-Q/SM120, confirmed live 2026-08-25,
  see Task 0.2); a fresh, fully isolated vLLM 0.26.0 venv (Task 0.3) — NOT
  inherited from `feat-1`'s `/data/vllm/.venv`, built independently to
  guarantee REQ-009's isolation; HF access/download tooling (already
  present and working per `feat-1`'s cache under `/data/nvidia/hf_cache`);
  sufficient disk headroom under `/data` (7TB free confirmed 2026-08-25 —
  trivial for ~54GB BF16 + ~23GB NVFP4)
- Related (not a hard dependency): `feat-1`'s **open, unresolved** SM120
  degenerate-output bug (`vllm-project/vllm#52938`) — directly relevant
  here (same GPU family), unlike `feat-3`'s GB10 (different GPU, the bug
  does not apply there) — see REQ-010; `feat-1`'s vLLM 0.27.1 rollback
  finding (DeepGEMM/SM120 regression) — directly informs REQ-005's version
  pin; `feat-3`'s already-published YaRN factor-table entry for 896K
  (factor 3.5), NVFP4 checkpoint pin, and MTP methodology — reused
  verbatim wherever a finding is architecture-driven rather than hardware-
  -driven (`feat-3` Task 6.2 step 4 already showed KV-cache token capacity
  at a given context is architecture-driven, not precision- or hardware-
  -pool-driven, though it must still be re-measured on this box's discrete-
  -VRAM GPU rather than assumed identical to the GB10's unified-pool
  numbers)
- Blocks: none

### Design Notes

- **Model facts**: identical to `feat-3` — `Qwen/Qwen3.8-27B`, Apache-2.0,
  dense causal LM + vision encoder, 27B language-model params (28B total on
  disk, BF16 safetensors). Hybrid layout: 16x (3x (Gated DeltaNet -> FFN)
  -> 1x (Gated Attention -> FFN)), 64 layers total. Native context 262,144,
  extensible via YaRN. See `feat-3`'s Design Notes for the full
  architectural detail — not repeated here.

- **Hardware verified live on this box, 2026-08-25** (all read-only checks,
  no state changed): 4x RTX PRO 6000 Blackwell Max-Q, 96GB VRAM each, all
  idle (0 MiB used) at check time; driver 610.57.04, CUDA (nvidia-smi)
  13.3; `nvidia-smi topo -m` shows `NODE` (PCIe-through-host-bridge, no
  NVLink) between every one of the 6 GPU pairs; per-GPU PCIe generation:
  GPU0 and GPU2 are Gen5 x16, GPU1 and GPU3 are Gen4 x16
  (`pcie.link.gen.max`); GPU2 chosen over GPU0 for the default single-GPU
  pin because `hardware/dell-7960t/configuration.md` notes GPU0
  occasionally holds an Ollama-resident model (~43GB) — no Ollama
  process/service was found running on the box at check time, but GPU2 is
  the cleaner choice to avoid that class of contention recurring later.

- **Why no NVLink changes the multi-GPU calculus vs. `feat-1`**: `feat-1`'s
  DeepSeek-V4-Flash *needs* `--tensor-parallel-size 4` just to fit the
  model at all — TP is load-bearing there regardless of interconnect
  quality. Qwen3.8-27B does not need the extra VRAM (54GB BF16 fits one
  96GB GPU with room to spare for a 896K KV cache), so TP here is purely a
  throughput question, and with no NVLink between any GPU pair, splitting
  compute across GPUs was expected to add real PCIe communication latency
  per decode step for no offsetting capacity gain — the working hypothesis
  going into Phase 2 was that TP=1/GPU2-only wins or ties TP=2, not that
  TP=2 helps. **Superseded by Task 2.1's measurement (2026-08-25): this
  hypothesis was WRONG.** TP=2 (GPU2+GPU0) beat TP=1 by +64% output
  throughput and -31%/-41% TTFT/TPOT at BF16/8192-context/1024-in-512-out
  — at this precision/context, compute is evidently the bottleneck, not
  inter-GPU communication, so the PCIe-only interconnect's added latency
  is outweighed by having twice the compute available. Production is
  pinned to GPU2+GPU0 (TP=2) — see Task 2.2. Left this paragraph in place
  (rather than deleting it) precisely because the "measure, don't assume"
  methodology this feature otherwise preaches is best illustrated by a
  hypothesis that turned out to be wrong once actually measured.

- **Post-completion follow-up (2026-08-25): does TP=2's win hold for a
  SINGLE request, and would TP=4 help further?** Asked after the feature's
  core scope (Phases 0-6.1) was already done. Two sub-findings:

  - **Single-request (concurrency=1) latency, TP=1 vs. TP=2, matched
    1024-in/512-out/8192-context shape**: TP=2 wins decisively here too,
    not just under Task 2.1's 64-concurrent-request batched load — mean
    TTFT 218.41 ms (TP=2) vs. 281.97 ms (TP=1, −23%); mean TPOT 20.37 ms
    vs. 37.71 ms (**−46%, ~1.85x faster decode**). Confirms the workload
    is genuinely compute-bound even at batch size 1: the per-token
    all-reduce payload TP requires (one ~10 KB BF16 hidden-state vector
    per layer) is small enough that PCIe-only (no NVLink) synchronization
    does not erase the benefit of halving each layer's GEMM FLOPs across
    2 GPUs. Logs:
    `bin/baselines/2026-08-25-single-request-tp{1,2}.log`.

  - **TP=3 is not a valid configuration for this model** — checked before
    testing, not assumed: Qwen3.8-27B has only 4 KV heads (GQA,
    `num_key_value_heads: 4` in `config.json`), and vLLM's tensor-parallel
    sharding requires the TP size to divide the KV-head count evenly;
    only TP=1/2/4 are possible, TP=3 is architecturally excluded.

  - **TP=4 first attempt was NOT successfully measured** — attempting it
    triggered a real hardware/driver incident (GPU1 dropped off the PCIe
    bus mid-warmup, cascading NVRM RPC failures on GPU3), not a benign
    software/config bug. Full incident detail logged in
    `hardware/dell-7960t/recovery.md`'s "Incident log" section (this is a
    box-wide hardware concern, not feature-specific, hence logged there
    rather than only here).

  - **TP=4 re-attempt, after the hardware fault was physically fixed
    (2026-08-25, same day)**: re-ran the *exact same* diagnostic unit
    (`qwen3.8-27b-bf16-tp4-bench.service`, unchanged) with close
    monitoring through the exact warmup window that crashed last time
    (kernel-log tailing + GPU polling every ~6s). This time it came up
    completely cleanly — engine init/graph-capture/warmup completed in
    78.68s with zero NVRM/Xid errors, `/health` returned 200 within 3s of
    the server starting, `/v1/models` responded correctly. Ran the same
    `vllm bench serve` methodology as Task 2.1
    (`--backend openai-chat --tokenizer Qwen/Qwen3.8-27B --dataset-name random --random-input-len 1024 --random-output-len 512 --num-prompts 128 --max-concurrency 64 --request-rate inf --ignore-eos`), 128/128 requests
    succeeded, 0 failures:

    | metric | TP=1 (GPU2) | TP=2 (GPU2+GPU0) | TP=4 (all 4 GPUs) |
    |---|---|---|---|
    | Output tok/s | 746.35 | 1222.74 | 1215.93 |
    | Total tok/s | 2315.41 | 3793.33 | 3772.19 |
    | Req/s | 1.46 | 2.39 | 2.37 |
    | Mean TTFT (ms) | 7144 | 4953 | 5389.58 |
    | Mean TPOT (ms) | 71.74 | 42.63 | 42.09 |

    **TP=4 essentially ties TP=2 — it does NOT deliver the further
    ~1.5-1.8x this Design Notes entry previously flagged as an
    unverified extrapolation.** Every metric is within ~1-9% of TP=2
    (TTFT is actually 9% worse; output/total tok/s and req/s are
    ~0.5-0.9% lower; TPOT is ~1.3% better, within noise for n=128). The
    TP=1→TP=2 near-linear scaling (Task 2.1) does not continue into
    TP=2→TP=4 — going from 2 to 4 GPUs adds no further throughput or
    latency benefit at this model/precision/context (BF16, 8192 ctx,
    1024-in/512-out, 64 concurrency). Plausible explanation (not
    independently verified): Qwen3.8-27B's GQA has only 4 KV heads, and
    the model is small enough (27B) that 2 GPUs already saturate
    whatever compute-bound advantage TP offers here — a 4-way split adds
    proportionally more communication overhead per layer without a
    matching per-GPU compute reduction once the per-GPU compute is
    already small. Full log:
    `bin/baselines/2026-08-25-task-tp4-bench.log`. Diagnostic service
    stopped afterward, all 4 GPUs confirmed freed, zero NVRM/Xid errors
    throughout the entire attempt (kernel log monitored live end-to-end).
    TP=4 remains out of this feature's production scope regardless
    (REQ-001) — this was a pure research probe, not a step toward
    changing that scope; the number now exists, but it argues against
    TP=4, not for it.

- **Why `feat-1`'s open SM120 bug is a real (not theoretical) risk here,
  unlike for `feat-3`**: `feat-1`'s bug
  (`vllm-project/vllm#52938`) is specific to SM120 (this box's GPU family)
  and DeepSeek-V4-Flash's sparse MLA attention kernel
  (`FLASHINFER_MLA_SPARSE_DSV4`). Qwen3.8-27B's Gated DeltaNet + Gated
  Attention layout is a different kernel path, so there is no strong
  reason to expect the *same* bug to recur — but there is also no
  vLLM/FlashInfer track record yet of this specific architecture running
  cleanly on SM120 at all (it was only ever validated on `feat-3`'s SM121a
  GB10). Phase 1's smoke test exists specifically to close this gap before
  any further investment, mirroring the exact check `feat-3` ran on the
  GB10 for the same reason (new platform, new architecture, verify before
  extending).

- **Why staying on vLLM 0.26.0, not `feat-3`'s 0.27.1**: `feat-1`'s
  Decisions Made record a trial upgrade to 0.27.1 (with flashinfer 0.6.17)
  that was rolled back after hitting a hard, unconditional "unsupported
  architecture" DeepGEMM gap for SM120. Since this box's GPUs are SM120
  (not `feat-3`'s SM121a, where 0.27.1 was required for `qwen3_5`/NVFP4
  support), there is no reason to take on that known regression here — the
  box's already-installed 0.26.0 was live-checked on 2026-08-25 (against
  `feat-1`'s existing venv, as a fast proxy) and already registers
  `Qwen3_5ForConditionalGeneration`/`Qwen3_5MTP`, has working NVFP4 GEMM
  kernels (`cutlass_scaled_mm_supports_fp4(120)` -> `True`), and exposes
  every CLI flag this feature needs (`--kv-cache-dtype`,
  `--kv-cache-memory-bytes`, `--hf-overrides`, `--speculative-config`,
  `--tensor-parallel-size`, `--served-model-name`, `--tool-call-parser qwen3_xml`, `--reasoning-parser`, `--linear-backend`). Task 0.3 still
  re-runs these same checks inside the feature's own dedicated venv before
  trusting them for real (REQ-009 isolation means the existing venv's
  state is only a proxy, not a substitute).

- **Isolation implementation**: dedicated tree `/data/qwen3.8-27b/`
  contains its own `.venv`, launch scripts, and (via
  `~/.config/systemd/user/`) its own systemd unit files — no file or
  package under this tree is shared with `/data/vllm/.venv` (`feat-1`) or
  `feat-2`'s `/data/llama.cpp-dsa` tree. The single deliberate exception is
  the read-only Hugging Face download cache (`HF_HOME=/data/nvidia/hf_cache`,
  matching `feat-1`'s existing convention) — a cache directory carries no
  code/package coupling risk, so sharing it does not violate REQ-009.

- **YaRN config (fixed, not a table)**: since REQ-002 fixes the target
  context at 896K (917,504 tokens), only one factor value is needed —
  `factor: 3.5` — reused verbatim from `feat-3`'s vendor-documented
  override shape:
  `{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 3.5, "original_max_position_embeddings": 262144}}}`
  passed via `--hf-overrides` (needs `VLLM_ALLOW_LONG_MAX_MODEL_LEN=1`).

- **On-demand-only service model (explicit user decision, differs from
  `feat-3`)**: `feat-3` started with multiple disabled services and ended,
  after its own precision journey, with exactly one auto-promoted
  "production" service (NVFP4+MTP at 896K) and the rest kept as disabled
  fallbacks. This feature does **not** converge to a single default —
  every adopted variant (BF16, and NVFP4[+MTP] if it clears REQ-004's bar)
  stays installed as its own disabled, on-demand `systemctl --user` unit,
  and the user decides at any given time which one (if any) is running.
  This also means, unlike `feat-3`, there is no expectation that this
  feature's service(s) run continuously — coexistence with `feat-1`/
  `feat-2` is handled by keeping this feature's GPU footprint to GPU2 (or
  GPU2+GPU0) only, not by any runtime scheduling logic.

- **NO environment inheritance from `feat-1`/`feat-2`'s venvs/install
  trees**, by design (REQ-009) — the only things inherited are the box's
  driver/CUDA stack (already shared infrastructure, not a venv), the
  shared HF cache directory (deliberate, low-risk exception), and
  practice/precedent (systemd `--user`-lingering pattern, HF-pin
  discipline, no-auth internal posture, "measure don't assume" capacity
  methodology) from `feat-1`/`feat-2`/`feat-3`.

- **Model-architecture-driven findings reused verbatim from `feat-3`**
  (i.e., not hardware-pool-dependent, so no need to re-derive): the YaRN
  `rope_parameters` override shape and factor-to-context mapping; the
  `qwen3_xml` tool-call-parser / `qwen3` reasoning-parser choice (derived
  from the model's own `chat_template.jinja`, not from GB10-specific
  behavior); the NVFP4 checkpoint's mixed quantization scheme (NVFP4 MLPs,
  FP8 attention/`lm_head`/last-8-layers, MTP draft head bundled in the
  same `unsloth/Qwen3.8-27B-NVFP4` repo, no separate `speculative-config "model"` field needed); the tokenizer-truncation-bug check (`tokenizer. json`'s `truncation` field must be `null`) before trusting a downloaded
  NVFP4 revision. **Not** reused as-is, requires fresh measurement on this
  box: KV-cache byte-per-token/capacity/headroom numbers (different memory
  pool shape), decode/prefill throughput numbers (different GPU, no shared-
  -pool contention, possibly different FlashInfer kernel selection on
  SM120 vs. SM121a), and the TP=1-vs-TP=2 question (`feat-3` never tested
  multi-GPU at all, since the GB10 only has one GPU).

### Related ADRs

- None (infrastructure/deployment work, tracked in this repo using the
  feature-folder convention, same as `feat-1`/`feat-2`/`feat-3`)

### Task List

#### Phase 0: Environment prep (dedicated, isolated install)

- [x] Task 0.1: Confirm disk headroom under `/data` for the new dedicated
  tree plus BF16 (~54GB) and NVFP4 (~23GB) weights — depends on: none —
  status: done 2026-08-25 — `/data` (`/dev/md126`) has 7.0 TB free of
  15 TB (53% used) — trivial, no cleanup required
- [x] Task 0.2: Confirm the Dell 7960T's existing driver/CUDA are installed
  and working, AND — as a fast read-only proxy check before building the
  feature's own isolated venv — confirm the box's existing (`feat-1`)
  vLLM 0.26.0 install already supports Qwen3.8-27B's architecture and
  NVFP4 kernels on SM120 — depends on: none — status: done 2026-08-25 —
  driver 610.57.04 / CUDA (nvidia-smi) 13.3 confirmed, matches
  `hardware/dell-7960t/configuration.md`; `/data/vllm/.venv`'s vLLM 0.26.0
  registers `Qwen3_5ForConditionalGeneration`/`Qwen3_5MTP` in its
  `ModelRegistry`; `cutlass_scaled_mm_supports_fp4(120)` returns `True`
  (compute capability confirmed `(12, 0)` on all 4 GPUs); `vllm serve --help=all` confirms every CLI flag this feature needs is present
  (`--kv-cache-dtype` incl. `fp8`/`nvfp4`, `--kv-cache-memory-bytes`,
  `--hf-overrides`, `--speculative-config`, `--tensor-parallel-size`,
  `--served-model-name`, `--tool-call-parser qwen3_xml`,
  `--reasoning-parser`, `--enable-auto-tool-choice`, `--linear-backend`
  incl. `flashinfer_b12x`). **This checked `feat-1`'s existing venv only as
  a proxy — Task 0.3 re-verifies inside the feature's own dedicated venv
  before trusting it for real (REQ-009 isolation).**
- [x] Task 0.3: Build the fully isolated `/data/qwen3.8-27b/.venv`, pinned
  `vllm==0.26.0` (NOT 0.27.1 — see Design Notes/`feat-1`'s rollback
  finding), independent of `/data/vllm/.venv`; re-run the same `qwen3_5`
  registry / NVFP4 kernel / CLI-flag checks from Task 0.2 inside this new
  venv — depends on: Task 0.2 — status: done 2026-08-25 — built via
  `bin/01-build-venv.sh` (Python 3.12.13, `uv venv` + `pip install vllm==0.26.0 flashinfer-python==0.6.14`, then only the two fixes
  proven hardware/toolchain-level rather than DeepSeek-model-specific by
  `feat-1`: pinned the six `nvidia-cuda-*` wheels to the same 13.3.x line
  as production, and baked in the `cudart` lib64/unversioned-`.so`
  symlinks for FlashInfer's JIT linker (user decision 2026-08-25: minimal
  resolve, do not force-pin `fastokens`/`quack-kernels`/`ml_dtypes` the
  way `feat-1`'s `bin/18` clean-venv build did, since those are plausibly
  DeepSeek-mHC/MoE-specific, not generic vLLM requirements). All three
  Task 0.2 checks re-verified inside this dedicated venv, not just
  inferred from `feat-1`'s: `Qwen3_5ForConditionalGeneration` and
  `Qwen3_5MTP` both `True` in `ModelRegistry.get_supported_archs()`;
  `cutlass_scaled_mm_supports_fp4(120)` → `True`; `vllm serve --help=all`
  confirms every needed flag (`--kv-cache-dtype` incl. `fp8`/`nvfp4`,
  `--kv-cache-memory-bytes`, `--hf-overrides`, `--speculative-config`,
  `--tensor-parallel-size`, `--served-model-name`, `--tool-call-parser`
  incl. `qwen3_xml`, `--reasoning-parser`, `--enable-auto-tool-choice`,
  `--linear-backend` incl. `flashinfer_b12x`). A `pip freeze` diff against
  `/data/vllm/.venv` shows only expected divergence: minor floating-version
  drift on packages this script does not pin (`transformers` resolved
  5.15.1 vs. production's explicitly-pinned 5.14.1, similar for
  `huggingface_hub`/`mcp`/`openai`/etc.), and a handful of packages present
  in production only because they were installed by hand for
  DeepSeek-specific or diagnostic reasons and are absent here by design
  (`fastokens` — only needed if `VLLM_USE_FASTOKENS=1`, never set by this
  feature; `hf_transfer` — HF download accelerator, not yet needed until
  Task 0.6; `nccl4py`/`py-spy` — DeepSeek TP=4/diagnostic tooling). `tilelang`
  and `quack-kernels` (genuine transitive `vllm` dependencies) installed
  automatically without forcing, confirming they are not DeepSeek-specific
  after all — `ml_dtypes` resolved newer (0.6.0 vs. production's pinned
  0.5.4) since nothing here forces it down; revisit only if a future
  JIT-compiled kernel (e.g. `tilelang`) misbehaves. Both venvs share the
  same underlying `uv`-managed CPython 3.12.13 interpreter binary
  (`~/.local/share/uv/python/...`, normal for `uv venv` — analogous to a
  shared system Python) but have fully separate, independently-resolved
  `site-packages`, satisfying REQ-009. Build script + full rationale:
  `bin/01-build-venv.sh`; full freeze snapshot committed at
  `bin/baselines/2026-08-25-task-0.3-venv-freeze.txt` (same
  snapshot-to-`bin/baselines/` precedent as `feat-1`'s
  `bin/16-snapshot-baseline.sh`).
- [x] Task 0.4: Confirm GPU topology (NVLink presence/absence) and PCIe
  generation per GPU, to inform REQ-011's GPU-pinning decision — depends
  on: none — status: done 2026-08-25 — `nvidia-smi topo -m` shows `NODE`
  (PCIe-through-host-bridge, no NVLink) between all 4 GPUs; per-GPU PCIe
  link: GPU0 & GPU2 = Gen5 x16 (`pcie.link.gen.max`), GPU1 & GPU3 = Gen4
  x16; GPU2 selected as the default single-GPU pin (Gen5, and avoids
  GPU0's documented occasional Ollama residency per
  `hardware/dell-7960t/configuration.md`); GPU2's UUID is
  `GPU-7eea2a46-7ce4-e288-ab02-783dc5c5c9ea` (bus `00000000:AC:00.0`) —
  use this for `CUDA_VISIBLE_DEVICES` pinning (UUID, not index, to be
  robust against any future PCI re-enumeration)
- [x] Task 0.5: Confirm `feat-1`/`feat-2`'s current live state, to avoid
  surprises/contention during this feature's own testing — depends on:
  none — status: done 2026-08-25 — `feat-1` (DeepSeek-V4-Flash) is
  blocked/disabled (open SM120 degenerate-output bug,
  `vllm-project/vllm#52938`, `status: planning` in its README, service
  stopped); `feat-2` (GLM-5.2, served via `llama.cpp`, not vLLM/
  ktransformers — a discrepancy from `AGENTS.md`'s description worth
  flagging but not fixing here) has a working Q4 production config but was
  not running at check time; all 4 GPUs measured at ~0 MiB used (fully
  idle) at check time; no Ollama process/service found running
- [x] Task 0.6: Pin and download `Qwen/Qwen3.8-27B` (BF16) and
  `unsloth/Qwen3.8-27B-NVFP4` to specific HF revisions into the shared
  `/data/nvidia/hf_cache` (`HF_HOME`, matching `feat-1`'s convention) —
  reuse `feat-3`'s already-vetted NVFP4 revision
  (`7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108`) if still current, re-verify
  the tokenizer-truncation fix (`tokenizer.json`'s `truncation` field must
  be `null`) either way; pin the BF16 revision fresh at download time —
  depends on: Task 0.3 — status: done 2026-08-25 — both downloaded via
  `bin/02-download-weights.py`. **BF16**: pinned
  `Qwen/Qwen3.8-27B@1d4bf0f2ff6012fd82039f2fa52739d0dd7c60c0` (fresh HEAD at
  download time, 2026-08-25), 52 GB on disk (18 safetensors shards).
  **NVFP4**: re-checked `feat-3`'s pinned
  `7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108` against the repo's current
  HEAD (`9e3d73c76eddb75f795cc24ccfbc5affe41c66bd`, same day) — the only
  commit in between is a README.md-only edit, no weight/config change, so
  the vetted revision is still current in every way that matters and was
  reused verbatim (not bumped to HEAD); 22 GB on disk, confirms
  `feat-3`'s finding that the MTP draft head ships in the same repo
  (`model.safetensors` + `model_mtp.safetensors` both present, no separate
  `speculative-config "model"` field needed). Tokenizer-truncation fix
  re-verified directly against the downloaded file (not just the repo API):
  `tokenizer.json`'s `truncation` field is `null`. **Deliberate deviation
  from `feat-1`'s `download_flash.py`/`download_pro.py` pattern**: those
  scripts pass an explicit `local_dir=<HF_HOME>/hub/models--org--repo`,
  which was found (by inspecting `feat-1`'s own
  `models--deepseek-ai--DeepSeek-V4-Flash` on this box) to make
  `huggingface_hub` write the weights **twice** — once as real files
  directly under `local_dir`, once more under the standard
  `snapshots/<revision>/`-symlinks-into-`blobs/` cache layout — 270 GB on
  disk for a checkpoint whose own weights are ~135 GB. This feature's
  download script omits `local_dir` entirely (relies on the
  already-exported `HF_HOME` for the default cache-dir resolution
  instead), producing the standard no-duplication symlink layout while
  remaining exactly as resolvable by bare `repo_id` as `feat-1`'s pattern
  (confirmed: `snapshot_download(..., local_files_only=True)` for both
  repos resolves correctly, no download attempted) — same download
  bytes-over-the-wire, roughly half the disk footprint. `hf_transfer`
  installed in this feature's venv to match `feat-1`'s convention, though
  the installed `huggingface_hub==1.28.0` has since moved to a Xet-based
  transfer backend (`hf_transfer` is deprecated upstream); observed
  throughput ~50 MB/s across ~39 parallel Xet connections regardless,
  ~40 minutes total for both checkpoints (~74 GB downloaded). Disk
  headroom after both downloads: 6.9 TB free of 15 TB. Script + full
  rationale: `bin/02-download-weights.py`; full download log saved at
  `bin/baselines/2026-08-25-task-0.6-download.log`.

#### Phase 1: Native-context correctness smoke test (hard gate)

- [x] Task 1.1: Bring up the BF16 checkpoint on GPU2 (TP=1) at short/native
  context (no YaRN override yet) — depends on: Task 0.6 — status: done
  2026-08-25 — brought up as a `systemctl --user` unit (user decision:
  even Phase 1's diagnostic smoke test must go through systemd per
  REQ-008's literal "never as an ad-hoc foreground process, including
  during testing" — lingering was already enabled, no sudo needed for
  `--user` units). Unit: `qwen3.8-27b-bf16-native-diag.service`
  (`~/.config/systemd/user/`, copy tracked at
  `bin/qwen3.8-27b-bf16-native-diag.service`), `CUDA_VISIBLE_DEVICES`
  pinned to GPU2's UUID, `--max-model-len 8192`, port 8001 (deliberately
  not 8000, to avoid any collision with `feat-1`'s convention on this
  shared box). Hit and fixed one real, architecture-specific bug on first
  start: `ValueError: max_num_seqs (1024) exceeds available Mamba cache blocks (616)` — Qwen3.8-27B's Gated DeltaNet (Mamba-style state) layers
  cap concurrent sequences well below vLLM's default `--max-num-seqs 1024`; fixed with an explicit `--max-num-seqs 512`. Model loaded cleanly
  after the fix (BF16 weights: 51.1 GiB in ~6s, `FLASH_ATTN` attention
  backend auto-selected, `torch.compile` succeeded, KV cache: 360,448
  tokens available at 8192 max-model-len). Cosmetic-only finding, not
  blocking: the unit's `Type=notify` never transitions out of
  `activating (start)` in `systemctl --user status` even once the API
  server is fully up and serving `/health`/`/v1/chat/completions`
  correctly — vLLM 0.26.0 apparently doesn't emit the systemd
  `READY=1` notification this unit type expects; revisit
  (`Type=simple` vs. `Type=notify`) when Phase 5 writes the real
  production unit(s).
- [x] Task 1.2: Temperature=0 smoke test — explicitly check for `feat-1`'s
  exact degenerate-output signature (a single frozen token / identical
  logprob repeated at every decode position); verify tool-calling and all
  three thinking-control modes — depends on: Task 1.1 — status: done
  2026-08-25 — **all checks pass, no SM120 degenerate-output bug**:
  - **Non-degenerate output**: a haiku-writing prompt at `temperature: 0`
    produced coherent, varied text with distinct, varying per-token
    logprobs throughout (nothing resembling `feat-1`'s single frozen
    token / identical `-11.7697` logprob at every position) — confirms
    the Design Notes' hypothesis that Qwen3.8-27B's Gated DeltaNet +
    Gated Attention kernel path is unaffected by the SM120 sparse-MLA
    decode bug that blocks `feat-1`'s DeepSeek-V4-Flash.
  - **Tool-calling**: `get_weather("Paris")` via
    `--tool-call-parser qwen3_xml --enable-auto-tool-choice`
    → clean `finish_reason: "tool_calls"`, correctly-formed
    `arguments: {"city": "Paris"}`, `content: null`.
  - **Thinking-control modes** (17×24 arithmetic prompt, correct
    answer=408 in every case): `chat_template_kwargs: {"enable_thinking": false}` → `reasoning: null`, direct
    `content: "408"`, `finish_reason: "stop"`; `reasoning_effort: "low"`
    → 110-char reasoning; `reasoning_effort: "medium"` → 115-char
    reasoning (different wording, not just coincidentally same length);
    `reasoning_effort: "xhigh"` → 115-char reasoning, distinctly
    different phrasing/style from medium — all three produced the
    correct final answer. (Note: for this trivial a prompt, medium/xhigh
    reasoning length converged; the *content* differs, confirming the
    parameter is taking effect rather than being silently ignored —
    scaling with harder prompts is not re-tested here, out of scope for
    a Phase 1 smoke test.)
  - Diagnostic service stopped afterward (on-demand philosophy — GPU2
    fully freed, confirmed via `nvidia-smi`, ready for Phase 2's fresh
    TP=1/TP=2 benchmark instances).
- [x] Task 1.3: Record the outcome. If the degenerate-output signature IS
  reproduced, this is a blocking finding (same bug class as `feat-1`'s
  open, unresolved issue) requiring investigation/escalation before any
  further work in this feature — depends on: Task 1.2 — status: done
  2026-08-25 — **outcome: NOT reproduced, hard gate cleared.** Qwen3.8-27B
  BF16 on this box's SM120 GPUs (GPU2) produces coherent, correct output
  at native/short context, with working tool-calling and all three
  thinking-control modes. `feat-1`'s open
  `vllm-project/vllm#52938` is confirmed specific to DeepSeek-V4-Flash's
  sparse-MLA decode kernel path and does not affect this model's
  different (Gated DeltaNet + Gated Attention) architecture on this same
  hardware. Phase 2 (TP=1 vs. TP=2 throughput) is now unblocked.

#### Phase 2: TP=1 vs. TP=2 throughput check (GPU-pinning decision)

- [x] Task 2.1: Benchmark decode throughput at matched settings: GPU2-only
  (TP=1) vs. GPU2+GPU0 (TP=2) — depends on: Task 1.3 — status: done
  2026-08-25 — used `vllm bench serve` (the standard vLLM benchmark CLI,
  user decision) against two fresh diagnostic `systemctl --user` units
  (`qwen3.8-27b-bf16-tp1-bench.service` port 8001,
  `qwen3.8-27b-bf16-tp2-bench.service` port 8002 — both tracked under
  `bin/`), identical settings for both: `--dataset-name random --random-input-len 1024 --random-output-len 512 --num-prompts 128 --max-concurrency 64 --request-rate inf --ignore-eos`. **TP=2
  (GPU2+GPU0) decisively wins on every single metric**, not just ties:
  | metric | TP=1 (GPU2) | TP=2 (GPU2+GPU0) | delta |
  |---|---|---|---|
  | Output tok/s | 746.35 | 1222.74 | **+64%** |
  | Total tok/s | 2315.41 | 3793.33 | +64% |
  | Req/s | 1.46 | 2.39 | +64% |
  | Mean TTFT (ms) | 7144 | 4953 | −31% |
  | Mean TPOT (ms) | 71.74 | 42.63 | −41% |

  Full logs: `bin/baselines/2026-08-25-task-2.1-bench-tp1.log` and
  `-tp2.log`. Both diagnostic services stopped afterward, both GPUs
  confirmed fully freed via `nvidia-smi`.

- [x] Task 2.2: Decide production GPU pinning based on the measured
  numbers (working hypothesis, per Design Notes: TP=1/GPU2-only wins or
  ties, given no NVLink between any GPU pair) — depends on: Task 2.1 —
  status: done 2026-08-25 — **decision: GPU2+GPU0 (TP=2), REVERSING the
  working hypothesis.** The Design Notes' PCIe-communication-overhead
  concern turned out not to dominate for this model/precision/context
  combination: at BF16 and a 1024-in/512-out workload, compute (not
  inter-GPU communication) is evidently the bottleneck, so splitting
  compute across GPU2+GPU0 (both PCIe Gen5 x16, per Task 0.4) still nets
  a large, consistent win across throughput AND latency, despite the
  confirmed absence of NVLink. REQ-001/REQ-011 updated accordingly:
  production is pinned to **GPU2+GPU0 (TP=2)**, not GPU2-only. (Caveat
  for Phase 4: this was measured at BF16/8192-context only — NVFP4's
  smaller memory/compute footprint and the eventual 896K/YaRN context
  could shift this balance; not re-tested here, flagged for awareness
  only, not a blocker for this decision.)

#### Phase 3: YaRN 896K context — apply + validate (fixed target)

- [x] Task 3.1: Apply the YaRN `rope_parameters` override (factor 3.5)
  targeting the fixed 917,504-token context, on the GPU(s) chosen in
  Phase 2 — depends on: Task 2.2 — status: done 2026-08-25 — diagnostic
  unit `qwen3.8-27b-bf16-896k-diag.service` (tracked at `bin/`), TP=2
  (GPU2+GPU0 UUIDs), `--max-model-len 917504`,
  `VLLM_ALLOW_LONG_MAX_MODEL_LEN=1`, and `--hf-overrides` set to the exact
  vendor-documented JSON blob from Design Notes/REQ-012 (reused verbatim
  from `feat-3`, single-quoted in the systemd `ExecStart` — systemd 249
  confirmed to support this quoting). `--max-num-seqs 2` (deliberately low
  — Task 1.1's Mamba-cache-block constraint scales with concurrent
  sequences, and at 896K context only a couple of concurrent full-length
  requests fit anyway; see Task 3.2). Came up clean on the first attempt
  (no repeat of Task 1.1's Mamba-block error — the lower `--max-num-seqs`
  avoided it). `/v1/models` confirms `max_model_len: 917504`.
- [x] Task 3.2: Measure KV-cache token capacity and free VRAM headroom at
  896K — depends on: Task 3.1 — status: done 2026-08-25 — read directly
  from the vLLM startup log (not estimated): BF16 weights 26.0 GiB per
  GPU (52 GiB total / 2, TP=2 shard); **GPU KV cache size: 1,892,058
  tokens** (combined across the TP=2 pair); **maximum concurrency for
  917,504 tokens per request: 2.06x** (room for 2 full-length concurrent
  requests); free VRAM headroom after load: ~10.5 GiB per GPU (97,887 MiB
  total − 87,122 MiB used). Comfortable margin, no tuning needed to hit
  the fixed 896K target.
- [x] Task 3.3: Validate with a real filled-context request (a real
  ~899K-token prompt built with the model's own tokenizer, not a synthetic
  estimate) end-to-end; confirm no OOM — depends on: Task 3.2 — status:
  done 2026-08-25 — built a real 906,159-token prompt with the model's own
  tokenizer (`bin/03-build-prompt-896k.py`, same technique as `feat-3`'s
  Task 4.3: repeated paragraph text, tokenized, decode/re-encode-trimmed
  to land close to the 899,067-token reference value — decode() shrinks
  the naive token count by ~1.2% via BPE re-tokenization, compensated for
  by inflating the initial slice). Embedded a fact ("The Dell 7960T
  workstation...") near the start of the ~906K-token prompt and asked
  "What is the name of the workstation mentioned above?" at the end.
  **Result: `content: "Dell"` — correct, `finish_reason: "stop"`, HTTP
  200, `usage.prompt_tokens: 906159`, no OOM.** This is a genuine
  long-context comprehension check (the model had to actually attend
  back across ~906K tokens to answer), not just a token-count/OOM check.
  Request took 8m48s end-to-end (BF16 TP=2 prefill compute at this scale,
  not a throughput-optimized config — acceptable for a one-off validation
  request, not a production throughput claim). Post-request VRAM: ~9.1
  GiB free per GPU (essentially unchanged from pre-request, no leak).
  Diagnostic service stopped afterward, both GPUs confirmed freed.
  Response saved: `bin/baselines/2026-08-25-task-3.3-896k-response.json`.

#### Phase 4: Precision + MTP comparison at 896K/YaRN

- [x] Task 4.1: Benchmark BF16 vs. NVFP4 decode/prefill throughput at
  896K/YaRN, on the GPU(s) chosen in Phase 2 — depends on: Task 3.3 —
  status: done 2026-08-25 — ran the handoff note's two-step approach
  (cheap-context sanity pass first, then the real 896K/YaRN comparison),
  both via `vllm bench serve` at TP=2 (GPU2+GPU0), reusing fresh diagnostic
  `systemctl --user` units per variant
  (`qwen3.8-27b-nvfp4-tp2-bench.service` port 8004,
  `qwen3.8-27b-nvfp4-896k-diag.service` port 8005 — both tracked under
  `bin/`, mirroring the BF16 units' exact shape; NVFP4 needs no
  `--dtype`/`--quantization` flag, confirmed auto-detected from the
  checkpoint's own `quantization_config`, and deliberately no
  `--linear-backend` pin, per `feat-3`'s finding that forcing one broke a
  different kernel path):
  - **Step 1 (cheap-context sanity, 8192 ctx, `--random-input-len 1024 --random-output-len 512 --num-prompts 128 --max-concurrency 64`,
    reusing Phase 2's exact methodology)**: NVFP4 clearly wins —
    | metric | BF16 (TP=2) | NVFP4 (TP=2) | delta |
    |---|---|---|---|
    | Output tok/s | 1258.45 | 1938.87 | **+54%** |
    | Total tok/s | 3775.34 | 5816.62 | +54% |
    | Mean TTFT (ms) | 4542 | 3386 | −25% |
    | Mean TPOT (ms) | 41.96 | 26.38 | −37% |

    Per-GPU weight footprint confirms the expected precision-driven gap:
    BF16 25.69 GiB vs. NVFP4 10.9-11.21 GiB. Cleared the bar to proceed
    to the real 896K/YaRN comparison.

  - **Step 2 (real 896K/YaRN context, `--random-input-len 890000 --random-output-len 100 --num-prompts 2 --max-concurrency 2`, matched to
    each variant's own measured full-context concurrency ceiling)**:
    **the precision advantage essentially disappears at this scale** —
    | metric | BF16 896K | NVFP4 896K | delta |
    |---|---|---|---|
    | Total tok/s (prefill-dominated) | 1703.18 | 1628.37 | **−4%** (NVFP4 slightly slower) |
    | Mean TTFT (ms) | 776,466 | 819,148 | +5% (NVFP4 slightly slower) |
    | Mean TPOT (ms) | 2320.27 | 2335.38 | ~parity (n=2, within noise) |

    KV-cache capacity at 896K, read from each variant's own startup log
    (not estimated): BF16 1,892,058 tokens / 2.06x concurrency (Task 3.2,
    unchanged); **NVFP4 4,709,023 tokens / 5.13x concurrency** — 2.5x more
    headroom than BF16, exactly matching the ~2.3x smaller per-GPU weight
    footprint (11.2 GiB vs. 25.7 GiB) freeing that much more VRAM for KV
    cache. Capacity-wise NVFP4 is a clear win; throughput-wise it is not.

  - **Why the win reverses at 896K (architecture-driven, not a
    measurement artifact)**: NVFP4 quantizes MLP weights only (mixed
    scheme: FP8 for attention/`lm_head`/last-8-layers, confirmed in the
    checkpoint's own `quantization_config` — see Design Notes). At the
    cheap 8192-context/512-output workload, decode is dominated by
    per-token MLP GEMM cost, which NVFP4 accelerates directly. At the
    890K-token-input workload, both TTFT (prefill) and TPOT (decode) are
    dominated by attention compute over an enormous KV cache — a cost
    that scales with context length and is architecturally untouched by
    MLP weight quantization. The `n=2`, ~18-minute-per-run 896K
    comparison is necessarily lower-powered than the cheap-context pass
    (128 prompts), but the direction (parity/slight regression, not a
    win) is consistent across every one of the three reported metrics,
    not an isolated outlier.

  - **Implication for REQ-004's adoption bar**: pure NVFP4 (no MTP) does
    NOT clear a measurable throughput improvement at the fixed 896K/YaRN
    target context — Task 4.2's NVFP4+MTP comparison is therefore the
    real decision point for whether any NVFP4-based variant is worth
    adopting at 896K, not this step alone. Both diagnostic services
    stopped afterward, both GPUs confirmed freed. Logs:
    `bin/baselines/2026-08-25-task-4.1-bench-{bf16,nvfp4}-{8k,896k}.log`.
- [x] Task 4.2: Benchmark NVFP4 + MTP (`--speculative-config '{"method":"mtp","num_speculative_tokens":5}'`, draft head ships inside
  the `unsloth/Qwen3.8-27B-NVFP4` checkpoint) vs. NVFP4-without-MTP at the
  same context; verify byte-identical (lossless) greedy output at
  temperature=0 vs. the non-MTP run on the same prompt — depends on: Task
  4.1 — status: **skipped, explicit user decision 2026-08-25** — after
  reviewing Task 4.1's exact absolute numbers (not just the percentage
  deltas), the user decided BF16 at 896K is "fast enough" and NVFP4 will
  not be pursued further, including the MTP leg — no MTP benchmark was
  run. Not a "tried and failed" outcome — a deliberate scope-narrowing
  decision to stop investing in the NVFP4 branch at all, made explicitly
  before Task 4.2 was attempted
- [x] Task 4.3: Re-verify KV-cache token capacity/headroom with MTP
  enabled still clears the 917,504-token requirement — depends on: Task
  4.2 — status: **skipped, same reason as Task 4.2** — no MTP config was
  ever built, so there is nothing to re-verify
- [x] Task 4.4: Re-verify correctness (coherent non-degenerate output,
  tool-calling, all three thinking-control modes) on the MTP-enabled
  config — depends on: Task 4.3 — status: **skipped, same reason as Task
  4.2/4.3**
- [x] Task 4.5: Record the final precision/MTP decision (BF16 / NVFP4 /
  NVFP4+MTP), with the measured throughput numbers and a one-line
  rationale, per REQ-004 — depends on: Task 4.4 — status: done 2026-08-25
  — **final decision: BF16, at the fixed 896K/YaRN context. NVFP4 (with
  or without MTP) is NOT adopted.** Rationale (one-line, per ACC-004):
  Task 4.1's real 896K/YaRN measurement showed NVFP4 at parity-or-slightly-
  slower than BF16 (1628.37 vs. 1703.18 tok/s total throughput, 819,148 vs.
  776,466 ms mean TTFT) despite a real +54% win at short (8192) context —
  since REQ-004's adoption bar is throughput *at the fixed 896K/YaRN
  target*, not at a cheap context, and BF16 already clears that target
  end-to-end (Task 3.3), the user made the explicit call to stop
  investing further in the NVFP4 branch (including its MTP leg, which
  only accelerates decode, not the prefill/attention cost that dominates
  at 896K) rather than chase a precision change whose Task-4.1-measured
  benefit does not show up at the feature's actual target context. This
  satisfies REQ-004's "adopt only if empirically justified" bar by its
  negative branch: NVFP4 was empirically evaluated (Task 4.1, not
  assumed) and found not to justify adoption at 896K, so BF16 remains the
  sole production precision — closest precedent is `feat-3`'s own
  "not very different / not adopted" fallback outcome description for
  its own Task 6.2 step 7, just reached here without needing the MTP leg
  at all.

#### Phase 5: On-demand systemd service (BF16 only — no auto-start, ever)

- [x] Task 5.1: Install `qwen3.8-27b-bf16-896k.service` — `systemctl --user`, lingering enabled, left `disabled` (never auto-starts at boot)
  — depends on: Task 4.5 — status: done 2026-08-25 — promoted
  `qwen3.8-27b-bf16-896k-diag.service` to a production unit (tracked at
  `bin/qwen3.8-27b-bf16-896k.service`): same TP=2 (GPU2+GPU0 UUIDs), YaRN
  `rope_parameters` override, `--max-model-len 917504`, `--max-num-seqs 2`
  as the validated Phase 3 diagnostic, renamed
  `--served-model-name qwen3.8-27b-bf16-896k`, moved to port 8001 (this
  feature's own established diagnostic-port range, port 8000 deliberately
  avoided per Task 1.1's `feat-1`-collision-avoidance convention). One
  deliberate change from every earlier diagnostic unit: switched
  `Type=notify` → `Type=simple`, fixing Task 1.1's cosmetic finding
  (vLLM 0.26.0 never emits systemd's `READY=1`, so `Type=notify` units
  never leave `activating (start)` even once fully up) — confirmed this
  fix works: `systemctl --user status` now correctly shows
  `active (running)` immediately after `ExecStart` spawns, instead of
  being stuck in `activating`. Installed via `systemctl --user daemon-reload`; confirmed `Loaded: loaded (...; disabled; vendor preset: enabled)`, `Active: inactive (dead)` before first start — exactly
  the intended state.
- [x] Task 5.2: Confirm the service starts/stops cleanly on demand via
  `systemctl --user start|stop`, and confirm it does not auto-start at
  boot or on install — depends on: Task 5.1 — status: done 2026-08-25 —
  `systemctl --user start` brought the service to `active (running)` in
  ~3s (process spawn), fully healthy (`/health` 200, `/v1/models` confirms
  `max_model_len: 917504`) after ~90s total load time. Ran the full
  ACC-003 smoke-test suite against this production unit (not just the
  earlier diagnostic ones): tool-calling (`get_weather("Paris")` → clean
  `finish_reason: "tool_calls"`, correct `arguments: {"city": "Paris"}`);
  all three thinking-control modes on a 17×24 arithmetic prompt, all
  correct (answer=408) with reasoning correctly scaling
  (`enable_thinking: false` → 0-length/`null` reasoning,
  `reasoning_effort: medium` → 44-char reasoning,
  `reasoning_effort: xhigh` → 125-char reasoning); a haiku prompt
  confirming coherent, non-degenerate output. `systemctl --user stop`
  cleanly returned the unit to `inactive (dead)` with all 4 GPUs back to
  ~0 MiB used. Confirmed `systemctl --user is-enabled` → `disabled`, and
  no symlink for this unit exists under
  `~/.config/systemd/user/default.target.wants/` — will not auto-start at
  boot or on install, per REQ-008.

#### Phase 6: Integration

- [x] Task 6.1: Produce an OpenCode provider snippet for the installed
  BF16 896K service — depends on: Task 5.2 — status: done 2026-08-25 —
  written to
  `opencode-provider-snippet-qwen3.8-27b.jsonc` (feature folder root),
  same "standalone, not written into any actual `opencode.jsonc`"
  precedent as `feat-2`/`feat-3`: `@ai-sdk/openai-compatible`,
  `baseURL: http://<sys0-LAN-IP>:8001/v1` (placeholder, not a literal
  IP — the box's LAN address is DHCP-assigned and was `192.168.1.103` as
  of this session, but can change; same placeholder convention `feat-2`
  used for this reason), model id `qwen3.8-27b-bf16-896k` matching the
  production unit's `--served-model-name`, `limit.context: 917504`
  (matching the real deployed `max_model_len`, not a rounder number).
  Snippet documents the two prerequisites explicitly: the user must
  `systemctl --user start qwen3.8-27b-bf16-896k.service` by hand first
  (on-demand only, per REQ-008), and no API key is required or accepted
  (REQ-007) — with the `"apiKey": "not-needed"` workaround noted in case
  the AI SDK errors on a missing key regardless, same as
  `feat-2`/`feat-3`.
- [x] Task 6.2: OpenWebUI wiring — depends on: Task 6.1 — status:
  **closed 2026-08-25, explicit user decision: out of scope, not pursued.**
  No OpenWebUI configuration will be produced for this feature.

## Progress

### Current Status

**As of 2026-08-25 (feature written, no implementation performed yet)**:
this README was written following a planning conversation that produced
several already-verified (read-only, no state changed) findings, recorded
above as done Task entries: disk headroom (Task 0.1), the Dell 7960T's
existing driver/CUDA and a proxy check of `feat-1`'s existing vLLM 0.26.0
venv for `qwen3_5`/NVFP4 support (Task 0.2), GPU topology/NVLink-absence/
PCIe-generation-per-GPU and the resulting GPU2 pinning choice (Task 0.4),
and `feat-1`/`feat-2`'s current live state (Task 0.5). None of these
required any write/deploy action — they were confirmed via `nvidia-smi`,
`vllm serve --help=all`, a Python import against `feat-1`'s existing venv,
`systemctl`/`docker ps` checks, and reading
`hardware/dell-7960t/configuration.md`.

**2026-08-25 (Task 0.3 completed)**: the dedicated, isolated
`/data/qwen3.8-27b/.venv` has been built (Python 3.12.13, `vllm==0.26.0`,
`flashinfer-python==0.6.14`) via
`bin/01-build-venv.sh`, independent of `feat-1`'s `/data/vllm/.venv` (same
underlying `uv`-managed CPython interpreter binary, fully separate
`site-packages`). The `qwen3_5` registry / NVFP4 kernel / CLI-flag checks
from Task 0.2 were re-verified inside this new venv, not just inferred from
`feat-1`'s proxy check — see Task 0.3 for the full result and the
"minimal resolve" pinning rationale.

**2026-08-25 (Task 0.6 completed)**: both checkpoints downloaded and
pinned into the shared `/data/nvidia/hf_cache` via
`bin/02-download-weights.py` — BF16 (`Qwen/Qwen3.8-27B`, 52 GB, fresh HEAD
revision) and NVFP4 (`unsloth/Qwen3.8-27B-NVFP4`, 22 GB, `feat-3`'s vetted
revision reused verbatim after confirming the repo's newer HEAD is a
README-only commit). Found and avoided a disk-duplication issue in
`feat-1`'s download-script pattern (see Task 0.6 for detail) — both
checkpoints resolve correctly by bare `repo_id`, confirmed via a
`local_files_only=True` cache-resolution check. GitHub issue
[#4](https://github.com/dfch/biz.dfch.LlmOps/issues/4) has been created for
this feature.

**2026-08-25 (Phase 1 hard gate cleared)**: brought up the BF16 checkpoint
on GPU2 (TP=1) at native/short (8192) context via a `systemctl --user`
diagnostic unit (REQ-008 applied even to Phase 1 testing, per user
decision) and ran the full Task 1.2 smoke test — **`feat-1`'s open SM120
degenerate-output bug (`vllm-project/vllm#52938`) does NOT reproduce**:
coherent, varied output at `temperature: 0`; clean tool-calling; all three
thinking-control modes correctly scaled. One real architecture-specific
bug found and fixed along the way (`--max-num-seqs` must be capped below
Qwen3.8-27B's available Mamba cache blocks — see Task 1.1). Phase 1 is
fully done; the diagnostic service was stopped afterward (GPU2 confirmed
fully freed) — see Task 1.1-1.3 for full detail.

**2026-08-25 (Phase 2 done — working hypothesis overturned by measurement)**:
`vllm bench serve` against matched TP=1 (GPU2) and TP=2 (GPU2+GPU0)
diagnostic services shows **TP=2 wins decisively** (+64% output
throughput, -31% TTFT, -41% TPOT) at BF16/8192-context — the Design
Notes' "no NVLink → TP=1 wins" hypothesis did not hold once measured;
compute, not PCIe communication, is the bottleneck here. Production GPU
pinning is now **GPU2+GPU0 (TP=2)**, reversing the plan's working
assumption (REQ-001/REQ-011 already anticipated this possibility in their
wording, no requirement text change needed). Both diagnostic services
stopped, both GPUs confirmed freed.

**2026-08-25 (Phase 3 done — 896K context validated end-to-end)**: applied
the YaRN `rope_parameters` override on the TP=2 (GPU2+GPU0) config,
confirmed `max_model_len: 917504` live, measured comfortable KV-cache
capacity (1,892,058 tokens, 2.06x concurrency headroom at full context,
~10.5 GiB free VRAM/GPU), and validated with a real 906,159-token
filled-context request that correctly recalled a fact planted near the
start of the prompt (`content: "Dell"`, `finish_reason: "stop"`, no OOM).
See Task 3.1-3.3 for full detail. Diagnostic service stopped, GPUs freed.

**2026-08-25 (Task 4.1 done — NVFP4's throughput win at short context does
NOT carry over to 896K/YaRN)**: cheap-context (8192) sanity pass confirms
NVFP4 gives a clear +54% output-throughput win over BF16 (matching Phase
2's TP=2 baseline methodology) — but the real 896K/YaRN comparison (real
890K-token-input requests, matched to each variant's own measured
full-context concurrency ceiling) shows that win essentially disappearing
(NVFP4 ~4% slower total throughput, ~5% slower TTFT, TPOT at parity within
this `n=2` sample's noise). Root cause is architecture-driven, not a
measurement artifact: NVFP4 only quantizes MLP weights (FP8 for
attention/`lm_head`/last-8-layers), so it speeds up MLP-GEMM-dominated
decode at short context but does nothing for the attention-over-massive-
KV-cache cost that dominates at 890K tokens. NVFP4 still wins decisively
on **capacity** at 896K (4,709,023 KV-cache tokens / 5.13x concurrency vs.
BF16's 1,892,058 tokens / 2.06x — 2.5x more headroom, tracking its ~2.3x
smaller per-GPU weight footprint), just not on throughput. Exact absolute
numbers for both steps (not just percentage deltas) are recorded in Task
4.1.

**2026-08-25 (Phase 4 concluded — explicit user decision: BF16 only,
NVFP4/MTP not pursued further)**: after reviewing Task 4.1's exact
absolute numbers, the user decided BF16 at 896K is "fast enough" and that
NVFP4 will not be pursued further — including Task 4.2's NVFP4+MTP leg,
which was never run. Tasks 4.2-4.4 are marked skipped (not
attempted-and-failed; a deliberate scope-narrowing decision made before
they were attempted) and Task 4.5 records the final decision: **BF16 is
the sole production precision at the fixed 896K/YaRN context. No NVFP4 or
NVFP4+MTP service will be installed.** This satisfies REQ-004's "adopt
[NVFP4] only if empirically justified" bar by its negative branch — NVFP4
was empirically measured (Task 4.1), not assumed, and found not to justify
adoption at the feature's actual 896K target context (its win is real at
short context but does not transfer). Scope, Phase 5, and Phase 6 have
been updated accordingly: one BF16-only on-demand service, not
"two-or-more" variants.

**2026-08-25 (Phase 5 done — production BF16 896K service installed and
verified)**: promoted `qwen3.8-27b-bf16-896k-diag.service` to a real
production unit (`bin/qwen3.8-27b-bf16-896k.service`, port 8001,
`--served-model-name qwen3.8-27b-bf16-896k`), switching `Type=notify` →
`Type=simple` along the way to fix Task 1.1's cosmetic
never-leaves-`activating` finding (confirmed fixed: `systemctl --user status` now correctly shows `active (running)` right after start). Ran
the full ACC-003 smoke-test suite (tool-calling, all three thinking
modes, non-degenerate output) against this exact production unit, all
passing; `systemctl --user start|stop` both confirmed clean, unit
confirmed `disabled` with no `default.target.wants/` autostart symlink,
all 4 GPUs back to ~0 MiB used after stop. Most ACC-\* boxes checked off
accordingly (see Acceptance Criteria section) — ACC-007 is the one
holdout, since this session only had shell access on the Dell 7960T
itself, not a genuinely separate client host to test internal-network
reachability from.

**2026-08-25 (Task 6.1 done — OpenCode provider snippet written)**:
`opencode-provider-snippet-qwen3.8-27b.jsonc` (feature folder root) is a
standalone, paste-able `provider` entry (`@ai-sdk/openai-compatible`,
placeholder `<sys0-LAN-IP>:8001/v1`, model `qwen3.8-27b-bf16-896k`,
`limit.context: 917504`) — not written into any actual `opencode.jsonc`
on this box, same precedent as `feat-2`/`feat-3`. Documents its own two
prerequisites (start the service by hand first; no API key
needed/accepted). Only Task 6.2 (OpenWebUI, explicitly deferred/optional
per existing scope) remains — **this feature's core work (Phases 0-6.1)
is now complete**, modulo ACC-007's internal-network-reachability caveat
(see Acceptance Criteria) and the optional Task 6.2.

**Next step**: none required to close out this feature's core scope.
Optionally: Task 6.2 (OpenWebUI wiring, deferred), or ACC-007's from-a-
separate-host reachability check if that residual gap needs formal
closure. Otherwise this feature is ready for a final status review
(`status: planning` → `accepted`/`done` in the frontmatter) whenever the
user is satisfied with the recorded decisions.

**2026-08-25 (Task 6.2 explicitly closed, out of scope — user decision):**
no OpenWebUI wiring will be produced for this feature. This closes out
every remaining formal Task List item; only ACC-007's cross-host
reachability caveat remains open (see Acceptance Criteria).

**2026-08-25 (post-completion follow-up + hardware incident — session
paused for user hardware inspection)**: after the feature's core scope
was done, the user asked a genuine technical question (does TP=1 vs. TP=2
matter for a SINGLE request, and would TP=3/4 help further) — answered
empirically for TP=1/TP=2 (see Design Notes: TP=2 wins decisively even at
concurrency=1, −46% TPOT), and TP=3 was ruled out analytically (model has
only 4 KV heads, TP size must divide that evenly). Attempting to measure
TP=4 **triggered a real hardware/driver incident, not a benign bug**:
GPU1 dropped off the PCIe bus mid-warmup, with cascading NVRM RPC
failures logged against GPU3 too. Full incident detail (trigger,
symptoms, recommended next steps) is logged in
`hardware/dell-7960t/recovery.md`'s new "Incident log" section — box-wide
hardware concern, not specific to this feature, so it lives there rather
than only here. **No TP=4 throughput number exists for this box/model.**

**Session state at pause (2026-08-25, ~18:16 UTC)**: user is pausing this
session to physically inspect the hardware fault (GPU1), then will
restart and continue in this same session/thread. Box state left as-is
for that inspection, not "cleaned up" beyond making sure nothing keeps
retrying automatically:

- GPU1: unreachable (`nvidia-smi` reports `Unable to determine the device handle for GPU1: 0000:34:00.0: Unknown Error`) — **left in this
  degraded state deliberately, for the user's physical inspection**, not
  auto-recovered (no non-interactive `sudo` was available to attempt a
  driver reload or reset; a reboot was NOT performed, pending the user's
  own decision)
- GPU0, GPU2, GPU3: were showing a stuck, abnormal 100% GPU-Util/P0
  reading with 0 MiB used and zero processes shortly after the incident —
  worth re-checking whether that cleared on its own or persists, once the
  user is back
- The failed `qwen3.8-27b-bf16-tp4-bench.service` diagnostic unit was
  stopped and `systemctl --user reset-failed` was run against it, so it
  will not keep retrying in the background; it remains installed
  (disabled) at `~/.config/systemd/user/` and `bin/` for reference
- All other `qwen3.8-27b-*` units: confirmed `disabled`, none loaded/
  active, `qwen3.8-27b-bf16-896k.service` (production) untouched by this
  incident (it was never started during this follow-up) and still ready
  for an explicit `systemctl --user start` once GPU1/GPU3 are confirmed
  healthy again — **do not start it (or any other unit here) before
  re-confirming all 4 GPUs are back to a clean `nvidia-smi` listing**,
  since GPU2+GPU0 (the production pair) were not directly implicated but
  the driver's overall state was clearly disturbed
- Both checkpoints remain downloaded under `/data/nvidia/hf_cache`
  (unaffected by this incident — a storage/cache concern, not GPU state)

**Next step when this session resumes**: user will report back on GPU1's
physical/hardware state; from there, likely either (a) re-run the
Post-reboot validation commands in `hardware/dell-7960t/recovery.md` if a
reboot was performed, confirming all 4 GPUs enumerate cleanly again
before trusting any of them for compute, or (b) if GPU1 is still down,
help investigate further (the recovery doc's recommended next steps list
a physical power-cable check as the first thing to try, given this box's
own precedent of a defective power cable causing a similar symptom on a
different slot). This feature's own remaining optional item (ACC-007's
cross-host reachability check) is unrelated to the incident and can wait.

**2026-08-25 (hardware incident resolved — session resumed)**: user
physically inspected and fixed GPU1, then rebooted; all 4 GPUs are back.
Re-ran the recovery doc's post-reboot validation (path (a) above) and
confirmed a genuinely clean recovery, not just a surface-level
`nvidia-smi` listing:

- All 4 GPUs enumerate at idle `P8`/0%-util/near-0-MiB, including GPU1
  (bus `34:00.0`) and GPU3, the pair implicated in the incident — no
  repeat of the stuck `100% GPU-Util`/`P0` reading seen right after the
  drop.
- Fresh boot's kernel log (`journalctl -k -b`) shows the driver loading
  cleanly on all 4 PCIe addresses with **zero** NVRM/Xid errors — no
  repeat of the `kgmmuInvalidateTlb`/`rpcSendMessage failed` cascade.
- Both pre-existing hardware fixes (`pcie_aspm=off`,
  `NVreg_DynamicPowerManagement=0x00`) survived the reboot; topology
  (`nvidia-smi topo -m`) unchanged (all `NODE`, no NVLink).
- Went one step further than a generic hardware check: started this
  feature's actual production unit
  (`qwen3.8-27b-bf16-896k.service`, TP=2 on GPU2+GPU0 — the driver state
  the incident log flagged as "clearly disturbed" even though not
  directly implicated) for real. It loaded BF16 weights cleanly (~29.9
  GiB on each of GPU0/GPU2), `/health` → 200, `/v1/models` confirmed
  `max_model_len: 917504`, a temperature=0 chat completion returned
  correct/coherent output (no degenerate-output signature), then
  `systemctl --user stop` cleanly returned it to `inactive (dead)` with
  all 4 GPUs back to ~0 MiB used. Unit remains `disabled` (on-demand
  only, unchanged).

Full detail (including the caveat that the power-cable/seating root
cause was not independently re-verified beyond "symptom cleared after
inspection + reboot") logged in `hardware/dell-7960t/recovery.md`'s
Incident log entry, under its new "Resolution" subsection.

**Status**: this feature's core scope (Phases 0-6.1) was already
complete before the incident, and is now reconfirmed working on fully
recovered hardware. Only ACC-007's cross-host reachability caveat
remains open (unrelated to this incident, still requires a genuinely
separate client host to close). No other action is required to consider
this feature done; frontmatter `status` can move from `planning` to
`accepted`/`done` whenever the user is satisfied, with or without closing
ACC-007.

**2026-08-25 (TP=4 re-attempted post-recovery — now measured, closes the
Design Notes gap)**: with the hardware fault fixed, re-ran the exact
diagnostic unit that crashed during the earlier incident
(`qwen3.8-27b-bf16-tp4-bench.service`), this time under close live
monitoring (kernel-log tailing + GPU polling through the specific
warmup window that failed before). It came up completely cleanly this
time — zero NVRM/Xid errors, healthy `/health`/`/v1/models` — and the
same `vllm bench serve` methodology as Task 2.1 ran to completion,
128/128 requests, 0 failures. **Result: TP=4 essentially ties TP=2 on
every metric** (output/total tok/s and req/s within ~1%, TPOT within
~1.3%, TTFT actually 9% worse) — the further ~1.5-1.8x this Design Notes
entry had explicitly flagged as an *unverified guess* did not
materialize; TP=2→TP=4 scaling is flat, unlike the near-linear
TP=1→TP=2 win. See Design Notes for the full table and log location
(`bin/baselines/2026-08-25-task-tp4-bench.log`). This remains a pure
research probe — TP=4 stays out of production scope (REQ-001) — but the
open "no TP=4 number exists" gap is now closed with a real, clean
measurement.

**Clarification on concurrency (2026-08-25)**: the TP=1/TP=2/TP=4 table
above (Task 2.1 methodology, `--max-concurrency 64 --num-prompts 128`)
is a **batched-load** benchmark, not a single-request one. The only
genuinely single-concurrent-request (concurrency=1) numbers that exist
are TP=1 vs. TP=2 (see the earlier "post-completion follow-up" entry:
TTFT 281.97 ms vs. 218.41 ms, TPOT 37.71 ms vs. 20.37 ms) — **no
single-request TP=4 number was ever measured, and attempting it
crashed the hardware a second time (see next entry) — this gap is now
staying open, not closed.**

**2026-08-25 (TP=4 single-request attempt — GPU1 crashed a second time,
session wrapped up here)**: immediately after the successful batched
(64-concurrency) TP=4 run above, attempted the matching single-request
(concurrency=1, `--num-prompts 5`, same `vllm bench serve`
methodology used for the TP=1/TP=2 single-request numbers) benchmark
against the same still-running `qwen3.8-27b-bf16-tp4-bench.service`
(unchanged config). **GPU1 dropped off the PCIe bus again**, partway
through (4/5 requests had completed), with the kernel log this time
showing an explicit GSP-firmware heartbeat timeout
(`_kgspIsHeartbeatTimedOut`) and `NVRM: Xid 154` on **all 4 GPUs**, each
flagged with `GPU recovery action changed ... to 0x2 (OS Reboot)`. This
is the same fault class as the original incident, occurring on the very
next TP=4 attempt after a clean one — i.e. **TP=4 on this box is
intermittent, not reliably safe, even freshly post-repair**; one clean
run does not mean the fault is resolved. Full detail (kernel log
excerpts, cleanup outcome, and the resulting recommendation to treat
TP=4 as unreliable pending a longer soak test) logged in
`hardware/dell-7960t/recovery.md`'s new "GPU1 dropped off the bus a
second time" incident entry, per this repo's box-wide-hardware-concern
convention.

Cleanup this time was straightforward: `systemctl --user stop` on the
diagnostic unit succeeded without hanging (no stuck NCCL collective to
force-kill), no leftover vLLM processes, all 4 GPUs' memory freed
(GPU1 itself still unreachable; GPU0/2/3 retain the same cosmetic
stuck-`100%`-util reading seen in the first incident, with zero real
processes/compute behind it — not investigated further, per explicit
user decision to stop testing here). All `qwen3.8-27b-*` systemd units
confirmed unloaded/inactive; temp diagnostic files removed.

**By explicit user decision, this incident is not being investigated
further in this session** — engineering/benchmarking work on this
feature stops here. **The user will separately validate the actual
production configuration (TP=2, GPU0+GPU2 only) themselves**, in a
real-life test outside this session — this is exactly the config this
feature's `qwen3.8-27b-bf16-896k.service` production unit already uses
(TP=4 was never a production target — REQ-001 explicitly scopes it out,
and this feature's own hardware findings from earlier today already
showed TP=4 offers no throughput advantage over TP=2 even when it does
work). The `~/.local/bin/qwen3.8-27b start|stop|restart|status|logs`
convenience script (added earlier this session) is what the user is
expected to drive that real-life test with.

**Final state at session end**: `qwen3.8-27b-bf16-896k.service`
(production, TP=2/GPU0+GPU2) is `disabled`, `inactive (dead)`, untouched
by this incident (never started during this TP=4 probe). All other
`qwen3.8-27b-*` diagnostic units are likewise `disabled`/unloaded. GPU1
is unreachable at the hardware/driver level (same as the first
incident); GPU0/2/3 are free of any real process but show the same
cosmetic stuck-utilization-metric anomaly as before. No reboot or driver
reset was attempted in this session (no non-interactive `sudo`
available, and — per explicit user instruction — this is now the user's
own hardware investigation to make, not a continuation of this
session's engineering work).

**2026-08-25 (simple start/stop script added)**: since
`qwen3.8-27b-bf16-896k.service` was already confirmed pinned to exactly
GPU0+GPU2 (`CUDA_VISIBLE_DEVICES` by UUID — `GPU-7eea2a46...`=GPU2,
`GPU-5200c9f6...`=GPU0, cross-checked against `nvidia-smi -L`;
`--tensor-parallel-size 2`; unchanged from Task 2.2/5.1), no
reconfiguration was needed there. Added a thin convenience wrapper,
`~/.local/bin/qwen3.8-27b` (`start|stop|restart|status|logs`), that
still goes through `systemctl --user` under the hood — REQ-008 requires
this service to only ever run as a `systemctl --user` unit, so the
script does not launch `vllm serve` directly, it is purely a shorter
spelling of the same `systemctl --user <verb> qwen3.8-27b-bf16-896k.service` commands used throughout this feature.
Verified working: `qwen3.8-27b start` → `active (running)` (TP=2,
GPU2+GPU0 confirmed in the unit's own description line); `qwen3.8-27b stop` → `inactive (dead)`, GPUs freed. Not tracked under this feature's
own `bin/` (it is a personal shell convenience file under the user's
home directory, not a feature deliverable), so it is not part of this
repo's version control.
