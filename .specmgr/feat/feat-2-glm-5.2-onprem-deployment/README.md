---
created: 2026-08-19
id: feat-2-glm-5.2-onprem-deployment
status: planning
updated: 2026-08-20
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
- [x] ACC-002: Verifies REQ-010 — a short smoke test at temperature=0
  produces coherent, non-degenerate output on SM120 (explicitly checked
  against the `feat-1` Task 1.4 failure signature: NOT a single frozen
  token repeated at every decode position) — PASS 2026-08-19
  (`bin/05-spike-glm-dsa-strong.sh`, `llama.cpp`/`UD-IQ1_S`): 3 of 4 cases
  (`enable_thinking:false`) reached a finished, non-truncated answer —
  `"Hello!"`, `"Paris"` (factually correct), and a correct recursive
  Python `factorial()` — each run TWICE at temperature=0 and byte-identical
  both times (rules out flaky/intermittent failure, not just a lucky single
  run). The 4th case (default thinking mode, 600 tokens) produced a
  coherent, structured reasoning trace with no frozen-token pattern, just
  still truncated (GLM-5.2 defaults to `reasoning_effort: max`, needs an
  even larger budget or an explicit lower effort level to finish — separate
  from REQ-010 correctness). `OVERALL: no degenerate/suspicious/
  non-deterministic results found`
- [ ] ACC-003: Verifies REQ-003 — empirical test confirms the endpoint
  handles a 350-370K-token coding prompt without OOM
- [ ] ACC-004: Verifies REQ-004/REQ-011 — tool-call verified via curl smoke
  test then a real OpenCode agentic session; all 3 reasoning modes
  (`reasoning_effort` max/high and `enable_thinking:false`) confirmed to
  toggle correctly. If the engine is llama.cpp, tool-calling is explicitly
  re-verified (REQ-011 risk)
