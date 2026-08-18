---
created: 2026-08-18
github_issue: 1
id: feat-1-deepseek-v4-onprem-deployment
status: planning
updated: 2026-08-18
version: 1.0.0
---

# Feature: On-prem DeepSeek-V4-Flash/Pro serving for OpenCode + OpenWebUI

## Plan

### Overview

Deploy DeepSeek-V4-Flash and DeepSeek-V4-Pro on existing on-prem hardware,
each behind an OpenAI-compatible API, for use as coding models via OpenCode
and OpenWebUI. Quality is the priority over speed. Ollama's library-listed
`deepseek-v4-flash`/`deepseek-v4-pro` are cloud-proxy tags only (no local
weights) and are explicitly not used; official MIT-licensed weights from
`deepseek-ai/DeepSeek-V4-Flash`/`-Pro` on Hugging Face are loaded directly
instead, pinned to a specific revision for reproducibility.

### Requirements

- REQ-001: Serve DeepSeek-V4-Flash via an OpenAI-compatible API
  (`/v1/chat/completions`) on the Dell 7960T (4x RTX Pro 6000 Blackwell
  Max-Q, 96GB each = 384GB VRAM; 512GB system RAM)
- REQ-002: Serve DeepSeek-V4-Pro via an OpenAI-compatible API on the same
  Dell 7960T, without adding new hardware and without networking in the
  DGX Spark
- REQ-003: Both endpoints must support real coding workloads reaching
  350-370K tokens of context
- REQ-004: Both endpoints must support tool-calling (required for OpenCode
  agentic use) and expose DeepSeek-V4's think/non-think/max-think reasoning
  modes correctly
- REQ-005: Maximize model quality; inference speed is explicitly secondary
- REQ-006: No third-party GGUF requantization — load official weights
  directly to avoid an extra, unverified source of quality loss
- REQ-007: Pin both models to a specific Hugging Face revision/commit
  (not "latest") for reproducibility across redeploys
- REQ-008: Both endpoints run unauthenticated (anonymous, no API-key/auth
  layer) — accepted risk, internal network only
- REQ-009: Both engines run as managed services (systemd units or
  equivalent), started/stopped via the service manager — no ad-hoc
  foreground processes, including during testing

### Acceptance Criteria

- [ ] ACC-001: Verifies REQ-001 — `vllm serve deepseek-ai/DeepSeek-V4-Flash`
  running with tensor-parallel=4 on the Dell 7960T, reachable via
  `/v1/chat/completions`
- [ ] ACC-002: Verifies REQ-002 — ktransformers serving
  `deepseek-ai/DeepSeek-V4-Pro` on the same box, reachable via its
  OpenAI-compatible endpoint
- [ ] ACC-003: Verifies REQ-003 — empirical test confirms both endpoints
  handle a 350-370K-token coding prompt without OOM
- [ ] ACC-004: Verifies REQ-004 — tool-call and reasoning-mode output
  verified via curl smoke test, then via a real OpenCode agentic session
- [ ] ACC-005: Verifies REQ-005 — Flash runs with FP8 experts (upgraded
  from native FP4+FP8 mixed) if vLLM's loader supports the override;
  Pro's exact quantization level is chosen empirically to leave headroom
  for REQ-003's context requirement
- [ ] ACC-006: Verifies REQ-006 — both engines load weights directly from
  `deepseek-ai/DeepSeek-V4-Flash`/`-Pro` on Hugging Face, no GGUF requant
- [ ] ACC-007: Verifies REQ-007 — deployment config records the exact HF
  revision/commit hash used for each model
- [ ] ACC-008: Verifies REQ-008 — endpoints reachable without credentials
  from the internal network, confirmed intentional (not an oversight)
- [ ] ACC-009: Verifies REQ-009 — both engines installed as systemd
  services; started/stopped/restarted exclusively via `systemctl`
  throughout testing and production use
- [ ] ACC-010: User runs their own existing coding-task examples against
  both endpoints once setup is complete; same examples reused later to
  compare quality across future implementations (e.g. GLM-5.2)

### Scope

What is included in this feature:

- vLLM deployment of DeepSeek-V4-Flash on the Dell 7960T, as a systemd
  service
- ktransformers deployment of DeepSeek-V4-Pro on the Dell 7960T, as a
  systemd service
- OpenWebUI and OpenCode configured against both endpoints
- Empirical KV-cache/context validation for both models
- Pinning both models to a fixed HF revision

What is explicitly out of scope:

- Any use of the DGX Spark for this deployment (explicitly excluded by
  user decision)
- Any use of Ollama's cloud-tagged library models
- Any GGUF/community requantization path
- Acquiring additional hardware for DeepSeek-V4-Pro
- Authentication/access-control layer (explicitly accepted as anonymous)
- GLM-5.2 fallback deployment — tracked as a separate, future feature

