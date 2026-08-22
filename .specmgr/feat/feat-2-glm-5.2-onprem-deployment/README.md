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
  from REQ-010 correctness). `OVERALL: no degenerate/suspicious/ non-deterministic results found`
- [ ] ACC-003: Verifies REQ-003 — empirical test confirms the endpoint
  handles a 350-370K-token coding prompt without OOM
- [ ] ACC-004: Verifies REQ-004/REQ-011 — tool-call verified via curl smoke
  test then a real OpenCode agentic session; all 3 reasoning modes
  (`reasoning_effort` max/high and `enable_thinking:false`) confirmed to
  toggle correctly. If the engine is llama.cpp, tool-calling is explicitly
  re-verified (REQ-011 risk) — **curl smoke-test half PASSED 2026-08-20**
  (Task 2.4, `bin/14-smoke-test-glm-service.sh`): all 3 reasoning modes
  produced coherent, non-degenerate, non-truncated (`finish_reason: stop`)
  output, and the tool-calling case emitted a well-formed
  `tool_calls[].function` block (`get_weather`, `arguments: {"location":"Paris"}`) — REQ-011's llama.cpp risk did NOT materialize on this
  smoke test. **Still open: the real OpenCode agentic session** (deferred
  to Task 2.6/2.7 once OpenCode is wired up) — this checkbox stays
  unchecked until that half also passes