- [x] ACC-005: Verifies REQ-005/REQ-006 — the chosen quant is recorded
  (target `UD-Q5_K_XL`, else `UD-Q4_K_XL`), with a one-line rationale for
  why it is the highest-quality option that still meets REQ-003's context
  target on this hardware (both are near-lossless per unsloth's KLD data)
  — PASS 2026-08-20 (Task 2.2): **`UD-Q5_K_XL` confirmed as the production
  quant.** Rationale: under the validated `--n-cpu-moe 54 --tensor-split
  54,9,8,8` placement, Task 2.1 directly measured `ctx=524,288` (512K
  tokens, > REQ-003's 370K upper bound) succeeding with ≥25.5 GiB (≥26.9%
  of 97,288 MiB) free on the worst-margined GPU (CUDA1) — a measured floor
  that, by monotonicity of context-size memory use, guarantees at least
  as much headroom at the actual 350-370K target (a linear-fit projection
  puts it slightly higher, ~27.7 GiB/~28%, consistent with this floor).
  Both comfortably clear a ≥15%-or-≥10 GiB per-GPU safety-margin policy —
  so the highest-quality near-lossless
  option fits with room to spare and there is no need to drop to the
  lossier `UD-Q4_K_XL` fallback. See Task 2.2 for the full per-GPU
  extrapolation.
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
  may let this feature skip its own spike. UPDATE 2026-08-19: `feat-1`
  confirmed its bug is vLLM/FlashInfer's `FLASHINFER_MLA_SPARSE_DSV4`
  specifically (all local hypotheses ruled out, filed upstream as
  vllm-project/vllm#52938), and this feature's own Task 1.2 spike (run
  independently, not skipped) found `llama.cpp` producing coherent output
  on the same SM120 GPUs — the two findings corroborate each other toward
  "engine-specific," not "SM120-fundamental."
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
- [x] Task 0.4: Choose and record pinned HF revision/commit for `zai-org/GLM-5.2` (base) — depends on: Task 0.3 — status: done — pinned revision `b4734de4facf877f85769a911abafc5283eab3d9` (recorded 2026-08-19; not downloaded, base BF16 not needed for the GGUF path)
- [x] Task 0.5: Select the quant strategy + source and record its pinned revision. Default: unsloth Dynamic GGUF `UD-Q5_K_XL` (target) / `UD-Q4_K_XL` (fallback) from `unsloth/GLM-5.2-GGUF` for a llama.cpp/SGLang path; or an FP8/FP4 checkpoint if vLLM is chosen (vLLM does not consume GGUF) — depends on: Task 0.4 — status: done — pinned revision `abc55e72527792c6e77069c99b4cb7de16fa9f23` (recorded 2026-08-19); download kicked off out of order via `bin/00-download-glm-quants.sh` (see Decisions Made)

#### Phase 1: SM120 correctness spike (de-risk REQ-010 BEFORE full deploy)

- [ ] Task 1.1: Pick the engine(s) to spike and their GLM-5.2-supporting versions. Candidates in order of SM120-risk: llama.cpp/llama-server (separate GGUF CUDA path, does NOT inherit feat-1's vLLM sparse-attention bug — strongest Plan B), SGLang (distinct SM120 path), vLLM (default runbook but same broken kernel class as feat-1) — depends on: Task 0.4 — status: in-progress — llama.cpp picked as the lead spike candidate; dedicated checkout cloned+built at `/data/llama.cpp-dsa` (commit `ee4c505a4fb37be8ea37a78af272e74dad2835c1`, 2026-08-19) via `bin/01-clone-llama-cpp-dsa.sh` + `bin/02-build-llama-cpp-dsa.sh`, CUDA/SM120 confirmed linked (`CMAKE_CUDA_ARCHITECTURES` includes `120a-real`); done in parallel with the quant download while GPUs are still occupied by `feat-1`'s service, so Task 1.2 bring-up itself has not started yet
- [x] Task 1.2: Minimal short-context bring-up of GLM-5.2 on ONE engine at a small quant, temperature=0 greedy smoke test — check specifically for the feat-1 Task 1.4 degenerate signature (single frozen token at every decode position) — depends on: Task 1.1, Task 0.5 — status: done — 2026-08-19, `bin/03-spike-glm-dsa.sh`: `llama-server` (commit `ee4c505a4`) on `UD-IQ1_S`, all 4 GPUs (~50-53 GB VRAM each), `-c 4096`. Temp=0 greedy request produced coherent, grammatical chain-of-thought reasoning tokens (`The user wants me to say hello...`) with naturally varying logprobs (`-0.0000649` to `-1.126`) — NOT the feat-1 flat `-11.77`-at-every-position frozen-token signature. `finish_reason: length` with empty `message.content` is expected (GLM-5.2 defaults to thinking mode; 20-token budget was spent entirely on `reasoning_content`), not a failure. Decode ran at ~39 tok/s. Strengthened same-day via `bin/05-spike-glm-dsa-strong.sh`: multiple prompts (chit-chat/factual/code), `enable_thinking:false` to reach finished answers, each run twice for determinism — see ACC-002 for the full result. **REQ-010: llama.cpp's DSA decode path is correct on this box's SM120 GPUs.** Cross-reference: `feat-1` independently hit the same *class* of bug (vLLM's `FLASHINFER_MLA_SPARSE_DSV4` sparse-MLA decode produces the exact degenerate signature on these same SM120 GPUs, all local hypotheses ruled out, filed as upstream https://github.com/vllm-project/vllm/issues/52938) — this result is a second, independent data point supporting "vLLM/FlashInfer-specific bug," not "SM120 fundamentally broken for this kernel class"
- [x] Task 1.3: If output is degenerate on the first engine, repeat Task 1.2 on the next engine (llama.cpp vs SGLang vs vLLM is the SM120 sparse-attention discriminator that also informs feat-1) — depends on: Task 1.2 — status: not applicable — the first engine tried (llama.cpp) did NOT produce degenerate output (see Task 1.2/ACC-002), so the "repeat on next engine" condition never triggers. SGLang/vLLM not tested for GLM-5.2 — not needed since Phase 1's goal (find ONE working engine) is already met
- [x] Task 1.4: Record the outcome: which engine(s) produce coherent GLM-5.2 output on SM120, and whether the sparse-attention problem is engine-specific or SM120-fundamental (feed this back into feat-1 Task 1.4) — depends on: Task 1.2, Task 1.3 — status: done — **llama.cpp produces coherent GLM-5.2 DSA-decode output on this box's SM120 GPUs** (Task 1.2/ACC-002, strengthened via `bin/05-spike-glm-dsa-strong.sh`: deterministic, factually-correct, finished answers across chit-chat/factual/code prompts). Combined with `feat-1`'s finding that vLLM's `FLASHINFER_MLA_SPARSE_DSV4` produces the degenerate signature on the SAME GPUs for a different model (DeepSeek-V4-Flash, upstream vllm-project/vllm#52938), this is consistent with the sparse-attention problem being **engine-specific (vLLM/FlashInfer), not SM120-fundamental** — though this is corroborating evidence from a different model/engine pairing, not a direct reproduction of feat-1's exact bug. Fed back into `feat-1`'s README (cross-reference note under Task 1.4/Blockers)

#### Phase 2: Full deployment (only if Phase 1 yields a working engine)

- [x] Task 2.1: Measure actual KV-cache memory per 1K tokens at real context shapes on the chosen engine/quant — depends on: Task 1.4 — status: done — `bin/06-measure-kv-cache.sh` (adaptive ramp 4K→32K→128K→256K→512K). Two unsafe-config incidents hit and fixed before a run succeeded (see Decisions Made 2026-08-19 "KV-cache measurement MoE placement"): (1) `--cpu-moe` alone pushed ~500 GiB onto the 512 GiB system RAM, causing real swap growth — killed as a precaution (sweep attempt `2026-08-19T203936Z`, crashed at `ctx=4096`, no explicit error in the log — consistent with an external kill); (2) `--n-cpu-moe 41` alone let one GPU (CUDA2) get assigned a full ~132 GiB chunk of MoE weight before the CPU cutoff was applied, causing `cudaMalloc failed: out of memory ... buffer of size 138774596736` (sweep attempt `2026-08-19T212601Z`, crashed at `ctx=4096`). **Fixed run (`2026-08-19T220559Z`) succeeded on ALL 5 ramp sizes** with `--n-cpu-moe 54 --tensor-split 54,9,8,8`, no bisection needed:

  | ctx (tokens) | status | GPU mem (4 GPUs) | RAM used | load time |
  |---|---|---|---|---|
  | 4,096 | ok | 190,512 MiB (~186.1 GiB) | ~11.68 GiB | 1302 s |
  | 32,768 | ok | 193,520 MiB (~189.0 GiB) | ~11.66 GiB | 1212 s |
  | 131,072 | ok | 203,768 MiB (~199.0 GiB) | ~11.75 GiB | 1112 s |
  | 262,144 | ok | 217,462 MiB (~212.4 GiB) | ~11.58 GiB | 1322 s |
  | 524,288 | ok | 244,864 MiB (~239.1 GiB) | ~11.63 GiB | 1462 s |

  All 5 succeeded up to 524,288 tokens (512K) — well past the 350-370K
  REQ-003 target — no ceiling found in the tested range (this was a
  model-load/VRAM-allocation probe per context size, not a filled-context
  generation run; that end-to-end validation is still Task 2.5). Linear
  fit across all 5 points: `total_GiB ≈ 197.3 + 0.000102 × ctx_size` →
  **~0.104 GiB KV cache per 1K context tokens**, fixed
  (weights+runtime) footprint **~197.3 GiB**. Extrapolated: ctx=350,000 ≈
  233.0 GiB total, ctx=370,000 ≈ 235.0 GiB total — comfortably inside the
  896 GB (384 GB VRAM + 512 GB RAM) pool, and system RAM stayed flat at
  ~11.6-11.8 GiB throughout (the `--tensor-split 54,9,8,8` placement keeps
  nearly everything on GPU/VRAM). Full data: `bin/logs/2026-08-19T220559Z-kv-cache-sweep.{txt,json}` and per-context server logs `bin/logs/2026-08-19T220559Z-kv-ctx*.log`.
 - [x] Task 2.2: Confirm the highest-quality quant that reliably supports 350-370K context with safe margin, based on Task 2.1 (start from UD-Q5_K_XL @ 570 GB in the 896 GB pool; step to UD-Q4_K_XL only if KV headroom demands) — depends on: Task 2.1 — status: done — 2026-08-20. Task 2.1's aggregate numbers (~233-235 GiB @ 350-370K vs the 896 GB pool) are necessary but not sufficient, since `--tensor-split 54,9,8,8` splits model weight AND KV-cache growth unevenly per GPU (each hard-capped at 97,288 MiB) — so the real gate is per-GPU headroom, not the pool sum. Per-GPU `memory breakdown` lines were pulled from all 5 Task 2.1 logs.

  **Primary evidence — measured floor, no extrapolation needed:** Task 2.1
  already directly measured `ctx=524,288` (512K tokens, `status=ok` on all
  4 GPUs), and 524,288 > 370,000 (REQ-003's upper bound). Since
  KV-cache/compute-buffer memory use is monotonically non-decreasing in
  context size, the *measured* per-GPU margin at 512K is a guaranteed
  floor for the actual 350-370K target — stronger evidence than a
  projection past the tested range:

  | GPU | free @ ctx=524,288 (measured) | % free |
  |---|---|---|
  | CUDA0 | 38,717 MiB (~37.8 GiB) | 39.80% |
  | **CUDA1 (worst)** | **26,153 MiB (~25.5 GiB)** | **26.89%** |
  | CUDA2 | 33,686 MiB (~32.9 GiB) | 34.63% |
  | CUDA3 | 45,727 MiB (~44.7 GiB) | 47.00% |

  Worst case CUDA1 (holds the most static MoE weight, 62,690 MiB) still
  retains ~26.9% (~25.5 GiB) free at a context size *larger* than the
  target — so the true 370K margin is guaranteed to be at least this good.

  **Secondary evidence — linear regression, for color only:** the same 5
  log points, regressed (free MiB vs ctx) per GPU, project CUDA1's margin
  at the *actual* 370K target at ~27.7 GiB (~28%) free — consistent with
  (and, as expected, slightly better than) the measured 512K floor above,
  confirming monotonicity. CUDA0 (assigned the largest KV-cache growth
  share) closes its margin fastest as context grows but stays ahead of
  CUDA1 throughout the tested range.

  Both figures comfortably clear an adopted safety-margin policy of
  **≥15% free VRAM per GPU, or ≥10 GiB absolute, whichever is greater**,
  at the 350-370K target (covers production extras Task 2.1's load-only
  probe didn't exercise: larger batch sizes, the prompt cache seen enabled
  at 8,192 MiB, OpenCode tool-call payloads, OS/driver overhead).
  **Decision: keep `UD-Q5_K_XL`** (near-lossless, 99.9% KLD) as the
  production quant under the validated `--n-cpu-moe 54 --tensor-split
  54,9,8,8` placement; `UD-Q4_K_XL` fallback is not needed for this
  hardware/placement combo (see ACC-005 for the recorded rationale, and
   Decisions Made for the safety-margin policy).
- [ ] Task 2.2.1: Benchmark `--load-mode none` (direct/eager read) vs the `mmap` default for `UD-Q5_K_XL` cold-load wall-clock time — run BEFORE Task 2.3's install, via the same kind of ad-hoc probe script used for Task 2.1/2.2 (not the installed systemd service), so the winning mode is baked into `bin/08-llama-glm-5.2.service` from the start instead of requiring an edit-and-reinstall cycle after the fact. Does not need to wait on Track A/PCIe rebalancing or the finalized production context size: the `--load-mode` difference is about the tensor-loading phase (reading/mapping the ~524 GiB GGUF file), which is essentially independent of `--ctx-size` (KV-cache allocation is a separate, fast step after tensor loading) — so this can run at any convenient context size (e.g. reuse the small `ctx=4096` probe shape from Task 2.1). Motivated by this box being power-cycled at the start of each ~8.4h working day, where the measured ~45-minute mmap cold load (`bin/logs/2026-08-20T055618Z-kv-ctx768000.log`) already costs ~9% of the day. Acceptable to trade mmap's lazy CPU-RAM residency for a faster eager read here since this box runs GLM-5.2 exclusively with no other RAM consumers once in production use (see Decisions Made for the full reasoning/tradeoff discussion). Adopt whichever mode loads faster; feed the winning value into Task 2.3's `bin/08-llama-glm-5.2.service` alongside the finalized `--ctx-size`/`--tensor-split`/`--n-cpu-moe` values — depends on: Task 2.2 — status: not-started
- [ ] Task 2.3: Install the engine + GLM-5.2 as a systemd service with the chosen quant and GPU/CPU-RAM placement — depends on: Task 2.2, Task 2.2.1 — status: in-progress — 2026-08-20: draft artifacts created — `bin/08-llama-glm-5.2.service` (systemd unit, placeholder `--ctx-size 524288` / `--n-cpu-moe 54 --tensor-split 54,9,8,8`, port 8092, follows feat-1's `vllm-deepseek-v4-flash.service` conventions already installed on this box: `User=user`, `--host 0.0.0.0`, `Restart=on-failure`, etc.) and `bin/09-install-llama-glm-service.sh` (installer: copy + `daemon-reload` + `enable`, deliberately NOT `start` — that's Task 2.4). **Not yet installed** — gated on three open items running/pending in parallel: (1) a follow-up empirical probe at `ctx=768,000`/`896,000` (`bin/07-measure-kv-cache-768-896.sh`, copied from `bin/06`, hardcoded to just these 2 sizes — user is running it separately, already confirmed live on the box as of 2026-08-20: `llama-server --ctx-size 768000 ...` loading under tmux session `glm-kv-768-986`), motivated by a "go for 1M context" ask whose math didn't hold up (see below); (2) a `--tensor-split`/`--n-cpu-moe` rebalancing discussion informed by PCIe topology, confirmed via `nvidia-smi --query-gpu=index,pcie.link.gen.max`: **GPU0 and GPU2 are PCIe 5.0 x16, GPU1 and GPU3 are PCIe 4.0 x16** (Gen5 ≈ 2x Gen4 bandwidth/lane) — relevant because CUDA0 (currently the disproportionately KV-cache-heavy GPU under the validated split) happens to sit on the faster bus, while CUDA1 (heaviest static MoE weight) sits on a slower one; whether/how to lean on that asymmetry when rebalancing is still open; (3) Task 2.2.1's `--load-mode` benchmark result. Once all three land, swap `--ctx-size`/`--tensor-split`/`--n-cpu-moe`/`--load-mode` in `bin/08-*.service` to the finalized values, then run `bin/09-install-llama-glm-service.sh`.

  **Why the follow-up probe exists — "go for 1M" checked against the math first:** extending Task 2.2's per-GPU linear regressions to `ctx=1,048,576` (1M, GLM-5.2's advertised max) projects CUDA0 (the GPU with the steepest KV-cache-growth slope, ~66.3 MiB/1K tokens) down to only ~3.89 GiB (~4.1%) free — clearly below the adopted ≥15%/≥10 GiB safety-margin policy, and this is ~2x beyond the largest size Task 2.1 actually measured (524,288), so it's genuine extrapolation risk, not just a policy breach. Extending the same regression to intermediate sizes:

  | ctx (tokens) | CUDA0 free (projected) | vs. ≥15%/≥10 GiB policy |
  |---|---|---|
  | 768,000 | ~22.0 GiB (~23.2%) | passes comfortably |
  | 896,000 | ~13.8 GiB (~14.5%) | borderline — just under 15%, still >10 GiB flat |
  | 960,000 | ~9.6 GiB (~10.1%) | fails both thresholds, though still mathematically positive |
  | 1,048,576 | ~3.9 GiB (~4.1%) | fails clearly |

  768K and 896K were picked for the follow-up probe as the genuinely informative gray zone (960K/1M were dropped — the math already says "no" clearly enough not to burn a ~20-30 min load cycle on them).
- [x] Task 2.3.1: Prepare a script to tune `vm.swappiness` down (target `1`, not `0`) via `/etc/sysctl.d/` (persisted across reboots) on the Dell 7960T — keep swap enabled as a last-resort safety net for genuine memory-pressure emergencies, but stop the kernel from proactively swapping anonymous pages during normal operation (default `swappiness=60` is tuned for general-purpose workloads, not this single dedicated, capacity-planned appliance). Explicitly NOT disabling swap outright — see Decisions Made for the full rationale (mmap'd GGUF weight pages are file-backed/cleanly-reclaimable and don't depend on swap at all; swap only covers anonymous memory, and its gradual growth has already served as a useful early-warning canary during Task 2.1's incidents, which a hard OOM-kill would not) — depends on: none — status: done — 2026-08-20: `bin/10-tune-vm-swappiness.sh` created (idempotent: checks current value + persisted file before writing, writes `/etc/sysctl.d/99-glm-swappiness.conf`, applies immediately via `sudo sysctl --system` so no reboot is required, verifies the resulting value and warns if a conflicting sysctl file wins). Requires sudo on the box, same as `bin/09`. **Run on the actual box 2026-08-20** — succeeded: `vm.swappiness` confirmed `60 -> 1`, persisted at `/etc/sysctl.d/99-glm-swappiness.conf`. Two unrelated `sysctl: setting key ... Invalid argument` warnings appeared for pre-existing `net.ipv4.conf.all.accept_source_route`/`promote_secondaries` keys — harmless, caused by `sudo sysctl --system` re-applying every existing sysctl file on the box, not by `99-glm-swappiness.conf` (confirmed by the final readback showing `vm.swappiness` at the correct target value). Also surfaced an important new finding, logged as Task 3.1: `/swapfile` is only 2 GiB total and already ~1.8 GiB (~90%) used — see Decisions Made and Task 3.1 for why this changes the swap-policy premise
- [ ] Task 2.4: `systemctl start` the service; curl smoke test against `/v1/chat/completions`, verify tool-calls and all 3 reasoning modes (reasoning_effort max/high, enable_thinking:false). If engine is llama.cpp, explicitly verify OpenAI-compatible tool-calling works for OpenCode (REQ-011 risk) — depends on: Task 2.3 — status: not-started
- [ ] Task 2.5: Validate the finalized production context size (768K or 896K — see Task 2.3's Track A result; both comfortably exceed REQ-003's 350-370K minimum bar) works without OOM — depends on: Task 2.4 — status: not-started
- [ ] Task 2.5.1: Measure actual generation throughput (tokens/min in and tokens/min out, or tok/s) for `UD-Q5_K_XL` in the production config (`--n-cpu-moe 54 --tensor-split 54,9,8,8`), at the finalized production context size — Task 2.1/2.2 were model-load/VRAM-allocation probes only, not decode-speed benchmarks; the only speed figure on record (~39 tok/s, Task 1.2) is for the much lighter `UD-IQ1_S` spike quant and is not representative, since `UD-Q5_K_XL` streams the majority of MoE expert weight from CPU RAM per decode step (`--n-cpu-moe 54`), which is structurally slower. Runs against the already-installed service, which already has Task 2.2.1's winning `--load-mode` baked in — no second cold-load-mode comparison needed here — depends on: Task 2.5 — status: not-started
- [ ] Task 2.6: Connect OpenWebUI and OpenCode to the GLM-5.2 endpoint as a separate model entry — depends on: Task 2.5 — status: not-started
- [ ] Task 2.7: User runs the SAME coding-task examples from feat-1 (Task 1.7 / ACC-010) against this endpoint for a direct quality comparison — depends on: Task 2.6 — status: not-started

#### Phase 3: Optimisations (nice-to-have, non-blocking on Phase 2)

- [ ] Task 3.1: Evaluate/resize the `/swapfile` swap device. Discovered while actually running Task 2.3.1's `bin/10-tune-vm-swappiness.sh` on the box (2026-08-20): the swap device is only **2 GiB total, already ~1.8 GiB (~90%) used** — much smaller than assumed when the swap-policy decision was made. This meaningfully changes that decision's premise: at 2 GiB against a 512 GiB RAM pool, swap cannot absorb anything close to the multi-hundred-GB-scale anonymous-memory incidents already seen in Task 2.1 (Incident #1 alone consumed ~1.4 GiB of this same 2 GiB device in well under a minute — ~70% of its entire capacity from one transient event). At this size swap functions as an early trip-wire signal, not a real capacity cushion — `vm.swappiness=1` (Task 2.3.1) still correctly reduces *proactive* swapping, but does not fix the fact that any genuine pressure event would exhaust this device almost immediately and fall through to the OOM-killer anyway, safety-net or not. Decide whether to enlarge the swapfile (and to what size) to make it a meaningful buffer, or explicitly accept it as trip-wire-only and document that — depends on: Task 2.3.1 — status: not-started

**Note:** If a task's scope changes mid-flight, edit its description in place;
rely on git history (`git log -p` on this file) to recover what was
originally planned, rather than keeping a second copy of the task around.

## Progress

### Current Status

**As of 2026-08-20**: Phase 1 SM120 correctness spike
**PASSED** — `llama.cpp` (fresh CUDA build at `/data/llama.cpp-dsa`,
commit `ee4c505a4`) serves GLM-5.2's DSA decode correctly on this box's 4
SM120 GPUs: coherent, deterministic (byte-identical across repeat runs at
temperature=0), and factually correct output (e.g. "Paris", a working
recursive `factorial()`) across chit-chat/factual/code prompts
(`bin/03-spike-glm-dsa.sh`, strengthened by
`bin/05-spike-glm-dsa-strong.sh`). REQ-010/ACC-002 closed; Task 1.1-1.4 all
done (Task 1.3 not-applicable — first engine tried already worked). This
also became a cross-feature signal for `feat-1`: its vLLM
`FLASHINFER_MLA_SPARSE_DSV4` bug (upstream vllm-project/vllm#52938) now has
a second, independent (though not conclusive) data point suggesting
engine-specific rather than SM120-fundamental — a candidate follow-up
comment is drafted (NOT posted) at `followup-comment-draft.md`.
Quant download (`bin/00-download-glm-quants.sh`) was deliberately started
ahead of the Phase 1 gate passing (user instruction, logged as a Decisions
Made deviation): `UD-IQ1_S` (spike, 217 GB) finished; **`UD-Q5_K_XL`
(target, 562 GB) is now DONE** (confirmed via `bin/04-dl-status.sh`,
100.1%); `UD-Q4_K_XL` (fallback, 467 GB) in progress, 60.8% at last check
(~13.4 MB/s sampled rate, ETA ~3.8h — bandwidth looked slow, re-check
before trusting the ETA). GPUs are currently idle/free.

**Task 2.1 (KV-cache measurement) is now also done.** `bin/06-measure-kv-cache.sh`'s
adaptive ramp (4K→32K→128K→256K→512K) on `UD-Q5_K_XL` succeeded at all 5
sizes after two unsafe-MoE-placement incidents were fixed (`--n-cpu-moe 54
--tensor-split 54,9,8,8`, see Decisions Made). Result: ~186-239 GiB total
GPU memory across the 4K→512K range, system RAM flat at ~11.6-11.8 GiB,
derived rate **~0.104 GiB KV cache per 1K context tokens** on a **~197.3
GiB fixed footprint**, extrapolating to ~233-235 GiB total at the
350-370K REQ-003 target — large headroom inside the 896 GB pool, and no
context-size ceiling found up to 524K tokens (the tested range's upper
bound, not a hard limit). See Task 2.1 for the full per-context table and
log references.

**Task 2.2 (quant confirmation) is now also done.** Task 2.1's aggregate
number wasn't sufficient on its own (the `54,9,8,8` tensor-split splits
weight/KV growth unevenly per GPU, each capped at 97,288 MiB), so a
per-GPU linear regression was run against the same 5 log points. Worst
case at the 370K upper bound is CUDA1 with ~27.7 GiB (~28%) free —
comfortably clearing an adopted ≥15%-or-≥10 GiB per-GPU safety margin.
**Decision: `UD-Q5_K_XL` confirmed as the production quant**; the
`UD-Q4_K_XL` fallback is not needed for this hardware/placement. See Task
2.2/ACC-005 for the full per-GPU table and rationale.

**Task 2.3 (systemd install) is in progress, split into two parallel
tracks.** A "go for the full 1M context" idea was checked against the
per-GPU regressions first: it fails (CUDA0 projects to ~4.1% free at 1M),
but the projections for 768K/896K looked genuinely uncertain rather than
clearly pass/fail, so:
- **Track A (empirical, running now, not by the assistant):** a hardcoded
  two-size copy of the measurement script, `bin/07-measure-kv-cache-768-896.sh`
  (768K/896K only, no adaptive ramp/bisection), confirmed live on the box
  as of 2026-08-20 — `llama-server --ctx-size 768000 ...` loading under
  tmux session `glm-kv-768-986` (PID 137131 at check time). **Last checked
  2026-08-20T06:05Z**: still loading the first probe (`ctx=768000`), GPU
  memory still at idle baseline (~562-570 MiB/GPU) — the ~562 GB quant's
  cold load is disk-bound (historically 20-45+ min per load, see
  `bin/06-measure-kv-cache.sh`'s header), so this is expected, not a hang.
  Result file: `bin/logs/2026-08-20T055618Z-kv-cache-768-896.txt`
  (currently just the header/baseline line — no probe result recorded
  yet). Per this repo's own long-running-job guidance (see AGENTS.md /
  `feat-1`'s Task 2.1 incident), this run should be left to the user's own
  monitoring (tmux session already attached) rather than polled
  tick-by-tick from an assistant session — the next session should just
  read the finished `bin/logs/*-kv-cache-768-896.txt`/`.json` and the two
  per-context `*-kv-ctx768000.log`/`*-kv-ctx896000.log` files once it's
  done, rather than re-running `nvidia-smi`/`ps` in a loop.
- **Track B (installation plan, drafted in parallel):** `bin/08-llama-glm-5.2.service`
  (systemd unit, placeholder `--ctx-size 524288`/512K — the largest size
  Task 2.1 directly measured, not extrapolated — and the validated
  `--n-cpu-moe 54 --tensor-split 54,9,8,8`, port 8092 to avoid colliding
  with the ad-hoc measurement-script port 8091 or feat-1's vLLM port
  8000) and `bin/09-install-llama-glm-service.sh` (installer: copy +
  `daemon-reload` + `enable`, deliberately NOT `start`). Both follow the
  `User=user`/`--host 0.0.0.0`/`Restart=on-failure`/etc. conventions of
  feat-1's already-installed (currently inactive) `vllm-deepseek-v4-flash.service`
  on this same box. **Not installed yet** — pending Track A's results and
  a `--tensor-split` rebalancing discussion.
- **New info feeding that rebalancing discussion:** `nvidia-smi
  --query-gpu=index,pcie.link.gen.max` confirms **GPU0/GPU2 are PCIe 5.0
  x16, GPU1/GPU3 are PCIe 4.0 x16**. CUDA0 (the GPU with the steepest
  KV-cache-growth slope under the current split, and thus the binding
  constraint at high context) happens to already sit on the faster bus;
  CUDA1 (heaviest static MoE weight) sits on a slower one. Whether/how to
  use that asymmetry when rebalancing is the next discussion, once Track
  A's data is in.

**Task 2.3.1 (swap tuning) is done — actually run on the real box, not
just scripted.** `bin/10-tune-vm-swappiness.sh` executed successfully:
`vm.swappiness` confirmed `60 -> 1`, persisted at
`/etc/sysctl.d/99-glm-swappiness.conf`. Surfaced an important new fact not
known when the swap-policy decision was made: `/swapfile` is only **2 GiB
total, already ~1.8 GiB (~90%) used** — weakens (does not reverse) the
"swap as a safety net" argument, since it's too small to absorb anything
close to the multi-hundred-GB incidents already seen in Task 2.1. Tracked
as new **Task 3.1** in a new **Phase 3: Optimisations** (non-blocking on
Phase 2).

**Task 2.2.1 (load-mode benchmark) is in progress.** `bin/11-benchmark-load-mode.sh`
created (compares `mmap` default vs. `--load-mode none` at `--ctx-size
896000`, fixed per instruction). **First attempt (2026-08-20) was killed
mid-run** after live observation (using `/proc/<pid>/io` deltas, 3 samples
over ~3.5 min) showed disk-read throughput degrading from ~120 MB/s down
to ~53 MB/s — a real, measured slowdown, not perception. Root cause
confirmed via `/proc/mdstat`: an active `mdadm` RAID10 consistency check
on `/dev/md126` (the exact array `/data` lives on; started 2026-08-05,
84.1% done, resumed 4h21m earlier via `mdcheck_continue.timer`) was
competing for disk I/O with the model load — a genuine confound for a
clean load-mode comparison, not just an annoyance. Both the benchmark
script and its `llama-server` child were killed cleanly (confirmed: GPU
memory drained to true idle 2-10 MiB/GPU, port 8091 freed), then the RAID
check was paused (`echo idle | sudo tee /sys/block/md126/md/sync_action`
— confirmed via `sync_action: idle` and no active `check` line in
`/proc/mdstat`). **User is restarting `bin/11` under clean I/O conditions
as of session end** — next session should pick up its result once done,
and remember the RAID check is currently PAUSED, not cancelled or
finished (resume later with `echo check | sudo tee
/sys/block/md126/md/sync_action`, or it may auto-resume via the next
`mdcheck_continue.timer` fire — do not forget it was paused for this
reason).

### Next Steps

1. **Task 2.1 and Task 2.2 are both done**; **Task 2.3 is in progress**
   (two parallel tracks — see Current Status). **Do not poll Track A
   tick-by-tick in a new assistant session** — it's a long unattended job
   (still loading `ctx=768000` as of the last check, 2026-08-20T06:05Z;
   two probes total, each potentially 20-45+ min); let it run under tmux
   session `glm-kv-768-986` and just read the finished
   `bin/logs/2026-08-20T055618Z-kv-cache-768-896.txt`/`.json` (or whatever
   later timestamp if re-run) and the per-context
   `*-kv-ctx768000.log`/`*-kv-ctx896000.log` for per-GPU
   `common_memory_breakdown_print` results once it's actually done.
2. **Task 2.2.1 is IN PROGRESS, restarting now.** `bin/11-benchmark-load-mode.sh`
   exists (fixed at `--ctx-size 896000`). First attempt was killed
   mid-run due to confirmed RAID-check I/O contention (see Current
   Status) — the RAID check has now been paused, and the user is
   restarting `bin/11` under clean conditions. Next session: check
   whether it finished (`bin/logs/*-load-mode-bench.txt`/`.json`), and if
   so, read the RECOMMENDATION line to see which `--load-mode` won; feed
   that into `bin/08-llama-glm-5.2.service` before Task 2.3 install. If
   still running, do NOT poll it tick-by-tick (same long-unattended-job
   guidance as Track A) — just check the log file once.
3. **Remember to resume the paused RAID check** once `bin/11` (and
   ideally Track A too, if still relevant) are done consuming disk I/O:
   `echo check | sudo tee /sys/block/md126/md/sync_action` (or it may
   auto-resume via the next `mdcheck_continue.timer` fire on its own).
   It was at 84.1% when paused — don't forget it's paused, not finished
   or cancelled.
4. Once Track A's results are in: hold the `--tensor-split`/`--n-cpu-moe`
   rebalancing discussion (PCIe topology — GPU0/GPU2 are PCIe 5.0 x16,
   GPU1/GPU3 are PCIe 4.0 x16 — is the new input for that), settle on
   final `--ctx-size`/`--tensor-split`/`--n-cpu-moe`/`--load-mode` values,
   edit `bin/08-llama-glm-5.2.service` accordingly, then run
   `bin/09-install-llama-glm-service.sh` to actually install (copy +
   `daemon-reload` + `enable`, not `start`).
5. Continue Task 2.4 (`systemctl start`, curl smoke test, tool-calls, all
   3 reasoning modes) through Task 2.7 (OpenWebUI/OpenCode wiring,
   real context validation at the finalized 768K/896K target, quality
   comparison vs. `feat-1`), including Task 2.5.1 (measure actual
   tok/min-in/tok/min-out throughput for `UD-Q5_K_XL` — currently
   unmeasured; Task 2.1/2.2 were memory-only probes).
6. **Task 2.3.1 is fully done** — `bin/10-tune-vm-swappiness.sh` actually
   run on the box, `vm.swappiness` confirmed `1`. Follow-up spun off as
   **Task 3.1** (Phase 3: Optimisations) — decide whether to enlarge the
   2 GiB `/swapfile`, not yet started, non-blocking on Phase 2.
7. Let `bin/00-download-glm-quants.sh` keep finishing `UD-Q4_K_XL`
   (fallback, 60.8% at last check) in the background — check progress any
   time with `bin/04-dl-status.sh`. No longer a gate on anything now that
   Task 2.2 has confirmed `UD-Q5_K_XL` as the production quant; can be left
   to finish or abandoned at the user's discretion.
8. Decide whether to post `followup-comment-draft.md` to
   vllm-project/vllm#52938 — drafted and hedged, deliberately left for a
   separate decision, not posted.
9. `feat-1`'s parallel SGLang/vLLM-version diagnostics remain independently
   useful context if they report back, but are no longer a hard dependency
   — this feature already has one confirmed working engine (`llama.cpp`).

### Blockers

- None currently open. (Former blocker — REQ-010/GLM-5.2 DSA decode on
  SM120 unverified — resolved via the Phase 1 spike; see Current Status.)
  The former soft dependency — Phase 2 gated on the
  `UD-Q5_K_XL`/`UD-Q4_K_XL` downloads — resolved for the target quant
  (`UD-Q5_K_XL` finished, confirmed via `bin/04-dl-status.sh`), and Task
  2.1's KV-cache measurement is now also done (see Task 2.1/Current
  Status):   `UD-Q5_K_XL` fits 350-370K context with large headroom
  (~235 GiB vs the 896 GB pool), and Task 2.2's per-GPU analysis confirms
  `UD-Q5_K_XL` as the production quant (worst-case GPU still ~28% free at
  370K). `UD-Q4_K_XL` (fallback) is still downloading in the background
  (60.8% at last check) but is no longer needed for anything in the
  current plan. **Soft dependency (not a hard blocker):** Task 2.3's
  systemd install is drafted but not yet run — waiting on Track A's
  768K/896K empirical results (running now, separately), the
  `--tensor-split` rebalancing discussion, and Task 2.2.1's `--load-mode`
  result before finalizing `bin/08-llama-glm-5.2.service`'s
  placement/context values.
- **Maintenance loose end (not a feature blocker, but do not lose track
  of it):** the box's `/dev/md126` RAID10 consistency check (the array
  `/data` lives on) is currently PAUSED (`sync_action: idle`), not
  finished or cancelled — it was at 84.1% when paused to eliminate I/O
  contention for Task 2.2.1's `bin/11` benchmark. Resume it once `bin/11`
  (and any other disk-heavy work) is done:
  `echo check | sudo tee /sys/block/md126/md/sync_action` (or it may
  auto-resume on its own via the next `mdcheck_continue.timer` fire).

### Recent Updates

#### 2026-08-20 (Task 2.3.1 real run, Task 2.2.1 creation + RAID-contention incident)

- Completed: Implemented Task 2.3.1 — `bin/10-tune-vm-swappiness.sh`
  created (idempotent, persists `vm.swappiness=1` via
  `/etc/sysctl.d/99-glm-swappiness.conf`, applies immediately via `sudo
  sysctl --system`). User ran it on the actual box: succeeded,
  `vm.swappiness` confirmed `60 -> 1`. Two unrelated `sysctl: ... Invalid
  argument` warnings for pre-existing `net.ipv4.conf.all.*` keys appeared
  (harmless — caused by `sysctl --system` re-applying every existing
  sysctl file, not ours).
- Found: running Task 2.3.1 surfaced that `/swapfile` is only 2 GiB total
  and already ~90% used — much smaller than assumed when the swap-policy
  decision was made, weakening (not reversing) its "safety net" argument.
  Logged as a Decisions Made update and spun off as new **Task 3.1** in a
  new **Phase 3: Optimisations** (non-blocking on Phase 2).
- Completed: Implemented Task 2.2.1 — `bin/11-benchmark-load-mode.sh`
  created (compares `--load-mode none` vs. the `mmap` default for
  `UD-Q5_K_XL` cold-load wall-clock time, fixed at `--ctx-size 896000`
  per instruction; sequenced to run BEFORE Task 2.3's install rather than
  after Task 2.4, since the winning mode is an input to
  `bin/08-llama-glm-5.2.service`).
- Found (incident): the user's first `bin/11` run appeared to be loading
  slower than earlier loads. Verified this live and quantitatively — this
  session has actual shell access to the box (`hostname` = `sys0`, real
  `nvidia-smi`/GPUs present), not just the repo checkout. Sampled
  `/proc/<pid>/io`'s `read_bytes` three times over ~3.5 minutes: rate
  dropped from ~120 MB/s (cumulative average) to ~53 MB/s (most recent
  window) — a real, measured slowdown, not perception. Root-caused via
  `/proc/mdstat`: an active `mdadm` RAID10 consistency check on
  `/dev/md126` (the exact array `/data`/the GGUF file lives on; started
  2026-08-05, at 84.1%, last resumed via `mdcheck_continue.timer` 4h21m
  earlier) was competing for disk I/O with the model load. This was also
  a genuine methodological problem for Task 2.2.1 itself: an uncontrolled,
  time-varying confound would have made the two `--load-mode` probes
  incomparable if one ran during active contention and the other didn't.
- Completed: killed the run cleanly at the user's request — `llama-server`
  (SIGTERM, exited cleanly) and the wrapper script `bin/11` itself (so it
  would not auto-advance to the second probe). Confirmed clean teardown:
  GPU memory drained to true idle (2-10 MiB/GPU), port 8091 freed.
- Completed: paused the RAID check at the user's request —
  `echo idle | sudo tee /sys/block/md126/md/sync_action` — but this
  specific step required `sudo`, and the assistant's shell session had no
  cached credential and no way to supply an interactive password, so the
  user ran that one command themselves. Confirmed paused afterward
  (`sync_action: idle`, `sync_completed: none`, no active `check` line in
  `/proc/mdstat`).
- Next: user is restarting `bin/11` under clean I/O conditions. Once it
  finishes, read `bin/logs/*-load-mode-bench.txt`/`.json`'s
  RECOMMENDATION line and feed the winning `--load-mode` into
  `bin/08-llama-glm-5.2.service` before Task 2.3 install. Remember to
  resume the paused RAID check afterward (see Blockers) — it is paused,
  not finished or cancelled.

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

#### 2026-08-19 (download, llama.cpp CUDA build, Phase 1 spike — ahead of the Phase 1 gate)

- Decided (user instruction, deviation from the "wait for Phase 1" plan):
  started the GGUF quant download in parallel with other work rather than
  waiting for the Phase 1 spike to pass first. Recorded as its own
  Decisions Made entry below.
- Completed: `bin/00-download-glm-quants.sh` — pulls `UD-IQ1_S` (spike),
  `UD-Q5_K_XL` (target), `UD-Q4_K_XL` (fallback) from `unsloth/GLM-5.2-GGUF`
  @ pinned `abc55e72527792c6e77069c99b4cb7de16fa9f23`. `UD-IQ1_S` finished
  first (as ordered); `UD-Q5_K_XL` in progress at session end. Also
  `bin/04-dl-status.sh` for on-demand progress/rate/ETA reporting.
- Completed: `bin/01-clone-llama-cpp-dsa.sh` + `bin/02-build-llama-cpp-dsa.sh`
  — a fresh, dedicated `llama.cpp` checkout at `/data/llama.cpp-dsa`
  (commit `ee4c505a4`, separate from an unrelated existing checkout at
  `~/src/llama.cpp`), built with `-DGGML_CUDA=ON`; confirmed CUDA-linked
  and targeting Blackwell (`CMAKE_CUDA_ARCHITECTURES` includes `120a-real`).
  Pure CPU/compiler work, done in parallel with the download and while
  GPUs were still occupied by `feat-1`'s service.
- Completed: `bin/03-spike-glm-dsa.sh` (Task 1.2 first pass) and
  `bin/05-spike-glm-dsa-strong.sh` (strengthened follow-up: multiple
  prompts, `enable_thinking:false` for finished answers, 2x repeat for
  determinism) — see Task 1.2/1.3/1.4/ACC-002 for full results. **REQ-010
  passes**: llama.cpp's GLM-5.2 DSA decode is coherent, deterministic, and
  factually correct on this box's SM120 GPUs.
- Found: cross-referenced this result into `feat-1`'s README — its vLLM
  `FLASHINFER_MLA_SPARSE_DSV4` bug (upstream vllm-project/vllm#52938) now
  has a second, independent corroborating data point suggesting
  engine-specific rather than SM120-fundamental. Not yet posted as an
  upstream comment — left as a deliberate follow-up decision, not done
  automatically.
- Completed: drafted (NOT posted, user instruction) a candidate follow-up
  comment for `feat-1`'s upstream vLLM issue
  (https://github.com/vllm-project/vllm/issues/52938), at
  `followup-comment-draft.md` (this feature folder's root, not `bin/` — a
  draft document, not a script). Cites this feature's Task 1.2/1.4 result
  as corroborating-but-not-conclusive evidence (engine-specific vs.
  SM120-fundamental), explicitly hedged: different model, different
  quantization, and a genuinely different attention kernel implementation
  than the one `feat-1` hit the bug in.
- Next: Phase 2 is now unblocked in principle (Task 1.4 done) — but still
  gated on `UD-Q5_K_XL`/`UD-Q4_K_XL` finishing download (Task 2.1 KV-cache
  measurement needs the real target quant, not the 1-bit spike quant).

#### 2026-08-19 (download status check — target quant confirmed done)

- Completed: Ran `bin/04-dl-status.sh` on the box. Results: `UD-IQ1_S`
  216.7/217 GB (99.9%), **`UD-Q5_K_XL` 562.5/562 GB (100.1% — done)**,
  `UD-Q4_K_XL` 284.0/467 GB (60.8%, in progress). Live rate sample on the
  active `UD-Q4_K_XL` download: ~13.4 MB/s, ETA ~3.8h (looked slow —
  re-check before trusting the ETA). GPUs idle/free at check time.
- Found: since the Phase 2 target quant (`UD-Q5_K_XL`) is fully downloaded,
  the "wait for downloads" gate on Phase 2 is resolved for Task 2.1
  specifically — it does not need the `UD-Q4_K_XL` fallback, only needed
  later if Task 2.2's KV-cache headroom check forces a step-down.
- Next: Start Phase 2 — Task 2.1 (measure real KV-cache cost per 1K tokens
  on `llama.cpp` at real context shapes) — while `UD-Q4_K_XL` keeps
  downloading in the background.

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
- **2026-08-19 (deviation from Phase 1 gate)**: Started the GGUF quant
  download (`bin/00-download-glm-quants.sh`) in parallel with other work,
  ahead of the Phase 1 SM120 correctness spike passing, contrary to the
  "do NOT start the ~1.5 TB download until Phase 1 passes" note under Next
  Steps. Rationale: disk/bandwidth is a multi-hour, engine-independent
  bottleneck (~1.25 TB total across the spike + both Phase 2 quants) that
  does not need to wait on the SM120 correctness question, and the user
  wanted it running in the background while doing other things. The spike
  quant (`UD-IQ1_S`) is still downloaded first so Task 1.2 is unblocked
  soonest; deployment (Phase 2) still will not proceed until Phase 1
  actually passes.
- **2026-08-19 (Task 2.1 KV-cache measurement — MoE placement, two
  incidents)**: `bin/06-measure-kv-cache.sh`'s llama.cpp MoE weight
  placement went through two unsafe configs before landing on a safe one,
  both on a live, monitored run (no data loss, no actual OOM-kill):
  1. `--cpu-moe` (ALL MoE expert weight on CPU RAM) assumed this would
     free VRAM for the KV cache under test without affecting the true
     KV-cache-per-token cost (correct reasoning) — but GLM-5.2 is 744B
     total/40B active, so nearly all its weight IS MoE experts: `--cpu-moe`
     pushes ~500 GiB of the ~562 GiB `UD-Q5_K_XL` quant onto this box's
     512 GiB system RAM alone. Live run showed swap climbing from ~0 to
     ~1.4 GiB in well under a minute while RSS approached ~500/502 GiB —
     killed as a precaution.
  2. `--n-cpu-moe 41` (partial CPU/GPU MoE split, no explicit
     `--tensor-split`) assumed llama.cpp spreads GPU-offloaded MoE blocks
     evenly across all 4 GPUs. It doesn't: blocks are assigned to GPUs in
     contiguous chunks (~20 each) *before* the CPU cutoff is applied, so
     one GPU (CUDA2) ended up owning a chunk entirely above the cutoff and
     tried to allocate its full, undiminished MoE weight
     (`cudaMalloc failed: out of memory ... buffer of size 138774596736`,
     ~129 GiB on one 96 GiB device).
  3. **Fix**: `--n-cpu-moe 54` + explicit `--tensor-split 54,9,8,8`,
     calibrated from the quant's own GGUF metadata (`block_count=79`,
     `leading_dense_block_count=3`, ~6.6 GiB expert weight/MoE block,
     cross-checked against incident 2's own failed-allocation byte count).
     Concentrates all cheap (CPU-side) blocks on device0 (~12.5 GiB,
     trivial) and evenly caps devices 1-3's GPU-offloaded share at
     ~53-59 GiB each (well under 96 GiB). First probe (`ctx=4096`)
     completed cleanly under this config: ~186 GiB total across 4 GPUs,
     ~11.7 GiB system RAM "used" (the earlier RSS/swap climb during
     loading turned out to be largely reclaimable mmap page-cache churn,
     not a genuine capacity crisis — confirmed post-hoc since "available"
     RAM never actually collapsed in either incident, though the swap
     growth rate in incident 1 was still a reasonable trigger for caution
     given the uncertainty at the time).
  4. **Process note**: monitoring a multi-hour, multi-probe unattended run
     tick-by-tick from the assistant session consumed significant context
     budget for comparatively low information density (mostly repeated
     `nvidia-smi`/`free`/log-tail polling). For future long-running
     watch-and-report background jobs like this, delegate the actual
     babysitting (polling loop + anomaly detection + summarizing back) to
     an implementation/monitoring specialist (e.g. a background agent or a
     dedicated task) rather than doing it inline turn-by-turn in the main
     session, to preserve the main session's context for planning/decision
     work. The user took over live monitoring directly for the remainder
     of this sweep.
- **2026-08-20 (load-mode/cold-load-time discussion)**: Added Task 2.2.1 to
  empirically compare `--load-mode none` (direct/eager read) against the
  `mmap` default for `UD-Q5_K_XL` cold-load wall-clock time. Sequenced
  BEFORE Task 2.3's systemd install (not after Task 2.4 start, as first
  drafted) — the `--load-mode` decision is an input to `bin/08-llama-glm-
  5.2.service`, same as the finalized `--ctx-size`/`--tensor-split` values,
  so it should be resolved before the service is installed rather than
  requiring an edit-and-reinstall cycle afterward. It also doesn't need to
  wait on Track A/PCIe rebalancing or the finalized context size at all,
  since the tensor-loading phase this benchmark targets is essentially
  independent of `--ctx-size` — it can run via the same kind of ad-hoc
  probe script already used for Task 2.1/2.2. Motivation:
  this box will be power-cycled at the start of each ~8.4h working day
  (not left running long-term), so the measured ~45-minute mmap cold load
  (`bin/logs/2026-08-20T055618Z-kv-ctx768000.log`: ~43 of the ~45.5 min is
  the tensor-load phase) is a *recurring daily* cost (~9% of the working
  day), not a one-time/rare-restart cost — a materially different
  trade-off than initially assumed. `mmap`'s lazy CPU-RAM residency (only
  actively-routed MoE experts get faulted in, confirmed via the ~11.6-11.8
  GiB actually-resident figure from Task 2.1 vs. the ~350 GiB logically
  mapped) is normally the safer default, since clean mmap'd pages are
  kernel-reclaimable under memory pressure, unlike the non-reclaimable
  private memory `--load-mode none` would commit instead (the same risk
  class as the `--cpu-moe` swap-growth incident above). That downside is
  judged acceptable here specifically because this box will run GLM-5.2
  *exclusively* once in production use (no other workloads, no downloads,
  no SSH sessions competing for the 512 GiB pool per the user's own
  operating model), leaving the usual RAM-headroom objection much weaker
  than on a general-purpose or long-uptime box. Additionally, since page
  cache never survives the daily power-cycle anyway, mmap's laziness only
  partially helps here (every morning re-reads from cold disk either way),
  and over a full 8.4h day of varied coding traffic most of the CPU-side
  MoE experts likely get touched regardless — reducing the "wasted read"
  downside of eagerly loading it all upfront. No hard number exists yet
  for the expected speedup (depends on this storage medium's
  random-vs-sequential I/O characteristics, not measured) — Task 2.2.1
  exists specifically to replace this reasoning with a real measurement.
  Whichever mode Task 2.2.1 finds faster is baked directly into Task 2.3's
  `bin/08-llama-glm-5.2.service` before install, so neither Task 2.5 nor
  Task 2.5.1 need to pay a second cold-load-mode comparison.
- **2026-08-20 (swap policy)**: Decided to KEEP swap enabled (not disable it
  outright), but tune `vm.swappiness` down (target `1`) — added as Task
  2.3.1. Rationale, prompted by the repeated observation that swap fills up
  during model load: (1) the `mmap`'d GGUF weight pages (the large bulk of
  this workload's memory footprint) are file-backed and cleanly reclaimable
  regardless of swap — they can simply be dropped and re-read from disk, so
  swap was never actually protecting the model weights in the first place;
  the swap growth actually observed during Task 2.1's `--cpu-moe` incident
  must therefore have come from some other anonymous-memory consumer (page
  table overhead for the huge sparse mapping, loader staging buffers, or
  the kernel's default swappiness heuristics), not from the weights
  themselves. (2) That gradual swap growth served as a useful early-warning
  canary in the Task 2.1 incident (it let the run be killed as a
  precaution before a harder failure) — disabling swap outright removes
  that signal entirely and replaces it with an immediate OOM-kill as the
  only remaining escape valve under any unexpected memory-pressure spike.
  (3) An OOM-kill of `llama-server` is arguably worse for this box's actual
  operational goal (minimizing the recurring ~45-minute daily cold-load
  cost, see Task 2.2.1) than a slow-but-survivable swap episode, since a
  kill forces exactly the expensive reload being optimized against. (4)
  This project's own track record (two distinct unsafe-MoE-placement
  incidents in Task 2.1 before landing on a safe config) argues for keeping
  a safety margin rather than removing it, given capacity planning here has
  already been wrong twice on the first two attempts. Lowering
  `vm.swappiness` (rather than leaving the general-purpose default of `60`)
  addresses the user's actual complaint — wasted cycles from the kernel
  *proactively* swapping during normal operation — without giving up the
  emergency safety net for genuine, unexpected pressure spikes.
- **2026-08-20 (swap policy — real-world update, swap size)**: Running
  Task 2.3.1's `bin/10-tune-vm-swappiness.sh` on the actual box surfaced a
  fact not known when the swap-policy decision above was made: `/swapfile`
  is only **2 GiB total, already ~1.8 GiB (~90%) used**. This meaningfully
  weakens (without reversing) that decision's "swap as a safety net"
  argument — at 2 GiB against a 512 GiB RAM pool, swap cannot absorb
  anything close to the multi-hundred-GB-scale anonymous-memory incidents
  already seen in Task 2.1 (Incident #1 alone consumed ~1.4 GiB of this
  same 2 GiB device, ~70% of its entire capacity, in well under a minute).
  At this size, swap functions as an early trip-wire/diagnostic signal
  (which is still genuinely useful, per point (2) of the original
  decision), not a real capacity cushion capable of absorbing a serious
  overcommit — any such event would exhaust this device almost
  immediately and fall through to the OOM-killer regardless.
  `vm.swappiness=1` still stands (it correctly addresses *proactive*
  swapping, which is size-independent), but whether to also enlarge
  `/swapfile` is now open as its own question — tracked as Task 3.1 in a
  new "Phase 3: Optimisations" rather than blocking Phase 2's deployment
  work.

#### 2026-08-20 (Task 2.1 KV-cache sweep — result analysis)

- Completed: Reviewed the full `bin/06-measure-kv-cache.sh` run history in
  `bin/logs/`. Two earlier sweep attempts (`2026-08-19T203936Z`,
  `2026-08-19T212601Z`) crashed at the smallest ramp size (`ctx=4096`),
  matching the two unsafe-MoE-placement incidents already logged under
  Decisions Made 2026-08-19 ("KV-cache measurement MoE placement"): the
  first shows no explicit error (consistent with an external kill during
  the `--cpu-moe` swap-growth incident); the second shows the literal
  `cudaMalloc failed: out of memory ... buffer of size 138774596736` on
  CUDA2 (the `--n-cpu-moe 41`-without-`--tensor-split` incident). The
  third attempt (`2026-08-19T220559Z`), using the fixed
  `--n-cpu-moe 54 --tensor-split 54,9,8,8` config, completed cleanly
  across all 5 ramp sizes (4,096 / 32,768 / 131,072 / 262,144 / 524,288
  tokens), all `status=ok`, no bisection triggered.
- Found: linear fit across the 5 successful data points gives
  `total_GiB ≈ 197.3 + 0.000102 × ctx_size` → ~0.104 GiB KV cache per 1K
  context tokens, ~197.3 GiB fixed (weights+runtime) footprint.
  Extrapolated cost at REQ-003's target: ~233.0 GiB @ 350K tokens, ~235.0
  GiB @ 370K tokens — well inside the 896 GB (384 GB VRAM + 512 GB RAM)
  pool. System RAM stayed essentially flat (~11.6-11.8 GiB) across the
  whole ramp since the `--tensor-split 54,9,8,8` placement keeps almost
  all weight/KV-cache on GPU/VRAM.
- Completed: Marked Task 2.1 `done` in the Task List with the full
  per-context result table and updated Current Status/Next
  Steps/Blockers accordingly.
- Note: this was a model-load/VRAM-allocation probe per context size
  (confirms the memory budget), not an end-to-end filled-context
  generation run — that remains Task 2.5 (REQ-003/ACC-003 real validation).
- Next: Task 2.2 (confirm `UD-Q5_K_XL` as the production quant — Task
  2.1's headroom strongly supports keeping it over `UD-Q4_K_XL`) through
  Task 2.7.

#### 2026-08-20 (Task 2.2 — quant confirmation)

- Completed: Determined that Task 2.1's aggregate GPU+RAM total
  (~233-235 GiB @ 350-370K vs the 896 GB pool) was necessary but not
  sufficient to confirm the quant choice, since `--tensor-split 54,9,8,8`
  splits both model weight and KV-cache growth unevenly across the 4 GPUs
  (each hard-capped at 97,288 MiB) — the real gate is per-GPU headroom.
- Completed: Pulled the per-GPU `common_memory_breakdown_print` lines from
  all 5 Task 2.1 logs (`2026-08-19T220559Z-kv-ctx*.log`) and ran a linear
  regression (free MiB vs ctx) per GPU. CUDA1 (holds the most static MoE
  weight, 62,690 MiB) is worst-margined across the whole tested range;
  CUDA0 (assigned the largest KV-cache growth share) loses free memory
  fastest but stays ahead of CUDA1 within 4K-512K tokens.
- Found: extrapolating to REQ-003's 370K-token upper bound, the
  worst-margined GPU (CUDA1) still has ~27.7 GiB (~28% of its 97,288 MiB)
  free.
- Decided: adopted a safety-margin policy of **≥15% free VRAM per GPU, or
  ≥10 GiB absolute, whichever is greater**, at the 350-370K target (covers
  production extras the load-only Task 2.1 probe didn't exercise: larger
  batch sizes, the prompt cache, OpenCode tool-call payloads, OS/driver
  overhead). CUDA1's ~28% clears this with room to spare.
- Decided: **`UD-Q5_K_XL` confirmed as the production quant** — the
  highest-quality near-lossless option, and it fits the 350-370K target
  with large per-GPU margin under the validated
  `--n-cpu-moe 54 --tensor-split 54,9,8,8` placement. `UD-Q4_K_XL`
  fallback is not required for this hardware/placement combo.
- Completed: Marked Task 2.2 and ACC-005 `done`/`[x]` with the full
  per-GPU table and rationale; updated Current Status/Next Steps
  accordingly.
- Next: Task 2.3 — install the engine + GLM-5.2 as a systemd service using
  `UD-Q5_K_XL` and the validated GPU/CPU-RAM placement.
- Revised (same day, before moving to Task 2.3): reworked ACC-005/Task
  2.2's rationale to lead with a stronger argument. Task 2.1 already
  directly measured `ctx=524,288` (512K, `status=ok`) — since that's
  larger than REQ-003's 370K target and memory use is monotonically
  non-decreasing in context size, the *measured* margin at 512K (worst
  case CUDA1: ~25.5 GiB/~26.9% free) is a guaranteed floor for the actual
  370K target, not an extrapolation. The earlier linear-regression
  projection (~27.7 GiB/~28%) is kept only as consistency-checking color
  (it's slightly higher, as monotonicity predicts) — the decision itself
  (`UD-Q5_K_XL` confirmed) is unchanged.

#### 2026-08-20 (Task 2.3 kickoff — "go for 1M" checked, two parallel tracks started)

- Found: extending Task 2.2's per-GPU regressions to `ctx=1,048,576` (1M,
  GLM-5.2's advertised max context) in response to a "go for 1M" ask
  projects CUDA0 (steepest KV-cache-growth slope, ~66.3 MiB/1K tokens)
  down to only ~3.89 GiB (~4.1%) free — clearly below the adopted
  ≥15%/≥10 GiB safety-margin policy, and ~2x beyond the largest context
  Task 2.1 actually measured (524,288), so real behavior could plausibly
  be worse than the straight-line projection. Extending the same
  regression to intermediate round sizes identified 768K as
  comfortably-projected-safe, 896K as a genuine borderline case (~14.5%,
  just under the 15% line but still >10 GiB flat), and 960K as
  failing-the-policy-but-still-mathematically-positive (~10.1%) — 960K
  and the full 1M were dropped from the follow-up test list (the math
  already says "no" clearly enough).
- Completed: copied `bin/06-measure-kv-cache.sh` to
  `bin/07-measure-kv-cache-768-896.sh`, stripped down to FIXED mode only,
  hardcoded to exactly `ctx=768000` and `ctx=896000` (no CLI args, no
  adaptive ramp/bisection), same engine/quant/placement as the validated
  Task 2.1 run. Handed off to the user to run separately (per instruction)
  — confirmed live on the box shortly after (`llama-server --ctx-size
  768000 ...` loading under tmux session `glm-kv-768-986`, PID 137131).
- Completed (in parallel, Track B): drafted `bin/08-llama-glm-5.2.service`
  (systemd unit for `llama-server` + GLM-5.2/`UD-Q5_K_XL`, placeholder
  `--ctx-size 524288`/512K — the largest DIRECTLY measured size, not the
  extrapolated one — and the validated `--n-cpu-moe 54 --tensor-split
  54,9,8,8`; port 8092, chosen to avoid the ad-hoc measurement port 8091
  and feat-1's vLLM port 8000) and `bin/09-install-llama-glm-service.sh`
  (copy + `daemon-reload` + `enable`, explicitly not `start` — that stays
  Task 2.4). Conventions copied from feat-1's already-installed (currently
  inactive) `vllm-deepseek-v4-flash.service` on this same box for
  cross-feature consistency: `User=user`/`Group=user`, `--host 0.0.0.0`,
  `Restart=on-failure`/`RestartSec=10`, `KillMode=control-group`,
  `LimitNOFILE=65536`/`LimitMEMLOCK=infinity`,
  `WantedBy=multi-user.target`. Deliberately NOT installed yet (unit is a
  draft with placeholder values pending Track A + rebalancing).
- Found: `nvidia-smi --query-gpu=index,pcie.link.gen.max` confirms the
  user-supplied PCIe topology — **GPU0 and GPU2 are PCIe 5.0 x16, GPU1 and
  GPU3 are PCIe 4.0 x16**. Notable because CUDA0 (already the
  disproportionately KV-cache-heavy GPU under the current
  `--tensor-split`) sits on the faster bus, while CUDA1 (heaviest static
  MoE weight) sits on a slower one — this is new input for the
  `--tensor-split` rebalancing discussion, not yet acted on.
- Next: wait for Track A's 768K/896K results, then hold the rebalancing
  discussion (informed by the PCIe finding), finalize
  `bin/08-llama-glm-5.2.service`'s placement values, and run
  `bin/09-install-llama-glm-service.sh`.
- Session wrap-up (context-budget reasons, same rationale as `feat-1`'s
  Task 2.1 incident and this repo's AGENTS.md guidance): confirmed Track A
  still healthy and loading (`ctx=768000` probe, GPU memory still at idle
  baseline ~562-570 MiB/GPU, ~9 min elapsed as of 2026-08-20T06:05Z — not
  a hang, this quant's cold load is disk-bound and historically takes
  20-45+ min) before handing monitoring back to the user rather than
  polling `nvidia-smi`/`ps`/tmux tick-by-tick in this session. Nothing
  else changed on the box this session beyond what's recorded above (no
  GPU/model state touched, no files outside this feature folder). Clean
  resumption point for the next session: read
  `bin/logs/2026-08-20T055618Z-kv-cache-768-896.txt`/`.json` (or a later
  timestamp if the run was restarted) once Track A has actually finished
  both probes, then proceed with the `--tensor-split` rebalancing
  discussion (PCIe topology already captured above) before touching
  `bin/08-llama-glm-5.2.service`/`bin/09-install-llama-glm-service.sh`.

### Related PRs / Commits

- None yet
  </content>
  </invoke>
