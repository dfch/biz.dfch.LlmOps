---
id: feat-0-deepseek-v4-onprem-deployment
version: 1.0.0
status: planning
created: 2026-08-18
updated: 2026-08-18
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
- [ ] Task 0.1: Validate available local disk space on the Dell 7960T (need 1TB+ free for both weight sets combined) — depends on: none — status: not-started
- [ ] Task 0.2: Verify GPU driver/CUDA version compatibility with RTX Pro 6000 Blackwell across all 4 GPUs — depends on: none — status: not-started
- [ ] Task 0.3: Set up Hugging Face access/token and download tooling — depends on: none — status: not-started
- [ ] Task 0.4: Choose and record pinned HF revision/commit for `deepseek-ai/DeepSeek-V4-Flash` — depends on: Task 0.3 — status: not-started
- [ ] Task 0.5: Choose and record pinned HF revision/commit for `deepseek-ai/DeepSeek-V4-Pro` — depends on: Task 0.3 — status: not-started
- [ ] Task 0.6: Download DeepSeek-V4-Flash weights at the pinned revision — depends on: Task 0.4, Task 0.1 — status: not-started
- [ ] Task 0.7: Download DeepSeek-V4-Pro weights at the pinned revision — depends on: Task 0.5, Task 0.1 — status: not-started

#### Phase 1: DeepSeek-V4-Flash (vLLM)
- [ ] Task 1.1: Confirm vLLM version/build with merged DeepSeek-V4 tool-call and reasoning parsers — depends on: none — status: not-started
- [ ] Task 1.2: Verify whether vLLM's `deepseek_v4` loader honors an FP8-expert override (vs. native FP4 experts) — depends on: Task 1.1 — status: not-started
- [ ] Task 1.3: Install vLLM + DeepSeek-V4-Flash as a systemd service (tensor-parallel=4) on the Dell 7960T — depends on: Task 1.2, Task 0.6 — status: not-started
- [ ] Task 1.4: `systemctl start` the service; curl smoke test against `/v1/chat/completions`, verify tool-calls and think/non-think output — depends on: Task 1.3 — status: not-started
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

**As of 2026-08-18**: Planning complete via discussion; hardware, engine,
precision, security, versioning, and operational (systemd) decisions all
finalized. Repo `biz.dfch.LlmOps` created. No implementation started yet.

### Blockers

- [ ] vLLM's exact support for the FP8-expert override on DeepSeek-V4 is
  unverified — impact: Flash may have to run at native FP4+FP8 mixed
  instead of full FP8 experts; mitigation: verify early in Task 1.2
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
- Notes: Feature created without a GitHub issue (`feat-0-`) per user
  instruction

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

### Related PRs / Commits

- None yet
