# AGENTS.md — biz.dfch.LlmOps

## Project Overview
On-prem LLM serving for DeepSeek-V4-Flash and DeepSeek-V4-Pro via OpenAI-compatible APIs, consumed by OpenCode and OpenWebUI. Managed through specmgr feature folders.

## Repository Structure
- `.specmgr/feat/feat-0-deepseek-v4-onprem-deployment/README.md` — Active feature spec (planning phase, not started)
- `.specmgr/_template/v1/README.md` — Feature template (copy for new features)
- `session-ses_fec5.md` — Research session (Ollama cloud tags → HF weights decision)

## Key Conventions
- **Feature folders**: `.specmgr/feat/feat-NNN-slug/README.md` — single source of truth per feature
- **Status lives on tasks**: Update task lines in place (`- [ ]` → `- [x]`), don't duplicate lists
- **Decisions logged in feature README** under "Decisions Made" with date + rationale
- **No GitHub issues** — features tracked directly in repo (user instruction)

## Current Feature: `feat-0-deepseek-v4-onprem-deployment`
**Hardware**: Dell 7960T (4× RTX Pro 6000 Blackwell Max-Q, 96 GB VRAM each = 384 GB total; 512 GB sys RAM). DGX Spark explicitly excluded.

**Engines**:
- **DeepSeek-V4-Flash** → vLLM (tensor-parallel=4), FP8-expert override target (native FP4+FP8 mixed fallback)
- **DeepSeek-V4-Pro** → ktransformers (GPU+CPU-RAM hybrid MoE), precision trimmed empirically for 350–370K context

**Non-negotiables** (from Decisions Made):
- Official HF weights only (`deepseek-ai/DeepSeek-V4-Flash`, `deepseek-ai/DeepSeek-V4-Pro`), pinned to specific HF revision — no Ollama cloud tags, no GGUF requant
- Both endpoints: unauthenticated (anonymous), internal network only, accepted risk
- Both engines: systemd services only (`systemctl` start/stop/restart), never ad-hoc foreground processes
- Context target: 350–370K tokens for coding workloads, tool-calling + reasoning modes required

## Development Workflow
1. Read the active feature README before starting work
2. Execute tasks in dependency order (listed in Task List)
3. Update task status in place as you progress
4. Log decisions + blockers in the feature README
5. Use `git log -p` on the feature file to recover original task wording if scope shifts

## Validation Commands (when implementation starts)
- `systemctl status <service>` — verify service state
- `curl <endpoint>/v1/chat/completions` — smoke test OpenAI-compatible API
- OpenCode/OpenWebUI integration test against live endpoints
- Context stress test: 350–370K token prompt without OOM

## Specmgr Tooling
Available via MCP (`specmgr` server):
- `specmgr_create_feat` / `specmgr_get_feat` / `specmgr_update_feat` — feature lifecycle
- `specmgr_create_adr` / `specmgr_get_adr` — ADRs (infrastructure decisions)
- `specmgr_create_req` / `specmgr_get_req` — requirements
- `specmgr_create_tsk` / `specmgr_get_tsk` — task lists
- Templates: `specmgr_get_feat_template`, `specmgr_get_req_template`, etc.

## License
GPL-2.0-only (see LICENSE)