### Dependencies

- Depends on: confirmed vLLM version with merged DeepSeek-V4 tool-call/
  reasoning-parser support; confirmed ktransformers version with
  DeepSeek-V4 architecture support; GPU driver/CUDA compatibility for RTX
  Pro 6000 Blackwell; sufficient local disk space (1TB+) on the Dell
  7960T for both model weight sets
- Blocks: none
- Related (not a dependency, tracked separately): a future feature will
  deploy GLM-5.2 as a fallback/alternative model — not part of this
  feature's scope

### Design Notes

- Two independent serving engines by design: vLLM for Flash (fits fully
  in VRAM, gets native DeepSeek-V4 tool-call/reasoning-parser support),
  ktransformers for Pro (purpose-built GPU+CPU-RAM hybrid MoE inference,
  needed because Pro's ~800GB+ native footprint doesn't fit in 384GB VRAM
  alone).
- Precision tradeoff resolved: for Pro, user explicitly accepted lower
  precision (below native FP4+FP8 mixed) in exchange for guaranteed
  350-370K context headroom, since both cannot fit simultaneously in the
  896GB VRAM+RAM pool at native precision. Exact quant level to be
  determined empirically (measure real KV-cache cost per 1K tokens first,
  then pick the lightest trim that leaves safe margin — not the tightest
  possible fit).
- For Flash, FP8-expert override is the target (vs. native FP4 experts)
  since the resulting ~284GB footprint still fits comfortably in 384GB
  VRAM with headroom for the required context; fallback to native FP4+FP8
  mixed if vLLM's loader doesn't expose the override.
- DGX Spark intentionally left out of this feature's scope per explicit
  user decision (no cross-node networking between DGX Spark and Dell
  7960T).
- Both models pinned to a specific HF revision at deployment time, not
  tracking "latest" — avoids unexpected drift on redeploy, given DeepSeek
  appears to ship rolling checkpoint updates (observed `preview` →
  `0731`/`0813`-dated snapshots).
- No authentication layer: both OpenAI-compatible endpoints are
  reachable anonymously on the internal network. Accepted risk, not an
  oversight — revisit only if network exposure changes.
- Both engines run exclusively as systemd-managed services (or
  equivalent service manager) — start/stop/restart via `systemctl`, even
  during initial testing, never as manually-launched foreground
  processes.
- Benchmark approach: no synthetic/formal benchmark suite defined here.
  User will run their own existing real coding-task examples once each
  endpoint is live, and reuse the same examples later to compare quality
  across future alternatives (e.g. GLM-5.2).

### Related ADRs

- None (this is infrastructure/deployment work, tracked in its own repo
  using the feature-folder convention documented in biz.dfch.SpecMgr's
  ADR e369ee2e-3353-4f92-991c-6367d76d832e)

### Task List

#### Phase 0: Environment prep

- [x] Task 0.1: Validate available local disk space on the Dell 7960T (need 1TB+ free for both weight sets combined) — depends on: none — status: completed (2026-08-18: /data has 9.3 TB free)
- [x] Task 0.2: Verify GPU driver/CUDA version compatibility with RTX Pro 6000 Blackwell across all 4 GPUs — depends on: none — status: completed (2026-08-18: 4 GPUs detected, driver 610.57.04, CUDA 13.3, 384 GB VRAM total; GRUB + modprobe fixes applied; GPU 0 has ollama using 43 GB, GPUs 1-3 free)
- [x] Task 0.3: Set up Hugging Face access/token and download tooling — depends on: none — status: completed (2026-08-18: HF CLI logged in as appclusive; hf_transfer installed via uv)
- [x] Task 0.4: Choose and record pinned HF revision/commit for `deepseek-ai/DeepSeek-V4-Flash` — depends on: Task 0.3 — status: completed (2026-08-18: pinned to 60d8d70770c6776ff598c94bb586a859a38244f1 from main branch, dated 2026-06-22)
- [x] Task 0.5: Choose and record pinned HF revision/commit for `deepseek-ai/DeepSeek-V4-Pro` — depends on: Task 0.3 — status: completed (2026-08-18: pinned to b5968e9190ef611bbf34a7229255be88a0e937c1 from main branch, dated 2026-06-22)
- [x] Task 0.6: Download DeepSeek-V4-Flash weights at the pinned revision — depends on: Task 0.4, Task 0.1 — status: completed (2026-08-18: 46/46 shards, 186 GB at /data/nvidia/hf_cache/hub/models--deepseek-ai--DeepSeek-V4-Flash)
- [ ] Task 0.7: Download DeepSeek-V4-Pro weights at the pinned revision — depends on: Task 0.5, Task 0.1 — status: in-progress (2026-08-18: script created at /data/vllm/download_pro.py)

