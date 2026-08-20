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

### Next Steps

1. **Task 2.1 is done.** The fixed-config sweep (`2026-08-19T220559Z`)
   succeeded at all 5 ramp sizes up to 524,288 tokens with large headroom
   (~239 GiB at 512K ctx vs the 896 GB pool) — see Task 2.1 for the full
   table and the derived ~0.104 GiB/1K-tokens KV-cache rate.
2. Do Task 2.2 (confirm `UD-Q5_K_XL` vs `UD-Q4_K_XL` for the 350-370K
   target — Task 2.1's numbers strongly favor keeping `UD-Q5_K_XL`, no
   headroom pressure found) through Task 2.7 (systemd service,
   OpenWebUI/OpenCode wiring, context validation, quality comparison vs.
   `feat-1`).
3. Let `bin/00-download-glm-quants.sh` keep finishing `UD-Q4_K_XL`
   (fallback, 60.8% at last check) in the background — check progress any
   time with `bin/04-dl-status.sh`. Not a gate on Task 2.2+ unless
   something downstream (e.g. Task 2.5's real filled-context run) forces a
   step-down.
4. Decide whether to post `followup-comment-draft.md` to
   vllm-project/vllm#52938 — drafted and hedged, deliberately left for a
   separate decision, not posted.
5. `feat-1`'s parallel SGLang/vLLM-version diagnostics remain independently
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
  (~235 GiB vs the 896 GB pool). `UD-Q4_K_XL` (fallback) is still
  downloading in the background (60.8% at last check) but is not required
  for Task 2.2+.

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

### Related PRs / Commits

- None yet
  </content>
  </invoke>
