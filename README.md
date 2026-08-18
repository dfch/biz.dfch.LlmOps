# biz.dfch.LlmOps

On-prem LLM serving for DeepSeek-V4-Flash and DeepSeek-V4-Pro via OpenAI-compatible APIs, consumed by OpenCode and OpenWebUI. Managed through specmgr feature folders.

## Quick Start

### Install OpenCode (on Dell 7960T / Ubuntu 24.04)
```bash
curl -fsSL https://opencode.ai/install | bash
source ~/.bashrc
opencode --version
```

### Run in this repo
```bash
cd /home/user/src/biz.dfch.LlmOps
opencode
```

## Repository Structure
- `.specmgr/feat/feat-1-deepseek-v4-onprem-deployment/README.md` — Active feature spec (planning phase)
- `.specmgr/_template/v1/README.md` — Feature template
- `hardware/dell-7960t/` — Dell 7960T NVIDIA driver config & recovery docs
- `session-ses_fec5.md` — Research session (Ollama cloud tags → HF weights decision)

## Hardware (Dell 7960T)
- 4× RTX Pro 6000 Blackwell Max-Q, 96 GB VRAM each = 384 GB total
- 512 GB system RAM
- Ubuntu 24.04 LTS, kernel 6.8.0-117-generic
- NVIDIA 595.71.05 open driver (CUDA 13.2) from NVIDIA CUDA repo
- See `hardware/dell-7960t/configuration.md` for working package list & pinning
- See `hardware/dell-7960t/recovery.md` for full recovery procedure + power fixes

## Current Feature: `feat-1-deepseek-v4-onprem-deployment`
**Engines**:
- DeepSeek-V4-Flash → vLLM (tensor-parallel=4), FP8-expert override target
- DeepSeek-V4-Pro → ktransformers (GPU+CPU-RAM hybrid MoE)

**Non-negotiables**:
- Official HF weights only (`deepseek-ai/DeepSeek-V4-Flash`, `deepseek-ai/DeepSeek-V4-Pro`), pinned revision
- Both endpoints: unauthenticated, internal network only
- Both engines: systemd services only (`systemctl`)
- Context target: 350–370K tokens, tool-calling + reasoning modes

## Development Workflow
1. Read the active feature README before starting work
2. Execute tasks in dependency order (Task List)
3. Update task status in place (`- [ ]` → `- [x]`)
4. Log decisions + blockers in feature README
5. Use `git log -p` on the feature file to recover original task wording

## Validation Commands
- `systemctl status <service>` — verify service state
- `curl <endpoint>/v1/chat/completions` — smoke test OpenAI-compatible API
- OpenCode/OpenWebUI integration test against live endpoints
- Context stress test: 350–370K token prompt without OOM

## License
GPL-2.0-only (see LICENSE)