#### Phase 1: DeepSeek-V4-Flash (vLLM)

- [x] Task 1.1: Confirm vLLM version/build with merged DeepSeek-V4 tool-call and reasoning parsers — depends on: none — status: completed (2026-08-18: vLLM 0.26.0 has DeepSeek-V4 model, tokenizer, tool parser (deepseek_v4), reasoning parser (deepseek_v4), FP8 quant config with expert_dtype detection; --hf-overrides available for expert_dtype override)
- [x] Task 1.2: Verify whether vLLM's `deepseek_v4` loader honors an FP8-expert override (vs. native FP4 experts) — depends on: Task 1.1 — status: completed (2026-08-18: verified via --hf-overrides '{"expert_dtype": "fp8"}'; quant config resolves to fp8 when vllm_config context active)
- [x] Task 1.3: Install vLLM + DeepSeek-V4-Flash as a systemd service (tensor-parallel=4) on the Dell 7960T — depends on: Task 1.2, Task 0.6 — status: completed (2026-08-18: service at /etc/systemd/system/vllm-deepseek-v4-flash.service now starts reliably, stays up under `systemctl`, and serves HTTP. Reached only after fixing a chain of 7 distinct bugs, in order: (1) `KillMode=process` left orphaned GPU-memory-holding workers behind after a start-timeout kill, causing every subsequent attempt to fail on insufficient free VRAM — fixed via `KillMode=control-group` + `TimeoutStartSec=3600` (script `bin/00-fix-vllm-flash-service.sh`); (2) every startup silently hung on an outbound Hugging Face network call (`snapshot_download`/Xet backend) despite weights being fully local — fixed via `HF_HUB_OFFLINE=1`/`TRANSFORMERS_OFFLINE=1` (`bin/02-fix-vllm-flash-offline.sh`); (3) `--hf-overrides '{"expert_dtype":"fp8"}'` hit a real vLLM TP-sharding bug in the MoE weight loader (`tensor a (32) != tensor b (128)`, i.e. `128 experts / tp_size(4)`) — fixed by dropping the override and falling back to the model's native FP4+FP8 mixed expert precision, the contingency already called out in Design Notes (`bin/03-fallback-native-quant.sh`); (4) the venv's pip-installed CUDA component wheels were version-skewed (`nvidia-cuda-nvcc`/`-crt`/`-cccl` on 13.3.x vs `-runtime`/`-nvrtc`/`-cupti` still on 13.0.x), breaking TileLang's nvcc JIT compiles — fixed by upgrading the latter three to 13.3.x (`bin/04-fix-cuda-toolkit-skew.sh`); (5) the systemd unit had no `PATH`, so `ninja` (needed for JIT-compiled CUDA extensions) couldn't be found even though it was installed — fixed by adding `PATH=/data/vllm/.venv/bin:...` (`bin/05-fix-missing-venv-path.sh`); (6) `--attention-backend FLASHMLA_SPARSE_DSV4` has a confirmed, unconditional gap for `sm_120` GPUs (ours) in this vLLM build — its tile-scheduler builder intentionally returns all-`None` on SM120, but the FlashMLA decode path asserts on it anyway — fixed by switching to the SM120-aware sibling backend `FLASHINFER_MLA_SPARSE_DSV4`, which in turn needed `nvcc`'s directory added to `PATH` for FlashInfer's own capability probing (`bin/06-fix-attention-backend-sm120.sh`); (7) FlashInfer's JIT linker step failed with `cannot find -lcudart` because the pip-installed CUDA runtime wheel uses a `lib/` + versioned-only layout, not the classic toolkit's `lib64/` + unversioned-symlink layout FlashInfer's build script assumes — fixed with two symlinks (`lib64 -> lib`, `libcudart.so -> libcudart.so.13`) (`bin/07-fix-cudart-symlinks.sh`). All fix scripts live in `bin/` in this feature folder, numbered in the order they were created, each with a detailed root-cause comment header.)
- [ ] Task 1.4: `systemctl start` the service; curl smoke test against `/v1/chat/completions`, verify tool-calls and think/non-think output — depends on: Task 1.3 — status: blocked (2026-08-18: service starts and responds over HTTP with `finish_reason: length`, but generated output is degenerate garbage, not a crash. At temperature=1 output is token noise mixing many scripts/languages; at temperature=0 (greedy) every single decode position returns the exact same special token (`<|begin▁of▁sentence|>`) with the exact identical logprob (-11.7697...) regardless of position/context — a strong signature of a broken forward pass (e.g. sparse-attention decode returning zeroed/garbage context), not a sampling or tokenizer issue. Ruled out CUDA-graph capture as the cause via `--enforce-eager` (`bin/08-diag-enforce-eager.sh`): identical degenerate output with graphs fully disabled. Remaining suspects: the `FLASHINFER_MLA_SPARSE_DSV4` SM120 sparse-MLA decode kernel path (needed per Task 1.3 fix #6, since the alternative `FLASHMLA_SPARSE_DSV4` backend is unconditionally broken on our `sm_120` GPUs in this vLLM build) and/or the native FP4+FP8 mixed quantization fallback (needed per Task 1.3 fix #3) and/or missing fp8 kv-cache scaling factors (vLLM logs its own warning: "may cause accuracy drop without a proper scaling factor"). A true `--tensor-parallel-size 1` isolation test is infeasible: native-precision weights are ~152 GB total (38 GB/GPU × 4), which doesn't fit on one ~95 GB GPU. Needs upstream vLLM/FlashInfer investigation, a different vLLM/FlashInfer version, or a `--tensor-parallel-size 2` isolation test (feasible but weaker signal, not yet tried) before this can be unblocked. UPDATE 2026-08-18 evening: researched and verified (via direct GitHub fetches, not just an LLM research summary) several open upstream vLLM issues matching this hardware/model combo — vLLM #47528 (DeepSeek-V4-Pro garbled under TP, correct under DP+EP), #50720 (FlashInfer SM120 sparse-MLA decode dispatch bug, spec-decode-specific), #50773 (fuse_norm_quant/fuse_act_quant fusions garble output on SM120 for DeepSeek-V4-Flash). Ran `bin/09-diag-dp-ep.sh` to test the #47528 pattern: switched to `--data-parallel-size 4 --enable-expert-parallel` (same native FP4+FP8 mixed experts, same FLASHINFER_MLA_SPARSE_DSV4 backend, `--max-model-len` temporarily dropped to 8192 for a fast diagnostic). Result: **identical degenerate signature** (every decode position returns `<|begin▁of▁sentence|>` at logprob -11.769736289978027, byte-for-byte the same as under TP=4) — rules out #47528's TP-vs-DP+EP pattern as the cause here. Also ruled out #50773's fusion-pass theory without a separate test: the DP+EP run's own startup log showed "Inductor compilation was disabled by user settings, optimizations settings that are only active during inductor compilation will be ignored" immediately after "Enabled custom fusions: norm_quant, act_quant" — confirming those fusions are configured but never actually applied under `--enforce-eager`, which we'd already tested. Remaining live suspects: the `FLASHINFER_MLA_SPARSE_DSV4` decode kernel itself (independent of TP/DP+EP, since both parallelism strategies hit the same failure), missing FP8 KV-cache scaling factors, or a vLLM/FlashInfer version issue — vLLM 0.27.0/0.27.1 and flashinfer-python 0.6.16/0.6.17 postdate our 0.26.0/0.6.14 and contain real (verified) DeepSeek-V4 sparse-MLA-decode-adjacent fixes, though none confirmed to fix this exact signature. Diagnostic service is currently still running under the DP+EP/8192-context config from `bin/09-diag-dp-ep.sh`; not yet reverted. UPDATE 2026-08-18 late night: tried upgrading vLLM 0.26.0 → 0.27.1 and flashinfer-python 0.6.14 → 0.6.17 via `bin/10-upgrade-vllm-flashinfer.sh` (a much larger change than expected — vLLM 0.27.1 requires torch 2.13.0, pulling ~2GB of new/updated CUDA-toolkit wheels; pip also flagged flashinfer-python 0.6.17 as incompatible with vLLM 0.27.1's pinned `flashinfer-python==0.6.16.post3`, a risk accepted for the test). Result: **this upgrade path is a dead end on our hardware**, discovered via two consecutive deterministic crashes, both regressions vs. 0.26.0 (worse than the original bug — 0.26.0 at least served HTTP with degenerate output; 0.27.1 never got that far): (1) on first restart, `RuntimeError: Assertion error (deepgemm-src/csrc/apis/layout.hpp:60): Unknown SF transformation` in `deepgemm_post_process_weight_scale_block` during weight loading; (2) after trying the cheap `VLLM_USE_DEEP_GEMM=0` workaround (`bin/12-diag-disable-deepgemm.sh`), a *different* deterministic crash: `RuntimeError: Assertion error (deepgemm-src/csrc/apis/hyperconnection.hpp:56): Unsupported architecture`, raised from `tf32_hc_prenorm_gemm` while computing DeepSeek-V4's mHC (Manifold-Constrained Hyper-Connections) layers — this call path is unconditional and bypasses `VLLM_USE_DEEP_GEMM=0` entirely (that env var only affects the separate FP8 linear-layer scaled-mm path in `fp8.py`). Conclusion: vLLM 0.27.1's vendored DeepGEMM build does not support SM120 (RTX PRO 6000 Blackwell) for DeepSeek-V4's mHC kernels at all — a hard architecture gap, not a flag to work around. Rolled vLLM/flashinfer-python back to 0.26.0/0.6.14 via `bin/13-rollback-vllm-flashinfer.sh` (confirmed via `pip show`) and removed the now-irrelevant `VLLM_USE_DEEP_GEMM=0` env line via `bin/14-remove-deepgemm-env-and-retest.sh`, restoring the unit to its exact pre-upgrade baseline (TP=4, native FP4+FP8 mixed experts, `FLASHINFER_MLA_SPARSE_DSV4`, fp8 kv-cache, `--enforce-eager`, 8192-token diagnostic context) for retesting. This rules out the vLLM/flashinfer version-upgrade hypothesis entirely — remaining candidates are testing without `--kv-cache-dtype fp8`, or filing an upstream vLLM issue with our exact repro.)
- [ ] Task 1.5: Connect OpenWebUI and OpenCode to the Flash endpoint — depends on: Task 1.4 — status: not-started
- [ ] Task 1.6: Validate 350-370K-token context works without OOM — depends on: Task 1.5 — status: not-started
- [ ] Task 1.7: User runs their real coding-task examples against the endpoint — depends on: Task 1.6 — status: not-started

#### Phase 2: DeepSeek-V4-Pro (ktransformers)

- [ ] Task 2.1: Confirm ktransformers version with DeepSeek-V4 architecture support and OpenAI-compatible API — depends on: none — status: not-started
- [ ] Task 2.2: Install ktransformers + DeepSeek-V4-Pro as a systemd service at native FP4+FP8 mixed precision, measure actual KV-cache memory per 1K tokens at real context shapes — depends on: Task 2.1, Task 0.7 — status: not-started
- [ ] Task 2.3: Choose the lightest precision trim that reliably supports 350-370K context with safe margin, based on Task 2.2 measurements — depends on: Task 2.2 — status: not-started
- [ ] Task 2.4: Reconfigure the service with the chosen precision and ktransformers per-layer GPU/RAM placement — depends on: Task 2.3 — status: not-started
- [ ] Task 2.5: `systemctl start`/restart the service; verify tool-calling and reasoning-mode behavior — depends on: Task 2.4 — status: not-started
- [ ] Task 2.6: Connect OpenWebUI and OpenCode to the Pro endpoint as a separate model entry — depends on: Task 2.5 — status: not-started
- [ ] Task 2.7: User runs the same coding-task examples from Task 1.7 against this endpoint for comparison — depends on: Task 2.6 — status: not-started

**Note:** If a task's scope changes mid-flight, edit its description in place;
rely on git history (`git log -p` on this file) to recover what was
originally planned, rather than keeping a second copy of the task around.

## Progress

### Current Status

**As of 2026-08-18 (late night)**: Phase 0 nearly complete (Task 0.7 Pro
download still running in the background, ~560GB downloaded so far). Phase 1:
Task 1.3 (systemd service) complete after a 7-bug crash-loop debugging
session (see Task 1.3 note and `bin/00`-`07` scripts). Task 1.4 remains
blocked on the model-output correctness bug; three upstream-matched
hypotheses have now been tested and **ruled out**: TP-path bug (vLLM #47528),
torch.compile fusion-pass bug (vLLM #50773), and a stale vLLM/flashinfer
version (upgrading to 0.27.1/0.6.17 hit a hard, unrelated SM120/DeepGEMM
architecture gap and was rolled back — see Task 1.4 note). Service is back on
vLLM 0.26.0/flashinfer-python 0.6.14 and **confirmed reproducing the exact
original degenerate-output baseline** post-rollback (identical frozen token
and logprob to 15 decimal places) — the rollback and its own CUDA-toolkit-
skew regression (bin/15, a repeat of Task 1.3 fix #4) are both fully
resolved and verified.

### Next Steps

1. **Continue Task 1.4 correctness-bug isolation** — TP-vs-DP+EP, the
   compilation fusion passes, and the vLLM/flashinfer version upgrade are
   now all ruled out (see Task 1.4 note). Live candidates: (a) test without
   `--kv-cache-dtype fp8` to rule out the missing-scaling-factor warning as
   the cause; (b) file an upstream vLLM issue with our exact repro
   (identical-token/identical-logprob at every position) since it doesn't
   exactly match #47528/#50720/#50773; (c) a `--tensor-parallel-size 2`
   isolation test (feasible VRAM-wise, weaker signal than the already-tried
   DP+EP=4).
2. ~~Confirm the post-rollback restart reproduces the original
   degenerate-output baseline~~ — done, confirmed 2026-08-18 late night.
3. Once Task 1.4 is unblocked, restore `--max-model-len 370000` (currently
   8192 for fast diagnostics) and remove the diagnostic `--enforce-eager`
   flag (`bin/08-diag-enforce-eager.sh` was diagnostic-only) before
   proceeding to Task 1.5+.
4. Monitor Task 0.7 (Pro download, `/data/vllm/download_pro.py`, PID 36347
   as of 2026-08-18 night) — independent of the Flash blocker, no action
   needed until it completes.

### Blockers

- [ ] **Task 1.4: DeepSeek-V4-Flash generates degenerate/garbage output**
  despite the service running and responding over HTTP without crashing —
  impact: endpoint is up but unusable; blocks Task 1.4 through 1.7;
  mitigation: see Task 1.4 note for the full diagnostic trail. Ruled out so
  far: CUDA-graph capture (`--enforce-eager`), the TP-vs-DP+EP execution
  path (vLLM #47528's pattern, tested via `bin/09-diag-dp-ep.sh` — identical
  degenerate output under DP+EP), torch.compile fusion passes (vLLM
  #50773 — confirmed inactive under `--enforce-eager` via startup log), and
  a stale vLLM/flashinfer version (0.27.1/0.6.17 upgrade hit a hard,
  unrelated SM120/DeepGEMM architecture gap in DeepSeek-V4's mHC layers —
  see Task 1.4 note — and was rolled back to 0.26.0/0.6.14). Remaining
  candidates: the `FLASHINFER_MLA_SPARSE_DSV4` decode kernel itself or
  missing FP8 KV-cache scaling factors.
- [ ] Pro's actual KV-cache cost at 350-370K tokens is unknown — impact:
  can't confirm precision/context fit without empirical testing;
  mitigation: Task 2.2 measures this directly before committing to a quant
  level

### Recent Updates

#### 2026-08-18

- Completed: Researched Ollama library listings (cloud-only tags),
  confirmed official HF weights + existing GGUF quantizations, evaluated
  hardware fit for both models on the DGX Spark and Dell 7960T, resolved
  engine choice (vLLM/ktransformers), precision tradeoffs, security
  posture (anonymous/no-auth accepted), version pinning, benchmark
  approach, and operational model (systemd services only) through
  discussion with user; repo `biz.dfch.LlmOps` created and this feature
  folder scaffolded (including `.specmgr/_template/v1/README.md`, copied
  from biz.dfch.SpecMgr's convention for reuse in this repo)
- Next: Begin Phase 0 (environment prep)
- Notes: Feature linked to GitHub issue #1 (was `feat-0-` per user instruction)

#### 2026-08-18 (evening session — Flash crash-loop debugging)

- Completed: Diagnosed and fixed a 7-bug chain preventing
  `vllm-deepseek-v4-flash.service` from ever starting successfully after a
  reboot (see Task 1.3 note for full detail): orphaned-process GPU-memory
  leak from `KillMode=process`, a silent network hang on every startup
  despite fully-local weights, a TP-sharding bug in the FP8-expert-override
  weight loader, a pip CUDA-toolkit version skew breaking JIT compiles, a
  missing `PATH` breaking `ninja`, an unconditional SM120 gap in the
  `FLASHMLA_SPARSE_DSV4` attention backend, and a missing `libcudart`
  dev-symlink breaking FlashInfer's JIT linker step. All fixes captured as
  numbered, root-cause-documented scripts in `bin/00` through `bin/07`.
- Completed: Got the service to actually start, load weights, capture CUDA
  graphs, and serve HTTP successfully for the first time.
- Found: Task 1.4 smoke test reveals the served model generates degenerate
  output (identical special token + identical logprob at every decode
  position at temperature=0) — a real correctness bug, not a crash.
  Ruled out CUDA-graph capture as the cause via `bin/08-diag-enforce-eager.sh`
  (diagnostic only, same degenerate output with graphs disabled). Root
  cause still open — see Blockers.
- Next: Decide on further correctness-bug isolation (TP=2 test, version
  change, or upstream bug report) before continuing to Task 1.5+.

#### 2026-08-18 (night session — upstream research + DP+EP isolation test)

- Completed: Researched vLLM/FlashInfer version history and upstream GitHub
  issues for the Task 1.4 correctness bug. Independently verified (via
  direct `webfetch` of the actual GitHub pages, not just trusting an LLM
  research summary — several claimed issue numbers were spot-checked and
  confirmed real) three closely-matching open vLLM issues: #47528
  (DeepSeek-V4-Pro garbled under TP, correct under DP+EP), #50720
  (FlashInfer SM120 sparse-MLA decode dispatch bug, spec-decode-specific),
  #50773 (fuse_norm_quant/fuse_act_quant fusions garble DeepSeek-V4-Flash
  output on SM120/GB10). Also confirmed vLLM v0.27.0's real release notes
  contain DeepSeek-V4-specific sparse-MLA-decode work and that
  flashinfer-python 0.6.17 (we're on 0.6.14) has SM12x-targeted fixes.
- Completed: Wrote and ran `bin/09-diag-dp-ep.sh` to test the #47528
  pattern against our Flash deployment — swapped `--tensor-parallel-size 4`
  for `--data-parallel-size 4 --enable-expert-parallel`, temporarily
  dropped `--max-model-len` to 8192 for a fast smoke test. Hit an unrelated
  transient failure first (GPU 0's pre-existing ollama usage spiked to 42GB
  right as the diagnostic started, pushing free memory below the 90%
  utilization target — self-resolved a few minutes later when ollama's
  model idled out; systemd's `Restart=on-failure` + `KillMode=control-group`
  handled the crash-loop cleanly, confirming Task 1.3 fix #1 still holds).
- Found: DP+EP produces the **exact same degenerate output** as TP=4 (same
  frozen token, same logprob to 15 decimal places) — rules out #47528's
  TP-vs-DP+EP pattern for our case. Also ruled out #50773's fusion-pass
  theory without a separate test, via the DP+EP run's own startup log
  ("optimizations settings that are only active during inductor compilation
  will be ignored" — confirming those fusions never actually run under
  `--enforce-eager`, which had already been tested).
- Next: choose between a vLLM/flashinfer version upgrade, disabling FP8
  KV-cache, or filing an upstream bug report — see Next Steps.

#### 2026-08-18 (late night session — vLLM 0.27.1 upgrade attempt and rollback)

- Completed: Upgraded vLLM 0.26.0 → 0.27.1 and flashinfer-python 0.6.14 →
  0.6.17 via `bin/10-upgrade-vllm-flashinfer.sh`, as the next Task 1.4
  diagnostic. Turned out to be a much larger change than a version bump:
  vLLM 0.27.1 requires torch 2.13.0, pulling ~2GB of new/updated CUDA
  wheels (cudnn, cublas, nccl, cusparselt, triton, etc.); pip also flagged
  the forced flashinfer-python 0.6.17 as incompatible with vLLM 0.27.1's
  own pin (`flashinfer-python==0.6.16.post3`), a risk accepted to test
  the newer flashinfer's SM12x fixes anyway.
- Found: the upgrade introduced two consecutive, deterministic, new
  regressions (both worse than the original Task 1.4 bug — service never
  reached HTTP serving): (1) `Unknown SF transformation` in DeepGEMM's
  weight-scale post-processing on the very first restart; (2) after trying
  `VLLM_USE_DEEP_GEMM=0` (`bin/12-diag-disable-deepgemm.sh`) as a cheap
  workaround, a *different* crash — `Unsupported architecture` in
  DeepGEMM's `hyperconnection.hpp`, raised from the unconditional
  `tf32_hc_prenorm_gemm` call computing DeepSeek-V4's mHC layers (this
  path bypasses `VLLM_USE_DEEP_GEMM=0` entirely, which only gates a
  separate FP8-linear scaled-mm path). Conclusion: vLLM 0.27.1's vendored
  DeepGEMM build has a hard, unconditional SM120 architecture gap for
  DeepSeek-V4's mHC (Manifold-Constrained Hyper-Connections) kernels —
  not something fixable via flags on our hardware.
- Completed: Rolled vLLM/flashinfer-python back to 0.26.0/0.6.14 via
  `bin/13-rollback-vllm-flashinfer.sh` (confirmed via `pip show`) and
  removed the now-irrelevant `VLLM_USE_DEEP_GEMM=0` env line via
  `bin/14-remove-deepgemm-env-and-retest.sh`, restoring the unit to its
  exact pre-upgrade baseline for retesting.
- Notes: each pip install/upgrade in this session took 10-20+ minutes due
  to large (300-500MB+) wheel downloads competing for bandwidth with the
  still-running Task 0.7 Pro download; ran them via `setsid nohup ... & disown` to survive shell-tool timeouts, since a plain backgrounded
  `nohup` process was still killed when its parent tool call timed out.
- Found: the rollback itself reintroduced Task 1.3 fix #4's CUDA-toolkit
  version skew — `nvidia-cuda-nvcc`/`-crt`/`-cccl` stayed on the 13.3.x
  line (pulled up by the 0.27.1/torch-2.13.0 upgrade) while
  `nvidia-cuda-runtime`/`-nvrtc`/`-cupti` came back down to 13.0.x with
  the torch 2.11.0 reinstall, since pip's resolver doesn't proactively
  downgrade transitive deps that still satisfy the new constraint. First
  post-rollback restart hit the identical CCCL error as Task 1.3 fix #4
  (`cuda_toolkit.h:41:8: error: "CUDA compiler and CUDA toolkit headers are incompatible"`), this time inside flashinfer's JIT-compiled
  `sampling` op rather than TileLang's mHC kernel.
- Completed: Re-applied Task 1.3 fix #4's exact remedy (upgrade
  `nvidia-cuda-runtime`/`-nvrtc`/`-cupti` to the matching 13.3.x line) via
  `bin/15-fix-cuda-toolkit-skew-again.sh`, plus clearing flashinfer's
  stale JIT cache built against the mismatched toolkit. The already-
  running `Restart=on-failure` crash loop picked up the fix on its next
  automatic retry (no unit change or manual restart needed).
- Completed: **Confirmed the service is back to the exact original
  Task 1.4 baseline** — temperature=0 smoke test reproduces the identical
  degenerate signature (`<|begin▁of▁sentence|>` at logprob
  `-11.769736289978027` for all 10 requested tokens), byte-for-byte
  matching both the original bug and the DP+EP test. The vLLM 0.27.1
  upgrade path, its DeepGEMM/mHC regression, and the rollback's own CUDA-
  skew regression are now all fully resolved and the environment is
  clean.
- Next: with TP-vs-DP+EP, fusion passes, and the version upgrade all ruled
  out, try disabling `--kv-cache-dtype fp8` or file an upstream vLLM issue
  with the exact repro — see Next Steps.

### Decisions Made

- **2026-08-18**: Rejected Ollama's official `deepseek-v4-flash`/
  `deepseek-v4-pro` library tags — cloud-proxy only, not on-prem
- **2026-08-18**: Use official HF weights directly via vLLM/ktransformers
  instead of community GGUF requantization, to preserve quality
- **2026-08-18**: Flash served via vLLM (fits fully in VRAM, gets native
  tool-call/reasoning-parser support); Pro served via ktransformers
  (purpose-built GPU+CPU-RAM hybrid for MoE, needed since Pro doesn't fit
  in VRAM alone)
- **2026-08-18**: No new hardware for Pro; DGX Spark explicitly excluded
  (no cross-node networking)
- **2026-08-18**: For Pro, user accepted lower precision (below native
  FP4+FP8 mixed) in exchange for guaranteed 350-370K context support
- **2026-08-18**: Both models pinned to a specific HF revision, not
  "latest"
- **2026-08-18**: No authentication on either endpoint — anonymous access
  accepted as internal-network-only risk
- **2026-08-18**: Both engines run as systemd services exclusively, never
  ad-hoc processes, including during testing
- **2026-08-18**: GLM-5.2 fallback explicitly deferred to a separate,
  future feature — not built here
- **2026-08-18**: Repo named `biz.dfch.LlmOps` (generic, not
  DeepSeek-specific, to host future model-serving features like GLM-5.2)
- **2026-08-18 (evening)**: For Flash, fell back from the FP8-expert
  override to native FP4+FP8 mixed expert precision — the override hit a
  real vLLM TP-sharding bug (checkpoint/loader shape mismatch), not just
  "unsupported"; this is the exact contingency already anticipated in
  Design Notes, just triggered by a bug rather than a missing feature
- **2026-08-18 (evening)**: For Flash, switched `--attention-backend` from
  `FLASHMLA_SPARSE_DSV4` to `FLASHINFER_MLA_SPARSE_DSV4` — the FlashMLA
  backend has a confirmed, unconditional gap for `sm_120` GPUs (ours) in
  this vLLM build; the FlashInfer sibling backend has a dedicated SM120
  code path instead. This later turned out to still produce degenerate
  output, so this decision may need revisiting once Task 1.4's blocker is
  resolved
- **2026-08-18 (evening)**: All infra/environment fix scripts for this
  feature live in `bin/` under this feature folder, numbered in the order
  they were created (`00`-`08`), each with a comment header documenting
  the root cause and evidence — kept as both a remediation record and a
  reproducible runbook for future redeploys
- **2026-08-18 (late night)**: Staying on vLLM 0.26.0 / flashinfer-python
  0.6.14 for now, not upgrading to 0.27.1/0.6.17 — the newer vLLM's
  vendored DeepGEMM build hard-asserts "Unsupported architecture" for
  DeepSeek-V4's mHC layers on our SM120 GPUs, a regression not present in
  0.26.0 and not avoidable via `VLLM_USE_DEEP_GEMM=0`. Revisit only if a
  future vLLM/flashinfer/DeepGEMM release specifically claims SM120 mHC
  support.

### Related PRs / Commits

- None yet
