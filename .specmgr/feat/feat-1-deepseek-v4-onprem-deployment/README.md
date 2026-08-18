---
id: feat-1-deepseek-v4-onprem-deployment
version: 1.0.0
status: planning
created: 2026-08-18
updated: 2026-08-18
github_issue: 1
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
- [ ] Task 1.4: `systemctl start` the service; curl smoke test against `/v1/chat/completions`, verify tool-calls and think/non-think output — depends on: Task 1.3 — status: blocked (2026-08-18: service starts and responds over HTTP with `finish_reason: length`, but generated output is degenerate garbage, not a crash. At temperature=1 output is token noise mixing many scripts/languages; at temperature=0 (greedy) every single decode position returns the exact same special token (`<|begin▁of▁sentence|>`) with the exact identical logprob (-11.7697...) regardless of position/context — a strong signature of a broken forward pass (e.g. sparse-attention decode returning zeroed/garbage context), not a sampling or tokenizer issue. Ruled out CUDA-graph capture as the cause via `--enforce-eager` (`bin/08-diag-enforce-eager.sh`): identical degenerate output with graphs fully disabled. Remaining suspects: the `FLASHINFER_MLA_SPARSE_DSV4` SM120 sparse-MLA decode kernel path (needed per Task 1.3 fix #6, since the alternative `FLASHMLA_SPARSE_DSV4` backend is unconditionally broken on our `sm_120` GPUs in this vLLM build) and/or the native FP4+FP8 mixed quantization fallback (needed per Task 1.3 fix #3) and/or missing fp8 kv-cache scaling factors (vLLM logs its own warning: "may cause accuracy drop without a proper scaling factor"). A true `--tensor-parallel-size 1` isolation test is infeasible: native-precision weights are ~152 GB total (38 GB/GPU × 4), which doesn't fit on one ~95 GB GPU. Needs upstream vLLM/FlashInfer investigation, a different vLLM/FlashInfer version, or a `--tensor-parallel-size 2` isolation test (feasible but weaker signal, not yet tried) before this can be unblocked.)
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

**As of 2026-08-18 (evening)**: Phase 0 complete. Phase 1: Task 1.3 (systemd
service) now complete after a long crash-loop debugging session (7 distinct
infra/environment bugs found and fixed — see Task 1.3 note and `bin/00`-`07`
scripts). Task 1.4 is now blocked on a genuine model-output correctness bug
(degenerate/garbage generation), not an infra problem — see Blockers below.
Service is currently left running (may still be up from the last
`--enforce-eager` diagnostic attempt) but should not be considered usable
until the correctness bug is resolved.

### Next Steps

1. **Decide how to attack the correctness bug** (Task 1.4 blocker): try a
   `--tensor-parallel-size 2` isolation run (feasible VRAM-wise, weaker
   signal than TP=1 which doesn't fit), try a different vLLM/FlashInfer
   version, or open an upstream issue against vLLM/FlashInfer for the
   `FLASHINFER_MLA_SPARSE_DSV4`/SM120 sparse-MLA decode path.
2. Once Task 1.4 is unblocked, remove the diagnostic `--enforce-eager`
   flag from the unit (`bin/08-diag-enforce-eager.sh` was diagnostic-only,
   not a fix) before proceeding to Task 1.5+.
3. **Start Pro download** (Task 0.7, independent of the Flash blocker):
   ```bash
   cd /data/vllm && python3 download_pro.py
   ```

### Blockers

- [ ] **Task 1.4: DeepSeek-V4-Flash generates degenerate/garbage output**
  despite the service running and responding over HTTP without crashing —
  impact: endpoint is up but unusable; blocks Task 1.4 through 1.7;
  mitigation: see Task 1.4 note for full diagnostic trail (CUDA graphs
  already ruled out via `--enforce-eager`); next candidates are a
  `--tensor-parallel-size 2` isolation run, a different vLLM/FlashInfer
  version, or an upstream bug report against the SM120 sparse-MLA decode
  kernel path.
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

### Related PRs / Commits

- None yet