- [x] ACC-005: Verifies REQ-005/REQ-006 — the chosen quant is recorded
  (target `UD-Q5_K_XL`, else `UD-Q4_K_XL`), with a one-line rationale for
  why it is the highest-quality option that still meets REQ-003's context
  target on this hardware (both are near-lossless per unsloth's KLD data)
  — PASS 2026-08-20 (Task 2.2): **`UD-Q5_K_XL` confirmed as the production
  quant.** Rationale: under the validated `--n-cpu-moe 54 --tensor-split 54,9,8,8` placement, Task 2.1 directly measured `ctx=524,288` (512K
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
production quant under the validated `--n-cpu-moe 54 --tensor-split   54,9,8,8` placement; `UD-Q4_K_XL` fallback is not needed for this
hardware/placement combo (see ACC-005 for the recorded rationale, and
Decisions Made for the safety-margin policy).

- [x] Task 2.2.1: Benchmark `--load-mode none` (direct/eager read) vs the `mmap` default for `UD-Q5_K_XL` cold-load wall-clock time — run BEFORE Task 2.3's install, via the same kind of ad-hoc probe script used for Task 2.1/2.2 (not the installed systemd service), so the winning mode is baked into `bin/08-llama-glm-5.2.service` from the start instead of requiring an edit-and-reinstall cycle after the fact. Motivated by this box being power-cycled at the start of each ~8.4h working day, where the measured ~45-minute mmap cold load (`bin/logs/2026-08-20T055618Z-kv-ctx768000.log`) already costs ~9% of the day — depends on: Task 2.2 — status: done. **Result (2026-08-20, `bin/11-benchmark-load-mode.sh`, `bin/logs/2026-08-20T081824Z-load-mode-bench.{txt,json}`):** `--load-mode none` loaded in 1694s (~28.2m) vs. `mmap-default`'s 1842s (~30.7m) — **8% faster**, ~2.5 min saved per cold load. Per-GPU memory footprint (`common_memory_breakdown_print`) identical between modes, as expected — `--load-mode` only affects the CPU-side tensor-loading path, not GPU placement. **3 earlier attempts** (`07:23`, `09:40`, `10:12`) were killed within seconds each, before the silent tensor-copy phase even started — not a loader hang, just impatience meeting a loader with zero progress feedback for a multi-hundred-GB copy, compounded by a genuine confound: an `mdadm` RAID10 consistency check on `/data`'s `md126` array was competing for disk I/O (see Current Status/Decisions Made for the full incident); confirmed fully resolved by the time of the successful run (`sync_action: idle`, `mismatch_cnt: 0`) — nothing left to resume. **Caveat carried into the decision, not hidden:** the script doesn't drop the page cache between the two probes, and `mmap-default` ran first — some of the 8% gap could reflect residual cache warmth on the second probe rather than a purely structural effect; judged not worth a further ~1h re-test given the modest, directionally-expected result and the trade this was always about (recovering a slice of a recurring daily cold-load cost). **DECIDED: adopt `--load-mode none`** — already added to `bin/08-llama-glm-5.2.service`'s `ExecStart`.

- [x] Task 2.3: Install the engine + GLM-5.2 as a systemd service with the chosen quant and GPU/CPU-RAM placement — depends on: Task 2.2, Task 2.2.1 — status: done — 2026-08-20: draft artifacts created — `bin/08-llama-glm-5.2.service` (systemd unit, `--ctx-size 768000` / `--n-cpu-moe 54 --tensor-split 54,9,8,8 --load-mode none`, port 8092, `--host 0.0.0.0`, `Restart=on-failure`, etc., mostly following feat-1's `vllm-deepseek-v4-flash.service` conventions where they still apply) and `bin/09-install-llama-glm-service.sh` (installer: copy + `daemon-reload`, deliberately NOT `enable` and NOT `start` — enabling is skipped on purpose, see below; starting is Task 2.4). **DECIDED (2026-08-20): install as a systemd `--user` unit** (`~/.config/systemd/user/llama-glm-5.2.service`, `systemctl --user ...`), NOT a system-wide unit — unlike `feat-1`'s vLLM service, so no `User=`/`Group=` and `sudo` is never needed for day-to-day `start`/`stop`/`restart`. **REVISED same day:** the real requirement is "keep running with no user logged in" (NOT "autostart at boot right now") — those need different, independently-controlled mechanisms: lingering (`loginctl enable-linger`, now **enabled** via `bin/13-enable-user-lingering.sh`) keeps `user`'s systemd --user manager alive without a session, while the unit itself is deliberately left **NOT enabled** so it does not autostart at boot (lingering + an enabled unit together WOULD autostart it — caught and corrected live on the box, see Decisions Made "lingering + no autostart" for the full incident/rationale). Once manually started (Task 2.4), it persists across logout; after a reboot it must be started again by hand. New **Task 2.3.2** (`bin/12-setup-user-systemd-groups.sh`, video/render groups, requires logout/login) and **Task 2.3.3** (`bin/13-enable-user-lingering.sh`, lingering — DONE, confirmed `Linger=yes`) added. **Not yet installed for production use** (loaded via `bin/09` as a dry-run check, but disabled/inactive) — **all three original gating items are now resolved, Task 2.3 is unblocked:** (1) **DONE (2026-08-20 ~10:30 CEST):** the follow-up empirical probe at `ctx=768,000`/`896,000` (`bin/07-measure-kv-cache-768-896.sh`) completed — both sizes `status=ok`; measured worst-case-GPU (CUDA0) free memory: 768K → 22,569 MiB (~22.0 GiB, 23.2%, passes comfortably), 896K → 14,079 MiB (~13.75 GiB, 14.47%, narrowly misses the 15% leg of the ≥15%/≥10 GiB policy — a ~514 MiB shortfall — though it still clears the flat ≥10 GiB leg) — near-exact match to the pre-computed projection table below, confirming the regression's reliability. Full data: `bin/logs/2026-08-20T055618Z-kv-cache-768-896.{txt,json}` and per-context `*-kv-ctx768000.log`/`*-kv-ctx896000.log`. **DECIDED (2026-08-20): production `--ctx-size` = 768,000** (already updated in `bin/08-*.service`). (2) **DECIDED (2026-08-20): NOT rebalancing `--tensor-split`/`--n-cpu-moe` before install.** The rebalancing discussion (PCIe topology: GPU0/GPU2 are PCIe 5.0 x16, GPU1/GPU3 are PCIe 4.0 x16) was only ever relevant to reclaiming 896K, not to 768K's safety — 768K already clears the margin policy comfortably and exceeds REQ-003 by 2x+, so there is no requirements pressure to rebalance. **Moved to Phase 3 as new Task 3.3** (see below), explicitly gated on Task 2.5.1's decode-throughput baseline first — rebalancing to relieve CUDA0's KV-cache pressure risks shifting CPU-offloaded-expert PCIe traffic onto a slower Gen4 GPU, which could regress decode speed in a way we currently have no baseline to even detect. 896K remains flagged as a revisit candidate, not discarded — just deferred, non-blocking. (3) **DONE (2026-08-20):** Task 2.2.1's `--load-mode` benchmark result landed — `--load-mode none` measured 8% faster than `mmap-default` (1694s vs 1842s); already added to `bin/08-*.service`'s `ExecStart` (see Task 2.2.1 above for the full result and its cache-warmth caveat). **`bin/08-llama-glm-5.2.service` is now fully finalized** (`--ctx-size 768000 --n-cpu-moe 54 --tensor-split 54,9,8,8 --load-mode none`). **INSTALLED on the box (2026-08-20):** `bin/09-install-llama-glm-service.sh` run successfully — `systemctl --user status llama-glm-5.2.service` confirms `Loaded: loaded (...; disabled; vendor preset: enabled)`, `Active: inactive (dead)`, exactly the intended state (won't autostart, ready for an explicit `start`); installed file confirmed byte-identical to `bin/08-llama-glm-5.2.service` via `diff`. **Task 2.3 is DONE.** Next up: Task 2.4 (`systemctl --user start`, then curl smoke test).

  **Why the follow-up probe exists — "go for 1M" checked against the math first:** extending Task 2.2's per-GPU linear regressions to `ctx=1,048,576` (1M, GLM-5.2's advertised max) projects CUDA0 (the GPU with the steepest KV-cache-growth slope, ~66.3 MiB/1K tokens) down to only ~3.89 GiB (~4.1%) free — clearly below the adopted ≥15%/≥10 GiB safety-margin policy, and this is ~2x beyond the largest size Task 2.1 actually measured (524,288), so it's genuine extrapolation risk, not just a policy breach. Extending the same regression to intermediate sizes:

  | ctx (tokens) | CUDA0 free (projected) | vs. ≥15%/≥10 GiB policy |
  |---|---|---|
  | 768,000 | ~22.0 GiB (~23.2%) | passes comfortably |
  | 896,000 | ~13.8 GiB (~14.5%) | borderline — just under 15%, still >10 GiB flat |
  | 960,000 | ~9.6 GiB (~10.1%) | fails both thresholds, though still mathematically positive |
  | 1,048,576 | ~3.9 GiB (~4.1%) | fails clearly |

  768K and 896K were picked for the follow-up probe as the genuinely informative gray zone (960K/1M were dropped — the math already says "no" clearly enough not to burn a ~20-30 min load cycle on them).

  **DECISION (2026-08-20): production `--ctx-size` = 768,000.** With both probes now measured (not just projected), 768K clears the ≥15%/≥10 GiB safety-margin policy on every GPU with real room to spare (worst case CUDA0 at 23.2% free), while 896K's worst GPU (CUDA0) measures 14,079 MiB free (14.47%) against a 14,593 MiB (15%) requirement — a ~514 MiB shortfall on the primary leg of the policy, even though it still clears the flat ≥10 GiB leg. Rather than ship on a config that already trips one leg of its own adopted safety policy before accounting for batch size, prompt cache, and OpenCode tool-call payloads (the exact production extras the policy was sized to cover, per Task 2.2), 768K is the safer choice, and it still comfortably exceeds REQ-003's 350-370K target by more than 2x. **896K is not discarded — it is flagged as a revisit candidate** (see Decisions Made) once the pending `--tensor-split`/PCIe-topology rebalancing lands, since shifting some of CUDA0's KV-cache share onto its faster PCIe 5.0 bus or onto another GPU could plausibly close that ~514 MiB gap.

- [x] Task 2.3.1: Prepare a script to tune `vm.swappiness` down (target `1`, not `0`) via `/etc/sysctl.d/` (persisted across reboots) on the Dell 7960T — keep swap enabled as a last-resort safety net for genuine memory-pressure emergencies, but stop the kernel from proactively swapping anonymous pages during normal operation (default `swappiness=60` is tuned for general-purpose workloads, not this single dedicated, capacity-planned appliance). Explicitly NOT disabling swap outright — see Decisions Made for the full rationale (mmap'd GGUF weight pages are file-backed/cleanly-reclaimable and don't depend on swap at all; swap only covers anonymous memory, and its gradual growth has already served as a useful early-warning canary during Task 2.1's incidents, which a hard OOM-kill would not) — depends on: none — status: done — 2026-08-20: `bin/10-tune-vm-swappiness.sh` created (idempotent: checks current value + persisted file before writing, writes `/etc/sysctl.d/99-glm-swappiness.conf`, applies immediately via `sudo sysctl --system` so no reboot is required, verifies the resulting value and warns if a conflicting sysctl file wins). Requires sudo on the box. **Run on the actual box 2026-08-20** — succeeded: `vm.swappiness` confirmed `60 -> 1`, persisted at `/etc/sysctl.d/99-glm-swappiness.conf`. Two unrelated `sysctl: setting key ... Invalid argument` warnings appeared for pre-existing `net.ipv4.conf.all.accept_source_route`/`promote_secondaries` keys — harmless, caused by `sudo sysctl --system` re-applying every existing sysctl file on the box, not by `99-glm-swappiness.conf` (confirmed by the final readback showing `vm.swappiness` at the correct target value). Also surfaced an important new finding, logged as Task 3.1: `/swapfile` is only 2 GiB total and already ~1.8 GiB (~90%) used — see Decisions Made and Task 3.1 for why this changes the swap-policy premise

- [x] Task 2.3.2: Add `user` to the `video`/`render` groups as defense-in-depth for GPU device access under the systemd `--user` unit decided for Task 2.3 — not currently required since `/dev/nvidia*` on this box are world-writable (`crw-rw-rw-`), but this should not be relied upon to stay true (a driver update or udev rule change could tighten it) — depends on: none — status: done — `bin/12-setup-user-systemd-groups.sh` created (idempotent, checks current group membership first, requires interactive sudo like `bin/10`). **Bug found and fixed during rollout:** the script originally derived its target user from `$USER`, which resolves to `root` when the script itself is invoked via `sudo` (`sudo bash 12-setup-user-systemd-groups.sh`) — a first run silently added `root` (already a no-op, `root` was already in both groups) instead of `user`. Fixed to take the target user as an optional first argument, defaulting to `user` (`bash 12-setup-user-systemd-groups.sh [target-user]`), and re-run correctly as `sudo bash 12-setup-user-systemd-groups.sh user`. **Done (2026-08-20):** confirmed via `id user` — `video`(44)/`render`(110) both present, groups took effect immediately without a fresh login being required beyond the one already in progress. **Also done manually (per explicit decision, deliberately NOT scripted):** `root` removed from both groups (`sudo delgroup root video`, `sudo delgroup root render`) — `/etc/group` now shows `video:x:44:user` / `render:x:110:user`, `user` only.

- [x] Task 2.3.3: Enable lingering (`loginctl enable-linger`) for `user` so `llama-glm-5.2.service` can keep running with no user logged in, WITHOUT autostarting at boot — the actual requirement turned out to be "survive logout", not "autostart now", and those need lingering-on + unit-NOT-enabled together, not lingering alone (see Decisions Made "lingering + no autostart" for the full incident where this was caught and corrected live on the box) — depends on: none — status: done — 2026-08-20: `bin/13-enable-user-lingering.sh` created (idempotent, no sudo needed — verified `loginctl enable-linger` succeeds for `user` without a password prompt on this box) and run: `Linger=yes` confirmed via `loginctl show-user user -p Linger`. **Incident found and fixed in the same check:** `bin/09-install-llama-glm-service.sh` had already been run once (separately) and had `enable`d the unit — with lingering now on, that combination would have auto-started it at the next boot. Caught immediately (`systemctl --user status llama-glm-5.2` showed `enabled`), fixed via `systemctl --user disable llama-glm-5.2` (confirmed `disabled`/`inactive`), and `bin/09` itself rewritten to never call `enable` (it now also defensively re-disables the unit if it finds it enabled from a prior run, so re-running the installer can't silently reintroduce this).

- [x] Task 2.4: `systemctl --user start` the service (no sudo); curl smoke test against `/v1/chat/completions`, verify tool-calls and all 3 reasoning modes (reasoning_effort max/high, enable_thinking:false). If engine is llama.cpp, explicitly verify OpenAI-compatible tool-calling works for OpenCode (REQ-011 risk) — depends on: Task 2.3, Task 2.3.2, Task 2.3.3 — status: done — 2026-08-20 11:58:20 CEST: `systemctl --user start llama-glm-5.2.service` issued by user. Cold load completed successfully at `12:31:12` (~33 min, matching Task 2.2.1's estimate); confirmed via `systemctl --user status` (`active (running)`), `journalctl` (`model loaded`, `listening on http://0.0.0.0:8092`), `curl http://localhost:8092/health` (`200 {"status":"ok"}`), and `/v1/models` (`glm-5.2:UD-Q5_K_XL`, `n_ctx: 768000`). **`bin/14-smoke-test-glm-service.sh` run 2026-08-20 12:50-12:52 CEST against the live service — ALL 4 CASES PASSED, `OVERALL: no degenerate/suspicious/failed results found`:**

  - `enable_thinking:false`: `finish_reason: stop`, content `"Paris"` (factually correct), 2 completion tokens, ~12.0 tok/s
  - `reasoning_effort:high`: `finish_reason: stop` (NOT truncated), a correct recursive `fibonacci()` plus a note on its exponential complexity and a memoized alternative, 477 completion tokens, ~12.9 tok/s, non-empty `reasoning_content`
  - `reasoning_effort:max`: `finish_reason: stop` (NOT truncated — earlier ACC-002 attempt at 600 tokens WAS truncated; 4000-token budget here let it finish), a correct recursive `fibonacci()` plus memoized variant, 694 completion tokens, ~12.9 tok/s, non-empty `reasoning_content`
  - Tool-calling (REQ-011 risk): `finish_reason: tool_calls`, well-formed `message.tool_calls[0].function` = `{"name":"get_weather","arguments":"{\"location\":\"Paris\"}"}`, valid JSON args with the expected key — llama.cpp's tool-calling did NOT show the historically-weaker failure mode (no plain-text imitation in `content`, which was empty as expected for a pure tool-call turn)

  No degenerate/frozen-token signature in any case. Results:
  `bin/logs/2026-08-20T105048Z-smoke-test-glm-service/{nothink,reasoning_high,reasoning_max,toolcall}.json`. **REQ-004 (all 3 reasoning modes) and the curl half of REQ-011/ACC-004 (tool-calling) both confirmed via curl.** ACC-004's remaining half (a real OpenCode agentic session) is deferred to Task 2.6/2.7 once OpenCode is wired up — see ACC-004.

- [ ] Task 2.5: Validate the finalized production context size (**768K**, decided in Task 2.3 — see Track A result; comfortably exceeds REQ-003's 350-370K minimum bar by 2x+. 896K remains a flagged revisit candidate pending the tensor-split rebalancing, see Decisions Made, but is not the current target) works without OOM — depends on: Task 2.4 — status: not-started

- [x] Task 2.5.1: Measure actual generation throughput (tokens/min in and tokens/min out, or tok/s) for `UD-Q5_K_XL` in the production config (`--n-cpu-moe 54 --tensor-split 54,9,8,8`), at the finalized production context size — Task 2.1/2.2 were model-load/VRAM-allocation probes only, not decode-speed benchmarks; the only speed figure on record (~39 tok/s, Task 1.2) is for the much lighter `UD-IQ1_S` spike quant and is not representative, since `UD-Q5_K_XL` streams the majority of MoE expert weight from CPU RAM per decode step (`--n-cpu-moe 54`), which is structurally slower. Runs against the already-installed service, which already has Task 2.2.1's winning `--load-mode` baked in — no second cold-load-mode comparison needed here — depends on: Task 2.5 — status: not-started — **2026-08-20: prep work done ahead of time**, prompted by a user report that decode felt slow in real use. A live spot-check during this session (`nvidia-smi dmon -s ut`) found GPU0 (the PCIe 5.0 x16 bus, see Task 2.3/3.3's topology finding) sustaining **~46-60 GB/s PCIe RX at 100% SM utilization** during real generation traffic, while GPUs 1-3 sat idle — a strong signal decode may be PCIe-transfer-bound in this `--n-cpu-moe` hybrid config (the CPU-offloaded MoE-expert weight rows being re-streamed to GPU every decode step), not purely compute-bound. Three scripts created (executable, **not yet run**): `bin/15-measure-pcie-vs-throughput.sh` (generic — correlates per-GPU PCIe RX/TX + SM% with measured `tok/s` against any already-running endpoint; doubles as this task's actual measurement tool), `bin/17-tune-q4-placement.sh` (see below — finds a Q4-specific `--n-cpu-moe`/`--tensor-split` placement rather than blindly reusing Q5's, run BEFORE `bin/16`), and `bin/16-benchmark-q4-vs-q5.sh` (orchestrates a full A/B: benchmarks the live Q5 production service via `bin/15` first — satisfying this task — then stops it, cold-loads `UD-Q4_K_XL` ad-hoc on port 8093 with a placement now parameterized via `NCMOE`/`TENSOR_SPLIT` env vars — defaulting to Q5's `54,9,8,8` but meant to be overridden with `bin/17`'s winning candidate — benchmarks it via `bin/15`, and restarts production Q5 via a `trap`-guarded cleanup that always runs regardless of how the script exits). Also see the theoretical Q4-vs-Q5 speedup estimate under Current Status/session notes (~15-30%, derived from the ~17% smaller Q4 file size and the PCIe-bound hypothesis) — a rough estimate only, to be replaced by `bin/16`'s actual measurement.

- **2026-08-20 (later): Q4-specific placement tuning added, prompted by a
  user question — "shouldn't Q4 get its own block-placement tuning,
  like Q5 did?".** Correct catch: blindly reusing Q5's `54,9,8,8` for Q4
  is SAFE (every Q4 tensor is \<= its Q5 counterpart) but leaves headroom
  unused. Measured directly from GGUF tensor metadata (not estimated):
  Q4's average MoE-expert-block size is **5.468 GiB vs Q5's 6.635 GiB
  (~82.4% of Q5's size)**, both over the same 76 MoE blocks
  (`block_count=79`, `leading_dense_block_count=3`, confirmed via
  `gguf-dump`). Reusing Q5's split unchanged would free ~28 GiB combined
  headroom across GPU1-3 (not needed for safety at 768K — Q5 already
  clears its margin comfortably there — so it's available to push MORE
  blocks off CPU-offload onto GPU-resident, which would compound with
  Q4's bit-width win under the PCIe-bound hypothesis). Confirmed via
  `llama-server --help`: `--n-cpu-moe N` keeps the MoE weights of the
  FIRST N layers on CPU (not last N). Also discovered a key efficiency
  fact: llama.cpp's own startup fit-check
  (`common_params_fit_impl`/`common_fit_params`, confirmed in existing
  logs: "fitting params to free memory took 0.60 seconds") completes in
  **under a second**, right after reading GGUF metadata — WAY before the
  30-45 min tensor-copy phase. This means candidate placements can be
  tested in seconds each (start, capture the early diagnostic, kill
  before the expensive load), not one full cold-load per candidate.
  `bin/17-tune-q4-placement.sh` created to exploit this: stops
  production, tries 3 candidates (`54,9,8,8` baseline reuse plus two
  progressively more aggressive rebalances, `50,11,9,9` and `46,13,10,10`)
  each killed right after its fit-check, prints a comparison table
  against Q5's known 768K reference, and restarts production via the
  same `trap`-guarded cleanup pattern as `bin/16`. **Not yet run.**
  `bin/16` updated to take `NCMOE`/`TENSOR_SPLIT` as overridable env vars
  (still defaulting to Q5's values) so the winning candidate from
  `bin/17` can feed directly into a fair "best Q4 config vs best Q5
  config" throughput comparison. Recommended order:
  `bin/17-tune-q4-placement.sh` → pick a winner → re-run `bin/16` with
  `NCMOE=... TENSOR_SPLIT=... bash bin/16-benchmark-q4-vs-q5.sh`.

- **2026-08-22: `bin/23-tune-q4-placement-v2.sh` finally produced valid
  placement data, after TWO independent bugs were found and fixed (see
  Recent Updates for the full incident writeup of both).** Bug #1
  (stdbuf/SIGKILL buffering) was fixed first but insufficient on its own —
  3 more clean runs still produced only 60s-timeout/inconclusive results
  (all 3 candidate logs truncated at an identical 3445 bytes/35 lines,
  never reaching the fit-check line). Bug #2, found by comparing against
  `bin/07-measure-kv-cache-768-896.sh` (which DID capture this line for
  Task 2.1/2.2/3.4): the target line
  (`common_fit_params: successfully fit params to free device memory`) is
  INFO-level and is silently suppressed at the default log verbosity 3 —
  `bin/07`/`bin/18` always passed `-lv 4`, but `bin/17`/`bin/23` never
  did. Added `-lv 4` to `bin/23`; re-run immediately succeeded, all 3
  candidates reaching a real fit-check result in ~2s each (not 60s
  timeouts):

  | candidate | n-cpu-moe / split | worst GPU | worst free % | vs. ≥15%/≥10 GiB policy |
  |---|---|---|---|---|
  | baseline-reuse-q5 | 54 / `54,9,8,8` | CUDA0 | 25.3% | passes comfortably — best of the 3 |
  | candidate-A-modest | 50 / `50,11,9,9` | CUDA1 | 20.7% | passes, worse than baseline |
  | candidate-B-aggressive | 46 / `46,13,10,10` | CUDA1 | 6.8% (6,663 MiB) | **fails both legs** |

  **Finding: the rebalancing hypothesis was wrong, not just unproven.**
  Shifting blocks off CPU-offload (lower `--n-cpu-moe`) does free headroom
  on CUDA0/2/3, but the paired `--tensor-split` rebalance concentrates
  that shifted static weight onto CUDA1 specifically (already the
  heaviest-static-weight GPU per Task 2.2's original per-GPU analysis:
  62,690 MiB baseline → 63,685 MiB (A) → 75,264 MiB (B)), so CUDA1's free
  margin collapses (33,400 → 20,125 → 6,663 MiB) faster than the other
  GPUs improve. **Decision: keep `54,9,8,8` for Q4** — not merely "safe
  by reuse" as originally assumed, but the actual best-margin option of
  the 3 tested. No further, more-aggressive rebalance candidates are
  worth trying in this direction. This also means `bin/24-benchmark-q4-vs-q5-v2.sh`
  needs no `Q4_NCMOE`/`Q4_TENSOR_SPLIT` override — its default (reusing
  Q5's `54,9,8,8`) already is the winning Q4 config, so Task 2.5.1's
  throughput A/B can run as-is once Q4 (stopped/restarted by this sweep,
  cold-loading again as of this finding) finishes reloading. Full logs:
  `bin/logs/2026-08-22T144828Z-tune-q4-placement-v2/`.

- **2026-08-22 (later): Task 2.5.1 DONE — real throughput A/B run via
  `bin/24-benchmark-q4-vs-q5-v2.sh`, launched detached in the background
  once Q4 was healthy again (per this repo's own long-running-job
  guidance — monitored via a background task, not polled tick-by-tick in
  the main session).** No `Q4_NCMOE`/`Q4_TENSOR_SPLIT` override needed —
  the script's default (`54,9,8,8`) was already confirmed as the winning
  Q4 config by the placement-tuning sweep above. Ran clean end-to-end,
  ~1h for the two benchmark phases (Phase A: Q4 live, already
  loaded/healthy; Phase B: Q5 ad-hoc cold-load ~20 min), plus a further
  ~32 min for the trap-guarded cleanup to restart and cold-load Q4 back
  to production — confirmed healthy afterward
  (`systemctl --user status llama-glm-5.2-q4.service` = `active (running)`,
  `/health` = `{"status":"ok"}`). **Result:**

  | quant | context | tok/s | completion tokens | finish_reason |
  |---|---|---|---|---|
  | **Q4** (`UD-Q4_K_XL`, live production) | 768000 | **14.26** | 912 | stop |
  | **Q5** (`UD-Q5_K_XL`, ad-hoc, same `54,9,8,8` placement) | 768000 | **12.65** | 845 | stop |

  **Q5 is 11.3% slower than Q4** in this single-request A/B — directionally
  consistent with (though smaller than) the session's own theoretical
  15-30% estimate derived from the PCIe-bound hypothesis and Q4's smaller
  per-block footprint (Task 2.5.1's earlier prep notes, and the smoke-test
  spot-check in Task 3.4 which found +11.5%/+13.1% on two prompts) — this
  full A/B (longer completions, dedicated single-purpose run via
  `bin/15-measure-pcie-vs-throughput.sh`, not a smoke-test side-effect)
  lands right in the same ballpark (~11-13%), reinforcing that figure
  rather than the higher end of the original 15-30% estimate range. No
  errors; only expected/benign "unused tensor blk.78.\*" warnings during
  both cold-loads and one non-fatal PCIe-sampling granularity miss in
  `bin/15`'s dmon window (noted in-log, not a failure). **REQ-005's
  "maximize quality, speed secondary" framing is satisfied either way**
  (Q5 stays the primary/production quant per Task 2.2/ACC-005's
  near-lossless rationale; Q4's measurable-but-modest speed edge is
  informational for the swap-when-wanted side-by-side design from Task
  3.4, not grounds to change the default). Full logs:
  `bin/logs/2026-08-22T145303Z-q4-vs-q5-benchmark-v2/` (per-phase
  `bin/15` outputs: `response.json`, `dmon.log`, ad-hoc server log).
  **Phase 2 is now fully clear to move to Task 2.6** (OpenWebUI/OpenCode
  wiring); Task 3.3's rebalancing revisit (gated on this throughput
  baseline landing) can also now be picked up if wanted, though Task
  2.5.1's own placement-tuning sweep (see above) already found no better
  split than the current `54,9,8,8` for Q4 specifically.

- [ ] Task 2.6: Connect OpenWebUI and OpenCode to the GLM-5.2 endpoint as a separate model entry — depends on: Task 2.5 — status: not-started — OpenCode side drafted ahead of time (2026-08-20): `opencode-provider-snippet-glm-5.2.jsonc` (feature folder root) holds a `provider.llama-cpp-sys0` entry using `@ai-sdk/openai-compatible`, `baseURL: http://<sys0-LAN-IP>:8092/v1`, model key `glm-5.2:UD-Q5_K_XL` with `limit.context: 768000` (matching Task 2.3's decided production context size) — mirrors the box's existing `ollama-sys0` provider entry in shape. Deliberately NOT written into any actual `opencode.jsonc` on this box (that file belongs to a different system) — it's a standalone paste-able fragment for the user to merge into their own config's `provider` object once Task 2.4 confirms the endpoint is actually up. Motivated the `--alias glm-5.2:UD-Q5_K_XL` addition to `bin/08-llama-glm-5.2.service` (see its header comment) so the model id OpenCode/OpenWebUI would show isn't the raw GGUF file path. See Task 3.2 (Phase 3) for the still-open question of driving `--chat-template-kwargs` reasoning-mode toggles from OpenCode itself.

- [ ] Task 2.7: User runs the SAME coding-task examples from feat-1 (Task 1.7 / ACC-010) against this endpoint for a direct quality comparison — depends on: Task 2.6 — status: not-started

#### Phase 3: Optimisations (nice-to-have, non-blocking on Phase 2)

- [ ] Task 3.1: Evaluate/resize the `/swapfile` swap device. Discovered while actually running Task 2.3.1's `bin/10-tune-vm-swappiness.sh` on the box (2026-08-20): the swap device is only **2 GiB total, already ~1.8 GiB (~90%) used** — much smaller than assumed when the swap-policy decision was made. This meaningfully changes that decision's premise: at 2 GiB against a 512 GiB RAM pool, swap cannot absorb anything close to the multi-hundred-GB-scale anonymous-memory incidents already seen in Task 2.1 (Incident #1 alone consumed ~1.4 GiB of this same 2 GiB device in well under a minute — ~70% of its entire capacity from one transient event). At this size swap functions as an early trip-wire signal, not a real capacity cushion — `vm.swappiness=1` (Task 2.3.1) still correctly reduces *proactive* swapping, but does not fix the fact that any genuine pressure event would exhaust this device almost immediately and fall through to the OOM-killer anyway, safety-net or not. Decide whether to enlarge the swapfile (and to what size) to make it a meaningful buffer, or explicitly accept it as trip-wire-only and document that — depends on: Task 2.3.1 — status: not-started

- [ ] Task 3.2: Work out how to drive GLM-5.2's `--chat-template-kwargs` reasoning-mode toggles (`reasoning_effort: max`/`high`, or `enable_thinking: false` — REQ-004) from an OpenCode client session, not just from raw curl smoke tests. Surfaced while drafting the OpenCode `opencode.jsonc` provider snippet for this endpoint (`@ai-sdk/openai-compatible`, pointed at `http://<sys0-host>:8092/v1`): OpenCode's documented config schema for a custom OpenAI-compatible provider (`provider.<id>.models.<id>.{name,limit.context,limit.output}`) has no obvious per-model or per-request hook for injecting arbitrary extra body fields like `chat_template_kwargs` into the request OpenCode sends. Options to evaluate: (a) an OpenCode plugin that injects the field (similar in spirit to `opencode-helicone-session`'s header injection, but for a body field instead of a header); (b) exposing each reasoning mode as a SEPARATE model entry in `opencode.jsonc` pointed at the SAME `baseURL`/model, if the AI SDK's `providerOptions`/`options` surface turns out to support a static extra-body passthrough per model entry (needs verification against the actual `@ai-sdk/openai-compatible` package, not just the opencode.jsonc doc examples seen so far); (c) worst case, accept that OpenCode sessions run GLM-5.2 in its default mode only (`reasoning_effort: max` per unsloth's defaults) and reserve explicit low/no-thinking-mode testing for direct curl/API smoke tests outside OpenCode (Task 2.4/ACC-004 already covers that path). Not a blocker for Task 2.4/ACC-004 (which verifies the modes via curl, per REQ-004's own wording), but does affect how usable the reasoning-mode flexibility actually is day-to-day once OpenCode is wired up (Task 2.6) — depends on: Task 2.6 — status: not-started

- [ ] Task 3.3: Revisit the `--tensor-split`/`--n-cpu-moe` split to see whether 896K context can be reclaimed, informed by the box's PCIe topology (`nvidia-smi --query-gpu=index,pcie.link.gen.max`: GPU0/GPU2 are PCIe 5.0 x16, GPU1/GPU3 are PCIe 4.0 x16). **Moved here from being an embedded Task 2.3 gating item (2026-08-20)** — it never actually blocked shipping at 768K (which already clears the safety-margin policy on every GPU and exceeds REQ-003's 350-370K target by 2x+); it only matters for the 896K stretch goal, which is explicitly "flagged as a revisit candidate, not discarded" rather than required. Context for the revisit: at ctx=896,000 under the current validated split (`--n-cpu-moe 54 --tensor-split 54,9,8,8`), CUDA0 is the binding constraint (14,079 MiB / 14.5% free, ~514 MiB short of the 15% leg) despite holding the *smallest* static model weight of the four GPUs (19,485 MiB) — it appears the layers assigned to CUDA0 by the tensor-split ratio (54/79 ≈ 68%) are the same ones `--n-cpu-moe 54` offloads experts from, so CUDA0 ends up "hollowed out" of static weight but loaded with a proportional (71%) share of the KV-cache instead, which is what makes it tight as context grows. **A real risk, not just an optimization detail:** CUDA0 also happens to sit on the fast PCIe 5.0 bus, which is currently a good pairing (CPU-offloaded experts stream across PCIe every decode step, and that traffic is landing on the faster bus) — shrinking CUDA0's tensor-split ratio to relieve KV-cache pressure could inadvertently shift that expert-streaming traffic onto a Gen4 GPU instead, regressing decode throughput to gain KV-cache margin. **Do not attempt this rebalancing before Task 2.5.1 (decode tok/s baseline) has run** — without a throughput baseline first, a rebalance's downside (slower decode) would be invisible until after the fact. If pursued: re-validate both KV-cache margin (`bin/07-measure-kv-cache-768-896.sh`-style, at ctx=896000) AND decode throughput (Task 2.5.1-style) for any candidate split, not just the former — depends on: Task 2.5.1 — status: not-started

- [x] Task 3.4: Install `UD-Q4_K_XL` as a side-by-side, independently
  swappable systemd service (user request, 2026-08-20/2026-08-22) —
  depends on: none — status: done. **Investigated and found a hard
  capacity ceiling first**: `UD-Q4_K_XL` (~467 GB) + `UD-Q5_K_XL` (~562
  GB) combined (~1029 GB) exceed this box's 896 GB total pool (384 GB
  VRAM + 512 GB RAM) by ~133 GB, confirmed against live numbers (only
  ~116 GiB combined GPU free / ~131 GiB RAM "available" while Q5 alone
  ran) — true concurrent residency of both quants is impossible
  regardless of placement, a raw capacity limit, not a tuning problem.
  **Decided (user): install both as separate, independently
  start/stoppable systemd `--user` services, swapped (never run
  together).** `bin/19-llama-glm-5.2-q4.service` (port 8093, distinct
  `--alias glm-5.2:UD-Q4_K_XL`, otherwise identical
  `--n-cpu-moe 54 --tensor-split 54,9,8,8 --ctx-size 768000 --load-mode none` placement to Q5 — deliberately reused unchanged rather than
  re-optimized, since every Q4 tensor is ≤ its Q5 counterpart so a split
  validated for Q5 is guaranteed safe for Q4) and
  `bin/20-install-llama-glm-q4-service.sh` (mirrors `bin/09`: copy +
  daemon-reload, NOT enable, NOT start) created and run — confirmed
  installed (`loaded; disabled; inactive`) side-by-side with Q5, which
  stayed running throughout the install untouched.
  **`bin/18-tune-q4-kv-cache-768-896.sh`** (Q4 equivalent of `bin/07`:
  same real-load methodology, same 768K/896K sizes, same reused
  placement) validated the config on a clean GPU set — briefly stopped
  Q5 for this one measurement (explicitly approved), tested both sizes,
  restarted Q5 afterward via a `trap`-guarded cleanup. **Both sizes
  measured `status=ok`, clearing the ≥15%/≥10 GiB safety-margin policy
  on every GPU at BOTH context sizes** (authoritative
  `common_params_fit_impl` figures):

  | ctx | CUDA0 free | CUDA1 free | CUDA2 free | CUDA3 free |
  |---|---|---|---|---|
  | 768,000 | 24,630 MiB (25.3%) | 33,400 MiB (34.3%) | 40,033 MiB (41.2%) | 51,315 MiB (52.8%) |
  | 896,000 | 16,146 MiB (16.6%) | 31,572 MiB (32.5%) | 38,345 MiB (39.4%) | 49,940 MiB (51.3%) |

  **Notable secondary finding**: unlike Q5 (which narrowly missed 896K's
  15% leg at 14.47% on CUDA0), **Q4 clears 896K comfortably** (CUDA0
  16.6% > 15%) at this same split — Q4's smaller per-block footprint
  (measured ~5.468 GiB/MoE block vs Q5's ~6.635 GiB, ~82.4%, from actual
  GGUF tensor metadata) gives it enough extra headroom to reach the 896K
  stretch goal that Q5 couldn't safely reach without Task 3.3's
  rebalancing. Not yet acted on (the installed `bin/19` unit still
  ships at 768000, matching Q5, for a fair baseline) — worth revisiting
  if 896K context specifically is wanted for the Q4 slot. Full logs:
  `bin/logs/2026-08-20T120959Z-q4-kv-cache-768-896.{txt,json}` and
  per-context `*-q4-kv-ctx768000.log`/`*-q4-kv-ctx896000.log`.
  **Confirmed working end-to-end**: after this feature's own session
  ended and the box was power-cycled (per its normal daily routine), the
  user exercised the actual swap workflow live — cleanly stopped Q5,
  started `llama-glm-5.2-q4.service` — confirming the side-by-side
  design works as intended outside of any assistant-driven script.
  **`bin/14-smoke-test-glm-service.sh` (Task 2.4's smoke test) generalized
  to reuse against Q4**: `SERVICE_UNIT`/`HOST`/`PORT`/`MODEL` are now
  overridable env vars (previously hardcoded to Q5's values). `bin/21-smoke-test-glm-q4-service.sh` added as a thin wrapper (no new
  logic, just sets those env vars and `exec`s `bin/14`) — run
  `bash bin/21-smoke-test-glm-q4-service.sh` once Q4's `/health` (port
  8093\) returns 200.

  **`bin/21` run 2026-08-22 11:18-11:20 CEST against the live Q4 service
  (cold-loaded via the user's own swap of Q5→Q4 above) — ALL 4 CASES
  PASSED**, same as Q5's original Task 2.4 run: `nothink.json`
  (`enable_thinking:false`) returns `"Paris"`, `finish_reason:"stop"`, no
  `reasoning_content` (correct); `reasoning_high.json` (549 tokens) and
  `reasoning_max.json` (798 tokens) both return coherent, correct,
  non-truncated Fibonacci implementations with non-empty
  `reasoning_content`; `toolcall.json` returns a well-formed
  `tool_calls[0].function` block (`get_weather`,
  `{"location":"Paris"}`) — no degenerate/repeated-token output in any
  case. **Decode throughput comparison** (same prompts/config as Q5's
  2026-08-20 `bin/14` run, `predicted_per_second` from each response's
  own `timings`, larger-sample cases only since `nothink`/`toolcall`
  generate too few tokens — 2/11 — to be meaningful):

  | case | Q5 tok/s | Q4 tok/s | Q4/Q5 |
  |---|---|---|---|
  | reasoning_high | 12.91 | 14.40 | +11.5% |
  | reasoning_max | 12.88 | 14.57 | +13.1% |

  Q4 decodes ~12-13% faster than Q5 in this single-request smoke test —
  directionally consistent with Q4's smaller per-block footprint
  (~82.4% of Q5's size) reducing the PCIe-transfer-bound cost identified
  earlier (Task 2.5.1/PCIe RX saturation finding), though this is one
  sample per case, not a rigorous throughput benchmark (that's
  `bin/15-measure-pcie-vs-throughput.sh`/`bin/16-benchmark-q4-vs-q5.sh`,
  not yet run against the installed Q4 service specifically). Directly
  relevant to the original complaint that motivated this whole
  side-by-side effort ("Q5 decode feels slow") — Q4 is measurably
  faster here, not just theoretically smaller. Full responses:
  `bin/logs/2026-08-22T091818Z-smoke-test-glm-service/*.json`.

**Note:** If a task's scope changes mid-flight, edit its description in place;
rely on git history (`git log -p` on this file) to recover what was
originally planned, rather than keeping a second copy of the task around.

## Progress

### Current Status

**As of 2026-08-22 (latest): Task 2.5.1 (decode throughput) is DONE; Q4's
own placement-tuning sweep is DONE (kept `54,9,8,8`).** Two independent
bugs in `bin/23-tune-q4-placement-v2.sh` were found and fixed this
session (stdout buffering, then a missing `-lv 4` verbosity flag
suppressing the INFO-level fit-check line) before it could produce any
valid data — see Task 2.5.1 and Recent Updates for the full incident.
Once fixed, all 3 placement candidates resolved in ~2s each: baseline
`54,9,8,8` (25.3% worst-GPU margin) beat both rebalanced alternatives
(20.7% and a failing 6.8%) — the "shift more onto GPU" hypothesis that
motivated the sweep was wrong, not just untested. `bin/24-benchmark-q4-vs-q5-v2.sh`
then ran clean (background-monitored, not polled tick-by-tick): **Q4
14.26 tok/s vs Q5 12.65 tok/s (Q5 11.3% slower)** at the same `54,9,8,8`/768K
config — consistent with, though smaller than, the session's earlier
15-30% theoretical estimate. Q4 was successfully restored to production
afterward (`/health` = `{"status":"ok"}`). **Task 2.5 (a genuine
filled-context/large-prompt 768K generation run) is still NOT done** —
`bin/24`'s benchmark used only a short one-sentence coding prompt against
a server configured at `--ctx-size 768000`, which validates the KV-cache
allocation and short-prompt decode but does not exercise a real
350-370K+-token prompt; that remains open, next up before Task 2.6.

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
sizes after two unsafe-MoE-placement incidents were fixed (`--n-cpu-moe 54 --tensor-split 54,9,8,8`, see Decisions Made). Result: ~186-239 GiB total
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
  (systemd unit, `--ctx-size 768000`/768K — updated from the original
  524288/512K placeholder now that Track A's data has settled the
  context-size decision (see below) — and the validated
  `--n-cpu-moe 54 --tensor-split 54,9,8,8`, port 8092 to avoid colliding
  with the ad-hoc measurement-script port 8091 or feat-1's vLLM port
  8000\) and `bin/09-install-llama-glm-service.sh` (installer: copy +
  `daemon-reload` + `enable`, deliberately NOT `start`). Both follow the
  `User=user`/`--host 0.0.0.0`/`Restart=on-failure`/etc. conventions of
  feat-1's already-installed (currently inactive) `vllm-deepseek-v4-flash.service`
  on this same box. **Not installed yet** — pending the `--tensor-split`
  rebalancing discussion and Task 2.2.1's `--load-mode` result.
- **New info feeding that rebalancing discussion:** `nvidia-smi --query-gpu=index,pcie.link.gen.max` confirms **GPU0/GPU2 are PCIe 5.0
  x16, GPU1/GPU3 are PCIe 4.0 x16**. CUDA0 (the GPU with the steepest
  KV-cache-growth slope under the current split, and thus the binding
  constraint at high context) happens to already sit on the faster bus;
  CUDA1 (heaviest static MoE weight) sits on a slower one. Whether/how to
  use that asymmetry when rebalancing is the next discussion, once Track
  A's data is in.

**DECISION (2026-08-20): production context size = 768K.** Track A's data
is now in (see Task 2.3 for the full per-GPU tables): 768K clears the
≥15%/≥10 GiB safety-margin policy on every GPU (worst case CUDA0, 23.2%
free); 896K's worst GPU (CUDA0) narrowly misses the 15% leg (14.47% free
vs. a 15% requirement, a ~514 MiB shortfall) though it clears the flat
≥10 GiB leg. `bin/08-llama-glm-5.2.service`'s `--ctx-size` has been
updated from the 512K placeholder to **768000**. **896K is flagged as a
revisit candidate, not discarded** — a possible `--tensor-split`
rebalancing (CUDA0 sits on the faster PCIe 5.0 bus but currently also
carries the largest KV-cache share) could plausibly close that gap; see
Decisions Made for the full rationale. **DECIDED: not rebalancing before
install** — moved to Phase 3 as Task 3.3, gated on a decode-throughput
baseline first (Task 2.5.1). **Track B is now fully done** — both its
items (768K/896K probe, `--load-mode` result) have landed and nothing
further blocks Task 2.3's install.

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
created (compares `mmap` default vs. `--load-mode none` at `--ctx-size 896000`, fixed per instruction). **First attempt (2026-08-20) was killed
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
finished (resume later with `echo check | sudo tee /sys/block/md126/md/sync_action`, or it may auto-resume via the next
`mdcheck_continue.timer` fire — do not forget it was paused for this
reason).

**UPDATE (same day, ~10:30 CEST) — a "very slow progress" report on the
restart was investigated and explained; not a new problem.** The manual
pause above did NOT survive the system stop/start in between sessions:
`mdcheck_continue.timer` re-fired a fresh continuation scrub
(`05:14:02Z`–`09:42:05Z`, confirmed via `journalctl`), which really was
slow to compete with. Three quick `bin/11` restarts during/just after
that window (`09:23`, `09:40`, `10:12`) were each killed within seconds,
before `llama.cpp`'s silent (no log output) tensor-copy phase ever got
going — not the loader hanging, just impatience meeting a loader that
gives zero progress feedback for the multi-hundred-GB copy. The 4th
attempt (`10:18:24Z`) is confirmed healthy: RAID scrub done
(`sync_action: idle`, `mismatch_cnt: 0`), clean GPU baseline, sustained
**~289 MB/s** disk read (two independent `/proc/<pid>/io` samples), ~33%
through the 524 GiB file at check time, `/health` correctly `503 Loading model`. **Action: let it finish uninterrupted** (ETA ~20 more min at
check time); judge progress via `/proc/<pid>/io` `read_bytes` or
`/health`, not GPU-memory/log appearance. Full writeup in Recent Updates
and Blockers.

**UPDATE (same day) — Task 2.2.1 is DONE, result decided.** The 4th
attempt (`10:18:24Z`) completed both probes cleanly:
`bin/logs/2026-08-20T081824Z-load-mode-bench.{txt,json}` show
`--load-mode none` at 1694s (~28.2m) vs. `mmap-default` at 1842s
(~30.7m) — **8% faster**. Per-GPU `common_memory_breakdown_print`
identical between the two runs, as expected. **DECIDED: adopt
`--load-mode none`** — already added to `bin/08-llama-glm-5.2.service`'s
`ExecStart`. The RAID10 consistency check that caused the earlier
restarts is confirmed fully finished, not just paused (`sync_action: idle`, `mismatch_cnt: 0`) — nothing left to resume. One caveat
carried into the decision, not hidden: the script doesn't drop the page
cache between probes and `mmap-default` ran first, so part of the 8%
gap could reflect cache warmth on the second probe rather than a purely
structural effect; judged not worth a further ~1h re-test given the
modest, directionally-expected result. Track B's remaining open item is
now only the `--tensor-split`/`--n-cpu-moe` rebalancing discussion (see
above) — once that lands, `bin/09-install-llama-glm-service.sh` can run.

**Task 2.4 is now DONE — service started, cold-loaded, and smoke-tested
successfully.** `llama-glm-5.2.service` was started `11:58:20 CEST`,
finished cold-loading at `12:31:12` (~33 min), and
`bin/14-smoke-test-glm-service.sh` (run `12:50-12:52 CEST` against the
live service) passed all 4 cases: all 3 reasoning modes
(`enable_thinking:false`, `reasoning_effort:high`/`max`) produced
coherent, non-truncated, non-degenerate output, and the tool-calling case
returned a well-formed `tool_calls[].function` block — REQ-011's
llama.cpp tool-calling risk did not materialize. REQ-004 and the curl half
of REQ-011/ACC-004 are confirmed; ACC-004's remaining half (a real
OpenCode agentic session) awaits Task 2.6. Phase 2 now moves to Task 2.5
(768K end-to-end OOM validation) and Task 2.5.1 (decode throughput
benchmark).

**User-reported: decode feels slow in real use; investigated, not yet
resolved.** Prompted a live PCIe spot-check (`nvidia-smi dmon -s ut`)
during real generation traffic against production: **GPU0 sustained
~46-60 GB/s PCIe RX at 100% SM utilization** while GPUs 1-3 sat idle —
GPU0 is the GPU on the PCIe 5.0 x16 bus (Task 2.3/3.3's topology finding),
and that RX rate is close to the bus's practical ceiling. This is a
strong (not yet fully isolated/proven) signal that decode in this
`--n-cpu-moe 54` hybrid config is at least partly **PCIe-transfer-bound**
— every decode step re-streams the routed MoE-expert weight rows for the
54 CPU-offloaded layers from CPU RAM to GPU0. **Theoretical estimate for
`UD-Q4_K_XL` vs `UD-Q5_K_XL`:** Q4 is ~467 GB vs Q5's ~562 GB (~17%
smaller, ~5.0 vs ~6.05 bits/weight average); if decode is genuinely
PCIe-bound, expect roughly **15-30% higher tok/s at Q4** (Q5's
smoke-test figures were ~12.0-12.9 tok/s → very roughly ~14-17 tok/s
estimated for Q4) — plausibly toward the higher end since Dynamic/XL
quant schemes typically cut MoE-expert bit-depth more aggressively than
attention/embedding layers, and the CPU-offloaded/streamed data is
specifically MoE-expert weight. **This is an estimate, not a
measurement** — `UD-Q4_K_XL` finished downloading (100.1%, confirmed via
`bin/04-dl-status.sh`) partway through this session, so a real A/B is now
possible. `bin/15-measure-pcie-vs-throughput.sh` (generic PCIe+throughput
correlator) and `bin/16-benchmark-q4-vs-q5.sh` (full stop-Q5/load-Q4
ad-hoc/benchmark/restart-Q5 orchestration, doubling as Task 2.5.1's
throughput measurement for Q5 along the way) were created this session —
**both prepared but deliberately NOT executed yet** (per instruction;
`bin/16` is disruptive — stops production for roughly one Q4 cold-load +
one Q5 cold-load, likely 1-1.5+ hours). See Task 2.5.1 for the full
detail and Next Steps for how to run it.

**IMPORTANT capacity finding — Q4 and Q5 CANNOT be loaded/running at the
same time on this box.** Investigated in response to a user request to
install Q4 "side-by-side" with Q5: `UD-Q4_K_XL` (~467 GB) + `UD-Q5_K_XL`
(~562 GB) combined (~1029 GB) **exceed this box's total 896 GB pool
(384 GB VRAM + 512 GB RAM) by ~133 GB**, even before either model's
KV-cache/compute buffers — confirmed against live numbers at the time
(only ~116 GiB combined GPU free and ~131 GiB RAM "available" while Q5
alone ran, nowhere near Q4's own ~467 GB weight requirement). This is a
raw capacity ceiling, not a placement/tuning problem — no
`--tensor-split`/`--n-cpu-moe` choice changes how many total bytes a
quant's weights need, only where they live. **Per explicit user decision:
install both as separate systemd services for quick swapping (stop one,
start the other) — never run both loaded at once.**
`bin/19-llama-glm-5.2-q4.service` (port 8093, same `--n-cpu-moe 54 --tensor-split 54,9,8,8 --ctx-size 768000` placement as Q5, since it's
guaranteed safe — every Q4 tensor is ≤ its Q5 counterpart) and
`bin/20-install-llama-glm-q4-service.sh` (mirrors `bin/09`: copy +
daemon-reload, NOT enable, NOT start) were created and **the Q4 service
is now installed** — confirmed side-by-side with Q5, which stayed running
throughout the install untouched.

**`bin/18-tune-q4-kv-cache-768-896.sh` completed successfully (Task
3.4) — both 768K and 896K measured `status=ok`, clearing the
≥15%/≥10 GiB safety-margin policy on every GPU at BOTH sizes:**

| ctx | CUDA0 free | CUDA1 free | CUDA2 free | CUDA3 free |
|---|---|---|---|---|
| 768,000 | 24,630 MiB (25.3%) | 33,400 MiB (34.3%) | 40,033 MiB (41.2%) | 51,315 MiB (52.8%) |
| 896,000 | 16,146 MiB (16.6%) | 31,572 MiB (32.5%) | 38,345 MiB (39.4%) | 49,940 MiB (51.3%) |

Notably, **Q4 clears 896K where Q5 narrowly missed it** (Q5's CUDA0 was
14.47% at 896K; Q4's is 16.6%) — see Task 3.4 for the full detail.

**Live-confirmed end-to-end after this session ended and the box was
power-cycled**: the user exercised the actual swap workflow themselves —
cleanly stopped `llama-glm-5.2.service` (Q5, clean `systemctl stop`, not
a crash — confirmed via `journalctl`) and started
`llama-glm-5.2-q4.service` (Q4), which was mid-cold-load (healthy,
`active (running)`, RSS climbing normally) when this session resumed.
This is exactly the intended "swap, never both at once" usage pattern
working as designed, exercised independently of any assistant action.

### Next Steps

**IMMEDIATE (2026-08-22 update): Task 2.5.1 and Task 2.5.1's own
placement-tuning sweep are both DONE (see Current Status/Recent
Updates) — kept `54,9,8,8` for Q4, measured Q4 14.26 vs Q5 12.65 tok/s.
The only remaining Phase 2 gap before Task 2.6 is Task 2.5 itself: a
real filled-context (350-370K+ token prompt) generation run at the
768K production config, which nothing run so far has actually exercised
(all throughput/tuning runs used short prompts). Do that next, then
proceed to Task 2.6 (OpenWebUI/OpenCode wiring) and Task 2.7 (quality
comparison vs. feat-1).**

**NEW — Q4 vs Q5 investigation, prompted by a user report of slow
decode (highest priority once ready to take the endpoint offline
briefly). Two-step sequence, run in this order:**

1. **`bin/17-tune-q4-placement.sh`** — find Q4's own `--n-cpu-moe`/
   `--tensor-split` placement rather than reusing Q5's unchanged. Fast
   (seconds per candidate, not a full cold load — exploits llama.cpp's
   own sub-second startup fit-check). Stops production briefly, tries 3
   candidates (`54,9,8,8` baseline reuse, `50,11,9,9`, `46,13,10,10`),
   restarts production afterward via a `trap`-guarded cleanup. Review its
   comparison table (per-GPU used/free MiB vs. the printed Q5 768K
   reference) and pick whichever candidate clears the adopted
   ≥15%/≥10 GiB safety margin with the most blocks shifted off
   CPU-offload (lower `--n-cpu-moe`, more PCIe traffic eliminated).
2. **`bin/16-benchmark-q4-vs-q5.sh`**, re-run with the winning candidate:
   `NCMOE=<winner> TENSOR_SPLIT=<winner> bash bin/16-benchmark-q4-vs-q5.sh`
   (defaults to Q5's `54,9,8,8` if step 1 is skipped — still a valid,
   safe comparison, just not necessarily Q4's best case). This stops
   production, cold-loads `UD-Q4_K_XL` ad-hoc on port 8093 with the
   chosen placement, benchmarks both quants via
   `bin/15-measure-pcie-vs-throughput.sh` (Q5 pass first, which also
   satisfies Task 2.5.1), and restarts production Q5 afterward. Expect
   ~1-1.5+ hours offline (two cold loads) for this step, vs. step 1's
   few minutes.

Check `ss -tnp | grep 8092` first to confirm no one else is using the
endpoint before either step — both scripts also warn and pause 10s if
they find a connection. Result: a measured tok/s delta to compare against
this session's ~15-30% theoretical estimate (see Current Status) — likely
higher if step 1 finds a placement with fewer CPU-offloaded blocks than
Q5's. Do not poll either script tick-by-tick once started (same
long-unattended-job guidance as the cold-load waits elsewhere in this
file).

0. **Task 2.4 is now DONE — smoke test PASSED, no further action here.**
   `bin/14-smoke-test-glm-service.sh` ran 2026-08-20 12:50-12:52 CEST
   against the live `llama-glm-5.2.service`: all 3 reasoning modes
   (`enable_thinking:false`, `reasoning_effort:high/max`) produced
   coherent, non-truncated, non-degenerate output, and the tool-calling
   case emitted a well-formed `tool_calls[].function` block (REQ-011 risk
   did not materialize). See Task 2.4 for the full per-case result
   summary and `bin/logs/2026-08-20T105048Z-smoke-test-glm-service/` for
   the raw JSON. **IMMEDIATE — pick this up first in a fresh session: Task
   2.5** (validate the finalized 768K production context works
   end-to-end without OOM — Task 2.1/2.2 were load-only probes, not a
   filled-context generation run) and **Task 2.5.1** (measure actual
   decode throughput for `UD-Q5_K_XL` in the production config — the
   smoke test's ~12-13 tok/s figures are informative but NOT a substitute
   for Task 2.5.1's dedicated benchmark, since the smoke-test prompts were
   short and not run at the production 768K context depth). Then Task 2.6
   (OpenWebUI/OpenCode wiring — this also unblocks ACC-004's remaining
   "real OpenCode agentic session" half) and Task 2.7 (quality comparison
   vs. `feat-1`).

1. **Track A (Task 2.3's 768K/896K probe) is now DONE** — checked
   2026-08-20 ~10:30 CEST: `bin/logs/2026-08-20T055618Z-kv-cache-768-896.txt`
   shows both sizes `status=ok`. Actual per-GPU `common_memory_breakdown_print`
   results (worst case is CUDA0 both times, matching Task 2.3's
   pre-computed projection almost exactly):

   | ctx (tokens) | CUDA0 free (measured) | % free | vs. ≥15%/≥10 GiB policy |
   |---|---|---|---|
   | 768,000 | 22,569 MiB (~22.0 GiB) | 23.2% | passes comfortably |
   | 896,000 | 14,079 MiB (~13.75 GiB) | 14.5% | borderline — just under 15%, still >10 GiB flat |

   This data is now available for the `--tensor-split`/PCIe-rebalancing
   discussion and the 768K-vs-896K production-context decision (both
   still open — this is factual measurement, not the decision itself).

2. **Task 2.2.1 (load-mode benchmark) is DONE.** `bin/11-benchmark-load-mode.sh`'s
   4th attempt (`10:18:24Z`) completed cleanly after the RAID10
   consistency-check contention that killed the first 3 was fully
   resolved: `--load-mode none` measured 8% faster than `mmap-default`
   (1694s vs 1842s). **DECIDED: adopt `--load-mode none`** — already
   added to `bin/08-llama-glm-5.2.service`'s `ExecStart`. Nothing further
   to do here (see Current Status/Decisions Made for the result detail
   and the page-cache-warmth caveat carried into the decision).

3. **The RAID check does not need resuming — it finished on its own.**
   Confirmed `sync_action: idle`, `mismatch_cnt: 0` on `/dev/md126` — the
   earlier "paused, remember to resume" note is now moot; the scrub ran
   to completion via `mdcheck_continue.timer` before the successful
   `bin/11` attempt even started.

4. **Task 2.3 is DONE — installed on the box.** All three gating items
   resolved (`--ctx-size 768000`, `--load-mode none` decided; `--tensor-split`
   rebalancing decided NOT to happen before install, moved to Phase 3 as
   Task 3.3, gated on Task 2.5.1's decode-throughput baseline — see
   Decisions Made for the full rationale). `bin/09-install-llama-glm-service.sh`
   run successfully: `systemctl --user status llama-glm-5.2.service`
   confirms `loaded; disabled; inactive (dead)` — installed file verified
   byte-identical to `bin/08-llama-glm-5.2.service` via `diff`. **Task
   2.3.2 (groups) and Task 2.3.3 (lingering) were already done before
   this**, so nothing further is needed before Task 2.4.

5. **Task 2.4 is DONE** (`systemctl --user start llama-glm-5.2.service` +
   `bin/14-smoke-test-glm-service.sh` both completed 2026-08-20, all 4
   cases passed — see Task 2.4 for the full result). **Next up: Task
   2.5** (validate the finalized 768K production context works end-to-end
   without OOM — a real filled-context generation run, not just the
   load-only probes Task 2.1/2.2 did) **then Task 2.5.1** (measure actual
   tok/min-in/tok/min-out throughput for `UD-Q5_K_XL` in the production
   config — currently unmeasured at production depth; the smoke test's
   ~12-13 tok/s figures were short-prompt/short-context and are not a
   substitute; Task 3.3's rebalancing revisit is gated on this landing).
   Then Task 2.6 (OpenWebUI/OpenCode wiring — also completes ACC-004's
   remaining "real OpenCode agentic session" half) and Task 2.7 (quality
   comparison vs. `feat-1`).

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
  Status): `UD-Q5_K_XL` fits 350-370K context with large headroom
  (~235 GiB vs the 896 GB pool), and Task 2.2's per-GPU analysis confirms
  `UD-Q5_K_XL` as the production quant (worst-case GPU still ~28% free at
  370K). `UD-Q4_K_XL` (fallback) is still downloading in the background
  (60.8% at last check) but is no longer needed for anything in the
  current plan. **Soft dependency (not a hard blocker) — down to ONE open
  item:** Track A's 768K/896K probe and Task 2.2.1's `--load-mode`
  benchmark are both DONE and DECIDED (`--ctx-size 768000`, `--load-mode none` — both already baked into `bin/08-llama-glm-5.2.service`). The
  only thing still gating Task 2.3's actual install
  (`bin/09-install-llama-glm-service.sh`) is the `--tensor-split`/
  `--n-cpu-moe` rebalancing discussion informed by the PCIe-topology
  finding (GPU0/GPU2 = PCIe 5.0 x16, GPU1/GPU3 = PCIe 4.0 x16) — not yet
  held.
- **RAID maintenance loose end — RESOLVED, but not the way expected.**
  The manually-paused `/dev/md126` check from earlier did NOT stay
  paused: the system stop/start (reboot) around the same time let
  `mdcheck_continue.timer` re-fire a fresh continuation run
  (`journalctl -u mdcheck_continue.service`: started 2026-08-20T05:14:02Z,
  finished 2026-08-20T09:42:05Z, "Deactivated successfully"). Confirmed
  now via `/sys/block/md126/md/sync_action` = `idle` and `mismatch_cnt` =
  `0` — the scrub completed cleanly on its own; no manual resume command
  is needed. This 4.5h window DID cause real, measured I/O contention
  (see Task 2.2.1 below) for anything disk-heavy started while it ran —
  now fully clear.

### Recent Updates

#### 2026-08-22 (latest — `bin/23`'s second, independent bug found and fixed; valid Q4 placement-tuning data finally obtained)

- **Context**: the `stdbuf -oL` + graceful-`SIGTERM` fix applied to
  `bin/23-tune-q4-placement-v2.sh` earlier the same day (see entry below)
  addressed a real buffering bug, but a fresh, clean re-run (after
  waiting for Q4's `/health` to return 200, per the prior session
  handoff instruction) still produced only 60s-timeout/inconclusive
  results: all 3 candidate logs across 3 separate attempts
  (`2026-08-22T123612Z`, `T131018Z`, `T140950Z`) were truncated at an
  identical 3445 bytes / 35 lines, always stopping right after the
  "unused tensor blk.78.\*" warnings and never reaching the
  `common_fit_params` line the script greps for — even though cleanup
  worked correctly each time (Q4 was always properly stopped/restarted,
  no crash loop, confirmed via `systemctl`/`journalctl`/`nvidia-smi`).
- **Root cause, found by comparison**: `common_fit_params: successfully
  fit params to free device memory` is an INFO-level log line, and
  `bin/23` (like `bin/17` before it) never passed `-lv N`, so it ran at
  the default verbosity 3, which suppresses that line unconditionally —
  success or not. Confirmed by diffing against
  `bin/07-measure-kv-cache-768-896.sh`, which DID capture this exact
  line for Task 2.1/2.2/3.4's real per-GPU breakdowns and explicitly
  passes `-lv 4`. The only place this message had ever appeared in any
  of this script's own logs was the WARNING-level "abort" variant, in
  `bin/17`'s original pre-fix run (`2026-08-22T121941Z`, launched into a
  GPU already filled by Q4) — warnings print regardless of verbosity,
  unlike the INFO-level success line, which is why that one instance was
  visible even without `-lv 4` while every clean, successful run's INFO
  line stayed invisible. Production's own real loads (same flags, no
  `-lv`) show zero `common_fit_params` lines anywhere across their
  ~30-40 min journals either, consistent with the same suppression, not
  evidence the fit-check doesn't run.
- **Fix**: added `-lv 4` to `bin/23`'s `llama-server` invocation
  (matching `bin/07`/`bin/18`'s already-proven recipe); syntax-checked,
  then re-run for real.
- **Result — first valid Q4 placement-tuning data, all 3 candidates
  reaching a real fit-check result in ~2s each (not a 60s timeout):**

  | candidate | n-cpu-moe / tensor-split | worst GPU | worst free % | vs. ≥15%/≥10 GiB policy |
  |---|---|---|---|---|
  | baseline-reuse-q5 | 54 / `54,9,8,8` | CUDA0 | 25.3% | passes comfortably — best of the 3 |
  | candidate-A-modest | 50 / `50,11,9,9` | CUDA1 | 20.7% | passes, but worse than baseline |
  | candidate-B-aggressive | 46 / `46,13,10,10` | CUDA1 | 6.8% (6,663 MiB) | **fails both legs** |

  The rebalancing hypothesis this whole sweep was built on (shift blocks
  off CPU-offload since Q4's blocks are smaller than Q5's, freeing
  headroom to push further) turned out to be **wrong, not just
  unproven**: lowering `--n-cpu-moe` does free headroom on CUDA0/2/3, but
  the paired `--tensor-split` rebalance concentrates the shifted static
  weight onto CUDA1 (already the heaviest-static-weight GPU), so CUDA1's
  margin collapses (33,400 → 20,125 → 6,663 MiB free) faster than the
  other GPUs improve. **Decision: keep `54,9,8,8` for Q4** — confirmed as
  the actual best-margin option of the 3, not merely "safe by reuse."
  See Task 2.5.1 for the full table and reasoning. Cleanup restarted Q4
  correctly each time (confirmed via `systemctl`/`nvidia-smi`); Q4 is
  cold-loading again as of this finding (stopped/restarted by this
  sweep), expected back healthy in the usual ~27-33 min. Full logs:
  `bin/logs/2026-08-22T144828Z-tune-q4-placement-v2/`.
- **Next**: once Q4 is healthy again, run
  `bin/24-benchmark-q4-vs-q5-v2.sh` (Task 2.5.1's throughput A/B) — no
  `Q4_NCMOE`/`Q4_TENSOR_SPLIT` override needed, since its default
  (Q5's `54,9,8,8`) is now confirmed as the winning Q4 config too.

#### 2026-08-22 (later — incident: `bin/17`'s stale Q5-only assumption caused a live crash loop; fixed copies created)

- **Incident**: while examining `bin/17-tune-q4-placement.sh`'s
  just-completed run (see below), found `llama-glm-5.2.service` (Q5)
  stuck in a `Restart=on-failure` crash loop (`activating (auto-restart)`,
  repeated `failed to load model` every ~10s). Root cause: `bin/17`'s
  cleanup trap unconditionally runs `systemctl --user start llama-glm-5.2.service` on exit, regardless of whether Q5 was the
  service actually running before the script started. Since Q4
  (`llama-glm-5.2-q4.service`) is the real live service now (not Q5),
  this made cleanup start Q5 on top of GPU memory Q4 was still holding —
  guaranteed OOM, retried forever by systemd. **Stopped immediately**
  (`systemctl --user stop llama-glm-5.2.service`); confirmed only one
  failed cycle occurred (`journalctl` shows one `Main process exited` at
  14:29:14 CEST before being stopped at 14:29:18) and Q4 was never
  affected (`/health` returned 200 throughout, `nvidia-smi`/`ps aux`
  showed Q4's PID 4316 untouched).
- **Root cause, fully diagnosed**: both `bin/16-benchmark-q4-vs-q5.sh`
  and `bin/17-tune-q4-placement.sh` were written before Task 3.4
  installed `llama-glm-5.2-q4.service` as a real side-by-side systemd
  unit — they hardcode `llama-glm-5.2.service` (Q5) as "the production
  service to stop/restart" in both directions. Confirmed by inspecting
  `bin/17`'s actual just-completed run: `bin/logs/2026-08-22T121941Z-tune-q4-placement/*.log`
  shows all 3 candidates failing `cudaMalloc failed: out of memory` on
  CUDA1 (52-75 GiB requested, none available) — `bin/17` saw Q5 already
  inactive, concluded "nothing to stop," and launched every candidate
  straight into a GPU state Q4 had already filled. **That run's tuning
  data is invalid and was not used for any decision.** `bin/16` has the
  same blind spot, made worse by a literal port collision:
  `AD_HOC_PORT=8093` is now `llama-glm-5.2-q4.service`'s own
  permanently-assigned port.
- **Fix, per explicit user request ("just make copies... run them for Q4
  WITHOUT adding any parameters or setting any env vars")**: rather than
  editing `bin/16`/`bin/17` in place, created corrected copies that need
  zero parameters and auto-detect which service to manage instead of
  hardcoding Q5:
  - **`bin/22-measure-pcie-vs-throughput-q4.sh`**: thin wrapper for
    `bin/15` (mirrors `bin/21`'s pattern for `bin/14`), hardcodes
    `HOST=localhost PORT=8093 MODEL=glm-5.2:UD-Q4_K_XL`. `bin/15` itself
    needed no fix (it's generic — never starts/stops anything, just
    calls whatever `HOST:PORT` is already healthy — and had already been
    run successfully against Q4 by the user directly).
  - **`bin/23-tune-q4-placement-v2.sh`**: corrected copy of `bin/17`.
    Auto-detects whichever of `llama-glm-5.2.service`/
    `llama-glm-5.2-q4.service` is actually active at start, stops THAT
    one for the trial candidates, and restarts THAT SAME one in cleanup
    — never hardcodes either direction. Same 3 candidates, same
    sub-second fit-check technique, same ad-hoc port (8094, unchanged,
    no collision).
  - **`bin/24-benchmark-q4-vs-q5-v2.sh`**: corrected copy of `bin/16`.
    Same auto-detection: benchmarks whichever service is live first
    (Phase A, no ad-hoc load needed since it's already running), stops
    it, ad-hoc cold-loads the OTHER quant (Q5 always `54,9,8,8`; Q4
    defaults to the same reuse until `bin/23` validates a better split —
    editable `Q4_NCMOE`/`Q4_TENSOR_SPLIT` variables at the top, not env
    vars), benchmarks it (Phase B), and restarts the ORIGINAL live
    service in cleanup. Ad-hoc port moved to **8095** (was 8093,
    colliding with the real Q4 service) — full port map now: 8092=Q5
    prod, 8093=Q4 prod, 8094=tuning ad-hoc (`bin/17`/`bin/23`),
    8095=A/B-benchmark ad-hoc (`bin/16`/`bin/24`).
  - `bin/16` and `bin/17` themselves left untouched (not deleted/rewritten)
    as the historical record of the first, buggy attempt — per this
    project's convention of preferring new numbered scripts over
    silently rewriting history.
- **`bin/23` run by the user immediately after being created — surfaced a
  SECOND, independent bug**, this time in the log-grep-then-kill
  technique itself (not the service-detection fix, which worked
  correctly: the run's own pre-flight correctly detected
  `llama-glm-5.2-q4.service` as active, stopped it, and its cleanup
  correctly restarted that same service afterward — confirmed via
  `systemctl`/`ps aux`/`/health` immediately after). **All 3 candidate
  logs stopped at an identical ~3445 bytes**, always right before where
  the `common_fit_params: successfully fit params` line should appear
  (per the known-good reference timing in `bin/logs/*-kv-ctx768000.log`)
  — never showing success OR an explicit failure. Root cause: glibc
  fully-buffers a process's stdout when it isn't a TTY (true here, since
  stdout is redirected to a log file); the script's SIGKILL (used to cut
  each candidate short after only a few seconds, the whole point of the
  "sub-second fit-check" technique) skips normal process exit entirely,
  so any buffered-but-not-yet-flushed stdout content — including the one
  line the script is grep-ing for — is silently lost. (Fatal/OOM errors
  were unaffected, since glibc's stderr is unbuffered by default — this
  is why bin/17's original, invalid run could still show its OOM
  failures correctly even though, per this same bug, it could never have
  shown a genuine success either.) **Fixed in `bin/23`** (not yet
  re-verified live, since testing the success path needs genuinely free
  GPU memory, unavailable while Q4's post-tuning cold-load was in
  progress): (1) `stdbuf -oL` prefixed onto the `llama-server` invocation
  to force line-buffered stdout, and (2) the kill sequence changed from
  an immediate `SIGKILL` to a graceful `SIGTERM` with a 5s grace period
  before falling back to `SIGKILL` — belt-and-suspenders, since a normal
  process exit (unlike `SIGKILL`) triggers the C runtime's own stdio
  flush regardless of whether `stdbuf` alone was sufficient. `bin/24` was
  checked and confirmed NOT to need this fix — it polls `/health` over
  HTTP, not log content, so it was never exposed to this bug.
- **Found (separate, third bug) while retrying**: the user ran
  `bin/24-benchmark-q4-vs-q5-v2.sh` right after `bin/23`'s cleanup
  restarted Q4 — it failed immediately (`localhost:8093/health returned 503`). Cause: Phase A's pre-flight only checked `systemctl is-active`
  to pick which service to benchmark, but a systemd unit reports `active (running)` for the ENTIRE 20-45+ min cold-load window, long before
  `/health` ever returns 200 — `is-active` being true does not mean
  "ready to benchmark." **Fixed in `bin/24`**: Phase A now polls
  `/health` (same pattern Phase B's ad-hoc load already used, up to
  `STARTUP_TIMEOUT`=5400s) before calling `bin/15`, instead of assuming
  active implies healthy. Syntax-checked (`bash -n`), not yet
  re-exercised live.
- **SESSION HANDOFF (context window filling up, continuing in a new
  session)** — state as of session end:
  - `llama-glm-5.2-q4.service` (Q4): `active (running)` since 14:40:44
    CEST, **still cold-loading** (RSS plateaued ~479 GiB for several
    minutes — consistent with the final KV-cache-allocation/graph-build
    phase seen in prior successful loads, not a hang), `/health` still
    503 as of ~21 min elapsed. Historical Q4 cold-loads took ~27-33 min
    total, so likely close.
  - `llama-glm-5.2.service` (Q5): `inactive (dead)`, as expected.
  - User's explicit instruction for the next session: **wait for Q4's
    `/health` to return 200, then re-run
    `bin/23-tune-q4-placement-v2.sh`** (now fixed — `stdbuf -oL` +
    graceful `SIGTERM`, see above) **to get the first genuinely valid Q4
    placement-tuning data.** After that, if a better split is found,
    update `Q4_NCMOE`/`Q4_TENSOR_SPLIT` in
    `bin/24-benchmark-q4-vs-q5-v2.sh` (now also fixed for the
    active-vs-healthy gap above) before running the disruptive full A/B
    benchmark.
  - Nothing destructive in flight; safe to resume by just polling
    `curl http://localhost:8093/health` and proceeding once it's 200.

#### 2026-08-22 (session resumed after a 2-day gap/power-cycle — Task 3.4 side-by-side Q4 install completed and validated)

- Context: user requested (2026-08-20) a Q5-style tuning script for Q4
  limited to 768K/896K, an install script for a side-by-side Q4 service,
  and explicitly "do not take anything offline". Investigating the
  side-by-side request surfaced a hard capacity finding first (see
  Current Status/Task 3.4): `UD-Q4_K_XL` (~467 GB) + `UD-Q5_K_XL`
  (~562 GB) exceed the box's 896 GB pool by ~133 GB, so true concurrent
  residency is impossible regardless of placement. User decided: install
  both as separate, independently swappable systemd services instead,
  with the tuning script allowed to briefly stop Q5 for its own
  measurement window (an explicit, scoped exception to "no offline").
- Completed: `bin/19-llama-glm-5.2-q4.service` (side-by-side unit, port
  8093, reuses Q5's exact `--n-cpu-moe 54 --tensor-split 54,9,8,8 --ctx-size 768000 --load-mode none` placement — deliberately not
  re-optimized, since it's guaranteed safe) and
  `bin/20-install-llama-glm-q4-service.sh` (mirrors `bin/09`) created and
  run: **Q4 service installed** (`loaded; disabled; inactive`),
  confirmed side-by-side with Q5 (which stayed active/untouched
  throughout the install itself — a safe, non-disruptive step).
- Completed: `bin/18-tune-q4-kv-cache-768-896.sh` (Q4 equivalent of
  `bin/07` — same real-load methodology, same 2 context sizes, same
  reused placement) created and run in the background. Briefly stopped
  Q5 (explicitly approved for this script), ran both probes, restarted
  Q5 via a `trap`-guarded cleanup. **Both sizes measured `status=ok`**,
  clearing the ≥15%/≥10 GiB safety-margin policy on every GPU at both
  sizes (see Task 3.4/Current Status for the full per-GPU table) — and
  notably, **Q4 clears 896K where Q5 narrowly missed it** (CUDA0 16.6%
  vs Q5's 14.47%), a side benefit of Q4's smaller per-block footprint
  (~82.4% of Q5's size, measured from GGUF metadata in an earlier
  session entry).
- Found (session gap): this session was interrupted mid-monitoring of
  `bin/18` (which had, in fact, already completed successfully in the
  background before the interruption). On resuming, ~2 real days had
  passed (`date` jumped from 2026-08-20 to 2026-08-22) — consistent with
  this box's normal daily power-cycle routine (see AGENTS.md). Verified
  the tuning script's own log showed a clean completion (`Cleanup (exit code 0)`, Q5 restored) before the gap, so no results were lost.
- Found (live validation, not assistant-driven): on resuming, the box
  showed `llama-glm-5.2-q4.service` actively cold-loading (`active (running)`, healthy) and `llama-glm-5.2.service` freshly, cleanly
  stopped (`journalctl` confirms `systemctl stop`, not a crash — Q5 was
  even briefly started at 10:19:54 CEST and deliberately stopped 8s
  later at 10:20:02, then Q4 started at 10:20:16). This is the user
  exercising the actual intended swap workflow (`stop Q5, start Q4`)
  live and independently after the reboot — good real-world confirmation
  the side-by-side design works as intended, not just in script logic.
- Completed: updated Task 3.4 (new), Current Status, and this entry with
  the full validated results; verified no GPU/RAM conflict occurred at
  any point (checked `nvidia-smi`, `ps aux`, `journalctl` timelines).
- Completed: generalized `bin/14-smoke-test-glm-service.sh`
  (`SERVICE_UNIT`/`HOST`/`PORT`/`MODEL` now overridable env vars,
  previously hardcoded to Q5) and added
  `bin/21-smoke-test-glm-q4-service.sh` as a thin wrapper around it for
  Q4. Ran `bin/21` once the user's cold-load finished (2026-08-22
  11:18-11:20 CEST) against the live `llama-glm-5.2-q4.service`: **all 4
  cases passed** (correct `"Paris"` answer for `enable_thinking:false`,
  coherent non-truncated Fibonacci implementations for both
  `reasoning_effort` modes, well-formed `get_weather` tool call) — same
  bar Q5 passed on 2026-08-20. **Decode throughput came out ~12-13%
  faster than Q5** on the two larger-sample cases (reasoning_high: 14.40
  vs 12.91 tok/s; reasoning_max: 14.57 vs 12.88 tok/s) — a single-sample
  smoke-test comparison, not `bin/15`/`bin/16`'s rigorous benchmark, but
  directly on-point for the complaint that started this whole
  side-by-side effort ("Q5 decode feels slow") — see Task 3.4 for the
  full table and detail.
- Next: whether/when to switch back to Q5, or keep Q4 running given its
  faster smoke-test decode numbers, is the user's call — not automated
  by anything here. If a real throughput comparison is wanted,
  `bin/15-measure-pcie-vs-throughput.sh`/`bin/16-benchmark-q4-vs-q5.sh`
  haven't yet been run against the installed side-by-side Q4 service
  specifically (only ad-hoc probes so far).

#### 2026-08-20 (yet later — Q4-specific block-placement tuning added)

- Found (user question, good catch): reusing Q5's validated
  `--n-cpu-moe 54 --tensor-split 54,9,8,8` for the Q4-vs-Q5 benchmark
  (previous session entry) tests "Q5's config forced onto Q4," not "Q4
  tuned for itself" — since Q4's per-block weight is smaller, the same
  VRAM budget could plausibly support MORE GPU-resident (fewer
  CPU-offloaded) blocks, which would compound with Q4's bit-width
  reduction for a potentially bigger speedup than the ~15-30% estimate.
- Completed: measured Q4's actual MoE-expert-block size directly from
  GGUF tensor metadata (via `gguf-dump`/the `gguf` Python package,
  scanning all shards of both quants) rather than estimating from overall
  file size: **Q4 averages 5.468 GiB/block vs Q5's 6.635 GiB/block
  (~82.4% of Q5's size)**, across the same 76 MoE blocks
  (`block_count=79`, `leading_dense_block_count=3`, `expert_count=256`,
  `expert_used_count=8`, `expert_shared_count=1` — identical architecture
  metadata for both quants, confirming only the per-tensor bit-depth
  differs, not the model structure). Close to but not identical to the
  ~17% overall file-size ratio, confirming MoE-expert tensors shrink
  roughly in step with the whole model between these two quant levels
  (no dramatic surprise, but good to have confirmed rather than assumed).
- Completed: confirmed `--n-cpu-moe N` semantics precisely via
  `llama-server --help`: keeps the MoE weights of the FIRST N layers on
  CPU (not the last N) — resolves an ambiguity that mattered for
  reasoning about how a changed value would interact with
  `--tensor-split`.
- Found (significant efficiency discovery): llama.cpp's own startup
  fit-check (`common_params_fit_impl`/`common_fit_params` log lines,
  e.g. "fitting params to free memory took 0.60 seconds" in an existing
  cold-load log) completes in under a second, immediately after reading
  GGUF metadata — long before the 30-45 min tensor-copy phase begins.
  This means candidate `--n-cpu-moe`/`--tensor-split` placements can be
  evaluated in SECONDS each (start `llama-server`, capture the early
  diagnostic, kill before the expensive load) rather than requiring a
  full cold load per candidate — turning what looked like a multi-hour
  tuning exercise into a few-minutes one.
- Completed: verified the parsing logic for this diagnostic against a
  known-good existing log (`bin/logs/2026-08-20T055618Z-kv-ctx768000.log`)
  before trusting it — the `common_memory_breakdown_print` line's fields
  were initially mislabeled during a first pass (its "second number" is
  the PRE-load baseline free memory, not the post-load free memory as
  first assumed) and corrected to use the more direct, authoritative
  `common_params_fit_impl` line ("`X total, Y used, Z free`") as the
  primary source instead, with the breakdown line kept only for
  supplementary model/context/compute detail. Re-verified against the
  real log: reproduces the already-known-correct Task 2.3 per-GPU numbers
  exactly (e.g. CUDA0 22,710 MiB/23.3% free at ctx=768K, matching prior
  session's recorded 22,569 MiB/23.2% within expected rounding).
- Completed: created `bin/17-tune-q4-placement.sh` (executable,
  syntax-checked, parsing logic verified against real data as above) —
  stops production, tries 3 candidates against `UD-Q4_K_XL`
  (`54,9,8,8` baseline-reuse, `50,11,9,9` modest rebalance,
  `46,13,10,10` more aggressive rebalance — the latter two are informed
  estimates from the ~28 GiB combined headroom Q4 would free if reusing
  Q5's split unchanged, NOT derived from a full simulation of llama.cpp's
  internal layer-assignment algorithm, which isn't fully known/predictable
  from outside — consistent with this project's "measure, don't
  hand-calculate" lesson from Task 2.1's own incidents), each candidate
  killed immediately after its fit-check result, prints a comparison
  table against Q5's hardcoded 768K reference, and restarts production
  via the same `trap`-guarded cleanup pattern as `bin/16`. **Not yet
  run.**
- Completed: updated `bin/16-benchmark-q4-vs-q5.sh` to take
  `NCMOE`/`TENSOR_SPLIT` as overridable env vars (still defaulting to
  Q5's `54,9,8,8` for backward compatibility) instead of hardcoding them,
  so `bin/17`'s winning candidate can feed directly into a fair
  "best Q4 config vs best Q5 config" throughput comparison; added a
  header cross-reference to run `bin/17` first, and a pre-flight-check
  note if the defaults are left unchanged.
- Next: run `bin/17-tune-q4-placement.sh` (expected: minutes, not hours),
  pick a winning candidate, then re-run `bin/16-benchmark-q4-vs-q5.sh`
  with `NCMOE=... TENSOR_SPLIT=...` set to that winner for the real
  throughput A/B (expected: ~1-1.5+ hours, two cold loads). Both still
  require explicit confirmation before running, given they take
  production offline.

#### 2026-08-20 (still later — user reports slow decode; PCIe investigation; Q4-vs-Q5 benchmark tooling prepared)

- Found: user reported decode feels slow in real use. Investigated live
  (this session has shell access to `sys0`): an active connection to the
  production endpoint from `192.168.1.166` was mid-generation.
  `nvidia-smi dmon -s ut` showed **GPU0 sustaining ~46-60 GB/s PCIe RX at
  100% SM utilization**, sampled repeatedly over several seconds (not a
  single-sample fluke), while GPUs 1-3 sat at 0% utilization/near-zero
  PCIe traffic. GPU0 is the GPU already identified (Task 2.3/3.3's
  `nvidia-smi --query-gpu=pcie.link.gen.max` finding) as sitting on this
  box's PCIe 5.0 x16 bus (practical ceiling roughly 55-60 GB/s) — the
  observed rate is close to saturating it.
- Found: this refines earlier assumptions about how `--n-cpu-moe`
  actually behaves here. The evidence (sustained, large, GPU0-concentrated
  PCIe RX, correlated with 100% SM use) is more consistent with the
  CPU-offloaded MoE-expert weight rows being **streamed from CPU RAM to
  GPU every decode step** (closer to a KTransformers-style hybrid) than
  with "those 54 layers' FFN math is computed entirely on the CPU" (which
  would predict much less PCIe traffic — mostly just small activation
  vectors crossing the CPU/GPU boundary). Not fully proven/isolated
  (would need `nsys`-level per-copy tracing or a controlled single-request
  test to rule out confounds), but a strong working hypothesis.
- Completed: derived a theoretical Q4-vs-Q5 speedup estimate from this
  hypothesis: `UD-Q4_K_XL` (467.3 GB actual, ~5.0 bits/weight average) vs
  `UD-Q5_K_XL` (562.5 GB actual, ~6.05 bits/weight average) is ~17%
  smaller overall; if decode is genuinely PCIe-bound, expect **roughly
  15-30% higher tok/s at Q4** (plausibly toward the higher end, since
  Dynamic/XL quant schemes typically cut MoE-expert bit-depth more
  aggressively than attention/embedding layers, and the CPU-offloaded/
  streamed data is specifically MoE-expert weight). Explicitly presented
  to the user as an estimate, not a measurement, with its caveats.
- Found: `UD-Q4_K_XL` (the fallback quant, downloading in the background
  since 2026-08-19) finished during this session — confirmed 100.1%/467.3
  GB via `bin/04-dl-status.sh`, all 11 shards present — so a real A/B
  measurement is now possible.
- Decided (per instruction): don't run the live A/B test yet (it's
  disruptive — stops production for ~1-1.5+ hours). Instead prepared two
  reusable scripts, both executable and syntax/logic-checked against
  synthetic data, but **deliberately NOT executed**:
  - `bin/15-measure-pcie-vs-throughput.sh`: generic — against any
    already-running llama-server endpoint (HOST/PORT/MODEL overridable),
    sends one deterministic long-generation request while sampling
    `nvidia-smi dmon -s ut -o T` in the background, then correlates the
    response's own `timings.predicted_per_second` with per-GPU avg/max
    PCIe RX/TX and SM% during the request's exact wall-clock window.
    Reusable for future throughput checks beyond just this Q4/Q5
    question.
  - `bin/16-benchmark-q4-vs-q5.sh`: orchestrates the full A/B —
    benchmarks the live Q5 production service via `bin/15` first (this
    pass doubles as Task 2.5.1's throughput measurement), stops
    `llama-glm-5.2.service`, cold-loads `UD-Q4_K_XL` ad-hoc on
    `127.0.0.1:8093` (deliberately not `0.0.0.0` — never network-reachable
    as an accidental second endpoint) with identical
    `--n-cpu-moe 54 --tensor-split 54,9,8,8 --load-mode none` placement,
    benchmarks it via `bin/15`, tears it down, and restarts production Q5
    via a `trap`-guarded `cleanup()` that runs on normal exit, on any
    `set -e` failure, and on Ctrl-C — so a mid-script error should not
    leave the box with neither model loaded. Prints a final tok/s
    comparison table with % delta.
- Next: when the endpoint can be taken offline for ~1-1.5h, run
  `bash bin/16-benchmark-q4-vs-q5.sh` and compare its measured delta
  against the ~15-30% theoretical estimate above; update Task 2.5.1 (and
  this session's estimate) with the real number. Feeds into Task 3.3's
  gated rebalancing discussion too, since it's the same PCIe-bound
  hypothesis at stake there.

#### 2026-08-20 (even later, Task 2.4 smoke test run — PASSED, Task 2.4 done)

- Completed: user ran `bin/14-smoke-test-glm-service.sh` against the live
  `llama-glm-5.2.service` (`12:50-12:52 CEST`). All 4 cases passed with
  `finish_reason: stop` (or `tool_calls` for the tool case), no truncation,
  no degenerate/frozen-token signature:
  - `enable_thinking:false`: `"Paris"` (factually correct), 2 completion
    tokens, ~12.0 tok/s
  - `reasoning_effort:high`: correct recursive `fibonacci()` + complexity
    note + memoized alternative, 477 completion tokens, ~12.9 tok/s,
    non-empty `reasoning_content`, NOT truncated
  - `reasoning_effort:max`: correct recursive `fibonacci()` + memoized
    variant, 694 completion tokens, ~12.9 tok/s, non-empty
    `reasoning_content`, NOT truncated (contrast with the earlier ACC-002
    spike's 600-token attempt, which truncated at this same default mode —
    this run's 4000-token budget was enough for a full answer)
  - Tool-calling (REQ-011 risk): well-formed
    `message.tool_calls[0].function` = `{"name":"get_weather","arguments":"{\"location\":\"Paris\"}"}`
    with valid, correctly-keyed JSON arguments; `content` empty as expected
    for a pure tool-call turn (no plain-text imitation, the historical
    llama.cpp weak-tool-calling failure mode)
- Completed: reviewed all 4 result JSONs
  (`bin/logs/2026-08-20T105048Z-smoke-test-glm-service/`) and re-ran the
  script's own analysis pass manually — confirmed `OVERALL: no degenerate/suspicious/failed results found`.
- Completed: marked Task 2.4 `done` with the full per-case result summary;
  updated ACC-004 to record the curl-smoke-test half as PASSED, keeping
  the checkbox itself unchecked since ACC-004's wording explicitly also
  requires a real OpenCode agentic session (deferred to Task 2.6/2.7).
  Updated Current Status, Next Steps (items 0 and 5), and this entry
  accordingly.
- Note: the ~12-13 tok/s figures from this smoke test are informative but
  explicitly NOT a substitute for Task 2.5.1's dedicated throughput
  benchmark — these were short prompts at low actual context depth, not a
  production-realistic 768K-context decode measurement.
- Next: Task 2.5 (768K end-to-end OOM validation — a real filled-context
  generation run, not a load-only probe) → Task 2.5.1 (decode throughput
  benchmark) → Task 2.6 (OpenWebUI/OpenCode wiring, also completes
  ACC-004's remaining OpenCode-session half) → Task 2.7 (quality
  comparison vs. `feat-1`).

#### 2026-08-20 (later, Task 2.4 cold-load confirmed done, smoke-test script prepared)

- Found: confirmed live on `sys0` (this session has shell access to the
  box) that Task 2.4's `llama-glm-5.2.service` cold load — started
  `11:58:20 CEST` — completed successfully: `systemctl --user status`
  shows `active (running)`, `journalctl` shows `model loaded` /
  `listening on http://0.0.0.0:8092` at `12:31:12` (~33 min, in line with
  Task 2.2.1's ~28 min order-of-magnitude estimate), `curl http://localhost:8092/health` returns `200 {"status":"ok"}`, and
  `/v1/models` reports `glm-5.2:UD-Q5_K_XL` with `n_ctx: 768000` /
  `n_ctx_train: 1048576` as expected. No errors observed.
- Completed: wrote `bin/14-smoke-test-glm-service.sh` (Task 2.4's
  remaining verification step) — unlike bin/03/05's Phase 1 spikes, this
  targets the already-running systemd service directly (checks
  `systemctl --user is-active` + `/health` first, does not start/stop its
  own ad-hoc `llama-server`). Runs 3 reasoning-mode cases against
  `/v1/chat/completions` (`enable_thinking:false`, `reasoning_effort:high`,
  `reasoning_effort:max`) plus 1 tool-calling case (a `get_weather`-style
  function schema, checking REQ-011's llama.cpp-tool-calling risk
  specifically), each temperature=0. Includes an automated Python analysis
  pass reusing bin/05's degenerate-frozen-token-signature check, plus new
  checks for truncation (`finish_reason=length` with no content) and
  well-formed `tool_calls[].function.{name,arguments}` (vs. a plain-text
  imitation of a tool call in `content`).
- Decided (per instruction): script written but **deliberately NOT
  executed** this session — left for the next session or the user to run
  (`bash bin/14-smoke-test-glm-service.sh`) and review the `OVERALL`
  verdict before marking Task 2.4/ACC-004 done.
- Next: run `bin/14-smoke-test-glm-service.sh`, review results, mark Task
  2.4/ACC-004 done (or fix and re-run if any case is flagged), then
  proceed to Task 2.5 (768K context OOM validation) → Task 2.5.1
  (throughput benchmark) → Task 2.6 (OpenWebUI/OpenCode wiring) → Task 2.7
  (quality comparison vs. `feat-1`).

#### 2026-08-20 (Task 2.3.1 real run, Task 2.2.1 creation + RAID-contention incident)

- Completed: Implemented Task 2.3.1 — `bin/10-tune-vm-swappiness.sh`
  created (idempotent, persists `vm.swappiness=1` via
  `/etc/sysctl.d/99-glm-swappiness.conf`, applies immediately via `sudo sysctl --system`). User ran it on the actual box: succeeded,
  `vm.swappiness` confirmed `60 -> 1`. Two unrelated `sysctl: ... Invalid argument` warnings for pre-existing `net.ipv4.conf.all.*` keys appeared
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

#### 2026-08-20 (later same day, ~10:30 CEST) — investigated a "very slow progress" report

- Found: the manual RAID-check pause from earlier did NOT survive the
  system stop/start (reboot) — `mdcheck_continue.timer` re-fired a
  **fresh, unpaused** continuation scrub on `/dev/md126`, confirmed via
  `journalctl -u mdcheck_continue.service`: started `2026-08-20T05:14:02Z`,
  finished `2026-08-20T09:42:05Z` ("Deactivated successfully"). Confirmed
  finished now: `sync_action`=`idle`, `mismatch_cnt`=`0`. This was a
  genuine, ~4.5h I/O-contention window for anything disk-heavy started
  during it — not user error, and now fully resolved. The Blockers
  section's "remember to resume the paused RAID check" note is stale —
  no manual resume needed, it already completed on its own trigger.
- Found: three `bin/11` restart attempts this morning
  (`09:23:47`, `09:40:51`, `10:12:43`) each got killed within ~2-3 seconds
  of starting — every log stops at the identical point (right after the
  `blk.78` "unused tensor" metadata warnings), before `llama.cpp`'s
  tensor-copy phase begins, which prints nothing until the model is fully
  loaded. Read: these were restarted believing "no new log output" meant
  hung, when this loader is simply silent for the entire multi-hundred-GB
  copy phase. The `10:12:43` attempt additionally started with a
  contaminated baseline (162,064 MiB already "in use" on GPU — a
  stale-teardown artifact from the prior kill not yet fully released).
- Found: the 4th attempt (started `10:18:24Z`, still running at check
  time) is healthy — clean baseline, RAID scrub already finished before
  it started, and a sustained **~289 MB/s** disk-read rate verified via
  two independent `/proc/<pid>/io` `read_bytes` samples ~90s apart (no
  degradation). At check time: 186.8 GiB / 524 GiB read (~33%), ETA
  ~20-22 more minutes — consistent with Task 2.1's historical 20-45 min
  cold-load range. `curl http://127.0.0.1:8091/health` correctly returned
  `503 Loading model` (not crashed/hung).
- Lesson recorded for future sessions: judge a cold-load's progress by
  `/proc/<pid>/io`'s `read_bytes` growth (or `/health` status) — NOT by
  GPU-memory appearing idle or by log silence, both of which look
  identical whether the load is healthy or actually stuck. Also: a
  reboot can silently un-pause a previously-paused RAID scrub via its
  systemd timer, so re-check `/proc/mdstat`/`sync_action` after any
  power-cycle before blaming a slow load on something else.
- Next: let the current `bin/11` run (PID 8615 at check time) finish
  uninterrupted; do not kill/restart it again. Then proceed as previously
  planned (read the RECOMMENDATION line, feed `--load-mode` into
  `bin/08-llama-glm-5.2.service`, Task 2.3 install).

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
  drafted) — the `--load-mode` decision is an input to `bin/08-llama-glm- 5.2.service`, same as the finalized `--ctx-size`/`--tensor-split` values,
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
- **2026-08-20 (production context size: 768K chosen, 896K flagged as a
  revisit candidate)**: With Track A's `bin/07-measure-kv-cache-768-896.sh`
  results in (both `ctx=768,000` and `ctx=896,000` measured `status=ok`,
  see Task 2.3), the per-GPU numbers settle the context-size question in
  favor of **768K as the production `--ctx-size`**: every GPU clears the
  adopted ≥15%-free-or-≥10-GiB-absolute safety-margin policy with room to
  spare (worst case CUDA0 at 22,569 MiB free / 23.2%). **896K does not
  clear the same bar**: its worst GPU (CUDA0) measures 14,079 MiB free
  (14.47%) against a 14,593 MiB (15% of its 97,288 MiB total) requirement —
  a ~514 MiB (~0.5 GiB) shortfall on the stricter leg of the policy, even
  though it still clears the flat ≥10 GiB leg (13.75 GiB > 10 GiB). Given
  the policy was deliberately sized to leave headroom for production
  extras Task 2.1/Track A's load-only probes don't exercise (larger batch
  sizes, prompt cache, OpenCode tool-call payloads, OS/driver overhead —
  see Task 2.2), shipping on a config that already trips one leg of its
  own safety policy before any of those extras are added is judged too
  thin a margin for a first production deployment. 768K still exceeds
  REQ-003's 350-370K target by more than 2x, so there is no requirements
  pressure to take the risk.
  **896K is explicitly NOT discarded — it is flagged as a candidate to
  revisit later**, for at least two reasons: (1) it is CUDA0's margin
  specifically that fails, and CUDA0 is also the GPU identified (Task 2.3,
  PCIe-topology finding) as sitting on the box's faster PCIe 5.0 bus while
  carrying the largest KV-cache-growth share under the current
  `--tensor-split 54,9,8,8` split — the pending rebalancing discussion
  could plausibly shift enough of that share off CUDA0 (or onto the other
  Gen5 GPU, CUDA2, which has ~28-30 GiB free at both sizes) to close the
  ~514 MiB gap without giving up any margin elsewhere; (2) the ~514 MiB
  shortfall itself is small relative to the ~14-23 GiB range these GPUs are
  operating in, i.e. this is a placement/tuning problem, not a fundamental
  capacity one. If/when the rebalancing lands and a re-measurement shows
  896K clearing the policy, this decision can be revisited without
  re-running the 768K/896K probe again (the data already exists in
  `bin/logs/2026-08-20T055618Z-kv-cache-768-896.{txt,json}` and the
  per-context `*-kv-ctx768000.log`/`*-kv-ctx896000.log` files) — only the
  rebalanced config would need re-testing. Until then, 768K is what ships
  in `bin/08-llama-glm-5.2.service`.

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
  — confirmed live on the box shortly after (`llama-server --ctx-size 768000 ...` loading under tmux session `glm-kv-768-986`, PID 137131).
- Completed (in parallel, Track B): drafted `bin/08-llama-glm-5.2.service`
  (systemd unit for `llama-server` + GLM-5.2/`UD-Q5_K_XL`, placeholder
  `--ctx-size 524288`/512K — the largest DIRECTLY measured size, not the
  extrapolated one — and the validated `--n-cpu-moe 54 --tensor-split 54,9,8,8`; port 8092, chosen to avoid the ad-hoc measurement port 8091
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

#### 2026-08-20 (user-level systemd for Task 2.3)

- **Decision: `llama-glm-5.2.service` will be installed as a systemd
  `--user` unit** (`~/.config/systemd/user/llama-glm-5.2.service`,
  managed entirely via `systemctl --user ...`), NOT a system-wide unit
  under `/etc/systemd/system/` like `feat-1`'s
  `vllm-deepseek-v4-flash.service`. Rationale: this service is expected
  to be started/stopped/restarted repeatedly during iterative testing
  (Tasks 2.4-2.7 and beyond), and requiring an interactive `sudo`
  password for every one of those cycles is friction with no real
  security benefit here — the box's `user` account already has `sudo`,
  REQ-008 already accepts an anonymous/unauthenticated network posture,
  and REQ-009 only requires "a managed service (systemd unit or
  equivalent)", which `systemctl --user` satisfies exactly as well as a
  system unit (still no ad-hoc foreground processes, still start/stop
  exclusively via `systemctl`, just with `--user` added).
- **Trade-off explicitly accepted: lingering (`loginctl enable-linger`)
  is deliberately NOT enabled.** Consequence: the service only runs
  while `user` has an active login session; it will NOT auto-start on
  boot and will NOT survive past the last session closing. Chosen
  because this box's actual workflow is already "power-cycle, then
  manually kick off testing" (see AGENTS.md/Task 2.2.1's own note about
  the daily power-cycle) — a manual `systemctl --user start` after each
  boot/login fits that workflow with no added step, whereas lingering
  would add a persistence guarantee nothing here currently needs. This is
  revisitable: if unattended 24/7 uptime across reboots ever becomes a
  requirement (e.g. once this moves from iterative testing to a
  standing production endpoint that other users/services depend on),
  `loginctl enable-linger` is the one additional command needed — no
  changes to the unit file itself.
  **CORRECTED later the same day** — this bullet's framing of the
  requirement was wrong; see "lingering + no autostart" below for the
  corrected decision and the incident it caught.
- **Decision: add `user` to the `video`/`render` groups** (new **Task
  2.3.2**, `bin/12-setup-user-systemd-groups.sh`) as defense-in-depth for
  GPU device access, even though it is not currently required — this
  box's `/dev/nvidia*` device files are presently world-writable
  (`crw-rw-rw-`), so a systemd `--user` service can already open them
  without any group membership. Explicit group membership is the
  standard, portable mechanism for this and should not be skipped just
  because a permissive (and possibly incidental/overridable) device
  permission happens to make it unnecessary today.
- **Practical consequences for the unit file** (`bin/08-llama-glm-5.2.service`,
  already updated): no `User=`/`Group=` (meaningless for a `--user`
  unit), `[Install] WantedBy=default.target` instead of
  `multi-user.target` (the user manager's equivalent target), and
  explicit `Environment=PATH=...`/`Environment=CUDA_VISIBLE_DEVICES=...`
  since `systemd --user` does not source the login shell's
  `~/.bashrc`/`~/.profile`. `bin/09-install-llama-glm-service.sh` updated
  to install to `~/.config/systemd/user/` via `systemctl --user daemon-reload` — deliberately NOT `enable` (see "lingering + no
  autostart" below for why), with no `sudo` anywhere in that script.

#### 2026-08-20 (lingering + no autostart — correction + live incident)

- **Corrected requirement:** the actual ask was "keep `llama-glm-5.2.service`
  running even when no user is logged in", NOT "autostart at boot right
  now" — these are two different systemd mechanisms and the original
  same-day decision above conflated them (it assumed "no lingering" was
  the right choice for "no autostart yet", which is wrong: without
  lingering, the service dies the moment the last login session closes,
  autostart or not).
- **Decision (superseding the earlier one): enable lingering, but do NOT
  enable the unit.** The two together give exactly the wanted behavior:
  - Lingering ON (`loginctl enable-linger`, no sudo needed for a user
    enabling their own lingering — verified on this box) keeps `user`'s
    `systemd --user` manager instance alive/running with zero active
    login sessions (and starts it at boot, ahead of any login), so a
    service started under it survives logout.
  - The unit stays **disabled** (never `systemctl --user enable`d) —
    critically, enabling a unit is what causes it to auto-start when the
    user manager reaches `default.target`, which now happens at boot
    once lingering is on. Leaving it disabled means it only ever runs
    when someone explicitly runs `systemctl --user start llama-glm-5.2` — but once started that way, it keeps running across
    logout (because of lingering) and simply does not come back on its
    own after a reboot until started again by hand.
  - To opt into full autostart-at-boot later, the only additional step
    is `systemctl --user enable llama-glm-5.2.service`; nothing else
    (lingering, the unit file itself) needs to change for that.
- **Live incident caught and fixed while implementing this:** checking
  lingering status on the box found that `bin/09-install-llama-glm-service.sh`
  had already been run once (by the user, separately, per this feature's
  established parallel-work pattern) and had `enable`d the unit as that
  script was originally written. With lingering freshly turned on in the
  very same check, that enabled unit was one boot away from silently
  auto-starting `llama-glm-5.2` — a 570 GB model load across all 4
  GPUs — the exact "autostart at this time" outcome explicitly ruled
  out. Caught immediately (`systemctl --user status llama-glm-5.2`
  showed `enabled`), fixed via `systemctl --user disable llama-glm-5.2`
  (confirmed back to `disabled`/`inactive (dead)`, GPUs unaffected — the
  GPU memory in use at check time was independently accounted for by
  Task 2.2.1's own `bin/11` load-mode benchmark, not by an accidental
  start of this unit). Tracked as **Task 2.3.3** (done) alongside Task
  2.3.2.
- **Fixes applied so this can't silently recur:** `bin/09-install-llama-glm-service.sh`
  rewritten to never call `systemctl --user enable`, and to defensively
  `disable` the unit again if it finds it already enabled from a prior
  run (e.g. from before this correction) every time the script is
  re-run. New `bin/13-enable-user-lingering.sh` created (idempotent) to
  make the lingering step itself scripted/reproducible rather than a
  one-off manual command. `bin/08-llama-glm-5.2.service`'s header comment
  rewritten to describe the corrected lingering + not-enabled combination
  instead of the superseded "no lingering" framing.

#### 2026-08-20 (Task 2.3.2 rollout — `$USER`-under-`sudo` bug + manual `root` removal)

- **Bug found while rolling out Task 2.3.2:** `bin/12-setup-user-systemd-groups.sh`
  originally derived its target account from `$USER`. Invoked as `sudo bash 12-setup-user-systemd-groups.sh`, `$USER` resolved to `root`
  (the account `sudo` actually runs as), so the script happily reported
  "already a member of video/render" for `root` — which was true and
  therefore silently made no changes — rather than adding the intended
  `user` account. No harm done (idempotent, no-op on the wrong target),
  but the real work hadn't happened.
- **Fix:** changed the script to take the target user as an optional
  first positional argument (`TARGET_USER="${1:-user}"`), defaulting to
  `user`, with the header comment updated to warn against relying on
  `$USER` under `sudo` and to show the corrected invocation:
  `sudo bash 12-setup-user-systemd-groups.sh user`.
- **Done (2026-08-20):** re-run with the fix; confirmed via `id user` —
  `video`(44) and `render`(110) both present in `user`'s group list, no
  fresh login needed beyond the session already active at the time.
- **Decision: remove `root` from `video`/`render`, but do this manually,
  NOT as part of the script.** Rationale: `root` doesn't need group
  membership for device access (it has it unconditionally), and having
  it there is very likely an artifact of the driver/base-image setup
  rather than an intentional choice for this feature — tightening it is
  reasonable, but doing so automatically from a script whose stated
  purpose is "add `user`" would be a scope-creeping, easy-to-miss side
  effect on a shared system group. Executed manually: `sudo delgroup root video`, `sudo delgroup root render`. Confirmed: `/etc/group` now
  shows `video:x:44:user` / `render:x:110:user` — `user` only, no `root`.

#### 2026-08-20 (session wrap-up — Task 2.2.1 landed, OpenCode config drafted, context budget)

- **Completed: Task 2.2.1 (`--load-mode` benchmark) confirmed DONE and
  DECIDED this session** (the 4th `bin/11-benchmark-load-mode.sh` attempt,
  killed/restarted three times earlier the same day due to RAID10-scrub
  I/O contention, finished cleanly): `--load-mode none` measured 1694s
  (~28.2m) vs. `mmap-default`'s 1842s (~30.7m) — **8% faster**. Verified
  directly from `bin/logs/2026-08-20T081824Z-load-mode-bench.{txt,json}`
  and cross-checked that no `llama-server` process was still running.
  `--load-mode none` is now baked into `bin/08-llama-glm-5.2.service`'s
  `ExecStart`, alongside the already-decided `--ctx-size 768000`. Also
  re-confirmed `/dev/md126`'s RAID10 consistency check is genuinely
  finished (`sync_action: idle`, `mismatch_cnt: 0`), not merely paused —
  the earlier "remember to resume it" note is stale/moot.
- **Completed: drafted the OpenCode client-side config for this endpoint**
  (Task 2.6, done ahead of time since Task 2.3/2.4 aren't finished yet):
  - Added `--alias glm-5.2:UD-Q5_K_XL` to `bin/08-llama-glm-5.2.service`.
    Without it, `llama-server` reports its own identity as the raw
    absolute GGUF file path in `/v1/models` and in every response's
    `"model"` field — confirmed empirically from an early spike response
    (`bin/logs/2026-08-19T113231Z-spike-result.json`: the client sent one
    `"model"` value, the server echoed back a completely different one,
    its own full path — `llama-server` does not validate/echo the
    request's `model` field when only one model is loaded).
  - Created `opencode-provider-snippet-glm-5.2.jsonc` (feature folder
    root, alongside `followup-comment-draft.md`) — a standalone,
    paste-able `provider` fragment for a **different** system's
    `opencode.jsonc` (explicitly NOT written into this box's own
    `~/.config/opencode/opencode.jsonc`, per user instruction). Mirrors
    the box's existing `ollama-sys0` provider shape:
    `@ai-sdk/openai-compatible`, `baseURL: http://<sys0-LAN-IP>:8092/v1`,
    model key `glm-5.2:UD-Q5_K_XL`, `limit.context: 768000`,
    `limit.output: 32768` (a placeholder cap, not a measured value —
    chosen to comfortably clear the truncation seen in one ACC-002 spike
    case where a 600-token budget wasn't enough for GLM-5.2's default
    `reasoning_effort: max` mode).
  - Added **Task 3.2** (Phase 3: Optimisations) to track a gap surfaced
    while drafting that snippet: OpenCode's documented config schema has
    no obvious way to inject `--chat-template-kwargs`-equivalent extra
    body fields (`reasoning_effort`/`enable_thinking`) per model, so
    OpenCode sessions against this endpoint would run GLM-5.2 in its
    default mode only until that's resolved. Not a blocker for
    Task 2.4/ACC-004 (verified via curl instead, per REQ-004's own
    wording).
- **Completed: fixed a stale line in Blockers** — it still referenced
  Track A/load-mode as open/running; corrected to reflect both are done
  and decided, leaving the `--tensor-split`/`--n-cpu-moe` rebalancing
  discussion as the ONLY remaining gate before Task 2.3's actual install.
- **Session wrap-up (context budget, ending here for a fresh session):**
  nothing else was touched on the box this session beyond what's recorded
  above (no GPU/model state changed, no other files outside this feature
  folder). Clean resumption point for the next session:
  1. Hold the `--tensor-split`/`--n-cpu-moe` PCIe-rebalancing discussion
     (GPU0/GPU2 = PCIe 5.0 x16, GPU1/GPU3 = PCIe 4.0 x16; CUDA0 is both
     the GPU that decided 768K-over-896K in Task 2.3 AND the one on the
     faster bus — rebalancing could reopen the 896K question, see
     Decisions Made). This is the single open item blocking install.
  2. Once decided, edit `bin/08-llama-glm-5.2.service`'s
     `--tensor-split`/`--n-cpu-moe` (everything else — `--ctx-size`,
     `--load-mode`, `--alias` — is already final), then run
     `bin/09-install-llama-glm-service.sh` (copy + `daemon-reload` only,
     a `systemctl --user` install, no sudo).
  3. Task 2.4 (`systemctl --user start`, curl smoke test, tool-calls, all
     3 reasoning modes) through Task 2.7 (OpenWebUI/OpenCode wiring using
     `opencode-provider-snippet-glm-5.2.jsonc`, real 768K context
     validation, quality comparison vs. `feat-1`) remain not-started.
  4. `UD-Q4_K_XL` fallback download may still be finishing in the
     background (`bin/04-dl-status.sh`) — no longer needed for anything,
     safe to ignore or let finish.
  5. Task 3.1 (swapfile resize), Task 3.2 (`--chat-template-kwargs`
     from OpenCode), and Task 3.3 (`--tensor-split`/`--n-cpu-moe`
     rebalancing, revisiting 896K) are all open, non-blocking Phase 3
     items — Task 3.3 additionally depends on Task 2.5.1 landing first.

#### 2026-08-20 (rebalancing reframed as non-blocking, moved to Phase 3)

- **Reframing decision:** the `--tensor-split`/`--n-cpu-moe` rebalancing
  discussion was being tracked as an embedded gating item inside Task
  2.3's description, phrased as "the only remaining gate" before install.
  On review, that framing was imprecise: rebalancing was never actually
  needed for 768K's safety (768K already clears the adopted ≥15%/≥10 GiB
  safety-margin policy on every GPU with real room to spare, and exceeds
  REQ-003's 350-370K target by 2x+) — it was only ever relevant to
  reclaiming the 896K stretch goal, which was already independently
  flagged as "a revisit candidate, not discarded" rather than required.
  Conflating the two made Task 2.3 look blocked when it wasn't.
- **Decision: do not rebalance before installing at 768K.** Stripped the
  rebalancing item out of Task 2.3's gating list entirely (all three
  original gates — 768K/896K probe, `--load-mode`, and now this — are
  resolved; Task 2.3 is unblocked). Moved the discussion to a new **Task
  3.3** in **Phase 3: Optimisations**, explicitly gated on **Task 2.5.1**
  (decode tok/s baseline) landing first — not just deferred for
  scheduling convenience. Rationale: the current split's KV-cache
  imbalance on CUDA0 appears tied to which layers `--n-cpu-moe 54`
  offloads experts from (CUDA0 holds the *smallest* static model weight
  of the four GPUs, 19,485 MiB, yet 71% of the total KV-cache) — CUDA0
  also happens to sit on the box's faster PCIe 5.0 bus, which is
  currently a good pairing for that offloaded-expert traffic (streamed
  across PCIe every decode step). Shrinking CUDA0's tensor-split ratio to
  free KV-cache margin could inadvertently shift that traffic onto a
  slower Gen4 GPU instead, regressing decode throughput to gain context
  headroom — a trade-off invisible without a throughput baseline to
  compare against, hence the explicit Task 2.5.1 dependency.
- **Practical effect:** `bin/08-llama-glm-5.2.service` is now considered
  fully finalized (`--ctx-size 768000 --n-cpu-moe 54 --tensor-split 54,9,8,8 --load-mode none`); `bin/09-install-llama-glm-service.sh` can
  be run at any time without waiting on anything further.

#### 2026-08-20 (Task 2.3 installed)

- **Task 2.3 is DONE.** `bin/09-install-llama-glm-service.sh` run
  successfully on the box: `systemctl --user status llama-glm-5.2.service`
  confirms `Loaded: loaded (/home/user/.config/systemd/user/llama-glm-5.2.service; disabled; vendor preset: enabled)`, `Active: inactive (dead)` — exactly the intended state (see "lingering + no autostart"
  above): won't autostart at boot, ready for an explicit `systemctl --user start`. Installed unit file confirmed byte-identical to
  `bin/08-llama-glm-5.2.service` via `diff`. Task 2.4 (`start` + curl
  smoke test) is next.

### Related PRs / Commits

- None yet
  </content>
  </invoke>
