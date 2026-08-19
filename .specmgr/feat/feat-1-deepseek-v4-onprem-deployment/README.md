---
created: 2026-08-18
github_issue: 1
id: feat-1-deepseek-v4-onprem-deployment
status: planning
updated: 2026-08-19
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
- Related (not a dependency, tracked separately):
  `feat-2-glm-5.2-onprem-deployment` deploys GLM-5.2 as a fallback/
  alternative model — not part of this feature's scope. Its Phase 1 SM120
  sparse-attention correctness spike and this feature's Task 1.4 diagnostic
  inform each other (both hit the same SM120 sparse-attention-decode kernel
  class).

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
- [x] Task 0.7: Download DeepSeek-V4-Pro weights at the pinned revision — depends on: Task 0.5, Task 0.1 — status: completed (2026-08-19: all 64 shards downloaded to /data/nvidia/hf_cache/hub/models--deepseek-ai--DeepSeek-V4-Pro)

#### Phase 1: DeepSeek-V4-Flash (vLLM)

- [x] Task 1.1: Confirm vLLM version/build with merged DeepSeek-V4 tool-call and reasoning parsers — depends on: none — status: completed (2026-08-18: vLLM 0.26.0 has DeepSeek-V4 model, tokenizer, tool parser (deepseek_v4), reasoning parser (deepseek_v4), FP8 quant config with expert_dtype detection; --hf-overrides available for expert_dtype override)
- [x] Task 1.2: Verify whether vLLM's `deepseek_v4` loader honors an FP8-expert override (vs. native FP4 experts) — depends on: Task 1.1 — status: completed (2026-08-18: verified via --hf-overrides '{"expert_dtype": "fp8"}'; quant config resolves to fp8 when vllm_config context active)
- [x] Task 1.3: Install vLLM + DeepSeek-V4-Flash as a systemd service (tensor-parallel=4) on the Dell 7960T — depends on: Task 1.2, Task 0.6 — status: completed (2026-08-18: service at /etc/systemd/system/vllm-deepseek-v4-flash.service now starts reliably, stays up under `systemctl`, and serves HTTP. Reached only after fixing a chain of 7 distinct bugs, in order: (1) `KillMode=process` left orphaned GPU-memory-holding workers behind after a start-timeout kill, causing every subsequent attempt to fail on insufficient free VRAM — fixed via `KillMode=control-group` + `TimeoutStartSec=3600` (script `bin/00-fix-vllm-flash-service.sh`); (2) every startup silently hung on an outbound Hugging Face network call (`snapshot_download`/Xet backend) despite weights being fully local — fixed via `HF_HUB_OFFLINE=1`/`TRANSFORMERS_OFFLINE=1` (`bin/02-fix-vllm-flash-offline.sh`); (3) `--hf-overrides '{"expert_dtype":"fp8"}'` hit a real vLLM TP-sharding bug in the MoE weight loader (`tensor a (32) != tensor b (128)`, i.e. `128 experts / tp_size(4)`) — fixed by dropping the override and falling back to the model's native FP4+FP8 mixed expert precision, the contingency already called out in Design Notes (`bin/03-fallback-native-quant.sh`); (4) the venv's pip-installed CUDA component wheels were version-skewed (`nvidia-cuda-nvcc`/`-crt`/`-cccl` on 13.3.x vs `-runtime`/`-nvrtc`/`-cupti` still on 13.0.x), breaking TileLang's nvcc JIT compiles — fixed by upgrading the latter three to 13.3.x (`bin/04-fix-cuda-toolkit-skew.sh`); (5) the systemd unit had no `PATH`, so `ninja` (needed for JIT-compiled CUDA extensions) couldn't be found even though it was installed — fixed by adding `PATH=/data/vllm/.venv/bin:...` (`bin/05-fix-missing-venv-path.sh`); (6) `--attention-backend FLASHMLA_SPARSE_DSV4` has a confirmed, unconditional gap for `sm_120` GPUs (ours) in this vLLM build — its tile-scheduler builder intentionally returns all-`None` on SM120, but the FlashMLA decode path asserts on it anyway — fixed by switching to the SM120-aware sibling backend `FLASHINFER_MLA_SPARSE_DSV4`, which in turn needed `nvcc`'s directory added to `PATH` for FlashInfer's own capability probing (`bin/06-fix-attention-backend-sm120.sh`); (7) FlashInfer's JIT linker step failed with `cannot find -lcudart` because the pip-installed CUDA runtime wheel uses a `lib/` + versioned-only layout, not the classic toolkit's `lib64/` + unversioned-symlink layout FlashInfer's build script assumes — fixed with two symlinks (`lib64 -> lib`, `libcudart.so -> libcudart.so.13`) (`bin/07-fix-cudart-symlinks.sh`). All fix scripts live in `bin/` in this feature folder, numbered in the order they were created, each with a detailed root-cause comment header.)
- [ ] Task 1.4: `systemctl start` the service; curl smoke test against `/v1/chat/completions`, verify tool-calls and think/non-think output — depends on: Task 1.3 — status: blocked (2026-08-18: service starts and responds over HTTP with `finish_reason: length`, but generated output is degenerate garbage, not a crash. At temperature=1 output is token noise mixing many scripts/languages; at temperature=0 (greedy) every single decode position returns the exact same special token (`<|begin▁of▁sentence|>`) with the exact identical logprob (-11.7697...) regardless of position/context — a strong signature of a broken forward pass (e.g. sparse-attention decode returning zeroed/garbage context), not a sampling or tokenizer issue. Ruled out CUDA-graph capture as the cause via `--enforce-eager` (`bin/08-diag-enforce-eager.sh`): identical degenerate output with graphs fully disabled. Remaining suspects: the `FLASHINFER_MLA_SPARSE_DSV4` SM120 sparse-MLA decode kernel path (needed per Task 1.3 fix #6, since the alternative `FLASHMLA_SPARSE_DSV4` backend is unconditionally broken on our `sm_120` GPUs in this vLLM build) and/or the native FP4+FP8 mixed quantization fallback (needed per Task 1.3 fix #3) and/or missing fp8 kv-cache scaling factors (vLLM logs its own warning: "may cause accuracy drop without a proper scaling factor"). A true `--tensor-parallel-size 1` isolation test is infeasible: native-precision weights are ~152 GB total (38 GB/GPU × 4), which doesn't fit on one ~95 GB GPU. Needs upstream vLLM/FlashInfer investigation, a different vLLM/FlashInfer version, or a `--tensor-parallel-size 2` isolation test (feasible but weaker signal, not yet tried) before this can be unblocked. UPDATE 2026-08-18 evening: researched and verified (via direct GitHub fetches, not just an LLM research summary) several open upstream vLLM issues matching this hardware/model combo — vLLM #47528 (DeepSeek-V4-Pro garbled under TP, correct under DP+EP), #50720 (FlashInfer SM120 sparse-MLA decode dispatch bug, spec-decode-specific), #50773 (fuse_norm_quant/fuse_act_quant fusions garble output on SM120 for DeepSeek-V4-Flash). Ran `bin/09-diag-dp-ep.sh` to test the #47528 pattern: switched to `--data-parallel-size 4 --enable-expert-parallel` (same native FP4+FP8 mixed experts, same FLASHINFER_MLA_SPARSE_DSV4 backend, `--max-model-len` temporarily dropped to 8192 for a fast diagnostic). Result: **identical degenerate signature** (every decode position returns `<|begin▁of▁sentence|>` at logprob -11.769736289978027, byte-for-byte the same as under TP=4) — rules out #47528's TP-vs-DP+EP pattern as the cause here. Also ruled out #50773's fusion-pass theory without a separate test: the DP+EP run's own startup log showed "Inductor compilation was disabled by user settings, optimizations settings that are only active during inductor compilation will be ignored" immediately after "Enabled custom fusions: norm_quant, act_quant" — confirming those fusions are configured but never actually applied under `--enforce-eager`, which we'd already tested. Remaining live suspects: the `FLASHINFER_MLA_SPARSE_DSV4` decode kernel itself (independent of TP/DP+EP, since both parallelism strategies hit the same failure), missing FP8 KV-cache scaling factors, or a vLLM/FlashInfer version issue — vLLM 0.27.0/0.27.1 and flashinfer-python 0.6.16/0.6.17 postdate our 0.26.0/0.6.14 and contain real (verified) DeepSeek-V4 sparse-MLA-decode-adjacent fixes, though none confirmed to fix this exact signature. Diagnostic service is currently still running under the DP+EP/8192-context config from `bin/09-diag-dp-ep.sh`; not yet reverted. UPDATE 2026-08-18 late night: tried upgrading vLLM 0.26.0 → 0.27.1 and flashinfer-python 0.6.14 → 0.6.17 via `bin/10-upgrade-vllm-flashinfer.sh` (a much larger change than expected — vLLM 0.27.1 requires torch 2.13.0, pulling ~2GB of new/updated CUDA-toolkit wheels; pip also flagged flashinfer-python 0.6.17 as incompatible with vLLM 0.27.1's pinned `flashinfer-python==0.6.16.post3`, a risk accepted for the test). Result: **this upgrade path is a dead end on our hardware**, discovered via two consecutive deterministic crashes, both regressions vs. 0.26.0 (worse than the original bug — 0.26.0 at least served HTTP with degenerate output; 0.27.1 never got that far): (1) on first restart, `RuntimeError: Assertion error (deepgemm-src/csrc/apis/layout.hpp:60): Unknown SF transformation` in `deepgemm_post_process_weight_scale_block` during weight loading; (2) after trying the cheap `VLLM_USE_DEEP_GEMM=0` workaround (`bin/12-diag-disable-deepgemm.sh`), a *different* deterministic crash: `RuntimeError: Assertion error (deepgemm-src/csrc/apis/hyperconnection.hpp:56): Unsupported architecture`, raised from `tf32_hc_prenorm_gemm` while computing DeepSeek-V4's mHC (Manifold-Constrained Hyper-Connections) layers — this call path is unconditional and bypasses `VLLM_USE_DEEP_GEMM=0` entirely (that env var only affects the separate FP8 linear-layer scaled-mm path in `fp8.py`). Conclusion: vLLM 0.27.1's vendored DeepGEMM build does not support SM120 (RTX PRO 6000 Blackwell) for DeepSeek-V4's mHC kernels at all — a hard architecture gap, not a flag to work around. Rolled vLLM/flashinfer-python back to 0.26.0/0.6.14 via `bin/13-rollback-vllm-flashinfer.sh` (confirmed via `pip show`) and removed the now-irrelevant `VLLM_USE_DEEP_GEMM=0` env line via `bin/14-remove-deepgemm-env-and-retest.sh`, restoring the unit to its exact pre-upgrade baseline (TP=4, native FP4+FP8 mixed experts, `FLASHINFER_MLA_SPARSE_DSV4`, fp8 kv-cache, `--enforce-eager`, 8192-token diagnostic context) for retesting. This rules out the vLLM/flashinfer version-upgrade hypothesis entirely — remaining candidates are testing without `--kv-cache-dtype fp8`, or filing an upstream vLLM issue with our exact repro. UPDATE 2026-08-19T08:04:27Z: a structured unblock plan was folded in and scripted (`bin/16`-`bin/20`). Step 0 `bin/16-snapshot-baseline.sh` records the exact degenerate baseline (ExecStart, `pip freeze`, `nvidia-smi`, temp=0 response) to `bin/baselines/` for byte-exact comparison. Step 1 runs two parallel tracks: Track A `bin/17-diag-no-fp8-kvcache.sh` drops `--kv-cache-dtype fp8` (cheapest live suspect); Track B re-verifies the remaining SM120 sparse-MLA-decode-correctness signature against upstream and drafts (does NOT post) an issue if novel. If Track A yields coherent output, non-fp8 KV cache is adopted as the working fix (user decision 2026-08-19: test it; dig further only if quality/context is unacceptable) → `bin/20-restore-production-config.sh` restores `--max-model-len 370000` and drops the diagnostic `--enforce-eager`, then runs the real ACC-004 tool-call + think/non-think/max-think checks. If Track A still degenerate, Step 2 builds a clean side-by-side venv (`bin/18-build-clean-venv.sh`, leaving `/data/vllm/.venv` untouched) wired via `bin/19-diag-clean-venv-unit.sh` to rule out in-place-patch contamination; if that is still degenerate, the bug is genuinely vLLM 0.26.0's SM120 sparse-MLA decode path and the Track B upstream draft becomes the primary path. All scripts run on the Dell 7960T via `systemctl`; results feed the decision gates before any production restore. UPDATE 2026-08-19T09:1x-11:36Z: ran `bin/17` — Track A is now **ruled out definitively, not inconclusively**: dropping `--kv-cache-dtype fp8` makes every worker fail at model construction with `AssertionError: DeepseekV4 fp8_ds_mla layout only supports fp8 kv-cache, got auto` (`vllm/models/deepseek_v4/attention.py:83`). fp8 KV-cache is a hard architectural requirement of the `fp8_ds_mla` layout used by `FLASHINFER_MLA_SPARSE_DSV4` on this vLLM build, not a tunable precision knob — the "missing fp8 kv-cache scaling factors" hypothesis cannot be isolated via this backend at all. `bin/17` has no auto-revert, so the unit crash-looped (7+ restarts) until `bin/21-revert-fp8-kvcache-crashloop.sh` restored `--kv-cache-dtype fp8` and confirmed the service is back to the exact frozen degenerate baseline. Remaining live candidates: the `FLASHINFER_MLA_SPARSE_DSV4` SM120 sparse-MLA decode kernel itself, or in-place-patch contamination in `.venv` — next up is `bin/18`/`bin/19`'s clean side-by-side venv test. UPDATE 2026-08-19 (bin/18/bin/19 result + upstream posted): the clean side-by-side venv (rebuilt from scratch, verified package-by-package against production on every dependency close to the compute path) reproduces the **exact same byte-for-byte degenerate signature** — environment/in-place-patch contamination is now ruled out too, alongside Track A. Both local hypotheses exhausted; escalated to upstream: **filed https://github.com/vllm-project/vllm/issues/52938**, with a fresh dedup pass (checked #47528, #50720, #50773, #47783/#47493 — confirmed that fix is already present in our installed 0.26.0 via source inspection, so not our cause — and #47266) confirming this exact non-crashing frozen-token/frozen-logprob signature is novel. Awaiting upstream response; Task 1.4 remains blocked in the meantime.)
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

**As of 2026-08-19 (end of session)**: Phase 0 complete (Task 0.7 Pro
download finished — all 64 shards at
`/data/nvidia/hf_cache/hub/models--deepseek-ai--DeepSeek-V4-Pro`). Phase 1:
Task 1.3 (systemd service) complete after a 7-bug crash-loop debugging
session. **Task 1.4 remains blocked** on a model-output correctness bug
(identical argmax token + identical logprob at every decode position,
temperature=0) — every locally-testable hypothesis has now been
systematically ruled out: CUDA-graph capture, the TP-vs-DP+EP execution
path, torch.compile fusion passes, a stale vLLM/flashinfer version
(0.27.1/0.6.17 hits an unrelated hard SM120/DeepGEMM gap), fp8 KV-cache
scaling factors (fp8 KV-cache is architecturally required by this vLLM
build's `fp8_ds_mla` layout, not tunable), and environment/in-place-patch
contamination (a from-scratch clean venv, verified package-by-package
against production, reproduces the identical byte-for-byte signature). All
local diagnostics exhausted; **escalated upstream** — filed
https://github.com/vllm-project/vllm/issues/52938 after a fresh dedup pass
against the closest known issues, none of which match this exact
non-crashing frozen-token signature. Both the diagnostic clean-venv
service and the production service are currently **stopped** (idle GPUs,
no leftover processes) pending upstream response or a decision on next
steps (alternate vLLM/flashinfer version, or pivot to Phase 2). Phase 2
(Pro/ktransformers) is fully unblocked (Task 0.7 done) but not yet started.

### Next Steps

1. ~~Execute the Task 1.4 unblock plan (`bin/16`-`bin/20`)~~ — **COMPLETE**,
   both local hypotheses ruled out:
   1. ~~`bin/16-snapshot-baseline.sh`~~ — DONE (2026-08-19T09:10:23Z): baseline
      captured to `bin/baselines/2026-08-19T09:10:23Z-degenerate.txt`,
      confirmed byte-for-byte matching the known degenerate signature
      (`<｜begin▁of▁sentence｜>` at logprob `-11.769736289978027` for all 10
      positions).
   2. ~~Track A: `bin/17-diag-no-fp8-kvcache.sh`~~ — RULED OUT
      (2026-08-19T09:1x-11:36Z): fp8 KV-cache is a hard architectural
      requirement of the `fp8_ds_mla` attention layout used by
      `FLASHINFER_MLA_SPARSE_DSV4` on this vLLM build, not a tunable
      precision knob — confirmed via a hard `AssertionError` at model-init,
      not an inconclusive test. See Task 1.4 note for the crash-loop/revert
      detail (`bin/21-revert-fp8-kvcache-crashloop.sh`).
   3. ~~`bin/18-build-clean-venv.sh` + `bin/19-diag-clean-venv-unit.sh`~~ —
      RULED OUT (2026-08-19): a from-scratch clean venv, verified
      package-by-package against production on every dependency close to
      the compute path, reproduces the exact same byte-for-byte degenerate
      signature. Environment/in-place-patch contamination is not the cause.
   4. ~~Track B: upstream issue~~ — **ESCALATED AND POSTED** (2026-08-19,
      supersedes the earlier draft-only decision): with both local
      hypotheses exhausted, filed
      **https://github.com/vllm-project/vllm/issues/52938** after a fresh
      dedup pass (checked #47528, #50720, #50773, #47783/#47493 — verified
      its fix is already present in our installed 0.26.0 via direct source
      inspection — and #47266).
2. **Awaiting upstream response on
   https://github.com/vllm-project/vllm/issues/52938.** In parallel,
   options to consider with the user: (a) try a different vLLM/flashinfer
   version pairing (0.27.1/0.6.17 already ruled out — hard SM120/DeepGEMM
   mHC gap — but nothing between 0.26.0 and 0.27.1, or after 0.27.1, is
   explored); (b) pivot effort to Phase 2 (Pro/ktransformers, fully
   unblocked since Task 0.7) while this stays escalated upstream, rather
   than continuing to sink time into Flash locally.
3. Once Task 1.4 is actually unblocked (upstream fix, workaround, or a
   version bump that resolves it), `bin/20-restore-production-config.sh`
   restores `--max-model-len 370000` (currently 8192 for fast diagnostics)
   and removes the diagnostic `--enforce-eager` before proceeding to
   Task 1.5+.
4. Task 0.7 (Pro download) complete — no further monitoring needed.
5. ~~Diagnostic cleanup~~ — DONE: both
   `vllm-deepseek-v4-flash-clean.service` and the production
   `vllm-deepseek-v4-flash.service` are stopped (confirmed via
   `systemctl show` — both `inactive`/`dead`), all 4 GPUs are idle (0-10 MiB
   used), no leftover `VLLM::` processes. **Left deliberately idle** —
   production is not currently running; whoever picks this up next should
   decide whether to restart it (e.g. to keep smoke-testing while waiting
   on upstream) or leave it stopped until #52938 gets a response or a new
   diagnostic is ready to try. `/data/vllm/.venv-clean` and the
   `...-clean.service` unit are both still present on disk for potential
   reuse in a future diagnostic — not deleted.

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
  see Task 1.4 note — and was rolled back to 0.26.0/0.6.14), and missing
  FP8 KV-cache scaling factors (dropping `--kv-cache-dtype fp8` doesn't
  give a usable A/B test — it hard-asserts at model init, since fp8
  KV-cache is a required part of the `fp8_ds_mla` attention layout on this
  vLLM build, not a tunable knob; see Task 1.4 note), and now also
  environment/in-place-patch contamination (a from-scratch clean
  side-by-side venv, verified package-by-package against production,
  reproduces the exact same byte-for-byte degenerate signature — see Task
  1.4 note). All local hypotheses exhausted. Escalated upstream: filed
  **https://github.com/vllm-project/vllm/issues/52938** — awaiting
  response. Next action: monitor the upstream issue; consider a different
  vLLM/flashinfer version pairing, or reassess whether to keep debugging
  Flash on vLLM vs. pivoting effort to Phase 2 in the meantime. Cross-feature
  signal (2026-08-19, see Recent Updates): `feat-2`'s `llama.cpp`/GLM-5.2
  Phase 1 spike produced coherent (non-degenerate) sparse-attention decode
  output on these same SM120 GPUs — supporting evidence this is a
  vLLM/FlashInfer-specific implementation bug, not an SM120-hardware
  limitation; worth adding to #52938 as a comment.
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

#### 2026-08-19T08:04:27Z (Task 1.4 unblock plan folded in + scripted)

- Decided: keep this work inside `feat-1` (do NOT open a new feature) — it
  is the in-flight remediation of the existing, `blocked` Task 1.4 (serves
  ACC-001/004/005, no new REQ), and continues the unbroken `bin/00`-`bin/15`
  forensic runbook per the repo's single-source-of-truth + edit-in-place
  conventions.
- Completed: authored and staged the unblock plan as five numbered scripts
  (not yet run — they execute on the Dell 7960T via `systemctl`):
  - `bin/16-snapshot-baseline.sh` — Step 0, read-only capture of the exact
    degenerate baseline (ExecStart, `pip freeze`, `nvidia-smi`, temp=0
    response) to `bin/baselines/<ISO8601>-degenerate.txt` for byte-exact
    comparison across experiments.
  - `bin/17-diag-no-fp8-kvcache.sh` — Step 1 / Track A, drops
    `--kv-cache-dtype fp8` (cheapest remaining live suspect) and re-tests.
  - `bin/18-build-clean-venv.sh` — Step 2 fallback, builds a pristine
    `/data/vllm/.venv-clean` at the same pinned vLLM 0.26.0 /
    flashinfer 0.6.14 with the hard-won Task 1.3 fixes (#4 CUDA-line match,
    #7 cudart symlinks) baked in; leaves the existing `.venv` untouched.
  - `bin/19-diag-clean-venv-unit.sh` — wires a copy of the unit
    (`...-flash-clean.service`) at the clean venv to isolate in-place-patch
    contamination without disturbing the baseline service.
  - `bin/20-restore-production-config.sh` — Step 3, restores
    `--max-model-len 370000` and removes the diagnostic `--enforce-eager`,
    then runs the real ACC-004 tool-call + reasoning-mode checks. Run only
    after a diagnostic produces coherent output.
- Decided: Track B (upstream) is re-verify + draft only — no issue is posted
  (user instruction 2026-08-19). Draft written to
  `bin/upstream-issue-draft.md` with a "why this is not a duplicate of
  #47528/#50720/#50773" section and `<FILL FROM DELL BOX>` placeholders for
  the env/ExecStart/response fields that `bin/16` captures; must pass a
  dedup search before posting.
- Decided: if Track A yields coherent output, non-fp8 KV cache is adopted as
  the working fix and we proceed; dig further only if quality/context proves
  unacceptable (user instruction 2026-08-19). Trade-off recorded: non-fp8 KV
  cache roughly doubles KV memory, so Task 1.6's 350-370K context headroom
  must be re-checked at restore time. **SUPERSEDED 2026-08-19T09:1x-11:36Z**:
  this decision's premise doesn't hold — dropping `--kv-cache-dtype fp8` is
  not a viable config at all on this vLLM build (hard assertion at model
  init, not a runtime behavior to A/B test), so non-fp8 KV cache is not an
  available option for `FLASHINFER_MLA_SPARSE_DSV4`/`fp8_ds_mla`. See Task
  1.4 note.
- Next: run `bin/16` → `bin/17` (+ Track B) on the Dell 7960T; drive the
  decision gates from the diffs vs the frozen baseline.

#### 2026-08-19T09:10:23Z (bin/16 baseline snapshot executed)

- Completed: ran `bin/16-snapshot-baseline.sh` on the Dell 7960T. Wrote
  `bin/baselines/2026-08-19T09:10:23Z-degenerate.txt` capturing the live
  `ExecStart`, environment, `pip freeze`, `nvidia-smi`, and a temperature=0
  smoke test.
- Found: snapshot reconfirms the exact known degenerate signature —
  temperature=0, 10 requested tokens, every position returns
  `<｜begin▁of▁sentence｜>` at `logprob=-11.769736289978027`, byte-for-byte
  identical to the original bug, the DP+EP test, and the post-rollback
  reproduction. No drift since the last confirmation.
- Next: run `bin/17-diag-no-fp8-kvcache.sh` (Track A — drop
  `--kv-cache-dtype fp8`, restart, re-snapshot, diff vs this baseline) and,
  in parallel, Track B's upstream re-verify/draft.

#### 2026-08-19T09:1x-11:36Z (Track A ruled out — fp8 KV-cache is hard-required, not tunable)

- Completed: ran `bin/17-diag-no-fp8-kvcache.sh` on the Dell 7960T (dropped
  `--kv-cache-dtype fp8`). Ran `bin/16-snapshot-baseline.sh` again
  immediately after to check the result — it reported `(curl failed -- is
  the service up?)` and captured `nvidia-smi` showing all 4 GPUs at ~2 MiB
  used, i.e. the service was not holding the model at all at snapshot time.
- Found: `journalctl` shows every worker (`Worker_TP1`/`TP3`, etc.) failing
  at model construction with `AssertionError: DeepseekV4 fp8_ds_mla layout
  only supports fp8 kv-cache, got auto`, raised from
  `vllm/models/deepseek_v4/attention.py:83`
  (`_resolve_dsv4_kv_cache_dtype`), called from
  `nvidia/flashinfer_sparse.py:578`. **fp8 KV-cache is a hard architectural
  requirement of the `fp8_ds_mla` attention layout used by
  `--attention-backend FLASHINFER_MLA_SPARSE_DSV4` on this vLLM build, not
  a tunable precision knob** — the model never reaches inference without
  it, so Track A's hypothesis ("fp8 kv-cache scaling factors cause the
  degenerate output") cannot be isolated via this backend at all. This is
  a definitive, code-level ruling-out, not an inconclusive test.
- Found: because `bin/17` has no auto-revert and the unit's
  `Restart=on-failure`/`RestartSec=10` kept retrying the now-permanently-
  broken config, the service was stuck in an infinite crash loop (7+
  restarts observed) burning CPU and filling the journal until manually
  reverted.
- Completed: authored and ran `bin/21-revert-fp8-kvcache-crashloop.sh` —
  stops the crash loop, kills leftover `VLLM::` processes, restores
  `--kv-cache-dtype fp8` to its original `ExecStart` position, reloads
  systemd, restarts, polls for the API, and re-runs the temperature=0 smoke
  test. Confirmed the service is back up (`NRestarts=0` after the clean
  restart, `/health` returns 200) and **byte-identical to the frozen
  baseline** (`<｜begin▁of▁sentence｜>` at `logprob=-11.769736289978027`
  for all 10 positions) — the known-bad-but-stable state is restored.
- Decided: Track A is closed. Remaining live candidates for Task 1.4:
  the `FLASHINFER_MLA_SPARSE_DSV4` SM120 sparse-MLA decode kernel itself,
  or in-place-patch contamination in the existing `.venv` (accumulated
  fixes from Task 1.3/bin/00-15 and this session's edits). Track B
  (upstream re-verify + draft-only issue) remains open independently.
- Next: run `bin/18-build-clean-venv.sh` + `bin/19-diag-clean-venv-unit.sh`
  (clean side-by-side venv, original `.venv` untouched) to rule out
  in-place-patch contamination.
- Note: `bin/21` originally used a blocking `systemctl start` on this
  `Type=notify` unit (`TimeoutStartSec=3600`) — vLLM was observed serving
  real HTTP traffic successfully while systemd still reported
  `ActiveState=activating` (it does not appear to send `READY=1` promptly,
  if at all, under `--enforce-eager`), making the script look hung when the
  service was actually fine. Fixed by switching to `systemctl start
  --no-block` and driving the wait entirely off the actual HTTP `/health`
  endpoint instead of systemd's `ActiveState`.
- Completed: authored `bin/22-verify-against-baseline.sh` — a read-only,
  no-sudo smoke test that hits `/v1/chat/completions` and automatically
  parses the response's `token`/`logprob` fields to give a plain verdict
  (matches frozen baseline / same-class-different-value / possibly fixed /
  no logprobs found) instead of requiring a manual JSON diff.
- Completed: ran `bin/22-verify-against-baseline.sh` twice (once from this
  session, once independently by the user) — **both confirm the service
  still matches the frozen degenerate baseline exactly** (20/20 logprob
  values identical at `-11.769736289978027`, single repeated token
  `<｜begin▁of▁sentence｜>`). Service is stable, Track A is fully closed,
  ready to proceed to `bin/18`/`bin/19`.

#### 2026-08-19 (bin/18 clean-venv build started; production service stopped early)

- Started: `bin/18-build-clean-venv.sh` on the Dell 7960T — builds
  `/data/vllm/.venv-clean` at the same pinned vLLM 0.26.0/flashinfer-python
  0.6.14, with Task 1.3 fixes #4 (CUDA-toolkit line pin) and #7 (cudart
  symlinks) baked in from the start. Purely a CPU/disk operation (venv
  creation + `pip install`), no GPU or systemd interaction, so it's safe to
  run concurrently with anything else.
- Noted: `uv venv` printed a warning that the resolved Python 3.12.13
  "is incompatible with the project's Python requirement: `>=3.13`" —
  harmless. That requirement comes from this repo's own placeholder
  `pyproject.toml` (`biz-dfch-llmops`, unrelated to the deployment); `uv`
  still honored the script's explicit `--python 3.12` and created the venv
  correctly at 3.12.13, matching the production venv's Python version.
- Completed: stopped `vllm-deepseek-v4-flash.service` early (ahead of
  `bin/19`, which would have stopped it anyway) to free GPU VRAM while
  `bin/18`'s `pip install vllm==0.26.0 flashinfer-python==0.6.14` was still
  running in the background. Confirmed via `nvidia-smi`: all 4 GPUs back to
  ~2-10 MiB used / ~97.3 GB free (down from ~90.6 GB used each), service
  `ActiveState=inactive`, no leftover `VLLM::` processes.
- Next: wait for `bin/18`'s pip install to finish, verify the printed
  `pip freeze` shows the expected pinned versions, then run
  `bin/19-diag-clean-venv-unit.sh` (needs `sudo`) to wire the clean venv
  into a parallel `vllm-deepseek-v4-flash-clean.service` unit.

#### 2026-08-19 (bin/18 finished with two real bugs found and fixed before use)

- Found: `bin/18`'s own Step 5 (CUDA-toolkit line pin) **silently failed**
  with `ERROR: Could not find a version that satisfies the requirement
  nvidia-cuda-nvcc-cu13~=13.3.0` — a package-naming bug in the script
  itself (spurious `-cu13` suffix; the real PyPI package names have none).
  As a result the exact skew this step exists to prevent (Task 1.3 fix #4 /
  bin/15) was reproduced in the "clean" venv: `nvidia-cuda-nvcc`/`-crt`/
  `-cccl` resolved to `13.3.x` (pulled in transitively by vllm/flashinfer)
  while `nvidia-cuda-runtime`/`-nvrtc`/`-cupti` stayed on a stale `13.0.x`
  line.
- Fixed: reinstalled the correct package names at the exact versions from
  the confirmed-working production baseline (`nvidia-cuda-runtime==13.3.29`,
  `nvidia-cuda-nvrtc==13.3.33`, `nvidia-cuda-cupti==13.3.75`) directly into
  `/data/vllm/.venv-clean`, then corrected `bin/18` itself (exact-version
  pins for all six wheels, not just the buggy `-cu13`-suffixed `~=` pattern)
  so a future rebuild doesn't reproduce this.
- Found: a second, independent bug in `bin/18`'s Step 6 (cudart symlinks,
  Task 1.3 fix #7 / bin/07) — it created a useless self-referential
  `cu13/lib/lib64 -> .` (inside `lib/`, pointing at itself) instead of the
  actual working fix's `cu13/lib64 -> lib` (a sibling-level symlink
  pointing at the `lib` directory). FlashInfer's JIT linker resolves
  `cuda_home` as `dirname(dirname(which nvcc))` == `cu13`, then links
  `-L$cuda_home/lib64 -lcudart` — without `cu13/lib64` existing at that
  level, this silently reproduces the original `cannot find -lcudart`
  bin/07 bug.
- Fixed: removed the incorrect self-link, created the correct
  `cu13/lib64 -> lib` symlink directly in `.venv-clean`, verified
  `cu13/lib64/libcudart.so` now resolves through to
  `cu13/lib/libcudart.so.13` (confirmed via `readlink -f`). Corrected
  `bin/18`'s Step 6 to match `bin/07`'s exact layout for future rebuilds.
- Checked: `tilelang==0.1.9` (needed for DeepSeek-V4's mHC layers per Task
  1.3) IS present in the clean venv — an earlier quick pip-freeze diff
  looked like it was missing, but that was only because the grep filter
  used didn't include the string `tilelang`; it was never actually absent.
- Checked and accepted as low-risk: `torchaudio`/`torchcodec` resolved to
  slightly different build tags/versions than production
  (`torchaudio==2.11.0` vs `2.11.0+cu130`; `torchcodec==0.16.0` vs
  `0.15.0+cu130`). No `--extra-index-url` is recorded in any setup script
  for either venv, and `journalctl` shows neither package is ever imported
  while the service actually serves this text-only model — treated as
  incidental pip-resolution drift, not a functional difference, and not
  chased further absent evidence it matters.
- Completed: final `pip freeze` diff between `.venv-clean` and `.venv`
  shows only the accepted `torchaudio`/`torchcodec` tag difference — vLLM,
  flashinfer, tilelang, and all six `nvidia-cuda-*` wheels now match
  exactly, and the cudart symlink structure matches `bin/07`'s fix
  byte-for-byte. The clean venv is now genuinely equivalent to production
  except for the code/environment history being tested (fresh vs.
  patched-in-place) — ready for `bin/19`.
- Next: run `bin/19-diag-clean-venv-unit.sh` (needs `sudo`) to wire
  `.venv-clean` into a parallel `vllm-deepseek-v4-flash-clean.service`
  unit, then start it with `--no-block` and verify with
  `bin/22-verify-against-baseline.sh`.

#### 2026-08-19 (bin/19 run; clean-venv service crashed with THREE more environment gaps found and fixed)

- Completed: ran `bin/19-diag-clean-venv-unit.sh` — created
  `vllm-deepseek-v4-flash-clean.service` pointed at `.venv-clean`,
  production service already stopped.
- Found (crash #1, fatal): starting the clean unit crashed immediately with
  `ModuleNotFoundError` / `ImportError: The 'fastokens' package (>= 0.2.0)
  is required when VLLM_USE_FASTOKENS=1` — the unit's env var was copied
  verbatim from production by `bin/19`, but `bin/18` never installed
  `fastokens` (it's not pulled in by vllm/flashinfer's own metadata; must
  have been added by hand at some point in the Task 1.3 crash-loop
  history). Crash happens at tokenizer/renderer construction, well before
  model load -- no signal on Task 1.4's actual bug, just a missing
  package. Fixed: installed `fastokens==0.3.1` (matching production)
  directly into `.venv-clean`.
- Found (risk #2, silent — would not have crashed, but could have
  invalidated the test): a full `pip freeze` diff (not just the
  vllm/flashinfer/CUDA-filtered one from the earlier check) turned up ~25
  more version differences. Nearly all are incidental drift in
  HTTP/serving/client-library packages with no plausible connection to
  model math (anthropic, openai, starlette, uvicorn, httpx2/httpcore2,
  huggingface_hub, idna, charset-normalizer, filelock, pydantic-settings,
  Pygments, python-dotenv, python-json-logger, sentry-sdk, tiktoken,
  typing-inspection) — not pinned by the install command, so pip resolved
  whatever was newest at each install time. Two stood out as close enough
  to the compute path to control for: `transformers` (5.15.0 vs.
  production's 5.14.1 — directly patched by `fastokens`, whose log line
  explicitly names "v5.14.1") and `quack-kernels` (0.6.3 vs. 0.6.1 —
  confirmed `Required-by: vllm`, an actual CUDA-kernel dependency, not a
  bystander). Pinned both to match production exactly.
- Found (risk #3, self-inflicted by fixing #2): installing
  `quack-kernels==0.6.1` **reintroduced the CUDA-toolkit-line skew**
  (`nvidia-cuda-runtime`/`-nvrtc`/`-cupti` pulled back down to 13.0.x by
  quack-kernels' own dependency resolution) — the same skew pattern this
  deployment has now hit four times (Task 1.3 fix #4, bin/15, the earlier
  bin/18 fix this session, and now this). Re-pinned the three wheels back
  to 13.3.x; confirmed the `cu13/lib64 -> lib` symlink survived the churn.
- Checked one more near-compute-path candidate: `ml_dtypes` (0.6.0 vs.
  production's 0.5.4) is `Required-by: tilelang`, which runs live JIT
  kernels for DeepSeek-V4's mHC layers during inference — close enough to
  pin exactly rather than assume it doesn't matter. Confirmed `nccl4py`
  (also differing) is a genuine orphan in production (`Required-by:`
  empty, never imported per `journalctl`) — safe to leave undiffed.
  Confirmed `cuda-bindings`/`cuda-core`/`cuda-python`/`humming-kernels`
  (all real vllm/torch dependencies, not orphans) already matched exactly
  between both venvs with no action needed.
- Completed: final full `pip freeze` diff now contains only the
  already-vetted, confirmed-irrelevant packages. Fixed `bin/18` itself to
  install `fastokens`/`transformers`/`quack-kernels`/`ml_dtypes` (in that
  order, BEFORE the CUDA-toolkit pin step, since installing
  `quack-kernels` after the pin re-triggers the skew) so a future rebuild
  doesn't have to rediscover any of this.
- Next: restart `vllm-deepseek-v4-flash-clean.service` with
  `systemctl start --no-block` and check with
  `bin/22-verify-against-baseline.sh` (pointed at the same port, works
  unmodified against either unit) whether the clean venv still reproduces
  Task 1.4's degenerate signature.

#### 2026-08-19T13:2xZ (bin/19 clean-venv test result: environment contamination RULED OUT)

- Note: on the first `systemctl start` attempt, the *production* unit
  (`vllm-deepseek-v4-flash.service`) was started by mistake instead of the
  clean-venv unit (`...-clean.service`) — an easy mix-up given the
  near-identical names. Caught via `systemctl list-jobs` /
  `systemctl status` showing the wrong unit's PID and GPU memory climbing
  under `.venv` rather than `.venv-clean`. Corrected: stopped production,
  killed leftover `VLLM::` processes, started
  `vllm-deepseek-v4-flash-clean.service` (with `--no-block`, per the
  `bin/21` lesson) instead.
- Completed: `vllm-deepseek-v4-flash-clean.service` started successfully
  this time — `[fastokens] patch_transformers: successfully patched
  transformers v5.14.1` confirms the `bin/19` crash's root cause (missing
  `fastokens`) is fixed. Engine initialized with matching config
  (`kv_cache_dtype=fp8`, `tensor_parallel_size=4`,
  `quantization=deepseek_v4_fp8`, etc.), FlashInfer SM120 sparse-MLA-decode
  autotuning completed normally (same warmup pattern as every successful
  production start), all 4 GPUs loaded (~87 GB each), `/health` returned
  200 after ~70s.
- **Result: `bin/22-verify-against-baseline.sh` shows the clean venv is
  BYTE-FOR-BYTE IDENTICAL to the frozen degenerate baseline** — same
  single repeated token `<｜begin▁of▁sentence｜>`, same logprob
  `-11.769736289978027` at all 10 decode positions, same
  `system_fingerprint`. This is on a venv independently verified,
  package-by-package, to match production on every dependency remotely
  close to the compute path (vLLM, flashinfer, transformers,
  quack-kernels, ml_dtypes, tilelang, fastokens, all 6
  `nvidia-cuda-*` wheels, the cudart symlink structure) — the only
  unresolved differences are HTTP/serving/client-library packages
  confirmed never imported at runtime.
- **Decided: environment / in-place-patch contamination in `/data/vllm/.venv`
  is RULED OUT as the cause of Task 1.4's bug.** Per the `bin/19` decision
  gate, this means the bug is genuinely in vLLM 0.26.0's
  `FLASHINFER_MLA_SPARSE_DSV4` SM120 sparse-MLA decode path for this model
  on this hardware, not an artifact of the accumulated patch history from
  the Task 1.3 crash-loop debugging sessions.
- Both Track A (fp8 KV-cache is architecturally required, not tunable) and
  the environment-contamination hypothesis are now closed. Remaining live
  paths: (1) escalate the Track B upstream-issue draft
  (`bin/upstream-issue-draft.md`) as the primary route — still draft-only
  per user instruction, needs a fresh dedup pass given time elapsed; (2) a
  different vLLM/flashinfer version pairing (0.27.1/0.6.17 already ruled
  out — hard SM120/DeepGEMM mHC gap, see the vLLM-upgrade note above —
  but a version between 0.26.0 and 0.27.1, or a release after 0.27.1, is
  unexplored); (3) reassess with the user whether to keep debugging Flash
  on vLLM at all, or pivot effort to Phase 2 (Pro/ktransformers, unblocked
  since Task 0.7) while this is escalated upstream.
- Next: clean up the diagnostic clean-venv service/unit, restore the
  production service, and reassess the path forward with the user (Track B
  escalation vs. version exploration vs. Phase 2 pivot).

#### 2026-08-19 (Track B escalated: upstream vLLM issue posted)

- Decided (user instruction): escalate Track B now — post the upstream
  issue rather than continue local diagnosis, since both local hypotheses
  (fp8 KV-cache, environment contamination) are exhausted.
- Completed: ran a fresh dedup pass via `gh` (the repo access token was
  already configured) before posting, per the draft's own checklist —
  `gh issue list --search` (not `gh search`, unsupported in this `gh`
  version) against `vllm-project/vllm` for multiple keyword variants
  (`FLASHINFER_MLA_SPARSE_DSV4`, `SM120 degenerate`, `identical logprob
  every position`, `DeepSeek-V4-Flash RTX PRO 6000 Blackwell`, etc.).
  Found and read in full: #47528, #50720, #50773 (all already known from
  the original draft), plus two newly surfaced candidates:
  - **#47783 / #47493**: a packed-KV-cache `stride(0)` addressing bug in
    the `FLASHINFER_MLA_SPARSE_DSV4` decode kernel (cache-store honors the
    packed block stride, the decode kernel doesn't, so tokens in block ≥1
    read from the wrong offset). **Checked our installed vLLM 0.26.0
    source directly** (`grep` for `_remap_flashinfer_index`,
    `_packed_block_span`, `alignment=576 if uses_fp8_ds_mla_layout`) and
    confirmed **the fix is already present** — consistent with #47493
    merging 2026-07-08, three weeks before the 0.26.0 tag (2026-07-27).
    Ruled out as our cause, with code-level evidence, not just a version
    heuristic.
  - **#50720**: SM120 sparse-MLA decode dispatch table missing a
    `(num_heads, topk=256)` entry for DSpark's `dspark_markov_rank=256`
    draft attention. Read the full 10-comment thread — this is a **hard
    crash at warmup** (`Check failed: num_tokens > 64`), strictly tied to
    **speculative decoding** (DSpark). We run no `--speculative-config` at
    all, and our server starts and serves successfully (a correctness bug,
    not a crash) — confirmed not applicable.
  - Also checked **#47266** ("Comprehensive Issues Report" for vLLM 0.24.0
    on this exact SM120/RTX PRO 6000 hardware, 13 cataloged issues) — its
    "Issue 2" is the *exact* `fp8_ds_mla`/`kv-cache-dtype auto` assertion
    we independently hit via Track A, good corroboration — but none of
    its 13 issues describe our non-crashing frozen-token signature.
  - Conclusion: our exact symptom (non-crashing service; identical argmax
    token AND identical logprob to 15 decimal places at every decode
    position, reproducing under TP and DP+EP alike, confirmed independent
    of environment contamination via the from-scratch clean-venv test) is
    genuinely novel across everything found.
- Completed: rewrote the draft with real data (this session's exact
  `collect_env` output, full `ExecStart`, verbatim JSON response, all six
  `nvidia-cuda-*` wheel versions) replacing every `<FILL FROM DELL BOX>`
  placeholder, added the two newly-checked issues to the "why not a
  duplicate" section, and folded in the clean-venv-contamination-ruled-out
  finding as a distinguishing, hard-to-dismiss piece of evidence most
  reports in this space don't have.
- Completed: **posted the issue** — https://github.com/vllm-project/vllm/issues/52938
  ("[Bug]: DeepSeek-V4-Flash on RTX PRO 6000 Blackwell (SM120) emits
  degenerate output — identical argmax token + identical logprob at every
  decode position, TP and DP+EP alike, confirmed independent of
  environment/install history (FLASHINFER_MLA_SPARSE_DSV4)"), via `gh
  issue create` (an already-authenticated `gh` CLI was available in this
  environment). **This supersedes the earlier "draft-only, do not post"
  decisions** recorded on 2026-08-19T08:04:27Z and 2026-08-19T09:1x-11:36Z
  — Track B is no longer draft-only.
- Next: continue with cleanup (restore production service, tear down the
  diagnostic clean-venv unit) and reassess Task 1.4's path forward — wait
  on upstream response to #52938, try a different vLLM/flashinfer version
  pairing, or pivot effort to Phase 2 (Pro/ktransformers) in the meantime.

#### 2026-08-19 (cross-feature signal from feat-2: llama.cpp unaffected on same SM120 hardware)

- Found (via `feat-2-glm-5.2-onprem-deployment`'s Phase 1 SM120 spike,
  Task 1.2): `llama.cpp` (fresh CUDA build, commit `ee4c505a4`) serving
  GLM-5.2 (`UD-IQ1_S` quant) on these exact same 4 RTX Pro 6000 Blackwell
  (SM120) GPUs produced **coherent, non-degenerate output** at
  temperature=0 — grammatical chain-of-thought reasoning tokens with
  naturally varying logprobs, not a single frozen token/logprob repeated
  at every decode position. Different engine, different model, but the
  same general class of kernel (DeepSeek Sparse Attention / sparse-MLA
  decode) that produces the degenerate signature here under vLLM's
  `FLASHINFER_MLA_SPARSE_DSV4` backend.
- Implication: this is a second, independent data point (beyond this
  feature's own exhausted local diagnostics — CUDA graphs, TP-vs-DP+EP,
  torch.compile fusions, fp8 KV-cache, environment/in-place-patch
  contamination, all ruled out) supporting the theory that Task 1.4's bug
  is specific to vLLM/FlashInfer's SM120 sparse-attention decode
  implementation, not a fundamental SM120-hardware limitation on
  sparse-attention/DSA decode in general. Worth adding as a comment on
  upstream issue #52938 — "a different engine's GGUF/CUDA sparse-attention
  decode path works correctly on the identical GPUs" is exactly the kind
  of corroborating evidence that distinguishes "vLLM-specific bug" from
  "SM120 is broken for this kernel class," and may help prioritize/route
  the upstream response.
- Not yet done: actually posting this as a follow-up comment on #52938 —
  flagged here for whoever picks this up next, not executed automatically.
- Completed: drafted (NOT posted, user instruction) a candidate follow-up
  comment, kept at
  `../feat-2-glm-5.2-onprem-deployment/followup-comment-draft.md` (lives in
  `feat-2` since that's where the underlying evidence/test was produced;
  cross-referenced here rather than duplicated). Explicitly hedges that
  this is corroborating, not conclusive, evidence — different model,
  different quantization, and critically a different attention kernel
  implementation (`llama.cpp`'s own DSA CUDA kernels vs. FlashInfer's
  `fp8_ds_mla` fused layout) — so it's offered as a data point, not a
  reproduction.
- Next: consider adding this finding as a comment on
  https://github.com/vllm-project/vllm/issues/52938 (draft ready in
  `feat-2`'s `followup-comment-draft.md`); otherwise unchanged — still
  awaiting upstream response, version-pairing exploration, or a Phase 2
  pivot decision.

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
- **2026-08-19**: GLM-5.2 confirmed real on Hugging Face
  (`zai-org/GLM-5.2`, MIT, 753B BF16, arch tag `glm_moe_dsa` = MoE +
  DeepSeek Sparse Attention). Two caveats recorded for the future GLM-5.2
  feature: (1) at 753B BF16 (~1.5 TB) it does NOT fit in 384 GB VRAM, nor
  in the 896 GB VRAM+RAM pool at native precision — it is a Pro-class
  quantized + GPU/CPU-hybrid (ktransformers) deployment, not a Flash-class
  VRAM-only one; (2) its DSA sparse-attention decode path is the same
  *class* of kernel currently breaking Task 1.4 on SM120, so a GLM-5.2
  pivot does NOT automatically escape the SM120 sparse-attention risk.
  Vendor lists vLLM v0.23.0+, SGLang v0.5.13.post1+, KTransformers
  v0.5.12+ as supported engines; SGLang is a genuinely distinct SM120
  code path worth testing as a shared unblock for both models.
- **2026-08-19**: REQ-006 relaxation scoped to GLM-5.2 ONLY. User accepts
  GGUF requant for the future GLM-5.2 feature (no native sub-BF16
  checkpoint exists that fits this hardware, so "no requant" = "can't run
  it here at all"). DeepSeek-V4 in this feature stays native-weights-only
  — REQ-006/ACC-006 remain unchanged and strict. This decision is
  recorded here for carry-over; it is applied when the GLM-5.2 feature is
  created, not retroactively to feat-1.
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
- **2026-08-19T08:04:27Z**: Keep the Task 1.4 unblock work inside `feat-1`
  rather than opening a new feature — it is in-flight remediation of the
  existing `blocked` Task 1.4, adds no new REQ/ACC, and continues the
  `bin/00`-`bin/15` runbook (repo convention: single source of truth per
  feature, edit tasks in place, recover history via `git log -p`).
- **2026-08-19T08:04:27Z**: Task 1.4 next-step order fixed as fp8-kv-cache
  test (Track A, cheapest) in parallel with an upstream re-verify; upstream
  issue is DRAFT-ONLY, not posted (user instruction).
- **2026-08-19T08:04:27Z**: If dropping fp8 KV cache produces coherent
  output, adopt non-fp8 KV cache as the working fix and proceed; dig further
  only if quality/context proves unacceptable (user instruction). Re-check
  Task 1.6 context headroom at restore, since non-fp8 KV cache ~doubles KV
  memory.
- **2026-08-19T08:04:27Z**: The clean-venv contamination test builds a
  side-by-side `/data/vllm/.venv-clean` and leaves the existing `.venv`
  untouched as rollback (user instruction), rather than rebuilding in place.
- **2026-08-19 (SUPERSEDES the 2026-08-19T08:04:27Z draft-only decision)**:
  with both local hypotheses (fp8 KV-cache, environment contamination)
  exhausted and ruled out, user instructed escalating Track B now — the
  upstream issue was rewritten with real data and **posted** (not draft
  anymore): https://github.com/vllm-project/vllm/issues/52938.

### Related PRs / Commits

- Upstream issue filed against `vllm-project/vllm` for Task 1.4's
  degenerate-output bug (identical argmax token + identical logprob at
  every decode position, SM120, `FLASHINFER_MLA_SPARSE_DSV4`, confirmed
  independent of environment/install history):
  https://github.com/vllm-project/vllm/issues/52938
