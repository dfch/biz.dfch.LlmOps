# Coding agent LLM for DGX Spark 768k context

**Session ID:** ses_fbd17f7deffeAinWdPZli1eChO
**Created:** 8/27/2026, 1:08:17 PM
**Updated:** 8/27/2026, 5:01:33 PM

---

## User

what is the best coding agent LLM that I can run on an NVIDIA DGX Spark with 120 GB usable VRAM and that supports an 768k context size?

---

## Assistant (Plan · Claude Sonnet 5 · 39.1s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "find /home/user/src/biz.dfch.LlmOps/.specmgr -maxdepth 3 -type d 2>/dev/null; echo ---; ls /home/user/src/biz.dfch.LlmOps"
}
```

**Output:**
```
/home/user/src/biz.dfch.LlmOps/.specmgr
/home/user/src/biz.dfch.LlmOps/.specmgr/_template
/home/user/src/biz.dfch.LlmOps/.specmgr/_template/v1
/home/user/src/biz.dfch.LlmOps/.specmgr/feat
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/bin
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-1-deepseek-v4-onprem-deployment
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-1-deepseek-v4-onprem-deployment/bin
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/bin
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-4-qwen3.8-27b-dell-7960t
/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-4-qwen3.8-27b-dell-7960t/bin
---
AGENTS.md
hardware
LICENSE
pyproject.toml
README.md
src
uv.lock

```

**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/session-ses_fec5.md"
}
```

**Error:**
```
File not found: /home/user/src/biz.dfch.LlmOps/session-ses_fec5.md
```

---

## Assistant (Plan · Claude Sonnet 5 · 4.5s)

_Thinking:_



**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/README.md"
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/README.md</path>
<type>file</type>
<content>
1: # biz.dfch.LlmOps
2: 
3: On-prem LLM serving for DeepSeek-V4-Flash and DeepSeek-V4-Pro via OpenAI-compatible APIs, consumed by OpenCode and OpenWebUI. Managed through specmgr feature folders.
4: 
5: ## Quick Start
6: 
7: ### Install OpenCode (on Dell 7960T / Ubuntu 24.04)
8: ```bash
9: curl -fsSL https://opencode.ai/install | bash
10: source ~/.bashrc
11: opencode --version
12: ```
13: 
14: ### Run in this repo
15: ```bash
16: cd /home/user/src/biz.dfch.LlmOps
17: opencode
18: ```
19: 
20: ## Repository Structure
21: - `.specmgr/feat/feat-1-deepseek-v4-onprem-deployment/README.md` — Active feature spec (planning phase)
22: - `.specmgr/_template/v1/README.md` — Feature template
23: - `hardware/dell-7960t/` — Dell 7960T NVIDIA driver config & recovery docs
24: - `session-ses_fec5.md` — Research session (Ollama cloud tags → HF weights decision)
25: 
26: ## Hardware (Dell 7960T)
27: - 4× RTX Pro 6000 Blackwell Max-Q, 96 GB VRAM each = 384 GB total
28: - 512 GB system RAM
29: - Ubuntu 24.04 LTS, kernel 6.8.0-117-generic
30: - NVIDIA 595.71.05 open driver (CUDA 13.2) from NVIDIA CUDA repo
31: - See `hardware/dell-7960t/configuration.md` for working package list & pinning
32: - See `hardware/dell-7960t/recovery.md` for full recovery procedure + power fixes
33: 
34: ## Current Feature: `feat-1-deepseek-v4-onprem-deployment`
35: **Engines**:
36: - DeepSeek-V4-Flash → vLLM (tensor-parallel=4), FP8-expert override target
37: - DeepSeek-V4-Pro → ktransformers (GPU+CPU-RAM hybrid MoE)
38: 
39: **Non-negotiables**:
40: - Official HF weights only (`deepseek-ai/DeepSeek-V4-Flash`, `deepseek-ai/DeepSeek-V4-Pro`), pinned revision
41: - Both endpoints: unauthenticated, internal network only
42: - Both engines: systemd services only (`systemctl`)
43: - Context target: 350–370K tokens, tool-calling + reasoning modes
44: 
45: ## Development Workflow
46: 1. Read the active feature README before starting work
47: 2. Execute tasks in dependency order (Task List)
48: 3. Update task status in place (`- [ ]` → `- [x]`)
49: 4. Log decisions + blockers in feature README
50: 5. Use `git log -p` on the feature file to recover original task wording
51: 
52: ## Validation Commands
53: - `systemctl status <service>` — verify service state
54: - `curl <endpoint>/v1/chat/completions` — smoke test OpenAI-compatible API
55: - OpenCode/OpenWebUI integration test against live endpoints
56: - Context stress test: 350–370K token prompt without OOM
57: 
58: ## License
59: GPL-2.0-only (see LICENSE)

(End of file - total 59 lines)
</content>
```

**Tool: bash**

**Input:**
```json
{
  "command": "ls /home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment; echo ---; ls /home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context; echo ---; ls /home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-4-qwen3.8-27b-dell-7960t"
}
```

**Output:**
```
article-draft.md
article-draft og.md
bin
followup-comment-draft.md
opencode-provider-snippet-glm-5.2.jsonc
README.md
session-ses_fe1b-feat-2-04.md
session-ses_fe1b-feat-2-05-1.md
session-ses_fe1b-feat-2-05.md
session-ses_fe27-feat-2-03.md
session-ses_fe46-feat-2-02.md
session-ses_fe6b-feat-2-01.md
---
bin
README.md
session-ses_fcec-feat-3-06.md
session-ses_fcf4-feat-3-05.md
session-ses_fcfd-feat-3-04.md
session-ses_fd04-feat-3-03.md
session-ses_fd21-feat-3-02.md
session-ses_fd26-feat-3-01.md
session-ses_fd5d-feat-3-00.md
---
bin
opencode-provider-snippet-qwen3.8-27b.jsonc
README.md
session-ses_fc60-feat-4-03.md
session-ses_fc6b-feat-4-02.md
session-ses_fc74-feat-4-01.md
session-ses_fc75-feat-4-00.md

```

---

## Assistant (Plan · Claude Sonnet 5 · 5.6s)

_Thinking:_



**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md"
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md</path>
<type>file</type>
<content>
1: ---
2: created: 2026-08-22
3: github_issue: 3
4: id: feat-3-qwen3.8-27b-large-context
5: status: planning
6: updated: 2026-08-24
7: version: 1.0.0
8: ---
9: 
10: # Feature: On-prem Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI
11: 
12: ## Plan
13: 
14: ### Overview
15: 
16: Deploy `Qwen/Qwen3.8-27B` (dense causal LM + vision encoder, 27B params,
17: Apache-2.0) on the **new Dell GB10 (DGX Spark clone)** — arm64 DGX-class
18: box with a GB10 Grace-Blackwell SoC and a single unified
19: 128 GB LPDDR5x CPU+GPU memory pool (exact size confirmed by user
20: 2026-08-22) — behind an OpenAI-compatible API, for use as a
21: coding model via OpenCode and OpenWebUI, with its context window extended
22: well past the 262,144-token native limit via the vendor's documented YaRN
23: `rope_parameters` override. Target is a **768K-token floor** (786,432
24: tokens = native context x3), pushing toward the model's advertised
25: 1,048,576-token (1M) ceiling if the unified-memory safety margin allows.
26: 
27: Unlike `feat-2`'s GLM-5.2 (744B MoE, forced into a lossy quant to fit that
28: box), Qwen3.8-27B is small enough at full BF16 precision (~54 GB weights)
29: to fit the GB10's 128 GB unified pool with meaningful headroom left over
30: for KV cache — so this feature does not start from a
31: quality-vs-capacity compromise. That said, the KV cache at 768K–1M tokens
32: is non-trivial, so the achievable context must be measured, not assumed.
33: Quantization (e.g. FP8) is not required and stays optional, considered
34: only if empirical data shows it meaningfully helps context headroom or
35: throughput without a demonstrated quality cost.
36: 
37: This feature is independent of `feat-1` (DeepSeek-V4) and `feat-2`
38: (GLM-5.2) — it deploys on a separate box and does not replace either.
39: Coexistence with the Dell-7960T deployments is not a constraint here
40: (different machine); a coexistence question does exist in the other
41: direction (could the 7960T pair run *on this* box in the future?),
42: recorded as informational in REQ-010.
43: 
44: Qwen3.8-27B is a native vision-language model (image + video
45: understanding), but this feature scopes that capability OUT: only
46: text/coding use via OpenCode is targeted and validated here.
47: 
48: ### Requirements
49: 
50: - REQ-001: Serve Qwen3.8-27B via an OpenAI-compatible API
51:   (`/v1/chat/completions`) on the Dell GB10 (1x GB10 Grace-Blackwell,
52:   128GB unified LPDDR5x memory (shared CPU+GPU), NVIDIA DGX Spark clone)
53: - REQ-003: The endpoint must support a context length of at least
54:   **768,000 tokens** (floor). If the unified-memory safety margin
55:   allows, push higher in measured steps, up to the model's native
56:   ceiling of 1,048,576 tokens (1M) — do not stop at 768K if there is
57:   safe headroom to go further
58: - REQ-004: The endpoint must support tool-calling (required for OpenCode
59:   agentic use) and correctly expose Qwen3.8's thinking controls:
60:   `enable_thinking` (on by default), `reasoning_effort`
61:   (`xhigh`/`medium`/`low`), and `preserve_thinking`
62: - REQ-005: Run at full BF16 precision by default (the model fits VRAM
63:   comfortably at this precision). Quantization (e.g. FP8) is acceptable
64:   ONLY if empirically justified — i.e. it demonstrably improves context
65:   headroom or throughput without a documented quality regression; it must
66:   not be adopted purely by default the way `feat-2` had to for GLM-5.2
67: - REQ-006: Engine = vLLM as the primary/default path — it is the engine
68:   the vendor's model card documents the YaRN long-context override for,
69:   and it matches `feat-1`'s default engine. Two additional checks vs
70:   `feat-1`/`feat-2`, both before committing to the YaRN extension work:
71:   (a) the GB10 is an arm64 Grace-Blackwell (SM121) target, so the vLLM
72:   build must be an arm64/GB10-supported one (DGX Spark class support was
73:   only recent as of 2026) — not assumed, checked in Phase 0; (b) an early
74:   native-context smoke test (Phase 1) is still done, since neither the
75:   `qwen3_5` Gated DeltaNet + Gated Attention architecture nor the GB10
76:   platform has been validated for this model yet — cheap insurance
77:   before the YaRN work
78: - REQ-007: Pin `Qwen/Qwen3.8-27B` to a specific Hugging Face revision/
79:   commit (not "latest") for reproducibility across redeploys. Latest
80:   `main` commit at feature-creation time: `1d4bf0f` (README-only change;
81:   weights landed at `72a217a`/initial commit `6714f56`) — to be
82:   re-confirmed and pinned from the box itself at download time (Task 0.4)
83: - REQ-008: The endpoint runs unauthenticated (anonymous, no API-key/auth
84:   layer) — accepted risk, internal network only (same posture as
85:   `feat-1`/`feat-2`)
86: - REQ-009: The engine runs as a managed service (systemd unit, `--user`
87:   - lingering following `feat-2`'s pattern unless a reason emerges to
88:     deviate) — no ad-hoc foreground processes, including during testing
89: - REQ-010: Determine Qwen3.8-27B's actual memory footprint (weights + KV
90:   cache at the target context) within the GB10's unified pool, and record
91:   how much headroom remains at the chosen production context — i.e.
92:   whether anything else could be co-located on the same box, or whether
93:   Qwen3.8-27B effectively owns the pool at the chosen context
94: - REQ-011: YaRN rope scaling must be configured per the vendor's
95:   documented `rope_parameters` override (`mrope_interleaved`,
96:   `mrope_section`, `rope_type: yarn`, `rope_theta`,
97:   `partial_rotary_factor: 0.25`, `factor`, `original_max_position_embeddings: 262144`), with `factor` computed as
98:   `target_context / 262144` (e.g. 768K -> 3.0, 1M -> 4.0, matching the
99:   vendor's own worked example)
100: - REQ-012: Vision/video (image+video understanding) capability is
101:   explicitly OUT of scope for testing/validation in this feature — text/
102:   coding only
103: 
104: ### Acceptance Criteria
105: 
106: - [x] ACC-001: Verifies REQ-001/REQ-002 — Qwen3.8-27B running via vLLM on
107:   the Dell GB10 (DGX Spark clone), reachable via `/v1/chat/completions`,
108:   deployment confined to the GB10 (Dell 7960T untouched) — DONE, checkbox
109:   caught up 2026-08-24: has been true and verified since Phase 4
110:   (Task 4.2/4.3), reconfirmed live throughout Phase 6 — never touched
111:   simply not checked off until this pass. `qwen3.8-27b-nvfp4-896k.service`
112:   is the current live proof (`/v1/models`, `/v1/chat/completions` both
113:   responding); the Dell 7960T (`feat-1`/`feat-2`) was never touched by
114:   this feature's work.
115: - [x] ACC-002: Verifies REQ-003 — empirical memory/KV-cache
116:   measurement confirms the endpoint handles at least a 768K-token prompt
117:   without OOM, with the measured safety margin recorded against the
118:   unified pool; if a higher context (896K, 1M) also clears the adopted
119:   safety-margin policy (>=15% free, or >=10 GiB absolute, whichever is
120:   greater — reused from `feat-2`, applied to the GB10's unified pool),
121:   the highest safely-supported context is chosen as the production value
122:   instead of stopping at 768K — DONE 2026-08-23: **896K chosen as the
123:   production context** (BF16 weights + FP8 KV cache). Full step-up
124:   results in Task 2.1/2.2/2.3; 768K passed comfortably (19.8% free), 896K
125:   passed narrowly (16.1% free, just above the 15% floor), 1M failed
126:   (12.9% free, below the 15% floor) — step-up correctly stopped at 896K
127:   per policy.
128: - [ ] ACC-003: Verifies REQ-004 — tool-call and all three thinking-control
129:   modes (`enable_thinking: false`, `reasoning_effort: medium`,
130:   `reasoning_effort: xhigh`) verified via curl smoke test, then via a
131:   real OpenCode agentic session — CURL LEG DONE 2026-08-23 (Task 4.2):
132:   tool-calling and all 3 modes verified against the live production
133:   systemd service (`qwen3.8-27b-vllm.service`, 896K context) — correct
134:   answers, correctly-scaled reasoning length, clean tool-call. The
135:   OpenCode agentic session leg was done in Task 5.2 (2026-08-23), but
136:   ONLY against the (since-superseded) BF16 production service. **Since
137:   Task 6.2 replaced BF16 with NVFP4 as production (2026-08-24), the
138:   curl leg was re-verified against the new
139:   `qwen3.8-27b-nvfp4-896k.service`** (coherent output, clean tool-call,
140:   all 3 thinking-control modes, correct 17×24=408 answer throughout —
141:   see Task 6.2's step 6-7 results), **but the OpenCode agentic session
142:   itself has NOT been re-run against NVFP4** — still open, tracked as a
143:   follow-up rather than reopening this criterion's curl-verified state.
144: - [x] ACC-004: Verifies REQ-005 — BF16 is confirmed as the production
145:   precision, with a one-line rationale recorded; if a quantized variant
146:   is adopted instead, the empirical justification (headroom/throughput
147:   data, quality-impact check) is recorded alongside it — DONE
148:   2026-08-23: BF16 weights confirmed as production precision — the
149:   896K launch script (`/home/admin/launch-phase2-896k-fp8kv.sh`) sets
150:   no `--dtype`/`--quantization` flag, the model's `config.json` has no
151:   `quantization_config`, and the on-disk safetensors total (55.56 GB)
152:   matches BF16 for a 27B-param dense LM; Phase 2's FP8 change was
153:   KV-cache dtype only and never touched weights. **SUPERSEDED
154:   2026-08-24 (Task 6.2 steps 6-7)**: NVFP4 is now the adopted
155:   production precision instead of BF16 — this is exactly the
156:   quantized-variant path this criterion anticipated, satisfied with
157:   its own empirical justification: 2.54x-7.7x decode speedup over BF16
158:   (Task 6.1) plus a user-judged quality-impact check via their own
159:   coding-task examples on OpenCode ("NVFP4 quality is fine, adopt it,"
160:   Task 6.2 step 6) with no reported regression. BF16 remains on disk,
161:   disabled, as a documented fallback.
162: - [x] ACC-005: Verifies REQ-006 — vLLM is confirmed as the deployment
163:   engine, with the version used recorded; if vLLM fails the Phase 1
164:   native-context smoke test, the fallback engine actually used (SGLang)
165:   is recorded instead, along with why — DONE 2026-08-23: vLLM 0.27.1
166:   (aarch64) passed Phase 1 cleanly (Task 1.1–1.3), no SGLang fallback
167:   needed
168: - [x] ACC-006: Verifies REQ-007 — deployment config records the exact HF
169:   revision/commit hash used — DONE, checkbox caught up 2026-08-24: the
170:   NVFP4 checkpoint's pinned revision
171:   (`7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108`) is recorded in the README
172:   (Task 6.2 prep work) and now also baked directly into
173:   `bin/01-build.sh`'s `MODEL_REVISION` variable, so a fresh install
174:   reproduces the exact same pinned checkpoint, not "latest".
175: - [x] ACC-007: Verifies REQ-008 — endpoint reachable without credentials
176:   from the internal network, confirmed intentional (not an oversight) —
177:   DONE, checkbox caught up 2026-08-24: true throughout (no auth layer on
178:   any of this feature's services), and explicitly recorded as an
179:   accepted-risk decision in Decisions Made (2026-08-22), matching
180:   `feat-1`/`feat-2`'s posture.
181: - [x] ACC-008: Verifies REQ-009 — engine installed as a systemd service;
182:   started/stopped/restarted exclusively via `systemctl`
183:   (`systemctl --user ...` if following `feat-2`'s pattern) throughout
184:   testing and production use — DONE, checkbox caught up 2026-08-24: true
185:   since Task 4.1, and the discipline held throughout every subsequent
186:   cutover (BF16 → NVFP4 896K → NVFP4 1M candidate → back to NVFP4 896K
187:   - MTP) — every start/stop went through `systemctl --user`, no ad-hoc
188:     `nohup` process was ever left running as "production".
189: - [x] ACC-009: Verifies REQ-010 — a recorded decision on Qwen3.8-27B's
190:   memory footprint within the GB10's unified pool at the chosen
191:   production context, backed by measured numbers (not assumed), stating
192:   the remaining headroom explicitly — DONE, checkbox caught up
193:   2026-08-24: recorded at every precision/context change (Task 2.3 for
194:   BF16 896K: 19.28 GiB/16.1% free; Task 6.2 step 4 for NVFP4 896K:
195:   ~48 GiB/40.1% free; Task 6.3 for NVFP4+MTP 896K, the FINAL production
196:   config: ~46 GiB/~39% free, KV-cache margin 1.07x). The GB10
197:   effectively owns its pool at this context regardless of precision —
198:   no meaningful coexistence headroom for another model.
199: - [x] ACC-010: Verifies REQ-011 — the exact YaRN `rope_parameters` config
200:   used for the chosen production context size is recorded in the
201:   systemd unit/deployment config — DONE, checkbox caught up 2026-08-24:
202:   the full `--hf-overrides` block (factor 3.5, `mrope_interleaved`,
203:   `mrope_section`, `rope_theta`, `partial_rotary_factor`,
204:   `original_max_position_embeddings`) is baked into the production
205:   launch script (`qwen3.8-27b-nvfp4-896k.sh`), which the systemd unit's
206:   `ExecStart` runs directly, and is also reproduced verbatim by
207:   `bin/02-install-service.sh` for fresh installs.
208: - [ ] ACC-011: User runs the SAME coding-task examples used for `feat-1`/
209:   `feat-2` (see `feat-1` ACC-010, `feat-2` ACC-009) against this
210:   endpoint, for a direct three-way quality comparison — STILL OPEN as of
211:   2026-08-24: Task 5.2 (2026-08-23) executed this exact methodology, but
212:   ONLY against the since-superseded BF16 production service — the same
213:   gap already flagged on ACC-003. Production is now NVFP4 (Task 6.2);
214:   the formal three-way comparison record has not been repeated/
215:   reconfirmed against it. Not blocking (Task 5.2's BF16-era result is a
216:   reasonable first pass), but the accurate, fully-closed answer requires
217:   one more OpenCode session against `qwen3.8:27b-nvfp4-896k`.
218: 
219: ### Scope
220: 
221: What is included in this feature:
222: 
223: - A lightweight native-context (256K) correctness smoke test on vLLM/
224:   GB10 (SM121) BEFORE attempting the YaRN extension (Phase 1) — not a
225:   full multi-engine spike like `feat-2`'s Phase 1, but still verified
226:   rather than assumed, since platform (arm64/GB10) AND architecture
227:   (`qwen3_5`) are both unvalidated for this model
228: - Configuring and validating YaRN-based context extension per the
229:   vendor's documented `rope_parameters` override
230: - Empirical memory/KV-cache measurement at 768K and, if headroom allows,
231:   at higher context sizes up to 1M
232: - Phase 0 arm64 setup: OS/driver/CUDA/vLLM-arm64/HF tooling verified on
233:   the GB10 itself (new box — nothing inherited from `feat-1`/`feat-2`)
234: - Deployment of Qwen3.8-27B on the Dell GB10 as a systemd service
235: - Pinning the model to a fixed HF revision
236: - OpenWebUI and OpenCode configured against the endpoint
237: - Direct quality comparison against `feat-1`'s DeepSeek-V4 and `feat-2`'s
238:   GLM-5.2 using the same coding-task examples
239: 
240: What is explicitly out of scope:
241: 
242: - Any modification to the Dell 7960T or its `feat-1`/`feat-2`
243:   deployments — this feature runs only on the GB10 and does not touch
244:   the other box
245: - Acquiring additional hardware beyond the GB10
246: - Authentication/access-control layer (explicitly accepted as anonymous)
247: - Fine-tuning or training Qwen3.8-27B (serving only)
248: - Testing or validating vision-language (image/video) capability (REQ-012)
249: - Retiring or changing the `feat-1`/`feat-2` deployments — all three
250:   features coexist (on separate boxes); this feature does not depend on
251:   either succeeding
252: - Ollama/llama.cpp/GGUF as the serving path — the vendor's own
253:   documentation only covers the YaRN long-context extension for vLLM,
254:   SGLang, and TokenSpeed; Qwen3.8's hybrid Gated DeltaNet + partial-
255:   rotary/mrope architecture is non-standard enough that an unofficial
256:   llama.cpp YaRN override is judged too high-risk for this feature's
257:   goals (see the source chat session that preceded this feature for the
258:   detailed reasoning)
259: 
260: ### Dependencies
261: 
262: - Depends on: the Dell GB10 being physically present and bootable with a
263:   working NVIDIA driver + CUDA + vLLM arm64 stack (fresh setup — Task
264:   0.2/0.3, nothing is inherited from `feat-1`/`feat-2`'s x86 box); a vLLM
265:   release whose arm64 build supports BOTH the GB10 (SM121/Grace-Blackwell)
266:   AND Qwen3.8-27B's architecture (`qwen3_5` tag, hybrid Gated DeltaNet +
267:   Gated Attention layout) — both are new as of this feature's creation
268:   date (2026-08-22), support is NOT assumed, must be checked (Task 0.2);
269:   HF access/token/download tooling installed on the GB10 (Task 0.3);
270:   sufficient local disk on the GB10 for weights (~54GB BF16) (Task 0.1)
271: - Related (not a hard dependency): `feat-1`'s and `feat-2`'s SM120
272:   sparse-attention-decode findings (`vllm-project/vllm#52938`) — the GB10
273:   has no SM120 GPUs, so that specific bug likely cannot recur here, but
274:   the general lesson (smoke-test the new platform before committing to
275:   extension work) still applies
276: - Blocks: none
277: 
278: ### Design Notes
279: 
280: - **Model facts (verified from HF 2026-08-22)**: `Qwen/Qwen3.8-27B`,
281:   Apache-2.0, dense causal LM + vision encoder, 27B language-model params
282:   (28B total on disk, BF16 safetensors). Hybrid layout: 16x (3x (Gated
283:   DeltaNet -> FFN) -> 1x (Gated Attention -> FFN)), 64 layers total.
284:   Gated Attention: 24 Q heads / 4 KV heads, head dim 256, but only a
285:   `partial_rotary_factor` of 0.25 (64 of 256 dims) actually gets RoPE.
286:   Context: 262,144 native, extensible to 1,048,576 via YaRN per the
287:   vendor card. Successor generation after Qwen3.6/3.7.
288: 
289: - **Why BF16, not a forced quant (contrast with `feat-2`)**: 27B dense at
290:   BF16 is ~54GB of weights — inside the GB10's 128GB unified pool before
291:   accounting for KV cache, unlike GLM-5.2's 744B MoE which could not fit
292:   on its box at any near-lossless precision without a quant. There is no
293:   a priori reason to trade quality for capacity here; quantization is
294:   opportunistic (Task 3.x), not load-bearing. Caveat specific to the
295:   GB10: weights and KV cache share ONE memory pool with the CPU (no
296:   separate system-RAM fallback like the 7960T's 512GB), so the ceiling on
297:   achievable context is set by the free fraction of that single 128GB
298:   pool — measure it (Phase 2), don't model it.
299: 
300: - **YaRN factor table** (native = 262,144; vendor's own worked example:
301:   524,288 -> factor 2.0):
302: 
303:   | target context | factor |
304:   |---|---|
305:   | 524,288 (512K) | 2.0 |
306:   | 786,432 (768K) | 3.0 |
307:   | 917,504 (896K) | 3.5 |
308:   | 1,048,576 (1M, native ceiling) | 4.0 |
309: 
310:   Full override block (vendor-documented):
311:   `{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": <see table>, "original_max_position_embeddings": 262144}}}`
312:   passed via `--hf-overrides` (vLLM, needs
313:   `VLLM_ALLOW_LONG_MAX_MODEL_LEN=1`) or the equivalent SGLang
314:   `--json-model-override-args`.
315: 
316: - **Static YaRN caveat (from the vendor card, carried over verbatim)**:
317:   all current open-source frameworks implement static YaRN — the scaling
318:   factor is fixed regardless of actual input length, which can hurt
319:   short-prompt performance once a large factor is set. Only worth setting
320:   if 768K+ is the genuinely typical working context for this deployment,
321:   not just a ceiling to have available.
322: 
323: - **FP8 KV cache (not weight quantization) was required to get real OS
324:   headroom at 768K+ on the GB10's unified pool** (found in Task 2.1):
325:   `--gpu-memory-utilization` sizes vLLM's TOTAL memory footprint as a
326:   fixed fraction of the pool regardless of how much KV-cache token
327:   capacity that buys. On a discrete-VRAM box (`feat-1`/`feat-2`) that
328:   just trades away request concurrency; on the GB10's single unified
329:   pool it silently starves the OS itself (measured: only ~1.7-3.5 GiB
330:   system-wide free at 768K/BF16-KV/util=0.92, vs. a ~17.9 GiB policy
331:   floor). The fix is `--kv-cache-dtype fp8` (KV cache precision only —
332:   model weights stay BF16, REQ-005 untouched) combined with an EXPLICIT
333:   `--kv-cache-memory-bytes` sized just above what the target context
334:   needs (not the full `gpu_memory_utilization` budget) — this frees the
335:   difference as genuine, measured OS headroom. This is now a required
336:   flag pair for every Phase 2+/Phase 4 launch on this box, not optional.
337: 
338: - **Coexistence is a different shape of question here than on the 7960T**:
339:   `feat-1`/`feat-2` run on the Dell 7960T, a different box — so the
340:   question is no longer "can Qwen3.8-27B share GPUs with them" (trivially
341:   no, it's not on that box). The relevant questions are: (a) at the chosen
342:   production context, how much of the GB10's unified pool is free (Task
343:   2.3/REQ-010)? (b) does the endpoint even clear the 768K floor given
344:   weights + KV cache all live in that one 128GB pool? Both are measured,
345:   not assumed. Note the box already runs an Ollama stack (including a
346:   llama-server with a live 256K context holding ~4 GB of the pool as of
347:   2026-08-22) and OpenWebUI — their memory state must be included in
348:   Phase 2 measurements, and the running Ollama model should be stopped
349:   before the capacity tests to get a clean baseline.
350: 
351: - **NO environment inheritance from `feat-1`/`feat-2`.** The GB10 is a
352:   new, arm64 box: driver, CUDA, vLLM (the correct arm64/GB10-compatible
353:   build), and HF tooling all need to be verified/installed on it (Phase 0
354:   is real setup work, not confirmation of an inherited state). The only
355:   things inherited are practice (systemd `--user`-lingering pattern,
356:   HF-pin discipline, no-auth internal posture) and this repo.
357: 
358: - **Same non-negotiables as `feat-1`/`feat-2`**: pinned HF revision
359:   (REQ-007), anonymous internal-only endpoint (REQ-008), systemd-only
360:   operation (REQ-009).
361: 
362: - **Comparison is the point.** ACC-011 reuses the exact `feat-1`/`feat-2`
363:   coding-task examples so Qwen3.8-27B's quality (and its much larger
364:   context ceiling) can be judged head-to-head against DeepSeek-V4 and
365:   GLM-5.2 on the user's real workloads.
366: 
367: - **Why Ollama/llama.cpp was ruled out for this feature** (from the
368:   chat session preceding this feature's creation): the vendor card only
369:   documents the YaRN extension for vLLM/SGLang/TokenSpeed. GGUF/Ollama
370:   quantizations do exist for this model, but Qwen3.8-27B's hybrid
371:   Gated DeltaNet linear-attention blocks plus its unusual
372:   `partial_rotary_factor`/`mrope_section` rotary setup make it materially
373:   more likely that llama.cpp's independent YaRN implementation would
374:   silently diverge from the vendor-validated behavior, versus a standard
375:   dense-attention model. This can be revisited later as a separate
376:   feature if a specific need for an Ollama-served path emerges.
377: 
378: ### Related ADRs
379: 
380: - None (infrastructure/deployment work, tracked in this repo using the
381:   feature-folder convention, same as `feat-1`/`feat-2`)
382: 
383: ### Task List
384: 
385: #### Phase 0: Environment prep (new box — real setup, not confirmation)
386: 
387: - [x] Task 0.1: Confirm disk headroom on the GB10 is sufficient for
388:   Qwen3.8-27B weights (~54GB BF16) plus tooling/swap — depends on:
389:   none — status: done 2026-08-22 — 1.9 TB NVMe, 152 GB free at check
390:   time (92% used, mostly prior model stores under `/data`); 54 GB
391:   download fits with ~100 GB to spare, no cleanup required
392: - [x] Task 0.2: Verify the GB10's NVIDIA driver + CUDA are installed and
393:   working, AND confirm an arm64 vLLM build supports Qwen3.8-27B's
394:   architecture (`qwen3_5` tag, hybrid Gated DeltaNet + Gated Attention) —
395:   depends on: none — status: done 2026-08-22 — driver 580.173.02 +
396:   CUDA 13.0.88 present and working (nvidia-smi sees the GB10); vLLM
397:   0.27.1 (aarch64, venv `/home/admin/venvs/vllm`) registers
398:   `Qwen3_5ForConditionalGeneration`/`Qwen3_5ForCausalLM` in its
399:   ModelRegistry and implements `mrope_interleaved` — both the platform
400:   and architecture checks pass
401: - [x] Task 0.3: Install/verify HF CLI + token + `hf_transfer` on the GB10 —
402:   depends on: none — status: done 2026-08-22 — no system-wide HF CLI,
403:   but the `admin` HF token is present and working; downloads run via the
404:   `hf` CLI from the vLLM venv (`/home/admin/venvs/vllm/bin/hf`,
405:   hf_transfer enabled). NOTE: `/data` is root-owned and not writable by
406:   `admin`, so weights go under `/home/admin/models/`
407: - [x] Task 0.4: Choose and record the pinned HF revision/commit for
408:   `Qwen/Qwen3.8-27B` — depends on: Task 0.3 — status: done 2026-08-22 —
409:   pinned to full commit hash `1d4bf0f2ff6012fd82039f2fa52739d0dd7c60c0`
410:   (matches the `1d4bf0f` short hash recorded at feature-creation; model
411:   is not gated, last modified 2026-08-14, architecture tag `qwen3_5`) —
412:   download COMPLETE, 55.6 GB (18 safetensors shards + configs) at
413:   `/home/admin/models/qwen3.8-27b`
414: 
415: #### Phase 1: Baseline correctness smoke test (native context, before YaRN)
416: 
417: - [x] Task 1.1: Bring up Qwen3.8-27B on vLLM at native context (262,144 or
418:   smaller for a quick check) on the GB10, no YaRN override yet —
419:   depends on: Task 0.2, Task 0.4 — status: done 2026-08-23 — brought up
420:   at `--max-model-len 32768` on port 8000 (Ollama's prior 65 GB
421:   reservation was already clear — `free -h` showed ~114 GiB available,
422:   `nvidia-smi` showed 0 processes, before starting). Two NEW Phase-0-
423:   class environment gaps surfaced and were fixed, both without sudo/
424:   root:
425:   1. **Missing `Python.h`**: Triton's JIT step (used to inspect the
426:      `Qwen3_5ForConditionalGeneration` architecture) shells out to
427:      `gcc`, which failed with `fatal error: Python.h: No such file or directory` — `python3.12-dev` is not installed system-wide and
428:      apt requires sudo (not available non-interactively). Fixed with
429:      `uv python install 3.12` (downloads a standalone CPython 3.12.13
430:      build with headers under
431:      `~/.local/share/uv/python/cpython-3.12.13-linux-aarch64-gnu/`,
432:      no sudo) plus `export CPATH=.../include/python3.12` so `gcc`
433:      finds it. Same 3.12 minor version as the venv's interpreter
434:      (3.12.3), so no Python C-API ABI risk.
435:   2. **`ninja` unreachable**: `torch.compile`/inductor shells out to a
436:      bare `ninja` on `$PATH`; it IS installed inside the venv
437:      (`/home/admin/venvs/vllm/bin/ninja`, pulled in as a pip dependency)
438:      but the venv's `bin/` was not on `PATH` for a plain `nohup vllm serve ...` invocation, causing `FileNotFoundError: [Errno 2] No such file or directory: 'ninja'` deep in engine-core init. Fixed
439:      with `export PATH=/home/admin/venvs/vllm/bin:$PATH` before
440:      launching.
441:      Final working launch command (both fixes applied):
442:      `CPATH=/home/admin/.local/share/uv/python/cpython-3.12.13-linux-aarch64-gnu/include/python3.12 PATH=/home/admin/venvs/vllm/bin:$PATH /home/admin/venvs/vllm/bin/vllm serve /home/admin/models/qwen3.8-27b --port 8000 --trust-remote-code --no-enable-prefix-caching --max-model-len 32768 --enable-auto-tool-choice --tool-call-parser qwen3_xml --reasoning-parser qwen3` (tool/
443:      reasoning parser choice explained in Task 1.2). Startup took ~9 min
444:      total (weight load ~5m47s of 51.75 GiB checkpoint off local NVMe +
445:      torch.compile/CUDA-graph capture ~3m); no OOM; `gpu_worker.py`
446:      reported 51.7 GiB available for KV cache at this (deliberately small)
447:      32768 max-model-len — real capacity measurement is Phase 2's job, not
448:      this one. Server shut down cleanly after Task 1.2/1.3 (no leftover
449:      process, GPU back to 0 processes / ~114 GiB free) so Phase 2 starts
450:      from a clean baseline.
451: - [x] Task 1.2: Temperature=0 smoke test — verify coherent, non-degenerate
452:   output (explicitly check against the `feat-1`/`feat-2` degenerate
453:   signature: a single frozen token repeated at every decode position),
454:   and verify tool-calling + `enable_thinking`/`reasoning_effort` work at
455:   native context — depends on: Task 1.1 — status: done 2026-08-23 —
456:   ALL checks pass:
457:   - **Non-degenerate output**: a plain coding prompt (fib w/ memoization)
458:     produced coherent, varied text (not the `feat-1`/`feat-2` single-
459:     frozen-token signature). Generation throughput measured at only
460:     ~4.6 tokens/s in this initial run (unquantized BF16, no batching,
461:     32768 max-model-len) — noted as a throughput observation for later
462:     phases, not a correctness blocker.
463:   - **Tool-calling**: required explicit `--enable-auto-tool-choice --tool-call-parser <name>` (off by default; first attempt without it
464:     correctly errored rather than silently ignoring `tool_choice: "auto"`). Parser choice `qwen3_xml` was picked by inspecting the
465:     model's own `chat_template.jinja`, which emits tool calls as
466:     `<tool_call><function=NAME><parameter=...>...</parameter></function></tool_call>`
467:     — vLLM's registered `qwen3_engine_tool_parser` (aliased as both
468:     `qwen3_coder` and `qwen3_xml`) matches this format; `qwen3_xml` was
469:     used as the non-coder-specific name. A `get_weather("Paris")`
470:     tool-call test returned a clean, correctly-typed
471:     `tool_calls[0].function.arguments = {"location": "Paris"}` with
472:     `finish_reason: "tool_calls"` and `content: null`.
473:   - **Thinking controls**: also required an explicit `--reasoning-parser qwen3` (found via `vllm.reasoning.__init__` registry) to split
474:     `<think>`-style reasoning out of `content` into the OpenAI-style
475:     `message.reasoning` field — without it, reasoning text and the
476:     final answer are concatenated in `content` with `reasoning: null`.
477:     With the parser enabled, verified per ACC-003's exact 3 modes on a
478:     17\*24 arithmetic prompt (correct answer=408 in every case):
479:     `enable_thinking: false` -> no reasoning field populated, direct
480:     tool-call/answer; `reasoning_effort: low/medium/xhigh` (all with
481:     `enable_thinking: true`) -> each produced a populated `reasoning`
482:     field with a correctly-scaled amount of visible reasoning text and
483:     a correct final answer in `content`.
484: - [x] Task 1.3: Record the outcome. If vLLM produces degenerate output
485:   (unexpected given the different kernel class, but not impossible),
486:   fall back to spiking SGLang next, mirroring `feat-2`'s Phase 1
487:   approach — depends on: Task 1.2 — status: done 2026-08-23 — **vLLM
488:   passes cleanly, no SGLang fallback needed.** REQ-006/ACC-005 resolved:
489:   vLLM 0.27.1 (aarch64) is confirmed as the deployment engine for this
490:   feature. The `qwen3_5` Gated DeltaNet + Gated Attention architecture
491:   and the GB10 (SM121) platform are both validated at native context.
492:   Carry-forward flags for Phase 2/4 deployment configs: always launch
493:   with `CPATH`/`PATH` set as in Task 1.1, plus
494:   `--enable-auto-tool-choice --tool-call-parser qwen3_xml --reasoning-parser qwen3`.
495: 
496: #### Phase 2: Context extension + capacity measurement
497: 
498: - [x] Task 2.1: Apply the YaRN `rope_parameters` override (see Design
499:   Notes table) targeting 768K context; measure unified-pool memory +
500:   KV-cache usage and free headroom at that context size — depends on:
501:   Task 1.3 — status: done 2026-08-23 — two sub-attempts, the first of
502:   which surfaced a real problem before the second succeeded:
503: 
504:   1. **First attempt (default `--gpu-memory-utilization 0.92`, BF16 KV
505:      cache)**: hit a NEW environment gap — the default
506:      `VLLM_ENGINE_READY_TIMEOUT_S=600` was too short for this box (weight
507:      load alone took ~5.7 min because "Auto-prefetch is disabled" — the
508:      51.75 GiB checkpoint exceeds available page-cacheable RAM on EXT4 —
509:      plus KV-cache profiling/compile on a 786,432 max-model-len engine),
510:      so the engine core was killed as a false-timeout before finishing.
511:      Fixed with `VLLM_ENGINE_READY_TIMEOUT_S=3600`; carry this forward to
512:      every Phase 2+ launch (native-context Task 1.1 never needed it
513:      because its 32768 max-model-len profiled fast enough to clear the
514:      600s default).
515:   2. **Re-run with the fix**: server started cleanly and a REAL
516:      768,567-token prompt (built by encoding/trimming with the model's
517:      own tokenizer, not a synthetic token-count estimate) was POSTed to
518:      `/v1/chat/completions` end-to-end — HTTP 200, no OOM, ~36 min wall
519:      time (2166s) for the full prefill+decode. So the raw 768K capability
520:      bar is cleared. BUT the memory accounting exposed a real problem:
521:      KV cache capacity was only 820,013 tokens against the 786,432
522:      needed (1.04x margin — barely fits one full-length request), and
523:      system-wide `free -h` "available" during serving was only
524:      **~1.7-3.5 GiB** out of 119.63 GiB total — nowhere near the adopted
525:      safety-margin policy (needs at least 15% of 119.63 GiB, i.e. ~17.9
526:      GiB, or at least 10 GiB, whichever is greater). Root cause:
527:      `--gpu-memory-utilization 0.92` fixes vLLM's TOTAL footprint budget
528:      (weights 55.99 GiB + activation 3.78 GiB + CUDA graph 0.94 GiB + KV
529:      cache 50.29 GiB = ~111.0 GiB of the 119.63 GiB pool) regardless of
530:      how much KV-cache *capacity* that buys — on a discrete-VRAM box
531:      this just means "less concurrency headroom"; on the GB10's unified
532:      pool it means "the OS itself is left with almost nothing," a
533:      materially different risk.
534:   3. **Fix: `--kv-cache-dtype fp8` + explicit `--kv-cache-memory-bytes`**
535:      (KV cache precision only — model weights stay BF16, REQ-005
536:      unaffected). FP8 KV cache roughly halves bytes/token (~65.8 KB/token
537:      BF16 -> ~33.0 KB/token FP8, measured empirically, not just the
538:      nominal 2x), so the same 786,432-token requirement can be met with
539:      a much smaller, explicitly-sized KV-cache reservation instead of
540:      vLLM automatically consuming the full `gpu_memory_utilization`
541:      budget. Re-ran with `--kv-cache-dtype fp8 --kv-cache-memory-bytes 32212254720` (30 GiB, sized for ~1.24x margin over 786,432 tokens):
542:      KV cache capacity **974,864 tokens** (1.24x margin, up from 1.04x),
543:      system `free -h` available **23.73 GiB (19.8% of the 119.63 GiB
544:      pool)** — clears the safety-margin policy with real room to spare.
545:      Re-ran the SAME real 768,567-token prompt end-to-end: HTTP 200, no
546:      OOM, ~45 min wall time (2693s) — slower than the BF16 KV-cache run
547:      (likely FP8 dequant overhead on this platform's FlashInfer path,
548:      not yet tuned for GB10; flagged as a throughput observation, not a
549:      blocker, same bucket as Task 1.2's low-throughput note). **Adopted
550:      for production: FP8 KV cache + explicit `--kv-cache-memory-bytes`,
551:      NOT the default `--gpu-memory-utilization`-driven auto-sizing, is
552:      required on this box to get real OS headroom at 768K+.**
553: 
554: - [x] Task 2.2: If Task 2.1's margin clears the adopted safety-margin
555:   policy (>=15% free of the unified pool, or >=10 GiB absolute, whichever
556:   is greater) with room to spare, step upward (896K, then 1M) and
557:   re-measure at each step until the policy is no longer cleared — choose
558:   the highest context size that still clears it as the production target
559:   (may be 768K, may be higher) — depends on: Task 2.1 —
560:   status: done 2026-08-23 — stepped up using the same FP8-KV-cache
561:   approach (load-time capacity/headroom measurement at each step, per
562:   the plan's Task 4.3 being the place reserved for a full real-prompt
563:   end-to-end check at the FINAL chosen production context; 768K already
564:   got a real-prompt check in Task 2.1):
565: 
566:   | Context | Factor | `--kv-cache-memory-bytes` | KV cache capacity | Concurrency margin | Free memory | % free | Policy (>=15% or >=10 GiB) |
567:   |---|---|---|---|---|---|---|---|
568:   | 768K (786,432) | 3.0 | 30 GiB | 974,864 tokens | 1.24x | 23.73 GiB | 19.8% | **PASS** |
569:   | 896K (917,504) | 3.5 | 33 GiB | 1,073,277 tokens | 1.17x | 19.28 GiB | 16.1% | **PASS (thin — only ~1.1pp above the 15% floor)** |
570:   | 1M (1,048,576) | 4.0 | 37.11 GiB | 1,209,295 tokens | 1.15x | 15.39 GiB | 12.9% | **FAIL** (below the 15% floor, despite being above the 10 GiB absolute floor — the policy takes the greater/stricter of the two) |
571: 
572:   Step-up correctly stopped at 1M per the policy. **896K is the highest
573:   context that clears the policy and is the chosen production context**
574:   — clearly ahead of the 768K floor from REQ-003, but not the full 1M
575:   ceiling. **896K reconfirmed as final 2026-08-24**: even though NVFP4
576:   (adopted as production precision in Task 6.2, see ACC-004) also
577:   clears the full 1M ceiling with room to spare (36.2% free), the user
578:   explicitly chose to stay at 896K after testing — "the ctx is large
579:   enough with that size" — so 896K, not 1M, is the actual deployed
580:   production context regardless of precision. All three sizes loaded
581:   and served `/v1/models` successfully
582:   (200 OK) with no OOM at load time; only 768K got the full real-prompt
583:   end-to-end POST (Task 2.1) — 896K's real-prompt end-to-end validation
584:   is carried forward as Task 4.3 against the finalized systemd
585:   deployment, per the original plan.
586: 
587: - [x] Task 2.3: Record the remaining free headroom of the GB10's unified
588:   pool at the chosen production context, i.e. answer REQ-010's "what
589:   else could share this box, or is the pool effectively consumed"
590:   question with real measured numbers — depends on: Task 2.2 —
591:   status: done 2026-08-23 — at the chosen production context (896K,
592:   factor 3.5, FP8 KV cache, `--kv-cache-memory-bytes` 33 GiB): **19.28
593:   GiB (16.1%) of the GB10's 119.63 GiB unified pool remains free**,
594:   measured via `free -h`/`free -b` while the server was actively serving.
595:   This clears the adopted safety-margin policy but only just (the 15%
596:   floor is ~17.9 GiB; this is ~1.3 GiB above it) — answer to REQ-010:
597:   **the GB10 effectively owns the pool at 896K**; ~19 GiB is not enough
598:   to co-locate another meaningful model or service (e.g. the prior
599:   Ollama stack alone reserved ~65 GiB per the 2026-08-22 note), though it
600:   is enough headroom for the OS/desktop/monitoring tools to keep
601:   operating without instability. If more coexistence headroom is ever
602:   needed, the 768K step (23.73 GiB / 19.8% free) is the more
603:   conservative fallback, still comfortably above the 768K floor from
604:   REQ-003.
605: 
606: #### Phase 3: Precision decision
607: 
608: - [x] Task 3.1: Confirm BF16 as the production precision by default
609:   (expected outcome given Design Notes) — depends on: Task 2.3 —
610:   status: done 2026-08-23 — confirmed via live shell on the GB10 (no
611:   new serving run needed): the 896K launch script
612:   (`/home/admin/launch-phase2-896k-fp8kv.sh`) passes no
613:   `--dtype`/`--quantization` flag (only `--kv-cache-dtype fp8`, a
614:   KV-cache-only setting), `config.json` has no `quantization_config`,
615:   and the checkpoint's total safetensors size (55.56 GB) matches BF16
616:   for ~27B params. REQ-005/ACC-004 closed: BF16 is the production
617:   weight precision, unaffected by Phase 2's KV-cache FP8 decision.
618: - [ ] Task 3.2: (Optional, only if Task 2.2/2.3 data suggests a benefit)
619:   Evaluate an FP8 (or similar) variant for throughput or additional
620:   context/coexistence headroom, with an explicit quality-impact check
621:   before adopting it over BF16 — depends on: Task 3.1 — status: not-started
622: 
623: #### Phase 4: Full deployment
624: 
625: - [x] Task 4.1: Install vLLM + Qwen3.8-27B as a systemd service (`--user`
626:   - lingering, following `feat-2`'s pattern unless GB10-specific needs
627:     dictate a system-wide unit instead) with the chosen production context,
628:     YaRN config, and precision on the GB10 — depends on: Task 3.1 —
629:     status: done 2026-08-23 — followed `feat-2`'s pattern exactly
630:     (systemd `--user` unit + lingering, unit deliberately left disabled
631:     so it does NOT autostart at boot):
632:     1. Created `/home/admin/scripts/qwen3.8-27b-vllm-896k.sh`, a
633:        production copy of the already-tested Phase 2 script
634:        (`/home/admin/launch-phase2-896k-fp8kv.sh`) — flags byte-for-byte
635:        identical (only header comments added): 896K/917,504
636:        `--max-model-len`, YaRN factor 3.5 `--hf-overrides`, BF16 weights
637:        (no `--dtype`/`--quantization`, per Task 3.1), `--kv-cache-dtype fp8 --kv-cache-memory-bytes 35433480192`, `CPATH`/`PATH` fixes
638:        (Task 1.1), `VLLM_ENGINE_READY_TIMEOUT_S=3600` (Task 2.1),
639:        `--enable-auto-tool-choice --tool-call-parser qwen3_xml --reasoning-parser qwen3` (Task 1.3).
640:     2. Created `/home/admin/.config/systemd/user/qwen3.8-27b-vllm.service`
641:        (`Type=simple`, `ExecStart=` the script above, `Restart=on-failure`,
642:        `TimeoutStartSec=4200` — longer than the script's own 3600s
643:        engine-ready timeout so systemd never kills it mid-startup,
644:        `LimitNOFILE=1048576`).
645:     3. Enabled lingering: `loginctl enable-linger admin` succeeded
646:        without sudo/a password prompt (`Linger=yes` confirmed) — lets
647:        the service survive logout without autostarting at boot, same
648:        as `feat-2`'s "lingering + NOT enabled" combination.
649:     4. Installed: `systemctl --user daemon-reload`; confirmed via
650:        `systemctl --user status`: `Loaded: loaded (...; disabled; preset: enabled)`, `Active: inactive (dead)` — exactly the
651:        intended state, ready for an explicit start (Task 4.2).
652:     5. Skipped (not required here): `feat-2`'s Task 2.3.2 video/render
653:        group defense-in-depth — `/dev/nvidia*` on the GB10 are already
654:        world-writable (`crw-rw-rw-`), same underlying condition as
655:        `feat-2`'s box, and non-interactive `sudo` is unavailable on
656:        this box anyway (consistent with every other Phase 0-3 fix on
657:        this feature being sudo-free).
658:        GB10 confirmed clean afterward: port 8000 free, 0 GPU compute
659:        processes, ~100 GiB free/114 GiB available.
660: - [x] Task 4.2: Start the service; curl smoke test against
661:   `/v1/chat/completions` at the production context size — verify
662:   tool-calls and all thinking-control modes — depends on: Task 4.1 —
663:   status: done 2026-08-23 — `systemctl --user start qwen3.8-27b-vllm.service` issued; cold load completed in ~7m43s
664:   (18:02:58 → 18:10:41 UTC, `Application startup complete`), matching
665:   Phase 2's timing. Confirmed via `systemctl --user status`
666:   (`active (running)`), `/health` (200 OK), and `/v1/models`
667:   (`max_model_len: 917504`, i.e. the 896K production context). Ran the
668:   same smoke-test shape as Task 1.2, this time against the actual
669:   production systemd service rather than an ad-hoc launch — **all
670:   checks passed**:
671:   - **Coherent output** (temperature=0, fib-with-memoization prompt):
672:     correct, non-degenerate Python code — not the `feat-1`/`feat-2`
673:     frozen-token signature.
674:   - **Tool-calling**: `get_weather("Paris")` returned a clean
675:     `tool_calls[0].function.arguments = {"location": "Paris"}` with
676:     `finish_reason: "tool_calls"`, `content: null`.
677:   - **ACC-003's exact 3 thinking-control modes** (17×24 arithmetic,
678:     correct answer=408 every time): `enable_thinking: false` →
679:     `reasoning: null`, direct `content: "408"`; `reasoning_effort: medium` → 44-char reasoning, correct answer; `reasoning_effort: xhigh` → 161-char reasoning (visibly more elaborate than medium,
680:     correctly scaled), correct answer.
681:     Post-test health check: service still `active (running)`, no
682:     errors/warnings in the journal, `free -h` showed ~19 GiB
683:     available/1.6 GiB free — consistent with Task 2.3's measured 896K
684:     headroom (19.28 GiB). **Service left running** (not stopped) so
685:     Task 4.3 can reuse it for the real filled-context request. ACC-003's
686:     curl portion is satisfied; its "real OpenCode agentic session" leg
687:     remains for Phase 5.
688: - [x] Task 4.3: Validate the finalized production context size end-to-end
689:   (a real filled-context request, not just a load-time VRAM probe)
690:   works without OOM — depends on: Task 4.2 — status: done 2026-08-23 —
691:   built a REAL 899,067-token prompt with the model's own tokenizer
692:   (`/home/admin/build_prompt_896k.py` → `/home/admin/prompt-896k.txt`,
693:   same technique as Task 2.1's 768K test, not a synthetic estimate) and
694:   POSTed it to the live, already-running production
695:   `qwen3.8-27b-vllm.service` from Task 4.2 (not a fresh ad-hoc launch).
696:   **Result: HTTP 200, no OOM**, `usage.total_tokens: 899,117`
697:   (899,067 prompt + 50 completion) — comfortably within the 917,504
698:   max-model-len with ~18.4K tokens of headroom to spare, matching the
699:   margin design from Task 2.1/2.2. Wall time: 3582s (~59.7 min) — for
700:   scale, 768K took 45 min (FP8 KV cache, Task 2.1); the extra ~15 min
701:   for +131K tokens (17% more context) is directionally consistent, not
702:   a red flag on its own, but is folded into the existing throughput
703:   observation (see Phase 1/2's non-blocking note) rather than treated
704:   as a new finding. Service confirmed still `active (running)`, no
705:   errors/OOM-kills in the journal, `free -h` showing ~1.9 GiB free /
706:   18 GiB available afterward — consistent with (not degraded from)
707:   Task 2.3's measured 896K headroom (19.28 GiB free).
708:   **Caveat honestly flagged, not swept under the rug:** the test
709:   payload set `enable_thinking: false` as a top-level JSON field
710:   (copied from Task 2.1's own payload shape, written before Task 1.2
711:   established the correct `chat_template_kwargs: {"enable_thinking": false}` form) — this did NOT suppress thinking here: the response
712:   came back `finish_reason: "length"` with a non-empty, truncated
713:   `reasoning` field and `content: null` (ran out of the intentionally
714:   tiny `max_tokens: 50` mid-thought). This is a test-payload
715:   parameter-shape artifact, not evidence of a service defect — Task
716:   4.2 already separately verified the correct `chat_template_kwargs`
717:   form disables thinking correctly on this exact service. Task 4.3's
718:   actual acceptance bar (a real filled-context request completes
719:   without OOM) is unaffected and cleared regardless of the
720:   completion's content.
721: 
722: #### Phase 5: Integration
723: 
724: - [x] Task 5.1: Connect OpenCode to the Qwen3.8-27B endpoint as a separate
725:   model entry — depends on: Task 4.3 — status: done 2026-08-23 (OpenCode
726:   leg only; OpenWebUI wiring explicitly deferred/out of scope for this
727:   task per user decision — no OpenWebUI deployment/config details were
728:   available to act on) —
729:   1. Added `--served-model-name qwen3.8:27b-bf16` to
730:      `/home/admin/scripts/qwen3.8-27b-vllm-896k.sh` (mirrors `feat-2`'s
731:      `--alias` fix): before this change `/v1/models` reported the raw
732:      checkpoint path (`/home/admin/models/qwen3.8-27b`) as the model id;
733:      confirmed via a live `curl` before the change.
734:   2. Restarted `qwen3.8-27b-vllm.service` (`systemctl --user restart`);
735:      cold load ~9 min, consistent with prior Task 4.2/1.1 timings.
736:      Confirmed `active (running)`, `/health` 200 OK, and `/v1/models` now
737:      reports the clean id `qwen3.8:27b-bf16` (`max_model_len: 917504`
738:      unchanged). Re-ran a `chat_template_kwargs: {"enable_thinking": false}` smoke request against the new served name — correct answer,
739:      `finish_reason: "stop"` — service unaffected by the rename.
740:   3. Produced the OpenCode provider snippet (GB10 LAN IP
741:      `192.168.1.46`, port 8000, matching the box's `hostname -I`
742:      output) for the user to paste into their own `opencode.jsonc`
743:      `provider` object — NOT written into any config on this box, same
744:      "standalone snippet" precedent as `feat-2`:
745:      ```jsonc
746:      "vllm-dgx": {
747:          "npm": "@ai-sdk/openai-compatible",
748:          "name": "vllm (DGX)",
749:          "options": { "baseURL": "http://192.168.1.46:8000/v1" },
750:          "models": {
751:              "qwen3.8:27b-bf16": {
752:                  "name": "qwen3.8:27b-bf16",
753:                  "limit": { "context": 917504, "output": 65536 }
754:              }
755:          }
756:      }
757:      ```
758:      `limit.context` set to 917504 (the actual deployed 896K
759:      `max_model_len`), not the 768000 floor from REQ-003 — flagged to
760:      the user as a deliberate deviation from their initial draft value.
761:      Unauthenticated-endpoint caveat carried forward from `feat-2`: if
762:      OpenCode's `@ai-sdk/openai-compatible` provider errors on a missing
763:      key, add `"apiKey": "not-needed"` under `"options"`.
764:   4. **OpenWebUI wiring is NOT covered by this task's `done` status** —
765:      user explicitly chose to skip it for now (no OpenWebUI
766:      deployment/connection-mechanism details were available in this
767:      session, same gap noted as unresolved in both `feat-1` and
768:      `feat-2`). If OpenWebUI integration is needed later, it should be
769:      scoped as a follow-up task with its own dependency info gathered
770:      first (is it a separate service, env-var-driven, or admin-UI
771:      "Add Connection").
772: - [x] Task 5.2: User runs the same coding-task examples from `feat-1`/
773:   `feat-2` against this endpoint for a direct three-way quality
774:   comparison — depends on: Task 5.1 — status: DONE 2026-08-23 (checkbox
775:   fixed 2026-08-24 — Progress already recorded this as complete but the
776:   checkbox itself was never flipped, a documentation bug caught during
777:   this session's wrap-up). User ran their coding-task examples via
778:   OpenCode against the production BF16 endpoint at the time. **Caveat
779:   carried into ACC-011**: this was run against BF16, since superseded by
780:   NVFP4 (Task 6.2) — not re-run against the current NVFP4 production
781:   endpoint, so ACC-011's formal three-way comparison record is still
782:   open pending that re-run.
783: 
784: #### Phase 6: Compare with Qwen3.8-27B-NVFP4 (community benchmark cross-check)
785: 
786: Reference sources (both from the NVIDIA DGX Spark/GB10 forum, added
787: 2026-08-23; same hardware class as our GB10 — 121.63 GiB unified memory
788: vs. our measured 119.63 GiB pool — and the SAME `qwen3_5`-family hybrid
789: layout our Design Notes already record: 48 linear-attention + 16
790: full-attention layers, matching our 16×(3×Gated DeltaNet→FFN)→1×(Gated
791: Attention→FFN)):
792: 
793: - Source A: <https://forums.developer.nvidia.com/t/qwen3-8-27b-nvfp4-on-a-single-dgx-spark-up-to-1m-context-vllm-mtp-measurements/380244>
794:   — single DGX Spark, `unsloth/Qwen3.8-27B-NVFP4`, vLLM
795:   `0.26.1rc1.dev244+gd6a593feb` nightly + MTP speculative decoding
796:   (built-in draft head, no separate model needed)
797: - Source B: <https://forums.developer.nvidia.com/t/qwen3-8-27b-on-dual-sparks/380350>
798:   — dual-Spark TP=2 (vLLM+MTP and SGLang+DFlash2 variants); not
799:   directly comparable to our single-GB10 deployment, kept as an
800:   upper-bound/different-engine reference only
801: 
802: Key reference numbers preserved here for continuity (avoids re-fetching
803: the threads in a future session):
804: 
805: | Config (Source) | Decode | Prefill | Notes |
806: |---|---|---|---|
807: | Single Spark, vLLM+MTP `num_speculative_tokens=5`, native 262144 ctx (A) | 24.0 tok/s (thinking) / 26.0 tok/s (no-thinking) | — | Bubblesort prompt, temp=0, streaming, median of 5 |
808: | Single Spark, vLLM, `num_speculative_tokens=0` (no spec decode) (A) | **11.4 tok/s** | — | **Cleanest same-engine, no-spec-decode NVFP4 baseline — the direct precision-only comparison point** |
809: | Single Spark, vLLM, unique-prefix prefill (A) | — | 4,566 tok @ 1,734 tok/s; 11,988 tok @ 1,153 tok/s; 24,015 tok @ 1,014 tok/s; 47,857 tok @ 853 tok/s | Must use a distinct prefix per request — prefix caching otherwise inflates the number (A's own "three ways I fooled myself" section) |
810: | KV-cache cost, native 262144 ctx, fp8 KV (A) | — | — | 37,169 bytes/token measured (12% above the 32,768 B naive calc); 777,645-token KV capacity at `--gpu-memory-utilization 0.45`; 1M context needs >=0.53, 0.60 recommended for headroom |
811: | Dual Spark, vLLM+MTP `num_speculative_tokens=2` (stability tradeoff) (B) | 22.6 tok/s (1 session) → 75.0 tok/s (4 sessions, aggregate) → 116.1 tok/s (8 sessions, aggregate) | — | ~5x aggregate throughput at 8-way concurrency vs. 1 session on 1 Spark |
812: | Single/Dual Spark, SGLang+DFlash2 (B, different engine) | 52-61 / 87 tok/s (code); 26 / 41 tok/s (prose); 34-49 / 49 tok/s (thinking chat) | ~10K tok/s | HumanEval pass@1 159/164 (97.0%); tool-eval-bench 92/100 (★★★★★); DFlash2 is lossless (greedy output matches target model) but incompatible with YaRN >262K on that build |
813: 
814: - [x] Task 6.1: Compare the performance of our production BF16
815:   installation (`qwen3.8-27b-vllm.service`) against the published
816:   NVFP4 data above — depends on: Task 4.3 — status: done 2026-08-23 —

(Output capped at 50 KB. Showing lines 1-816. Use offset=817 to continue.)
</content>
```

**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-4-qwen3.8-27b-dell-7960t/README.md"
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-4-qwen3.8-27b-dell-7960t/README.md</path>
<type>file</type>
<content>
1: ---
2: created: 2026-08-25
3: github_issue: 4
4: id: feat-4-qwen3.8-27b-dell-7960t
5: status: planning
6: updated: 2026-08-25
7: version: 1.0.0
8: ---
9: 
10: # Feature: On-prem Qwen3.8-27B serving with extended context on the Dell 7960T
11: 
12: ## Plan
13: 
14: ### Overview
15: 
16: Deploy `Qwen/Qwen3.8-27B` (the same model as `feat-3`, dense causal LM + vision
17: encoder, 27B params, Apache-2.0) via vLLM on the **Dell 7960T** — the box
18: already hosting `feat-1` (DeepSeek-V4-Flash) and `feat-2` (GLM-5.2) — as a
19: **dedicated, on-demand** service pinned to a single GPU, at a **fixed 896K
20: (917,504-token) context** via the vendor's documented YaRN `rope_parameters`
21: override.
22: 
23: This is explicitly a re-deployment of a model `feat-3` already fully
24: validated on different hardware (a GB10/DGX-Spark-clone with one **unified**
25: 128GB CPU+GPU memory pool, arm64). The Dell 7960T is a fundamentally
26: different shape of box: x86_64, **4x RTX PRO 6000 Blackwell Max-Q, 96GB
27: *discrete* VRAM each (384GB total)**, plus a fully separate 512GB system RAM
28: pool, and **no NVLink between any of the 4 GPUs** (confirmed via
29: `nvidia-smi topo -m`: every GPU pair shows `NODE`, i.e. PCIe-through-host-
30: -bridge only). That changes which of `feat-3`'s hard-won findings transfer
31: and which don't:
32: 
33: - `feat-3`'s core Phase 2 problem — `--gpu-memory-utilization` silently
34:   starving the *OS* because VRAM and system RAM share one pool — **cannot
35:   happen on this box**: VRAM (per-GPU) and system RAM are physically
36:   separate pools here. Still good practice to size KV cache explicitly, but
37:   it is not the load-bearing fix it was on the GB10.
38: - Qwen3.8-27B (~54GB BF16 weights) fits comfortably inside a **single 96GB
39:   GPU**, unlike `feat-1`'s DeepSeek-V4-Flash, which needs `--tensor-parallel- -size 4` to fit at all. There is no a priori need to span multiple GPUs
40:   here, and — since none of the 4 GPUs have an NVLink interconnect between
41:   them — spanning GPUs via tensor-parallel is expected to *add* PCIe
42:   communication overhead for no capacity benefit, not help throughput. This
43:   must be measured (Phase 2), not assumed, but the working hypothesis is
44:   TP=1 wins.
45: - `feat-1` already found and is currently blocked by an **open, unresolved
46:   SM120-specific bug** (`vllm-project/vllm#52938`): DeepSeek-V4-Flash on
47:   these exact RTX PRO 6000 Blackwell GPUs produces degenerate output
48:   (frozen token / identical logprob at every decode position). `feat-3`'s
49:   Design Notes assumed this class of bug could not recur on the GB10
50:   because it uses different GPUs (SM121a, not SM120) — that assumption does
51:   **not** hold here, since this box has the exact GPU family the bug was
52:   found on. Qwen3.8-27B's hybrid Gated DeltaNet + Gated Attention layout is
53:   architecturally different from DeepSeek's sparse MLA attention, but this
54:   must be **verified, not assumed safe**, before any long-context work —
55:   hence Phase 1 is a hard gate here, not a formality.
56: - `feat-1` also already tried upgrading to vLLM 0.27.1 (the version `feat-3`
57:   pinned on the GB10) and had to **roll it back** — a hard "unsupported
58:   architecture" DeepGEMM gap for SM120. This feature stays on the box's
59:   already-working **vLLM 0.26.0** instead of adopting `feat-3`'s 0.27.1 pin.
60:   Live checks against the box's existing (feat-1) 0.26.0 venv on
61:   2026-08-25 already confirm this version registers `Qwen3_5ForConditional- Generation`/`Qwen3_5MTP` and has working NVFP4 GEMM kernels
62:   (`cutlass_scaled_mm_supports_fp4(120)` -> `True`) — see Task 0.2.
63: 
64: Unlike `feat-3`'s BF16-first-then-empirically-evaluate-NVFP4 journey, this
65: feature goes straight to comparing **BF16 vs NVFP4 vs NVFP4+MTP** at the
66: fixed 896K context, since `feat-3` already established (on the identical
67: model) that NVFP4 and MTP both give large, quality-neutral speedups — the
68: open question here is only how large the effect is on *this* hardware's
69: different bottleneck profile (dedicated GPU, no shared-pool contention,
70: different FlashInfer kernel path on SM120 vs. the GB10's SM121a), not
71: whether to try them at all.
72: 
73: **Isolation is a hard requirement, not a preference**: this feature's
74: install (venv, launch scripts, systemd units) must be fully independent of
75: `feat-1`'s `/data/vllm/.venv` — changing or upgrading anything in this
76: feature's dedicated `/data/qwen3.8-27b/` tree must never have side effects
77: on `feat-1` or `feat-2`, and vice versa. The only shared state is the
78: read-only Hugging Face download cache (`/data/nvidia/hf_cache`), which
79: carries no such coupling risk.
80: 
81: Every service this feature installs is **on-demand only** — started and
82: stopped exclusively by the user via `systemctl --user`, never auto-started
83: at boot, and with no single service auto-promoted to "the" production
84: default the way `feat-3` ended up doing after its own precision journey.
85: The user decides which variant (BF16 or NVFP4[+MTP]) runs at any given
86: time.
87: 
88: ### Requirements
89: 
90: - REQ-001: Serve Qwen3.8-27B via an OpenAI-compatible API
91:   (`/v1/chat/completions`) on the Dell 7960T, using vLLM, pinned to a single
92:   dedicated GPU (GPU2, by UUID) by default. If TP=2 (GPU2+GPU0, the box's
93:   two PCIe Gen5 x16 cards) is empirically shown to be faster (Phase 2),
94:   that becomes the pinned config instead — TP=4 (spanning all 4 GPUs, as
95:   `feat-1` does) is out of scope, since the model does not need the extra
96:   VRAM and doing so would prevent any coexistence with `feat-1`/`feat-2`
97: - REQ-002: The endpoint(s) must support a **fixed** context length of
98:   917,504 tokens (896K) via the vendor's documented YaRN `rope_parameters`
99:   override (factor 3.5) — no 768K-floor/1M-ceiling step-up exploration is
100:   in scope; 896K is the sole target, already proven sufficient and working
101:   on this exact model architecture by `feat-3`
102: - REQ-003: The endpoint(s) must support tool-calling (required for OpenCode
103:   agentic use) and correctly expose Qwen3.8's thinking controls:
104:   `enable_thinking` (on by default), `reasoning_effort`
105:   (`xhigh`/`medium`/`low`), and `preserve_thinking` — identical bar to
106:   `feat-3` REQ-004
107: - REQ-004: Empirically compare **BF16**, **NVFP4**, and **NVFP4 + MTP
108:   speculative decoding** at the fixed 896K/YaRN context, on this hardware.
109:   Adopt NVFP4 (optionally +MTP) as an available on-demand option only if it
110:   clears a measurable throughput improvement with no observed correctness
111:   regression (MTP's acceptance/verification step must be lossless —
112:   byte-identical greedy output vs. the non-MTP run at temperature=0, same
113:   bar `feat-3` Task 6.3 used) — mirrors `feat-3` REQ-005's "not adopted by
114:   default" bar, but MTP is explicitly requested up front for this feature
115:   (not gated behind a separate "is it worth it" decision the way it was
116:   for `feat-3`)
117: - REQ-005: Engine = vLLM, pinned to **0.26.0** (the version already
118:   installed and validated on this box's SM120 GPUs by `feat-1`) — **not**
119:   `feat-3`'s 0.27.1 pin, since `feat-1` already found that version regresses
120:   on this exact hardware (DeepGEMM/architecture-support gap for SM120).
121:   Installed in a **fully separate, dedicated venv**
122:   (`/data/qwen3.8-27b/.venv`), isolated from `feat-1`'s `/data/vllm/.venv`
123: - REQ-006: Pin `Qwen/Qwen3.8-27B` (BF16) and `unsloth/Qwen3.8-27B-NVFP4` to
124:   specific Hugging Face revisions/commits (not "latest") for reproducibility
125:   — reuse `feat-3`'s already-vetted NVFP4 revision
126:   (`7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108`) if still current at download
127:   time, re-verify the tokenizer-truncation fix is present either way; pin
128:   the BF16 revision fresh at download time
129: - REQ-007: The endpoint(s) run unauthenticated (anonymous, no API-key/auth
130:   layer) — accepted risk, internal network only (same posture as
131:   `feat-1`/`feat-2`/`feat-3`)
132: - REQ-008: Every engine variant runs exclusively as an **on-demand**
133:   systemd `--user` service (lingering enabled) — never auto-started at
134:   boot, never run as an ad-hoc foreground process, including during
135:   testing. The user starts/stops each variant explicitly via `systemctl --user`; no variant is ever auto-selected as "production" by default
136: - REQ-009: This feature's deployment must be **fully isolated** from
137:   `feat-1` (DeepSeek-V4) and `feat-2` (GLM-5.2): separate venv, separate
138:   launch scripts, separate systemd unit files, under a dedicated
139:   `/data/qwen3.8-27b/` tree — so that installing, upgrading, restarting, or
140:   debugging this feature's services has zero side effects on the other two
141:   features' services, and vice versa. The only permitted shared state is
142:   the read-only Hugging Face download cache (`/data/nvidia/hf_cache`), by
143:   explicit choice (it carries no code/package coupling risk)
144: - REQ-010: Before any long-context or precision work, run a native/short-
145:   context correctness smoke test that **explicitly checks for the exact
146:   degenerate-output signature** (a single frozen token / identical logprob
147:   repeated at every decode position) found on this same GPU family by
148:   `feat-1`'s open, unresolved bug (`vllm-project/vllm#52938`). This is a
149:   **hard gate**, not a formality — unlike `feat-3`'s GB10 (a different GPU
150:   family where this specific bug class does not apply), this box has the
151:   exact hardware the bug was found on
152: - REQ-011: Determine empirically (not assumed) whether GPU2-only (TP=1) or
153:   GPU2+GPU0 (TP=2, the box's two PCIe Gen5 x16 cards) gives better decode
154:   throughput. Since `nvidia-smi topo -m` confirms **no NVLink between any
155:   of the 4 GPUs** (every pair shows `NODE`, PCIe-through-host-bridge only),
156:   TP>1 is expected to add communication overhead without a capacity
157:   benefit — pin production to **GPU2-only (TP=1)** unless TP=2 is
158:   measurably faster
159: - REQ-012: YaRN `rope_parameters` override configured exactly per the
160:   vendor's documented shape, reused verbatim from `feat-3` REQ-011 (it is
161:   model-specific, not hardware-specific): `mrope_interleaved`,
162:   `mrope_section`, `rope_type: yarn`, `rope_theta`,
163:   `partial_rotary_factor: 0.25`, `factor: 3.5` (fixed, since REQ-002 fixes
164:   the target context at 896K), `original_max_position_embeddings: 262144`
165: - REQ-013: Vision/video (image+video understanding) capability is
166:   explicitly OUT of scope for testing/validation in this feature — text/
167:   coding only (same as `feat-3` REQ-012)
168: 
169: ### Acceptance Criteria
170: 
171: - [x] ACC-001: Verifies REQ-001/REQ-011 — Qwen3.8-27B running via vLLM on
172:   the Dell 7960T, reachable via `/v1/chat/completions`, pinned to GPU2 (or
173:   GPU2+GPU0 if TP=2 is empirically chosen instead), with the GPU-pinning
174:   decision backed by measured decode-throughput numbers, not assumed;
175:   `feat-1`/`feat-2`'s existing services and GPUs untouched — **done
176:   2026-08-25**: TP=2 (GPU2+GPU0) confirmed via Task 2.1's measured
177:   +64%/-31%/-41% numbers (Task 2.2); production unit
178:   `qwen3.8-27b-bf16-896k.service` reachable via `/v1/chat/completions`
179:   (Task 5.2); `feat-1`/`feat-2` confirmed untouched throughout (Task 0.5
180:   baseline, no shared state beyond the read-only HF cache)
181: - [x] ACC-002: Verifies REQ-002/REQ-012 — the endpoint serves the fixed
182:   917,504-token (896K) context via the exact YaRN `rope_parameters`
183:   override (factor 3.5), validated with a real filled-context request
184:   (built from the model's own tokenizer, not a synthetic estimate) that
185:   completes without OOM — **done 2026-08-25**: Task 3.3's real
186:   906,159-token request completed with `content: "Dell"` (correct fact
187:   recall), `finish_reason: "stop"`, no OOM; `/v1/models` on the
188:   production unit confirms `max_model_len: 917504`
189: - [x] ACC-003: Verifies REQ-003 — tool-calling and all three thinking-
190:   control modes (`enable_thinking: false`, `reasoning_effort: medium`,
191:   `reasoning_effort: xhigh`) verified via curl smoke test against every
192:   on-demand service variant that is ultimately installed (BF16, and
193:   NVFP4[+MTP] if adopted) — **done 2026-08-25**: only BF16 was ultimately
194:   installed (Task 4.5's decision), and Task 5.2 ran the full smoke test
195:   against that exact production unit: clean tool-call, all three
196:   thinking modes correctly scaled (0/44/125-char reasoning), all
197:   producing the correct answer
198: - [x] ACC-004: Verifies REQ-004 — a recorded BF16 vs. NVFP4 vs. NVFP4+MTP
199:   throughput comparison at the fixed 896K/YaRN context, with the final
200:   precision/MTP decision and its one-line rationale recorded; if MTP is
201:   adopted, its output is confirmed byte-identical (lossless) vs. the
202:   non-MTP run at temperature=0 on the same prompt — **done 2026-08-25**:
203:   Task 4.1 recorded the BF16-vs-NVFP4 comparison (both cheap-context and
204:   real-896K, exact absolute numbers); Task 4.5 recorded the final
205:   decision (BF16 only) and its rationale. The MTP leg was never run
206:   (explicit user decision after reviewing Task 4.1's numbers, before
207:   Task 4.2 was attempted) — the "if MTP is adopted" clause is therefore
208:   vacuously satisfied, not skipped: MTP was not adopted, so no
209:   byte-identical check was required
210: - [x] ACC-005: Verifies REQ-005 — vLLM 0.26.0 confirmed as the deployment
211:   engine version, installed in the dedicated `/data/qwen3.8-27b/.venv`,
212:   with the `qwen3_5` architecture and NVFP4 kernel support re-verified
213:   inside that specific venv (not just inferred from `feat-1`'s venv) —
214:   **done 2026-08-25**: Task 0.3 re-verified all three checks
215:   (`Qwen3_5ForConditionalGeneration`/`Qwen3_5MTP` registry,
216:   `cutlass_scaled_mm_supports_fp4(120)`, full CLI flag set) inside this
217:   feature's own dedicated venv, not `feat-1`'s
218: - [x] ACC-006: Verifies REQ-006 — deployment config records the exact HF
219:   revision/commit hash used for both the BF16 and NVFP4 checkpoints —
220:   **done 2026-08-25**: Task 0.6 recorded
221:   `Qwen/Qwen3.8-27B@1d4bf0f2ff6012fd82039f2fa52739d0dd7c60c0` (BF16) and
222:   `unsloth/Qwen3.8-27B-NVFP4@7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108`
223:   (NVFP4, reused verbatim from `feat-3` after re-verification); the
224:   production unit's `ExecStart --revision` flag pins the BF16 one
225:   explicitly
226: - [ ] ACC-007: Verifies REQ-007 — endpoint(s) reachable without credentials
227:   from the internal network, confirmed intentional (not an oversight) —
228:   **partially confirmed**: no `--api-key`/auth flag exists in any
229:   service unit this feature installed (by design, matching REQ-007's
230:   accepted-risk posture, same as `feat-1`/`feat-2`/`feat-3`), and every
231:   curl smoke test in this feature (Task 1.2, Task 5.2) succeeded without
232:   credentials — but those tests were all run from the box itself
233:   (`localhost`); reachability from a genuinely separate host on the
234:   internal network has not been separately tested, since this session
235:   only had shell access on the Dell 7960T itself, not a second client
236:   machine
237: - [x] ACC-008: Verifies REQ-008/REQ-009 — every installed service is a
238:   `systemctl --user` unit, left `disabled` (never auto-starts at boot),
239:   started/stopped exclusively via `systemctl --user` throughout testing;
240:   the dedicated `/data/qwen3.8-27b/` install tree is confirmed independent
241:   of `/data/vllm/.venv` (`feat-1`) and `feat-2`'s install tree — **done
242:   2026-08-25**: Task 5.1/5.2 confirm the production unit is `disabled`
243:   with no `default.target.wants/` symlink; Task 0.3 confirms the isolated
244:   venv tree
245: - [x] ACC-009: Verifies REQ-010 — the native/short-context smoke test
246:   explicitly checked for and did not reproduce `feat-1`'s SM120 degenerate-
247:   output signature, before any YaRN/precision work began — **done
248:   2026-08-25**: Task 1.2/1.3, confirmed NOT reproduced, hard gate cleared
249:   before Phase 2 started
250: - [x] ACC-010: Verifies REQ-013 — vision/video capability explicitly not
251:   tested/validated in this feature (scope confirmation, not a functional
252:   check)
253: 
254: ### Scope
255: 
256: What is included in this feature:
257: 
258: - A dedicated, fully isolated Phase 0 environment build on the Dell
259:   7960T (`/data/qwen3.8-27b/.venv`, vLLM 0.26.0) — independent of `feat-1`'s
260:   existing `/data/vllm/.venv`
261: - A native-context correctness smoke test explicitly checking for
262:   `feat-1`'s known SM120 degenerate-output signature, before any long-
263:   -context or precision work (hard gate, per REQ-010)
264: - An empirical TP=1 (GPU2-only) vs. TP=2 (GPU2+GPU0) decode-throughput
265:   comparison, to decide GPU pinning (REQ-011)
266: - Applying and validating the YaRN-based 896K context extension (fixed
267:   target, no step-up/down sweep) per the vendor's documented
268:   `rope_parameters` override
269: - An empirical BF16 vs. NVFP4 throughput comparison at both a cheap
270:   sanity context and the fixed 896K/YaRN context (Task 4.1) — this
271:   comparison is what decided NOT to pursue NVFP4/MTP further, per REQ-004
272:   (see Task 4.5)
273: - One on-demand, disabled `systemctl --user` service — BF16 at 896K, the
274:   sole adopted variant — that the user starts/stops manually
275: - Pinning both the BF16 and NVFP4 checkpoints to fixed HF revisions (the
276:   NVFP4 checkpoint was downloaded and benchmarked per Task 0.6/Task 4.1
277:   even though it was ultimately not adopted as a service)
278: - An OpenCode provider snippet for the installed BF16 896K service
279: 
280: What is explicitly out of scope:
281: 
282: - Any modification to `feat-1` (DeepSeek-V4) or `feat-2` (GLM-5.2)'s
283:   deployments, venvs, systemd units, or GPU allocation beyond GPU2 (and
284:   GPU0, only if TP=2 is chosen) — this feature runs only on GPU2 (+GPU0 if
285:   needed) and does not touch the other two features
286: - 768K or 1M context sizes — REQ-002 fixes the target at 896K only, no
287:   step-up/down exploration (explicit user decision, given 896K is already
288:   proven sufficient and working on this model by `feat-3`)
289: - A Q8/FP8 weight-quantization comparison leg — explicitly dropped in
290:   favor of BF16 vs. NVFP4(+MTP) only (explicit user decision)
291: - NVFP4 and NVFP4+MTP as installed/adopted service variants — Task 4.1's
292:   measurement at the fixed 896K/YaRN context showed no throughput
293:   advantage over BF16 there (despite a real +54% win at a cheap 8192
294:   context), and the user made an explicit 2026-08-25 decision to stop
295:   investing in the NVFP4 branch entirely on that basis, without running
296:   Task 4.2's MTP leg — BF16 is the sole production precision (see Task
297:   4.5)
298: - Any single service being auto-promoted to "the" production default —
299:   the one adopted BF16 variant stays on-demand and user-started (unlike
300:   `feat-3`, which ended up cutting BF16 over to a single always-adopted
301:   NVFP4+MTP production service)
302: - Testing or validating vision-language (image/video) capability (REQ-013)
303: - Fine-tuning or training Qwen3.8-27B (serving only)
304: - Authentication/access-control layer (explicitly accepted as anonymous)
305: - OpenWebUI wiring (deferred/optional, same precedent as `feat-3`)
306: - Ollama/llama.cpp/GGUF as the serving path — same rationale as `feat-3`:
307:   the vendor's YaRN long-context documentation only covers vLLM, SGLang,
308:   and TokenSpeed, and Qwen3.8-27B's hybrid Gated DeltaNet + partial-rotary/
309:   mrope architecture is judged too high-risk for an independent llama.cpp
310:   YaRN re-implementation
311: 
312: ### Dependencies
313: 
314: - Depends on: the Dell 7960T's existing driver/CUDA stack (already
315:   installed and validated by `feat-1`/`feat-2` — driver 610.57.04, CUDA
316:   13.3, 4x RTX PRO 6000 Blackwell Max-Q/SM120, confirmed live 2026-08-25,
317:   see Task 0.2); a fresh, fully isolated vLLM 0.26.0 venv (Task 0.3) — NOT
318:   inherited from `feat-1`'s `/data/vllm/.venv`, built independently to
319:   guarantee REQ-009's isolation; HF access/download tooling (already
320:   present and working per `feat-1`'s cache under `/data/nvidia/hf_cache`);
321:   sufficient disk headroom under `/data` (7TB free confirmed 2026-08-25 —
322:   trivial for ~54GB BF16 + ~23GB NVFP4)
323: - Related (not a hard dependency): `feat-1`'s **open, unresolved** SM120
324:   degenerate-output bug (`vllm-project/vllm#52938`) — directly relevant
325:   here (same GPU family), unlike `feat-3`'s GB10 (different GPU, the bug
326:   does not apply there) — see REQ-010; `feat-1`'s vLLM 0.27.1 rollback
327:   finding (DeepGEMM/SM120 regression) — directly informs REQ-005's version
328:   pin; `feat-3`'s already-published YaRN factor-table entry for 896K
329:   (factor 3.5), NVFP4 checkpoint pin, and MTP methodology — reused
330:   verbatim wherever a finding is architecture-driven rather than hardware-
331:   -driven (`feat-3` Task 6.2 step 4 already showed KV-cache token capacity
332:   at a given context is architecture-driven, not precision- or hardware-
333:   -pool-driven, though it must still be re-measured on this box's discrete-
334:   -VRAM GPU rather than assumed identical to the GB10's unified-pool
335:   numbers)
336: - Blocks: none
337: 
338: ### Design Notes
339: 
340: - **Model facts**: identical to `feat-3` — `Qwen/Qwen3.8-27B`, Apache-2.0,
341:   dense causal LM + vision encoder, 27B language-model params (28B total on
342:   disk, BF16 safetensors). Hybrid layout: 16x (3x (Gated DeltaNet -> FFN)
343:   -> 1x (Gated Attention -> FFN)), 64 layers total. Native context 262,144,
344:   extensible via YaRN. See `feat-3`'s Design Notes for the full
345:   architectural detail — not repeated here.
346: 
347: - **Hardware verified live on this box, 2026-08-25** (all read-only checks,
348:   no state changed): 4x RTX PRO 6000 Blackwell Max-Q, 96GB VRAM each, all
349:   idle (0 MiB used) at check time; driver 610.57.04, CUDA (nvidia-smi)
350:   13.3; `nvidia-smi topo -m` shows `NODE` (PCIe-through-host-bridge, no
351:   NVLink) between every one of the 6 GPU pairs; per-GPU PCIe generation:
352:   GPU0 and GPU2 are Gen5 x16, GPU1 and GPU3 are Gen4 x16
353:   (`pcie.link.gen.max`); GPU2 chosen over GPU0 for the default single-GPU
354:   pin because `hardware/dell-7960t/configuration.md` notes GPU0
355:   occasionally holds an Ollama-resident model (~43GB) — no Ollama
356:   process/service was found running on the box at check time, but GPU2 is
357:   the cleaner choice to avoid that class of contention recurring later.
358: 
359: - **Why no NVLink changes the multi-GPU calculus vs. `feat-1`**: `feat-1`'s
360:   DeepSeek-V4-Flash *needs* `--tensor-parallel-size 4` just to fit the
361:   model at all — TP is load-bearing there regardless of interconnect
362:   quality. Qwen3.8-27B does not need the extra VRAM (54GB BF16 fits one
363:   96GB GPU with room to spare for a 896K KV cache), so TP here is purely a
364:   throughput question, and with no NVLink between any GPU pair, splitting
365:   compute across GPUs was expected to add real PCIe communication latency
366:   per decode step for no offsetting capacity gain — the working hypothesis
367:   going into Phase 2 was that TP=1/GPU2-only wins or ties TP=2, not that
368:   TP=2 helps. **Superseded by Task 2.1's measurement (2026-08-25): this
369:   hypothesis was WRONG.** TP=2 (GPU2+GPU0) beat TP=1 by +64% output
370:   throughput and -31%/-41% TTFT/TPOT at BF16/8192-context/1024-in-512-out
371:   — at this precision/context, compute is evidently the bottleneck, not
372:   inter-GPU communication, so the PCIe-only interconnect's added latency
373:   is outweighed by having twice the compute available. Production is
374:   pinned to GPU2+GPU0 (TP=2) — see Task 2.2. Left this paragraph in place
375:   (rather than deleting it) precisely because the "measure, don't assume"
376:   methodology this feature otherwise preaches is best illustrated by a
377:   hypothesis that turned out to be wrong once actually measured.
378: 
379: - **Post-completion follow-up (2026-08-25): does TP=2's win hold for a
380:   SINGLE request, and would TP=4 help further?** Asked after the feature's
381:   core scope (Phases 0-6.1) was already done. Two sub-findings:
382: 
383:   - **Single-request (concurrency=1) latency, TP=1 vs. TP=2, matched
384:     1024-in/512-out/8192-context shape**: TP=2 wins decisively here too,
385:     not just under Task 2.1's 64-concurrent-request batched load — mean
386:     TTFT 218.41 ms (TP=2) vs. 281.97 ms (TP=1, −23%); mean TPOT 20.37 ms
387:     vs. 37.71 ms (**−46%, ~1.85x faster decode**). Confirms the workload
388:     is genuinely compute-bound even at batch size 1: the per-token
389:     all-reduce payload TP requires (one ~10 KB BF16 hidden-state vector
390:     per layer) is small enough that PCIe-only (no NVLink) synchronization
391:     does not erase the benefit of halving each layer's GEMM FLOPs across
392:     2 GPUs. Logs:
393:     `bin/baselines/2026-08-25-single-request-tp{1,2}.log`.
394: 
395:   - **TP=3 is not a valid configuration for this model** — checked before
396:     testing, not assumed: Qwen3.8-27B has only 4 KV heads (GQA,
397:     `num_key_value_heads: 4` in `config.json`), and vLLM's tensor-parallel
398:     sharding requires the TP size to divide the KV-head count evenly;
399:     only TP=1/2/4 are possible, TP=3 is architecturally excluded.
400: 
401:   - **TP=4 first attempt was NOT successfully measured** — attempting it
402:     triggered a real hardware/driver incident (GPU1 dropped off the PCIe
403:     bus mid-warmup, cascading NVRM RPC failures on GPU3), not a benign
404:     software/config bug. Full incident detail logged in
405:     `hardware/dell-7960t/recovery.md`'s "Incident log" section (this is a
406:     box-wide hardware concern, not feature-specific, hence logged there
407:     rather than only here).
408: 
409:   - **TP=4 re-attempt, after the hardware fault was physically fixed
410:     (2026-08-25, same day)**: re-ran the *exact same* diagnostic unit
411:     (`qwen3.8-27b-bf16-tp4-bench.service`, unchanged) with close
412:     monitoring through the exact warmup window that crashed last time
413:     (kernel-log tailing + GPU polling every ~6s). This time it came up
414:     completely cleanly — engine init/graph-capture/warmup completed in
415:     78.68s with zero NVRM/Xid errors, `/health` returned 200 within 3s of
416:     the server starting, `/v1/models` responded correctly. Ran the same
417:     `vllm bench serve` methodology as Task 2.1
418:     (`--backend openai-chat --tokenizer Qwen/Qwen3.8-27B --dataset-name random --random-input-len 1024 --random-output-len 512 --num-prompts 128 --max-concurrency 64 --request-rate inf --ignore-eos`), 128/128 requests
419:     succeeded, 0 failures:
420: 
421:     | metric | TP=1 (GPU2) | TP=2 (GPU2+GPU0) | TP=4 (all 4 GPUs) |
422:     |---|---|---|---|
423:     | Output tok/s | 746.35 | 1222.74 | 1215.93 |
424:     | Total tok/s | 2315.41 | 3793.33 | 3772.19 |
425:     | Req/s | 1.46 | 2.39 | 2.37 |
426:     | Mean TTFT (ms) | 7144 | 4953 | 5389.58 |
427:     | Mean TPOT (ms) | 71.74 | 42.63 | 42.09 |
428: 
429:     **TP=4 essentially ties TP=2 — it does NOT deliver the further
430:     ~1.5-1.8x this Design Notes entry previously flagged as an
431:     unverified extrapolation.** Every metric is within ~1-9% of TP=2
432:     (TTFT is actually 9% worse; output/total tok/s and req/s are
433:     ~0.5-0.9% lower; TPOT is ~1.3% better, within noise for n=128). The
434:     TP=1→TP=2 near-linear scaling (Task 2.1) does not continue into
435:     TP=2→TP=4 — going from 2 to 4 GPUs adds no further throughput or
436:     latency benefit at this model/precision/context (BF16, 8192 ctx,
437:     1024-in/512-out, 64 concurrency). Plausible explanation (not
438:     independently verified): Qwen3.8-27B's GQA has only 4 KV heads, and
439:     the model is small enough (27B) that 2 GPUs already saturate
440:     whatever compute-bound advantage TP offers here — a 4-way split adds
441:     proportionally more communication overhead per layer without a
442:     matching per-GPU compute reduction once the per-GPU compute is
443:     already small. Full log:
444:     `bin/baselines/2026-08-25-task-tp4-bench.log`. Diagnostic service
445:     stopped afterward, all 4 GPUs confirmed freed, zero NVRM/Xid errors
446:     throughout the entire attempt (kernel log monitored live end-to-end).
447:     TP=4 remains out of this feature's production scope regardless
448:     (REQ-001) — this was a pure research probe, not a step toward
449:     changing that scope; the number now exists, but it argues against
450:     TP=4, not for it.
451: 
452: - **Why `feat-1`'s open SM120 bug is a real (not theoretical) risk here,
453:   unlike for `feat-3`**: `feat-1`'s bug
454:   (`vllm-project/vllm#52938`) is specific to SM120 (this box's GPU family)
455:   and DeepSeek-V4-Flash's sparse MLA attention kernel
456:   (`FLASHINFER_MLA_SPARSE_DSV4`). Qwen3.8-27B's Gated DeltaNet + Gated
457:   Attention layout is a different kernel path, so there is no strong
458:   reason to expect the *same* bug to recur — but there is also no
459:   vLLM/FlashInfer track record yet of this specific architecture running
460:   cleanly on SM120 at all (it was only ever validated on `feat-3`'s SM121a
461:   GB10). Phase 1's smoke test exists specifically to close this gap before
462:   any further investment, mirroring the exact check `feat-3` ran on the
463:   GB10 for the same reason (new platform, new architecture, verify before
464:   extending).
465: 
466: - **Why staying on vLLM 0.26.0, not `feat-3`'s 0.27.1**: `feat-1`'s
467:   Decisions Made record a trial upgrade to 0.27.1 (with flashinfer 0.6.17)
468:   that was rolled back after hitting a hard, unconditional "unsupported
469:   architecture" DeepGEMM gap for SM120. Since this box's GPUs are SM120
470:   (not `feat-3`'s SM121a, where 0.27.1 was required for `qwen3_5`/NVFP4
471:   support), there is no reason to take on that known regression here — the
472:   box's already-installed 0.26.0 was live-checked on 2026-08-25 (against
473:   `feat-1`'s existing venv, as a fast proxy) and already registers
474:   `Qwen3_5ForConditionalGeneration`/`Qwen3_5MTP`, has working NVFP4 GEMM
475:   kernels (`cutlass_scaled_mm_supports_fp4(120)` -> `True`), and exposes
476:   every CLI flag this feature needs (`--kv-cache-dtype`,
477:   `--kv-cache-memory-bytes`, `--hf-overrides`, `--speculative-config`,
478:   `--tensor-parallel-size`, `--served-model-name`, `--tool-call-parser qwen3_xml`, `--reasoning-parser`, `--linear-backend`). Task 0.3 still
479:   re-runs these same checks inside the feature's own dedicated venv before
480:   trusting them for real (REQ-009 isolation means the existing venv's
481:   state is only a proxy, not a substitute).
482: 
483: - **Isolation implementation**: dedicated tree `/data/qwen3.8-27b/`
484:   contains its own `.venv`, launch scripts, and (via
485:   `~/.config/systemd/user/`) its own systemd unit files — no file or
486:   package under this tree is shared with `/data/vllm/.venv` (`feat-1`) or
487:   `feat-2`'s `/data/llama.cpp-dsa` tree. The single deliberate exception is
488:   the read-only Hugging Face download cache (`HF_HOME=/data/nvidia/hf_cache`,
489:   matching `feat-1`'s existing convention) — a cache directory carries no
490:   code/package coupling risk, so sharing it does not violate REQ-009.
491: 
492: - **YaRN config (fixed, not a table)**: since REQ-002 fixes the target
493:   context at 896K (917,504 tokens), only one factor value is needed —
494:   `factor: 3.5` — reused verbatim from `feat-3`'s vendor-documented
495:   override shape:
496:   `{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 3.5, "original_max_position_embeddings": 262144}}}`
497:   passed via `--hf-overrides` (needs `VLLM_ALLOW_LONG_MAX_MODEL_LEN=1`).
498: 
499: - **On-demand-only service model (explicit user decision, differs from
500:   `feat-3`)**: `feat-3` started with multiple disabled services and ended,
501:   after its own precision journey, with exactly one auto-promoted
502:   "production" service (NVFP4+MTP at 896K) and the rest kept as disabled
503:   fallbacks. This feature does **not** converge to a single default —
504:   every adopted variant (BF16, and NVFP4[+MTP] if it clears REQ-004's bar)
505:   stays installed as its own disabled, on-demand `systemctl --user` unit,
506:   and the user decides at any given time which one (if any) is running.
507:   This also means, unlike `feat-3`, there is no expectation that this
508:   feature's service(s) run continuously — coexistence with `feat-1`/
509:   `feat-2` is handled by keeping this feature's GPU footprint to GPU2 (or
510:   GPU2+GPU0) only, not by any runtime scheduling logic.
511: 
512: - **NO environment inheritance from `feat-1`/`feat-2`'s venvs/install
513:   trees**, by design (REQ-009) — the only things inherited are the box's
514:   driver/CUDA stack (already shared infrastructure, not a venv), the
515:   shared HF cache directory (deliberate, low-risk exception), and
516:   practice/precedent (systemd `--user`-lingering pattern, HF-pin
517:   discipline, no-auth internal posture, "measure don't assume" capacity
518:   methodology) from `feat-1`/`feat-2`/`feat-3`.
519: 
520: - **Model-architecture-driven findings reused verbatim from `feat-3`**
521:   (i.e., not hardware-pool-dependent, so no need to re-derive): the YaRN
522:   `rope_parameters` override shape and factor-to-context mapping; the
523:   `qwen3_xml` tool-call-parser / `qwen3` reasoning-parser choice (derived
524:   from the model's own `chat_template.jinja`, not from GB10-specific
525:   behavior); the NVFP4 checkpoint's mixed quantization scheme (NVFP4 MLPs,
526:   FP8 attention/`lm_head`/last-8-layers, MTP draft head bundled in the
527:   same `unsloth/Qwen3.8-27B-NVFP4` repo, no separate `speculative-config "model"` field needed); the tokenizer-truncation-bug check (`tokenizer. json`'s `truncation` field must be `null`) before trusting a downloaded
528:   NVFP4 revision. **Not** reused as-is, requires fresh measurement on this
529:   box: KV-cache byte-per-token/capacity/headroom numbers (different memory
530:   pool shape), decode/prefill throughput numbers (different GPU, no shared-
531:   -pool contention, possibly different FlashInfer kernel selection on
532:   SM120 vs. SM121a), and the TP=1-vs-TP=2 question (`feat-3` never tested
533:   multi-GPU at all, since the GB10 only has one GPU).
534: 
535: ### Related ADRs
536: 
537: - None (infrastructure/deployment work, tracked in this repo using the
538:   feature-folder convention, same as `feat-1`/`feat-2`/`feat-3`)
539: 
540: ### Task List
541: 
542: #### Phase 0: Environment prep (dedicated, isolated install)
543: 
544: - [x] Task 0.1: Confirm disk headroom under `/data` for the new dedicated
545:   tree plus BF16 (~54GB) and NVFP4 (~23GB) weights — depends on: none —
546:   status: done 2026-08-25 — `/data` (`/dev/md126`) has 7.0 TB free of
547:   15 TB (53% used) — trivial, no cleanup required
548: - [x] Task 0.2: Confirm the Dell 7960T's existing driver/CUDA are installed
549:   and working, AND — as a fast read-only proxy check before building the
550:   feature's own isolated venv — confirm the box's existing (`feat-1`)
551:   vLLM 0.26.0 install already supports Qwen3.8-27B's architecture and
552:   NVFP4 kernels on SM120 — depends on: none — status: done 2026-08-25 —
553:   driver 610.57.04 / CUDA (nvidia-smi) 13.3 confirmed, matches
554:   `hardware/dell-7960t/configuration.md`; `/data/vllm/.venv`'s vLLM 0.26.0
555:   registers `Qwen3_5ForConditionalGeneration`/`Qwen3_5MTP` in its
556:   `ModelRegistry`; `cutlass_scaled_mm_supports_fp4(120)` returns `True`
557:   (compute capability confirmed `(12, 0)` on all 4 GPUs); `vllm serve --help=all` confirms every CLI flag this feature needs is present
558:   (`--kv-cache-dtype` incl. `fp8`/`nvfp4`, `--kv-cache-memory-bytes`,
559:   `--hf-overrides`, `--speculative-config`, `--tensor-parallel-size`,
560:   `--served-model-name`, `--tool-call-parser qwen3_xml`,
561:   `--reasoning-parser`, `--enable-auto-tool-choice`, `--linear-backend`
562:   incl. `flashinfer_b12x`). **This checked `feat-1`'s existing venv only as
563:   a proxy — Task 0.3 re-verifies inside the feature's own dedicated venv
564:   before trusting it for real (REQ-009 isolation).**
565: - [x] Task 0.3: Build the fully isolated `/data/qwen3.8-27b/.venv`, pinned
566:   `vllm==0.26.0` (NOT 0.27.1 — see Design Notes/`feat-1`'s rollback
567:   finding), independent of `/data/vllm/.venv`; re-run the same `qwen3_5`
568:   registry / NVFP4 kernel / CLI-flag checks from Task 0.2 inside this new
569:   venv — depends on: Task 0.2 — status: done 2026-08-25 — built via
570:   `bin/01-build-venv.sh` (Python 3.12.13, `uv venv` + `pip install vllm==0.26.0 flashinfer-python==0.6.14`, then only the two fixes
571:   proven hardware/toolchain-level rather than DeepSeek-model-specific by
572:   `feat-1`: pinned the six `nvidia-cuda-*` wheels to the same 13.3.x line
573:   as production, and baked in the `cudart` lib64/unversioned-`.so`
574:   symlinks for FlashInfer's JIT linker (user decision 2026-08-25: minimal
575:   resolve, do not force-pin `fastokens`/`quack-kernels`/`ml_dtypes` the
576:   way `feat-1`'s `bin/18` clean-venv build did, since those are plausibly
577:   DeepSeek-mHC/MoE-specific, not generic vLLM requirements). All three
578:   Task 0.2 checks re-verified inside this dedicated venv, not just
579:   inferred from `feat-1`'s: `Qwen3_5ForConditionalGeneration` and
580:   `Qwen3_5MTP` both `True` in `ModelRegistry.get_supported_archs()`;
581:   `cutlass_scaled_mm_supports_fp4(120)` → `True`; `vllm serve --help=all`
582:   confirms every needed flag (`--kv-cache-dtype` incl. `fp8`/`nvfp4`,
583:   `--kv-cache-memory-bytes`, `--hf-overrides`, `--speculative-config`,
584:   `--tensor-parallel-size`, `--served-model-name`, `--tool-call-parser`
585:   incl. `qwen3_xml`, `--reasoning-parser`, `--enable-auto-tool-choice`,
586:   `--linear-backend` incl. `flashinfer_b12x`). A `pip freeze` diff against
587:   `/data/vllm/.venv` shows only expected divergence: minor floating-version
588:   drift on packages this script does not pin (`transformers` resolved
589:   5.15.1 vs. production's explicitly-pinned 5.14.1, similar for
590:   `huggingface_hub`/`mcp`/`openai`/etc.), and a handful of packages present
591:   in production only because they were installed by hand for
592:   DeepSeek-specific or diagnostic reasons and are absent here by design
593:   (`fastokens` — only needed if `VLLM_USE_FASTOKENS=1`, never set by this
594:   feature; `hf_transfer` — HF download accelerator, not yet needed until
595:   Task 0.6; `nccl4py`/`py-spy` — DeepSeek TP=4/diagnostic tooling). `tilelang`
596:   and `quack-kernels` (genuine transitive `vllm` dependencies) installed
597:   automatically without forcing, confirming they are not DeepSeek-specific
598:   after all — `ml_dtypes` resolved newer (0.6.0 vs. production's pinned
599:   0.5.4) since nothing here forces it down; revisit only if a future
600:   JIT-compiled kernel (e.g. `tilelang`) misbehaves. Both venvs share the
601:   same underlying `uv`-managed CPython 3.12.13 interpreter binary
602:   (`~/.local/share/uv/python/...`, normal for `uv venv` — analogous to a
603:   shared system Python) but have fully separate, independently-resolved
604:   `site-packages`, satisfying REQ-009. Build script + full rationale:
605:   `bin/01-build-venv.sh`; full freeze snapshot committed at
606:   `bin/baselines/2026-08-25-task-0.3-venv-freeze.txt` (same
607:   snapshot-to-`bin/baselines/` precedent as `feat-1`'s
608:   `bin/16-snapshot-baseline.sh`).
609: - [x] Task 0.4: Confirm GPU topology (NVLink presence/absence) and PCIe
610:   generation per GPU, to inform REQ-011's GPU-pinning decision — depends
611:   on: none — status: done 2026-08-25 — `nvidia-smi topo -m` shows `NODE`
612:   (PCIe-through-host-bridge, no NVLink) between all 4 GPUs; per-GPU PCIe
613:   link: GPU0 & GPU2 = Gen5 x16 (`pcie.link.gen.max`), GPU1 & GPU3 = Gen4
614:   x16; GPU2 selected as the default single-GPU pin (Gen5, and avoids
615:   GPU0's documented occasional Ollama residency per
616:   `hardware/dell-7960t/configuration.md`); GPU2's UUID is
617:   `GPU-7eea2a46-7ce4-e288-ab02-783dc5c5c9ea` (bus `00000000:AC:00.0`) —
618:   use this for `CUDA_VISIBLE_DEVICES` pinning (UUID, not index, to be
619:   robust against any future PCI re-enumeration)
620: - [x] Task 0.5: Confirm `feat-1`/`feat-2`'s current live state, to avoid
621:   surprises/contention during this feature's own testing — depends on:
622:   none — status: done 2026-08-25 — `feat-1` (DeepSeek-V4-Flash) is
623:   blocked/disabled (open SM120 degenerate-output bug,
624:   `vllm-project/vllm#52938`, `status: planning` in its README, service
625:   stopped); `feat-2` (GLM-5.2, served via `llama.cpp`, not vLLM/
626:   ktransformers — a discrepancy from `AGENTS.md`'s description worth
627:   flagging but not fixing here) has a working Q4 production config but was
628:   not running at check time; all 4 GPUs measured at ~0 MiB used (fully
629:   idle) at check time; no Ollama process/service found running
630: - [x] Task 0.6: Pin and download `Qwen/Qwen3.8-27B` (BF16) and
631:   `unsloth/Qwen3.8-27B-NVFP4` to specific HF revisions into the shared
632:   `/data/nvidia/hf_cache` (`HF_HOME`, matching `feat-1`'s convention) —
633:   reuse `feat-3`'s already-vetted NVFP4 revision
634:   (`7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108`) if still current, re-verify
635:   the tokenizer-truncation fix (`tokenizer.json`'s `truncation` field must
636:   be `null`) either way; pin the BF16 revision fresh at download time —
637:   depends on: Task 0.3 — status: done 2026-08-25 — both downloaded via
638:   `bin/02-download-weights.py`. **BF16**: pinned
639:   `Qwen/Qwen3.8-27B@1d4bf0f2ff6012fd82039f2fa52739d0dd7c60c0` (fresh HEAD at
640:   download time, 2026-08-25), 52 GB on disk (18 safetensors shards).
641:   **NVFP4**: re-checked `feat-3`'s pinned
642:   `7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108` against the repo's current
643:   HEAD (`9e3d73c76eddb75f795cc24ccfbc5affe41c66bd`, same day) — the only
644:   commit in between is a README.md-only edit, no weight/config change, so
645:   the vetted revision is still current in every way that matters and was
646:   reused verbatim (not bumped to HEAD); 22 GB on disk, confirms
647:   `feat-3`'s finding that the MTP draft head ships in the same repo
648:   (`model.safetensors` + `model_mtp.safetensors` both present, no separate
649:   `speculative-config "model"` field needed). Tokenizer-truncation fix
650:   re-verified directly against the downloaded file (not just the repo API):
651:   `tokenizer.json`'s `truncation` field is `null`. **Deliberate deviation
652:   from `feat-1`'s `download_flash.py`/`download_pro.py` pattern**: those
653:   scripts pass an explicit `local_dir=<HF_HOME>/hub/models--org--repo`,
654:   which was found (by inspecting `feat-1`'s own
655:   `models--deepseek-ai--DeepSeek-V4-Flash` on this box) to make
656:   `huggingface_hub` write the weights **twice** — once as real files
657:   directly under `local_dir`, once more under the standard
658:   `snapshots/<revision>/`-symlinks-into-`blobs/` cache layout — 270 GB on
659:   disk for a checkpoint whose own weights are ~135 GB. This feature's
660:   download script omits `local_dir` entirely (relies on the
661:   already-exported `HF_HOME` for the default cache-dir resolution
662:   instead), producing the standard no-duplication symlink layout while
663:   remaining exactly as resolvable by bare `repo_id` as `feat-1`'s pattern
664:   (confirmed: `snapshot_download(..., local_files_only=True)` for both
665:   repos resolves correctly, no download attempted) — same download
666:   bytes-over-the-wire, roughly half the disk footprint. `hf_transfer`
667:   installed in this feature's venv to match `feat-1`'s convention, though
668:   the installed `huggingface_hub==1.28.0` has since moved to a Xet-based
669:   transfer backend (`hf_transfer` is deprecated upstream); observed
670:   throughput ~50 MB/s across ~39 parallel Xet connections regardless,
671:   ~40 minutes total for both checkpoints (~74 GB downloaded). Disk
672:   headroom after both downloads: 6.9 TB free of 15 TB. Script + full
673:   rationale: `bin/02-download-weights.py`; full download log saved at
674:   `bin/baselines/2026-08-25-task-0.6-download.log`.
675: 
676: #### Phase 1: Native-context correctness smoke test (hard gate)
677: 
678: - [x] Task 1.1: Bring up the BF16 checkpoint on GPU2 (TP=1) at short/native
679:   context (no YaRN override yet) — depends on: Task 0.6 — status: done
680:   2026-08-25 — brought up as a `systemctl --user` unit (user decision:
681:   even Phase 1's diagnostic smoke test must go through systemd per
682:   REQ-008's literal "never as an ad-hoc foreground process, including
683:   during testing" — lingering was already enabled, no sudo needed for
684:   `--user` units). Unit: `qwen3.8-27b-bf16-native-diag.service`
685:   (`~/.config/systemd/user/`, copy tracked at
686:   `bin/qwen3.8-27b-bf16-native-diag.service`), `CUDA_VISIBLE_DEVICES`
687:   pinned to GPU2's UUID, `--max-model-len 8192`, port 8001 (deliberately
688:   not 8000, to avoid any collision with `feat-1`'s convention on this
689:   shared box). Hit and fixed one real, architecture-specific bug on first
690:   start: `ValueError: max_num_seqs (1024) exceeds available Mamba cache blocks (616)` — Qwen3.8-27B's Gated DeltaNet (Mamba-style state) layers
691:   cap concurrent sequences well below vLLM's default `--max-num-seqs 1024`; fixed with an explicit `--max-num-seqs 512`. Model loaded cleanly
692:   after the fix (BF16 weights: 51.1 GiB in ~6s, `FLASH_ATTN` attention
693:   backend auto-selected, `torch.compile` succeeded, KV cache: 360,448
694:   tokens available at 8192 max-model-len). Cosmetic-only finding, not
695:   blocking: the unit's `Type=notify` never transitions out of
696:   `activating (start)` in `systemctl --user status` even once the API
697:   server is fully up and serving `/health`/`/v1/chat/completions`
698:   correctly — vLLM 0.26.0 apparently doesn't emit the systemd
699:   `READY=1` notification this unit type expects; revisit
700:   (`Type=simple` vs. `Type=notify`) when Phase 5 writes the real
701:   production unit(s).
702: - [x] Task 1.2: Temperature=0 smoke test — explicitly check for `feat-1`'s
703:   exact degenerate-output signature (a single frozen token / identical
704:   logprob repeated at every decode position); verify tool-calling and all
705:   three thinking-control modes — depends on: Task 1.1 — status: done
706:   2026-08-25 — **all checks pass, no SM120 degenerate-output bug**:
707:   - **Non-degenerate output**: a haiku-writing prompt at `temperature: 0`
708:     produced coherent, varied text with distinct, varying per-token
709:     logprobs throughout (nothing resembling `feat-1`'s single frozen
710:     token / identical `-11.7697` logprob at every position) — confirms
711:     the Design Notes' hypothesis that Qwen3.8-27B's Gated DeltaNet +
712:     Gated Attention kernel path is unaffected by the SM120 sparse-MLA
713:     decode bug that blocks `feat-1`'s DeepSeek-V4-Flash.
714:   - **Tool-calling**: `get_weather("Paris")` via
715:     `--tool-call-parser qwen3_xml --enable-auto-tool-choice`
716:     → clean `finish_reason: "tool_calls"`, correctly-formed
717:     `arguments: {"city": "Paris"}`, `content: null`.
718:   - **Thinking-control modes** (17×24 arithmetic prompt, correct
719:     answer=408 in every case): `chat_template_kwargs: {"enable_thinking": false}` → `reasoning: null`, direct
720:     `content: "408"`, `finish_reason: "stop"`; `reasoning_effort: "low"`
721:     → 110-char reasoning; `reasoning_effort: "medium"` → 115-char
722:     reasoning (different wording, not just coincidentally same length);
723:     `reasoning_effort: "xhigh"` → 115-char reasoning, distinctly
724:     different phrasing/style from medium — all three produced the
725:     correct final answer. (Note: for this trivial a prompt, medium/xhigh
726:     reasoning length converged; the *content* differs, confirming the
727:     parameter is taking effect rather than being silently ignored —
728:     scaling with harder prompts is not re-tested here, out of scope for
729:     a Phase 1 smoke test.)
730:   - Diagnostic service stopped afterward (on-demand philosophy — GPU2
731:     fully freed, confirmed via `nvidia-smi`, ready for Phase 2's fresh
732:     TP=1/TP=2 benchmark instances).
733: - [x] Task 1.3: Record the outcome. If the degenerate-output signature IS
734:   reproduced, this is a blocking finding (same bug class as `feat-1`'s
735:   open, unresolved issue) requiring investigation/escalation before any
736:   further work in this feature — depends on: Task 1.2 — status: done
737:   2026-08-25 — **outcome: NOT reproduced, hard gate cleared.** Qwen3.8-27B
738:   BF16 on this box's SM120 GPUs (GPU2) produces coherent, correct output
739:   at native/short context, with working tool-calling and all three
740:   thinking-control modes. `feat-1`'s open
741:   `vllm-project/vllm#52938` is confirmed specific to DeepSeek-V4-Flash's
742:   sparse-MLA decode kernel path and does not affect this model's
743:   different (Gated DeltaNet + Gated Attention) architecture on this same
744:   hardware. Phase 2 (TP=1 vs. TP=2 throughput) is now unblocked.
745: 
746: #### Phase 2: TP=1 vs. TP=2 throughput check (GPU-pinning decision)
747: 
748: - [x] Task 2.1: Benchmark decode throughput at matched settings: GPU2-only
749:   (TP=1) vs. GPU2+GPU0 (TP=2) — depends on: Task 1.3 — status: done
750:   2026-08-25 — used `vllm bench serve` (the standard vLLM benchmark CLI,
751:   user decision) against two fresh diagnostic `systemctl --user` units
752:   (`qwen3.8-27b-bf16-tp1-bench.service` port 8001,
753:   `qwen3.8-27b-bf16-tp2-bench.service` port 8002 — both tracked under
754:   `bin/`), identical settings for both: `--dataset-name random --random-input-len 1024 --random-output-len 512 --num-prompts 128 --max-concurrency 64 --request-rate inf --ignore-eos`. **TP=2
755:   (GPU2+GPU0) decisively wins on every single metric**, not just ties:
756:   | metric | TP=1 (GPU2) | TP=2 (GPU2+GPU0) | delta |
757:   |---|---|---|---|
758:   | Output tok/s | 746.35 | 1222.74 | **+64%** |
759:   | Total tok/s | 2315.41 | 3793.33 | +64% |
760:   | Req/s | 1.46 | 2.39 | +64% |
761:   | Mean TTFT (ms) | 7144 | 4953 | −31% |
762:   | Mean TPOT (ms) | 71.74 | 42.63 | −41% |
763: 
764:   Full logs: `bin/baselines/2026-08-25-task-2.1-bench-tp1.log` and
765:   `-tp2.log`. Both diagnostic services stopped afterward, both GPUs
766:   confirmed fully freed via `nvidia-smi`.
767: 
768: - [x] Task 2.2: Decide production GPU pinning based on the measured
769:   numbers (working hypothesis, per Design Notes: TP=1/GPU2-only wins or
770:   ties, given no NVLink between any GPU pair) — depends on: Task 2.1 —
771:   status: done 2026-08-25 — **decision: GPU2+GPU0 (TP=2), REVERSING the
772:   working hypothesis.** The Design Notes' PCIe-communication-overhead
773:   concern turned out not to dominate for this model/precision/context
774:   combination: at BF16 and a 1024-in/512-out workload, compute (not
775:   inter-GPU communication) is evidently the bottleneck, so splitting
776:   compute across GPU2+GPU0 (both PCIe Gen5 x16, per Task 0.4) still nets
777:   a large, consistent win across throughput AND latency, despite the
778:   confirmed absence of NVLink. REQ-001/REQ-011 updated accordingly:
779:   production is pinned to **GPU2+GPU0 (TP=2)**, not GPU2-only. (Caveat
780:   for Phase 4: this was measured at BF16/8192-context only — NVFP4's
781:   smaller memory/compute footprint and the eventual 896K/YaRN context
782:   could shift this balance; not re-tested here, flagged for awareness
783:   only, not a blocker for this decision.)
784: 
785: #### Phase 3: YaRN 896K context — apply + validate (fixed target)
786: 
787: - [x] Task 3.1: Apply the YaRN `rope_parameters` override (factor 3.5)
788:   targeting the fixed 917,504-token context, on the GPU(s) chosen in
789:   Phase 2 — depends on: Task 2.2 — status: done 2026-08-25 — diagnostic
790:   unit `qwen3.8-27b-bf16-896k-diag.service` (tracked at `bin/`), TP=2
791:   (GPU2+GPU0 UUIDs), `--max-model-len 917504`,
792:   `VLLM_ALLOW_LONG_MAX_MODEL_LEN=1`, and `--hf-overrides` set to the exact
793:   vendor-documented JSON blob from Design Notes/REQ-012 (reused verbatim
794:   from `feat-3`, single-quoted in the systemd `ExecStart` — systemd 249
795:   confirmed to support this quoting). `--max-num-seqs 2` (deliberately low
796:   — Task 1.1's Mamba-cache-block constraint scales with concurrent
797:   sequences, and at 896K context only a couple of concurrent full-length
798:   requests fit anyway; see Task 3.2). Came up clean on the first attempt
799:   (no repeat of Task 1.1's Mamba-block error — the lower `--max-num-seqs`
800:   avoided it). `/v1/models` confirms `max_model_len: 917504`.
801: - [x] Task 3.2: Measure KV-cache token capacity and free VRAM headroom at
802:   896K — depends on: Task 3.1 — status: done 2026-08-25 — read directly
803:   from the vLLM startup log (not estimated): BF16 weights 26.0 GiB per
804:   GPU (52 GiB total / 2, TP=2 shard); **GPU KV cache size: 1,892,058
805:   tokens** (combined across the TP=2 pair); **maximum concurrency for
806:   917,504 tokens per request: 2.06x** (room for 2 full-length concurrent
807:   requests); free VRAM headroom after load: ~10.5 GiB per GPU (97,887 MiB
808:   total − 87,122 MiB used). Comfortable margin, no tuning needed to hit
809:   the fixed 896K target.
810: - [x] Task 3.3: Validate with a real filled-context request (a real
811:   ~899K-token prompt built with the model's own tokenizer, not a synthetic

(Output capped at 50 KB. Showing lines 1-811. Use offset=812 to continue.)
</content>
```

---

## Assistant (Plan · Claude Sonnet 5 · 14.3s)

_Thinking:_



**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md",
  "offset": 812,
  "limit": 400
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md</path>
<type>file</type>
<content>
812: | Single/Dual Spark, SGLang+DFlash2 (B, different engine) | 52-61 / 87 tok/s (code); 26 / 41 tok/s (prose); 34-49 / 49 tok/s (thinking chat) | ~10K tok/s | HumanEval pass@1 159/164 (97.0%); tool-eval-bench 92/100 (★★★★★); DFlash2 is lossless (greedy output matches target model) but incompatible with YaRN >262K on that build |
813: 
814: - [x] Task 6.1: Compare the performance of our production BF16
815:   installation (`qwen3.8-27b-vllm.service`) against the published
816:   NVFP4 data above — depends on: Task 4.3 — status: done 2026-08-23 —
817:   see RESULTS below; BF16 vs. NVFP4 performance is very different,
818:   Task 6.2 is warranted. Apples-to-apples plan:
819: 
820:   1. Reproduce Source A's exact decode benchmark (the Bubblesort
821:      prompt, `temperature=0`, streaming, median of 5 runs after
822:      warmup) against our live BF16 service, thinking on and off.
823:   2. Reproduce Source A's four unique-prefix prefill measurements
824:      (4,566 / 11,988 / 24,015 / 47,857 tokens, distinct prefix per
825:      request — no prefix-cache reuse) against our live BF16 service.
826:   3. Record our own already-measured FP8-KV-cache cost (~33.0 KB/token,
827:      BF16 weights, Task 2.1) next to Source A's 37,169 bytes/token
828:      (FP8 KV, NVFP4 weights) — since the architecture is confirmed
829:      equivalent, any material delta here is attributable to weight
830:      precision/packing, not architecture.
831:   4. Compute the throughput ratio between our BF16 result and Source
832:      A's `num_speculative_tokens=0` NVFP4 baseline specifically (11.4
833:      tok/s) — the only same-engine, no-speculative-decoding data point
834:      in either thread — to isolate the pure BF16-vs-NVFP4 precision
835:      effect from the separate, additive effect of speculative decoding
836:      (MTP/DFlash2).
837:   5. Explicitly record whether most of Source A/B's headline speedup
838:      (24-26 tok/s single-Spark MTP, up to 87 tok/s SGLang+DFlash2) comes
839:      from precision (BF16→NVFP4) or from speculative decoding (none→
840:      MTP/DFlash2) — if the latter dominates, adding MTP-style
841:      speculative decoding to our EXISTING BF16 deployment may be a
842:      lower-risk lever than a full NVFP4 requant, and should be
843:      considered as an alternative outcome of this task, not just
844:      "NVFP4 or nothing."
845: 
846:   **RESULTS (2026-08-23, executed live)** — ran all four planned
847:   measurements with a coordinated maintenance window: stopped the 896K
848:   BF16 production service, ran the NVFP4 checkpoint at native 262144
849:   context (`--gpu-memory-utilization 0.45`, reproducing Source A's exact
850:   recipe) in both `MTP=0` and `MTP=5` configurations, then restarted
851:   the BF16 production service and re-ran the SAME decode benchmark
852:   script against it for a rigorous, identically-methodology BF16
853:   baseline (superseding the rougher ~4.6 tok/s note from Task 1.2). All
854:   three configs passed the same tool-calling/thinking-mode/coherent-
855:   output smoke checks (Task 1.2/4.2 style) before benchmarking.
856: 
857:   | Config | Decode (thinking) | Decode (no-thinking) | Kernel used |
858:   |---|---|---|---|
859:   | Our BF16 production (896K ctx, FP8 KV, no spec decode) | 4.41 tok/s | 4.40 tok/s | n/a (BF16 GEMM) |
860:   | Our NVFP4, `MTP=0` (native 262144 ctx, FP8 KV) | 11.21 tok/s | 11.21 tok/s | `FlashInferCutlassNvFp4LinearKernel` (auto-selected) |
861:   | Our NVFP4, `MTP=5` (native 262144 ctx, FP8 KV) | 31.04 tok/s | 34.03 tok/s | same, + MTP draft head |
862:   | Source A reference, `num_speculative_tokens=0` | — | 11.4 tok/s | (their nightly build) |
863:   | Source A reference, `num_speculative_tokens=5` | 24.0 tok/s | 26.0 tok/s | (their nightly build) |
864: 
865:   Decomposed effects (median of 5 runs each, Bubblesort prompt,
866:   temperature=0, streaming — Source A's exact methodology):
867: 
868:   - **Precision-only effect, isolated (NVFP4 vs BF16, neither using
869:     speculative decoding)**: **2.54x** (11.21 / 4.405 tok/s avg).
870:   - **Speculative-decoding-only effect, isolated (MTP vs no-MTP, both
871:     NVFP4)**: **2.77x** (thinking) / **3.04x** (no-thinking).
872:   - **Combined effect (what a naive before/after would report)**:
873:     **7.05x** (thinking) / **7.73x** (no-thinking).
874:   - Our `MTP=0` result (11.21 tok/s) reproduces Source A's own
875:     no-spec-decode baseline (11.4 tok/s) within ~2% — validates the
876:     reproduction is sound and our stack behaves consistently with
877:     theirs at matched settings.
878:   - Our `MTP=5` result (31.04-34.03 tok/s) BEATS Source A's own
879:     `num_speculative_tokens=5` headline (24.0-26.0 tok/s) by **~29-31%**
880:     — attributed to our newer, stock vLLM 0.27.1 + FlashInfer
881:     0.6.16.post3 release vs. their August nightly dev build
882:     (`0.26.1rc1.dev244+...`), consistent with Task 6.2's kernel-check
883:     finding that our stock release closed real gaps present in their
884:     build.
885:   - **Prefill**: our unique-prefix measurements (2,388 / 2,316 / 2,136 /
886:     1,804 tok/s at 4,578 / 12,000 / 24,027 / 47,869 tokens) are
887:     meaningfully HIGHER than Source A's (1,734 / 1,153 / 1,014 /
888:     853 tok/s at closely-matching lengths) — same newer-stack
889:     explanation likely applies; no chunked-prefill flags were set
890:     explicitly on either side of our A/B, so this isn't a config
891:     artifact on our end.
892:   - **KV-cache efficiency**: our measured 33,571 bytes/token (27.56 GiB
893:     / 881,478 tokens, FP8 KV, native 262144 ctx — the 27.56 GiB figure
894:     matches Source A's exactly) is tighter than Source A's 37,169
895:     bytes/token — only 2.5% overhead above the 32,768-byte naive
896:     calculation vs. their 13.4% — another data point consistent with a
897:     more optimized build.
898:   - Conclusion for Task 6.2's decision criterion (adopt only if
899:     > =1.5-2x and it survives isolating speculative decoding): **BF16
900:     > performance is very different from NVFP4 — both YES independently**
901:     > (2.54x from precision alone clears the bar on its own) **and
902:     > combined with MTP** (7-7.7x). Task 6.2 is warranted and should
903:     > proceed. Still open before a final adoption decision: NVFP4 at our
904:     > actual production context (768K-1M via YaRN, not yet tested — Task
905:     > 6.2 step 4) and the REQ-005-mandated quality-impact check (Task 6.2
906:     > step 6, needs Task 5.2's coding-task examples).
907:   - Housekeeping: benchmark scripts left at `/home/admin/bench_decode.py`
908:     and `/home/admin/bench_prefill.py` for reuse in Task 6.2's
909:     long-context re-test once YaRN is applied to the NVFP4 checkpoint.
910:     Production BF16 service confirmed restored and healthy (896K
911:     context, `qwen3.8:27b-bf16`) at the end of this session — no net
912:     change to the running production state.
913: 
914: - [x] Task 6.2: Set up an NVFP4 deployment if Task 6.1 shows the BF16
915:   installation's performance is very different (materially slower)
916:   from the reference data, once the speculative-decoding contribution
917:   from Task 6.1.5 is accounted for — depends on: Task 6.1 —
918:   status: DONE 2026-08-24. Steps 1-5 done 2026-08-23 (kernel check
919:   passed, checkpoint pinned/downloaded, MTP decision deferred, YaRN
920:   capacity step-up complete — see step 4 RESULTS below: **NVFP4 clears
921:   all of 768K/896K/1M, including the full 1M ceiling BF16 failed at**;
922:   step 5 built/validated a production-candidate NVFP4+YaRN systemd
923:   service at 1M). **Steps 6-7 closed 2026-08-24: user's quality
924:   verdict via OpenCode was "NVFP4 quality is fine, adopt it" (step 6);
925:   final decision (step 7) is to ADOPT NVFP4 as production, replacing
926:   BF16 — but at a chosen production context of 896K, not the 1M
927:   candidate step 5 built**, per a separate user decision that 896K is
928:   "large enough" for real usage after testing (see STEP 6-7 RESULTS /
929:   PRODUCTION CUTOVER below for the full record, including the
930:   resulting deployment change from the 1M candidate to a new 896K
931:   production service). Decision
932:   criterion: only adopt NVFP4 (optionally
933:   with MTP) as production if it clears a large (e.g. >=1.5-2x)
934:   decode/prefill improvement that survives isolating speculative
935:   decoding, AND passes an empirical quality-impact check — per REQ-005,
936:   it must not be adopted by default. Required pre-work, in order:
937: 
938:   1. **Blocking check, do FIRST**: verify our installed vLLM 0.27.1
939:      (stock PyPI wheel, aarch64) actually has NVFP4 GEMM kernels for
940:      GB10/SM121a. Source B's community recipe explicitly warns: "Stock
941:      `vllm/vllm-openai` has NO NVFP4 kernels for Blackwell sm_121a
942:      (GB10). Every stock-vLLM attempt crashed" and required a custom
943:      community-built image
944:      (`ghcr.io/drowzeys/keys-vllm-027-gb10-qwen38` or
945:      `eugr/spark-vllm-b12x`, providing
946:      `FlashInferCutlassNvFp4LinearKernel`). Check this BEFORE any
947:      download/setup work, same discipline as Phase 0/Task 0.2's
948:      platform-support verification. If our stock vLLM build lacks
949:      NVFP4 kernel support, either find/validate an equivalent
950:      GB10-NVFP4-capable build, or treat NVFP4 as blocked and stop at
951:      Task 6.1's findings.
952:   2. Pin and download `unsloth/Qwen3.8-27B-NVFP4` (or an alternative
953:      NVFP4 repo, e.g. RadixArk's, if quality/compatibility differs) to
954:      a specific HF revision (REQ-007 discipline carried forward);
955:      re-verify the pinned revision doesn't have Source A's
956:      since-fixed tokenizer-truncation bug
957:      (`tokenizer.json`'s `truncation` field must be `null`).
958:   3. Decide whether to add MTP speculative decoding
959:      (`--speculative-config '{"method":"mtp","num_speculative_tokens":5}'`
960:      — the draft head ships inside the NVFP4 checkpoint, no separate
961:      model needed) — stays on our existing engine (vLLM), so REQ-006's
962:      engine decision is unaffected. SGLang+DFlash2 (Source B) is
963:      explicitly out of scope for this task unless MTP alone doesn't
964:      close the gap, since it is a different serving engine and would
965:      reopen the REQ-006 engine decision.
966:   4. Re-run the SAME Task 2.1-2.3 capacity/headroom step-up methodology
967:      (768K → 896K → 1M, >=15% free or >=10 GiB absolute policy) with
968:      NVFP4 weights. Explicitly named goal: NVFP4's much smaller
969:      resident weight footprint (~22.6-23.4 GB vs. BF16's ~55.6 GB)
970:      frees roughly 32 GB of the unified pool, which may be enough to
971:      clear the 1M-context policy floor that BF16 failed at (Task 2.2:
972:      1M measured 12.9% free, below the 15% floor) — re-measuring 1M
973:      with NVFP4 is a specific goal here, not just re-confirming 896K.
974:   5. Re-verify tool-calling and all three thinking-control modes
975:      (mirroring Task 1.2/4.2's exact checks) against the NVFP4(+MTP)
976:      service before calling it production-equivalent.
977:   6. Quality-impact check (REQ-005's bar): at minimum, re-run ACC-011's
978:      coding-task examples (once available from Task 5.2) against both
979:      BF16 and NVFP4 side by side; do not just trust Source A/B's own
980:      NVFP4 quality numbers (HumanEval 97.0%, tool-eval-bench 92/100),
981:      since those measured DIFFERENT NVFP4 checkpoints (unsloth vs.
982:      RadixArk) and a different draft/spec-decode stack (MTP vs.
983:      DFlash2) than whatever ends up deployed here.
984:   7. Record the outcome either way: adopt NVFP4 (± MTP) as the new
985:      production precision (replacing BF16, with the same
986:      one-line-rationale discipline as ACC-004), OR keep BF16 as
987:      production and record NVFP4 as evaluated-but-not-adopted with the
988:      reason (insufficient throughput gain once speculative decoding is
989:      isolated, unacceptable quality regression, or no GB10-compatible
990:      NVFP4 vLLM kernel available). "Not very different" is a valid,
991:      complete answer to this task, not a failure. Supersedes/closes the
992:      still-open Task 3.2 (optional FP8/quant weight eval) either way.
993: 
994:   **Step 4 RESULTS (2026-08-23, executed live, maintenance window)** —
995:   stopped the 896K BF16 production service (`systemctl --user stop qwen3.8-27b-vllm.service`, confirmed 0 GPU processes / clean pool
996:   before starting), created a parameterized YaRN-enabled NVFP4 launch
997:   script (`/home/admin/scripts/qwen3.8-27b-nvfp4-yarn-vllm.sh`, `CTX=768k|896k|1m` toggle, same YaRN `rope_parameters` override shape as
998:   BF16's, same per-context `--kv-cache-memory-bytes` values as the
999:   BF16 `launch-phase2-*-fp8kv.sh` scripts since KV-cache size is a
1000:   function of architecture, not weight precision), then ran the full
1001:   768K → 896K → 1M step-up, one context at a time (stop/measure/stop
1002:   between each — the pool cannot hold two instances at once):
1003: 
1004:   | Context | Factor | `--kv-cache-memory-bytes` | KV cache capacity | Concurrency margin | Available memory | % free | Policy (>=15% or >=10 GiB) |
1005:   |---|---|---|---|---|---|---|---|
1006:   | 768K (786,432) | 3.0 | 30 GiB | 974,864 tokens | 1.24x | 51.61 GiB | 43.1% | **PASS** |
1007:   | 896K (917,504) | 3.5 | 33 GiB | 1,073,277 tokens | 1.17x | 48.00 GiB | 40.1% | **PASS** |
1008:   | 1M (1,048,576) | 4.0 | 37.11 GiB | 1,209,295 tokens | 1.15x | 43.34 GiB | 36.2% | **PASS** |
1009: 
1010:   Key findings:
1011: 
1012:   - **KV-cache token capacity and concurrency margin are IDENTICAL to
1013:     the BF16 measurements at every context size** (974,864 / 1,073,277
1014:     / 1,209,295 tokens at 768K/896K/1M, same 1.24x/1.17x/1.15x
1015:     margins) — confirms KV-cache sizing is driven by model architecture
1016:     (hidden dim, KV heads, layer count), not weight quantization, exactly
1017:     as expected since NVFP4 only quantizes MLP weights (+FP8 attention),
1018:     not the KV-cache-relevant attention shape.
1019:   - **NVFP4 clears ALL THREE context sizes, including the full 1M
1020:     native ceiling that BF16 failed (12.9% free, below the 15%
1021:     floor)** — at 1M, NVFP4 leaves 36.2% of the unified pool free,
1022:     more than double the 15% policy floor and nearly 3x BF16's
1023:     899K-max/12.9%-at-1M result. This directly confirms the Design
1024:     Notes' hypothesis: NVFP4's ~33 GB smaller resident weight footprint
1025:     (21.59 GiB vs. BF16's ~55.99 GiB, measured at load time) is enough
1026:     to fully absorb the difference.
1027:   - Smoke-tested (coherent non-degenerate output, clean
1028:     `get_weather("Paris")` tool-call, all three ACC-003 thinking-control
1029:     modes on the 17×24=408 arithmetic prompt) at all three context
1030:     sizes — all passed at every size: correct answers, correctly-scaled
1031:     reasoning length by effort level (768K: n/a run only for
1032:     correctness/tool-call; 896K: medium=44-char/xhigh=156-char
1033:     reasoning; 1M: medium=124-char/xhigh=175-char reasoning), clean
1034:     tool-calls, no degenerate output at any size.
1035:   - All three test instances shut down cleanly after their
1036:     measurements (0 GPU processes, port 8000 free, ~114 GiB available
1037:     between each step and at the end).
1038:   - **Per your maintenance-window instruction, the BF16 production
1039:     service was intentionally left stopped (not restarted)** at the
1040:     end of this run — `qwen3.8-27b-vllm.service` is `inactive (dead)`.
1041:     Restarting it (`systemctl --user start qwen3.8-27b-vllm.service`)
1042:     is a one-line action whenever normal production serving needs to
1043:     resume; nothing else on the box needs cleanup.
1044:   - **Still open before final adoption (Task 6.2 steps 5-7)**: step 5
1045:     (re-verify tool-calling/thinking at whichever size is chosen as
1046:     NVFP4's production context — informally done above at all three,
1047:     but not yet against a finalized systemd deployment); step 6 (the
1048:     REQ-005-mandated quality-impact check, BF16 vs. NVFP4 side by side
1049:     on Task 5.2's coding-task examples — not yet run); step 7 (the
1050:     final adopt-NVFP4-or-keep-BF16 recorded decision). Given NVFP4 now
1051:     clears the full 1M ceiling (vs. BF16's 896K cap) AND is 2.54x-7.7x
1052:     faster (Task 6.1), 1M is the natural candidate production context
1053:     for NVFP4 if step 6's quality check clears the bar — but that
1054:     decision is explicitly not made yet.
1055: 
1056:   **Prep work done ahead of time (2026-08-23, in parallel with Task
1057:   5.2, no GPU/memory impact on the running BF16 production service)**:
1058: 
1059:   - **Step 1's blocking check is RESOLVED, and the outcome differs from
1060:     the forum's warning**: verified live on this box (no test server
1061:     needed) that our stock vLLM 0.27.1 + FlashInfer 0.6.16.post3
1062:     (aarch64, PyPI release) DOES have working NVFP4 GEMM kernels for
1063:     GB10/SM121a — `cutlass_scaled_mm_supports_fp4(121)` returns `True`,
1064:     and `has_flashinfer_b12x_gemm()` (the exact `Sm120B12xBlockScaledDenseGemmKernel`
1065:     the forum's custom community image added) is also `True`. This
1066:     contradicts Source B's "stock vllm/vllm-openai has NO NVFP4 kernels
1067:     for Blackwell sm_121a" claim — that was true for the August nightly
1068:     dev build (`0.26.1rc1.dev244+...`) the forum posters used; our
1069:     newer stock 0.27.1 release has since closed that gap.
1070:   - One real caveat found in the kernel-selection source itself
1071:     (`vllm/model_executor/kernels/linear/__init__.py`): vLLM's
1072:     auto-selection deliberately EXCLUDES the fastest b12x kernel by
1073:     default — code comment: *"FlashInferB12xNvFp4LinearKernel excluded
1074:     from auto-selection until upstream CUTLASS SM121 MMA op guard is
1075:     resolved; use `--linear-backend flashinfer_b12x` to opt in
1076:     explicitly."* Auto-selection order on this box resolves to
1077:     `FlashInferCutlassNvFp4LinearKernel` (confirmed `is_supported() -> True`) — a solid, supported default, just not the fastest possible
1078:     path. `--linear-backend flashinfer_b12x` is available as an
1079:     explicit, opt-in experiment, not the baseline comparison config.
1080:   - Pinned and downloaded `unsloth/Qwen3.8-27B-NVFP4` to HF revision
1081:     `7d6f8d4d72f56b92b3cdbf22f156b90e1bab0108` (2026-08-17, i.e. after
1082:     the 2026-08-15 tokenizer-truncation fix mentioned in Source A) —
1083:     verified `tokenizer.json`'s `truncation` field is `null` BEFORE
1084:     committing to the full 23.4 GB download (fetched that one file
1085:     first), then re-verified after — confirmed fixed both times.
1086:     22.6 GB `model.safetensors` + 0.85 GB `model_mtp.safetensors`
1087:     (1968 tensors total, 15 of them the MTP head, all registered in one
1088:     `model.safetensors.index.json` — matches Source A's finding that no
1089:     separate `--speculative-config "model"` field is needed) landed at
1090:     `/home/admin/models/qwen3.8-27b-nvfp4`. 345 GB still free on
1091:     `/home/admin` afterward — no disk pressure.
1092:   - `config.json` confirms `Qwen3_5ForConditionalGeneration` (same
1093:     registry entry the BF16 checkpoint uses) and a compressed-tensors
1094:     mixed quantization config: NVFP4 for most MLPs, FP8 for
1095:     attention/`lm_head`/the last 8 layers' MLPs — matches Source A's
1096:     "MLP in NVFP4, attention in FP8" description exactly. `rope_type: "default"` (no scaling) with `max_position_embeddings: 262144` in
1097:     `text_config` — same YaRN-override shape (REQ-011) as our BF16
1098:     deployment, just needs applying to this checkpoint when context
1099:     extension is tested.
1100:   - Drafted (not yet run) `/home/admin/scripts/qwen3.8-27b-nvfp4-vllm.sh`
1101:     — two modes via `MTP=0` (default, no speculative decoding — the
1102:     apples-to-apples comparison point for Task 6.1.4 against Source A's
1103:     `num_speculative_tokens=0` baseline) or `MTP=1` (adds
1104:     `--speculative-config '{"method":"mtp","num_speculative_tokens":5}'`,
1105:     matching Source A's headline config), both at native 262144 context
1106:     and `--gpu-memory-utilization 0.45` (reproducing Source A's exact
1107:     recipe). **Deliberately NOT started**: the unified 128 GB pool
1108:     cannot hold both this and the running 896K BF16 production service
1109:     at once (BF16 alone already uses ~111 GiB at 896K) — running it
1110:     requires a coordinated maintenance window (`systemctl --user stop qwen3.8-27b-vllm.service` first, restart after), left for whenever
1111:     Task 6.1's actual benchmark run is scheduled, so as not to disrupt
1112:     Task 5.2's live user testing.
1113: 
1114:   **Step 6-7 RESULTS / PRODUCTION CUTOVER (2026-08-24)**:
1115: 
1116:   1. **Step 6 (quality verdict)**: user ran their coding-task examples
1117:      via OpenCode against the NVFP4 1M candidate service
1118:      (`qwen3.8-27b-nvfp4-1m.service`, left running from step 5) and
1119:      reported: **"NVFP4 quality is fine, adopt it."** This is the
1120:      REQ-005-mandated quality-impact check, satisfied per the same
1121:      "user's own judgment on their own examples" precedent as `feat-1`
1122:      ACC-010 and this feature's own Task 5.2.
1123:   2. **Separate context decision**: in the same follow-up, the user
1124:      concluded from their testing that **896K context is "large
1125:      enough"** for real usage and explicitly chose it over the 1M
1126:      ceiling that step 4/5 had qualified and built a candidate for.
1127:      This is independent of the precision decision — NVFP4 at 896K
1128:      (Task 6.2 step 4's table) has even more headroom (40.1% free) than
1129:      NVFP4 at 1M (36.2% free), so dropping to 896K is a strictly safer
1130:      choice on top of being the user's stated preference.
1131:   3. **Step 7 (final decision, recorded)**: **ADOPT NVFP4 as the
1132:      production precision, replacing BF16, at 896K context (not
1133:      1M).** Rationale (one-line, per ACC-004's precedent): NVFP4 gives
1134:      a 2.54x-7.7x decode speedup over BF16 (Task 6.1) with no quality
1135:      regression per the user's own coding-task judgment (step 6 above),
1136:      clearing REQ-005's bar for adopting a quantized variant over BF16
1137:      ("not adopted by default... only if empirically justified").
1138:      REQ-003/ACC-002's already-chosen 896K production context is
1139:      unaffected by the precision change (KV-cache sizing at 896K is
1140:      architecture-driven and identical for BF16/NVFP4 per Task 6.2 step
1141:      4's table) — only the weight precision changes.
1142:   4. **Deployment cutover performed** (live, this session, directly on
1143:      `dgx`): the 1M NVFP4 candidate no longer matches the chosen
1144:      production context, so it was retired rather than promoted as-is.
1145:      Built a NEW production script/unit at 896K instead:
1146:      - `/home/admin/scripts/qwen3.8-27b-nvfp4-896k.sh` — derived from
1147:        the validated `qwen3.8-27b-nvfp4-1m.sh` (same
1148:        `VLLM_DISABLE_COMPILE_CACHE=1` fix from step 5, deliberately NO
1149:        `--linear-backend` pin per step 5's finding), with 896K params
1150:        (`--max-model-len 917504`, YaRN factor 3.5, `--kv-cache-memory-bytes 35433480192` / 33 GiB — identical KV-cache sizing to the
1151:        BF16 896K script), `--served-model-name qwen3.8:27b-nvfp4-896k`.
1152:      - `/home/admin/.config/systemd/user/qwen3.8-27b-nvfp4-896k.service`
1153:        — mirrors the existing unit pattern (`--user`, disabled/
1154:        no-autostart, `TimeoutStartSec=4200`, `LimitNOFILE=1048576`).
1155:      - Stopped `qwen3.8-27b-nvfp4-1m.service` (confirmed `inactive`,
1156:        port 8000 free, 0 GPU processes) and `qwen3.8-27b-vllm.service`
1157:        (BF16, already stopped from the maintenance window) before
1158:        starting the new unit — both retained on disk, disabled, as
1159:        fallback/reference, not deleted.
1160:   5. **Real environment gap found and fixed during cutover**: the first
1161:      two start attempts of `qwen3.8-27b-nvfp4-896k.service` failed with
1162:      `ValueError: Free memory on device cuda:0 (65.52-65.74/119.63 GiB) on startup is less than desired GPU memory utilization` — NOT a
1163:      script/config bug. Root cause: a **resident Ollama-served model**
1164:      (`qwen3.8:27b-q8_0`, 46 GB, via the `ollama` Docker container,
1165:      `--restart always`) was loaded and holding ~43-46 GiB of the
1166:      unified pool, evidently left over from unrelated testing (possibly
1167:      the same Ollama quant used informally for comparison outside this
1168:      feature). This is the exact contention class the Design Notes
1169:      already warned about for capacity *testing* — new finding here is
1170:      that it also blocks *production service restarts*, not just
1171:      measurement runs. Fixed with `docker exec ollama ollama stop qwen3.8:27b-q8_0` (unloads the model, does NOT stop the
1172:      always-restarting container itself) — pool returned to a clean
1173:      ~114 GiB available baseline immediately. **Operational risk now
1174:      recorded, not just fixed once**: if any Ollama model is loaded
1175:      (via OpenWebUI or the Ollama API directly) while the NVFP4
1176:      production service is running, the shared unified pool has thin
1177:      enough headroom (40.1% / ~48 GiB at 896K) that a large concurrent
1178:      Ollama load could still cause runtime memory pressure even though
1179:      it won't crash an already-started vLLM engine outright (unlike a
1180:      cold start, which re-checks free memory against
1181:      `--gpu-memory-utilization` and fails fast, as observed here). No
1182:      guard/quota is implemented for this coexistence risk — flagged as
1183:      an open operational caveat, not solved by this feature.
1184:   6. **Full re-verification passed** against the new
1185:      `qwen3.8-27b-nvfp4-896k.service` (cold start ~3m45s after the
1186:      Ollama fix): `/v1/models` reports `qwen3.8:27b-nvfp4-896k` /
1187:      `max_model_len: 917504`; memory measured at ~48 GiB available /
1188:      119Gi total (~40.1% free), matching step 4's table exactly;
1189:      coherent non-degenerate output (fib-with-memoization prompt); clean
1190:      `get_weather("Paris")` tool-call (`finish_reason: "tool_calls"`);
1191:      all three ACC-003 thinking-control modes on the 17×24=408 prompt
1192:      (`enable_thinking: false` → 0-length reasoning, direct "408";
1193:      `reasoning_effort: medium` → 44-char reasoning, correct answer;
1194:      `reasoning_effort: xhigh` → 120-char reasoning, correctly more
1195:      elaborate, correct answer). Service left `active (running)` as the
1196:      new production service.
1197:   7. **Not yet re-run**: Task 5.2's exact OpenCode-agentic-session leg
1198:      of ACC-003 (the curl leg above is done, but the full agentic
1199:      session was previously only run against the now-superseded BF16
1200:      production service — see the caveat added to ACC-003 below).
1201:      Also not yet done: updating the user's actual `opencode.jsonc`
1202:      provider entry to the new `qwen3.8:27b-nvfp4-896k` model id (the
1203:      user manages that file, not this repo — an updated snippet is
1204:      provided in Progress below).
1205:   8. Housekeeping: `qwen3.8-27b-nvfp4-1m.service`/`.sh` and
1206:      `qwen3.8-27b-vllm.service`/`.sh` (BF16) are both left on disk,
1207:      `disabled`, `inactive` — kept as documented fallback paths (1M
1208:      NVFP4 if more context is ever needed and headroom allows re-
1209:      confirming it; BF16 if a future finding reverses the NVFP4
1210:      adoption) rather than deleted.
1211: 

(Showing lines 812-1211 of 2274. Use offset=1212 to continue.)
</content>
```

---

## Assistant (Plan · Claude Sonnet 5 · 10.1s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "grep -n \"Decisions Made\\|three-way\\|ACC-011\\|## Progress\\|Comparison result\\|preferred over\\|better than\\|worse than\" /home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md | head -60"
}
```

**Output:**
```
179:  accepted-risk decision in Decisions Made (2026-08-22), matching
208:- [ ] ACC-011: User runs the SAME coding-task examples used for `feat-1`/
210:  endpoint, for a direct three-way quality comparison — STILL OPEN as of
214:  the formal three-way comparison record has not been repeated/
362:- **Comparison is the point.** ACC-011 reuses the exact `feat-1`/`feat-2`
773:  `feat-2` against this endpoint for a direct three-way quality
779:  carried into ACC-011**: this was run against BF16, since superseded by
781:  endpoint, so ACC-011's formal three-way comparison record is still
977:  6. Quality-impact check (REQ-005's bar): at minimum, re-run ACC-011's
1266:## Progress
1627:1. **ACC-003 / ACC-011 (the same underlying gap, twice)**: the OpenCode
2040:### Decisions Made

```

---

## Assistant (Plan · Claude Sonnet 5 · 3.5s)

_Thinking:_



**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md",
  "offset": 2040,
  "limit": 234
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-3-qwen3.8-27b-large-context/README.md</path>
<type>file</type>
<content>
2040: ### Decisions Made
2041: 
2042: - **2026-08-22**: Feature goal is production serving (systemd service +
2043:   OpenCode/OpenWebUI wiring + quality comparison), not just an evaluation
2044:   spike — matching the bar set by `feat-1`/`feat-2`.
2045: - **2026-08-22**: Context target is a 768K floor, not a hard ceiling —
2046:   push higher (up to the model's 1M native max) if the unified-memory
2047:   safety margin allows, rather than stopping at 768K by default.
2048: - **2026-08-22**: This feature is independent of `feat-1`/`feat-2` and
2049:   does NOT share a box with them (they stay on the Dell 7960T);
2050:   the question of what (if anything) else runs alongside Qwen3.8-27B is
2051:   about this box's own unified-pool headroom, to be confirmed empirically
2052:   (Task 2.3), not assumed.
2053: - **2026-08-22 (user decision)**: Target hardware changed to **Dell GB10
2054:   (DGX Spark clone)** — a single SoC, 128GB unified LPDDR5x memory
2055:   shared between CPU and GPU (arm64, SM121), replacing the "existing
2056:   Dell 7960T only" constraint from the original plan. Consequences:
2057:   (a) Phase 0 becomes real environment setup on a new arm64 machine,
2058:   nothing is inherited from `feat-1`/`feat-2`'s x86 box; (b) the vLLM
2059:   build must be an arm64/GB10-compatible one — new risk, checked in
2060:   Task 0.2, NOT assumed; (c) single unified memory pool means no
2061:   multi-GPU placement and no separate CPU-RAM fallback for the KV cache,
2062:   so the 768K context floor is a genuine capability question that Task
2063:   2.x must measure, not assume.
2064: - **2026-08-22**: vLLM is the starting engine (matches the vendor's
2065:   documented YaRN path and `feat-1`'s default), with a lightweight
2066:   native-context smoke test (Phase 1) as insurance before the YaRN
2067:   work. On the GB10 the risk profile differs from `feat-1`/`feat-2`: the
2068:   relevant unvalidated variables are the arm64/SM121 build AND the
2069:   `qwen3_5` Gated DeltaNet architecture, not the SM120
2070:   DSA/sparse-MLA bug that hit `feat-1`/`feat-2`
2071:   (`vllm-project/vllm#52938`) — which likely cannot recur on a box with
2072:   no SM120 GPUs.
2073: - **2026-08-22**: Vision-language (image/video) capability is explicitly
2074:   out of scope for this feature — text/coding use only.
2075: - **2026-08-22**: Full BF16 precision is the default target (the model
2076:   fits VRAM comfortably); quantization is opportunistic, adopted only if
2077:   empirically justified — NOT a forced compromise like `feat-2`'s GLM-5.2
2078:   quant decision.
2079: - **2026-08-22**: Ollama/llama.cpp (GGUF) was explicitly ruled out as the
2080:   serving path for this feature — the vendor only documents the YaRN
2081:   long-context extension for vLLM/SGLang/TokenSpeed, and Qwen3.8-27B's
2082:   non-standard hybrid/partial-rotary rotary setup makes an unofficial
2083:   llama.cpp YaRN override judged too high-risk versus the officially
2084:   validated frameworks.
2085: - **2026-08-23**: vLLM 0.27.1 confirmed as the deployment engine
2086:   (REQ-006/ACC-005) after Phase 1's native-context smoke test passed
2087:   cleanly (coherent output, tool-calling, all three thinking-control
2088:   modes) — no SGLang fallback spike required.
2089: - **2026-08-23**: Missing system packages needed by vLLM's runtime
2090:   JIT/compile path (`python3.12-dev` for `Python.h`, needed by Triton's
2091:   architecture-inspection step; `ninja`, needed by `torch.compile`) are
2092:   worked around WITHOUT sudo/root — `uv python install 3.12` provides a
2093:   standalone-build `Python.h` (exposed via `CPATH`), and `ninja` (already
2094:   a venv pip dependency) is exposed via `PATH` including the venv's
2095:   `bin/`. Chosen over asking for `apt-get install python3.12-dev`
2096:   because sudo is not available non-interactively in this environment;
2097:   matching the venv's Python 3.12.x minor version for the `uv`-installed
2098:   headers avoids any C-API ABI mismatch risk. This is now a required
2099:   step in every vLLM launch command for this feature (Phase 2 onward),
2100:   not a one-time fix.
2101: - **2026-08-23**: `VLLM_ENGINE_READY_TIMEOUT_S` must be raised from
2102:   vLLM's 600s default to 3600 for any Phase 2+ launch on this box —
2103:   the 786,432+ max-model-len engine-core startup (weight load without
2104:   auto-prefetch + KV-cache profiling/compile) exceeds 600s and the
2105:   APIServer kills the engine core as a false-timeout otherwise. Task
2106:   1.1's native-context (32768) launch never hit this because it
2107:   profiled fast enough to clear the 600s default. This is now a
2108:   required env var for every Phase 2/4 launch command for this feature.
2109: - **2026-08-23**: `--gpu-memory-utilization` (vLLM's default KV-cache
2110:   sizing mechanism, reused as-is from `feat-1`/`feat-2`) is UNSAFE on
2111:   the GB10's unified pool at 768K+ context — it sizes vLLM's total
2112:   footprint as a fixed fraction of the WHOLE pool regardless of the
2113:   resulting KV-cache token capacity, which starves the OS itself
2114:   (measured ~1.7-3.5 GiB system-wide free at util=0.92/768K, against a
2115:   ~17.9 GiB safety-margin-policy floor). **`--kv-cache-dtype fp8` with
2116:   an explicit, right-sized `--kv-cache-memory-bytes` is required for
2117:   production on this box instead** — this only changes KV-cache
2118:   precision (model weights stay BF16, REQ-005 unaffected) and gives
2119:   direct, measured control over how much of the pool is actually
2120:   reserved, leaving the rest as real OS headroom. Empirically verified
2121:   via two full real-768K-token-prompt end-to-end requests (BF16 KV:
2122:   36 min; FP8 KV: 45 min; both HTTP 200, no OOM).
2123: - **2026-08-23**: **896K (YaRN factor 3.5) chosen as the production
2124:   context** for REQ-003/ACC-002, not the 768K floor and not the 1M
2125:   ceiling — measured step-up (FP8 KV cache): 768K = 19.8% free (PASS),
2126:   896K = 16.1% free (PASS, narrowly — only ~1.1pp above the adopted 15%
2127:   policy floor), 1M = 12.9% free (FAIL). Per the adopted safety-margin
2128:   policy (>=15% free or >=10 GiB, whichever greater — the 15% floor is
2129:   the binding one here), the step-up correctly stops at 896K. At 896K,
2130:   19.28 GiB (16.1%) of the GB10's 119.63 GiB unified pool remains free
2131:   — answering REQ-010, the GB10 effectively owns its pool at this
2132:   context; the 768K step (23.73 GiB / 19.8% free) remains documented as
2133:   a more conservative fallback if headroom needs ever outweigh the
2134:   extra 896K-768K=131,072 tokens of context in the future.
2135: - **2026-08-23**: Tool-call parser `qwen3_xml` and reasoning parser
2136:   `qwen3` are the correct vLLM flags for Qwen3.8-27B's `qwen3_5`
2137:   architecture — determined by inspecting the model's own
2138:   `chat_template.jinja` (XML-style `<tool_call><function=...>` format)
2139:   and vLLM's `vllm.reasoning`/`vllm.tool_parsers` registries, not
2140:   assumed from the model name alone (there is no plain `qwen3` tool-call
2141:   parser; `qwen3_xml`/`qwen3_coder` both map to the same underlying
2142:   `qwen3_engine_tool_parser`, and `qwen3_xml` matches this non-coder
2143:   model's chat template). These flags are required for ACC-003 and must
2144:   be carried into the Phase 4 systemd unit.
2145: - **2026-08-23**: **BF16 confirmed as the production model weight
2146:   precision** (REQ-005/ACC-004/Task 3.1) — verified via a live shell on
2147:   the GB10: the 896K production launch script sets no
2148:   `--dtype`/`--quantization` flag (only `--kv-cache-dtype fp8`, a
2149:   KV-cache-only setting from Task 2.1), the model's `config.json` has
2150:   no `quantization_config`, and the checkpoint's total safetensors size
2151:   (55.56 GB) matches BF16 for ~27B params. Task 3.2 (optional FP8/quant
2152:   weight eval) is left open/not-started by explicit user decision,
2153:   rather than closed now, to be revisited later (e.g. after Phase 4
2154:   throughput data).
2155: - **2026-08-23**: **Qwen3.8-27B installed as a systemd `--user` service**
2156:   (Task 4.1) on the GB10, mirroring `feat-2`'s "lingering enabled + unit
2157:   NOT enabled" pattern rather than a system-wide unit — no GB10-specific
2158:   reason emerged to deviate. `loginctl enable-linger` succeeded without
2159:   sudo (same sudo-free posture as every other environment fix on this
2160:   feature). The `feat-2`-style video/render group defense-in-depth step
2161:   was explicitly skipped: `/dev/nvidia*` is already world-writable on
2162:   this box (same condition that made it non-essential on `feat-2`'s
2163:   box), and non-interactive sudo isn't available here to add it anyway.
2164: - **2026-08-23**: **Task 4.2 curl smoke tests all passed against the
2165:   live production `qwen3.8-27b-vllm.service`** (896K context,
2166:   confirmed via `/v1/models`) — coherent output, clean tool-call, and
2167:   all 3 of ACC-003's exact thinking-control modes
2168:   (`enable_thinking: false`/`reasoning_effort: medium`/`reasoning_effort: xhigh`) gave the correct 17×24=408 answer with correctly-scaled
2169:   reasoning length. Cold load measured at ~7m43s, matching Phase 2's
2170:   timing for this exact config — confirms the 36-45 min figures from
2171:   Task 2.1 were full-context prompt processing time, not startup
2172:   latency. Service intentionally left running for Task 4.3 to reuse.
2173:   ACC-003's curl leg is done; its OpenCode-agentic-session leg is
2174:   deferred to Phase 5.
2175: - **2026-08-23**: **Task 4.3 passed — real 899,067-token filled-context
2176:   request against the production `qwen3.8-27b-vllm.service` completed
2177:   with HTTP 200 and no OOM** (`usage.total_tokens: 899,117`, ~18.4K
2178:   headroom under the 917,504 max-model-len), 3582s wall time. Service
2179:   confirmed healthy afterward (no degradation from Task 2.3's measured
2180:   headroom). A test-payload artifact (wrong `enable_thinking` field
2181:   shape, truncated reasoning in the response) was found and recorded
2182:   honestly but does not affect the OOM-free pass/fail bar Task 4.3
2183:   actually measures. **Phase 4 (Tasks 4.1-4.3) is now fully COMPLETE**
2184:   — Qwen3.8-27B is live in production on the GB10 at 896K context.
2185: - **2026-08-23**: **NVFP4 clears the full 1M native-ceiling context
2186:   (Task 6.2 step 4)** — the same 768K→896K→1M YaRN capacity step-up
2187:   methodology from Task 2.1-2.3, re-run against the NVFP4 checkpoint,
2188:   passes at all three sizes (43.1% / 40.1% / 36.2% free), including 1M
2189:   where BF16 failed (12.9% free, below the 15% floor). KV-cache token
2190:   capacity is identical to BF16's at every size, confirming the
2191:   headroom gain comes entirely from NVFP4's smaller resident weight
2192:   footprint (~21.6 GiB vs. BF16's ~56 GiB). This does not by itself
2193:   decide NVFP4 adoption (Task 6.2 steps 5-7, especially the REQ-005
2194:   quality-impact check, remain open) but establishes 1M as NVFP4's
2195:   natural production-context candidate if quality clears the bar. Per
2196:   explicit instruction, the BF16 production service was stopped for
2197:   this maintenance-window test and intentionally left stopped
2198:   afterward (not restored) — restart is a one-line `systemctl --user start qwen3.8-27b-vllm.service` whenever normal production serving
2199:   needs to resume.
2200: - **2026-08-23**: **`VLLM_DISABLE_COMPILE_CACHE=1` is required for any
2201:   NVFP4 systemd deployment of `Qwen/Qwen3.8-27B-NVFP4` on this box**
2202:   (Task 6.2 step 5) — vLLM's NVFP4/FP8 kernel auto-selection is not
2203:   stable run-to-run (observed switching between `CutlassNvFp4LinearKernel` and `FlashInferCutlassNvFp4LinearKernel`
2204:   across otherwise-identical launches against the same model
2205:   directory), and the on-disk `torch.compile` AOT cache does not key on
2206:   which kernel was selected — a run that auto-selects a different
2207:   kernel than a cached compile can crash-loop with an `AttributeError`
2208:   on a missing op. An explicit `--linear-backend flashinfer_cutlass`
2209:   pin was tried and rejected: it broke the checkpoint's SEPARATE FP8
2210:   W8A8 kernel selection (used for attention/lm_head/last-8-layers-MLP),
2211:   since `--linear-backend` applies across this checkpoint's mixed
2212:   NVFP4+FP8 quantization scheme rather than to NVFP4 GEMM alone.
2213:   Disabling the compile cache instead forces a fresh, self-consistent
2214:   compile every launch (slightly longer cold start, no AOT-artifact
2215:   reuse) and is now baked into
2216:   `/home/admin/scripts/qwen3.8-27b-nvfp4-1m.sh`.
2217: - **2026-08-23**: **Built and validated
2218:   `qwen3.8-27b-nvfp4-1m.service`** (Task 6.2 step 5) — a production-
2219:   candidate NVFP4+YaRN systemd deployment at the 1M native ceiling,
2220:   mirroring the BF16 `qwen3.8-27b-vllm.service` pattern (`--user` unit,
2221:   disabled/no-autostart). Passed the full re-verification: KV cache
2222:   1,209,295 tokens (1.15x margin, matches step 4's measurement
2223:   exactly), 39.0% pool free, coherent output, clean tool-call, all
2224:   three thinking-control modes correct. Left running (not stopped) so
2225:   OpenCode can be pointed at it for Task 6.2 step 6 (the REQ-005
2226:   quality-impact check) — explicitly a user-judgment task, not
2227:   automatable, per feat-1 ACC-010's "user's own existing coding-task
2228:   examples" precedent. The BF16 and NVFP4 services cannot run
2229:   simultaneously (shared port 8000, unified-pool constraint) — exactly
2230:   one should be active at a time.
2231: - **2026-08-24**: **NVFP4 adopted as the production precision,
2232:   replacing BF16** (Task 6.2 steps 6-7, REQ-005/ACC-004) — the user's
2233:   own coding-task quality check via OpenCode against the NVFP4
2234:   candidate returned "quality is fine, adopt it," clearing REQ-005's
2235:   bar for adopting a quantized variant over BF16 by default, backed by
2236:   Task 6.1's already-measured 2.54x-7.7x decode speedup. BF16 is kept
2237:   on disk, disabled, as a documented fallback rather than deleted.
2238: - **2026-08-24**: **Production context stays at 896K, not the 1M
2239:   ceiling**, even though NVFP4 clears 1M with more headroom (36.2%
2240:   free) than BF16 ever cleared 896K (16.1% free) — independent user
2241:   decision after testing ("the ctx is large enough with that size").
2242:   This meant retiring the already-built 1M NVFP4 candidate service
2243:   rather than promoting it, and building a new 896K NVFP4 production
2244:   service instead (`qwen3.8-27b-nvfp4-896k.service`).
2245: - **2026-08-24**: **Discovered a real Ollama/vLLM unified-pool
2246:   coexistence risk beyond what earlier capacity-testing sessions
2247:   accounted for**: a resident Ollama-served model can silently persist
2248:   across sessions (Docker `--restart always`, model held loaded via the
2249:   Ollama API) and block a fresh vLLM engine's startup free-memory check
2250:   even when no vLLM instance was previously running. Fixed operationally
2251:   (`docker exec ollama ollama stop <model>`) but not solved
2252:   structurally — no guard/quota prevents an Ollama load during normal
2253:   operation from pressuring the production vLLM service's already-thin
2254:   headroom (40.1% free at 896K). Recorded as an open operational
2255:   caveat, not a task.
2256: - **2026-08-24**: **MTP speculative decoding activated in production**
2257:   (Task 6.3, same-day follow-up) — previously deferred out of the
2258:   initial NVFP4 896K cutover because Task 6.1's MTP benchmarks were
2259:   only ever run at native 262144 context, never combined with YaRN.
2260:   Tested and adopted after clearing all three bars: capacity (KV-cache
2261:   margin drops from 1.17x to 1.07x but stays >1.0x, pool free ~39%,
2262:   still above the 15% policy floor), correctness (byte-identical greedy
2263:   output vs. non-MTP at the same context), and throughput (2.66x/3.12x
2264:   decode speedup at 896K/YaRN, matching Task 6.1's native-context
2265:   finding). Promoted into the same production script/service (no model
2266:   id change); the pre-MTP script is kept as a rollback path.
2267: 
2268: ### Related PRs / Commits
2269: 
2270: - [Issue #3](https://github.com/dfch/biz.dfch.LlmOps/issues/3): On-prem
2271:   Qwen3.8-27B serving with extended context for OpenCode + OpenWebUI —
2272:   description mirrors this README's Overview section. (Issue #2 was an
2273:   accidental duplicate, created moments earlier with identical title/

(Showing lines 2040-2273 of 2274. Use offset=2274 to continue.)
</content>
```

---

## Assistant (Plan · Claude Sonnet 5 · 39.2s)

_Thinking:_



## Recommendation: Qwen3.8-27B (NVFP4 + MTP, vLLM, YaRN to 896K)

This isn't a cold-start question for this repo — `feat-3-qwen3.8-27b-large-context` already deployed and empirically benchmarked almost exactly this hardware/context target (a GB10/DGX-Spark-clone, 128GB unified LPDDR5x, measured **119.63 GiB usable pool** — essentially your "120GB usable"). I'd treat that feature's findings as the answer rather than re-deriving it from scratch.

**Model**: `Qwen/Qwen3.8-27B` — Apache-2.0, 27B dense params, hybrid Gated DeltaNet + Gated Attention, native 262,144-token context extensible via the vendor's documented YaRN `rope_parameters` override.

**Production config that was actually measured to work on this exact hardware class**:
- Engine: **vLLM** (0.27.1 was required for arm64/SM121a NVFP4 kernel support at the time)
- Weights: **NVFP4** (`unsloth/Qwen3.8-27B-NVFP4`) — not BF16
- Speculative decoding: **MTP** (draft head ships in the same checkpoint, `num_speculative_tokens=5`)
- Context: **YaRN factor 3.5 → 917,504 tokens (896K)** — comfortably clears a 768K floor
- KV cache: **`--kv-cache-dtype fp8`** with an **explicit `--kv-cache-memory-bytes`** (critical — see caveat below)

**Why this, not BF16 or a bigger MoE**:
1. **Speed is the real constraint on this hardware, not capacity.** BF16 decode measured only **4.4 tok/s** at 896K on this class of box — unusable for interactive agentic coding. NVFP4 alone: **11.2 tok/s** (2.54x). NVFP4+MTP: **31–34 tok/s** (7–7.7x over BF16). DGX-Spark-class unified memory is bandwidth-bound, so quantization + speculative decoding aren't optional nice-to-haves here, they're what makes it usable at all.
2. **768K on a shared unified-memory pool is a real risk, not a formality.** vLLM's default `--gpu-memory-utilization` sizing starved the *OS itself* (down to ~1.7–3.5 GiB free system-wide) at 768K+ before the fix. `--kv-cache-dtype fp8` + explicit `--kv-cache-memory-bytes` was required to get real headroom (19.8–43% free depending on precision/context). Don't skip this if you replicate the setup.
3. **Quality checked, not assumed**: the repo's own user ran real coding-task examples via OpenCode against NVFP4 and NVFP4+MTP and judged both "fine, adopt it" — no reported regression vs BF16.
4. **1M native ceiling is reachable with NVFP4** (36.2% free, comfortably clears policy) if you want to push past 896K — BF16 alone fails the safety margin at 1M (12.9% free). 896K was chosen in that project only because the user judged it "large enough," not because 1M didn't work.
5. **Alternatives already tried on other boxes in this repo don't transfer well here**: GLM-5.2 (744B MoE) needed a forced lossy quant just to fit 384GB of *discrete* VRAM across 4 GPUs — wrong shape for a single 120GB unified pool. DeepSeek-V4-Flash hit an unresolved SM120-specific vLLM bug (degenerate output) on Blackwell Max-Q GPUs — not the same GPU family as DGX Spark's SM121a, but a reminder that brand-new Blackwell architectures need a smoke test before trusting them.

**Caveats worth flagging**:
- Static YaRN scaling hurts short-prompt performance once a large factor is baked in — only worth it if 768K+ is your *typical* working context, not just a ceiling you want available.
- Requires an arm64/GB10-compatible vLLM build with working NVFP4 kernels for SM121a — verify (`cutlass_scaled_mm_supports_fp4(121)`) before committing, don't assume.
- A resident Ollama-loaded model can silently block a fresh vLLM start on the shared pool even after a prior vLLM instance stopped — worth checking before deploying.
- Vision/video capability of Qwen3.8-27B was explicitly out of scope in the prior work (text/coding only, matches your ask).

Want me to draft a task list / feature spec for deploying this on your actual DGX Spark box (following the `feat-3` pattern), or do you just need the recommendation for now?

---

## User

can you search huggingface.co and examine if there are other better models than qwen3.8-27b?

---

## Assistant (Plan · Claude Sonnet 5 · 17.4s)

_Thinking:_



**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/models?pipeline_tag=text-generation&sort=trending&search=coder"
}
```

**Output:**
```
                

  Text Generation Models – Hugging Face   

 [![Hugging Face's logo](/front/assets/huggingface_logo-noborder.svg) Hugging Face](/)

-   [Models](/models)
-   [Datasets](/datasets)
-   [Spaces](/spaces)
-   [Buckets new](/storage)
-   [Docs](/docs)
-   [Enterprise](/enterprise)
-   [Pricing](/pricing)
-   -   Website
        
        -   [Tasks](/tasks)
        -   [HuggingChat](/chat)
        -   [Collections](/collections)
        -   [Languages](/languages)
        -   [Organizations](/organizations)
    -   Community
        
        -   [Blog](/blog)
        -   [Posts](/posts)
        -   [Daily Papers](/papers)
        -   [Hardware](/hardware)
        -   [Learn](/learn)
        -   [Discord](/join/discord)
        -   [Forum](https://discuss.huggingface.co/)
        -   [GitHub](https://github.com/huggingface)
    -   Solutions
        
        -   [Team & Enterprise](/enterprise)
        -   [Hugging Face PRO](/pro)
        -   [Enterprise Support](/support)
        -   [Inference Providers](/inference/models)
        -   [Inference Endpoints](/inference-endpoints)
        -   [Storage Buckets](/storage)
    
-   ---
    
-   [Log In](/login)
-   [Sign Up](/join)

### Edit Models filters

-   Main
-   Tasks 1
-   Libraries
-   Languages
-   Licenses
-   Other

Tasks

Reset Tasks

[

Text Generation

](/models?pipeline_tag=text-generation)[

Any-to-Any

](/models?pipeline_tag=any-to-any)[

Image-Text-to-Text

](/models?pipeline_tag=image-text-to-text)[

Image-to-Text

](/models?pipeline_tag=image-to-text)[

Image-to-Image

](/models?pipeline_tag=image-to-image)[

Text-to-Image

](/models?pipeline_tag=text-to-image)[

Text-to-Video

](/models?pipeline_tag=text-to-video)[

Text-to-Speech

](/models?pipeline_tag=text-to-speech)\+ 44

Parameters

Reset Parameters

  < 1B

6B

12B

32B

128B

\> 500B

< 1B

\> 500B

Libraries

[

PyTorch

](/models?library=pytorch)[

 google-tensorflow TensorFlow

](/models?library=tf)[

 JAX

](/models?library=jax)[

Transformers

](/models?library=transformers)[

Diffusers

](/models?library=diffusers)[

GGUF

](/models?library=gguf)[

MLX

](/models?library=mlx)[

Transformers.js

](/models?library=transformers.js)[

Safetensors

](/models?library=safetensors)\+ 45\+ 47\+ 44

Apps

[

vLLM

](/models?other=vllm)[

llama.cpp

](/models?other=llama.cpp)[

MLX LM

](/models?other=mlx-lm)[

LM Studio

](/models?other=lmstudio)[

Ollama

](/models?other=ollama)[

Jan

](/models?other=jan)[

Draw Things

](/models?other=drawthings)[

DiffusionBee

](/models?other=diffusionbee)[

JoyFusion

](/models?other=joyfusion)\+ 8\+ 10

Inference Providers

[

Groq

](/models?inference_provider=groq)[

Novita

](/models?inference_provider=novita)[

Cerebras

](/models?inference_provider=cerebras)[

Nscale

](/models?inference_provider=nscale)[

fal

](/models?inference_provider=fal-ai)[

Together AI

](/models?inference_provider=together)[

Fireworks

](/models?inference_provider=fireworks-ai)[

Featherless AI

](/models?inference_provider=featherless-ai)[

Zai

](/models?inference_provider=zai-org)\+ 9\+ 11\+ 10

Hardware

[Add your hardware](/settings/hardware)

Apply filters

# Models

6,400

Base only Inference Available Inference

Edit filters

Sort:  Trending

**Active filters:** text-generation

Clear all

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/noauth/Jq2eMstaOFxpkW95lD60Y.png)

#### JackAgentLead/Jack-3.8-27B-Coder-16GB-VRAM

Text Generation • 27B • Updated 5 days ago • 4.11k • 36



](/JackAgentLead/Jack-3.8-27B-Coder-16GB-VRAM)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6438cc09c04b3b996ea73196/izeqDmgIB27KPxPkisPSF.png)

#### Kwaipilot/KAT-Coder-V2.5-Dev

Text Generation • 35B • Updated about 1 month ago • 50.1k • 621



](/Kwaipilot/KAT-Coder-V2.5-Dev)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/62ecdc18b72a69615d6bd857/E4lkPz1TZNLzIFr_dR273.png)

#### unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF

Text Generation • 31B • Updated Jan 30 • 12.5M • 925



](/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/62ecdc18b72a69615d6bd857/E4lkPz1TZNLzIFr_dR273.png)

#### unsloth/Qwen3-Coder-Next-GGUF

Text Generation • 80B • Updated Mar 6 • 165k • 815



](/unsloth/Qwen3-Coder-Next-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/68381c529cf21282bb58fff5/BOAMsI-nrZMo-pannGgA-.png)

#### yuxinlu1/gemma-4-12B-coder-fable5-composer2.5-v1-GGUF

Text Generation • 12B • Updated Jun 19 • 510k • 2.85k



](/yuxinlu1/gemma-4-12B-coder-fable5-composer2.5-v1-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

#### Qwen/Qwen3-Coder-Next

Text Generation • 80B • Updated Feb 3 • 490k • • 1.62k



](/Qwen/Qwen3-Coder-Next)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

#### Qwen/Qwen3-Coder-30B-A3B-Instruct

Text Generation • 31B • Updated Dec 3, 2025 • 799k • • 1.22k



](/Qwen/Qwen3-Coder-30B-A3B-Instruct)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6435718aaaef013d1aec3b8b/XKf-8MA47tjVAM6SCX0MP.jpeg)

#### bartowski/Kwaipilot\_KAT-Coder-V2.5-Dev-GGUF

Text Generation • 35B • Updated Jul 24 • 326k • 126



](/bartowski/Kwaipilot_KAT-Coder-V2.5-Dev-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6538815d1bdb3c40db94fbfa/xMBly9PUMphrFVMxLX4kq.png)

#### deepseek-ai/DeepSeek-Coder-V2-Lite-Instruct

Text Generation • 16B • Updated Jul 3, 2024 • 629k • 643



](/deepseek-ai/DeepSeek-Coder-V2-Lite-Instruct)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/623c830997ddced06d78699b/3qTjC7d3YFCJTwpxd2noq.png)

#### mlx-community/gemma-4-12b-coder-fable5-composer2.5-4bit

Text Generation • 12B • Updated Jun 21 • 7.89k • 56



](/mlx-community/gemma-4-12b-coder-fable5-composer2.5-4bit)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

#### Qwen/Qwen2.5-Coder-7B-Instruct

Text Generation • 8B • Updated Jan 12, 2025 • 2.39M • • 782



](/Qwen/Qwen2.5-Coder-7B-Instruct)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

#### Qwen/Qwen2.5-Coder-32B-Instruct

Text Generation • 33B • Updated Jan 12, 2025 • 1.57M • • 2.11k



](/Qwen/Qwen2.5-Coder-32B-Instruct)

[

![](/avatars/030c55db40b80f4b54e0c7fd30d2701d.svg)

#### Lord-H4D3ZS/Qwen3.8-Distill-35B-A3B-Coder-Abliterated

Text Generation • 36B • Updated 12 days ago • 24.7k • 6



](/Lord-H4D3ZS/Qwen3.8-Distill-35B-A3B-Coder-Abliterated)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/64445e5f1bc692d87b27e183/Quwh3tlKXa1y7aduVfxZi.png)

#### lmstudio-community/DeepSeek-Coder-V2-Lite-Instruct-GGUF

Text Generation • 16B • Updated Jun 22, 2024 • 23.3k • 93



](/lmstudio-community/DeepSeek-Coder-V2-Lite-Instruct-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

#### Qwen/Qwen2.5-Coder-1.5B

Text Generation • 2B • Updated Nov 18, 2024 • 160k • • 102



](/Qwen/Qwen2.5-Coder-1.5B)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

#### Qwen/Qwen2.5-Coder-7B-Instruct-GGUF

Text Generation • 8B • Updated Nov 12, 2024 • 242k • 393



](/Qwen/Qwen2.5-Coder-7B-Instruct-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

#### Qwen/Qwen2.5-Coder-14B-Instruct-GGUF

Text Generation • 15B • Updated Nov 12, 2024 • 90.3k • 191



](/Qwen/Qwen2.5-Coder-14B-Instruct-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

#### Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8

Text Generation • 31B • Updated Dec 3, 2025 • 1.18M • 197



](/Qwen/Qwen3-Coder-30B-A3B-Instruct-FP8)

[

![](/avatars/da57395b183c29b1e8812bffd8ce46f5.svg)

#### jica98/qwen3.5-4B-super-coder

Text Generation • 4B • Updated Jun 27 • 31.7k • 76



](/jica98/qwen3.5-4B-super-coder)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/65fb32f58a66679f92b73458/ozQW6W27tVCM-SRouzGJa.jpeg)

#### ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF

Text Generation • 26B • Updated 24 days ago • 97.6k • 35



](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF)

[

![](/avatars/87f38579591500819fa2fc9c0a5a39b0.svg)

#### Myric/KAT-Coder-V2.5-Dev-MTP-APEX-GGUF

Text Generation • 35B • Updated 6 days ago • 10.8k • 8



](/Myric/KAT-Coder-V2.5-Dev-MTP-APEX-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

#### Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF

Text Generation • 2B • Updated Nov 12, 2024 • 101k • 100



](/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6435718aaaef013d1aec3b8b/XKf-8MA47tjVAM6SCX0MP.jpeg)

#### bartowski/Qwen2.5-Coder-32B-Instruct-GGUF

Text Generation • 33B • Updated Nov 10, 2024 • 119k • 125



](/bartowski/Qwen2.5-Coder-32B-Instruct-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

#### Qwen/Qwen2.5-Coder-0.5B

Text Generation • 0.5B • Updated Nov 18, 2024 • 22.6k • • 60



](/Qwen/Qwen2.5-Coder-0.5B)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6435718aaaef013d1aec3b8b/XKf-8MA47tjVAM6SCX0MP.jpeg)

#### bartowski/Qwen2.5-Coder-7B-Instruct-abliterated-GGUF

Text Generation • 8B • Updated Nov 14, 2024 • 22.1k • 28



](/bartowski/Qwen2.5-Coder-7B-Instruct-abliterated-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/64c0e503f04093c08831dc6f/-25Y4Kd8KVkbOmYqqOM1D.jpeg)

#### BlossomsAI/Qwen2.5-Coder-7B-Instruct-Uncensored

Text Generation • 8B • Updated Feb 12, 2025 • 495 • • 9



](/BlossomsAI/Qwen2.5-Coder-7B-Instruct-Uncensored)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

#### Qwen/Qwen3-Coder-480B-A35B-Instruct

Text Generation • 480B • Updated Aug 21, 2025 • 35.2k • • 1.37k



](/Qwen/Qwen3-Coder-480B-A35B-Instruct)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/66228dc4c8920ec3513dc81a/9stczijVqp6TgQduzT8kN.png)

#### huihui-ai/Huihui-Qwen3-Coder-Next-abliterated

Text Generation • 80B • Updated Feb 9 • 2.31k • 61



](/huihui-ai/Huihui-Qwen3-Coder-Next-abliterated)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6435718aaaef013d1aec3b8b/XKf-8MA47tjVAM6SCX0MP.jpeg)

#### bartowski/huihui-ai\_Qwen3-Coder-Next-abliterated-GGUF

Text Generation • 80B • Updated Feb 10 • 35.4k • 34



](/bartowski/huihui-ai_Qwen3-Coder-Next-abliterated-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6835ec61de90b2eb4d49a71b/jGZuTexduBzH6zyFDxvEi.jpeg)

#### bigatuna/Qwen3.5-9b-Sushi-Coder-RL-GGUF

Text Generation • 9B • Updated Apr 20 • 3.67k • 95



](/bigatuna/Qwen3.5-9b-Sushi-Coder-RL-GGUF)

-   Previous
-   [1](?pipeline_tag=text-generation&p=0&sort=trending&search=coder)
-   [2](?pipeline_tag=text-generation&p=1&sort=trending&search=coder)
-   [3](?pipeline_tag=text-generation&p=2&sort=trending&search=coder)
-   [...](#)
-   [100](?pipeline_tag=text-generation&p=99&sort=trending&search=coder)
-   [Next](?pipeline_tag=text-generation&p=1&sort=trending&search=coder)

System theme

Company

[TOS](/terms-of-service) [Privacy](/privacy) [About](/huggingface) [Careers](https://apply.workable.com/huggingface/)[](/)

Website

[Models](/models) [Datasets](/datasets) [Spaces](/spaces) [Pricing](/pricing) [Docs](/docs)
```

**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/models?sort=trending&search=1M+context"
}
```

**Output:**
```
                

  Models – Hugging Face   

 [![Hugging Face's logo](/front/assets/huggingface_logo-noborder.svg) Hugging Face](/)

-   [Models](/models)
-   [Datasets](/datasets)
-   [Spaces](/spaces)
-   [Buckets new](/storage)
-   [Docs](/docs)
-   [Enterprise](/enterprise)
-   [Pricing](/pricing)
-   -   Website
        
        -   [Tasks](/tasks)
        -   [HuggingChat](/chat)
        -   [Collections](/collections)
        -   [Languages](/languages)
        -   [Organizations](/organizations)
    -   Community
        
        -   [Blog](/blog)
        -   [Posts](/posts)
        -   [Daily Papers](/papers)
        -   [Hardware](/hardware)
        -   [Learn](/learn)
        -   [Discord](/join/discord)
        -   [Forum](https://discuss.huggingface.co/)
        -   [GitHub](https://github.com/huggingface)
    -   Solutions
        
        -   [Team & Enterprise](/enterprise)
        -   [Hugging Face PRO](/pro)
        -   [Enterprise Support](/support)
        -   [Inference Providers](/inference/models)
        -   [Inference Endpoints](/inference-endpoints)
        -   [Storage Buckets](/storage)
    
-   ---
    
-   [Log In](/login)
-   [Sign Up](/join)

### Edit Models filters

-   Main
-   Tasks
-   Libraries
-   Languages
-   Licenses
-   Other

Tasks

[

Text Generation

](/models?pipeline_tag=text-generation)[

Any-to-Any

](/models?pipeline_tag=any-to-any)[

Image-Text-to-Text

](/models?pipeline_tag=image-text-to-text)[

Image-to-Text

](/models?pipeline_tag=image-to-text)[

Image-to-Image

](/models?pipeline_tag=image-to-image)[

Text-to-Image

](/models?pipeline_tag=text-to-image)[

Text-to-Video

](/models?pipeline_tag=text-to-video)[

Text-to-Speech

](/models?pipeline_tag=text-to-speech)\+ 44

Parameters

Reset Parameters

  < 1B

6B

12B

32B

128B

\> 500B

< 1B

\> 500B

Libraries

[

PyTorch

](/models?library=pytorch)[

 google-tensorflow TensorFlow

](/models?library=tf)[

 JAX

](/models?library=jax)[

Transformers

](/models?library=transformers)[

Diffusers

](/models?library=diffusers)[

GGUF

](/models?library=gguf)[

MLX

](/models?library=mlx)[

Transformers.js

](/models?library=transformers.js)[

Safetensors

](/models?library=safetensors)\+ 45\+ 47\+ 44

Apps

[

vLLM

](/models?other=vllm)[

llama.cpp

](/models?other=llama.cpp)[

MLX LM

](/models?other=mlx-lm)[

LM Studio

](/models?other=lmstudio)[

Ollama

](/models?other=ollama)[

Jan

](/models?other=jan)[

Draw Things

](/models?other=drawthings)[

DiffusionBee

](/models?other=diffusionbee)[

JoyFusion

](/models?other=joyfusion)\+ 8\+ 10

Inference Providers

[

Groq

](/models?inference_provider=groq)[

Novita

](/models?inference_provider=novita)[

Cerebras

](/models?inference_provider=cerebras)[

Nscale

](/models?inference_provider=nscale)[

fal

](/models?inference_provider=fal-ai)[

Together AI

](/models?inference_provider=together)[

Fireworks

](/models?inference_provider=fireworks-ai)[

Featherless AI

](/models?inference_provider=featherless-ai)[

Zai

](/models?inference_provider=zai-org)\+ 9\+ 11\+ 10

Hardware

[Add your hardware](/settings/hardware)

Apply filters

# Models

20

Base only Inference Available Inference

Add filters

Sort:  Trending

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/641dfddf3bae5a77636817c5/2IwNwh9kK98eCHUmOGoWD.png)

#### winglian/llama-3-1m-context-gradient-lora

Updated Apr 30, 2024 • 12



](/winglian/llama-3-1m-context-gradient-lora)

[

![](/avatars/d63cea9017482fd1d3a534f71504aefa.svg)

#### Vlad1m/destractive\_context

Text Classification • 0.4B • Updated May 19, 2024 • 6



](/Vlad1m/destractive_context)

[

![](/avatars/b35ee7bf25be7b703da7a8492afef093.svg)

#### dumbequation/Qwen2.5-7B-GRPO-1M-Context-Medical-Reasoning-f16

Text Generation • 8B • Updated Mar 4, 2025 • 17 • 1



](/dumbequation/Qwen2.5-7B-GRPO-1M-Context-Medical-Reasoning-f16)

[

![](/avatars/b35ee7bf25be7b703da7a8492afef093.svg)

#### dumbequation/Qwen2.5-7B-GRPO-1M-Context-Medical-Reasoning-f16-GGUF

8B • Updated Mar 4, 2025 • 38



](/dumbequation/Qwen2.5-7B-GRPO-1M-Context-Medical-Reasoning-f16-GGUF)

[

![](/avatars/b35ee7bf25be7b703da7a8492afef093.svg)

#### dumbequation/Qwen2.5-7B-GRPO-1M-Context-Medical-Reasoning-quant-GGUF

8B • Updated Feb 22, 2025 • 46



](/dumbequation/Qwen2.5-7B-GRPO-1M-Context-Medical-Reasoning-quant-GGUF)

[

![](/avatars/b35ee7bf25be7b703da7a8492afef093.svg)

#### dumbequation/Qwen2.5-7B-GRPO-1M-Context-Medical-Reasoning-f16-v2

Text Generation • 8B • Updated Mar 4, 2025 • 15 • 1



](/dumbequation/Qwen2.5-7B-GRPO-1M-Context-Medical-Reasoning-f16-v2)

[

![](/avatars/b35ee7bf25be7b703da7a8492afef093.svg)

#### dumbequation/Qwen2.5-7B-GRPO-1M-Context-Medical-Reasoning-f16-GGUF-v2

8B • Updated Mar 4, 2025 • 31



](/dumbequation/Qwen2.5-7B-GRPO-1M-Context-Medical-Reasoning-f16-GGUF-v2)

[

![](/avatars/b35ee7bf25be7b703da7a8492afef093.svg)

#### dumbequation/Qwen2.5-7B-GRPO-1M-Context-Medical-Reasoning-quant-GGUF-v2

8B • Updated Mar 4, 2025 • 119



](/dumbequation/Qwen2.5-7B-GRPO-1M-Context-Medical-Reasoning-quant-GGUF-v2)

[

![](/avatars/6b97d30ff0bdb5d5c633ba850af739cd.svg)

#### mradermacher/Qwen2.5-7B-GRPO-1M-Context-Medical-Reasoning-f16-GGUF

8B • Updated Feb 22, 2025 • 124 • 1



](/mradermacher/Qwen2.5-7B-GRPO-1M-Context-Medical-Reasoning-f16-GGUF)

[

![](/avatars/6b97d30ff0bdb5d5c633ba850af739cd.svg)

#### mradermacher/Qwen2.5-7B-GRPO-1M-Context-Medical-Reasoning-f16-v2-GGUF

8B • Updated Feb 22, 2025 • 134 • 1



](/mradermacher/Qwen2.5-7B-GRPO-1M-Context-Medical-Reasoning-f16-v2-GGUF)

[

![](/avatars/b5398d7a9aeb19a959fdd3895936171f.svg)

#### Disya/Qwen2.5-1M-RP-Context-Merge

Text Generation • 15B • Updated Aug 12, 2025 • 12



](/Disya/Qwen2.5-1M-RP-Context-Merge)

[

![](/avatars/b5398d7a9aeb19a959fdd3895936171f.svg)

#### Disya/Qwen2.5-1M-RP-Context-Merge-Q4\_K\_M-GGUF

15B • Updated Aug 12, 2025 • 490



](/Disya/Qwen2.5-1M-RP-Context-Merge-Q4_K_M-GGUF)

[

![](/avatars/b5398d7a9aeb19a959fdd3895936171f.svg)

#### Disya/Qwen2.5-1M-RP-Context-Merge-Q8\_0-GGUF

15B • Updated Aug 12, 2025 • 3



](/Disya/Qwen2.5-1M-RP-Context-Merge-Q8_0-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/1653390727490-5dd96eb166059660ed1ee413.jpeg)

#### apple/mobileclip2\_coca\_dfn2b\_s13b\_gbc1m-short\_context77

Updated Oct 9, 2025 • 9 • 1



](/apple/mobileclip2_coca_dfn2b_s13b_gbc1m-short_context77)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/64c4620f3e80e593568f3875/CkkKHS1GOp9UKZpA_arA_.jpeg)

#### loaiabdalslam/Ouroboros-1MContext-Gemma-270m

Text Generation • 0.3B • Updated Feb 11 • 20 • 9



](/loaiabdalslam/Ouroboros-1MContext-Gemma-270m)

[

![](/avatars/2d4bdc66bdd173d12bee651145e6a24d.svg)

#### neutroon/Ouroboros-1MContext-Gemma-270m

Text Generation • 0.3B • Updated Feb 12 • 11



](/neutroon/Ouroboros-1MContext-Gemma-270m)

[

![](/avatars/a04eebb1d323446f8f2c8e4c66d399f4.svg)

#### Mahmoud22/Ouroboros-1MContext-Gemma-270m

Text Generation • 0.3B • Updated Feb 14 • 13 • 1



](/Mahmoud22/Ouroboros-1MContext-Gemma-270m)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6238a5c325488d060324249d/7E46J76pm6jR4lpIYd9Ud.png)

#### LisaMegaWatts/Ouroboros-1MContext-Gemma-270m

0.3B • Updated Mar 19 • 7



](/LisaMegaWatts/Ouroboros-1MContext-Gemma-270m)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6372f6a1bd1595ae66a605d8/NvxUE08IEtqw9e7F7BmFD.png)

#### MonumentalSystems/Ouroboros-1MContext-Gemma-270m

Text Generation • 0.3B • Updated Mar 19 • 23



](/MonumentalSystems/Ouroboros-1MContext-Gemma-270m)

[

![](/avatars/e94965521cdd21f80d2587d60413c135.svg)

#### 0xdfi/GLM-5.2-1M-context-NVFP4-4x-DGX-Spark

Text Generation • Updated Jul 21 • 2



](/0xdfi/GLM-5.2-1M-context-NVFP4-4x-DGX-Spark)

System theme

Company

[TOS](/terms-of-service) [Privacy](/privacy) [About](/huggingface) [Careers](https://apply.workable.com/huggingface/)[](/)

Website

[Models](/models) [Datasets](/datasets) [Spaces](/spaces) [Pricing](/pricing) [Docs](/docs)
```

---

## Assistant (Plan · Claude Sonnet 5 · 17.9s)

_Thinking:_



**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/Qwen/Qwen3-Coder-Next"
}
```

**Output:**
```
                

  Qwen/Qwen3-Coder-Next · Hugging Face   

 [![Hugging Face's logo](/front/assets/huggingface_logo-noborder.svg) Hugging Face](/)

-   [Models](/models)
-   [Datasets](/datasets)
-   [Spaces](/spaces)
-   [Buckets new](/storage)
-   [Docs](/docs)
-   [Enterprise](/enterprise)
-   [Pricing](/pricing)
-   -   Website
        
        -   [Tasks](/tasks)
        -   [HuggingChat](/chat)
        -   [Collections](/collections)
        -   [Languages](/languages)
        -   [Organizations](/organizations)
    -   Community
        
        -   [Blog](/blog)
        -   [Posts](/posts)
        -   [Daily Papers](/papers)
        -   [Hardware](/hardware)
        -   [Learn](/learn)
        -   [Discord](/join/discord)
        -   [Forum](https://discuss.huggingface.co/)
        -   [GitHub](https://github.com/huggingface)
    -   Solutions
        
        -   [Team & Enterprise](/enterprise)
        -   [Hugging Face PRO](/pro)
        -   [Enterprise Support](/support)
        -   [Inference Providers](/inference/models)
        -   [Inference Endpoints](/inference-endpoints)
        -   [Storage Buckets](/storage)
    
-   ---
    
-   [Log In](/login)
-   [Sign Up](/join)

# 

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

](/Qwen)

[Qwen](/Qwen)

/

[Qwen3-Coder-Next](/Qwen/Qwen3-Coder-Next)

like 1.62k

Follow

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg) Qwen 101k

[

Text Generation

](/models?pipeline_tag=text-generation)[

Transformers

](/models?library=transformers)[

Safetensors

](/models?library=safetensors)[

qwen3\_next

](/models?other=qwen3_next)[

conversational

](/models?other=conversational)[

Eval Results

](/models?other=eval-results)

License: apache-2.0

[Model card](/Qwen/Qwen3-Coder-Next) [Files Files and versions

xet

](/Qwen/Qwen3-Coder-Next/tree/main)[Community

51

](/Qwen/Qwen3-Coder-Next/discussions)

Deploy

Copy to bucket new

Use this model

### Instructions to use Qwen/Qwen3-Coder-Next with libraries, inference providers, notebooks, and local apps. Follow these links to get started.

-   Libraries
-   [Transformers](/Qwen/Qwen3-Coder-Next?library=transformers)
    
    How to use Qwen/Qwen3-Coder-Next with Transformers:
    
    \# Use a pipeline as a high-level helper
    from transformers import pipeline
    
    pipe = pipeline("text-generation", model="Qwen/Qwen3-Coder-Next")
    messages = \[
        {"role": "user", "content": "Who are you?"},
    \]
    pipe(messages)
    
    \# Load model directly
    from transformers import AutoTokenizer, AutoModelForCausalLM
    
    tokenizer = AutoTokenizer.from\_pretrained("Qwen/Qwen3-Coder-Next")
    model = AutoModelForCausalLM.from\_pretrained("Qwen/Qwen3-Coder-Next", device\_map="auto")
    messages = \[
        {"role": "user", "content": "Who are you?"},
    \]
    inputs = tokenizer.apply\_chat\_template(
    	messages,
    	add\_generation\_prompt=True,
    	tokenize=True,
    	return\_dict=True,
    	return\_tensors="pt",
    ).to(model.device)
    
    outputs = model.generate(\*\*inputs, max\_new\_tokens=40)
    print(tokenizer.decode(outputs\[0\]\[inputs\["input\_ids"\].shape\[-1\]:\]))
    
-   Inference
-   Inference Providers
-   [HuggingChat](/chat/models/Qwen/Qwen3-Coder-Next)
-   Notebooks
-   [Google Colab](/Qwen/Qwen3-Coder-Next/colab)
-   [Kaggle](/Qwen/Qwen3-Coder-Next/kaggle)
-   Local Apps [Settings](/settings/local-apps "Set up your favorite local applications")
-   [vLLM](/Qwen/Qwen3-Coder-Next?local-app=vllm)
    
    How to use Qwen/Qwen3-Coder-Next with vLLM:
    
    ##### Install from pip and serve model
    
    \# Install vLLM from pip:
    pip install vllm
    # Start the vLLM server:
    vllm serve "Qwen/Qwen3-Coder-Next"
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:8000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3-Coder-Next",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
    			}
    		\]
    	}'
    
    ##### Use Docker
    
    docker model run hf.co/Qwen/Qwen3-Coder-Next
    
-   [SGLang](/Qwen/Qwen3-Coder-Next?local-app=sglang)
    
    How to use Qwen/Qwen3-Coder-Next with SGLang:
    
    ##### Install from pip and serve model
    
    \# Install SGLang from pip:
    pip install sglang
    # Start the SGLang server:
    python3 -m sglang.launch\_server \\
        --model-path "Qwen/Qwen3-Coder-Next" \\
        --host 0.0.0.0 \\
        --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3-Coder-Next",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
    			}
    		\]
    	}'
    
    ##### Use Docker images
    
    docker run --gpus all \\
        --shm-size 32g \\
        -p 30000:30000 \\
        -v ~/.cache/huggingface:/root/.cache/huggingface \\
        --env "HF\_TOKEN=<secret>" \\
        --ipc=host \\
        lmsysorg/sglang:latest \\
        python3 -m sglang.launch\_server \\
            --model-path "Qwen/Qwen3-Coder-Next" \\
            --host 0.0.0.0 \\
            --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3-Coder-Next",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
    			}
    		\]
    	}'
    
-   [Docker Model Runner](/Qwen/Qwen3-Coder-Next?local-app=docker-model-runner)
    
    How to use Qwen/Qwen3-Coder-Next with Docker Model Runner:
    
    docker model run hf.co/Qwen/Qwen3-Coder-Next
    
-   [Browse Quantizations](/models?other=base_model:quantized:Qwen/Qwen3-Coder-Next) to use this model in llama.cpp, Ollama, LM Studio, or any compatible app.
    

-   [Qwen3-Coder-Next](#qwen3-coder-next "Qwen3-Coder-Next")
    -   [Highlights](#highlights "Highlights")
        
    -   [Model Overview](#model-overview "Model Overview")
        
    -   [Quickstart](#quickstart "Quickstart")
        
    -   [Deployment](#deployment "Deployment")
        -   [SGLang](#sglang "SGLang")
        -   [vLLM](#vllm "vLLM")
    -   [Agentic Coding](#agentic-coding "Agentic Coding")
        
    -   [Best Practices](#best-practices "Best Practices")
        
    -   [Citation](#citation "Citation")
        

# [](#qwen3-coder-next)Qwen3-Coder-Next

## [](#highlights)Highlights

Today, we're announcing **Qwen3-Coder-Next**, an open-weight language model designed specifically for coding agents and local development. It features the following key enhancements:

-   **Super Efficient with Significant Performance**: With only 3B activated parameters (80B total parameters), it achieves performance comparable to models with 10–20x more active parameters, making it highly cost-effective for agent deployment.
-   **Advanced Agentic Capabilities**: Through an elaborate training recipe, it excels at long-horizon reasoning, complex tool usage, and recovery from execution failures, ensuring robust performance in dynamic coding tasks.
-   **Versatile Integration with Real-World IDE**: Its 256k context length, combined with adaptability to various scaffold templates, enables seamless integration with different CLI/IDE platforms (e.g., Claude Code, Qwen Code, Qoder, Kilo, Trae, Cline, etc.), supporting diverse development environments.

[![image/jpeg](https://qianwen-res.oss-accelerate-overseas.aliyuncs.com/Qwen3-Coder-Next/benchmarks.png)](https://qianwen-res.oss-accelerate-overseas.aliyuncs.com/Qwen3-Coder-Next/benchmarks.png)

[![image/jpeg](https://qianwen-res.oss-accelerate-overseas.aliyuncs.com/Qwen3-Coder-Next/swebench_pro.png)](https://qianwen-res.oss-accelerate-overseas.aliyuncs.com/Qwen3-Coder-Next/swebench_pro.png)

## [](#model-overview)Model Overview

**Qwen3-Coder-Next** has the following features:

-   Type: Causal Language Models
-   Training Stage: Pretraining & Post-training
-   Number of Parameters: 80B in total and 3B activated
-   Number of Parameters (Non-Embedding): 79B
-   Hidden Dimension: 2048
-   Number of Layers: 48
    -   Hybrid Layout: 12 \* (3 \* (Gated DeltaNet -> MoE) -> 1 \* (Gated Attention -> MoE))
-   Gated Attention:
    -   Number of Attention Heads: 16 for Q and 2 for KV
    -   Head Dimension: 256
    -   Rotary Position Embedding Dimension: 64
-   Gated DeltaNet:
    -   Number of Linear Attention Heads: 32 for V and 16 for QK
    -   Head Dimension: 128
-   Mixture of Experts:
    -   Number of Experts: 512
    -   Number of Activated Experts: 10
    -   Number of Shared Experts: 1
    -   Expert Intermediate Dimension: 512
-   Context Length: 262,144 natively

**NOTE: This model supports only non-thinking mode and does not generate `<think></think>` blocks in its output. Meanwhile, specifying `enable_thinking=False` is no longer required.**

For more details, including benchmark evaluation, hardware requirements, and inference performance, please refer to our [blog](https://qwen.ai/blog?id=qwen3-coder-next), [GitHub](https://github.com/QwenLM/Qwen3-Coder), and [Documentation](https://qwen.readthedocs.io/en/latest/).

## [](#quickstart)Quickstart

We advise you to use the latest version of `transformers`.

The following contains a code snippet illustrating how to use the model generate content based on given inputs.

```python
from transformers import AutoModelForCausalLM, AutoTokenizer

model_name = "Qwen/Qwen3-Coder-Next"

# load the tokenizer and the model
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(
  model_name,
  torch_dtype="auto",
  device_map="auto"
)

# prepare the model input
prompt = "Write a quick sort algorithm."
messages = [
  {"role": "user", "content": prompt}
]
text = tokenizer.apply_chat_template(
  messages,
  tokenize=False,
  add_generation_prompt=True,
)
model_inputs = tokenizer([text], return_tensors="pt").to(model.device)

# conduct text completion
generated_ids = model.generate(
    **model_inputs,
    max_new_tokens=65536
)
output_ids = generated_ids[0][len(model_inputs.input_ids[0]):].tolist() 

content = tokenizer.decode(output_ids, skip_special_tokens=True)

print("content:", content)
```

**Note: If you encounter out-of-memory (OOM) issues, consider reducing the context length to a shorter value, such as `32,768`.**

For local use, applications such as Ollama, LMStudio, MLX-LM, llama.cpp, and KTransformers have also supported Qwen3.

## [](#deployment)Deployment

For deployment, you can use the latest `sglang` or `vllm` to create an OpenAI-compatible API endpoint.

### [](#sglang)SGLang

[SGLang](https://github.com/sgl-project/sglang) is a fast serving framework for large language models and vision language models. SGLang could be used to launch a server with OpenAI-compatible API service.

`sglang>=v0.5.8` is required for Qwen3-Coder-Next, which can be installed using:

```shell
pip install 'sglang[all]>=v0.5.8'
```

See [its documentation](https://docs.sglang.ai/get_started/install.html) for more details.

The following command can be used to create an API endpoint at `http://localhost:30000/v1` with maximum context length 256K tokens using tensor parallel on 4 GPUs.

```shell
python -m sglang.launch_server --model Qwen/Qwen3-Coder-Next --port 30000 --tp-size 2 --tool-call-parser qwen3_coder
```

> The default context length is 256K. Consider reducing the context length to a smaller value, e.g., `32768`, if the server fails to start.

### [](#vllm)vLLM

[vLLM](https://github.com/vllm-project/vllm) is a high-throughput and memory-efficient inference and serving engine for LLMs. vLLM could be used to launch a server with OpenAI-compatible API service.

`vllm>=0.15.0` is required for Qwen3-Coder-Next, which can be installed using:

```shell
pip install 'vllm>=0.15.0'
```

See [its documentation](https://docs.vllm.ai/en/stable/getting_started/installation/index.html) for more details.

The following command can be used to create an API endpoint at `http://localhost:8000/v1` with maximum context length 256K tokens using tensor parallel on 4 GPUs.

```shell
vllm serve Qwen/Qwen3-Coder-Next --port 8000 --tensor-parallel-size 2 --enable-auto-tool-choice --tool-call-parser qwen3_coder
```

> The default context length is 256K. Consider reducing the context length to a smaller value, e.g., `32768`, if the server fails to start.

## [](#agentic-coding)Agentic Coding

Qwen3-Coder-Next excels in tool calling capabilities.

You can simply define or use any tools as following example.

```python
# Your tool implementation
def square_the_number(num: float) -> dict:
    return num ** 2

# Define Tools
tools=[
    {
        "type":"function",
        "function":{
            "name": "square_the_number",
            "description": "output the square of the number.",
            "parameters": {
                "type": "object",
                "required": ["input_num"],
                "properties": {
                    'input_num': {
                        'type': 'number', 
                        'description': 'input_num is a number that will be squared'
                        }
                },
            }
        }
    }
]

from openai import OpenAI
# Define LLM
client = OpenAI(
    # Use a custom endpoint compatible with OpenAI API
    base_url='http://localhost:8000/v1',  # api_base
    api_key="EMPTY"
)
 
messages = [{'role': 'user', 'content': 'square the number 1024'}]

completion = client.chat.completions.create(
    messages=messages,
    model="Qwen3-Coder-Next",
    max_tokens=65536,
    tools=tools,
)

print(completion.choices[0])
```

## [](#best-practices)Best Practices

To achieve optimal performance, we recommend the following sampling parameters: `temperature=1.0`, `top_p=0.95`, `top_k=40`.

## [](#citation)Citation

If you find our work helpful, feel free to give us a cite.

```
@techreport{qwen_qwen3_coder_next_tech_report,
  title        = {Qwen3-Coder-Next Technical Report},
  author       = {{Qwen Team}},
  url          = {https://github.com/QwenLM/Qwen3-Coder/blob/main/qwen3_coder_next_tech_report.pdf},
  note         = {Accessed: 2026-02-03}
}
```

Downloads last month

490,480

Safetensors[](https://huggingface.co/docs/safetensors)

Model size

80B params

Tensor type

BF16

·

Chat template

Files info

Inference Providers [NEW](https://huggingface.co/docs/inference-providers)

Novita

[

Text Generation

](/tasks/text-generation "Learn more about text-generation")

Examples

Input a message to start chatting with **Qwen/Qwen3-Coder-Next**.

Send

View Code Snippets

[Compare providers](/inference/models?model=Qwen%2FQwen3-Coder-Next)

## Model tree for Qwen/Qwen3-Coder-Next[](/docs/hub/model-cards#specifying-a-base-model)

Adapters

[7 models](/models?other=base_model:adapter:Qwen/Qwen3-Coder-Next)

Finetunes

[38 models](/models?other=base_model:finetune:Qwen/Qwen3-Coder-Next)

Quantizations

[](/models?apps=llama.cpp&other=base_model:quantized:Qwen/Qwen3-Coder-Next "Use with llama.cpp")[](/models?apps=lmstudio&other=base_model:quantized:Qwen/Qwen3-Coder-Next "Use with LM Studio")[](/models?apps=jan&other=base_model:quantized:Qwen/Qwen3-Coder-Next "Use with Jan")[](/models?apps=ollama&other=base_model:quantized:Qwen/Qwen3-Coder-Next "Use with Ollama")

[119 models](/models?other=base_model:quantized:Qwen/Qwen3-Coder-Next)

## Spaces using Qwen/Qwen3-Coder-Next 100

[

🏆

akhaliq/anycoder

](/spaces/akhaliq/anycoder)[

🌌

hfmlsoc/different-flops

](/spaces/hfmlsoc/different-flops)[

💬

lalopenguin/Qwen-Qwen3-Coder-Next

](/spaces/lalopenguin/Qwen-Qwen3-Coder-Next)[

🐈‍⬛

Chinook416/test\_caracat\_code

](/spaces/Chinook416/test_caracat_code)[

💬

acecalisto3/Qwen-Qwen3-Coder-Next

](/spaces/acecalisto3/Qwen-Qwen3-Coder-Next)[

🐠

LogitCode/FlexChat

](/spaces/LogitCode/FlexChat)[

🐠

LogitCode/FlexChat-Warm

](/spaces/LogitCode/FlexChat-Warm)[

🐠

LogitCode/FlexChat-terminal

](/spaces/LogitCode/FlexChat-terminal)\+ 95 Spaces \+ 92 Spaces

## Collection including Qwen/Qwen3-Coder-Next

[

#### Qwen3-Coder-Next

Collection

4 items • Updated Feb 3 • 130

](/collections/Qwen/qwen3-coder-next)

## Evaluation results[](https://huggingface.co/docs/hub/eval-results)

-   [SWE-bench/SWE-bench\_Verified](/datasets/SWE-bench/SWE-bench_Verified) · Swe Bench Resolved [View evaluation results](/Qwen/Qwen3-Coder-Next/discussions/43)[
    
    ![](https://cdn-avatars.huggingface.co/v1/production/uploads/1608042047613-5f1158120c833276f61f1a84.jpeg)
    
    source](https://huggingface.co/papers/2603.00729) [leaderboard](/datasets/SWE-bench/SWE-bench_Verified?eval_result=Qwen/Qwen3-Coder-Next&leaderboard_task_id=swe_bench_%_resolved)
    
    70.6 \*
    
-   [ScaleAI/SWE-bench\_Pro](/datasets/ScaleAI/SWE-bench_Pro) · SWE Bench Pro [View evaluation results](/Qwen/Qwen3-Coder-Next/discussions/43)[
    
    ![](https://cdn-avatars.huggingface.co/v1/production/uploads/1608042047613-5f1158120c833276f61f1a84.jpeg)
    
    source](https://huggingface.co/papers/2603.00729) [leaderboard](/datasets/ScaleAI/SWE-bench_Pro?eval_result=Qwen/Qwen3-Coder-Next&leaderboard_task_id=SWE_Bench_Pro)
    
    44.3 \*
    
-   [harborframework/terminal-bench-2.0](/datasets/harborframework/terminal-bench-2.0) · Terminalbench 2 [View evaluation results](/Qwen/Qwen3-Coder-Next/discussions/43) [leaderboard](/datasets/harborframework/terminal-bench-2.0?eval_result=Qwen/Qwen3-Coder-Next&leaderboard_task_id=terminalbench_2)
    
    36.2 \*
    

System theme

Company

[TOS](/terms-of-service) [Privacy](/privacy) [About](/huggingface) [Careers](https://apply.workable.com/huggingface/)[](/)

Website

[Models](/models) [Datasets](/datasets) [Spaces](/spaces) [Pricing](/pricing) [Docs](/docs)
```

**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct"
}
```

**Output:**
```
                

  Qwen/Qwen3-Coder-30B-A3B-Instruct · Hugging Face   

 [![Hugging Face's logo](/front/assets/huggingface_logo-noborder.svg) Hugging Face](/)

-   [Models](/models)
-   [Datasets](/datasets)
-   [Spaces](/spaces)
-   [Buckets new](/storage)
-   [Docs](/docs)
-   [Enterprise](/enterprise)
-   [Pricing](/pricing)
-   -   Website
        
        -   [Tasks](/tasks)
        -   [HuggingChat](/chat)
        -   [Collections](/collections)
        -   [Languages](/languages)
        -   [Organizations](/organizations)
    -   Community
        
        -   [Blog](/blog)
        -   [Posts](/posts)
        -   [Daily Papers](/papers)
        -   [Hardware](/hardware)
        -   [Learn](/learn)
        -   [Discord](/join/discord)
        -   [Forum](https://discuss.huggingface.co/)
        -   [GitHub](https://github.com/huggingface)
    -   Solutions
        
        -   [Team & Enterprise](/enterprise)
        -   [Hugging Face PRO](/pro)
        -   [Enterprise Support](/support)
        -   [Inference Providers](/inference/models)
        -   [Inference Endpoints](/inference-endpoints)
        -   [Storage Buckets](/storage)
    
-   ---
    
-   [Log In](/login)
-   [Sign Up](/join)

# 

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

](/Qwen)

[Qwen](/Qwen)

/

[Qwen3-Coder-30B-A3B-Instruct](/Qwen/Qwen3-Coder-30B-A3B-Instruct)

like 1.22k

Follow

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg) Qwen 101k

[

Text Generation

](/models?pipeline_tag=text-generation)[

Transformers

](/models?library=transformers)[

Safetensors

](/models?library=safetensors)[

qwen3\_moe

](/models?other=qwen3_moe)[

conversational

](/models?other=conversational)

arxiv: 2505.09388

License: apache-2.0

[Model card](/Qwen/Qwen3-Coder-30B-A3B-Instruct) [Files Files and versions

xet

](/Qwen/Qwen3-Coder-30B-A3B-Instruct/tree/main)[Community

38

](/Qwen/Qwen3-Coder-30B-A3B-Instruct/discussions)

Deploy

Copy to bucket new

Use this model

### Instructions to use Qwen/Qwen3-Coder-30B-A3B-Instruct with libraries, inference providers, notebooks, and local apps. Follow these links to get started.

-   Libraries
-   [Transformers](/Qwen/Qwen3-Coder-30B-A3B-Instruct?library=transformers)
    
    How to use Qwen/Qwen3-Coder-30B-A3B-Instruct with Transformers:
    
    \# Use a pipeline as a high-level helper
    from transformers import pipeline
    
    pipe = pipeline("text-generation", model="Qwen/Qwen3-Coder-30B-A3B-Instruct")
    messages = \[
        {"role": "user", "content": "Who are you?"},
    \]
    pipe(messages)
    
    \# Load model directly
    from transformers import AutoTokenizer, AutoModelForCausalLM
    
    tokenizer = AutoTokenizer.from\_pretrained("Qwen/Qwen3-Coder-30B-A3B-Instruct")
    model = AutoModelForCausalLM.from\_pretrained("Qwen/Qwen3-Coder-30B-A3B-Instruct", device\_map="auto")
    messages = \[
        {"role": "user", "content": "Who are you?"},
    \]
    inputs = tokenizer.apply\_chat\_template(
    	messages,
    	add\_generation\_prompt=True,
    	tokenize=True,
    	return\_dict=True,
    	return\_tensors="pt",
    ).to(model.device)
    
    outputs = model.generate(\*\*inputs, max\_new\_tokens=40)
    print(tokenizer.decode(outputs\[0\]\[inputs\["input\_ids"\].shape\[-1\]:\]))
    
-   Inference
-   Inference Providers
-   [HuggingChat](/chat/models/Qwen/Qwen3-Coder-30B-A3B-Instruct)
-   Notebooks
-   [Google Colab](/Qwen/Qwen3-Coder-30B-A3B-Instruct/colab)
-   [Kaggle](/Qwen/Qwen3-Coder-30B-A3B-Instruct/kaggle)
-   Local Apps [Settings](/settings/local-apps "Set up your favorite local applications")
-   [vLLM](/Qwen/Qwen3-Coder-30B-A3B-Instruct?local-app=vllm)
    
    How to use Qwen/Qwen3-Coder-30B-A3B-Instruct with vLLM:
    
    ##### Install from pip and serve model
    
    \# Install vLLM from pip:
    pip install vllm
    # Start the vLLM server:
    vllm serve "Qwen/Qwen3-Coder-30B-A3B-Instruct"
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:8000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3-Coder-30B-A3B-Instruct",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
    			}
    		\]
    	}'
    
    ##### Use Docker
    
    docker model run hf.co/Qwen/Qwen3-Coder-30B-A3B-Instruct
    
-   [SGLang](/Qwen/Qwen3-Coder-30B-A3B-Instruct?local-app=sglang)
    
    How to use Qwen/Qwen3-Coder-30B-A3B-Instruct with SGLang:
    
    ##### Install from pip and serve model
    
    \# Install SGLang from pip:
    pip install sglang
    # Start the SGLang server:
    python3 -m sglang.launch\_server \\
        --model-path "Qwen/Qwen3-Coder-30B-A3B-Instruct" \\
        --host 0.0.0.0 \\
        --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3-Coder-30B-A3B-Instruct",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
    			}
    		\]
    	}'
    
    ##### Use Docker images
    
    docker run --gpus all \\
        --shm-size 32g \\
        -p 30000:30000 \\
        -v ~/.cache/huggingface:/root/.cache/huggingface \\
        --env "HF\_TOKEN=<secret>" \\
        --ipc=host \\
        lmsysorg/sglang:latest \\
        python3 -m sglang.launch\_server \\
            --model-path "Qwen/Qwen3-Coder-30B-A3B-Instruct" \\
            --host 0.0.0.0 \\
            --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3-Coder-30B-A3B-Instruct",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
    			}
    		\]
    	}'
    
-   [Docker Model Runner](/Qwen/Qwen3-Coder-30B-A3B-Instruct?local-app=docker-model-runner)
    
    How to use Qwen/Qwen3-Coder-30B-A3B-Instruct with Docker Model Runner:
    
    docker model run hf.co/Qwen/Qwen3-Coder-30B-A3B-Instruct
    
-   [Browse Quantizations](/models?other=base_model:quantized:Qwen/Qwen3-Coder-30B-A3B-Instruct) to use this model in llama.cpp, Ollama, LM Studio, or any compatible app.
    

-   [Qwen3-Coder-30B-A3B-Instruct](#qwen3-coder-30b-a3b-instruct "Qwen3-Coder-30B-A3B-Instruct")
    -   [Highlights](#highlights "Highlights")
        
    -   [Model Overview](#model-overview "Model Overview")
        
    -   [Quickstart](#quickstart "Quickstart")
        
    -   [Agentic Coding](#agentic-coding "Agentic Coding")
        
    -   [Best Practices](#best-practices "Best Practices")
        -   [Citation](#citation "Citation")

# [](#qwen3-coder-30b-a3b-instruct)Qwen3-Coder-30B-A3B-Instruct

[![Chat](https://img.shields.io/badge/%F0%9F%92%9C%EF%B8%8F%20Qwen%20Chat%20-536af5)](https://chat.qwen.ai/)

## [](#highlights)Highlights

**Qwen3-Coder** is available in multiple sizes. Today, we're excited to introduce **Qwen3-Coder-30B-A3B-Instruct**. This streamlined model maintains impressive performance and efficiency, featuring the following key enhancements:

-   **Significant Performance** among open models on **Agentic Coding**, **Agentic Browser-Use**, and other foundational coding tasks.
-   **Long-context Capabilities** with native support for **256K** tokens, extendable up to **1M** tokens using Yarn, optimized for repository-scale understanding.
-   **Agentic Coding** supporting for most platform such as **Qwen Code**, **CLINE**, featuring a specially designed function call format.

[![image/jpeg](https://qianwen-res.oss-cn-beijing.aliyuncs.com/Qwen3-Coder/qwen3-coder-30a3-main.jpg)](https://qianwen-res.oss-cn-beijing.aliyuncs.com/Qwen3-Coder/qwen3-coder-30a3-main.jpg)

## [](#model-overview)Model Overview

**Qwen3-Coder-30B-A3B-Instruct** has the following features:

-   Type: Causal Language Models
-   Training Stage: Pretraining & Post-training
-   Number of Parameters: 30.5B in total and 3.3B activated
-   Number of Layers: 48
-   Number of Attention Heads (GQA): 32 for Q and 4 for KV
-   Number of Experts: 128
-   Number of Activated Experts: 8
-   Context Length: **262,144 natively**.

**NOTE: This model supports only non-thinking mode and does not generate `<think></think>` blocks in its output. Meanwhile, specifying `enable_thinking=False` is no longer required.**

For more details, including benchmark evaluation, hardware requirements, and inference performance, please refer to our [blog](https://qwenlm.github.io/blog/qwen3-coder/), [GitHub](https://github.com/QwenLM/Qwen3-Coder), and [Documentation](https://qwen.readthedocs.io/en/latest/).

## [](#quickstart)Quickstart

We advise you to use the latest version of `transformers`.

With `transformers<4.51.0`, you will encounter the following error:

```
KeyError: 'qwen3_moe'
```

The following contains a code snippet illustrating how to use the model generate content based on given inputs.

```python
from transformers import AutoModelForCausalLM, AutoTokenizer

model_name = "Qwen/Qwen3-Coder-30B-A3B-Instruct"

# load the tokenizer and the model
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    torch_dtype="auto",
    device_map="auto"
)

# prepare the model input
prompt = "Write a quick sort algorithm."
messages = [
    {"role": "user", "content": prompt}
]
text = tokenizer.apply_chat_template(
    messages,
    tokenize=False,
    add_generation_prompt=True,
)
model_inputs = tokenizer([text], return_tensors="pt").to(model.device)

# conduct text completion
generated_ids = model.generate(
    **model_inputs,
    max_new_tokens=65536
)
output_ids = generated_ids[0][len(model_inputs.input_ids[0]):].tolist() 

content = tokenizer.decode(output_ids, skip_special_tokens=True)

print("content:", content)
```

**Note: If you encounter out-of-memory (OOM) issues, consider reducing the context length to a shorter value, such as `32,768`.**

For local use, applications such as Ollama, LMStudio, MLX-LM, llama.cpp, and KTransformers have also supported Qwen3.

## [](#agentic-coding)Agentic Coding

Qwen3-Coder excels in tool calling capabilities.

You can simply define or use any tools as following example.

```python
# Your tool implementation
def square_the_number(num: float) -> dict:
    return num ** 2

# Define Tools
tools=[
    {
        "type":"function",
        "function":{
            "name": "square_the_number",
            "description": "output the square of the number.",
            "parameters": {
                "type": "object",
                "required": ["input_num"],
                "properties": {
                    'input_num': {
                        'type': 'number', 
                        'description': 'input_num is a number that will be squared'
                        }
                },
            }
        }
    }
]

import OpenAI
# Define LLM
client = OpenAI(
    # Use a custom endpoint compatible with OpenAI API
    base_url='http://localhost:8000/v1',  # api_base
    api_key="EMPTY"
)
 
messages = [{'role': 'user', 'content': 'square the number 1024'}]

completion = client.chat.completions.create(
    messages=messages,
    model="Qwen3-Coder-30B-A3B-Instruct",
    max_tokens=65536,
    tools=tools,
)

print(completion.choice[0])
```

## [](#best-practices)Best Practices

To achieve optimal performance, we recommend the following settings:

1.  **Sampling Parameters**:
    
    -   We suggest using `temperature=0.7`, `top_p=0.8`, `top_k=20`, `repetition_penalty=1.05`.
2.  **Adequate Output Length**: We recommend using an output length of 65,536 tokens for most queries, which is adequate for instruct models.
    

### [](#citation)Citation

If you find our work helpful, feel free to give us a cite.

```
@misc{qwen3technicalreport,
      title={Qwen3 Technical Report}, 
      author={Qwen Team},
      year={2025},
      eprint={2505.09388},
      archivePrefix={arXiv},
      primaryClass={cs.CL},
      url={https://arxiv.org/abs/2505.09388}, 
}
```

Downloads last month

799,458

Safetensors[](https://huggingface.co/docs/safetensors)

Model size

31B params

Tensor type

BF16

·

Chat template

Files info

Inference Providers [NEW](https://huggingface.co/docs/inference-providers)

Featherless AI

[

Text Generation

](/tasks/text-generation "Learn more about text-generation")

Examples

Input a message to start chatting with **Qwen/Qwen3-Coder-30B-A3B-Instruct**.

Send

View Code Snippets

[Compare providers](/inference/models?model=Qwen%2FQwen3-Coder-30B-A3B-Instruct)

## Model tree for Qwen/Qwen3-Coder-30B-A3B-Instruct[](/docs/hub/model-cards#specifying-a-base-model)

Adapters

[53 models](/models?other=base_model:adapter:Qwen/Qwen3-Coder-30B-A3B-Instruct)

Finetunes

[84 models](/models?other=base_model:finetune:Qwen/Qwen3-Coder-30B-A3B-Instruct)

Merges

[6 models](/models?other=base_model:merge:Qwen/Qwen3-Coder-30B-A3B-Instruct)

Quantizations

[](/models?apps=llama.cpp&other=base_model:quantized:Qwen/Qwen3-Coder-30B-A3B-Instruct "Use with llama.cpp")[](/models?apps=lmstudio&other=base_model:quantized:Qwen/Qwen3-Coder-30B-A3B-Instruct "Use with LM Studio")[](/models?apps=jan&other=base_model:quantized:Qwen/Qwen3-Coder-30B-A3B-Instruct "Use with Jan")[](/models?apps=ollama&other=base_model:quantized:Qwen/Qwen3-Coder-30B-A3B-Instruct "Use with Ollama")

[164 models](/models?other=base_model:quantized:Qwen/Qwen3-Coder-30B-A3B-Instruct)

## Spaces using Qwen/Qwen3-Coder-30B-A3B-Instruct 100

[

🐳

enzostvs/deepsite

](/spaces/enzostvs/deepsite)[

♾️📚

infinite-dataset-hub/infinite-dataset-hub

](/spaces/infinite-dataset-hub/infinite-dataset-hub)[

🥹

bobber/Z-Image-to-LoRA

](/spaces/bobber/Z-Image-to-LoRA)[

🚀

nazdridoy/inferoxy-hub

](/spaces/nazdridoy/inferoxy-hub)[

🚀

build-small-hackathon/6ixPulse

](/spaces/build-small-hackathon/6ixPulse)[

👀

vidulpanickan/tinyehr-sql

](/spaces/vidulpanickan/tinyehr-sql)[

📊

AleeexUst/Qwen-Qwen3-Coder-30B-A3B-Instruct

](/spaces/AleeexUst/Qwen-Qwen3-Coder-30B-A3B-Instruct)[

😭

miguelaf4/Qwen-Image-to-LoRA

](/spaces/miguelaf4/Qwen-Image-to-LoRA)\+ 95 Spaces \+ 92 Spaces

## Collection including Qwen/Qwen3-Coder-30B-A3B-Instruct

[

#### Qwen3-Coder

Collection

5 items • Updated Dec 31, 2025 • 184

](/collections/Qwen/qwen3-coder)

## Paper for Qwen/Qwen3-Coder-30B-A3B-Instruct

[

#### Qwen3 Technical Report

Paper • 2505.09388 • Published May 14, 2025 • 344

](/papers/2505.09388)

System theme

Company

[TOS](/terms-of-service) [Privacy](/privacy) [About](/huggingface) [Careers](https://apply.workable.com/huggingface/)[](/)

Website

[Models](/models) [Datasets](/datasets) [Spaces](/spaces) [Pricing](/pricing) [Docs](/docs)
```

**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/Kwaipilot/KAT-Coder-V2.5-Dev"
}
```

**Output:**
```
                

  Kwaipilot/KAT-Coder-V2.5-Dev · Hugging Face   

 [![Hugging Face's logo](/front/assets/huggingface_logo-noborder.svg) Hugging Face](/)

-   [Models](/models)
-   [Datasets](/datasets)
-   [Spaces](/spaces)
-   [Buckets new](/storage)
-   [Docs](/docs)
-   [Enterprise](/enterprise)
-   [Pricing](/pricing)
-   -   Website
        
        -   [Tasks](/tasks)
        -   [HuggingChat](/chat)
        -   [Collections](/collections)
        -   [Languages](/languages)
        -   [Organizations](/organizations)
    -   Community
        
        -   [Blog](/blog)
        -   [Posts](/posts)
        -   [Daily Papers](/papers)
        -   [Hardware](/hardware)
        -   [Learn](/learn)
        -   [Discord](/join/discord)
        -   [Forum](https://discuss.huggingface.co/)
        -   [GitHub](https://github.com/huggingface)
    -   Solutions
        
        -   [Team & Enterprise](/enterprise)
        -   [Hugging Face PRO](/pro)
        -   [Enterprise Support](/support)
        -   [Inference Providers](/inference/models)
        -   [Inference Endpoints](/inference-endpoints)
        -   [Storage Buckets](/storage)
    
-   ---
    
-   [Log In](/login)
-   [Sign Up](/join)

# 

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6438cc09c04b3b996ea73196/izeqDmgIB27KPxPkisPSF.png)

](/Kwaipilot)

[Kwaipilot](/Kwaipilot)

/

[KAT-Coder-V2.5-Dev](/Kwaipilot/KAT-Coder-V2.5-Dev)

like 621

Follow

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6438cc09c04b3b996ea73196/izeqDmgIB27KPxPkisPSF.png) Kwaipilot 763

[

Text Generation

](/models?pipeline_tag=text-generation)[

Transformers

](/models?library=transformers)[

Safetensors

](/models?library=safetensors)[

English

](/models?language=en)[

Chinese

](/models?language=zh)[

qwen3\_5\_moe

](/models?other=qwen3_5_moe)[

image-text-to-text

](/models?other=image-text-to-text)[

code

](/models?other=code)[

agent

](/models?other=agent)[

agentic-coding

](/models?other=agentic-coding)[

Mixture of Experts

](/models?other=moe)[

coding

](/models?other=coding)[

conversational

](/models?other=conversational)

arxiv: 2607.05471

License: apache-2.0

[Model card](/Kwaipilot/KAT-Coder-V2.5-Dev) [Files Files and versions

xet

](/Kwaipilot/KAT-Coder-V2.5-Dev/tree/main)[Community

30

](/Kwaipilot/KAT-Coder-V2.5-Dev/discussions)

Deploy

Copy to bucket new

Use this model

### Instructions to use Kwaipilot/KAT-Coder-V2.5-Dev with libraries, inference providers, notebooks, and local apps. Follow these links to get started.

-   Libraries
-   [Transformers](/Kwaipilot/KAT-Coder-V2.5-Dev?library=transformers)
    
    How to use Kwaipilot/KAT-Coder-V2.5-Dev with Transformers:
    
    \# Use a pipeline as a high-level helper
    from transformers import pipeline
    
    pipe = pipeline("text-generation", model="Kwaipilot/KAT-Coder-V2.5-Dev")
    messages = \[
        {
            "role": "user",
            "content": \[
                {"type": "image", "url": "https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/p-blog/candy.JPG"},
                {"type": "text", "text": "What animal is on the candy?"}
            \]
        },
    \]
    pipe(text=messages)
    
    \# Load model directly
    from transformers import AutoProcessor, AutoModelForMultimodalLM
    
    processor = AutoProcessor.from\_pretrained("Kwaipilot/KAT-Coder-V2.5-Dev")
    model = AutoModelForMultimodalLM.from\_pretrained("Kwaipilot/KAT-Coder-V2.5-Dev", device\_map="auto")
    messages = \[
        {
            "role": "user",
            "content": \[
                {"type": "image", "url": "https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/p-blog/candy.JPG"},
                {"type": "text", "text": "What animal is on the candy?"}
            \]
        },
    \]
    inputs = processor.apply\_chat\_template(
    	messages,
    	add\_generation\_prompt=True,
    	tokenize=True,
    	return\_dict=True,
    	return\_tensors="pt",
    ).to(model.device)
    
    outputs = model.generate(\*\*inputs, max\_new\_tokens=40)
    print(processor.decode(outputs\[0\]\[inputs\["input\_ids"\].shape\[-1\]:\]))
    
-   Notebooks
-   [Google Colab](/Kwaipilot/KAT-Coder-V2.5-Dev/colab)
-   [Kaggle](/Kwaipilot/KAT-Coder-V2.5-Dev/kaggle)
-   Local Apps [Settings](/settings/local-apps "Set up your favorite local applications")
-   [vLLM](/Kwaipilot/KAT-Coder-V2.5-Dev?local-app=vllm)
    
    How to use Kwaipilot/KAT-Coder-V2.5-Dev with vLLM:
    
    ##### Install from pip and serve model
    
    \# Install vLLM from pip:
    pip install vllm
    # Start the vLLM server:
    vllm serve "Kwaipilot/KAT-Coder-V2.5-Dev"
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:8000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Kwaipilot/KAT-Coder-V2.5-Dev",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
    			}
    		\]
    	}'
    
    ##### Use Docker
    
    docker model run hf.co/Kwaipilot/KAT-Coder-V2.5-Dev
    
-   [SGLang](/Kwaipilot/KAT-Coder-V2.5-Dev?local-app=sglang)
    
    How to use Kwaipilot/KAT-Coder-V2.5-Dev with SGLang:
    
    ##### Install from pip and serve model
    
    \# Install SGLang from pip:
    pip install sglang
    # Start the SGLang server:
    python3 -m sglang.launch\_server \\
        --model-path "Kwaipilot/KAT-Coder-V2.5-Dev" \\
        --host 0.0.0.0 \\
        --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Kwaipilot/KAT-Coder-V2.5-Dev",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
    			}
    		\]
    	}'
    
    ##### Use Docker images
    
    docker run --gpus all \\
        --shm-size 32g \\
        -p 30000:30000 \\
        -v ~/.cache/huggingface:/root/.cache/huggingface \\
        --env "HF\_TOKEN=<secret>" \\
        --ipc=host \\
        lmsysorg/sglang:latest \\
        python3 -m sglang.launch\_server \\
            --model-path "Kwaipilot/KAT-Coder-V2.5-Dev" \\
            --host 0.0.0.0 \\
            --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Kwaipilot/KAT-Coder-V2.5-Dev",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
    			}
    		\]
    	}'
    
-   [Docker Model Runner](/Kwaipilot/KAT-Coder-V2.5-Dev?local-app=docker-model-runner)
    
    How to use Kwaipilot/KAT-Coder-V2.5-Dev with Docker Model Runner:
    
    docker model run hf.co/Kwaipilot/KAT-Coder-V2.5-Dev
    
-   [Browse Quantizations](/models?other=base_model:quantized:Kwaipilot/KAT-Coder-V2.5-Dev) to use this model in llama.cpp, Ollama, LM Studio, or any compatible app.
    

-   [KAT-Coder-V2.5-Dev Highlights](#kat-coder-v25-dev-highlights "KAT-Coder-V2.5-Dev Highlights")
    
-   [Benchmark performance](#benchmark-performance "Benchmark performance")
    
-   [Post-training](#post-training "Post-training")
    
-   [Quickstart](#quickstart "Quickstart")
    -   [Serving KAT-Coder-V2.5-Dev](#serving-kat-coder-v25-dev "Serving KAT-Coder-V2.5-Dev")
        -   [SGLang](#sglang "SGLang")
        -   [vLLM](#vllm "vLLM")
        -   [KTransformers](#ktransformers "KTransformers")
        -   [Hugging Face Transformers](#hugging-face-transformers "Hugging Face Transformers")
-   [Using KAT-Coder-V2.5-Dev via the Chat Completions API](#using-kat-coder-v25-dev-via-the-chat-completions-api "Using KAT-Coder-V2.5-Dev via the Chat Completions API")
    -   [Text-Only Input](#text-only-input "Text-Only Input")
        
-   [Instruct (or Non-Thinking) Mode](#instruct-or-non-thinking-mode "Instruct (or Non-Thinking) Mode")
    
-   [Preserve Thinking](#preserve-thinking "Preserve Thinking")
    
-   [Processing Ultra-Long Texts](#processing-ultra-long-texts "Processing Ultra-Long Texts")
    
-   [Citation](#citation "Citation")
    

![KAT-Coder logo](/Kwaipilot/KAT-Coder-V2.5-Dev/resolve/main/kat_logo_hd.png)

# KAT-Coder-V2.5-Dev

[![KAT-Coder Technical Report](https://img.shields.io/badge/Technical%20Report-1a4a25?style=for-the-badge&logo=arxiv&logoColor=white)](https://huggingface.co/papers/2607.05471)

This repository contains the model weights and configuration files for the post-trained **KAT-Coder-V2.5-Dev** in the Hugging Face Transformers format. The artifacts are compatible with Hugging Face Transformers, vLLM, SGLang, KTransformers, etc. **Note:** this open-weight release ships only the language-model weights and operates as a **text-only** model; the vision/multimodal components are not included and are unavailable.

Following the release of KAT-Coder-V2.5 in July, we are pleased to release the open-weight version **KAT-Coder-V2.5-Dev**, an MOE model with a total parameter count of 35B and 3B activated parameters, to strengthen communication with the community and showcase our research achievements.

## [](#kat-coder-v25-dev-highlights)KAT-Coder-V2.5-Dev Highlights

-   **Performance improvement.** Through SFT/RL training, KAT-Coder-V2.5-Dev achieves SOTA results in the field of Agentic Coding among models with similar parameter scales.
-   **Optimization of abnormal behaviors.** Through RL training, certain abnormal behaviors have been significantly optimized, such as: abnormal tool labels -9pp (9.34% -> 0.28%), single-turn continuous repetition -0.34pp (0.34% -> 0%).

## [](#benchmark-performance)Benchmark performance

[![KAT-Coder-V2.5-Dev benchmark performance](/Kwaipilot/KAT-Coder-V2.5-Dev/resolve/main/KAT-Coder-V2.5-Dev-Benchmarks.png)](https://huggingface.co/Kwaipilot/KAT-Coder-V2.5-Dev/resolve/main/KAT-Coder-V2.5-Dev-Benchmarks.png?download=true)

Benchmark

KAT-Coder-V2.5-Dev

Qwen3.5-27B

Qwen3.6-35BA3B

Gemma4-31B

Qwen3.5-35BA3B

Ornith-1.0-35B

Gemma4-26BA4B

Qwen3-Coder-30B

Coding Agent

SWE-bench Verified

**69.40**

68.60

64.40

60.60

58.60

55.80

35.80

31.80

SWE-bench Multilingual

**63.00**

57.67

57.00

49.33

47.67

51.67

27.33

20.67

SWE-bench Pro

**45.96**

42.13

40.63

32.97

38.03

34.47

9.58

19.84

Terminal-Bench 2.1

**41.02**  
32.60 / 49.44

34.84  
41.57 / 28.10

32.02  
34.83 / 29.20

32.59  
30.34 / 34.83

26.12  
26.44 / 25.80

35.98  
35.96 / 36.00

20.94  
27.27 / 14.60

13.50  
10.11 / 16.90

PinchBench

**93.43**

90.71

92.21

85.53

88.75

91.62

82.01

72.3

Scicode

**44.20**

25.58

37.53

33.19

27.73

30.34

30.84

18.27

KAT-Code-Bench

**46.21**

44.83

42.76

37.93

35.86

33.10

22.06

15.17

For **Terminal-Bench 2.1**, the bold number is the average across two agent harnesses; the small numbers below are the per-harness scores (Terminus-2 / Claude Code).

**1\. Evaluation method.** All metrics presented in the table are reproduced in-house: we download the public model checkpoints, deploy them via vLLM or SGLang, and evaluate under a unified standardized pipeline. No officially reported results of the respective models are directly adopted in this table. Each model is tested only once on each evaluation set; retests are conducted only if obvious errors are found.

**2\. Evaluation configuration.**

\* SWE-bench Verified / Multilingual / Pro, KAT-Code-Bench: agent=claude\_code@2.1.195, pass@k=1, temperature=1.0, top\_p=0.95, 256k ctx.

\* Terminal-Bench 2.1: agent=terminus-2 / claude\_code, pass@k=1, temperature=0.7, top\_p=1.0, 256k ctx.

\* PinchBench: agent=openclaw@2026.3.13, pass@k=1, temperature=0.7, top\_p=1.0, 256k ctx.

\* Scicode: pass@k=1, temperature=0.6, top\_p=1.0, 256k ctx.

**3\. Anomaly description.**

\* Qwen3.6-35BA3B: We found that on the SWE-bench Verified, SWE-bench Multilingual, and SWE-bench Pro test sets, our test results this time have an approximate 10 pp gap compared with the official results. We believe this is mainly caused by the harness version and some optimizations made to the test sets by the Qwen team, and it should not be an issue with the model itself.

\* Qwen3.5-35BA3B: We observed frequent hallucinations during evaluation, including attempts to invoke the unavailable MultiEdit tool under the current agent environment, which negatively impacts the final metric.

\* Gemma4-26B-A4B-it: Two main factors degrade evaluation performance: context overflow (exceeding the 256k context limit) and hallucinated calls to the unsupported MultiEdit tool in this evaluation setup.

The above deviations arise from mismatches between model tool preference and the allowed toolset in the evaluation harness, rather than inherent capability limitations of the models.

## [](#post-training)Post-training

To provide a systematic overview of our team's work on data and algorithms, we adopt the widely recognized Qwen3.6-35B-A3B as the base model for post-training and build KAT-Coder-V2.5-Dev on top of it. Overall, KAT-Coder-V2.5-Dev largely follows the post-training recipe of KAT-V2.5, with most settings—including data construction, training pipeline, and optimization strategy—remaining unchanged. The full pipeline consists of two stages: supervised fine-tuning (SFT) and reinforcement learning (RL). We first fine-tune Qwen3.6-35B-A3B on a dataset of 127K examples and then perform RL training on the resulting SFT model.

During the RL stage, we retain the training infrastructure and key technical designs validated in KAT-V2.5, including the following four components:

1.  **Token-in-Token-out (TITO) consistency.** We use TITO to ensure that the token sequences in the rollout and training stages are strictly identical, preventing training discrepancies caused by differences in chat templates, serialization, or tokenizer behavior.
2.  **Truncated Importance Sampling (TIS).** To mitigate policy staleness and off-policy issues introduced by asynchronous rollouts, we apply TIS to truncate importance-sampling weights, reducing the variance and instability caused by excessively large weights.
3.  **Reliable sandboxes and verifiers.** We systematically inspect and validate the stability and correctness of the sandboxes and verifiers. This helps prevent infrastructure failures—such as execution timeouts, environment errors, or verifier misjudgments—from being incorrectly treated as model failures and contaminating the reward signal.
4.  **Hierarchical rewards based on harness execution feedback.** We construct hierarchical rewards from fine-grained execution feedback provided by the harness. This allows the model to optimize toward the final task objective while also receiving credit for meaningful progress in unsuccessful trajectories, thereby increasing the training value of failed attempts and providing denser reward signals.

However, Qwen3.6 exhibits trajectory patterns that differ from those observed in KAT-V2.5, requiring additional reward adaptations tailored to its behavior. In our initial experiments, a simple binary 0–1 reward caused model collapse as early as the second epoch. An analysis of the training trajectories revealed that, as training progressed, the model increasingly tended to issue a large number of parallel tool calls within a single turn—occasionally exceeding 70 calls. This behavior caused the context length to grow rapidly, generated a substantial number of invalid trajectories and execution errors, and ultimately destabilized RL training.

To address this issue, we augmented the original hierarchical reward with several Qwen3.6-specific penalties targeting (including but not limited to the following):

-   Excessive parallel tool calls within a single turn;
-   Failed tool calls;
-   Empty tool-call blocks; and
-   Large amounts of repeated content.

These targeted reward adjustments effectively suppressed pathological tool-use and repetitive-generation behaviors, enabling stable RL training for 10 epochs. Our experiments validate the effectiveness and feasibility of both the overall training pipeline and the Qwen3.6-specific reward design.

[![RL training reward curve](/Kwaipilot/KAT-Coder-V2.5-Dev/resolve/main/KAT-Coder-V2.5-Dev-RL-Reward-Curve.png)](https://huggingface.co/Kwaipilot/KAT-Coder-V2.5-Dev/resolve/main/KAT-Coder-V2.5-Dev-RL-Reward-Curve.png?download=true)

*The proportion of samples that pass the unit test (1 for pass, 0 for fail) within a batch of samples during RL training.*

## [](#quickstart)Quickstart

For streamlined integration, we recommend using KAT-Coder-V2.5-Dev via APIs. Below is a guide to use KAT-Coder-V2.5-Dev via OpenAI-compatible API.

### [](#serving-kat-coder-v25-dev)Serving KAT-Coder-V2.5-Dev

KAT-Coder-V2.5-Dev can be served via APIs with popular inference frameworks. In the following, we show example commands to launch OpenAI-Compatible API servers for KAT-Coder-V2.5-Dev model.

#### [](#sglang)SGLang

SGLang is a fast serving framework for large language models and vision language models. sglang>=0.5.10 is recommended for KAT-Coder-V2.5-Dev, which can be installed using the following command in a fresh environment:

```shell
uv pip install sglang[all]
```

The following will create API endpoints at `http://localhost:8000/v1`:

> **Note:** This open-weight release ships only the language-model weights (no vision tower). If your SGLang version attempts to build the multimodal/vision components at load time, startup may fail on missing vision weights; in that case, run with the version's text/language-model-only option (see `python -m sglang.launch_server --help`).

-   Standard Version: The following command can be used to create an API endpoint with maximum context length 262,144 tokens using tensor parallel on 8 GPUs.
    
    ```shell
    python -m sglang.launch_server \
        --model-path Kwaipilot/KAT-Coder-V2.5-Dev \
        --port 8000 \
        --tp-size 8 \
        --mem-fraction-static 0.8 \
        --context-length 262144 \
        --reasoning-parser qwen3
    ```
    
-   Tool Use: To support tool use, you can use the following command.
    
    ```shell
    python -m sglang.launch_server \
        --model-path Kwaipilot/KAT-Coder-V2.5-Dev \
        --port 8000 \
        --tp-size 8 \
        --mem-fraction-static 0.8 \
        --context-length 262144 \
        --reasoning-parser qwen3 \
        --tool-call-parser qwen3_coder
    ```
    

#### [](#vllm)vLLM

vLLM is a high-throughput and memory-efficient inference and serving engine for LLMs. vllm>=0.19.0 is recommended for KAT-Coder-V2.5-Dev, which can be installed using the following command in a fresh environment:

```shell
uv pip install vllm --torch-backend=auto
```

The following will create API endpoints at `http://localhost:8000/v1`:

> **Note:** This open-weight release ships only the language-model weights, so the `--language-model-only` flag is **required**. It tells vLLM to skip the vision encoder and multimodal profiling; without it, vLLM attempts to initialize vision-tower weights that are not present in the checkpoint and startup fails.

-   Standard Version: The following command can be used to create an API endpoint with maximum context length 262,144 tokens using tensor parallel on 8 GPUs.
    
    ```shell
    vllm serve Kwaipilot/KAT-Coder-V2.5-Dev \
        --port 8000 \
        --tensor-parallel-size 8 \
        --max-model-len 262144 \
        --reasoning-parser qwen3 \
        --language-model-only
    ```
    
-   Tool Call: To support tool use, you can use the following command.
    
    ```shell
    vllm serve Kwaipilot/KAT-Coder-V2.5-Dev \
        --port 8000 \
        --tensor-parallel-size 8 \
        --max-model-len 262144 \
        --reasoning-parser qwen3 \
        --enable-auto-tool-choice \
        --tool-call-parser qwen3_coder \
        --language-model-only
    ```
    

#### [](#ktransformers)KTransformers

KTransformers is a flexible framework for experiencing cutting-edge LLM inference optimizations with CPU-GPU heterogeneous computing. For running KAT-Coder-V2.5-Dev with KTransformers, see the KTransformers Deployment Guide.

#### [](#hugging-face-transformers)Hugging Face Transformers

Hugging Face Transformers contains a lightweight server which can be used for quick testing and moderate load deployment. The latest transformers is required for KAT-Coder-V2.5-Dev. Installing `accelerate` is also required for multi-GPU (sharded) loading:

```shell
pip install "transformers[serving]" accelerate
```

Then, run transformers serve to launch a server with API endpoints at `http://localhost:8000/v1`; it will place the model on accelerators if available:

```shell
transformers serve Kwaipilot/KAT-Coder-V2.5-Dev --port 8000
```

## [](#using-kat-coder-v25-dev-via-the-chat-completions-api)Using KAT-Coder-V2.5-Dev via the Chat Completions API

The chat completions API is accessible via standard HTTP requests or OpenAI SDKs. Here, we show examples using the OpenAI Python SDK.

Before starting, make sure it is installed and the API key and the API base URL is configured, e.g.:

```shell
pip install -U openai

# Set the following accordingly
export OPENAI_BASE_URL="http://localhost:8000/v1"
export OPENAI_API_KEY="EMPTY"
```

### [](#text-only-input)Text-Only Input

```python
from openai import OpenAI
# Configured by environment variables
client = OpenAI()

messages = [
    {"role": "user", "content": "Type \"I love KAT-Coder-V2.5-Dev\" backwards"},
]

chat_response = client.chat.completions.create(
    model="Kwaipilot/KAT-Coder-V2.5-Dev",
    messages=messages,
    max_tokens=81920,
    temperature=1.0,
    top_p=0.95,
    presence_penalty=1.5,
    extra_body={
        "top_k": 20,
    },
)
print("Chat response:", chat_response)
```

## [](#instruct-or-non-thinking-mode)Instruct (or Non-Thinking) Mode

KAT-Coder-V2.5-Dev will think by default before response. You can obtain direct response from the model without thinking by configuring the API parameters. For example,

```python
from openai import OpenAI
# Configured by environment variables
client = OpenAI()

messages = [
    {"role": "user", "content": "Write a Python function that returns the n-th Fibonacci number."},
]

chat_response = client.chat.completions.create(
    model="Kwaipilot/KAT-Coder-V2.5-Dev",
    messages=messages,
    max_tokens=32768,
    temperature=0.7,
    top_p=0.8,
    presence_penalty=1.5,
    extra_body={
        "top_k": 20,
        "chat_template_kwargs": {"enable_thinking": False},
    },
)
print("Chat response:", chat_response)
```

## [](#preserve-thinking)Preserve Thinking

By default, only the thinking blocks generated in handling the latest user message is retained, resulting in a pattern commonly as interleaved thinking. KAT-Coder-V2.5-Dev has been additionally trained to preserve and leverage thinking traces from historical messages. You can enable this behavior by setting the preserve\_thinking option:

```python
from openai import OpenAI
# Configured by environment variables
client = OpenAI()

messages = [...]

chat_response = client.chat.completions.create(
    model="Kwaipilot/KAT-Coder-V2.5-Dev",
    messages=messages,
    max_tokens=32768,
    temperature=0.7,
    top_p=0.8,
    presence_penalty=1.5,
    extra_body={
        "top_k": 20,
        "chat_template_kwargs": {"preserve_thinking": True},
    },
)
print("Chat response:", chat_response)
```

This capability is particularly beneficial for agent scenarios, where maintaining full reasoning context can enhance decision consistency and, in many cases, reduce overall token consumption by minimizing redundant reasoning. Additionally, it can improve KV cache utilization, optimizing inference efficiency in both thinking and non-thinking modes.

## [](#processing-ultra-long-texts)Processing Ultra-Long Texts

KAT-Coder-V2.5-Dev natively supports context lengths of up to 262,144 tokens. For long-horizon tasks where the total length (including both input and output) exceeds this limit, we recommend using RoPE scaling techniques to handle long texts effectively, e.g., YaRN.

YaRN is currently supported by several inference frameworks, e.g., transformers, vllm, ktransformers and sglang. In general, there are two approaches to enabling YaRN for supported frameworks:

-   Modifying the model configuration file: In the config.json file, change the rope\_parameters fields in text\_config to:
    
    ```json
    {
        "mrope_interleaved": true,
        "mrope_section": [
            11,
            11,
            10
        ],
        "rope_type": "yarn",
        "rope_theta": 10000000,
        "partial_rotary_factor": 0.25,
        "factor": 4.0,
        "original_max_position_embeddings": 262144
    }
    ```
    
-   Passing command line arguments:
    
    For vllm, you can use
    
    ```shell
    VLLM_ALLOW_LONG_MAX_MODEL_LEN=1 vllm serve ... --hf-overrides '{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 4.0, "original_max_position_embeddings": 262144}}}' --max-model-len 1010000
    ```
    
    For sglang and ktransformers, you can use
    
    ```shell
    SGLANG_ALLOW_OVERWRITE_LONGER_CONTEXT_LEN=1 python -m sglang.launch_server ... --json-model-override-args '{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 4.0, "original_max_position_embeddings": 262144}}}' --context-length 1010000
    ```
    

## [](#citation)Citation

If you find our work helpful, feel free to give us a cite.

```bibtex
@misc{katcoder_v25_2026,
  title={{KAT-Coder-V2.5 Technical Report}},
  author={{KwaiKAT Team}},
  year={2026},
  month={July},
  eprint={2607.05471},
  archivePrefix={arXiv},
  primaryClass={cs.AI},
  url={https://arxiv.org/pdf/2607.05471}
}
```

Downloads last month

50,148

Safetensors[](https://huggingface.co/docs/safetensors)

Model size

35B params

Tensor type

BF16

·

Chat template

Files info

Inference Providers [NEW](https://huggingface.co/docs/inference-providers)

[

Text Generation

](/tasks/text-generation "Learn more about text-generation")

This model isn't deployed by any Inference Provider. [🙋 5 Ask for provider support](/spaces/huggingface/InferenceSupport/discussions/11492)

## Model tree for Kwaipilot/KAT-Coder-V2.5-Dev[](/docs/hub/model-cards#specifying-a-base-model)

Finetunes

[8 models](/models?other=base_model:finetune:Kwaipilot/KAT-Coder-V2.5-Dev)

Quantizations

[](/models?apps=llama.cpp&other=base_model:quantized:Kwaipilot/KAT-Coder-V2.5-Dev "Use with llama.cpp")[](/models?apps=lmstudio&other=base_model:quantized:Kwaipilot/KAT-Coder-V2.5-Dev "Use with LM Studio")[](/models?apps=jan&other=base_model:quantized:Kwaipilot/KAT-Coder-V2.5-Dev "Use with Jan")[](/models?apps=ollama&other=base_model:quantized:Kwaipilot/KAT-Coder-V2.5-Dev "Use with Ollama")

[66 models](/models?other=base_model:quantized:Kwaipilot/KAT-Coder-V2.5-Dev)

## Spaces using Kwaipilot/KAT-Coder-V2.5-Dev 2

[

🤖

localellm/WebGPU-kat-coder-v2-5-dev-i1-gguf

](/spaces/localellm/WebGPU-kat-coder-v2-5-dev-i1-gguf)[

🤖

localellm/WebGPU-kat-coder-v2-5-dev-gguf

](/spaces/localellm/WebGPU-kat-coder-v2-5-dev-gguf)

## Collection including Kwaipilot/KAT-Coder-V2.5-Dev

[

#### KAT

Collection

Agentic Models for Software Engineering • 4 items • Updated Jul 24 • 22

](/collections/Kwaipilot/kat)

## Paper for Kwaipilot/KAT-Coder-V2.5-Dev

[

#### KAT-Coder-V2.5 Technical Report

Paper • 2607.05471 • Published Jul 6 • 12

](/papers/2607.05471)

System theme

Company

[TOS](/terms-of-service) [Privacy](/privacy) [About](/huggingface) [Careers](https://apply.workable.com/huggingface/)[](/)

Website

[Models](/models) [Datasets](/datasets) [Spaces](/spaces) [Pricing](/pricing) [Docs](/docs)
```

**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF"
}
```

**Output:**
```
                

  ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF · Hugging Face   

 [![Hugging Face's logo](/front/assets/huggingface_logo-noborder.svg) Hugging Face](/)

-   [Models](/models)
-   [Datasets](/datasets)
-   [Spaces](/spaces)
-   [Buckets new](/storage)
-   [Docs](/docs)
-   [Enterprise](/enterprise)
-   [Pricing](/pricing)
-   -   Website
        
        -   [Tasks](/tasks)
        -   [HuggingChat](/chat)
        -   [Collections](/collections)
        -   [Languages](/languages)
        -   [Organizations](/organizations)
    -   Community
        
        -   [Blog](/blog)
        -   [Posts](/posts)
        -   [Daily Papers](/papers)
        -   [Hardware](/hardware)
        -   [Learn](/learn)
        -   [Discord](/join/discord)
        -   [Forum](https://discuss.huggingface.co/)
        -   [GitHub](https://github.com/huggingface)
    -   Solutions
        
        -   [Team & Enterprise](/enterprise)
        -   [Hugging Face PRO](/pro)
        -   [Enterprise Support](/support)
        -   [Inference Providers](/inference/models)
        -   [Inference Endpoints](/inference-endpoints)
        -   [Storage Buckets](/storage)
    
-   ---
    
-   [Log In](/login)
-   [Sign Up](/join)

# 

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/65fb32f58a66679f92b73458/ozQW6W27tVCM-SRouzGJa.jpeg)

](/ManniX-ITA)

[ManniX-ITA](/ManniX-ITA)

/

[Qwen3.6-27B-A3B-Coder-MTP-GGUF](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF)

like 35

[

Text Generation

](/models?pipeline_tag=text-generation)[

Transformers

](/models?library=transformers)[

GGUF

](/models?library=gguf)[

Mixture of Experts

](/models?other=moe)[

code

](/models?other=code)[

expert-pruning

](/models?other=expert-pruning)[

qwen3.6

](/models?other=qwen3.6)[

imatrix

](/models?other=imatrix)[

conversational

](/models?other=conversational)

License: apache-2.0

[Model card](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF) [Files Files and versions

xet

](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF/tree/main)[Community](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF/discussions)

Deploy

Copy to bucket new

Use this model

### Instructions to use ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF with libraries, inference providers, notebooks, and local apps. Follow these links to get started.

-   Libraries
-   [Transformers](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF?library=transformers)
    
    How to use ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF with Transformers:
    
    \# Use a pipeline as a high-level helper
    from transformers import pipeline
    
    pipe = pipeline("text-generation", model="ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF")
    messages = \[
        {"role": "user", "content": "Who are you?"},
    \]
    pipe(messages)
    
    \# Load model directly
    from transformers import AutoModel
    model = AutoModel.from\_pretrained("ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF", device\_map="auto")
    
-   Notebooks
-   [Google Colab](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF/colab)
-   [Kaggle](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF/kaggle)
-   Local Apps [Settings](/settings/local-apps "Set up your favorite local applications")
-   [llama.cpp](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF?local-app=llama.cpp)
    
    How to use ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF with llama.cpp:
    
    ##### Install (macOS, Linux)
    
    curl -LsSf https://llama.app/install.sh | sh
    # Start a local OpenAI-compatible server with a web UI:
    llama serve -hf ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    # Run inference directly in the terminal:
    llama cli -hf ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    
    ##### Install from WinGet (Windows)
    
    winget install llama.cpp
    # Start a local OpenAI-compatible server with a web UI:
    llama serve -hf ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    # Run inference directly in the terminal:
    llama cli -hf ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    
    ##### Use pre-built binary
    
    \# Download pre-built binary from:
    # https://github.com/ggerganov/llama.cpp/releases
    # Start a local OpenAI-compatible server with a web UI:
    ./llama-server -hf ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    # Run inference directly in the terminal:
    ./llama-cli -hf ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    
    ##### Build from source code
    
    git clone https://github.com/ggerganov/llama.cpp.git
    cd llama.cpp
    cmake -B build
    cmake --build build -j --target llama-server llama-cli
    # Start a local OpenAI-compatible server with a web UI:
    ./build/bin/llama-server -hf ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    # Run inference directly in the terminal:
    ./build/bin/llama-cli -hf ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    
    ##### Use Docker
    
    docker model run hf.co/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    
-   [LM Studio](lmstudio://open_from_hf?model=ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF)
-   [Jan](jan://models/huggingface/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF)
-   [vLLM](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF?local-app=vllm)
    
    How to use ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF with vLLM:
    
    ##### Install from pip and serve model
    
    \# Install vLLM from pip:
    pip install vllm
    # Start the vLLM server:
    vllm serve "ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF"
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:8000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
    			}
    		\]
    	}'
    
    ##### Use Docker
    
    docker model run hf.co/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    
-   [SGLang](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF?local-app=sglang)
    
    How to use ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF with SGLang:
    
    ##### Install from pip and serve model
    
    \# Install SGLang from pip:
    pip install sglang
    # Start the SGLang server:
    python3 -m sglang.launch\_server \\
        --model-path "ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF" \\
        --host 0.0.0.0 \\
        --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
    			}
    		\]
    	}'
    
    ##### Use Docker images
    
    docker run --gpus all \\
        --shm-size 32g \\
        -p 30000:30000 \\
        -v ~/.cache/huggingface:/root/.cache/huggingface \\
        --env "HF\_TOKEN=<secret>" \\
        --ipc=host \\
        lmsysorg/sglang:latest \\
        python3 -m sglang.launch\_server \\
            --model-path "ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF" \\
            --host 0.0.0.0 \\
            --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF",
    		"messages": \[
    			{
    				"role": "user",
    				"content": "What is the capital of France?"
    			}
    		\]
    	}'
    
-   [Ollama](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF?local-app=ollama)
    
    How to use ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF with Ollama:
    
    ollama run hf.co/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    
-   [Unsloth Studio](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF?local-app=unsloth)
    
    How to use ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF with Unsloth Studio:
    
    ##### Install Unsloth Studio (macOS, Linux, WSL)
    
    curl -fsSL https://unsloth.ai/install.sh | sh
    # Run unsloth studio
    unsloth studio -H 0.0.0.0 -p 8888
    # Then open http://localhost:8888 in your browser
    # Search for ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF to start chatting
    
    ##### Install Unsloth Studio (Windows)
    
    irm https://unsloth.ai/install.ps1 | iex
    # Run unsloth studio
    unsloth studio -H 0.0.0.0 -p 8888
    # Then open http://localhost:8888 in your browser
    # Search for ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF to start chatting
    
    ##### Using HuggingFace Spaces for Unsloth
    
    \# No setup required
    # Open https://huggingface.co/spaces/unsloth/studio in your browser
    # Search for ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF to start chatting
    
-   [Pi](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF?local-app=pi)
    
    How to use ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF with Pi:
    
    ##### Start the llama.cpp server
    
    \# Install llama.cpp:
    brew install llama.cpp
    # Start a local OpenAI-compatible server:
    llama serve -hf ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    
    ##### Configure the model in Pi
    
    \# Install Pi:
    npm install -g @earendil-works/pi-coding-agent
    # Add to ~/.pi/agent/models.json:
    {
      "providers": {
        "llama-cpp": {
          "baseUrl": "http://localhost:8080/v1",
          "api": "openai-completions",
          "apiKey": "none",
          "models": \[
            {
              "id": "ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M"
            }
          \]
        }
      }
    }
    
    ##### Run Pi
    
    \# Start Pi in your project directory:
    pi
    
-   [Docker Model Runner](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF?local-app=docker-model-runner)
    
    How to use ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF with Docker Model Runner:
    
    docker model run hf.co/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    
-   [Lemonade](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF?local-app=lemonade)
    
    How to use ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF with Lemonade:
    
    ##### Pull the model
    
    \# Download Lemonade from https://lemonade-server.ai/
    lemonade pull ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    
    ##### Run and chat with the model
    
    lemonade run user.Qwen3.6-27B-A3B-Coder-MTP-GGUF-Q4\_K\_M
    
    ##### List all available models
    
    lemonade list
    
-   [Hermes Agent](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF?local-app=hermes-agent)
    
    How to use ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF with Hermes Agent:
    
    ##### Start the llama.cpp server
    
    \# Install llama.cpp:
    brew install llama.cpp
    # Start a local OpenAI-compatible server:
    llama serve -hf ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    
    ##### Configure Hermes
    
    \# Install Hermes:
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
    hermes setup
    # Point Hermes at the local server:
    hermes config set model.provider custom
    hermes config set model.base\_url http://127.0.0.1:8080/v1
    hermes config set model.default ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    
    ##### Run Hermes
    
    hermes
    
-   [Atomic Chat](atomic-chat://models/huggingface/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF)
-   [OpenClaw](/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF?local-app=openclaw)
    
    How to use ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF with OpenClaw:
    
    ##### Start the llama.cpp server
    
    \# Install llama.cpp:
    brew install llama.cpp
    # Start a local OpenAI-compatible server:
    llama serve -hf ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M
    
    ##### Configure OpenClaw
    
    \# Install OpenClaw:
    npm install -g openclaw@latest
    # Register the local server and set it as the default model:
    openclaw onboard --non-interactive --mode local \\
      --auth-choice custom-api-key \\
      --custom-base-url http://127.0.0.1:8080/v1 \\
      --custom-model-id "ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF:Q4\_K\_M" \\
      --custom-provider-id llama-cpp \\
      --custom-compatibility openai \\
      --custom-text-input \\
      --accept-risk \\
      --skip-health
    
    ##### Run OpenClaw
    
    openclaw agent --local --agent main --message "Hello from Hugging Face"
    

-   [Qwen3.6-27B-A3B-Coder](#qwen36-27b-a3b-coder "Qwen3.6-27B-A3B-Coder")
    -   [Recipe](#recipe "Recipe")
        
    -   [Evaluation (Q6\_K, llama.cpp, temp 0.6 / top-p 0.95 / top-k 20)](#evaluation-q6_k-llamacpp-temp-06--top-p-095--top-k-20 "Evaluation (Q6_K, llama.cpp, temp 0.6 / top-p 0.95 / top-k 20)")
        
    -   [Verbosity / rumination (length breakdown per eval)](#verbosity--rumination-length-breakdown-per-eval "Verbosity / rumination (length breakdown per eval)")
        
    -   [Reasoning budget and thinking stop phrase (llama.cpp)](#reasoning-budget-and-thinking-stop-phrase-llamacpp "Reasoning budget and thinking stop phrase (llama.cpp)")
        -   [Serve with a bounded thinking block](#serve-with-a-bounded-thinking-block "Serve with a bounded thinking block")
        -   [Two wordings that work](#two-wordings-that-work "Two wordings that work")
        -   [What it measures out to](#what-it-measures-out-to "What it measures out to")
        -   [Per request, instead of per server](#per-request-instead-of-per-server "Per request, instead of per server")
        -   [Rules of thumb](#rules-of-thumb "Rules of thumb")
    -   [Formats](#formats "Formats")
        -   [Quantization quality](#quantization-quality "Quantization quality")
        -   [⚠️ Hardware note — low i-quants (IQ2\_M, IQ3\_M) on Blackwell (sm\_120) GPUs](#⚠️-hardware-note--low-i-quants-iq2m-iq3_m-on-blackwell-sm120-gpus "⚠️ Hardware note — low i-quants (IQ2_M, IQ3_M) on Blackwell (sm_120) GPUs")
    -   [Notes](#notes "Notes")
        

# [](#qwen36-27b-a3b-coder)Qwen3.6-27B-A3B-Coder

A **code-specialist expert prune** of [Qwen3.6-35B-A3B](https://huggingface.co/Qwen/Qwen3.6-35B-A3B): the MoE is reduced from **256 experts to 184** (72 dropped per layer, ~35B→27B, still A3B active) using a **code-targeted competence map** (LiveCodeBench + MultiPL-E competence classes). Same router, attention, norms, MTP head and vision tower as the base — only the expert keep-set changes.

**Served at top-10** (`num_experts_per_tok = 10`, baked as the default). This is a routing-recovery lever: after pruning to 184 experts, activating the top-10 (vs the base top-8) recovers instruction-following at **no cost to code** (see below). No fine-tuning, no distillation — pure expert selection + a routing-width dial.

## [](#recipe)Recipe

1.  **Competence map**: the 256e teacher is profiled per-expert on a balanced corpus + targeted **LiveCodeBench** and **MultiPL-E** (Rust/Java/JS) PASS-response classes.
2.  **Drop map**: `wmax` aggregation with the LCB + MPE classes up-weighted (1.5) → 72/256 experts dropped per layer, protecting the code-competent experts.
3.  **Top-10 routing** (`num_experts_per_tok = 10`) baked into the config → the shipped default. Pass `--override-kv qwen35moe.expert_used_count=int:8` to any llama.cpp tool to A/B back to native top-8.

## [](#evaluation-q6_k-llamacpp-temp-06--top-p-095--top-k-20)Evaluation (Q6\_K, llama.cpp, temp 0.6 / top-p 0.95 / top-k 20)

Benchmark

**This model**

Qwen3.6-35B-A3B (256e)

coder (LCB-only)

GPQA-Diamond

0.773

0.833

0.793

MATH-500

0.620

0.730

0.620

AIME

0.733

0.633

0.767

LiveCodeBench (v6, 77q)

0.688

0.714

0.688

IFEval

0.730

0.960

0.840

HumanEval

0.970

0.970

0.963

GSM8K

0.970

0.960

0.980

ARC-Challenge

0.944

0.935

0.933

**MultiPL-E**

**0.840**

0.827

0.670

**Average**

**0.808**

0.840

0.806

**Highlights:** best code profile of any prune — **MultiPL-E 0.840** (above the teacher; +17pp over the LCB-only coder that this model supersedes), LiveCodeBench 0.688 (tied best), HumanEval 0.970. Average 0.808 sits at the LCB-coder level and within 0.03 of the full teacher.

## [](#verbosity--rumination-length-breakdown-per-eval)Verbosity / rumination (length breakdown per eval)

Aggressive expert pruning makes the model **verbose on open-ended reasoning** — it over-thinks before answering. This is largely **inherited from the base** (the 256e teacher does the same on GPQA/AIME) and is bounded by the generation cap; it does **not** affect the code benches, which have a natural termination anchor.

Response length in characters (content + reasoning), this model vs the 256e teacher; **runaway** = responses > 20k chars (of 100, or 30/198 for GPQA, 30 for AIME):

Benchmark

p50

p90

max

runaway

256e runaway

GPQA

13.8k

58.8k

129k

58

58 (same)

AIME

52.9k

85.5k

96k

25

29

IFEval

12.1k

56.2k

81k

30

11

MATH-500

2.3k

14.5k

76k

9

12

GSM8K

2.5k

12.5k

108k

6

3

ARC

1.4k

2.3k

59k

7

0

HumanEval

0.8k

1.4k

24k

1

2

LiveCodeBench / MultiPL-E

— code path —

tight

tight

**Reading it:** GPQA/AIME verbosity is essentially the base model (58 vs 58, 25 vs 29). Only **IFEval** shows prune-added rumination (30 vs 11) — the trade for the code-targeted drop map. Code and math-with-boxing tasks terminate cleanly. If you want tighter output, a repetition/length penalty at serve time (or top-8 via the override above) reduces the tail.

## [](#reasoning-budget-and-thinking-stop-phrase-llamacpp)Reasoning budget and thinking stop phrase (llama.cpp)

Qwen 3.6 reasons at length by design, and on a hard prompt it can consume the whole context window before it answers. llama.cpp can bound the thinking block with a sampler, and — the part that actually matters — tell the model *why* the block is being closed.

Needs llama.cpp **b8508** or newer for the flags, **b10091** or newer for the per-request overrides.

### [](#serve-with-a-bounded-thinking-block)Serve with a bounded thinking block

```bash
llama-server -m Qwen3.6-27B-A3B-Coder-Q4_K_M.gguf -c 32768 -ngl 99 \
    --jinja \
    --reasoning-budget 8192 \
    --reasoning-budget-message $'\n\nConsidering the limited time by the user, I have to give the solution based on the thinking directly now.\n' \
    --temp 0.6 --top-k 20 --top-p 0.95
```

flag

meaning

`--reasoning-budget N`

`-1` unrestricted (default), `0` close the block immediately, `N > 0` cap it at N tokens

`--reasoning-budget-message`

text written into the block just before the closing tag is forced

`--jinja`

required — the delimiters come from the chat template (`<think>` … `</think>`). Without it llama.cpp has no tags to count and the budget silently does nothing

Both flags also read from the environment: `LLAMA_ARG_THINK_BUDGET` and `LLAMA_ARG_THINK_BUDGET_MESSAGE`.

`--reasoning-format` is **not** part of this. It only decides how the thinking is handed back — `message.reasoning_content` versus left inline in `message.content` — and never whether the budget is enforced: the delimiters the sampler counts are set by the chat template regardless, so the cap binds under `auto`, `deepseek` and `none` alike. The default `auto` already extracts reasoning and is behaviourally identical to `deepseek` (they differ only in name; the sole branch in the parser is `!= none`). Leave it at the default so the model's own tool-call and channel handling stays in play, and pin `deepseek` only when a harness needs the thinking kept out of `content`.

`--reasoning-budget` on its own forces the closing tag the moment the budget runs out, wherever the model happens to be. When that lands mid-thought the model frequently does not register that it was interrupted: it carries on reasoning, now inside the visible answer. The stop phrase is what prevents that — it gives the model a reason to be finishing.

### [](#two-wordings-that-work)Two wordings that work

```bash
# "qwen" — the string Qwen's own service uses, from their docs
--reasoning-budget-message $'\n\nConsidering the limited time by the user, I have to give the solution based on the thinking directly now.\n'

# "voice" — shorter, in the model's own reasoning voice
--reasoning-budget-message $'\n\nOK, I have enough to answer now.\n'
```

Wording is model-specific: Qwen note that the ability to act on such a message *"is not explicitly trained but emerges naturally"*, so it is worth trying both on your own workload. Leading and trailing newlines matter — they keep the phrase off whatever half-finished line the cut landed on.

### [](#what-it-measures-out-to)What it measures out to

Measured on the Qwen3.6-35B-A3B base this model is pruned from. Three hard questions, temperature 0.6, fixed seed, answer characters with wall time in brackets. Every run answered all three correctly, and thinking length is unchanged by the message in every row:

budget

no message

`qwen`

`voice`

2048

1907 (69 s)

1838 (42 s)

1615 (41 s)

4096

**18015 (170 s)**

2642 (78 s)

1441 (104 s)

8192

3642 (158 s)

1848 (129 s)

2023 (175 s)

The 4096 row is the failure this exists for: the cap lands mid-thought and the reasoning simply continues in the answer, ten times longer and 2.2x the wall time, for the same three correct answers. Both phrases remove it.

### [](#per-request-instead-of-per-server)Per request, instead of per server

The server accepts both as request fields, overriding the command line:

```json
{
  "messages": [ ... ],
  "thinking_budget_tokens": 8192,
  "reasoning_budget_message": "\n\nOK, I have enough to answer now.\n"
}
```

On the raw `/completion` endpoint the delimiters are not inferred, so they have to be supplied with the budget:

```json
{
  "prompt": "...",
  "reasoning_budget_tokens": 8192,
  "reasoning_budget_start_tag": "<think>",
  "reasoning_budget_end_tag": "</think>",
  "reasoning_budget_message": "\n\nOK, I have enough to answer now.\n"
}
```

On b10091 the message field must be **present** on `/completion` requests even when empty: llama.cpp builds the sequence it forces from `message + end_tag` inside that field's handler, so omitting it leaves the budget with nothing to force — the sampler logs as though the cap fired while the thinking block stays open.

### [](#rules-of-thumb)Rules of thumb

-   Keep `-c` several times larger than the budget. A budget equal to the context lets the thinking phase fill the window on its own.
-   A quarter of the context is a sensible starting point: 8192 at `-c 32768`.
-   Qwen recommend keeping a thinking budget **above 1024** tokens; below that the cap tends to land before the model has committed to an approach.
-   The budget is **per thinking block**, not per response — the sampler re-arms when it sees a new opening tag, so a multi-turn agent gets a fresh window each time.

## [](#formats)Formats

-   **GGUF** (this repo family): full imatrix quant sweep (Q8\_0 → IQ2, plus ContribDynamic **CD-**\* per-layer quants) in [`Qwen3.6-27B-A3B-Coder-MTP-GGUF`](https://huggingface.co/ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF). Includes the **native MTP head** (speculative decoding) and a **`-vision` mmproj** for multimodal use. imatrix.dat archived in-repo.
-   **Ollama**: [`mannix/qwen3.6-27b-a3b-coder`](https://ollama.com/mannix/qwen3.6-27b-a3b-coder) (text) and `…-vision` tags (with mmproj).

### [](#quantization-quality)Quantization quality

Every K-quant (Q4\_K\_S → Q6\_K and the `_L` variants) is built **with imatrix**. On this model the imatrix is **load-bearing at 4-bit** — the opposite of Gemma-4, where imatrix degrades K-quants. Measured on a deterministic greedy MultiPL-E code probe, the entire imatrix K-family and the ContribDynamic **CD-\*** tiers sit at **full-precision parity** (within measurement noise of the F16 anchor). The only outlier was a *plain*, imatrix-free Q4\_K\_M, which fell ~12pp below parity — which is why imatrix is now the default for every tier in this repo.

-   **Recommended tier:** **CD-IQ4\_K\_M** (~16 GB) — full-precision-parity code quality at the smallest at-parity size.
-   **Q4\_0 / Q4\_1 are not shipped** — superseded by the imatrix K-quants (legacy round-to-nearest tiers offered no quality at their size).

### [](#⚠️-hardware-note--low-i-quants-iq2_m-iq3_m-on-blackwell-sm_120-gpus)⚠️ Hardware note — low i-quants (IQ2\_M, IQ3\_M) on Blackwell (sm\_120) GPUs

The low **i-quant** tiers **`IQ2_M`** and **`IQ3_M`** produce **incoherent output ("token salad") on NVIDIA Blackwell GPUs (sm\_120, e.g. RTX PRO 6000)** — under **both stock llama.cpp and opencoti-llamafile**, which share the same ggml CUDA `IQ2_S`/`IQ3_S` kernel. **The weights are fine:** the *identical* GGUF is fully coherent and produces correct code on **CPU** and on **Ampere/Ada GPUs** (verified on an RTX 3090). This is a llama.cpp/ggml **CUDA-kernel issue on the sm\_120 `IQ2_S`/`IQ3_S` path**, not a defect in these files.

-   **On a Blackwell GPU, instead use:** the K-quants (`Q2_K_L`, `Q3_K_S`/`Q3_K_M`/`Q3_K_L`), or `IQ2_XS` / `IQ4_XS` / the `CD-*` tiers — all coherent on Blackwell in the same size band (`Q2_K_L`/`IQ2_XS` ≈ the `IQ2_M` band; `Q3_K_M`/`Q3_K_L` ≈ the `IQ3_M` band).
-   `IQ2_M` / `IQ3_M` are kept in the repo because they are correct on **CPU and Ampere/Ada** GPUs.

## [](#notes)Notes

-   Top-10 is baked as the default; the model was selected and evaluated at top-10.
-   Same tokenizer, chat template, MTP head and vision tower as the base.
-   Research checkpoint. Verbosity on open-ended prompts is a known, base-inherited trait.

Downloads last month

97,623

GGUF[](https://huggingface.co/docs/hub/gguf)

Model size

26B params

Architecture

qwen35moe

Chat template

Hardware compatibility

[Log In](/login) to add your hardware

2-bit

IQ2\_XS

8.2 GB IQ2\_M

9.06 GB Q2\_K\_L

10.4 GB IQ2\_XS\_H

8.2 GB

3-bit

Q3\_K\_S

11.5 GB IQ3\_M

11.7 GB Q3\_K\_M

12.7 GB Q3\_K\_L

12.3 GB Q3\_K\_L

13.7 GB Q3\_K\_XL

13.2 GB

4-bit

IQ4\_XS

14.2 GB Q4\_K\_S

15.1 GB IQ4\_NL

15 GB Q4\_K\_M

16.7 GB Q4\_K\_M

14.7 GB Q4\_K\_M

16.1 GB

5-bit

Q5\_K\_S

18.2 GB Q5\_K\_M

17.8 GB Q5\_K\_M

18.7 GB

6-bit

Q6\_K

21.1 GB Q6\_K

21.6 GB Q6\_K\_L

21.8 GB

8-bit

Q8\_0

27.9 GB

16-bit

F16

52.5 GB

Inference Providers [NEW](https://huggingface.co/docs/inference-providers)

[

Text Generation

](/tasks/text-generation "Learn more about text-generation")

This model isn't deployed by any Inference Provider. [🙋 1 Ask for provider support](/spaces/huggingface/InferenceSupport/discussions/11740)

## Model tree for ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF[](/docs/hub/model-cards#specifying-a-base-model)

Base model

[Qwen/Qwen3.6-35B-A3B](/Qwen/Qwen3.6-35B-A3B)

Quantized

([772](/models?other=base_model:quantized:Qwen/Qwen3.6-35B-A3B))

this model

## Collection including ManniX-ITA/Qwen3.6-27B-A3B-Coder-MTP-GGUF

[

#### Qwen-3.6

Collection

9 items • Updated 6 days ago

](/collections/ManniX-ITA/qwen-36)

System theme

Company

[TOS](/terms-of-service) [Privacy](/privacy) [About](/huggingface) [Careers](https://apply.workable.com/huggingface/)[](/)

Website

[Models](/models) [Datasets](/datasets) [Spaces](/spaces) [Pricing](/pricing) [Docs](/docs)
```

---

## Assistant (Plan · Claude Sonnet 5 · 105.6s)

_Thinking:_



## HF search results: yes, there are real alternatives worth considering — but each has an unverified risk for *this specific hardware*

I searched huggingface.co directly (not relying on stale training data) and pulled model cards for the strongest coding-agent candidates trending right now. Here's the honest comparison, including what's *proven* vs. what's *plausible but unverified* for a DGX-Spark-class 120GB unified-memory box.

| Model | Total / Active params | License | Native ctx → extendable | Architecture | Fits 120GB? | Agentic coding (SWE-bench Verified) |
|---|---|---|---|---|---|---|
| **Qwen3.8-27B** (current pick) | 27B / **27B (dense)** | Apache-2.0 | 262K → 1M (YaRN, vendor-documented) | Hybrid Gated DeltaNet + Gated Attention | ✅ **Empirically proven** on this exact hardware class (this repo's `feat-3`) | not in KAT's comparison table |
| **Kwaipilot/KAT-Coder-V2.5-Dev** | 35B / **3B (MoE)** | Apache-2.0 | 256K → documented to ~1.01M via the *same* YaRN `rope_parameters` recipe as Qwen3.8-27B | Standard MoE (base: Qwen3.6-35B-A3B) | Likely (35B BF16 ≈ 70GB) — **not tested on unified memory** | **69.4** (best of the models it benchmarked against) |
| **Qwen/Qwen3-Coder-Next** | 80B / **3B (MoE)** | Apache-2.0 | 256K native — **no YaRN extension documented** in the model card | Hybrid Gated DeltaNet + MoE (best of both worlds architecturally) | Only with NVFP4 (80B BF16 ≈ 160GB, won't fit at all) | **70.6** (per its own reported eval) |
| **Qwen/Qwen3-Coder-30B-A3B-Instruct** | 30.5B / **3.3B (MoE)** | Apache-2.0 | 262K → 1M via YaRN (official, mature) | Standard GQA (32Q/4KV), **not** hybrid | Likely, but KV-cache/token is probably much larger than Qwen3.8-27B's hybrid design (unverified) | **35.8** (weakest of this group per KAT's table) |
| ManniX-ITA's Qwen3.6-27B-A3B-Coder-MTP (community prune) | 27B / 3B (MoE, GGUF) | Apache-2.0 | inherits base's YaRN | Pruned-expert MoE, ships MTP head | GGUF/llama.cpp path | 0.808 avg (own benchmark suite, not SWE-bench) |

### The one variable that matters most on this hardware, and nobody has proven it for the alternatives

DGX Spark's unified memory is **bandwidth-bound, not capacity-bound** — that's exactly why your current Qwen3.8-27B deployment needed NVFP4+MTP just to get from 4.4 → 31 tok/s (it's fully dense: every decode step reads all 27B params). A **3B-active MoE model should decode dramatically faster even at BF16**, because only ~3B params get read per token instead of 27B — potentially a bigger win than the entire NVFP4+MTP stack you had to build for Qwen3.8-27B.

But there's a real countervailing risk nobody in your repo has measured yet: **MoE models with standard (non-hybrid) attention pay full KV-cache cost every layer**. Qwen3.8-27B's hybrid Gated-DeltaNet design was specifically why it could reach 768K–1M context in ~30–37KB/token — most of its layers don't cache anything at all. Qwen3-Coder-30B-A3B-Instruct uses plain GQA across all layers, which could mean a *much* bigger KV cache per token, potentially eating the very headroom that made 768K+ feasible on a 120GB pool. KAT-Coder-V2.5-Dev and Qwen3-Coder-Next both use the hybrid layout too (same trick), so they're the more promising long-context candidates on paper — but:

- **Qwen3-Coder-Next**: best benchmark numbers, hybrid architecture, but its model card shows **no YaRN long-context path at all** (256K native, no extension documented) — if that's really absent, it fails your 768K requirement outright regardless of everything else.
- **KAT-Coder-V2.5-Dev**: best combination on paper (SOTA agentic benchmarks, MoE, hybrid-lineage base, explicit YaRN docs reusing the same rope_parameters shape, reasonable 35B footprint) — but nobody has verified vLLM/SGLang NVFP4 kernel support for SM121a with this specific architecture tag (`qwen3_5_moe`), nor whether an NVFP4 checkpoint even exists for it (unlike Qwen3.8-27B's `unsloth/Qwen3.8-27B-NVFP4`).

### Bottom line

Per your own repo's "measure, don't assume" precedent (`feat-3`'s entire methodology), I wouldn't swap away from Qwen3.8-27B on benchmark numbers alone — **KAT-Coder-V2.5-Dev is the most promising candidate to actually validate** (better agentic-coding scores, MoE speed advantage, same YaRN family), with Qwen3-Coder-30B-A3B-Instruct as a lower-risk fallback (official, mature tooling, but weaker benchmarks and a real question mark on its KV-cache footprint at long context).

Want me to draft a validation-feature plan (mirroring `feat-3`'s phased approach: architecture/kernel check → native-context smoke test → KV-cache/headroom measurement at 768K → throughput comparison against your existing Qwen3.8-27B numbers) for KAT-Coder-V2.5-Dev on your DGX Spark before you commit to switching?

---

## User

so, I always thought, that the 3B active parameters per expert should be much worse than the 27B dense model. Is that correct or incorrect?

---

## Assistant (Plan · Claude Sonnet 5 · 38.2s)

_Thinking:_



**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/blog/moe"
}
```

**Output:**
```
                

     Mixture of Experts Explained   

 [![Hugging Face's logo](/front/assets/huggingface_logo-noborder.svg) Hugging Face](/)

-   [Models](/models)
-   [Datasets](/datasets)
-   [Spaces](/spaces)
-   [Buckets new](/storage)
-   [Docs](/docs)
-   [Enterprise](/enterprise)
-   [Pricing](/pricing)
-   -   Website
        
        -   [Tasks](/tasks)
        -   [HuggingChat](/chat)
        -   [Collections](/collections)
        -   [Languages](/languages)
        -   [Organizations](/organizations)
    -   Community
        
        -   [Blog](/blog)
        -   [Posts](/posts)
        -   [Daily Papers](/papers)
        -   [Hardware](/hardware)
        -   [Learn](/learn)
        -   [Discord](/join/discord)
        -   [Forum](https://discuss.huggingface.co/)
        -   [GitHub](https://github.com/huggingface)
    -   Solutions
        
        -   [Team & Enterprise](/enterprise)
        -   [Hugging Face PRO](/pro)
        -   [Enterprise Support](/support)
        -   [Inference Providers](/inference/models)
        -   [Inference Endpoints](/inference-endpoints)
        -   [Storage Buckets](/storage)
    
-   ---
    
-   [Log In](/login)
-   [Sign Up](/join)

[Back to Articles](/blog)

# [](#mixture-of-experts-explained)Mixture of Experts Explained

Published December 11, 2023

[Update on GitHub](https://github.com/huggingface/blog/blob/main/moe.md)

 [Upvote

1178](/login?next=%2Fblog%2Fmoe)

-   [![](https://cdn-avatars.huggingface.co/v1/production/uploads/1583857146757-5e67bdd61009063689407479.jpeg)](/clem "clem")
-   [![](https://cdn-avatars.huggingface.co/v1/production/uploads/1585493970035-noauth.jpeg)](/maveriq "maveriq")
-   [![](https://cdn-avatars.huggingface.co/v1/production/uploads/5edf9030636bdb3834e2da08/At8kxNZmG7ZWuxx7P3dlM.png)](/erinkhoo "erinkhoo")
-   [![](https://cdn-avatars.huggingface.co/v1/production/uploads/1594311341799-5f07383b19cb630495b812cd.jpeg)](/stas "stas")
-   [![](https://cdn-avatars.huggingface.co/v1/production/uploads/1594651707950-noauth.jpeg)](/lewtun "lewtun")
-   [![](https://cdn-avatars.huggingface.co/v1/production/uploads/5f43448a79c1ba4c353d0d8f/DiSygV3dn7A_OjmGVTrHD.jpeg)](/sugatoray "sugatoray")
-   +1172

[![Omar Sanseviero's avatar](https://cdn-avatars.huggingface.co/v1/production/uploads/6032802e1f993496bc14d9e3/w6hr-DEQot4VVkoyRIBiy.png)](/osanseviero)

[Omar Sanseviero

osanseviero

Follow







](/osanseviero)

[![Lewis Tunstall's avatar](https://cdn-avatars.huggingface.co/v1/production/uploads/1594651707950-noauth.jpeg)](/lewtun)

[Lewis Tunstall

lewtun

Follow







](/lewtun)

[![Philipp Schmid's avatar](https://cdn-avatars.huggingface.co/v1/production/uploads/1624629516652-5ff5d596f244529b3ec0fb89.png)](/philschmid)

[Philipp Schmid

philschmid

Follow







](/philschmid)

[![Sourab Mangrulkar's avatar](https://cdn-avatars.huggingface.co/v1/production/uploads/1638132956881-5fca176d1d7a08cb34d79d5d.jpeg)](/smangrul)

[Sourab Mangrulkar

smangrul

Follow







](/smangrul)

[![Younes B's avatar](https://cdn-avatars.huggingface.co/v1/production/uploads/1648631057413-noauth.png)](/ybelkada)

[Younes B

ybelkada

Follow







](/ybelkada)

[![Pedro Cuenca's avatar](https://cdn-avatars.huggingface.co/v1/production/uploads/1617264212503-603d25b75f9d390ab190b777.jpeg)](/pcuenq)

[Pedro Cuenca

pcuenq

Follow







](/pcuenq)

> -   [Table of Contents](#table-of-contents "Table of Contents")
>     
> -   [TL;DR](#tldr "TL;DR")
>     
> -   [What is a Mixture of Experts (MoE)?](#what-is-a-mixture-of-experts-moe "What is a Mixture of Experts (MoE)?")
>     
> -   [A Brief History of MoEs](#a-brief-history-of-moes "A Brief History of MoEs")
>     
> -   [What is Sparsity?](#what-is-sparsity "What is Sparsity?")
>     
> -   [Load balancing tokens for MoEs](#load-balancing-tokens-for-moes "Load balancing tokens for MoEs")
>     
> -   [MoEs and Transformers](#moes-and-transformers "MoEs and Transformers")
>     
> -   [Switch Transformers](#switch-transformers "Switch Transformers")
>     
> -   [Stabilizing training with router Z-loss](#stabilizing-training-with-router-z-loss "Stabilizing training with router Z-loss")
>     
> -   [What does an expert learn?](#what-does-an-expert-learn "What does an expert learn?")
>     
> -   [How does scaling the number of experts impact pretraining?](#how-does-scaling-the-number-of-experts-impact-pretraining "How does scaling the number of experts impact pretraining?")
>     
> -   [Fine-tuning MoEs](#fine-tuning-moes "Fine-tuning MoEs")
>     
> -   [When to use sparse MoEs vs dense models?](#when-to-use-sparse-moes-vs-dense-models "When to use sparse MoEs vs dense models?")
>     
> -   [Making MoEs go brrr](#making-moes-go-brrr "Making MoEs go brrr")
>     -   [Parallelism](#parallelism "Parallelism")
>         
>     -   [Capacity Factor and communication costs](#capacity-factor-and-communication-costs "Capacity Factor and communication costs")
>         
>     -   [Serving techniques](#serving-techniques "Serving techniques")
>         
>     -   [More on efficient training](#more-on-efficient-training "More on efficient training")
>         
> -   [Open Source MoEs](#open-source-moes "Open Source MoEs")
>     
> -   [Exciting directions of work](#exciting-directions-of-work "Exciting directions of work")
>     
> -   [Some resources](#some-resources "Some resources")
>     
> -   [Citation](#citation "Citation")
>     
> 
> There is a second iteration (Feb 2026) of the blog post where we cover how the `transformers` library has built around MoEs to make them "first class citizens" of the library and the Hub. Here is the link to the post: [Mixture of Experts (MoEs) in Transformers](https://huggingface.co/blog/moe-transformers)

With the release of Mixtral 8x7B ([announcement](https://mistral.ai/news/mixtral-of-experts/), [model card](https://huggingface.co/mistralai/Mixtral-8x7B-v0.1)), a class of transformer has become the hottest topic in the open AI community: Mixture of Experts, or MoEs for short. In this blog post, we take a look at the building blocks of MoEs, how they’re trained, and the tradeoffs to consider when serving them for inference.

Let’s dive in!

## [](#table-of-contents)Table of Contents

-   [What is a Mixture of Experts?](#what-is-a-mixture-of-experts-moe)
-   [A Brief History of MoEs](#a-brief-history-of-moes)
-   [What is Sparsity?](#what-is-sparsity)
-   [Load Balancing tokens for MoEs](#load-balancing-tokens-for-moes)
-   [MoEs and Transformers](#moes-and-transformers)
-   [Switch Transformers](#switch-transformers)
-   [Stabilizing training with router Z-loss](#stabilizing-training-with-router-z-loss)
-   [What does an expert learn?](#what-does-an-expert-learn)
-   [How does scaling the number of experts impact pretraining?](#how-does-scaling-the-number-of-experts-impact-pretraining)
-   [Fine-tuning MoEs](#fine-tuning-moes)
-   [When to use sparse MoEs vs dense models?](#when-to-use-sparse-moes-vs-dense-models)
-   [Making MoEs go brrr](#making-moes-go-brrr)
    -   [Expert Parallelism](#parallelism)
    -   [Capacity Factor and Communication costs](#capacity-factor-and-communication-costs)
    -   [Serving Techniques](#serving-techniques)
    -   [Efficient Training](#more-on-efficient-training)
-   [Open Source MoEs](#open-source-moes)
-   [Exciting directions of work](#exciting-directions-of-work)
-   [Some resources](#some-resources)

## [](#tldr)TL;DR

MoEs:

-   Are **pretrained much faster** vs. dense models
-   Have **faster inference** compared to a model with the same number of parameters
-   Require **high VRAM** as all experts are loaded in memory
-   Face many **challenges in fine-tuning**, but [recent work](https://arxiv.org/pdf/2305.14705.pdf) with MoE **instruction-tuning is promising**

Let’s dive in!

## [](#what-is-a-mixture-of-experts-moe)What is a Mixture of Experts (MoE)?

The scale of a model is one of the most important axes for better model quality. Given a fixed computing budget, training a larger model for fewer steps is better than training a smaller model for more steps.

Mixture of Experts enable models to be pretrained with far less compute, which means you can dramatically scale up the model or dataset size with the same compute budget as a dense model. In particular, a MoE model should achieve the same quality as its dense counterpart much faster during pretraining.

So, what exactly is a MoE? In the context of transformer models, a MoE consists of two main elements:

-   **Sparse MoE layers** are used instead of dense feed-forward network (FFN) layers. MoE layers have a certain number of “experts” (e.g. 8), where each expert is a neural network. In practice, the experts are FFNs, but they can also be more complex networks or even a MoE itself, leading to hierarchical MoEs!
-   A **gate network or router**, that determines which tokens are sent to which expert. For example, in the image below, the token “More” is sent to the second expert, and the token "Parameters” is sent to the first network. As we’ll explore later, we can send a token to more than one expert. How to route a token to an expert is one of the big decisions when working with MoEs - the router is composed of learned parameters and is pretrained at the same time as the rest of the network.

![Switch Layer](https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/blog/moe/00_switch_transformer.png)

MoE layer from the \[Switch Transformers paper\](https://arxiv.org/abs/2101.03961)

So, to recap, in MoEs we replace every FFN layer of the transformer model with an MoE layer, which is composed of a gate network and a certain number of experts.

Although MoEs provide benefits like efficient pretraining and faster inference compared to dense models, they also come with challenges:

-   **Training:** MoEs enable significantly more compute-efficient pretraining, but they’ve historically struggled to generalize during fine-tuning, leading to overfitting.
-   **Inference:** Although a MoE might have many parameters, only some of them are used during inference. This leads to much faster inference compared to a dense model with the same number of parameters. However, all parameters need to be loaded in RAM, so memory requirements are high. For example, given a MoE like Mixtral 8x7B, we’ll need to have enough VRAM to hold a dense 47B parameter model. Why 47B parameters and not 8 x 7B = 56B? That’s because in MoE models, only the FFN layers are treated as individual experts, and the rest of the model parameters are shared. At the same time, assuming just two experts are being used per token, the inference speed (FLOPs) is like using a 12B model (as opposed to a 14B model), because it computes 2x7B matrix multiplications, but with some layers shared (more on this soon).

Now that we have a rough idea of what a MoE is, let’s take a look at the research developments that led to their invention.

## [](#a-brief-history-of-moes)A Brief History of MoEs

The roots of MoEs come from the 1991 paper [Adaptive Mixture of Local Experts](https://www.cs.toronto.edu/~hinton/absps/jjnh91.pdf). The idea, akin to ensemble methods, was to have a supervised procedure for a system composed of separate networks, each handling a different subset of the training cases. Each separate network, or expert, specializes in a different region of the input space. How is the expert chosen? A gating network determines the weights for each expert. During training, both the expert and the gating are trained.

Between 2010-2015, two different research areas contributed to later MoE advancement:

-   **Experts as components**: In the traditional MoE setup, the whole system comprises a gating network and multiple experts. MoEs as the whole model have been explored in SVMs, Gaussian Processes, and other methods. The work by [Eigen, Ranzato, and Ilya](https://arxiv.org/abs/1312.4314) explored MoEs as components of deeper networks. This allows having MoEs as layers in a multilayer network, making it possible for the model to be both large and efficient simultaneously.
-   **Conditional Computation**: Traditional networks process all input data through every layer. In this period, Yoshua Bengio researched approaches to dynamically activate or deactivate components based on the input token.

These works led to exploring a mixture of experts in the context of NLP. Concretely, [Shazeer et al.](https://arxiv.org/abs/1701.06538) (2017, with “et al.” including Geoffrey Hinton and Jeff Dean, [Google’s Chuck Norris](https://www.informatika.bg/jeffdean)) scaled this idea to a 137B LSTM (the de-facto NLP architecture back then, created by Schmidhuber) by introducing sparsity, allowing to keep very fast inference even at high scale. This work focused on translation but faced many challenges, such as high communication costs and training instabilities.

![MoE layer in LSTM](https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/blog/moe/01_moe_layer.png)

MoE layer from the Outrageously Large Neural Network paper

MoEs have allowed training multi-trillion parameter models, such as the open-sourced 1.6T parameters Switch Transformers, among others. MoEs have also been explored in Computer Vision, but this blog post will focus on the NLP domain.

## [](#what-is-sparsity)What is Sparsity?

Sparsity uses the idea of conditional computation. While in dense models all the parameters are used for all the inputs, sparsity allows us to only run some parts of the whole system.

Let’s dive deeper into Shazeer's exploration of MoEs for translation. The idea of conditional computation (parts of the network are active on a per-example basis) allows one to scale the size of the model without increasing the computation, and hence, this led to thousands of experts being used in each MoE layer.

This setup introduces some challenges. For example, although large batch sizes are usually better for performance, batch sizes in MOEs are effectively reduced as data flows through the active experts. For example, if our batched input consists of 10 tokens, **five tokens might end in one expert, and the other five tokens might end in five different experts, leading to uneven batch sizes and underutilization**. The [Making MoEs go brrr](#making-moes-go-brrr) section below will discuss other challenges and solutions.

How can we solve this? A learned gating network (G) decides which experts (E) to send a part of the input:

y\=∑i\=1nG(x)iEi(x) y = \\sum\_{i=1}^{n} G(x)\_i E\_i(x) y\=i\=1∑n​G(x)i​Ei​(x)

In this setup, all experts are run for all inputs - it’s a weighted multiplication. But, what happens if G is 0? If that’s the case, there’s no need to compute the respective expert operations and hence we save compute. What’s a typical gating function? In the most traditional setup, we just use a simple network with a softmax function. The network will learn which expert to send the input.

Gσ(x)\=Softmax(x⋅Wg) G\_\\sigma(x) = \\text{Softmax}(x \\cdot W\_g) Gσ​(x)\=Softmax(x⋅Wg​)

Shazeer’s work also explored other gating mechanisms, such as Noisy Top-k Gating. This gating approach introduces some (tunable) noise and then keeps the top k values. That is:

1.  We add some noise

H(x)i\=(x⋅Wg)i+StandardNormal()⋅Softplus((x⋅Wnoise)i) H(x)\_i = (x \\cdot W\_{\\text{g}})\_i + \\text{StandardNormal()} \\cdot \\text{Softplus}((x \\cdot W\_{\\text{noise}})\_i) H(x)i​\=(x⋅Wg​)i​+StandardNormal()⋅Softplus((x⋅Wnoise​)i​)

2.  We only pick the top k

KeepTopK(v,k)i\={viif vi is in the top k elements of v,−∞otherwise. \\text{KeepTopK}(v, k)\_i = \\begin{cases} v\_i & \\text{if } v\_i \\text{ is in the top } k \\text{ elements of } v, \\\\ -\\infty & \\text{otherwise.} \\end{cases} KeepTopK(v,k)i​\={vi​−∞​if vi​ is in the top k elements of v,otherwise.​

3.  We apply the softmax.

G(x)\=Softmax(KeepTopK(H(x),k)) G(x) = \\text{Softmax}(\\text{KeepTopK}(H(x), k)) G(x)\=Softmax(KeepTopK(H(x),k))

This sparsity introduces some interesting properties. By using a low enough k (e.g. one or two), we can train and run inference much faster than if many experts were activated. Why not just select the top expert? The initial conjecture was that routing to more than one expert was needed to have the gate learn how to route to different experts, so at least two experts had to be picked. The [Switch Transformers](#switch-transformers) section revisits this decision.

Why do we add noise? That’s for load balancing!

## [](#load-balancing-tokens-for-moes)Load balancing tokens for MoEs

As discussed before, if all our tokens are sent to just a few popular experts, that will make training inefficient. In a normal MoE training, the gating network converges to mostly activate the same few experts. This self-reinforces as favored experts are trained quicker and hence selected more. To mitigate this, an **auxiliary loss** is added to encourage giving all experts equal importance. This loss ensures that all experts receive a roughly equal number of training examples. The following sections will also explore the concept of expert capacity, which introduces a threshold of how many tokens can be processed by an expert. In `transformers`, the auxiliary loss is exposed via the `aux_loss` parameter.

## [](#moes-and-transformers)MoEs and Transformers

Transformers are a very clear case that scaling up the number of parameters improves the performance, so it’s not surprising that Google explored this with [GShard](https://arxiv.org/abs/2006.16668), which explores scaling up transformers beyond 600 billion parameters.

GShard replaces every other FFN layer with an MoE layer using top-2 gating in both the encoder and the decoder. The next image shows how this looks like for the encoder part. This setup is quite beneficial for large-scale computing: when we scale to multiple devices, the MoE layer is shared across devices while all the other layers are replicated. This is further discussed in the [“Making MoEs go brrr”](#making-moes-go-brrr) section.

![MoE Transformer Encoder](https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/blog/moe/02_moe_block.png)

MoE Transformer Encoder from the GShard Paper

To maintain a balanced load and efficiency at scale, the GShard authors introduced a couple of changes in addition to an auxiliary loss similar to the one discussed in the previous section:

-   **Random routing**: in a top-2 setup, we always pick the top expert, but the second expert is picked with probability proportional to its weight.
-   **Expert capacity**: we can set a threshold of how many tokens can be processed by one expert. If both experts are at capacity, the token is considered overflowed, and it’s sent to the next layer via residual connections (or dropped entirely in other projects). This concept will become one of the most important concepts for MoEs. Why is expert capacity needed? Since all tensor shapes are statically determined at compilation time, but we cannot know how many tokens will go to each expert ahead of time, we need to fix the capacity factor.

The GShard paper has contributions by expressing parallel computation patterns that work well for MoEs, but discussing that is outside the scope of this blog post.

**Note:** when we run inference, only some experts will be triggered. At the same time, there are shared computations, such as self-attention, which is applied for all tokens. That’s why when we talk of a 47B model of 8 experts, we can run with the compute of a 12B dense model. If we use top-2, 14B parameters would be used. But given that the attention operations are shared (among others), the actual number of used parameters is 12B.

## [](#switch-transformers)Switch Transformers

Although MoEs showed a lot of promise, they struggle with training and fine-tuning instabilities. [Switch Transformers](https://arxiv.org/abs/2101.03961) is a very exciting work that deep dives into these topics. The authors even released a [1.6 trillion parameters MoE on Hugging Face](https://huggingface.co/google/switch-c-2048) with 2048 experts, which you can run with transformers. Switch Transformers achieved a 4x pre-train speed-up over T5-XXL.

![Switch Transformer Layer](https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/blog/moe/03_switch_layer.png)

Switch Transformer Layer of the Switch Transformer paper

Just as in GShard, the authors replaced the FFN layers with a MoE layer. The Switch Transformers paper proposes a Switch Transformer layer that receives two inputs (two different tokens) and has four experts.

Contrary to the initial idea of using at least two experts, Switch Transformers uses a simplified single-expert strategy. The effects of this approach are:

-   The router computation is reduced
-   The batch size of each expert can be at least halved
-   Communication costs are reduced
-   Quality is preserved

Switch Transformers also explores the concept of expert capacity.

Expert Capacity\=(tokens per batchnumber of experts)×capacity factor \\text{Expert Capacity} = \\left(\\frac{\\text{tokens per batch}}{\\text{number of experts}}\\right) \\times \\text{capacity factor} Expert Capacity\=(number of expertstokens per batch​)×capacity factor

The capacity suggested above evenly divides the number of tokens in the batch across the number of experts. If we use a capacity factor greater than 1, we provide a buffer for when tokens are not perfectly balanced. Increasing the capacity will lead to more expensive inter-device communication, so it’s a trade-off to keep in mind. In particular, Switch Transformers perform well at low capacity factors (1-1.25)

Switch Transformer authors also revisit and simplify the load balancing loss mentioned in the sections. For each Switch layer, the auxiliary loss is added to the total model loss during training. This loss encourages uniform routing and can be weighted using a hyperparameter.

The authors also experiment with selective precision, such as training the experts with `bfloat16` while using full precision for the rest of the computations. Lower precision reduces communication costs between processors, computation costs, and memory for storing tensors. The initial experiments, in which both the experts and the gate networks were trained in `bfloat16`, yielded more unstable training. This was, in particular, due to the router computation: as the router has an exponentiation function, having higher precision is important. To mitigate the instabilities, full precision was used for the routing as well.

![Table shows that selective precision does not degrade quality.](https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/blog/moe/04_switch_table.png)

Using selective precision does not degrade quality and enables faster models

This [notebook](https://colab.research.google.com/drive/1aGGVHZmtKmcNBbAwa9hbu58DDpIuB5O4?usp=sharing) showcases fine-tuning Switch Transformers for summarization, but we suggest first reviewing the [fine-tuning section](#fine-tuning-moes).

Switch Transformers uses an encoder-decoder setup in which they did a MoE counterpart of T5. The [GLaM](https://arxiv.org/abs/2112.06905) paper explores pushing up the scale of these models by training a model matching GPT-3 quality using 1/3 of the energy (yes, thanks to the lower amount of computing needed to train a MoE, they can reduce the carbon footprint by up to an order of magnitude). The authors focused on decoder-only models and few-shot and one-shot evaluation rather than fine-tuning. They used Top-2 routing and much larger capacity factors. In addition, they explored the capacity factor as a metric one can change during training and evaluation depending on how much computing one wants to use.

## [](#stabilizing-training-with-router-z-loss)Stabilizing training with router Z-loss

The balancing loss previously discussed can lead to instability issues. We can use many methods to stabilize sparse models at the expense of quality. For example, introducing dropout improves stability but leads to loss of model quality. On the other hand, adding more multiplicative components improves quality but decreases stability.

Router z-loss, introduced in [ST-MoE](https://arxiv.org/abs/2202.08906), significantly improves training stability without quality degradation by penalizing large logits entering the gating network. Since this loss encourages absolute magnitude of values to be smaller, roundoff errors are reduced, which can be quite impactful for exponential functions such as the gating. We recommend reviewing the paper for details.

## [](#what-does-an-expert-learn)What does an expert learn?

The ST-MoE authors observed that encoder experts specialize in a group of tokens or shallow concepts. For example, we might end with a punctuation expert, a proper noun expert, etc. On the other hand, the decoder experts have less specialization. The authors also trained in a multilingual setup. Although one could imagine each expert specializing in a language, the opposite happens: due to token routing and load balancing, there is no single expert specialized in any given language.

![Experts specialize in some token groups](https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/blog/moe/05_experts_learning.png)

Table from the ST-MoE paper showing which token groups were sent to which expert.

## [](#how-does-scaling-the-number-of-experts-impact-pretraining)How does scaling the number of experts impact pretraining?

More experts lead to improved sample efficiency and faster speedup, but these are diminishing gains (especially after 256 or 512), and more VRAM will be needed for inference. The properties studied in Switch Transformers at large scale were consistent at small scale, even with 2, 4, or 8 experts per layer.

## [](#fine-tuning-moes)Fine-tuning MoEs

> Mixtral is supported with version 4.36.0 of transformers. You can install it with `pip install transformers==4.36.0 --upgrade`

The overfitting dynamics are very different between dense and sparse models. Sparse models are more prone to overfitting, so we can explore higher regularization (e.g. dropout) within the experts themselves (e.g. we can have one dropout rate for the dense layers and another, higher, dropout for the sparse layers).

One question is whether to use the auxiliary loss for fine-tuning. The ST-MoE authors experimented with turning off the auxiliary loss, and the quality was not significantly impacted, even when up to 11% of the tokens were dropped. Token dropping might be a form of regularization that helps prevent overfitting.

Switch Transformers observed that at a fixed pretrain perplexity, the sparse model does worse than the dense counterpart in downstream tasks, especially on reasoning-heavy tasks such as SuperGLUE. On the other hand, for knowledge-heavy tasks such as TriviaQA, the sparse model performs disproportionately well. The authors also observed that a fewer number of experts helped at fine-tuning. Another observation that confirmed the generalization issue is that the model did worse in smaller tasks but did well in larger tasks.

![Fine-tuning learning curves](https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/blog/moe/06_superglue_curves.png)

In the small task (left), we can see clear overfitting as the sparse model does much worse in the validation set. In the larger task (right), the MoE performs well. This image is from the ST-MoE paper.

One could experiment with freezing all non-expert weights. That is, we'll only update the MoE layers. This leads to a huge performance drop. We could try the opposite: freezing only the parameters in MoE layers, which worked almost as well as updating all parameters. This can help speed up and reduce memory for fine-tuning. This can be somewhat counter-intuitive as 80% of the parameters are in the MoE layers (in the ST-MoE project). Their hypothesis for that architecture is that, as expert layers only occur every 1/4 layers, and each token sees at most two experts per layer, updating the MoE parameters affects much fewer layers than updating other parameters.

![Only updating the non MoE layers works well in fine-tuning](https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/blog/moe/07_superglue_bars.png)

By only freezing the MoE layers, we can speed up the training while preserving the quality. This image is from the ST-MoE paper.

One last part to consider when fine-tuning sparse MoEs is that they have different fine-tuning hyperparameter setups - e.g., sparse models tend to benefit more from smaller batch sizes and higher learning rates.

![Table comparing fine-tuning batch size and learning rate between dense and sparse models.](https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/blog/moe/08_superglue_dense_vs_sparse.png)

Sparse models fine-tuned quality improves with higher learning rates and smaller batch sizes. This image is from the ST-MoE paper.

At this point, you might be a bit sad that people have struggled to fine-tune MoEs. Excitingly, a recent paper, [MoEs Meets Instruction Tuning](https://arxiv.org/pdf/2305.14705.pdf) (July 2023), performs experiments doing:

-   Single task fine-tuning
-   Multi-task instruction-tuning
-   Multi-task instruction-tuning followed by single-task fine-tuning

When the authors fine-tuned the MoE and the T5 equivalent, the T5 equivalent was better. When the authors fine-tuned the Flan T5 (T5 instruct equivalent) MoE, the MoE performed significantly better. Not only this, the improvement of the Flan-MoE over the MoE was larger than Flan T5 over T5, indicating that MoEs might benefit much more from instruction tuning than dense models. MoEs benefit more from a higher number of tasks. Unlike the previous discussion suggesting to turn off the auxiliary loss function, the loss actually prevents overfitting.

![MoEs benefit even more from instruct tuning than dense models](https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/blog/moe/09_fine_tune_evals.png)

Sparse models benefit more from instruct-tuning compared to dense models. This image is from the MoEs Meets Instruction Tuning paper

## [](#when-to-use-sparse-moes-vs-dense-models)When to use sparse MoEs vs dense models?

Experts are useful for high throughput scenarios with many machines. Given a fixed compute budget for pretraining, a sparse model will be more optimal. For low throughput scenarios with little VRAM, a dense model will be better.

**Note:** one cannot directly compare the number of parameters between sparse and dense models, as both represent significantly different things.

## [](#making-moes-go-brrr)Making MoEs go brrr

The initial MoE work presented MoE layers as a branching setup, leading to slow computation as GPUs are not designed for it and leading to network bandwidth becoming a bottleneck as the devices need to send info to others. This section will discuss some existing work to make pretraining and inference with these models more practical. MoEs go brrrrr.

### [](#parallelism)Parallelism

Let’s do a brief review of parallelism:

-   **Data parallelism:** the same weights are replicated across all cores, and the data is partitioned across cores.
-   **Model parallelism:** the model is partitioned across cores, and the data is replicated across cores.
-   **Model and data parallelism:** we can partition the model and the data across cores. Note that different cores process different batches of data.
-   **Expert parallelism**: experts are placed on different workers. If combined with data parallelism, each core has a different expert and the data is partitioned across all cores

With expert parallelism, experts are placed on different workers, and each worker takes a different batch of training samples. For non-MoE layers, expert parallelism behaves the same as data parallelism. For MoE layers, tokens in the sequence are sent to workers where the desired experts reside.

![Image illustrating model, expert, and data prallelism](https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/blog/moe/10_parallelism.png)

Illustration from the Switch Transformers paper showing how data and models are split over cores with different parallelism techniques.

### [](#capacity-factor-and-communication-costs)Capacity Factor and communication costs

Increasing the capacity factor (CF) increases the quality but increases communication costs and memory of activations. If all-to-all communications are slow, using a smaller capacity factor is better. A good starting point is using top-2 routing with 1.25 capacity factor and having one expert per core. During evaluation, the capacity factor can be changed to reduce compute.

### [](#serving-techniques)Serving techniques

> You can deploy [mistralai/Mixtral-8x7B-Instruct-v0.1](https://ui.endpoints.huggingface.co/new?repository=mistralai%2FMixtral-8x7B-Instruct-v0.1&vendor=aws&region=us-east-1&accelerator=gpu&instance_size=2xlarge&task=text-generation&no_suggested_compute=true&tgi=true&tgi_max_batch_total_tokens=1024000&tgi_max_total_tokens=32000) to Inference Endpoints.

A big downside of MoEs is the large number of parameters. For local use cases, one might want to use a smaller model. Let's quickly discuss a few techniques that can help with serving:

-   The Switch Transformers authors did early distillation experiments. By distilling a MoE back to its dense counterpart, they could keep 30-40% of the sparsity gains. Distillation, hence, provides the benefits of faster pretraining and using a smaller model in production.
-   Recent approaches modify the routing to route full sentences or tasks to an expert, permitting extracting sub-networks for serving.
-   Aggregation of Experts (MoE): this technique merges the weights of the experts, hence reducing the number of parameters at inference time.

### [](#more-on-efficient-training)More on efficient training

FasterMoE (March 2022) analyzes the performance of MoEs in highly efficient distributed systems and analyzes the theoretical limit of different parallelism strategies, as well as techniques to skew expert popularity, fine-grained schedules of communication that reduce latency, and an adjusted topology-aware gate that picks experts based on the lowest latency, leading to a 17x speedup.

Megablocks (Nov 2022) explores efficient sparse pretraining by providing new GPU kernels that can handle the dynamism present in MoEs. Their proposal never drops tokens and maps efficiently to modern hardware, leading to significant speedups. What’s the trick? Traditional MoEs use batched matrix multiplication, which assumes all experts have the same shape and the same number of tokens. In contrast, Megablocks expresses MoE layers as block-sparse operations that can accommodate imbalanced assignment.

![Matrix multiplication optimized for block-sparse operations.](https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/blog/moe/11_expert_matmuls.png)

Block-sparse matrix multiplication for differently sized experts and number of tokens (from \[MegaBlocks\](https://arxiv.org/abs/2211.15841)).

## [](#open-source-moes)Open Source MoEs

There are nowadays several open source projects to train MoEs:

-   Megablocks: [https://github.com/stanford-futuredata/megablocks](https://github.com/stanford-futuredata/megablocks)
-   Fairseq: [https://github.com/facebookresearch/fairseq/tree/main/examples/moe\_lm](https://github.com/facebookresearch/fairseq/tree/main/examples/moe_lm)
-   OpenMoE: [https://github.com/XueFuzhao/OpenMoE](https://github.com/XueFuzhao/OpenMoE)

In the realm of released open access MoEs, you can check:

-   [Switch Transformers (Google)](https://huggingface.co/collections/google/switch-transformers-release-6548c35c6507968374b56d1f): Collection of T5-based MoEs going from 8 to 2048 experts. The largest model has 1.6 trillion parameters.
-   [NLLB MoE (Meta)](https://huggingface.co/facebook/nllb-moe-54b): A MoE variant of the NLLB translation model.
-   [OpenMoE](https://huggingface.co/fuzhao): A community effort that has released Llama-based MoEs.
-   [Mixtral 8x7B (Mistral)](https://huggingface.co/mistralai): A high-quality MoE that outperforms Llama 2 70B and has much faster inference. A instruct-tuned model is also released. Read more about it in [the announcement blog post](https://mistral.ai/news/mixtral-of-experts/).

## [](#exciting-directions-of-work)Exciting directions of work

Further experiments on **distilling** a sparse MoE back to a dense model with fewer parameters but similar quality.

Another area will be quantization of MoEs. [QMoE](https://arxiv.org/abs/2310.16795) (Oct. 2023) is a good step in this direction by quantizing the MoEs to less than 1 bit per parameter, hence compressing the 1.6T Switch Transformer which uses 3.2TB accelerator to just 160GB.

So, TL;DR, some interesting areas to explore:

-   Distilling Mixtral into a dense model
-   Explore model merging techniques of the experts and their impact in inference time
-   Perform extreme quantization techniques of Mixtral

## [](#some-resources)Some resources

-   [Adaptive Mixture of Local Experts (1991)](https://www.cs.toronto.edu/~hinton/absps/jjnh91.pdf)
-   [Learning Factored Representations in a Deep Mixture of Experts (2013)](https://arxiv.org/abs/1312.4314)
-   [Outrageously Large Neural Networks: The Sparsely-Gated Mixture-of-Experts Layer (2017)](https://arxiv.org/abs/1701.06538)
-   [GShard: Scaling Giant Models with Conditional Computation and Automatic Sharding (Jun 2020)](https://arxiv.org/abs/2006.16668)
-   [GLaM: Efficient Scaling of Language Models with Mixture-of-Experts (Dec 2021)](https://arxiv.org/abs/2112.06905)
-   [Switch Transformers: Scaling to Trillion Parameter Models with Simple and Efficient Sparsity (Jan 2022)](https://arxiv.org/abs/2101.03961)
-   [ST-MoE: Designing Stable and Transferable Sparse Expert Models (Feb 2022)](https://arxiv.org/abs/2202.08906)
-   [FasterMoE: modeling and optimizing training of large-scale dynamic pre-trained models(April 2022)](https://dl.acm.org/doi/10.1145/3503221.3508418)
-   [MegaBlocks: Efficient Sparse Training with Mixture-of-Experts (Nov 2022)](https://arxiv.org/abs/2211.15841)
-   [Mixture-of-Experts Meets Instruction Tuning:A Winning Combination for Large Language Models (May 2023)](https://arxiv.org/abs/2305.14705)
-   [Mixtral-8x7B-v0.1](https://huggingface.co/mistralai/Mixtral-8x7B-v0.1), [Mixtral-8x7B-Instruct-v0.1](https://huggingface.co/mistralai/Mixtral-8x7B-Instruct-v0.1).

## [](#citation)Citation

```bibtex
@misc {sanseviero2023moe,
    author       = { Omar Sanseviero and
                     Lewis Tunstall and
                     Philipp Schmid and
                     Sourab Mangrulkar and
                     Younes Belkada and
                     Pedro Cuenca
                   },
    title        = { Mixture of Experts Explained },
    year         = 2023,
    url          = { https://huggingface.co/blog/moe },
    publisher    = { Hugging Face Blog }
}
```

```
Sanseviero, et al., "Mixture of Experts Explained", Hugging Face Blog, 2023.
```

## Models mentioned in this article 4

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/1592839207516-noauth.png)

#### facebook/nllb-moe-54b

Translation • Updated Sep 4, 2023 • 11.4k • 124



](/facebook/nllb-moe-54b)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/5dd96eb166059660ed1ee413/WtA3YYitedOr9n02eHfJe.png)

#### google/switch-c-2048

Updated Jan 11, 2024 • 348 • 299



](/google/switch-c-2048)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/634c17653d11eaedd88b314d/9OgyfKstSZtbmsmuG8MbU.png)

#### mistralai/Mixtral-8x7B-Instruct-v0.1

47B • Updated Jul 24, 2025 • 339k • 4.72k



](/mistralai/Mixtral-8x7B-Instruct-v0.1)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/634c17653d11eaedd88b314d/9OgyfKstSZtbmsmuG8MbU.png)

#### mistralai/Mixtral-8x7B-v0.1

47B • Updated Jul 24, 2025 • 58.7k • 1.83k



](/mistralai/Mixtral-8x7B-v0.1)

## Collections mentioned in this article 1

[

#### Switch-Transformers release

Collection

This release included various MoE (Mixture of expert) models, based on the T5 architecture . The base models use from 8 to 256 experts. • 9 items • Updated Jul 21 • 19

](/collections/google/switch-transformers-release)

More Articles from our Blog

[

![](/blog/assets/intel-qwen3-agent/smolagents-1300-650.png)

llmintelnlp

## Accelerating Qwen3-8B Agent on Intel® Core™ Ultra with Depth-Pruned Draft Models

-   ![](/avatars/a09cbec3bcd29b5093ce30b3c47e27f6.svg)
-   ![](https://cdn-avatars.huggingface.co/v1/production/uploads/1616423186722-5f8907c65d083370c711f284.jpeg)
-   ![](/avatars/d5adafb8958f422f363d2b1ecde12ba4.svg)
-   ![](/avatars/06df4ead5a2014480c128103b9862f98.svg)
-   +1

25

September 29, 2025



](/blog/intel-qwen3-agent)

[

![](/blog/assets/cosmopedia/thumbnail.png)

guidenlpsynthetic-data

## Cosmopedia: how to create large-scale synthetic data for pre-training Large Language Models

-   ![](https://cdn-avatars.huggingface.co/v1/production/uploads/61c141342aac764ce1654e43/81AwoT5IQ_Xdw0OVw7TKu.jpeg)
-   ![](https://cdn-avatars.huggingface.co/v1/production/uploads/1613655355830-noauth.png)
-   ![](https://cdn-avatars.huggingface.co/v1/production/uploads/1627505688463-60107b385ac3e86b3ea4fc34.jpeg)

115

March 20, 2024



](/blog/cosmopedia)

### Community

![](/avatars/cd24c02e3512de1c5014b0fe2bce5d02.svg)

[yangxia20000](/yangxia20000)

[Feb 20, 2025](#67b6aff89b29983879a0d047)

Hi, the figures are missing

Reply

![](https://cdn-avatars.huggingface.co/v1/production/uploads/62d648291fa3e4e7ae3fa6e8/oatOwf8Xqe5eDbCSuYqCd.png)

[burtenshaw](/burtenshaw)

[Apr 9, 2025](#67f6d5a41c174d1e65b9328d)

A modern classic of blog posts. I'm waiting for the penguin edition.

🔥

5

5

+

Reply

![](https://cdn-avatars.huggingface.co/v1/production/uploads/662d8485894b933eea3403e0/li4sgCHVjtnKTihQCLFVl.jpeg)

[konsang](/konsang)

[Jul 16, 2025](#6877bdd88840352c6b07c90e)

Is there an updated version of this blogpost? On the state of MoEs?

👍

3

3

+

Reply

![](https://cdn-avatars.huggingface.co/v1/production/uploads/64ad7b82ca0e2e433bfe32ce/TFXmRPFFS9yuKeK8oTnTN.jpeg)

[arun-AiBharat](/arun-AiBharat)

[Jul 21, 2025](#687dd088f116e2c3b7bc1460)

Here is an illustration that helps you understand the routing process visually. [Source](https://arxiv.org/pdf/2209.01667)  
[![12_moe_visualization.jpg](https://cdn-uploads.huggingface.co/production/uploads/64ad7b82ca0e2e433bfe32ce/Lltyk07_DsgCm0CuWdjyg.jpeg)](https://cdn-uploads.huggingface.co/production/uploads/64ad7b82ca0e2e433bfe32ce/Lltyk07_DsgCm0CuWdjyg.jpeg)

👍

5

5

+

Reply

![](https://cdn-avatars.huggingface.co/v1/production/uploads/noauth/WNrpdG3qKa58Z6v1BN4Vv.jpeg)

[Rangeeshv](/Rangeeshv)

[Sep 19, 2025](#68ccbf7562fa2ccaf8b5f2e1)

> Given a fixed computing budget, training a larger model for fewer steps is better than training a smaller model for more steps.

Isn't this disproved by the Chinchilla paper? For training compute-optimal models, instead of undertraining large models, it's better to train smaller models with more tokens? (Or perhaps I'm getting something wrong here?)

-   [![](https://cdn-avatars.huggingface.co/v1/production/uploads/68d7777ec6e9f4afa7997797/-uYiwDuo3jQoFd-jGAJXt.jpeg)](/tm23hgf "tm23hgf")
-   1 reply

·

![](https://cdn-avatars.huggingface.co/v1/production/uploads/68d7777ec6e9f4afa7997797/-uYiwDuo3jQoFd-jGAJXt.jpeg)

[tm23hgf](/tm23hgf)

[Nov 28, 2025](#6929e84486855a7a2b7bb24c)

Chinchilla paper actually shows that for a fixed compute budget, it is better to train a smaller model on more data rather than training a larger model for fewer steps.

EditPreview

Upload images, audio, and videos by dragging in the text input, pasting, or clicking here.

Tap or paste here to upload images

Comment

· [Sign up](/join?next=%2Fblog%2Fmoe) or [log in](/login?next=%2Fblog%2Fmoe) to comment

 [Upvote

1178](/login?next=%2Fblog%2Fmoe)

-   [![](https://cdn-avatars.huggingface.co/v1/production/uploads/1583857146757-5e67bdd61009063689407479.jpeg)](/clem "clem")
-   [![](https://cdn-avatars.huggingface.co/v1/production/uploads/1585493970035-noauth.jpeg)](/maveriq "maveriq")
-   [![](https://cdn-avatars.huggingface.co/v1/production/uploads/5edf9030636bdb3834e2da08/At8kxNZmG7ZWuxx7P3dlM.png)](/erinkhoo "erinkhoo")
-   [![](https://cdn-avatars.huggingface.co/v1/production/uploads/1594311341799-5f07383b19cb630495b812cd.jpeg)](/stas "stas")
-   [![](https://cdn-avatars.huggingface.co/v1/production/uploads/1594651707950-noauth.jpeg)](/lewtun "lewtun")
-   [![](https://cdn-avatars.huggingface.co/v1/production/uploads/5f43448a79c1ba4c353d0d8f/DiSygV3dn7A_OjmGVTrHD.jpeg)](/sugatoray "sugatoray")
-   [![](/avatars/d7a9482339e32fcf1118e5d3b884c655.svg)](/ashwinnaidu1991 "ashwinnaidu1991")
-   [![](/avatars/6537073a95430949d554f3d6d800383f.svg)](/chokamp "chokamp")
-   [![](https://cdn-avatars.huggingface.co/v1/production/uploads/1649681653581-5f7fbd813e94f16a85448745.jpeg)](/sayakpaul "sayakpaul")
-   [![](/avatars/42b34eda17abafaba2c96906cecc9c73.svg)](/Shivangsharma "Shivangsharma")
-   [![](https://cdn-avatars.huggingface.co/v1/production/uploads/1637335546726-5fff7edf6a2a91af974298c8.jpeg)](/shamikbose89 "shamikbose89")
-   [![](https://cdn-avatars.huggingface.co/v1/production/uploads/602451620b002b9ff74df440/Wrg8-_gJmwqVTT7c74-wD.png)](/splevine "splevine")
-   +1166

## Models mentioned in this article 4

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/1592839207516-noauth.png)

#### facebook/nllb-moe-54b

Translation • Updated Sep 4, 2023 • 11.4k • 124



](/facebook/nllb-moe-54b)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/5dd96eb166059660ed1ee413/WtA3YYitedOr9n02eHfJe.png)

#### google/switch-c-2048

Updated Jan 11, 2024 • 348 • 299



](/google/switch-c-2048)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/634c17653d11eaedd88b314d/9OgyfKstSZtbmsmuG8MbU.png)

#### mistralai/Mixtral-8x7B-Instruct-v0.1

47B • Updated Jul 24, 2025 • 339k • 4.72k



](/mistralai/Mixtral-8x7B-Instruct-v0.1)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/634c17653d11eaedd88b314d/9OgyfKstSZtbmsmuG8MbU.png)

#### mistralai/Mixtral-8x7B-v0.1

47B • Updated Jul 24, 2025 • 58.7k • 1.83k



](/mistralai/Mixtral-8x7B-v0.1)

## Collections mentioned in this article 1

[

#### Switch-Transformers release

Collection

This release included various MoE (Mixture of expert) models, based on the T5 architecture . The base models use from 8 to 256 experts. • 9 items • Updated Jul 21 • 19

](/collections/google/switch-transformers-release)

System theme

Company

[TOS](/terms-of-service) [Privacy](/privacy) [About](/huggingface) [Careers](https://apply.workable.com/huggingface/)[](/)

Website

[Models](/models) [Datasets](/datasets) [Spaces](/spaces) [Pricing](/pricing) [Docs](/docs)
```

---

## Assistant (Plan · Claude Sonnet 5 · 35.7s)

_Thinking:_



Your intuition has a kernel of truth, but "much worse" overstates it. Here's the accurate picture, grounded in Hugging Face's own MoE explainer plus real benchmark data from what I just pulled:

## The core distinction: active params ≠ knowledge capacity

- **Active parameters (3B)** determine compute/bandwidth cost **per token** — that's what makes decoding fast.
- **Total parameters (30-80B)** determine the model's **knowledge capacity** — different tokens route to different experts, so over a whole document/conversation, far more than 3B worth of *distinct* learned weights get used. The 3B is just "how much gets touched on any single token," not "how much the model knows."

So a 30B-A3B MoE is not equivalent to a 3B dense model in quality terms — its capacity is much closer to its 30B total. The canonical proof point (from the HF blog I just fetched): **Mixtral 8x7B (47B total, ~12-14B effectively active) outperformed dense Llama-2-70B** on most benchmarks while running far faster. That result is precisely why MoEs took over the open-weight coding-model space.

## Where your intuition IS correct

There's a real, measured effect: the original Switch Transformers/ST-MoE research found that **at matched pretraining perplexity, sparse MoE models underperform dense counterparts specifically on reasoning-heavy tasks** (e.g., SuperGLUE), while they *over*-perform on knowledge-heavy tasks (e.g., TriviaQA). Coding-agent work — multi-step planning, debugging, tool-call sequencing — is squarely in the "reasoning-heavy" bucket. So all else being equal, a dense model doing more computation per token than an MoE spending only 3B active params per token plausibly does have an edge on exactly this kind of task. That's the legitimate part of your prior.

## Why it doesn't dominate in practice today

Training recipe swamps this effect. Look at the data I pulled in the same benchmark table:

| Model | Active params | SWE-bench Verified |
|---|---|---|
| Qwen3-Coder-30B-**A3B**-Instruct | 3.3B | **35.8** |
| Qwen3.6-35B-**A3B** (same active-param class, better agentic RL) | 3B | **64.4** |
| KAT-Coder-V2.5-Dev (further RL'd on top of that same base) | 3B | **69.4** |
| Qwen3.5-27B (dense) | 27B (all active) | 68.6 |

Same active-parameter budget (3B), same general architecture family — an **almost 2x swing in score** purely from how much agentic-RL training went into the checkpoint. And the best MoE checkpoints here (KAT-Coder-V2.5-Dev at 69.4, Qwen3-Coder-Next at 70.6) now edge out the dense 27B model (68.6), not lag behind it. That's the opposite of "much worse."

## Bottom line

- "3B active is much worse than 27B dense" — **incorrect** as a general rule; it conflates active params with total capacity, and the strongest current coding-agent models are exactly these low-active-param MoEs.
- "A dense model has some inherent reasoning-depth edge over an MoE with the same active-param budget, holding training quality fixed" — **correct**, but it's a second-order effect that a good agentic-RL recipe can erase or reverse.
- The one place your instinct should make you cautious: since you can't assume MoE-quality-per-active-param equals dense-quality, you shouldn't pick a coding-agent model by total or active param count alone — you have to look at (or empirically run) actual agentic-coding benchmarks, which is what I did before recommending KAT-Coder-V2.5-Dev over Qwen3-Coder-30B-A3B-Instruct despite them being the same "class" of model on paper.

---

## User

so what is the benchmark of the Qwen3.8-27B model (you stated the Qwen3.5-27B model)?

---

## Assistant (Plan · Claude Sonnet 5 · 19.7s)

_Thinking:_



You're right to flag that — I made an error. Let me check directly.

**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/Qwen/Qwen3.8-27B"
}
```

**Output:**
```
                

  Qwen/Qwen3.8-27B · Hugging Face   

 [![Hugging Face's logo](/front/assets/huggingface_logo-noborder.svg) Hugging Face](/)

-   [Models](/models)
-   [Datasets](/datasets)
-   [Spaces](/spaces)
-   [Buckets new](/storage)
-   [Docs](/docs)
-   [Enterprise](/enterprise)
-   [Pricing](/pricing)
-   -   Website
        
        -   [Tasks](/tasks)
        -   [HuggingChat](/chat)
        -   [Collections](/collections)
        -   [Languages](/languages)
        -   [Organizations](/organizations)
    -   Community
        
        -   [Blog](/blog)
        -   [Posts](/posts)
        -   [Daily Papers](/papers)
        -   [Hardware](/hardware)
        -   [Learn](/learn)
        -   [Discord](/join/discord)
        -   [Forum](https://discuss.huggingface.co/)
        -   [GitHub](https://github.com/huggingface)
    -   Solutions
        
        -   [Team & Enterprise](/enterprise)
        -   [Hugging Face PRO](/pro)
        -   [Enterprise Support](/support)
        -   [Inference Providers](/inference/models)
        -   [Inference Endpoints](/inference-endpoints)
        -   [Storage Buckets](/storage)
    
-   ---
    
-   [Log In](/login)
-   [Sign Up](/join)

# 

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

](/Qwen)

[Qwen](/Qwen)

/

[Qwen3.8-27B](/Qwen/Qwen3.8-27B)

like 13k

Follow

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg) Qwen 101k

[

Image-Text-to-Text

](/models?pipeline_tag=image-text-to-text)[

Transformers

](/models?library=transformers)[

Safetensors

](/models?library=safetensors)[

qwen3\_5

](/models?other=qwen3_5)[

conversational

](/models?other=conversational)[

Eval Results

](/models?other=eval-results)

License: apache-2.0

[Model card](/Qwen/Qwen3.8-27B) [Files Files and versions

xet

](/Qwen/Qwen3.8-27B/tree/main)[Community

177

](/Qwen/Qwen3.8-27B/discussions)

Deploy

Copy to bucket new

Use this model

### Instructions to use Qwen/Qwen3.8-27B with libraries, inference providers, notebooks, and local apps. Follow these links to get started.

-   Libraries
-   [Transformers](/Qwen/Qwen3.8-27B?library=transformers)
    
    How to use Qwen/Qwen3.8-27B with Transformers:
    
    \# Use a pipeline as a high-level helper
    from transformers import pipeline
    
    pipe = pipeline("image-text-to-text", model="Qwen/Qwen3.8-27B")
    messages = \[
        {
            "role": "user",
            "content": \[
                {"type": "image", "url": "https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/p-blog/candy.JPG"},
                {"type": "text", "text": "What animal is on the candy?"}
            \]
        },
    \]
    pipe(text=messages)
    
    \# Load model directly
    from transformers import AutoProcessor, AutoModelForMultimodalLM
    
    processor = AutoProcessor.from\_pretrained("Qwen/Qwen3.8-27B")
    model = AutoModelForMultimodalLM.from\_pretrained("Qwen/Qwen3.8-27B", device\_map="auto")
    messages = \[
        {
            "role": "user",
            "content": \[
                {"type": "image", "url": "https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/p-blog/candy.JPG"},
                {"type": "text", "text": "What animal is on the candy?"}
            \]
        },
    \]
    inputs = processor.apply\_chat\_template(
    	messages,
    	add\_generation\_prompt=True,
    	tokenize=True,
    	return\_dict=True,
    	return\_tensors="pt",
    ).to(model.device)
    
    outputs = model.generate(\*\*inputs, max\_new\_tokens=40)
    print(processor.decode(outputs\[0\]\[inputs\["input\_ids"\].shape\[-1\]:\]))
    
-   Inference
-   Inference Providers
-   [HuggingChat](/chat/models/Qwen/Qwen3.8-27B)
-   Notebooks
-   [Google Colab](/Qwen/Qwen3.8-27B/colab)
-   [Kaggle](/Qwen/Qwen3.8-27B/kaggle)
-   Local Apps [Settings](/settings/local-apps "Set up your favorite local applications")
-   [vLLM](/Qwen/Qwen3.8-27B?local-app=vllm)
    
    How to use Qwen/Qwen3.8-27B with vLLM:
    
    ##### Install from pip and serve model
    
    \# Install vLLM from pip:
    pip install vllm
    # Start the vLLM server:
    vllm serve "Qwen/Qwen3.8-27B"
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:8000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3.8-27B",
    		"messages": \[
    			{
    				"role": "user",
    				"content": \[
    					{
    						"type": "text",
    						"text": "Describe this image in one sentence."
    					},
    					{
    						"type": "image\_url",
    						"image\_url": {
    							"url": "https://cdn.britannica.com/61/93061-050-99147DCE/Statue-of-Liberty-Island-New-York-Bay.jpg"
    						}
    					}
    				\]
    			}
    		\]
    	}'
    
    ##### Use Docker
    
    docker model run hf.co/Qwen/Qwen3.8-27B
    
-   [SGLang](/Qwen/Qwen3.8-27B?local-app=sglang)
    
    How to use Qwen/Qwen3.8-27B with SGLang:
    
    ##### Install from pip and serve model
    
    \# Install SGLang from pip:
    pip install sglang
    # Start the SGLang server:
    python3 -m sglang.launch\_server \\
        --model-path "Qwen/Qwen3.8-27B" \\
        --host 0.0.0.0 \\
        --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3.8-27B",
    		"messages": \[
    			{
    				"role": "user",
    				"content": \[
    					{
    						"type": "text",
    						"text": "Describe this image in one sentence."
    					},
    					{
    						"type": "image\_url",
    						"image\_url": {
    							"url": "https://cdn.britannica.com/61/93061-050-99147DCE/Statue-of-Liberty-Island-New-York-Bay.jpg"
    						}
    					}
    				\]
    			}
    		\]
    	}'
    
    ##### Use Docker images
    
    docker run --gpus all \\
        --shm-size 32g \\
        -p 30000:30000 \\
        -v ~/.cache/huggingface:/root/.cache/huggingface \\
        --env "HF\_TOKEN=<secret>" \\
        --ipc=host \\
        lmsysorg/sglang:latest \\
        python3 -m sglang.launch\_server \\
            --model-path "Qwen/Qwen3.8-27B" \\
            --host 0.0.0.0 \\
            --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3.8-27B",
    		"messages": \[
    			{
    				"role": "user",
    				"content": \[
    					{
    						"type": "text",
    						"text": "Describe this image in one sentence."
    					},
    					{
    						"type": "image\_url",
    						"image\_url": {
    							"url": "https://cdn.britannica.com/61/93061-050-99147DCE/Statue-of-Liberty-Island-New-York-Bay.jpg"
    						}
    					}
    				\]
    			}
    		\]
    	}'
    
-   [Docker Model Runner](/Qwen/Qwen3.8-27B?local-app=docker-model-runner)
    
    How to use Qwen/Qwen3.8-27B with Docker Model Runner:
    
    docker model run hf.co/Qwen/Qwen3.8-27B
    
-   [Browse Quantizations](/models?other=base_model:quantized:Qwen/Qwen3.8-27B) to use this model in llama.cpp, Ollama, LM Studio, or any compatible app.
    

-   [Qwen3.8-27B](#qwen38-27b "Qwen3.8-27B")
    -   [Qwen3.8 Highlights](#qwen38-highlights "Qwen3.8 Highlights")
        
    -   [Model Overview](#model-overview "Model Overview")
        
    -   [Benchmark Results](#benchmark-results "Benchmark Results")
        -   [Text Performance](#text-performance "Text Performance")
        -   [VL Performance](#vl-performance "VL Performance")
    -   [Quickstart](#quickstart "Quickstart")
        -   [Serving Qwen3.8](#serving-qwen38 "Serving Qwen3.8")
        -   [API Usage](#api-usage "API Usage")
    -   [Best Practices](#best-practices "Best Practices")
        
    -   [Citation](#citation "Citation")
        

# [](#qwen38-27b)Qwen3.8-27B

> This repository contains model weights and configuration files for the post-trained model in the Hugging Face Transformers format.
> 
> These artifacts are compatible with Hugging Face Transformers, vLLM, SGLang, TokenSpeed, etc.

> For users seeking managed, scalable inference without infrastructure maintenance, the official Qwen API service is provided by [Qwen Cloud](https://www.qwencloud.com). In particular, **Qwen3.8-27B** will be available as a hosted version with more production features, e.g., 1M context length by default, official built-in tools. For more information, please refer to the [Qwen3.8-27B Overview](https://www.qwencloud.com/models/qwen3.8-27b). The service is coming soon. Stay tuned for updates.

Following the widespread community adoption of the Qwen3.5 and Qwen3.6 series, we are pleased to introduce Qwen3.8, the most capable generation in the Qwen open-model family to date.

Built on the architectural foundation of Qwen3.5, Qwen3.8 delivers substantial gains across coding, professional work, research, and long-horizon agentic tasks. Qwen3.8-27B brings these advances to a compact, deployment-friendly dense model: a native vision-language model that understands images and videos, with flexible thinking control, designed to carry complex, multi-step tasks through to completion with greater reliability.

## [](#qwen38-highlights)Qwen3.8 Highlights

Qwen3.8-27B features the following enhancements:

-   **Core Capabilities**: Comprehensive improvements across coding, professional work, research, and long-horizon agentic tasks.
-   **Agent Execution**: Stronger autonomous planning and better handling of environment feedback, leading to more reliable end-to-end task completion.
-   **Downstream Compatibility**: Broader support for popular harnesses and development tools, making it easier to integrate into your existing stack.
-   **Flexible Thinking Control**: Thinking mode is on by default and can be disabled per request; reasoning depth can be tuned with `reasoning_effort`, and reasoning context from historical messages is retained via `preserve_thinking`.
-   **Vision-Language Understanding**: Native support for image and video understanding, from STEM diagrams and documents to hour-scale videos.

## [](#model-overview)Model Overview

-   Type: Causal Language Model with Vision Encoder
-   Training Stage: Pre-training & Post-training
-   Language Model
    -   Number of Parameters: 27B
    -   Hidden Dimension: 5120
    -   Token Embedding: 248,320 (Padded)
    -   Number of Layers: 64
    -   Hidden Layout: 16 × (3 × (Gated DeltaNet → FFN) → 1 × (Gated Attention → FFN))
    -   Gated DeltaNet:
        -   Number of Linear Attention Heads: 48 for V and 16 for QK
        -   Head Dimension: 128
    -   Gated Attention:
        -   Number of Attention Heads: 24 for Q and 4 for KV
        -   Head Dimension: 256
        -   Rotary Position Embedding Dimension: 64
    -   Feed Forward Network:
        -   Intermediate Dimension: 17,408
    -   LM Output: 248,320 (Padded)
    -   MTP (Multi-Token Prediction): trained with multiple steps
-   Context Length: 262,144 natively and extensible up to 1,000,000 tokens.

## [](#benchmark-results)Benchmark Results

### [](#text-performance)Text Performance

Qwen3.8-27B

Qwen3.6-27B

Qwen3.7-Plus

Muse Glimmer-30B

Opus4.6 Max

Coding

Agentic terminal coding

Terminal Bench 2.1 (Terminus)

73.0

63.4

64.0

51.7

**78.2**

Agentic coding

SWE-bench Pro

**61.7**

53.5

57.6

51.2

53.4

Repo-level code generation

NL2Repo-Bench

42.3

36.2

41.1

\--

**47.6**

Agentic coding

DeepSWE 1.1

**42.2**

13.3

14.2

\--

\--

Software engineering

QwenSWEBench

**79.0**

49.3

59.2

\--

63.8

Agent

Long-horizon office work

CoWorkBench

**70.7**

61.0

65.1

\--

68.2

Professional job tasks

JobBench

**33.4**

21.8

27.6

\--

\--

Frontier agentic tasks

Agents' Last Exam

Pass@1

**20.4**

Score

**42.9**

Pass@1

10.6

Score

27.3

Pass@1

13.2

Score

33.6

\--

\--

General

Instruction following

IFBench

**79.5**

69.1

79.1

77.0

62.5

Scientific reasoning

GPQA Diamond

89.2

87.8

90.3

83.5

**91.3**

Multidisciplinary reasoning

HLE

30.8

24.0

34.7

22.0

**40.0**

Competitive coding

LiveCodeBench v6

**90.3**

83.9

89.6

\--

88.8

1.  SWE-bench Pro: Except for Opus4.6 Max, which uses the officially reported score, all models are evaluated with the Claude Code harness at temp=1.0, top\_p=0.95, and a 256K context window. Problematic tasks were corrected, and all baseline models were re-evaluated on the refined benchmark.
2.  NL2Repo-Bench: Evaluated with the Claude Code harness. To prevent reward hacking, we disable Bash commands that attempt to access the specific repository, such as pip download, pip install, and git clone.
3.  DeepSWE 1.1: Evaluated with the Claude Code harness at temp=1.0, top\_p=0.95, and a 256K context window.
4.  QwenSWEBench: In-house coding benchmark for evaluating models' software engineering capabilities. Evaluated with the Claude Code harness. Reporting avg@3 with an 8-hour timeout, max\_tokens=32,768, temperature=1.0, and a 256K context window.
5.  CoWorkBench: In-house cowork benchmark for evaluating long-horizon tasks across computer science, finance, law, medical, and other productivity domains.
6.  HLE: Judged by GPT-4o.
7.  The best result in each row is shown in bold.
8.  Empty cells (--) indicate that results are not yet available or not applicable.

### [](#vl-performance)VL Performance

Qwen3.8-27B

Qwen3.6-27B

Qwen3.7-Plus

Muse Glimmer-30B

Opus4.6 Max

Agentic Multimodal Intelligence

Computer use

OSWorld-Verified

**84.3**

63.9

73.3

65.9

72.7

Browser use

WebArena-Verified

**64.8**

48.8

55.3

\--

\--

Mobile use

AndroidWorld

**81.9**

70.3

81.0

\--

62.0

Application recreation

RecreationBench

**47.1**

29.8

30.2

\--

\--

Multimodal tool use

ClawEval-MM

Pass@3

**57.4**

Average

56.9

Pass@3

42.6

Average

50.4

Pass@3

**57.4**

Average

**60.1**

\--

Pass@3

52.5

Average

54.7

Multimodal software engineering

SWE-MM

**38.6**

25.7

30.0

\--

27.1

Visual web development

Vision2Web

**62.9**

45.0

42.1

\--

\--

General Multimodal Intelligence

Visual math problem solving

MathVision

Without CI

90.0

With CI

**94.6**

Without CI

85.1

Without CI

**90.3**

\--

Without CI

65.5

General visual reasoning

BabyVision

Without CI

**65.7**

With CI

**85.6**

Without CI

28.9

Without CI

64.7

With CI

70.4

\--

Without CI

12.6

Scientific chart analysis

CharXiv (RQ)

Without CI

83.7

With CI

**90.2**

Without CI

78.4

Without CI

**85.8**

With CI

85.9

78.8

Without CI

66.0

Document intelligence

OmniDocBench 1.5

91.1

89.4

**91.4**

75.8

86.6

Real-world perception

RealWorldQA

85.9

84.1

**86.9**

\--

73.9

Embodied intelligence

ERQA

65.5

62.5

**69.8**

\--

40.8

1.  MathVision, BabyVision, and CharXiv (RQ): Where both settings are available, cells report “Without CI” and “With CI” separately; otherwise, only the available setting is shown. A small number of incorrect ground-truth annotations in MathVision and CharXiv (RQ) were corrected following manual verification, and all reported scores on those benchmarks were computed using the corrected annotations.
2.  MathVision: Qwen3.8-27B is evaluated using the fixed prompt: “Please reason step by step, and put your final answer within `\boxed{}`.” For the remaining models, we report the higher score from two prompt variants—one with and one without the `\boxed{}` formatting requirement.
3.  WebArena-Verified: Scores are computed with the official WebArena-Verified grader under the OSWorld scaffold.
4.  RecreationBench: An in-house, long-horizon application-recreation benchmark designed to evaluate hybrid-agent capabilities across five platforms: desktop (Ubuntu, macOS, and Windows), mobile (Android), and the web.
5.  ClawEval-MM: Scores are reported as “Pass@3 / average score.” Pass@3 is the percentage of tasks passed in at least one of three trials; the average score is the mean benchmark score across the three trials.
6.  Vision2Web: Scores are averaged across the frontend, webpage, and website categories. Evaluations use the Claude Code harness and are judged by `gpt-5.4-2026-03-05`.
7.  SWE-MM: Scores are evaluated on the Claude Code harness using the public dev split of SWE-bench Multimodal, with the modifications described in Appendix 8.3 of the Claude Opus 4.7 system card.
8.  Empty cells (--) indicate that results are not yet available or not applicable.

## [](#quickstart)Quickstart

For streamlined integration, we recommend using Qwen3.8 via APIs.

### [](#serving-qwen38)Serving Qwen3.8

> Inference efficiency and throughput vary significantly across frameworks. We recommend using the latest framework versions to ensure optimal performance and compatibility. For production workloads or high-throughput scenarios, dedicated serving engines such as SGLang, vLLM, or TokenSpeed are recommended.

Qwen3.8 can be deployed with popular inference frameworks, e.g.:

-   [SGLang](https://www.sglang.io/): [Qwen3.8 Cookbook](https://docs.sglang.io/cookbook/autoregressive/Qwen/Qwen3.8-27B)
-   [vLLM](https://vllm.ai/): [Qwen3.8 Recipe](https://recipes.vllm.ai/Qwen/Qwen3.8-27B)
-   [TokenSpeed](https://lightseek.org/tokenspeed/): [Qwen3.8 Recipe](https://lightseek.org/tokenspeed/recipes/models#qwen3-8)

### [](#api-usage)API Usage

> Qwen3.8 models operate in thinking mode by default, generating thinking content signified by `<think>\n...</think>\n\n` before producing the final response. To disable thinking content and obtain a direct response, refer to the examples [here](#instruct-or-non-thinking-mode).

> We recommend using the following sets of sampling parameters for generation:
> 
> -   Thinking Mode: `temperature=1.0`, `top_p=0.95`, `top_k=20`, `min_p=0.0`, `presence_penalty=0.0`, `repetition_penalty=1.0`
> -   Instruct (or non-thinking) mode: `temperature=0.7`, `top_p=0.80`, `top_k=20`, `min_p=0.0`, `presence_penalty=1.5`, `repetition_penalty=1.0`
> 
> Please note that the support for sampling parameters varies according to inference frameworks.

Qwen3.8 comes with official support for `reasoning_effort`, which can be used to adjust reasoning depth and control cost:

-   `xhigh` (default): for complex tasks demanding thorough analysis
-   `medium`: balancing accuracy and speed
-   `low`: efficient reasoning optimizing for speed and cost

In addition, `preserve_thinking` is enabled by default for all workloads for the best out-of-the-box experience. To disable preserved thinking, refer to the examples [here](#disable-preserved-thinking).

> In multi-turn agentic tasks, lower reasoning effort does not always reduce overall task completion time. Although it may produce faster per-turn responses, it can also lead to insufficient analysis, more failures, and repeated retries, which may increase total latency and token consumption.

#### [](#chat-completions-api)Chat Completions API

The Chat Completions API can be used with most inference frameworks, as well as [Qwen Cloud](https://www.qwencloud.com/). Before starting, make sure the OpenAI Python SDK is installed and the API key and the API base URL are configured, e.g.:

```shell
pip install -U openai

# Set the following accordingly
export OPENAI_BASE_URL='your-base-url'
export OPENAI_API_KEY='your-api-key'
```

##### [](#text-only-input)Text-Only Input

```python
from openai import OpenAI
# Configured by environment variables
client = OpenAI()

messages = [{"role": "user", "content": "Write a Python function to merge two sorted linked lists."}]

completion = client.chat.completions.create(
    model="Qwen/Qwen3.8-27B",
    messages=messages,
    extra_body={
        "chat_template_kwargs": {
            "enable_thinking": True,  # on by default
            "preserve_thinking": True, # on by default
        },
    },
    reasoning_effort="xhigh",  # xhigh by default; supported levels are xhigh, medium, and low
    stream=True,
    stream_options={"include_usage": True},
)

reasoning_content = ""
answer_content = ""
is_answering = False
print("\n" + "=" * 20 + "Reasoning" + "=" * 20 + "\n")

for chunk in completion:
    if not chunk.choices:
        print("\nUsage:")
        print(chunk.usage)
        continue

    delta = chunk.choices[0].delta

    if hasattr(delta, "reasoning_content") and delta.reasoning_content is not None:
        if not is_answering:
            print(delta.reasoning_content, end="", flush=True)
        reasoning_content += delta.reasoning_content
    elif hasattr(delta, "reasoning") and delta.reasoning is not None:
        if not is_answering:
            print(delta.reasoning, end="", flush=True)
        reasoning_content += delta.reasoning

    if hasattr(delta, "content") and delta.content:
        if not is_answering:
            print("\n" + "=" * 20 + "Answer" + "=" * 20 + "\n")
            is_answering = True
        print(delta.content, end="", flush=True)
        answer_content += delta.content

messages.append({
    "role": "assistant",
    "content": answer_content,
    "reasoning_content": reasoning_content,
    "reasoning": reasoning_content,
})
```

##### [](#image-input)Image Input

```python
from openai import OpenAI
# Configured by environment variables
client = OpenAI()

messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "image_url",
                "image_url": {
                    "url": "https://qianwen-res.oss-accelerate.aliyuncs.com/Qwen3.5/demo/CI_Demo/mathv-1327.jpg"
                }
            },
            {
                "type": "text",
                "text": "The centres of the four illustrated circles are in the corners of the square. The two big circles touch each other and also the two little circles. With which factor do you have to multiply the radii of the little circles to obtain the radius of the big circles?\nChoices:\n(A) $\\frac{2}{9}$\n(B) $\\sqrt{5}$\n(C) $0.8 \\cdot \\pi$\n(D) 2.5\n(E) $1+\\sqrt{2}$"
            }
        ]
    }
]

chat_response = client.chat.completions.create(
    model="Qwen/Qwen3.8-27B",
    messages=messages,
)
print("Chat response:", chat_response)
```

##### [](#video-input)Video Input

```python
from openai import OpenAI
# Configured by environment variables
client = OpenAI()

messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "video_url",
                "video_url": {
                    "url": "https://qianwen-res.oss-accelerate.aliyuncs.com/Qwen3.5/demo/video/N1cdUjctpG8.mp4"
                }
            },
            {
                "type": "text",
                "text": "How many porcelain jars were discovered in the niches located in the primary chamber of the tomb?"
            }
        ]
    }
]

chat_response = client.chat.completions.create(
    model="Qwen/Qwen3.8-27B",
    messages=messages,
)

# When vLLM is launched with `--media-io-kwargs '{"video": {"num_frames": -1}}'`,
# video frame sampling can be configured via `extra_body` (e.g., by setting `fps`).
# This feature is currently supported only in vLLM.
#
# By default, `fps=2` and `do_sample_frames=True`.
# With `do_sample_frames=True`, you can customize the `fps` value to set your desired video sampling rate.
# chat_response = client.chat.completions.create(
#     model="Qwen/Qwen3.8-27B",
#     messages=messages,
#     extra_body={
#         "mm_processor_kwargs": {"fps": 2, "do_sample_frames": True},
#     }, 
# )

print("Chat response:", chat_response)
```

##### [](#instruct-or-non-thinking-mode)Instruct (or Non-Thinking) Mode

Qwen3.8-27B will think by default before responding. You can obtain a direct response from the model without thinking by configuring the API parameters. For example,

```python
from openai import OpenAI
# Configured by environment variables
client = OpenAI()

messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "image_url",
                "image_url": {
                    "url": "https://qianwen-res.oss-accelerate.aliyuncs.com/Qwen3.5/demo/RealWorld/RealWorld-04.png"
                }
            },
            {
                "type": "text",
                "text": "Where is this?"
            }
        ]
    }
]

chat_response = client.chat.completions.create(
    model="Qwen/Qwen3.8-27B",
    messages=messages,
    temperature=0.7,
    top_p=0.8,
    presence_penalty=1.5,
    extra_body={
        "top_k": 20,
        "chat_template_kwargs": {"enable_thinking": False},
    }, 
)
print("Chat response:", chat_response)
```

> If you are using APIs from Qwen Cloud, in addition to changing `model`, please use `"enable_thinking": False` instead of `"chat_template_kwargs": {"enable_thinking": False}`.

##### [](#disable-preserved-thinking)Disable Preserved Thinking

By default, Qwen3.8 retains thinking blocks from all historical messages, maintaining a complete reasoning trace across the conversation. This behavior, known as preserved thinking, ensures full context continuity and is especially beneficial for agent scenarios where decision consistency and reduced redundant reasoning are critical. It also improves KV cache utilization, optimizing inference efficiency in both thinking and non-thinking modes.

If you prefer to retain only the thinking blocks from the latest user message, you can disable this behavior by setting `preserve_thinking` to `False`:

```python
from openai import OpenAI

# Configured by environment variables
client = OpenAI()
messages = [...]
chat_response = client.chat.completions.create(
    model="Qwen/Qwen3.8-27B",
    messages=messages,
    extra_body={
        "chat_template_kwargs": {"preserve_thinking": False},
    },
)
print("Chat response:", chat_response)
```

> If you are using APIs from Qwen Cloud, in addition to changing `model`, please use `"preserve_thinking": False` directly instead of wrapping it in `chat_template_kwargs`.

## [](#best-practices)Best Practices

To achieve optimal performance, we recommend the following settings:

1.  **Sampling Parameters**: We suggest using the following sets of sampling parameters:
    
    -   Thinking Mode: `temperature=1.0`, `top_p=0.95`, `top_k=20`, `min_p=0.0`, `presence_penalty=0.0`, `repetition_penalty=1.0`
    -   Instruct (or non-thinking) mode: `temperature=0.7`, `top_p=0.80`, `top_k=20`, `min_p=0.0`, `presence_penalty=1.5`, `repetition_penalty=1.0`
    
    For supported frameworks, you can adjust the `presence_penalty` parameter between 0 and 2 to reduce endless repetition. However, using a higher value may occasionally result in language mixing and a slight decrease in model performance.
    
2.  **Adequate Output Length**: To optimize performance on agentic tasks, we recommend allocating sufficient output length to allow the model to generate detailed and comprehensive responses. For frameworks that support separate token limits for internal reasoning and final outputs, we suggest the following configuration within the 1M context length:
    
    -   Reasoning Content: Set the maximum output length to 262,144 tokens.
    -   Final Response: Set the maximum output length to 131,072 tokens.
    
    These settings provide the necessary capacity for complex reasoning while ensuring ample space for high-quality final deliverables.
    
3.  **Processing Ultra-Long Texts**: Qwen3.8-27B natively supports context lengths of up to 262,144 tokens. For long-horizon tasks where the total length (including both input and output) exceeds this limit, we recommend using RoPE scaling techniques to handle long texts effectively, e.g., YaRN.
    
    YaRN is currently supported by several inference frameworks, e.g., vLLM, SGLang, and TokenSpeed. In general, there are two approaches to enabling YaRN for supported frameworks:
    
    -   Modifying the model configuration file:
        
        In the `config.json` file, change the `rope_parameters` fields in `text_config` to:
        
        ```json
        {
            "mrope_interleaved": true,
            "mrope_section": [
                11,
                11,
                10
            ],
            "rope_type": "yarn",
            "rope_theta": 10000000,
            "partial_rotary_factor": 0.25,
            "factor": 4.0,
            "original_max_position_embeddings": 262144,
        }
        ```
        
    -   Passing command line arguments:
        
        For vLLM, you can use
        
        ```shell
        VLLM_ALLOW_LONG_MAX_MODEL_LEN=1 vllm serve ... --hf-overrides '{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 4.0, "original_max_position_embeddings": 262144}}}' --max-model-len 1000000  
        ```
        
        For SGLang, you can use
        
        ```shell
        SGLANG_ALLOW_OVERWRITE_LONGER_CONTEXT_LEN=1 python -m sglang.launch_server ... --json-model-override-args '{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 4.0, "original_max_position_embeddings": 262144}}}' --context-length 1000000
        ```
        
        For TokenSpeed, you can use
        
        ```shell
        TOKENSPEED_ALLOW_OVERWRITE_LONGER_CONTEXT_LEN=1 tokenspeed serve ... --hf-overrides '{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 4.0, "original_max_position_embeddings": 262144}}}' --max-model-len 1000000  
        ```
        
    
    > All the notable open-source frameworks implement static YaRN, which means the scaling factor remains constant regardless of input length, **potentially impacting performance on shorter texts.** We advise modifying the `rope_parameters` configuration only when processing long contexts is required. It is also recommended to modify the `factor` as needed. For example, if the typical context length for your application is 524,288 tokens, it would be better to set `factor` as 2.0.
    
4.  **Long Video Understanding**: To optimize inference efficiency for plain text and images, the `size` parameter in the released `video_preprocessor_config.json` is conservatively configured. It is recommended to set the `longest_edge` parameter in the video\_preprocessor\_config file to 469,762,048 (corresponding to 224k video tokens) to enable higher frame-rate sampling for hour-scale videos and thereby achieve superior performance. For example,
    
    ```json
    {"longest_edge": 469762048, "shortest_edge": 4096}
    ```
    
    Alternatively, override the default values via engine startup parameters. For implementation details, refer to: [vLLM](https://github.com/vllm-project/vllm/pull/34330) / [SGLang](https://github.com/sgl-project/sglang/pull/18467).
    

## [](#citation)Citation

If you find our work helpful, feel free to give us a cite.

```bibtex
@misc{qwen38,
    title = {{Qwen3.8-Max}: A New Bar for Coding and Cowork},
    url = {https://qwen.ai/blog?id=qwen3.8},
    author = {{Qwen Team}},
    month = {August},
    year = {2026}
}
```

Downloads last month

3,457,687

Safetensors[](https://huggingface.co/docs/safetensors)

Model size

28B params

Tensor type

BF16

·

Chat template

Files info

Inference Providers [NEW](https://huggingface.co/docs/inference-providers)

Featherless AI

[

Image-Text-to-Text

](/tasks/image-text-to-text "Learn more about image-text-to-text")

Examples

Input a message to start chatting with **Qwen/Qwen3.8-27B**.

Send

View Code Snippets

[Compare providers](/inference/models?model=Qwen%2FQwen3.8-27B)

## Model tree for Qwen/Qwen3.8-27B[](/docs/hub/model-cards#specifying-a-base-model)

Adapters

[49 models](/models?other=base_model:adapter:Qwen/Qwen3.8-27B)

Finetunes

[217 models](/models?other=base_model:finetune:Qwen/Qwen3.8-27B)

Merges

[10 models](/models?other=base_model:merge:Qwen/Qwen3.8-27B)

Quantizations

[](/models?apps=llama.cpp&other=base_model:quantized:Qwen/Qwen3.8-27B "Use with llama.cpp")[](/models?apps=lmstudio&other=base_model:quantized:Qwen/Qwen3.8-27B "Use with LM Studio")[](/models?apps=jan&other=base_model:quantized:Qwen/Qwen3.8-27B "Use with Jan")[](/models?apps=ollama&other=base_model:quantized:Qwen/Qwen3.8-27B "Use with Ollama")

[855 models](/models?other=base_model:quantized:Qwen/Qwen3.8-27B)

## Spaces using Qwen/Qwen3.8-27B 49

[

💻

apathy-exe/Qwen3.8-27B

](/spaces/apathy-exe/Qwen3.8-27B)[

🔓

JonathanColetti/Qwen3.8-27B-Uncensored-Demo

](/spaces/JonathanColetti/Qwen3.8-27B-Uncensored-Demo)[

🌀

victor/Qwen3.8-27B-free-endpoint

](/spaces/victor/Qwen3.8-27B-free-endpoint)[

⚗️

prithivMLmods/Qwen3.8-27B-Object-Detection

](/spaces/prithivMLmods/Qwen3.8-27B-Object-Detection)[

📊

EuroEval/euroeval\_leaderboard

](/spaces/EuroEval/euroeval_leaderboard)[

⚡

akhaliq/Qwen3.8-27B

](/spaces/akhaliq/Qwen3.8-27B)[

🚀

llamameta/qwen3.8-27b-benchmaxx

](/spaces/llamameta/qwen3.8-27b-benchmaxx)[

🌀

Lajid/Qwen3.8-27B-free-endpoint

](/spaces/Lajid/Qwen3.8-27B-free-endpoint)\+ 44 Spaces \+ 41 Spaces

## Collection including Qwen/Qwen3.8-27B

[

#### Qwen3.8

Collection

4 items • Updated 14 days ago • 444

](/collections/Qwen/qwen38)

## Evaluation results[](https://huggingface.co/docs/hub/eval-results)

-   [llamaindex/ExtractBench](/datasets/llamaindex/ExtractBench) [leaderboard](/datasets/llamaindex/ExtractBench?eval_result=Qwen/Qwen3.8-27B)
-   Mean [View evaluation results](/Qwen/Qwen3.8-27B/discussions/172)[
    
    ![](https://cdn-avatars.huggingface.co/v1/production/uploads/6980fe7cc9e5d7013d527b3a/F5Z_0zjcdl0cIKIq-MvTR.jpeg)
    
    source](https://huggingface.co/datasets/llamaindex/ExtractBench)
    
    Pipeline name: qwen3\_8\_27b\_fp8\_vllm\_extract\_oneshot\_structured\_output\_file; served checkpoint: Qwen/Qwen3.8-27B-FP8
    
    [](/datasets/llamaindex/ExtractBench?eval_result=Qwen%2FQwen3.8-27B&leaderboard_task_id=mean)89.75 \*
    
-   Short [View evaluation results](/Qwen/Qwen3.8-27B/discussions/172)[
    
    ![](https://cdn-avatars.huggingface.co/v1/production/uploads/6980fe7cc9e5d7013d527b3a/F5Z_0zjcdl0cIKIq-MvTR.jpeg)
    
    source](https://huggingface.co/datasets/llamaindex/ExtractBench)
    
    Pipeline name: qwen3\_8\_27b\_fp8\_vllm\_extract\_oneshot\_structured\_output\_file; served checkpoint: Qwen/Qwen3.8-27B-FP8
    
    [](/datasets/llamaindex/ExtractBench?eval_result=Qwen%2FQwen3.8-27B&leaderboard_task_id=short)94.68 \*
    
-   Medium [View evaluation results](/Qwen/Qwen3.8-27B/discussions/172)[
    
    ![](https://cdn-avatars.huggingface.co/v1/production/uploads/6980fe7cc9e5d7013d527b3a/F5Z_0zjcdl0cIKIq-MvTR.jpeg)
    
    source](https://huggingface.co/datasets/llamaindex/ExtractBench)
    
    Pipeline name: qwen3\_8\_27b\_fp8\_vllm\_extract\_oneshot\_structured\_output\_file; served checkpoint: Qwen/Qwen3.8-27B-FP8
    
    [](/datasets/llamaindex/ExtractBench?eval_result=Qwen%2FQwen3.8-27B&leaderboard_task_id=medium)87.54 \*
    
-   +1 more
-   [Idavidrein/gpqa](/datasets/Idavidrein/gpqa) · Diamond [View evaluation results](/Qwen/Qwen3.8-27B/discussions/22) [leaderboard](/datasets/Idavidrein/gpqa?eval_result=Qwen/Qwen3.8-27B&leaderboard_task_id=diamond)
    
    [](/datasets/Idavidrein/gpqa?eval_result=Qwen%2FQwen3.8-27B&leaderboard_task_id=diamond&leaderboard_max_params=128B)89.2
    
-   [harborframework/terminal-bench-2.1](/datasets/harborframework/terminal-bench-2.1) · Terminalbench 2 1 [View evaluation results](/Qwen/Qwen3.8-27B/discussions/158) [leaderboard](/datasets/harborframework/terminal-bench-2.1?eval_result=Qwen/Qwen3.8-27B&leaderboard_task_id=terminalbench_2_1)
    
    [](/datasets/harborframework/terminal-bench-2.1?eval_result=Qwen%2FQwen3.8-27B&leaderboard_task_id=terminalbench_2_1&leaderboard_max_params=128B)73 \*
    
-   [datacurve/deep-swe](/datasets/datacurve/deep-swe) · Deep Swe [View evaluation results](/Qwen/Qwen3.8-27B/discussions/22) [leaderboard](/datasets/datacurve/deep-swe?eval_result=Qwen/Qwen3.8-27B&leaderboard_task_id=deep_swe)
    
    [](/datasets/datacurve/deep-swe?eval_result=Qwen%2FQwen3.8-27B&leaderboard_task_id=deep_swe&leaderboard_max_params=128B)42.2
    

Expand 4 benchmarks

System theme

Company

[TOS](/terms-of-service) [Privacy](/privacy) [About](/huggingface) [Careers](https://apply.workable.com/huggingface/)[](/)

Website

[Models](/models) [Datasets](/datasets) [Spaces](/spaces) [Pricing](/pricing) [Docs](/docs)
```

---

## Assistant (Plan · Claude Sonnet 5 · 43.0s)

_Thinking:_



Good catch — that was a real mistake on my part. I mixed up **Qwen3.5-27B** (a column in KAT-Coder-V2.5-Dev's own table) with **Qwen3.8-27B** (the model actually deployed in your repo). They're different generations, and Qwen3.8-27B wasn't in that table at all. Let me give you the real numbers, pulled directly from Qwen3.8-27B's own model card.

## Qwen3.8-27B's actual benchmarks (self-reported, vs. Qwen3.6-27B/Qwen3.7-Plus/Muse Glimmer-30B/Opus4.6 Max)

| Benchmark | Qwen3.8-27B | Qwen3.6-27B | Qwen3.7-Plus | Opus4.6 Max |
|---|---|---|---|---|
| Terminal-Bench 2.1 | 73.0 | 63.4 | 64.0 | **78.2** |
| **SWE-bench Pro** | **61.7** | 53.5 | 57.6 | 53.4 |
| DeepSWE 1.1 | **42.2** | 13.3 | 14.2 | — |
| QwenSWEBench (in-house) | **79.0** | 49.3 | 59.2 | 63.8 |
| LiveCodeBench v6 | **90.3** | 83.9 | 89.6 | 88.8 |

Note: this table doesn't use "SWE-bench Verified" (what I quoted for KAT-Coder-V2.5-Dev/Qwen3-Coder-Next/Qwen3.5-27B earlier) — it uses **SWE-bench Pro** as its headline agentic-coding metric instead. Different benchmark, and per Qwen's own footnote, they re-ran/"corrected" this specific benchmark for their comparison set — so it's not the exact same evaluation event as the other cards.

## The one metric that *is* shared across all the cards I fetched: SWE-bench Pro

| Model | SWE-bench Pro | Source |
|---|---|---|
| **Qwen3.8-27B** | **61.7** | Qwen's own card |
| KAT-Coder-V2.5-Dev | 45.96 | Kwaipilot's own card |
| Qwen3-Coder-Next | 44.3 | Qwen's own card |
| Qwen3.5-27B | 42.13 | (as reported in KAT's comparison table) |
| Qwen3.6-35B-A3B | 40.63 | (as reported in KAT's comparison table) |

On this apples-to-closest-apples metric, **Qwen3.8-27B (61.7) is well ahead of every MoE coder alternative I found (44–46 range)**, not behind them as I implied earlier.

**Caveat, to be precise rather than overclaim**: these numbers come from three different labs' self-reported evals (Qwen for Qwen3.8-27B and Qwen3-Coder-Next, Kwaipilot for KAT-Coder-V2.5-Dev), possibly different harness versions/dates, and Qwen explicitly says they "corrected problematic tasks" for their own comparison set — meaning their 61.7 might be measured against a refined benchmark subset that the other two labs' 44–46 numbers weren't run against. So this isn't a clean, controlled head-to-head; it's suggestive, not proof.

## Revised bottom line

This changes my earlier framing. On the one genuinely comparable metric across labs, Qwen3.8-27B (dense, all 27B active) is **not** losing to the 3B-active MoE alternatives — it's substantially ahead. That's actually consistent with the nuance from the last question: dense models can retain a real edge on reasoning-heavy agentic-coding tasks, and here Qwen3.8-27B's own agentic-RL training (SWE-bench Pro, DeepSWE, QwenSWEBench are all agent-harness evals) appears to have closed and then exceeded whatever throughput/efficiency advantage the MoE coder models get from their lower active-param count.

Given this, my earlier recommendation to "validate KAT-Coder-V2.5-Dev as a likely upgrade" was weaker than I stated it — the benchmark evidence, once corrected to the right model, actually favors sticking with your already-deployed and hardware-validated Qwen3.8-27B unless you have a specific reason (e.g., decode-speed-per-dollar on your exact DGX Spark, given its 3B-active alternatives should still be meaningfully faster to decode) to test further. Want me to still scope a validation feature, now framed as "confirm Qwen3.8-27B's benchmark lead survives on your own coding workloads / decode-speed budget" rather than "look for an upgrade"?

---

## User

explain this model:

https://huggingface.co/Qwen/Qwen3.8-Flash-Next

---

## Assistant (Plan · Claude Sonnet 5 · 9.3s)

_Thinking:_



**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/Qwen/Qwen3.8-Flash-Next"
}
```

**Output:**
```
                

  Qwen/Qwen3.8-Flash-Next · Hugging Face   

 [![Hugging Face's logo](/front/assets/huggingface_logo-noborder.svg) Hugging Face](/)

-   [Models](/models)
-   [Datasets](/datasets)
-   [Spaces](/spaces)
-   [Buckets new](/storage)
-   [Docs](/docs)
-   [Enterprise](/enterprise)
-   [Pricing](/pricing)
-   -   Website
        
        -   [Tasks](/tasks)
        -   [HuggingChat](/chat)
        -   [Collections](/collections)
        -   [Languages](/languages)
        -   [Organizations](/organizations)
    -   Community
        
        -   [Blog](/blog)
        -   [Posts](/posts)
        -   [Daily Papers](/papers)
        -   [Hardware](/hardware)
        -   [Learn](/learn)
        -   [Discord](/join/discord)
        -   [Forum](https://discuss.huggingface.co/)
        -   [GitHub](https://github.com/huggingface)
    -   Solutions
        
        -   [Team & Enterprise](/enterprise)
        -   [Hugging Face PRO](/pro)
        -   [Enterprise Support](/support)
        -   [Inference Providers](/inference/models)
        -   [Inference Endpoints](/inference-endpoints)
        -   [Storage Buckets](/storage)
    
-   ---
    
-   [Log In](/login)
-   [Sign Up](/join)

# 

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

](/Qwen)

[Qwen](/Qwen)

/

[Qwen3.8-Flash-Next](/Qwen/Qwen3.8-Flash-Next)

like 3.86k

Follow

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg) Qwen 101k

[

Image-Text-to-Text

](/models?pipeline_tag=image-text-to-text)[

Transformers

](/models?library=transformers)[

Safetensors

](/models?library=safetensors)[

qwen4\_exp

](/models?other=qwen4_exp)[

conversational

](/models?other=conversational)[

Eval Results

](/models?other=eval-results)

License: qwen-community-1.0

[Model card](/Qwen/Qwen3.8-Flash-Next) [Files Files and versions

xet

](/Qwen/Qwen3.8-Flash-Next/tree/main)[Community

28

](/Qwen/Qwen3.8-Flash-Next/discussions)

Deploy

Copy to bucket new

Use this model

### Instructions to use Qwen/Qwen3.8-Flash-Next with libraries, inference providers, notebooks, and local apps. Follow these links to get started.

-   Libraries
-   [Transformers](/Qwen/Qwen3.8-Flash-Next?library=transformers)
    
    How to use Qwen/Qwen3.8-Flash-Next with Transformers:
    
    \# Use a pipeline as a high-level helper
    from transformers import pipeline
    
    pipe = pipeline("image-text-to-text", model="Qwen/Qwen3.8-Flash-Next")
    messages = \[
        {
            "role": "user",
            "content": \[
                {"type": "image", "url": "https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/p-blog/candy.JPG"},
                {"type": "text", "text": "What animal is on the candy?"}
            \]
        },
    \]
    pipe(text=messages)
    
    \# Load model directly
    from transformers import AutoProcessor, AutoModelForMultimodalLM
    
    processor = AutoProcessor.from\_pretrained("Qwen/Qwen3.8-Flash-Next")
    model = AutoModelForMultimodalLM.from\_pretrained("Qwen/Qwen3.8-Flash-Next", device\_map="auto")
    messages = \[
        {
            "role": "user",
            "content": \[
                {"type": "image", "url": "https://huggingface.co/datasets/huggingface/documentation-images/resolve/main/p-blog/candy.JPG"},
                {"type": "text", "text": "What animal is on the candy?"}
            \]
        },
    \]
    inputs = processor.apply\_chat\_template(
    	messages,
    	add\_generation\_prompt=True,
    	tokenize=True,
    	return\_dict=True,
    	return\_tensors="pt",
    ).to(model.device)
    
    outputs = model.generate(\*\*inputs, max\_new\_tokens=40)
    print(processor.decode(outputs\[0\]\[inputs\["input\_ids"\].shape\[-1\]:\]))
    
-   Notebooks
-   [Google Colab](/Qwen/Qwen3.8-Flash-Next/colab)
-   [Kaggle](/Qwen/Qwen3.8-Flash-Next/kaggle)
-   Local Apps [Settings](/settings/local-apps "Set up your favorite local applications")
-   [vLLM](/Qwen/Qwen3.8-Flash-Next?local-app=vllm)
    
    How to use Qwen/Qwen3.8-Flash-Next with vLLM:
    
    ##### Install from pip and serve model
    
    \# Install vLLM from pip:
    pip install vllm
    # Start the vLLM server:
    vllm serve "Qwen/Qwen3.8-Flash-Next"
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:8000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3.8-Flash-Next",
    		"messages": \[
    			{
    				"role": "user",
    				"content": \[
    					{
    						"type": "text",
    						"text": "Describe this image in one sentence."
    					},
    					{
    						"type": "image\_url",
    						"image\_url": {
    							"url": "https://cdn.britannica.com/61/93061-050-99147DCE/Statue-of-Liberty-Island-New-York-Bay.jpg"
    						}
    					}
    				\]
    			}
    		\]
    	}'
    
    ##### Use Docker
    
    docker model run hf.co/Qwen/Qwen3.8-Flash-Next
    
-   [SGLang](/Qwen/Qwen3.8-Flash-Next?local-app=sglang)
    
    How to use Qwen/Qwen3.8-Flash-Next with SGLang:
    
    ##### Install from pip and serve model
    
    \# Install SGLang from pip:
    pip install sglang
    # Start the SGLang server:
    python3 -m sglang.launch\_server \\
        --model-path "Qwen/Qwen3.8-Flash-Next" \\
        --host 0.0.0.0 \\
        --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3.8-Flash-Next",
    		"messages": \[
    			{
    				"role": "user",
    				"content": \[
    					{
    						"type": "text",
    						"text": "Describe this image in one sentence."
    					},
    					{
    						"type": "image\_url",
    						"image\_url": {
    							"url": "https://cdn.britannica.com/61/93061-050-99147DCE/Statue-of-Liberty-Island-New-York-Bay.jpg"
    						}
    					}
    				\]
    			}
    		\]
    	}'
    
    ##### Use Docker images
    
    docker run --gpus all \\
        --shm-size 32g \\
        -p 30000:30000 \\
        -v ~/.cache/huggingface:/root/.cache/huggingface \\
        --env "HF\_TOKEN=<secret>" \\
        --ipc=host \\
        lmsysorg/sglang:latest \\
        python3 -m sglang.launch\_server \\
            --model-path "Qwen/Qwen3.8-Flash-Next" \\
            --host 0.0.0.0 \\
            --port 30000
    # Call the server using curl (OpenAI-compatible API):
    curl -X POST "http://localhost:30000/v1/chat/completions" \\
    	-H "Content-Type: application/json" \\
    	--data '{
    		"model": "Qwen/Qwen3.8-Flash-Next",
    		"messages": \[
    			{
    				"role": "user",
    				"content": \[
    					{
    						"type": "text",
    						"text": "Describe this image in one sentence."
    					},
    					{
    						"type": "image\_url",
    						"image\_url": {
    							"url": "https://cdn.britannica.com/61/93061-050-99147DCE/Statue-of-Liberty-Island-New-York-Bay.jpg"
    						}
    					}
    				\]
    			}
    		\]
    	}'
    
-   [Docker Model Runner](/Qwen/Qwen3.8-Flash-Next?local-app=docker-model-runner)
    
    How to use Qwen/Qwen3.8-Flash-Next with Docker Model Runner:
    
    docker model run hf.co/Qwen/Qwen3.8-Flash-Next
    
-   [Browse Quantizations](/models?other=base_model:quantized:Qwen/Qwen3.8-Flash-Next) to use this model in llama.cpp, Ollama, LM Studio, or any compatible app.
    

-   [Qwen3.8-Flash-Next](#qwen38-flash-next "Qwen3.8-Flash-Next")
    -   [Highlights](#highlights "Highlights")
        
    -   [Model Overview](#model-overview "Model Overview")
        
    -   [Benchmark Results](#benchmark-results "Benchmark Results")
        -   [Language](#language "Language")
        -   [Vision Language](#vision-language "Vision Language")
    -   [Quickstart](#quickstart "Quickstart")
        -   [Serving Qwen3.8-Flash-Next](#serving-qwen38-flash-next "Serving Qwen3.8-Flash-Next")
        -   [API Usage](#api-usage "API Usage")
    -   [Best Practices](#best-practices "Best Practices")
        -   [Citation](#citation "Citation")

# [](#qwen38-flash-next)Qwen3.8-Flash-Next

> This repository contains model weights and configuration files for the post-trained model in the Hugging Face Transformers format.
> 
> These artifacts are compatible with Hugging Face Transformers, vLLM, SGLang, TokenSpeed, etc.

> For users seeking managed, scalable inference without infrastructure maintenance, the official Qwen API service is provided by [Qwen Cloud](https://www.qwencloud.com).
> 
> In particular, **Qwen3.8-Flash** is the official version based on Qwen3.8-Flash-Next with more production features, e.g., 1M context length by default, official built-in tools. For more information, please refer to the [Qwen3.8-Flash Overview](https://www.qwencloud.com/models/qwen3.8-flash).

As the frontier of foundation models pushes toward ever-larger parameter counts and ever-longer context windows, the question is no longer just how much we can scale, but how efficiently we can do so. Sustainable progress toward artificial general intelligence (AGI) that benefits everyone demands architectural innovation. Today, we are sharing a concrete step in that direction: Qwen3.8-Flash-Next.

[![Qwen3.8-Flash-Next Architecture](https://qianwen-res.oss-accelerate.aliyuncs.com/Qwen3.8-Flash-Next/architecture.png)](https://qianwen-res.oss-accelerate.aliyuncs.com/Qwen3.8-Flash-Next/architecture.png)

This experimental preview of the architecture that will underpin Qwen4 is built around a fundamental rethinking of how the core components of modern large language models (LLMs) interact at scale.

## [](#highlights)Highlights

The first open-weight release under this architecture is Qwen3.8-Flash-Next, which introduces:

-   **Hybrid Attention with QSA**: The Gated DeltaNet and Gated Attention pairing has been reworked into Gated DeltaNet and Qwen Sparse Attention (QSA). Rather than selecting individual tokens for processing, QSA operates at the micro-block level. This cuts long-context latency significantly, a critical gain as agentic workloads increasingly dominate real-world usage.
-   **Gated Residual**: Residual streams with normalization are what make deep LLM training manageable. Gated Residual modulates information flowing through widened residual streams via an element-wise, data-dependent read gate and a per-branch scalar write gate. This brings finer-grained expressiveness across layers while preserving training stability and keeping inference overhead low.
-   **N-gram Embedding**: Embeddings provide a unique axis for parameter scaling that requires less computation and is more amenable to offloading than Mixture-of-Experts (MoE). By indexing with short n-grams, this approach makes parameter scaling highly efficient for memory-constrained accelerators without sacrificing quality.
-   **Tailored Training Recipe**: The Muon and AdamW optimizers are applied to specific weight categories to maximize efficiency. Guided by refitted scaling laws, we eliminate traditional batch-size warmups and start directly at the target batch size, substantially reducing total optimizer steps while safely supporting larger learning rates for robust convergence.

For more details, please refer to our blog post [Qwen3.8-Flash-Next](https://qwen.ai/blog?id=qwen3.8-flash-next) and [the technical report](https://github.com/QwenLM/Qwen3.8-Flash-Next/blob/main/tech_report.pdf).

We are excited to embark on this next chapter with you and welcome your feedback as we build what comes next.

## [](#model-overview)Model Overview

-   Type: Causal Language Model with Vision Encoder
-   Training Stage: Pre-training & Post-training
-   Language Model
    -   Number of Parameters: 125B with 6B activated, plus 51B n-gram embedding and 4B MTP
    -   Hidden Dimension: 2560
    -   Token Embedding: 248320 (Padded)
    -   N-gram Embedding: 20,000,000 (bigrams/trigrams at layer 2)
    -   Number of Layers: 48
    -   Hidden Layout: 12 × (3 × (Gated DeltaNet → MoE) → 1 × (Qwen Sparse Attention → MoE))
    -   Gated DeltaNet:
        -   Number of Linear Attention Heads: 48 for V and 16 for QK
        -   Head Dimension: 128
    -   Qwen Sparse Attention:
        -   Number of Attention Heads: 24 for Q and 2 for KV
        -   Head Dimension: 256
        -   Rotary Position Embedding Dimension: 64
        -   Indexer Structure: MQA with 4 Query Heads and 1 Shared Key Head
        -   Indexer Head Dimension: 128
        -   Budget: 512 blocks or 2048 tokens
    -   Mixture Of Experts
        -   Number of Experts: 512
        -   Number of Activated Experts: 10 Routed + 1 Shared
        -   Expert Intermediate Dimension: 640
    -   Gated Residual:
        -   Number of Branches: 4
        -   Bottleneck Rank: 320
    -   LM Output: 248320 (Padded)
    -   MTP: 1 layer, trained with multi-steps
-   Context Length: 262,144 natively and extensible up to 1,000,000 tokens.

## [](#benchmark-results)Benchmark Results

### [](#language)Language

Qwen3.8-Flash-Next

Qwen3.8-27B

Qwen3.7-Plus

DeepSeek-V4-Flash-0731

Claude-Opus-4.6 (Max)

\# Params

125B

27B

397B

284B

\--

\# Activated params

6B

27B

17B

13B

\--

\# N-gram embedding params

51B

\--

\--

\--

\--

Coding

Agentic coding

DeepSWE 1.1

**58.7**

42.2

16.5

54.4

\--

Agentic coding

SWE-bench Pro

**62.5**

61.7

55.8

56.0

53.4

Multilingual software engineering

SWE-bench Multilingual

**81.0**

73.8

75.8

\--

77.5

Repo-level code generation

NL2Repo-Bench

48.1

42.3

41.1

**54.2**

47.6

Agent

Long-horizon office work

CoWorkBench

**73.9**

70.7

65.1

45.1

68.2

Professional job tasks

JobBench

**55.7**

33.4

27.6

41.3

36.6

Frontier agentic tasks

Agents' Last Exam

Pass@1

24.3

Score

**51.2**

Pass@1

20.4

Score

42.9

Pass@1

13.2

Score

33.6

Pass@1

**25.2**

Score

\--

\--

Real-world tool use

Toolathlon Verified (Pass@1)

**73.5**

67.1

50.6

70.3

\--

General

Instruction following

IFBench

**81.3**

79.5

79.1

79.2

62.5

Scientific reasoning

GPQA Diamond

**91.7**

89.2

90.3

90.8

91.3

Multidisciplinary reasoning

HLE

35.9

30.8

34.7

33.8

**40.0**

Competitive coding

LiveCodeBench v6

**91.9**

90.3

89.6

90.6

88.8

1\. DeepSWE 1.1: evaluated with the Claude Code and mini-SWE-agent harnesses, temp=1.0, top\_p=0.95, 256K context window. We report the highest score across the two harnesses; notably, Qwen3.8-Flash-Next performs best on mini-SWE-agent.  
2\. SWE-bench Pro: except for Claude-Opus-4.6 (Max), for which we report the officially published score, all models are evaluated with the Claude Code harness, temp=1.0, top\_p=0.95, 256K context window. Problematic tasks were corrected and all baseline models were re-evaluated on the refined benchmark.  
3\. SWE-bench Multilingual: evaluated with the mini-SWE-agent harness, temp=1.0, top\_p=0.95, 256K context window.  
4\. NL2Repo-Bench: evaluated with the Claude Code harness. To prevent reward hacking, we disable Bash commands that attempt to access the specific repository, such as pip download, pip install and git clone.  
5\. CoWorkBench: an in-house cowork benchmark for evaluating long-horizon office and productivity agent tasks across computer science, finance, law, medical and other productivity domains.  
6\. HLE: judged by GPT-4o.  
7\. The best result in each row is shown in bold.  
8\. Empty cells (--): scores are not yet available or are not applicable.

### [](#vision-language)Vision Language

Qwen3.8-Flash-Next

Qwen3.8-27B

Qwen3.7-Plus

Claude-Opus-4.6 (Max)

Agentic Multimodal Intelligence

Multimodal tool use

ClawEval-MM

Pass@3

**64.4**

Average

**60.4**

Pass@3

57.4

Average

56.9

Pass@3

57.4

Average

60.1

Pass@3

52.5

Average

54.7

Application recreation

RecreationBench

**49.9**

47.1

30.2

\--

Mobile use

AndroidWorld

**84.5**

81.9

81.0

62.0

Computer use

OSWorld 2.0

Binary

**19.4**

Partial

**52.3**

Binary

19.4

Partial

48.0

Binary

2.8

Partial

21.5

\--

Visual web development

Vision2Web

**64.0**

62.9

42.1

\--

General Multimodal Intelligence

Embodied intelligence

ERQA

**72.3**

65.5

69.8

40.8

Long video understanding

LVBench

**76.6**

72.4

76.2

63.0

Real-world perception

RealWorldQA

**88.5**

85.9

86.9

73.9

Visual math problem solving

MathVision

Without CI

**90.6**

With CI

**95.7**

Without CI

90.0

With CI

94.6

Without CI

90.3

With CI

88.7

Without CI

65.5

Scientific chart analysis

CharXiv (RQ)

Without CI

84.6

With CI

**90.6**

Without CI

83.7

With CI

90.2

Without CI

**85.8**

With CI

85.9

Without CI

66.0

1\. ClawEval-MM: scores are reported as "pass@3 / average score". Pass@3 measures the percentage passed in at least one of three trials, and the average score is the mean score across the three trials.  
2\. RecreationBench: an in-house long-horizon application-recreation benchmark for evaluating hybrid-agent abilities spanning five platforms — desktop (Ubuntu, macOS, Windows), mobile (Android) and web.  
3\. OSWorld 2.0: scores are reported as "binary / partial". The binary score is the percentage of tasks that receive the full task reward, while the partial score aggregates the partial rewards obtained across all tasks.  
4\. Vision2Web: scores are reported as the average over the frontend, webpage and website categories, using the Claude Code harness and judged by gpt-5.4-2026-03-05.  
5\. MathVision, CharXiv (RQ): scores are reported as "without CI / with CI". A small number of incorrect ground-truth annotations in MathVision were corrected after manual verification. Our model's score is evaluated using a fixed prompt, e.g. "Please reason step by step, and put your final answer within \\boxed{}." For other models, we report the higher score between runs with and without the \\boxed{} formatting.  
6\. The best result in each row is shown in bold.  
7\. Empty cells (--) indicate scores not yet available or not applicable.

## [](#quickstart)Quickstart

For streamlined integration, we recommend using Qwen3.8-Flash-Next via APIs.

### [](#serving-qwen38-flash-next)Serving Qwen3.8-Flash-Next

> Inference efficiency and throughput vary significantly across frameworks. We recommend using the latest framework versions to ensure optimal performance and compatibility. For production workloads or high-throughput scenarios, dedicated serving engines such as SGLang, KTransformers or vLLM are strongly recommended.

Qwen3.8-Flash-Next can be deployed with popular inference frameworks, e.g.:

-   [SGLang](https://www.sglang.io/): [Qwen3.8-Flash-Next Cookbook](https://docs.sglang.io/cookbook/autoregressive/Qwen/Qwen3.8-Flash-Next)
-   [vLLM](https://vllm.ai/): [Qwen3.8-Flash-Next Recipe](https://recipes.vllm.ai/Qwen/Qwen3.8-Flash-Next)
-   [TokenSpeed](https://lightseek.org/tokenspeed/): [Qwen3.8-Flash-Next Recipe](https://lightseek.org/tokenspeed/recipes/models#qwen3-8-flash-next)

### [](#api-usage)API Usage

> Qwen3.8-Flash-Next models operate in thinking mode by default, generating thinking content signified by `<think>\n...</think>\n\n` before producing the final responses. To disable thinking content and obtain direct response, refer to the examples [here](#instruct-or-non-thinking-mode).

> We recommend using the following sets of sampling parameters for generation:
> 
> -   Thinking Mode: `temperature=1.0`, `top_p=0.95`, `top_k=20`, `min_p=0.0`, `presence_penalty=0.0`, `repetition_penalty=1.0`
> -   Instruct (or non-thinking) mode: `temperature=0.7`, `top_p=0.80`, `top_k=20`, `min_p=0.0`, `presence_penalty=1.5`, `repetition_penalty=1.0`
> 
> Please note that the support for sampling parameters varies according to inference frameworks.

> In multi-turn agentic tasks, lower reasoning effort does not always reduce overall task completion time. Although it may produce faster per-turn responses, it can also lead to insufficient analysis, more failures, and repeated retries, which may increase total latency and token consumption.

Qwen3.8-Flash-Next supports controlling thinking behavior via `enable_thinking`, `preserve_thinking`, and `reasoning_effort`.

#### [](#chat-completions-api)Chat Completions API

The Chat Completions API can be used with most inference frameworks, as well as [Qwen Cloud](https://www.qwencloud.com/). Before starting, make sure it is installed and the API key and the API base URL is configured, e.g.:

```shell
pip install -U openai

# Set the following accordingly
export OPENAI_BASE_URL="http://localhost:8000/v1"
export OPENAI_API_KEY="EMPTY"
```

##### [](#text-only-input)Text-Only Input

```python
from openai import OpenAI
# Configured by environment variables
client = OpenAI()

messages = [
    {"role": "user", "content": "Write a Python function to merge two sorted linked lists."},
]

completion = client.chat.completions.create(
    model="Qwen/Qwen3.8-Flash-Next",
    messages=messages,
    extra_body={
        "chat_template_kwargs": {
            "enable_thinking": True,  # on by default
            "preserve_thinking": True, # on by default
        },
    },
    reasoning_effort="xhigh",  # xhigh by default; supported levels are xhigh, medium, and low
    stream=True,
    stream_options={"include_usage": True},
)

reasoning_content = ""
answer_content = ""
is_answering = False
print("\n" + "=" * 20 + "Reasoning" + "=" * 20 + "\n")

for chunk in completion:
    if not chunk.choices:
        print("\nUsage:")
        print(chunk.usage)
        continue

    delta = chunk.choices[0].delta

    if hasattr(delta, "reasoning_content") and delta.reasoning_content is not None:
        if not is_answering:
            print(delta.reasoning_content, end="", flush=True)
        reasoning_content += delta.reasoning_content
    elif hasattr(delta, "reasoning") and delta.reasoning is not None:
        if not is_answering:
            print(delta.reasoning, end="", flush=True)
        reasoning_content += delta.reasoning

    if hasattr(delta, "content") and delta.content:
        if not is_answering:
            print("\n" + "=" * 20 + "Answer" + "=" * 20 + "\n")
            is_answering = True
        print(delta.content, end="", flush=True)
        answer_content += delta.content

messages.append({
    "role": "assistant",
    "content": answer_content,
    "reasoning_content": reasoning_content,
    "reasoning": reasoning_content,
})
```

##### [](#image-input)Image Input

```python
from openai import OpenAI
# Configured by environment variables
client = OpenAI()

messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "image_url",
                "image_url": {
                    "url": "https://qianwen-res.oss-accelerate.aliyuncs.com/Qwen3.5/demo/CI_Demo/mathv-1327.jpg"
                }
            },
            {
                "type": "text",
                "text": "The centres of the four illustrated circles are in the corners of the square. The two big circles touch each other and also the two little circles. With which factor do you have to multiply the radii of the little circles to obtain the radius of the big circles?\nChoices:\n(A) $\\frac{2}{9}$\n(B) $\\sqrt{5}$\n(C) $0.8 \\cdot \\pi$\n(D) 2.5\n(E) $1+\\sqrt{2}$"
            }
        ]
    }
]

chat_response = client.chat.completions.create(
    model="Qwen/Qwen3.8-Flash-Next",
    messages=messages,
)
print("Chat response:", chat_response)
```

##### [](#video-input)Video Input

```python
from openai import OpenAI
# Configured by environment variables
client = OpenAI()

messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "video_url",
                "video_url": {
                    "url": "https://qianwen-res.oss-accelerate.aliyuncs.com/Qwen3.5/demo/video/N1cdUjctpG8.mp4"
                }
            },
            {
                "type": "text",
                "text": "How many porcelain jars were discovered in the niches located in the primary chamber of the tomb?"
            }
        ]
    }
]

chat_response = client.chat.completions.create(
    model="Qwen/Qwen3.8-Flash-Next",
    messages=messages,
)

# When vLLM is launched with `--media-io-kwargs '{"video": {"num_frames": -1}}'`,
# video frame sampling can be configured via `extra_body` (e.g., by setting `fps`).
# This feature is currently supported only in vLLM.
#
# By default, `fps=2` and `do_sample_frames=True`.
# With `do_sample_frames=True`, you can customize the `fps` value to set your desired video sampling rate.
# chat_response = client.chat.completions.create(
#     model="Qwen/Qwen3.8-Flash-Next",
#     messages=messages,
#     extra_body={
#         "mm_processor_kwargs": {"fps": 2, "do_sample_frames": True},
#     }, 
# )

print("Chat response:", chat_response)
```

##### [](#instruct-or-non-thinking-mode)Instruct (or Non-Thinking) Mode

Qwen3.8-Flash-Next will think by default before responding. You can obtain a direct response from the model without thinking by configuring the API parameters. For example,

```python
from openai import OpenAI
# Configured by environment variables
client = OpenAI()

messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "image_url",
                "image_url": {
                    "url": "https://qianwen-res.oss-accelerate.aliyuncs.com/Qwen3.5/demo/RealWorld/RealWorld-04.png"
                }
            },
            {
                "type": "text",
                "text": "Where is this?"
            }
        ]
    }
]

chat_response = client.chat.completions.create(
    model="Qwen/Qwen3.8-Flash-Next",
    messages=messages,
    temperature=0.7,
    top_p=0.8,
    presence_penalty=1.5,
    extra_body={
        "top_k": 20,
        "chat_template_kwargs": {"enable_thinking": False},
    }, 
)
print("Chat response:", chat_response)
```

> If you are using APIs from Qwen Cloud, in addition to changing `model`, please use `"enable_thinking": False` instead of `"chat_template_kwargs": {"enable_thinking": False}`.

##### [](#disable-preserved-thinking)Disable Preserved Thinking

By default, Qwen3.8-Flash-Next retains thinking blocks from all historical messages, maintaining a complete reasoning trace across the conversation. This behavior, known as preserved thinking, ensures full context continuity and is especially beneficial for agent scenarios where decision consistency and reduced redundant reasoning are critical. It also improves KV cache utilization, optimizing inference efficiency in both thinking and non-thinking modes.

If you prefer to retain only the thinking blocks from the latest user message, you can disable this behavior by setting `preserve_thinking` to `False`:

```python
from openai import OpenAI

# Configured by environment variables
client = OpenAI()
messages = [...]
chat_response = client.chat.completions.create(
    model="Qwen/Qwen3.8-Flash-Next",
    messages=messages,
    extra_body={
        "chat_template_kwargs": {"preserve_thinking": False},
    },
)
print("Chat response:", chat_response)
```

> If you are using APIs from Qwen Cloud, in addition to changing `model`, please use `"preserve_thinking": False` directly instead of wrapping it in `chat_template_kwargs`.

## [](#best-practices)Best Practices

To achieve optimal performance, we recommend the following settings:

1.  **Sampling Parameters**: We suggest using the following sets of sampling parameters:
    
    -   Thinking Mode: `temperature=1.0`, `top_p=0.95`, `top_k=20`, `min_p=0.0`, `presence_penalty=0.0`, `repetition_penalty=1.0`
    -   Instruct (or non-thinking) mode: `temperature=0.7`, `top_p=0.80`, `top_k=20`, `min_p=0.0`, `presence_penalty=1.5`, `repetition_penalty=1.0`
    
    For supported frameworks, you can adjust the `presence_penalty` parameter between 0 and 2 to reduce endless repetition. However, using a higher value may occasionally result in language mixing and a slight decrease in model performance.
    
2.  **Adequate Output Length**: To optimize performance on agentic tasks, we recommend allocating sufficient output length to allow the model to generate detailed and comprehensive responses. For frameworks that support separate token limits for internal reasoning and final outputs, we suggest the following configuration within the 1M context length:
    
    -   Reasoning Content: Set the maximum output length to 262,144 tokens.
    -   Final Response: Set the maximum output length to 131,072 tokens.
    
    These settings provide the necessary capacity for complex reasoning while ensuring ample space for high-quality final deliverables.
    
3.  **Processing Ultra-Long Texts**: Qwen3.8-Flash-Next natively supports context lengths of up to 262,144 tokens. For long-horizon tasks where the total length (including both input and output) exceeds this limit, we recommend using RoPE scaling techniques to handle long texts effectively, e.g., YaRN.
    
    YaRN is currently supported by several inference frameworks, e.g., vLLM, SGLang, and TokenSpeed. In general, there are two approaches to enabling YaRN for supported frameworks:
    
    -   Modifying the model configuration file:
        
        In the `config.json` file, change the `rope_parameters` fields in `text_config` to:
        
        ```json
        {
            "mrope_interleaved": true,
            "mrope_section": [
                11,
                11,
                10
            ],
            "rope_type": "yarn",
            "rope_theta": 10000000,
            "partial_rotary_factor": 0.25,
            "factor": 4.0,
            "original_max_position_embeddings": 262144
        }
        ```
        
    -   Passing command line arguments:
        
        For vLLM, you can use
        
        ```shell
        VLLM_ALLOW_LONG_MAX_MODEL_LEN=1 vllm serve ... --hf-overrides '{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 4.0, "original_max_position_embeddings": 262144}}}' --max-model-len 1000000  
        ```
        
        For SGLang, you can use
        
        ```shell
        SGLANG_ALLOW_OVERWRITE_LONGER_CONTEXT_LEN=1 python -m sglang.launch_server ... --json-model-override-args '{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 4.0, "original_max_position_embeddings": 262144}}}' --context-length 1000000
        ```
        
        For TokenSpeed, you can use
        
        ```shell
        TOKENSPEED_ALLOW_OVERWRITE_LONGER_CONTEXT_LEN=1 tokenspeed serve ... --hf-overrides '{"text_config": {"rope_parameters": {"mrope_interleaved": true, "mrope_section": [11, 11, 10], "rope_type": "yarn", "rope_theta": 10000000, "partial_rotary_factor": 0.25, "factor": 4.0, "original_max_position_embeddings": 262144}}}' --max-model-len 1000000  
        ```
        
    
    > All the notable open-source frameworks implement static YaRN, which means the scaling factor remains constant regardless of input length, **potentially impacting performance on shorter texts.** We advise modifying the `rope_parameters` configuration only when processing long contexts is required. It is also recommended to modify the `factor` as needed. For example, if the typical context length for your application is 524,288 tokens, it would be better to set `factor` as 2.0.
    
4.  **Long Video Understanding**: To optimize inference efficiency for plain text and images, the `size` parameter in the released `video_preprocessor_config.json` is conservatively configured. It is recommended to set the `longest_edge` parameter in the video\_preprocessor\_config file to 469,762,048 (corresponding to 224k video tokens) to enable higher frame-rate sampling for hour-scale videos and thereby achieve superior performance. For example,
    
    ```json
    {"longest_edge": 469762048, "shortest_edge": 4096}
    ```
    
    Alternatively, override the default values via engine startup parameters. For implementation details, refer to: [vLLM](https://github.com/vllm-project/vllm/pull/34330) / [SGLang](https://github.com/sgl-project/sglang/pull/18467).
    

### [](#citation)Citation

If you find our work helpful, feel free to give us a cite.

```bibtex
@techreport{qwen2026design,
    title       = {On the Design of {Qwen3.8-Next} Architecture: Evaluation, Efficiency, and Training Stability},
    author      = {{Qwen Team}},
    institution = {Alibaba Group},
    month       = {August},
    year        = {2026}
}

@misc{qwen3.8flashnext,
    title  = {{Qwen3.8-Flash-Next}: A New Architecture, Towards Ultimate Cost-Efficiency},
    author = {{Qwen Team}},
    month  = {August},
    year   = {2026},
    url    = {https://qwen.ai/blog?id=qwen3.8-flash-next}
}
```

Downloads last month

4,810

Safetensors[](https://huggingface.co/docs/safetensors)

Model size

180B params

Tensor type

BF16

·

I64

·

Chat template

Files info

Inference Providers [NEW](https://huggingface.co/docs/inference-providers)

[

Image-Text-to-Text

](/tasks/image-text-to-text "Learn more about image-text-to-text")

This model isn't deployed by any Inference Provider. [🙋 38 Ask for provider support](/spaces/huggingface/InferenceSupport/discussions/11985)

## Model tree for Qwen/Qwen3.8-Flash-Next[](/docs/hub/model-cards#specifying-a-base-model)

Finetunes

[15 models](/models?other=base_model:finetune:Qwen/Qwen3.8-Flash-Next)

Quantizations

[](/models?apps=llama.cpp&other=base_model:quantized:Qwen/Qwen3.8-Flash-Next "Use with llama.cpp")[](/models?apps=lmstudio&other=base_model:quantized:Qwen/Qwen3.8-Flash-Next "Use with LM Studio")[](/models?apps=jan&other=base_model:quantized:Qwen/Qwen3.8-Flash-Next "Use with Jan")[](/models?apps=ollama&other=base_model:quantized:Qwen/Qwen3.8-Flash-Next "Use with Ollama")

[69 models](/models?other=base_model:quantized:Qwen/Qwen3.8-Flash-Next)

## Spaces using Qwen/Qwen3.8-Flash-Next 3

[

⚡

victor/Qwen3.8-Flash-Next-free-endpoint

](/spaces/victor/Qwen3.8-Flash-Next-free-endpoint)[

⚡

NodeLinker/Qwen3.8-Flash-Next-Free-Chat

](/spaces/NodeLinker/Qwen3.8-Flash-Next-Free-Chat)[

⚡

bored10/qwen3-8-flash-next-demo

](/spaces/bored10/qwen3-8-flash-next-demo)

## Collection including Qwen/Qwen3.8-Flash-Next

[

#### Qwen3.8-Flash-Next

Collection

2 items • Updated 1 day ago • 30

](/collections/Qwen/qwen38-flash-next)

## Evaluation results[](https://huggingface.co/docs/hub/eval-results)

-   [Idavidrein/gpqa](/datasets/Idavidrein/gpqa) · Diamond [View evaluation results](/Qwen/Qwen3.8-Flash-Next/discussions/12) [leaderboard](/datasets/Idavidrein/gpqa?eval_result=Qwen/Qwen3.8-Flash-Next&leaderboard_task_id=diamond)
    
    [](/datasets/Idavidrein/gpqa?eval_result=Qwen%2FQwen3.8-Flash-Next&leaderboard_task_id=diamond&leaderboard_max_params=500B)91.7
    
-   [datacurve/deep-swe](/datasets/datacurve/deep-swe) · Deep Swe [View evaluation results](/Qwen/Qwen3.8-Flash-Next/discussions/12) [leaderboard](/datasets/datacurve/deep-swe?eval_result=Qwen/Qwen3.8-Flash-Next&leaderboard_task_id=deep_swe)
    
    [](/datasets/datacurve/deep-swe?eval_result=Qwen%2FQwen3.8-Flash-Next&leaderboard_task_id=deep_swe)58.7 \*
    
-   [ScaleAI/SWE-bench\_Pro](/datasets/ScaleAI/SWE-bench_Pro) · SWE Bench Pro [View evaluation results](/Qwen/Qwen3.8-Flash-Next/discussions/12) [leaderboard](/datasets/ScaleAI/SWE-bench_Pro?eval_result=Qwen/Qwen3.8-Flash-Next&leaderboard_task_id=SWE_Bench_Pro)
    
    [](/datasets/ScaleAI/SWE-bench_Pro?eval_result=Qwen%2FQwen3.8-Flash-Next&leaderboard_task_id=SWE_Bench_Pro)62.5 \*
    
-   [SWE-bench/SWE-bench\_Multilingual](/datasets/SWE-bench/SWE-bench_Multilingual) · Swe Bench Multilingual Resolved [View evaluation results](/Qwen/Qwen3.8-Flash-Next/discussions/12) [leaderboard](/datasets/SWE-bench/SWE-bench_Multilingual?eval_result=Qwen/Qwen3.8-Flash-Next&leaderboard_task_id=swe_bench_multilingual_%_resolved)
    
    [](/datasets/SWE-bench/SWE-bench_Multilingual?eval_result=Qwen%2FQwen3.8-Flash-Next&leaderboard_task_id=swe_bench_multilingual_%25_resolved)81 \*
    
-   [cais/hle](/datasets/cais/hle) · Hle [View evaluation results](/Qwen/Qwen3.8-Flash-Next/discussions/12)
    
    35.9 \*
    
-   [claw-eval/Claw-Eval](/datasets/claw-eval/Claw-Eval) · Multimodal [View evaluation results](/Qwen/Qwen3.8-Flash-Next/discussions/12) [leaderboard](/datasets/claw-eval/Claw-Eval?eval_result=Qwen/Qwen3.8-Flash-Next&leaderboard_task_id=multimodal)
    
    [](/datasets/claw-eval/Claw-Eval?eval_result=Qwen%2FQwen3.8-Flash-Next&leaderboard_task_id=multimodal)64.4 \*
    

System theme

Company

[TOS](/terms-of-service) [Privacy](/privacy) [About](/huggingface) [Careers](https://apply.workable.com/huggingface/)[](/)

Website

[Models](/models) [Datasets](/datasets) [Spaces](/spaces) [Pricing](/pricing) [Docs](/docs)
```

---

## Assistant (Plan · Claude Sonnet 5 · 80.0s)

_Thinking:_



## Qwen3.8-Flash-Next: an experimental preview of the next-generation "Qwen4" architecture

This is a genuinely different beast from everything else we've discussed — not an incremental coder fine-tune, but Qwen's public preview of **the architecture that will underpin Qwen4**. It swaps out several core building blocks of the transformer, not just the training recipe.

### Model facts

- **License: `qwen-community-1.0`** — not Apache-2.0 like Qwen3.8-27B/Qwen3-Coder. Worth reading the actual terms before adopting; it's a different (likely more restrictive) license class than everything else we've looked at.
- **Total footprint: 180B params** = 125B main model (6B activated per token) + **51B n-gram embedding** + 4B MTP head.
- **Native context**: 262,144 → extensible to 1,048,576 via the same YaRN `rope_parameters` mechanism as Qwen3.8-27B.
- Native vision-language model (image + video), thinking-mode controls (`enable_thinking`/`preserve_thinking`/`reasoning_effort`), MTP speculative decoding built in — same agent-friendly surface as Qwen3.8-27B.

### The four architectural changes it introduces

1. **Qwen Sparse Attention (QSA)** replaces the previous "Gated Attention" half of the hybrid layout. Instead of picking individual tokens to attend to, it operates at the **micro-block level** (budget: 512 blocks / 2048 tokens via an MQA-style indexer) — aimed squarely at cutting long-context latency for agentic workloads. This is the direct evolution of the mechanism that made Qwen3.8-27B's long-context serving viable at all.
2. **Gated Residual**: the residual stream itself becomes data-dependent — an element-wise read gate plus a per-branch scalar write gate across 4 branches. More per-layer expressiveness without blowing up inference cost.
3. **N-gram Embedding (51B params)**: this is the interesting one for your hardware questions. Instead of adding capacity via more MoE experts, they add a **51B-parameter lookup table indexed by bigrams/trigrams**. The model card explicitly frames this as "**more amenable to offloading than MoE**" — i.e., it's a cheap, sparse-lookup way to add raw knowledge capacity that doesn't need to sit in your fastest/most expensive memory tier, unlike dense FFN or expert weights which need to be read and multiplied every forward pass.
4. **Muon+AdamW split training recipe** with no batch-size warmup — a training-efficiency change, not something that affects serving.

### How it benchmarks (its own card, vs. Qwen3.8-27B/Qwen3.7-Plus/DeepSeek-V4-Flash/Claude-Opus-4.6)

| Benchmark | Qwen3.8-Flash-Next (6B active) | Qwen3.8-27B (27B active, dense) |
|---|---|---|
| SWE-bench Pro | **62.5** | 61.7 |
| SWE-bench Multilingual | **81.0** | 73.8 |
| DeepSWE 1.1 | **58.7** | 42.2 |
| CoWorkBench | **73.9** | 70.7 |
| JobBench | **55.7** | 33.4 |
| LiveCodeBench v6 | **91.9** | 90.3 |

It beats your currently-deployed Qwen3.8-27B on essentially every agentic-coding metric — **using 6B active params instead of 27B fully-dense**. If that benchmark lead holds up under independent testing, this is architecturally exactly the "MoE efficiency wins" story from two questions ago, done one generation further.

### Why it's a poor fit for your DGX Spark (120GB unified, 768K target) specifically

- **180B total params is too big for that box, full stop.** Even at aggressive NVFP4 (~0.5 bytes/param), weights alone are ~90GB — leaving only ~30GB of your ~120GB pool for KV cache + OS headroom. Given `feat-3`'s own measurement that a 27B model's KV cache at 896K needed ~33GB just by itself, this almost certainly can't hit 768K on a single DGX Spark, even quantized hard.
- **The n-gram embedding's whole selling point — "cheap to offload" — doesn't help you here.** That trick is designed for boxes with a *separate*, slow-but-huge memory tier to offload into (discrete GPU VRAM + a large separate system RAM pool). DGX Spark has one unified pool; there's no cheap tier to push the 51B embedding into. It only pays off on a box shaped like your **Dell 7960T** (384GB discrete VRAM + 512GB *separate* system RAM) — which is coincidentally the exact hybrid-memory shape your `feat-1` already reserved for DeepSeek-V4-Pro via ktransformers.
- **Brand-new, unshipped kernels**: QSA and Gated Residual are novel ops with essentially zero track record — expect rough/absent vLLM-SGLang support for months, and near-certainly no arm64/SM121a (DGX Spark) validation yet, on top of no verified NVFP4 checkpoint existing yet (unlike Qwen3.8-27B's `unsloth/Qwen3.8-27B-NVFP4`).
- Non-Apache license adds a real adoption question independent of the technical fit.

### Where it's actually interesting for you

Not the DGX Spark — **your Dell 7960T's still-open DeepSeek-V4-Pro slot** (`feat-1`, "ktransformers, GPU+CPU-RAM hybrid MoE"). Qwen3.8-Flash-Next's whole design (6B active MoE + a 51B param block purpose-built for offload to slower memory) is a closer architectural match to that hybrid-serving story than DeepSeek-V4-Pro itself, *if* ktransformers/vLLM ships support for it. That would need its own validation spike, not a swap-in — this is a preview release, not something to build production plans around yet.

Want me to note this as a candidate/watch item in `feat-1`'s README, or leave it as discussion for now?

---

## User

ok, create a new feature for this https://huggingface.co/Qwen/Qwen3.8-Flash-Next to be installed on the Dell 7960T.

---

## Assistant (Plan · Claude Sonnet 5 · 38.1s)

_Thinking:_



**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-1-deepseek-v4-onprem-deployment/README.md"
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-1-deepseek-v4-onprem-deployment/README.md</path>
<type>file</type>
<content>
1: ---
2: created: 2026-08-18
3: github_issue: 1
4: id: feat-1-deepseek-v4-onprem-deployment
5: status: planning
6: updated: 2026-08-19
7: version: 1.0.0
8: ---
9: 
10: # Feature: On-prem DeepSeek-V4-Flash/Pro serving for OpenCode + OpenWebUI
11: 
12: ## Plan
13: 
14: ### Overview
15: 
16: Deploy DeepSeek-V4-Flash and DeepSeek-V4-Pro on existing on-prem hardware,
17: each behind an OpenAI-compatible API, for use as coding models via OpenCode
18: and OpenWebUI. Quality is the priority over speed. Ollama's library-listed
19: `deepseek-v4-flash`/`deepseek-v4-pro` are cloud-proxy tags only (no local
20: weights) and are explicitly not used; official MIT-licensed weights from
21: `deepseek-ai/DeepSeek-V4-Flash`/`-Pro` on Hugging Face are loaded directly
22: instead, pinned to a specific revision for reproducibility.
23: 
24: ### Requirements
25: 
26: - REQ-001: Serve DeepSeek-V4-Flash via an OpenAI-compatible API
27:   (`/v1/chat/completions`) on the Dell 7960T (4x RTX Pro 6000 Blackwell
28:   Max-Q, 96GB each = 384GB VRAM; 512GB system RAM)
29: - REQ-002: Serve DeepSeek-V4-Pro via an OpenAI-compatible API on the same
30:   Dell 7960T, without adding new hardware and without networking in the
31:   DGX Spark
32: - REQ-003: Both endpoints must support real coding workloads reaching
33:   350-370K tokens of context
34: - REQ-004: Both endpoints must support tool-calling (required for OpenCode
35:   agentic use) and expose DeepSeek-V4's think/non-think/max-think reasoning
36:   modes correctly
37: - REQ-005: Maximize model quality; inference speed is explicitly secondary
38: - REQ-006: No third-party GGUF requantization — load official weights
39:   directly to avoid an extra, unverified source of quality loss
40: - REQ-007: Pin both models to a specific Hugging Face revision/commit
41:   (not "latest") for reproducibility across redeploys
42: - REQ-008: Both endpoints run unauthenticated (anonymous, no API-key/auth
43:   layer) — accepted risk, internal network only
44: - REQ-009: Both engines run as managed services (systemd units or
45:   equivalent), started/stopped via the service manager — no ad-hoc
46:   foreground processes, including during testing
47: 
48: ### Acceptance Criteria
49: 
50: - [ ] ACC-001: Verifies REQ-001 — `vllm serve deepseek-ai/DeepSeek-V4-Flash`
51:   running with tensor-parallel=4 on the Dell 7960T, reachable via
52:   `/v1/chat/completions`
53: - [ ] ACC-002: Verifies REQ-002 — ktransformers serving
54:   `deepseek-ai/DeepSeek-V4-Pro` on the same box, reachable via its
55:   OpenAI-compatible endpoint
56: - [ ] ACC-003: Verifies REQ-003 — empirical test confirms both endpoints
57:   handle a 350-370K-token coding prompt without OOM
58: - [ ] ACC-004: Verifies REQ-004 — tool-call and reasoning-mode output
59:   verified via curl smoke test, then via a real OpenCode agentic session
60: - [ ] ACC-005: Verifies REQ-005 — Flash runs with FP8 experts (upgraded
61:   from native FP4+FP8 mixed) if vLLM's loader supports the override;
62:   Pro's exact quantization level is chosen empirically to leave headroom
63:   for REQ-003's context requirement
64: - [ ] ACC-006: Verifies REQ-006 — both engines load weights directly from
65:   `deepseek-ai/DeepSeek-V4-Flash`/`-Pro` on Hugging Face, no GGUF requant
66: - [ ] ACC-007: Verifies REQ-007 — deployment config records the exact HF
67:   revision/commit hash used for each model
68: - [ ] ACC-008: Verifies REQ-008 — endpoints reachable without credentials
69:   from the internal network, confirmed intentional (not an oversight)
70: - [ ] ACC-009: Verifies REQ-009 — both engines installed as systemd
71:   services; started/stopped/restarted exclusively via `systemctl`
72:   throughout testing and production use
73: - [ ] ACC-010: User runs their own existing coding-task examples against
74:   both endpoints once setup is complete; same examples reused later to
75:   compare quality across future implementations (e.g. GLM-5.2)
76: 
77: ### Scope
78: 
79: What is included in this feature:
80: 
81: - vLLM deployment of DeepSeek-V4-Flash on the Dell 7960T, as a systemd
82:   service
83: - ktransformers deployment of DeepSeek-V4-Pro on the Dell 7960T, as a
84:   systemd service
85: - OpenWebUI and OpenCode configured against both endpoints
86: - Empirical KV-cache/context validation for both models
87: - Pinning both models to a fixed HF revision
88: 
89: What is explicitly out of scope:
90: 
91: - Any use of the DGX Spark for this deployment (explicitly excluded by
92:   user decision)
93: - Any use of Ollama's cloud-tagged library models
94: - Any GGUF/community requantization path
95: - Acquiring additional hardware for DeepSeek-V4-Pro
96: - Authentication/access-control layer (explicitly accepted as anonymous)
97: - GLM-5.2 fallback deployment — tracked as a separate, future feature
98: 
99: ### Dependencies
100: 
101: - Depends on: confirmed vLLM version with merged DeepSeek-V4 tool-call/
102:   reasoning-parser support; confirmed ktransformers version with
103:   DeepSeek-V4 architecture support; GPU driver/CUDA compatibility for RTX
104:   Pro 6000 Blackwell; sufficient local disk space (1TB+) on the Dell
105:   7960T for both model weight sets
106: - Blocks: none
107: - Related (not a dependency, tracked separately):
108:   `feat-2-glm-5.2-onprem-deployment` deploys GLM-5.2 as a fallback/
109:   alternative model — not part of this feature's scope. Its Phase 1 SM120
110:   sparse-attention correctness spike and this feature's Task 1.4 diagnostic
111:   inform each other (both hit the same SM120 sparse-attention-decode kernel
112:   class).
113: 
114: ### Design Notes
115: 
116: - Two independent serving engines by design: vLLM for Flash (fits fully
117:   in VRAM, gets native DeepSeek-V4 tool-call/reasoning-parser support),
118:   ktransformers for Pro (purpose-built GPU+CPU-RAM hybrid MoE inference,
119:   needed because Pro's ~800GB+ native footprint doesn't fit in 384GB VRAM
120:   alone).
121: - Precision tradeoff resolved: for Pro, user explicitly accepted lower
122:   precision (below native FP4+FP8 mixed) in exchange for guaranteed
123:   350-370K context headroom, since both cannot fit simultaneously in the
124:   896GB VRAM+RAM pool at native precision. Exact quant level to be
125:   determined empirically (measure real KV-cache cost per 1K tokens first,
126:   then pick the lightest trim that leaves safe margin — not the tightest
127:   possible fit).
128: - For Flash, FP8-expert override is the target (vs. native FP4 experts)
129:   since the resulting ~284GB footprint still fits comfortably in 384GB
130:   VRAM with headroom for the required context; fallback to native FP4+FP8
131:   mixed if vLLM's loader doesn't expose the override.
132: - DGX Spark intentionally left out of this feature's scope per explicit
133:   user decision (no cross-node networking between DGX Spark and Dell
134:   7960T).
135: - Both models pinned to a specific HF revision at deployment time, not
136:   tracking "latest" — avoids unexpected drift on redeploy, given DeepSeek
137:   appears to ship rolling checkpoint updates (observed `preview` →
138:   `0731`/`0813`-dated snapshots).
139: - No authentication layer: both OpenAI-compatible endpoints are
140:   reachable anonymously on the internal network. Accepted risk, not an
141:   oversight — revisit only if network exposure changes.
142: - Both engines run exclusively as systemd-managed services (or
143:   equivalent service manager) — start/stop/restart via `systemctl`, even
144:   during initial testing, never as manually-launched foreground
145:   processes.
146: - Benchmark approach: no synthetic/formal benchmark suite defined here.
147:   User will run their own existing real coding-task examples once each
148:   endpoint is live, and reuse the same examples later to compare quality
149:   across future alternatives (e.g. GLM-5.2).
150: 
151: ### Related ADRs
152: 
153: - None (this is infrastructure/deployment work, tracked in its own repo
154:   using the feature-folder convention documented in biz.dfch.SpecMgr's
155:   ADR e369ee2e-3353-4f92-991c-6367d76d832e)
156: 
157: ### Task List
158: 
159: #### Phase 0: Environment prep
160: 
161: - [x] Task 0.1: Validate available local disk space on the Dell 7960T (need 1TB+ free for both weight sets combined) — depends on: none — status: completed (2026-08-18: /data has 9.3 TB free)
162: - [x] Task 0.2: Verify GPU driver/CUDA version compatibility with RTX Pro 6000 Blackwell across all 4 GPUs — depends on: none — status: completed (2026-08-18: 4 GPUs detected, driver 610.57.04, CUDA 13.3, 384 GB VRAM total; GRUB + modprobe fixes applied; GPU 0 has ollama using 43 GB, GPUs 1-3 free)
163: - [x] Task 0.3: Set up Hugging Face access/token and download tooling — depends on: none — status: completed (2026-08-18: HF CLI logged in as appclusive; hf_transfer installed via uv)
164: - [x] Task 0.4: Choose and record pinned HF revision/commit for `deepseek-ai/DeepSeek-V4-Flash` — depends on: Task 0.3 — status: completed (2026-08-18: pinned to 60d8d70770c6776ff598c94bb586a859a38244f1 from main branch, dated 2026-06-22)
165: - [x] Task 0.5: Choose and record pinned HF revision/commit for `deepseek-ai/DeepSeek-V4-Pro` — depends on: Task 0.3 — status: completed (2026-08-18: pinned to b5968e9190ef611bbf34a7229255be88a0e937c1 from main branch, dated 2026-06-22)
166: - [x] Task 0.6: Download DeepSeek-V4-Flash weights at the pinned revision — depends on: Task 0.4, Task 0.1 — status: completed (2026-08-18: 46/46 shards, 186 GB at /data/nvidia/hf_cache/hub/models--deepseek-ai--DeepSeek-V4-Flash)
167: - [x] Task 0.7: Download DeepSeek-V4-Pro weights at the pinned revision — depends on: Task 0.5, Task 0.1 — status: completed (2026-08-19: all 64 shards downloaded to /data/nvidia/hf_cache/hub/models--deepseek-ai--DeepSeek-V4-Pro)
168: 
169: #### Phase 1: DeepSeek-V4-Flash (vLLM)
170: 
171: - [x] Task 1.1: Confirm vLLM version/build with merged DeepSeek-V4 tool-call and reasoning parsers — depends on: none — status: completed (2026-08-18: vLLM 0.26.0 has DeepSeek-V4 model, tokenizer, tool parser (deepseek_v4), reasoning parser (deepseek_v4), FP8 quant config with expert_dtype detection; --hf-overrides available for expert_dtype override)
172: - [x] Task 1.2: Verify whether vLLM's `deepseek_v4` loader honors an FP8-expert override (vs. native FP4 experts) — depends on: Task 1.1 — status: completed (2026-08-18: verified via --hf-overrides '{"expert_dtype": "fp8"}'; quant config resolves to fp8 when vllm_config context active)
173: - [x] Task 1.3: Install vLLM + DeepSeek-V4-Flash as a systemd service (tensor-parallel=4) on the Dell 7960T — depends on: Task 1.2, Task 0.6 — status: completed (2026-08-18: service at /etc/systemd/system/vllm-deepseek-v4-flash.service now starts reliably, stays up under `systemctl`, and serves HTTP. Reached only after fixing a chain of 7 distinct bugs, in order: (1) `KillMode=process` left orphaned GPU-memory-holding workers behind after a start-timeout kill, causing every subsequent attempt to fail on insufficient free VRAM — fixed via `KillMode=control-group` + `TimeoutStartSec=3600` (script `bin/00-fix-vllm-flash-service.sh`); (2) every startup silently hung on an outbound Hugging Face network call (`snapshot_download`/Xet backend) despite weights being fully local — fixed via `HF_HUB_OFFLINE=1`/`TRANSFORMERS_OFFLINE=1` (`bin/02-fix-vllm-flash-offline.sh`); (3) `--hf-overrides '{"expert_dtype":"fp8"}'` hit a real vLLM TP-sharding bug in the MoE weight loader (`tensor a (32) != tensor b (128)`, i.e. `128 experts / tp_size(4)`) — fixed by dropping the override and falling back to the model's native FP4+FP8 mixed expert precision, the contingency already called out in Design Notes (`bin/03-fallback-native-quant.sh`); (4) the venv's pip-installed CUDA component wheels were version-skewed (`nvidia-cuda-nvcc`/`-crt`/`-cccl` on 13.3.x vs `-runtime`/`-nvrtc`/`-cupti` still on 13.0.x), breaking TileLang's nvcc JIT compiles — fixed by upgrading the latter three to 13.3.x (`bin/04-fix-cuda-toolkit-skew.sh`); (5) the systemd unit had no `PATH`, so `ninja` (needed for JIT-compiled CUDA extensions) couldn't be found even though it was installed — fixed by adding `PATH=/data/vllm/.venv/bin:...` (`bin/05-fix-missing-venv-path.sh`); (6) `--attention-backend FLASHMLA_SPARSE_DSV4` has a confirmed, unconditional gap for `sm_120` GPUs (ours) in this vLLM build — its tile-scheduler builder intentionally returns all-`None` on SM120, but the FlashMLA decode path asserts on it anyway — ... (line truncated to 2000 chars)
174: - [ ] Task 1.4: `systemctl start` the service; curl smoke test against `/v1/chat/completions`, verify tool-calls and think/non-think output — depends on: Task 1.3 — status: blocked (2026-08-18: service starts and responds over HTTP with `finish_reason: length`, but generated output is degenerate garbage, not a crash. At temperature=1 output is token noise mixing many scripts/languages; at temperature=0 (greedy) every single decode position returns the exact same special token (`<|begin▁of▁sentence|>`) with the exact identical logprob (-11.7697...) regardless of position/context — a strong signature of a broken forward pass (e.g. sparse-attention decode returning zeroed/garbage context), not a sampling or tokenizer issue. Ruled out CUDA-graph capture as the cause via `--enforce-eager` (`bin/08-diag-enforce-eager.sh`): identical degenerate output with graphs fully disabled. Remaining suspects: the `FLASHINFER_MLA_SPARSE_DSV4` SM120 sparse-MLA decode kernel path (needed per Task 1.3 fix #6, since the alternative `FLASHMLA_SPARSE_DSV4` backend is unconditionally broken on our `sm_120` GPUs in this vLLM build) and/or the native FP4+FP8 mixed quantization fallback (needed per Task 1.3 fix #3) and/or missing fp8 kv-cache scaling factors (vLLM logs its own warning: "may cause accuracy drop without a proper scaling factor"). A true `--tensor-parallel-size 1` isolation test is infeasible: native-precision weights are ~152 GB total (38 GB/GPU × 4), which doesn't fit on one ~95 GB GPU. Needs upstream vLLM/FlashInfer investigation, a different vLLM/FlashInfer version, or a `--tensor-parallel-size 2` isolation test (feasible but weaker signal, not yet tried) before this can be unblocked. UPDATE 2026-08-18 evening: researched and verified (via direct GitHub fetches, not just an LLM research summary) several open upstream vLLM issues matching this hardware/model combo — vLLM #47528 (DeepSeek-V4-Pro garbled under TP, correct under DP+EP), #50720 (FlashInfer SM120 sparse-MLA decode d... (line truncated to 2000 chars)
175: - [ ] Task 1.5: Connect OpenWebUI and OpenCode to the Flash endpoint — depends on: Task 1.4 — status: not-started
176: - [ ] Task 1.6: Validate 350-370K-token context works without OOM — depends on: Task 1.5 — status: not-started
177: - [ ] Task 1.7: User runs their real coding-task examples against the endpoint — depends on: Task 1.6 — status: not-started
178: 
179: #### Phase 2: DeepSeek-V4-Pro (ktransformers)
180: 
181: - [ ] Task 2.1: Confirm ktransformers version with DeepSeek-V4 architecture support and OpenAI-compatible API — depends on: none — status: not-started
182: - [ ] Task 2.2: Install ktransformers + DeepSeek-V4-Pro as a systemd service at native FP4+FP8 mixed precision, measure actual KV-cache memory per 1K tokens at real context shapes — depends on: Task 2.1, Task 0.7 — status: not-started
183: - [ ] Task 2.3: Choose the lightest precision trim that reliably supports 350-370K context with safe margin, based on Task 2.2 measurements — depends on: Task 2.2 — status: not-started
184: - [ ] Task 2.4: Reconfigure the service with the chosen precision and ktransformers per-layer GPU/RAM placement — depends on: Task 2.3 — status: not-started
185: - [ ] Task 2.5: `systemctl start`/restart the service; verify tool-calling and reasoning-mode behavior — depends on: Task 2.4 — status: not-started
186: - [ ] Task 2.6: Connect OpenWebUI and OpenCode to the Pro endpoint as a separate model entry — depends on: Task 2.5 — status: not-started
187: - [ ] Task 2.7: User runs the same coding-task examples from Task 1.7 against this endpoint for comparison — depends on: Task 2.6 — status: not-started
188: 
189: **Note:** If a task's scope changes mid-flight, edit its description in place;
190: rely on git history (`git log -p` on this file) to recover what was
191: originally planned, rather than keeping a second copy of the task around.
192: 
193: ## Progress
194: 
195: ### Current Status
196: 
197: **As of 2026-08-19 (end of session)**: Phase 0 complete (Task 0.7 Pro
198: download finished — all 64 shards at
199: `/data/nvidia/hf_cache/hub/models--deepseek-ai--DeepSeek-V4-Pro`). Phase 1:
200: Task 1.3 (systemd service) complete after a 7-bug crash-loop debugging
201: session. **Task 1.4 remains blocked** on a model-output correctness bug
202: (identical argmax token + identical logprob at every decode position,
203: temperature=0) — every locally-testable hypothesis has now been
204: systematically ruled out: CUDA-graph capture, the TP-vs-DP+EP execution
205: path, torch.compile fusion passes, a stale vLLM/flashinfer version
206: (0.27.1/0.6.17 hits an unrelated hard SM120/DeepGEMM gap), fp8 KV-cache
207: scaling factors (fp8 KV-cache is architecturally required by this vLLM
208: build's `fp8_ds_mla` layout, not tunable), and environment/in-place-patch
209: contamination (a from-scratch clean venv, verified package-by-package
210: against production, reproduces the identical byte-for-byte signature). All
211: local diagnostics exhausted; **escalated upstream** — filed
212: https://github.com/vllm-project/vllm/issues/52938 after a fresh dedup pass
213: against the closest known issues, none of which match this exact
214: non-crashing frozen-token signature. Both the diagnostic clean-venv
215: service and the production service are currently **stopped** (idle GPUs,
216: no leftover processes) pending upstream response or a decision on next
217: steps (alternate vLLM/flashinfer version, or pivot to Phase 2). Phase 2
218: (Pro/ktransformers) is fully unblocked (Task 0.7 done) but not yet started.
219: 
220: ### Next Steps
221: 
222: 1. ~~Execute the Task 1.4 unblock plan (`bin/16`-`bin/20`)~~ — **COMPLETE**,
223:    both local hypotheses ruled out:
224:    1. ~~`bin/16-snapshot-baseline.sh`~~ — DONE (2026-08-19T09:10:23Z): baseline
225:       captured to `bin/baselines/2026-08-19T09:10:23Z-degenerate.txt`,
226:       confirmed byte-for-byte matching the known degenerate signature
227:       (`<｜begin▁of▁sentence｜>` at logprob `-11.769736289978027` for all 10
228:       positions).
229:    2. ~~Track A: `bin/17-diag-no-fp8-kvcache.sh`~~ — RULED OUT
230:       (2026-08-19T09:1x-11:36Z): fp8 KV-cache is a hard architectural
231:       requirement of the `fp8_ds_mla` attention layout used by
232:       `FLASHINFER_MLA_SPARSE_DSV4` on this vLLM build, not a tunable
233:       precision knob — confirmed via a hard `AssertionError` at model-init,
234:       not an inconclusive test. See Task 1.4 note for the crash-loop/revert
235:       detail (`bin/21-revert-fp8-kvcache-crashloop.sh`).
236:    3. ~~`bin/18-build-clean-venv.sh` + `bin/19-diag-clean-venv-unit.sh`~~ —
237:       RULED OUT (2026-08-19): a from-scratch clean venv, verified
238:       package-by-package against production on every dependency close to
239:       the compute path, reproduces the exact same byte-for-byte degenerate
240:       signature. Environment/in-place-patch contamination is not the cause.
241:    4. ~~Track B: upstream issue~~ — **ESCALATED AND POSTED** (2026-08-19,
242:       supersedes the earlier draft-only decision): with both local
243:       hypotheses exhausted, filed
244:       **https://github.com/vllm-project/vllm/issues/52938** after a fresh
245:       dedup pass (checked #47528, #50720, #50773, #47783/#47493 — verified
246:       its fix is already present in our installed 0.26.0 via direct source
247:       inspection — and #47266).
248: 2. **Awaiting upstream response on
249:    https://github.com/vllm-project/vllm/issues/52938.** In parallel,
250:    options to consider with the user: (a) try a different vLLM/flashinfer
251:    version pairing (0.27.1/0.6.17 already ruled out — hard SM120/DeepGEMM
252:    mHC gap — but nothing between 0.26.0 and 0.27.1, or after 0.27.1, is
253:    explored); (b) pivot effort to Phase 2 (Pro/ktransformers, fully
254:    unblocked since Task 0.7) while this stays escalated upstream, rather
255:    than continuing to sink time into Flash locally.
256: 3. Once Task 1.4 is actually unblocked (upstream fix, workaround, or a
257:    version bump that resolves it), `bin/20-restore-production-config.sh`
258:    restores `--max-model-len 370000` (currently 8192 for fast diagnostics)
259:    and removes the diagnostic `--enforce-eager` before proceeding to
260:    Task 1.5+.
261: 4. Task 0.7 (Pro download) complete — no further monitoring needed.
262: 5. ~~Diagnostic cleanup~~ — DONE: both
263:    `vllm-deepseek-v4-flash-clean.service` and the production
264:    `vllm-deepseek-v4-flash.service` are stopped (confirmed via
265:    `systemctl show` — both `inactive`/`dead`), all 4 GPUs are idle (0-10 MiB
266:    used), no leftover `VLLM::` processes. **Left deliberately idle** —
267:    production is not currently running; whoever picks this up next should
268:    decide whether to restart it (e.g. to keep smoke-testing while waiting
269:    on upstream) or leave it stopped until #52938 gets a response or a new
270:    diagnostic is ready to try. `/data/vllm/.venv-clean` and the
271:    `...-clean.service` unit are both still present on disk for potential
272:    reuse in a future diagnostic — not deleted.
273: 
274: ### Blockers
275: 
276: - [ ] **Task 1.4: DeepSeek-V4-Flash generates degenerate/garbage output**
277:   despite the service running and responding over HTTP without crashing —
278:   impact: endpoint is up but unusable; blocks Task 1.4 through 1.7;
279:   mitigation: see Task 1.4 note for the full diagnostic trail. Ruled out so
280:   far: CUDA-graph capture (`--enforce-eager`), the TP-vs-DP+EP execution
281:   path (vLLM #47528's pattern, tested via `bin/09-diag-dp-ep.sh` — identical
282:   degenerate output under DP+EP), torch.compile fusion passes (vLLM
283:   #50773 — confirmed inactive under `--enforce-eager` via startup log), and
284:   a stale vLLM/flashinfer version (0.27.1/0.6.17 upgrade hit a hard,
285:   unrelated SM120/DeepGEMM architecture gap in DeepSeek-V4's mHC layers —
286:   see Task 1.4 note — and was rolled back to 0.26.0/0.6.14), and missing
287:   FP8 KV-cache scaling factors (dropping `--kv-cache-dtype fp8` doesn't
288:   give a usable A/B test — it hard-asserts at model init, since fp8
289:   KV-cache is a required part of the `fp8_ds_mla` attention layout on this
290:   vLLM build, not a tunable knob; see Task 1.4 note), and now also
291:   environment/in-place-patch contamination (a from-scratch clean
292:   side-by-side venv, verified package-by-package against production,
293:   reproduces the exact same byte-for-byte degenerate signature — see Task
294:   1.4 note). All local hypotheses exhausted. Escalated upstream: filed
295:   **https://github.com/vllm-project/vllm/issues/52938** — awaiting
296:   response. Next action: monitor the upstream issue; consider a different
297:   vLLM/flashinfer version pairing, or reassess whether to keep debugging
298:   Flash on vLLM vs. pivoting effort to Phase 2 in the meantime. Cross-feature
299:   signal (2026-08-19, see Recent Updates): `feat-2`'s `llama.cpp`/GLM-5.2
300:   Phase 1 spike produced coherent (non-degenerate) sparse-attention decode
301:   output on these same SM120 GPUs — supporting evidence this is a
302:   vLLM/FlashInfer-specific implementation bug, not an SM120-hardware
303:   limitation; worth adding to #52938 as a comment.
304: - [ ] Pro's actual KV-cache cost at 350-370K tokens is unknown — impact:
305:   can't confirm precision/context fit without empirical testing;
306:   mitigation: Task 2.2 measures this directly before committing to a quant
307:   level
308: 
309: ### Recent Updates
310: 
311: #### 2026-08-18
312: 
313: - Completed: Researched Ollama library listings (cloud-only tags),
314:   confirmed official HF weights + existing GGUF quantizations, evaluated
315:   hardware fit for both models on the DGX Spark and Dell 7960T, resolved
316:   engine choice (vLLM/ktransformers), precision tradeoffs, security
317:   posture (anonymous/no-auth accepted), version pinning, benchmark
318:   approach, and operational model (systemd services only) through
319:   discussion with user; repo `biz.dfch.LlmOps` created and this feature
320:   folder scaffolded (including `.specmgr/_template/v1/README.md`, copied
321:   from biz.dfch.SpecMgr's convention for reuse in this repo)
322: - Next: Begin Phase 0 (environment prep)
323: - Notes: Feature linked to GitHub issue #1 (was `feat-0-` per user instruction)
324: 
325: #### 2026-08-18 (evening session — Flash crash-loop debugging)
326: 
327: - Completed: Diagnosed and fixed a 7-bug chain preventing
328:   `vllm-deepseek-v4-flash.service` from ever starting successfully after a
329:   reboot (see Task 1.3 note for full detail): orphaned-process GPU-memory
330:   leak from `KillMode=process`, a silent network hang on every startup
331:   despite fully-local weights, a TP-sharding bug in the FP8-expert-override
332:   weight loader, a pip CUDA-toolkit version skew breaking JIT compiles, a
333:   missing `PATH` breaking `ninja`, an unconditional SM120 gap in the
334:   `FLASHMLA_SPARSE_DSV4` attention backend, and a missing `libcudart`
335:   dev-symlink breaking FlashInfer's JIT linker step. All fixes captured as
336:   numbered, root-cause-documented scripts in `bin/00` through `bin/07`.
337: - Completed: Got the service to actually start, load weights, capture CUDA
338:   graphs, and serve HTTP successfully for the first time.
339: - Found: Task 1.4 smoke test reveals the served model generates degenerate
340:   output (identical special token + identical logprob at every decode
341:   position at temperature=0) — a real correctness bug, not a crash.
342:   Ruled out CUDA-graph capture as the cause via `bin/08-diag-enforce-eager.sh`
343:   (diagnostic only, same degenerate output with graphs disabled). Root
344:   cause still open — see Blockers.
345: - Next: Decide on further correctness-bug isolation (TP=2 test, version
346:   change, or upstream bug report) before continuing to Task 1.5+.
347: 
348: #### 2026-08-18 (night session — upstream research + DP+EP isolation test)
349: 
350: - Completed: Researched vLLM/FlashInfer version history and upstream GitHub
351:   issues for the Task 1.4 correctness bug. Independently verified (via
352:   direct `webfetch` of the actual GitHub pages, not just trusting an LLM
353:   research summary — several claimed issue numbers were spot-checked and
354:   confirmed real) three closely-matching open vLLM issues: #47528
355:   (DeepSeek-V4-Pro garbled under TP, correct under DP+EP), #50720
356:   (FlashInfer SM120 sparse-MLA decode dispatch bug, spec-decode-specific),
357:   #50773 (fuse_norm_quant/fuse_act_quant fusions garble DeepSeek-V4-Flash
358:   output on SM120/GB10). Also confirmed vLLM v0.27.0's real release notes
359:   contain DeepSeek-V4-specific sparse-MLA-decode work and that
360:   flashinfer-python 0.6.17 (we're on 0.6.14) has SM12x-targeted fixes.
361: - Completed: Wrote and ran `bin/09-diag-dp-ep.sh` to test the #47528
362:   pattern against our Flash deployment — swapped `--tensor-parallel-size 4`
363:   for `--data-parallel-size 4 --enable-expert-parallel`, temporarily
364:   dropped `--max-model-len` to 8192 for a fast smoke test. Hit an unrelated
365:   transient failure first (GPU 0's pre-existing ollama usage spiked to 42GB
366:   right as the diagnostic started, pushing free memory below the 90%
367:   utilization target — self-resolved a few minutes later when ollama's
368:   model idled out; systemd's `Restart=on-failure` + `KillMode=control-group`
369:   handled the crash-loop cleanly, confirming Task 1.3 fix #1 still holds).
370: - Found: DP+EP produces the **exact same degenerate output** as TP=4 (same
371:   frozen token, same logprob to 15 decimal places) — rules out #47528's
372:   TP-vs-DP+EP pattern for our case. Also ruled out #50773's fusion-pass
373:   theory without a separate test, via the DP+EP run's own startup log
374:   ("optimizations settings that are only active during inductor compilation
375:   will be ignored" — confirming those fusions never actually run under
376:   `--enforce-eager`, which had already been tested).
377: - Next: choose between a vLLM/flashinfer version upgrade, disabling FP8
378:   KV-cache, or filing an upstream bug report — see Next Steps.
379: 
380: #### 2026-08-18 (late night session — vLLM 0.27.1 upgrade attempt and rollback)
381: 
382: - Completed: Upgraded vLLM 0.26.0 → 0.27.1 and flashinfer-python 0.6.14 →
383:   0.6.17 via `bin/10-upgrade-vllm-flashinfer.sh`, as the next Task 1.4
384:   diagnostic. Turned out to be a much larger change than a version bump:
385:   vLLM 0.27.1 requires torch 2.13.0, pulling ~2GB of new/updated CUDA
386:   wheels (cudnn, cublas, nccl, cusparselt, triton, etc.); pip also flagged
387:   the forced flashinfer-python 0.6.17 as incompatible with vLLM 0.27.1's
388:   own pin (`flashinfer-python==0.6.16.post3`), a risk accepted to test
389:   the newer flashinfer's SM12x fixes anyway.
390: - Found: the upgrade introduced two consecutive, deterministic, new
391:   regressions (both worse than the original Task 1.4 bug — service never
392:   reached HTTP serving): (1) `Unknown SF transformation` in DeepGEMM's
393:   weight-scale post-processing on the very first restart; (2) after trying
394:   `VLLM_USE_DEEP_GEMM=0` (`bin/12-diag-disable-deepgemm.sh`) as a cheap
395:   workaround, a *different* crash — `Unsupported architecture` in
396:   DeepGEMM's `hyperconnection.hpp`, raised from the unconditional
397:   `tf32_hc_prenorm_gemm` call computing DeepSeek-V4's mHC layers (this
398:   path bypasses `VLLM_USE_DEEP_GEMM=0` entirely, which only gates a
399:   separate FP8-linear scaled-mm path). Conclusion: vLLM 0.27.1's vendored
400:   DeepGEMM build has a hard, unconditional SM120 architecture gap for
401:   DeepSeek-V4's mHC (Manifold-Constrained Hyper-Connections) kernels —
402:   not something fixable via flags on our hardware.
403: - Completed: Rolled vLLM/flashinfer-python back to 0.26.0/0.6.14 via
404:   `bin/13-rollback-vllm-flashinfer.sh` (confirmed via `pip show`) and
405:   removed the now-irrelevant `VLLM_USE_DEEP_GEMM=0` env line via
406:   `bin/14-remove-deepgemm-env-and-retest.sh`, restoring the unit to its
407:   exact pre-upgrade baseline for retesting.
408: - Notes: each pip install/upgrade in this session took 10-20+ minutes due
409:   to large (300-500MB+) wheel downloads competing for bandwidth with the
410:   still-running Task 0.7 Pro download; ran them via `setsid nohup ... & disown` to survive shell-tool timeouts, since a plain backgrounded
411:   `nohup` process was still killed when its parent tool call timed out.
412: - Found: the rollback itself reintroduced Task 1.3 fix #4's CUDA-toolkit
413:   version skew — `nvidia-cuda-nvcc`/`-crt`/`-cccl` stayed on the 13.3.x
414:   line (pulled up by the 0.27.1/torch-2.13.0 upgrade) while
415:   `nvidia-cuda-runtime`/`-nvrtc`/`-cupti` came back down to 13.0.x with
416:   the torch 2.11.0 reinstall, since pip's resolver doesn't proactively
417:   downgrade transitive deps that still satisfy the new constraint. First
418:   post-rollback restart hit the identical CCCL error as Task 1.3 fix #4
419:   (`cuda_toolkit.h:41:8: error: "CUDA compiler and CUDA toolkit headers are incompatible"`), this time inside flashinfer's JIT-compiled
420:   `sampling` op rather than TileLang's mHC kernel.
421: - Completed: Re-applied Task 1.3 fix #4's exact remedy (upgrade
422:   `nvidia-cuda-runtime`/`-nvrtc`/`-cupti` to the matching 13.3.x line) via
423:   `bin/15-fix-cuda-toolkit-skew-again.sh`, plus clearing flashinfer's
424:   stale JIT cache built against the mismatched toolkit. The already-
425:   running `Restart=on-failure` crash loop picked up the fix on its next
426:   automatic retry (no unit change or manual restart needed).
427: - Completed: **Confirmed the service is back to the exact original
428:   Task 1.4 baseline** — temperature=0 smoke test reproduces the identical
429:   degenerate signature (`<|begin▁of▁sentence|>` at logprob
430:   `-11.769736289978027` for all 10 requested tokens), byte-for-byte
431:   matching both the original bug and the DP+EP test. The vLLM 0.27.1
432:   upgrade path, its DeepGEMM/mHC regression, and the rollback's own CUDA-
433:   skew regression are now all fully resolved and the environment is
434:   clean.
435: - Next: with TP-vs-DP+EP, fusion passes, and the version upgrade all ruled
436:   out, try disabling `--kv-cache-dtype fp8` or file an upstream vLLM issue
437:   with the exact repro — see Next Steps.
438: 
439: #### 2026-08-19T08:04:27Z (Task 1.4 unblock plan folded in + scripted)
440: 
441: - Decided: keep this work inside `feat-1` (do NOT open a new feature) — it
442:   is the in-flight remediation of the existing, `blocked` Task 1.4 (serves
443:   ACC-001/004/005, no new REQ), and continues the unbroken `bin/00`-`bin/15`
444:   forensic runbook per the repo's single-source-of-truth + edit-in-place
445:   conventions.
446: - Completed: authored and staged the unblock plan as five numbered scripts
447:   (not yet run — they execute on the Dell 7960T via `systemctl`):
448:   - `bin/16-snapshot-baseline.sh` — Step 0, read-only capture of the exact
449:     degenerate baseline (ExecStart, `pip freeze`, `nvidia-smi`, temp=0
450:     response) to `bin/baselines/<ISO8601>-degenerate.txt` for byte-exact
451:     comparison across experiments.
452:   - `bin/17-diag-no-fp8-kvcache.sh` — Step 1 / Track A, drops
453:     `--kv-cache-dtype fp8` (cheapest remaining live suspect) and re-tests.
454:   - `bin/18-build-clean-venv.sh` — Step 2 fallback, builds a pristine
455:     `/data/vllm/.venv-clean` at the same pinned vLLM 0.26.0 /
456:     flashinfer 0.6.14 with the hard-won Task 1.3 fixes (#4 CUDA-line match,
457:     #7 cudart symlinks) baked in; leaves the existing `.venv` untouched.
458:   - `bin/19-diag-clean-venv-unit.sh` — wires a copy of the unit
459:     (`...-flash-clean.service`) at the clean venv to isolate in-place-patch
460:     contamination without disturbing the baseline service.
461:   - `bin/20-restore-production-config.sh` — Step 3, restores
462:     `--max-model-len 370000` and removes the diagnostic `--enforce-eager`,
463:     then runs the real ACC-004 tool-call + reasoning-mode checks. Run only
464:     after a diagnostic produces coherent output.
465: - Decided: Track B (upstream) is re-verify + draft only — no issue is posted
466:   (user instruction 2026-08-19). Draft written to
467:   `bin/upstream-issue-draft.md` with a "why this is not a duplicate of
468:   #47528/#50720/#50773" section and `<FILL FROM DELL BOX>` placeholders for
469:   the env/ExecStart/response fields that `bin/16` captures; must pass a
470:   dedup search before posting.
471: - Decided: if Track A yields coherent output, non-fp8 KV cache is adopted as
472:   the working fix and we proceed; dig further only if quality/context proves
473:   unacceptable (user instruction 2026-08-19). Trade-off recorded: non-fp8 KV
474:   cache roughly doubles KV memory, so Task 1.6's 350-370K context headroom
475:   must be re-checked at restore time. **SUPERSEDED 2026-08-19T09:1x-11:36Z**:
476:   this decision's premise doesn't hold — dropping `--kv-cache-dtype fp8` is
477:   not a viable config at all on this vLLM build (hard assertion at model
478:   init, not a runtime behavior to A/B test), so non-fp8 KV cache is not an
479:   available option for `FLASHINFER_MLA_SPARSE_DSV4`/`fp8_ds_mla`. See Task
480:   1.4 note.
481: - Next: run `bin/16` → `bin/17` (+ Track B) on the Dell 7960T; drive the
482:   decision gates from the diffs vs the frozen baseline.
483: 
484: #### 2026-08-19T09:10:23Z (bin/16 baseline snapshot executed)
485: 
486: - Completed: ran `bin/16-snapshot-baseline.sh` on the Dell 7960T. Wrote
487:   `bin/baselines/2026-08-19T09:10:23Z-degenerate.txt` capturing the live
488:   `ExecStart`, environment, `pip freeze`, `nvidia-smi`, and a temperature=0
489:   smoke test.
490: - Found: snapshot reconfirms the exact known degenerate signature —
491:   temperature=0, 10 requested tokens, every position returns
492:   `<｜begin▁of▁sentence｜>` at `logprob=-11.769736289978027`, byte-for-byte
493:   identical to the original bug, the DP+EP test, and the post-rollback
494:   reproduction. No drift since the last confirmation.
495: - Next: run `bin/17-diag-no-fp8-kvcache.sh` (Track A — drop
496:   `--kv-cache-dtype fp8`, restart, re-snapshot, diff vs this baseline) and,
497:   in parallel, Track B's upstream re-verify/draft.
498: 
499: #### 2026-08-19T09:1x-11:36Z (Track A ruled out — fp8 KV-cache is hard-required, not tunable)
500: 
501: - Completed: ran `bin/17-diag-no-fp8-kvcache.sh` on the Dell 7960T (dropped
502:   `--kv-cache-dtype fp8`). Ran `bin/16-snapshot-baseline.sh` again
503:   immediately after to check the result — it reported `(curl failed -- is
504:   the service up?)` and captured `nvidia-smi` showing all 4 GPUs at ~2 MiB
505:   used, i.e. the service was not holding the model at all at snapshot time.
506: - Found: `journalctl` shows every worker (`Worker_TP1`/`TP3`, etc.) failing
507:   at model construction with `AssertionError: DeepseekV4 fp8_ds_mla layout
508:   only supports fp8 kv-cache, got auto`, raised from
509:   `vllm/models/deepseek_v4/attention.py:83`
510:   (`_resolve_dsv4_kv_cache_dtype`), called from
511:   `nvidia/flashinfer_sparse.py:578`. **fp8 KV-cache is a hard architectural
512:   requirement of the `fp8_ds_mla` attention layout used by
513:   `--attention-backend FLASHINFER_MLA_SPARSE_DSV4` on this vLLM build, not
514:   a tunable precision knob** — the model never reaches inference without
515:   it, so Track A's hypothesis ("fp8 kv-cache scaling factors cause the
516:   degenerate output") cannot be isolated via this backend at all. This is
517:   a definitive, code-level ruling-out, not an inconclusive test.
518: - Found: because `bin/17` has no auto-revert and the unit's
519:   `Restart=on-failure`/`RestartSec=10` kept retrying the now-permanently-
520:   broken config, the service was stuck in an infinite crash loop (7+
521:   restarts observed) burning CPU and filling the journal until manually
522:   reverted.
523: - Completed: authored and ran `bin/21-revert-fp8-kvcache-crashloop.sh` —
524:   stops the crash loop, kills leftover `VLLM::` processes, restores
525:   `--kv-cache-dtype fp8` to its original `ExecStart` position, reloads
526:   systemd, restarts, polls for the API, and re-runs the temperature=0 smoke
527:   test. Confirmed the service is back up (`NRestarts=0` after the clean
528:   restart, `/health` returns 200) and **byte-identical to the frozen
529:   baseline** (`<｜begin▁of▁sentence｜>` at `logprob=-11.769736289978027`
530:   for all 10 positions) — the known-bad-but-stable state is restored.
531: - Decided: Track A is closed. Remaining live candidates for Task 1.4:
532:   the `FLASHINFER_MLA_SPARSE_DSV4` SM120 sparse-MLA decode kernel itself,
533:   or in-place-patch contamination in the existing `.venv` (accumulated
534:   fixes from Task 1.3/bin/00-15 and this session's edits). Track B
535:   (upstream re-verify + draft-only issue) remains open independently.
536: - Next: run `bin/18-build-clean-venv.sh` + `bin/19-diag-clean-venv-unit.sh`
537:   (clean side-by-side venv, original `.venv` untouched) to rule out
538:   in-place-patch contamination.
539: - Note: `bin/21` originally used a blocking `systemctl start` on this
540:   `Type=notify` unit (`TimeoutStartSec=3600`) — vLLM was observed serving
541:   real HTTP traffic successfully while systemd still reported
542:   `ActiveState=activating` (it does not appear to send `READY=1` promptly,
543:   if at all, under `--enforce-eager`), making the script look hung when the
544:   service was actually fine. Fixed by switching to `systemctl start
545:   --no-block` and driving the wait entirely off the actual HTTP `/health`
546:   endpoint instead of systemd's `ActiveState`.
547: - Completed: authored `bin/22-verify-against-baseline.sh` — a read-only,
548:   no-sudo smoke test that hits `/v1/chat/completions` and automatically
549:   parses the response's `token`/`logprob` fields to give a plain verdict
550:   (matches frozen baseline / same-class-different-value / possibly fixed /
551:   no logprobs found) instead of requiring a manual JSON diff.
552: - Completed: ran `bin/22-verify-against-baseline.sh` twice (once from this
553:   session, once independently by the user) — **both confirm the service
554:   still matches the frozen degenerate baseline exactly** (20/20 logprob
555:   values identical at `-11.769736289978027`, single repeated token
556:   `<｜begin▁of▁sentence｜>`). Service is stable, Track A is fully closed,
557:   ready to proceed to `bin/18`/`bin/19`.
558: 
559: #### 2026-08-19 (bin/18 clean-venv build started; production service stopped early)
560: 
561: - Started: `bin/18-build-clean-venv.sh` on the Dell 7960T — builds
562:   `/data/vllm/.venv-clean` at the same pinned vLLM 0.26.0/flashinfer-python
563:   0.6.14, with Task 1.3 fixes #4 (CUDA-toolkit line pin) and #7 (cudart
564:   symlinks) baked in from the start. Purely a CPU/disk operation (venv
565:   creation + `pip install`), no GPU or systemd interaction, so it's safe to
566:   run concurrently with anything else.
567: - Noted: `uv venv` printed a warning that the resolved Python 3.12.13
568:   "is incompatible with the project's Python requirement: `>=3.13`" —
569:   harmless. That requirement comes from this repo's own placeholder
570:   `pyproject.toml` (`biz-dfch-llmops`, unrelated to the deployment); `uv`
571:   still honored the script's explicit `--python 3.12` and created the venv
572:   correctly at 3.12.13, matching the production venv's Python version.
573: - Completed: stopped `vllm-deepseek-v4-flash.service` early (ahead of
574:   `bin/19`, which would have stopped it anyway) to free GPU VRAM while
575:   `bin/18`'s `pip install vllm==0.26.0 flashinfer-python==0.6.14` was still
576:   running in the background. Confirmed via `nvidia-smi`: all 4 GPUs back to
577:   ~2-10 MiB used / ~97.3 GB free (down from ~90.6 GB used each), service
578:   `ActiveState=inactive`, no leftover `VLLM::` processes.
579: - Next: wait for `bin/18`'s pip install to finish, verify the printed
580:   `pip freeze` shows the expected pinned versions, then run
581:   `bin/19-diag-clean-venv-unit.sh` (needs `sudo`) to wire the clean venv
582:   into a parallel `vllm-deepseek-v4-flash-clean.service` unit.
583: 
584: #### 2026-08-19 (bin/18 finished with two real bugs found and fixed before use)
585: 
586: - Found: `bin/18`'s own Step 5 (CUDA-toolkit line pin) **silently failed**
587:   with `ERROR: Could not find a version that satisfies the requirement
588:   nvidia-cuda-nvcc-cu13~=13.3.0` — a package-naming bug in the script
589:   itself (spurious `-cu13` suffix; the real PyPI package names have none).
590:   As a result the exact skew this step exists to prevent (Task 1.3 fix #4 /
591:   bin/15) was reproduced in the "clean" venv: `nvidia-cuda-nvcc`/`-crt`/
592:   `-cccl` resolved to `13.3.x` (pulled in transitively by vllm/flashinfer)
593:   while `nvidia-cuda-runtime`/`-nvrtc`/`-cupti` stayed on a stale `13.0.x`
594:   line.
595: - Fixed: reinstalled the correct package names at the exact versions from
596:   the confirmed-working production baseline (`nvidia-cuda-runtime==13.3.29`,
597:   `nvidia-cuda-nvrtc==13.3.33`, `nvidia-cuda-cupti==13.3.75`) directly into
598:   `/data/vllm/.venv-clean`, then corrected `bin/18` itself (exact-version
599:   pins for all six wheels, not just the buggy `-cu13`-suffixed `~=` pattern)
600:   so a future rebuild doesn't reproduce this.
601: - Found: a second, independent bug in `bin/18`'s Step 6 (cudart symlinks,
602:   Task 1.3 fix #7 / bin/07) — it created a useless self-referential
603:   `cu13/lib/lib64 -> .` (inside `lib/`, pointing at itself) instead of the
604:   actual working fix's `cu13/lib64 -> lib` (a sibling-level symlink
605:   pointing at the `lib` directory). FlashInfer's JIT linker resolves
606:   `cuda_home` as `dirname(dirname(which nvcc))` == `cu13`, then links
607:   `-L$cuda_home/lib64 -lcudart` — without `cu13/lib64` existing at that
608:   level, this silently reproduces the original `cannot find -lcudart`
609:   bin/07 bug.
610: - Fixed: removed the incorrect self-link, created the correct
611:   `cu13/lib64 -> lib` symlink directly in `.venv-clean`, verified
612:   `cu13/lib64/libcudart.so` now resolves through to
613:   `cu13/lib/libcudart.so.13` (confirmed via `readlink -f`). Corrected
614:   `bin/18`'s Step 6 to match `bin/07`'s exact layout for future rebuilds.
615: - Checked: `tilelang==0.1.9` (needed for DeepSeek-V4's mHC layers per Task
616:   1.3) IS present in the clean venv — an earlier quick pip-freeze diff
617:   looked like it was missing, but that was only because the grep filter
618:   used didn't include the string `tilelang`; it was never actually absent.
619: - Checked and accepted as low-risk: `torchaudio`/`torchcodec` resolved to
620:   slightly different build tags/versions than production
621:   (`torchaudio==2.11.0` vs `2.11.0+cu130`; `torchcodec==0.16.0` vs
622:   `0.15.0+cu130`). No `--extra-index-url` is recorded in any setup script
623:   for either venv, and `journalctl` shows neither package is ever imported
624:   while the service actually serves this text-only model — treated as
625:   incidental pip-resolution drift, not a functional difference, and not
626:   chased further absent evidence it matters.
627: - Completed: final `pip freeze` diff between `.venv-clean` and `.venv`
628:   shows only the accepted `torchaudio`/`torchcodec` tag difference — vLLM,
629:   flashinfer, tilelang, and all six `nvidia-cuda-*` wheels now match
630:   exactly, and the cudart symlink structure matches `bin/07`'s fix
631:   byte-for-byte. The clean venv is now genuinely equivalent to production
632:   except for the code/environment history being tested (fresh vs.
633:   patched-in-place) — ready for `bin/19`.
634: - Next: run `bin/19-diag-clean-venv-unit.sh` (needs `sudo`) to wire
635:   `.venv-clean` into a parallel `vllm-deepseek-v4-flash-clean.service`
636:   unit, then start it with `--no-block` and verify with
637:   `bin/22-verify-against-baseline.sh`.
638: 
639: #### 2026-08-19 (bin/19 run; clean-venv service crashed with THREE more environment gaps found and fixed)
640: 
641: - Completed: ran `bin/19-diag-clean-venv-unit.sh` — created
642:   `vllm-deepseek-v4-flash-clean.service` pointed at `.venv-clean`,
643:   production service already stopped.
644: - Found (crash #1, fatal): starting the clean unit crashed immediately with
645:   `ModuleNotFoundError` / `ImportError: The 'fastokens' package (>= 0.2.0)
646:   is required when VLLM_USE_FASTOKENS=1` — the unit's env var was copied
647:   verbatim from production by `bin/19`, but `bin/18` never installed
648:   `fastokens` (it's not pulled in by vllm/flashinfer's own metadata; must
649:   have been added by hand at some point in the Task 1.3 crash-loop
650:   history). Crash happens at tokenizer/renderer construction, well before
651:   model load -- no signal on Task 1.4's actual bug, just a missing
652:   package. Fixed: installed `fastokens==0.3.1` (matching production)
653:   directly into `.venv-clean`.
654: - Found (risk #2, silent — would not have crashed, but could have
655:   invalidated the test): a full `pip freeze` diff (not just the
656:   vllm/flashinfer/CUDA-filtered one from the earlier check) turned up ~25
657:   more version differences. Nearly all are incidental drift in
658:   HTTP/serving/client-library packages with no plausible connection to
659:   model math (anthropic, openai, starlette, uvicorn, httpx2/httpcore2,
660:   huggingface_hub, idna, charset-normalizer, filelock, pydantic-settings,
661:   Pygments, python-dotenv, python-json-logger, sentry-sdk, tiktoken,
662:   typing-inspection) — not pinned by the install command, so pip resolved
663:   whatever was newest at each install time. Two stood out as close enough
664:   to the compute path to control for: `transformers` (5.15.0 vs.
665:   production's 5.14.1 — directly patched by `fastokens`, whose log line
666:   explicitly names "v5.14.1") and `quack-kernels` (0.6.3 vs. 0.6.1 —
667:   confirmed `Required-by: vllm`, an actual CUDA-kernel dependency, not a
668:   bystander). Pinned both to match production exactly.
669: - Found (risk #3, self-inflicted by fixing #2): installing
670:   `quack-kernels==0.6.1` **reintroduced the CUDA-toolkit-line skew**
671:   (`nvidia-cuda-runtime`/`-nvrtc`/`-cupti` pulled back down to 13.0.x by
672:   quack-kernels' own dependency resolution) — the same skew pattern this
673:   deployment has now hit four times (Task 1.3 fix #4, bin/15, the earlier
674:   bin/18 fix this session, and now this). Re-pinned the three wheels back
675:   to 13.3.x; confirmed the `cu13/lib64 -> lib` symlink survived the churn.
676: - Checked one more near-compute-path candidate: `ml_dtypes` (0.6.0 vs.
677:   production's 0.5.4) is `Required-by: tilelang`, which runs live JIT
678:   kernels for DeepSeek-V4's mHC layers during inference — close enough to
679:   pin exactly rather than assume it doesn't matter. Confirmed `nccl4py`
680:   (also differing) is a genuine orphan in production (`Required-by:`
681:   empty, never imported per `journalctl`) — safe to leave undiffed.
682:   Confirmed `cuda-bindings`/`cuda-core`/`cuda-python`/`humming-kernels`
683:   (all real vllm/torch dependencies, not orphans) already matched exactly
684:   between both venvs with no action needed.
685: - Completed: final full `pip freeze` diff now contains only the
686:   already-vetted, confirmed-irrelevant packages. Fixed `bin/18` itself to
687:   install `fastokens`/`transformers`/`quack-kernels`/`ml_dtypes` (in that
688:   order, BEFORE the CUDA-toolkit pin step, since installing
689:   `quack-kernels` after the pin re-triggers the skew) so a future rebuild
690:   doesn't have to rediscover any of this.
691: - Next: restart `vllm-deepseek-v4-flash-clean.service` with
692:   `systemctl start --no-block` and check with
693:   `bin/22-verify-against-baseline.sh` (pointed at the same port, works
694:   unmodified against either unit) whether the clean venv still reproduces
695:   Task 1.4's degenerate signature.
696: 
697: #### 2026-08-19T13:2xZ (bin/19 clean-venv test result: environment contamination RULED OUT)
698: 
699: - Note: on the first `systemctl start` attempt, the *production* unit
700:   (`vllm-deepseek-v4-flash.service`) was started by mistake instead of the
701:   clean-venv unit (`...-clean.service`) — an easy mix-up given the
702:   near-identical names. Caught via `systemctl list-jobs` /
703:   `systemctl status` showing the wrong unit's PID and GPU memory climbing
704:   under `.venv` rather than `.venv-clean`. Corrected: stopped production,
705:   killed leftover `VLLM::` processes, started
706:   `vllm-deepseek-v4-flash-clean.service` (with `--no-block`, per the
707:   `bin/21` lesson) instead.
708: - Completed: `vllm-deepseek-v4-flash-clean.service` started successfully
709:   this time — `[fastokens] patch_transformers: successfully patched
710:   transformers v5.14.1` confirms the `bin/19` crash's root cause (missing
711:   `fastokens`) is fixed. Engine initialized with matching config
712:   (`kv_cache_dtype=fp8`, `tensor_parallel_size=4`,
713:   `quantization=deepseek_v4_fp8`, etc.), FlashInfer SM120 sparse-MLA-decode
714:   autotuning completed normally (same warmup pattern as every successful
715:   production start), all 4 GPUs loaded (~87 GB each), `/health` returned
716:   200 after ~70s.
717: - **Result: `bin/22-verify-against-baseline.sh` shows the clean venv is
718:   BYTE-FOR-BYTE IDENTICAL to the frozen degenerate baseline** — same
719:   single repeated token `<｜begin▁of▁sentence｜>`, same logprob
720:   `-11.769736289978027` at all 10 decode positions, same
721:   `system_fingerprint`. This is on a venv independently verified,
722:   package-by-package, to match production on every dependency remotely
723:   close to the compute path (vLLM, flashinfer, transformers,
724:   quack-kernels, ml_dtypes, tilelang, fastokens, all 6
725:   `nvidia-cuda-*` wheels, the cudart symlink structure) — the only
726:   unresolved differences are HTTP/serving/client-library packages
727:   confirmed never imported at runtime.
728: - **Decided: environment / in-place-patch contamination in `/data/vllm/.venv`
729:   is RULED OUT as the cause of Task 1.4's bug.** Per the `bin/19` decision
730:   gate, this means the bug is genuinely in vLLM 0.26.0's
731:   `FLASHINFER_MLA_SPARSE_DSV4` SM120 sparse-MLA decode path for this model
732:   on this hardware, not an artifact of the accumulated patch history from
733:   the Task 1.3 crash-loop debugging sessions.
734: - Both Track A (fp8 KV-cache is architecturally required, not tunable) and
735:   the environment-contamination hypothesis are now closed. Remaining live
736:   paths: (1) escalate the Track B upstream-issue draft
737:   (`bin/upstream-issue-draft.md`) as the primary route — still draft-only
738:   per user instruction, needs a fresh dedup pass given time elapsed; (2) a
739:   different vLLM/flashinfer version pairing (0.27.1/0.6.17 already ruled
740:   out — hard SM120/DeepGEMM mHC gap, see the vLLM-upgrade note above —
741:   but a version between 0.26.0 and 0.27.1, or a release after 0.27.1, is
742:   unexplored); (3) reassess with the user whether to keep debugging Flash
743:   on vLLM at all, or pivot effort to Phase 2 (Pro/ktransformers, unblocked
744:   since Task 0.7) while this is escalated upstream.
745: - Next: clean up the diagnostic clean-venv service/unit, restore the

(Output capped at 50 KB. Showing lines 1-745. Use offset=746 to continue.)
</content>
```

**Tool: bash**

**Input:**
```json
{
  "command": "ls /home/user/src/biz.dfch.LlmOps/hardware/dell-7960t/"
}
```

**Output:**
```
configuration.md
nvidia-manual-packages.txt
nvidia-package-selections.txt
recovery.md

```

---

## Assistant (Plan · Claude Sonnet 5 · 70.9s)

_Thinking:_



**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/Qwen/Qwen3.8-Flash-Next/raw/main/LICENSE"
}
```

**Output:**
```
Qwen Community License 1.0

Copyright (c) 2026 Qwen

Permission is hereby granted, free of charge, to any person obtaining a copy of this software, including the model weights, parameters, configuration files, inference code and associated documentation files (collectively, the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, sell, deploy, host, fine-tune, and create derivative works from (collectively, "Use" or "Using") copies of the Software; and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

1. The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. If the Software (or any derivative works thereof) is Used for any of the licensee's commercial products or services that have more than 100,000,000 monthly active users or US$ 20,000,000 (or equivalent in other currencies) monthly revenue, respective model name must be prominently displayed on the user interface of such product or service; and,

2. If the licensee or any of its affiliates conducts a Model as a Service or AI Work Assistant business, the licensee shall obtain a separate license from Qwen before Using the Software or its derivative works for any commercial purpose. The foregoing requirement shall not apply to the licensee's internal Use of the Software, provided that such Use does not make the Software, its outputs, or its underlying model capabilities available to any third party.

"Model as a Service" means giving a third party access to language model inference or fine-tuning (e.g., via API or a hosted endpoint) in a manner that allows such third parties to exercise meaningful control over the inputs, parameters, or training data. This does not include the mere relaying of requests to models hosted by other third parties. 
“AI Work Assistant” means an independent AI-powered product primarily designed for AI-assisted coding or office productivity (e.g., Qoder and QwenWork). It does not include: (a) a single-purpose AI tool (such as an AI translation tool); (b) an AI assistant primarily designed for a domain other than coding or office productivity (such as Taobao AI Shopping Assistant or AMap AI Chat); or (c) an AI assistant that is a feature of a product whose primary purpose is not AI-assisted coding or office productivity.

THE SOFTWARE AND ANY OUTPUT AND RESULTS THEREFROM ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL QWEN, ITS AFFILIATES OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. THE USE OF THE SOFTWARE MUST COMPLY WITH APPLICABLE LAWS AND REGULATIONS, AND MUST NOT INFRINGE THE INTELLECTUAL PROPERTY RIGHTS OF ANY THIRD PARTY.

For any questions regarding this license, please contact model-business@notice.qwencloud.com.
```

**Tool: bash**

**Input:**
```json
{
  "command": "grep -n \"GPU\\|status\\|llama.cpp\\|Q4\" /home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-2-glm-5.2-onprem-deployment/README.md | head -40"
}
```

**Output:**
```
5:status: planning
28:minimums (their reference config runs the 2-bit quant on a single 24 GB GPU
31:  4-bit (`UD-Q4_K_XL`, 372-475 GB) and 5-bit (`UD-Q5_K_XL`, 570 GB)** quants
55:  (preferred) or `UD-Q4_K_XL` (fallback) — NOT the lossy 1-2 bit levels
73:  (RTX Pro 6000 Blackwell) GPUs before committing to a full deployment —
76:- REQ-011: If llama.cpp/`llama-server` is chosen as the engine (its GGUF
80:  llama.cpp tool-calling is historically weaker than vLLM/SGLang and is a
91:  (`bin/05-spike-glm-dsa-strong.sh`, `llama.cpp`/`UD-IQ1_S`): 3 of 4 cases
106:  toggle correctly. If the engine is llama.cpp, tool-calling is explicitly
111:  `tool_calls[].function` block (`get_weather`, `arguments: {"location":"Paris"}`) — REQ-011's llama.cpp risk did NOT materialize on this
116:  (target `UD-Q5_K_XL`, else `UD-Q4_K_XL`), with a one-line rationale for
122:  of 97,288 MiB) free on the worst-margined GPU (CUDA1) — a measured floor
126:  Both comfortably clear a ≥15%-or-≥10 GiB per-GPU safety-margin policy —
129:  lossier `UD-Q4_K_XL` fallback. See Task 2.2 for the full per-GPU
149:  quantized + GPU/CPU-RAM-hybrid configuration
172:  v0.5.13.post1+, KTransformers v0.5.12+; GPU driver/CUDA compatibility for
184:  independently, not skipped) found `llama.cpp` producing coherent output
185:  on the same SM120 GPUs — the two findings corroborate each other toward
203:  4-bit `UD-Q4_K_XL` 372-475 GB · 5-bit `UD-Q5_K_XL` 570 GB · 8-bit
212:  reference (single 24 GB GPU + 256 GB RAM runs 2-bit). At 896 GB total the
214:  split, and **4-bit `UD-Q4_K_XL` (372-475 GB)** fits even more comfortably
216:  `UD-Q4_K_XL`; only drop lower if the 350-370K KV cache forces it. This is
223:  vLLM alternative. (3) **llama.cpp / `llama-server`** — the strongest
228:  remains a hybrid-size option but is lower priority now that llama.cpp
236:- **Reuse `feat-1` environment prep.** Disk (Task 0.1), GPU/driver/CUDA
255:- [ ] Task 0.1: Confirm disk headroom for GLM-5.2 weights + quant on /data (feat-1 Task 0.1 already showed 9.3 TB free; re-check remaining after feat-1's DeepSeek downloads) — depends on: none — status: not-started
256:- [ ] Task 0.2: Reuse feat-1's validated GPU/driver/CUDA (driver 610.57.04, CUDA 13.3, 4x SM120 GPUs) — no new work unless a different engine needs a different toolchain — depends on: none — status: not-started
257:- [ ] Task 0.3: Reuse feat-1's HF access/token + download tooling (hf CLI, hf_transfer) — depends on: none — status: not-started
258:- [x] Task 0.4: Choose and record pinned HF revision/commit for `zai-org/GLM-5.2` (base) — depends on: Task 0.3 — status: done — pinned revision `b4734de4facf877f85769a911abafc5283eab3d9` (recorded 2026-08-19; not downloaded, base BF16 not needed for the GGUF path)
259:- [x] Task 0.5: Select the quant strategy + source and record its pinned revision. Default: unsloth Dynamic GGUF `UD-Q5_K_XL` (target) / `UD-Q4_K_XL` (fallback) from `unsloth/GLM-5.2-GGUF` for a llama.cpp/SGLang path; or an FP8/FP4 checkpoint if vLLM is chosen (vLLM does not consume GGUF) — depends on: Task 0.4 — status: done — pinned revision `abc55e72527792c6e77069c99b4cb7de16fa9f23` (recorded 2026-08-19); download kicked off out of order via `bin/00-download-glm-quants.sh` (see Decisions Made)
263:- [ ] Task 1.1: Pick the engine(s) to spike and their GLM-5.2-supporting versions. Candidates in order of SM120-risk: llama.cpp/llama-server (separate GGUF CUDA path, does NOT inherit feat-1's vLLM sparse-attention bug — strongest Plan B), SGLang (distinct SM120 path), vLLM (default runbook but same broken kernel class as feat-1) — depends on: Task 0.4 — status: in-progress — llama.cpp picked as the lead spike candidate; dedicated checkout cloned+built at `/data/llama.cpp-dsa` (commit `ee4c505a4fb37be8ea37a78af272e74dad2835c1`, 2026-08-19) via `bin/01-clone-llama-cpp-dsa.sh` + `bin/02-build-llama-cpp-dsa.sh`, CUDA/SM120 confirmed linked (`CMAKE_CUDA_ARCHITECTURES` includes `120a-real`); done in parallel with the quant download while GPUs are still occupied by `feat-1`'s service, so Task 1.2 bring-up itself has not started yet
264:- [x] Task 1.2: Minimal short-context bring-up of GLM-5.2 on ONE engine at a small quant, temperature=0 greedy smoke test — check specifically for the feat-1 Task 1.4 degenerate signature (single frozen token at every decode position) — depends on: Task 1.1, Task 0.5 — status: done — 2026-08-19, `bin/03-spike-glm-dsa.sh`: `llama-server` (commit `ee4c505a4`) on `UD-IQ1_S`, all 4 GPUs (~50-53 GB VRAM each), `-c 4096`. Temp=0 greedy request produced coherent, grammatical chain-of-thought reasoning tokens (`The user wants me to say hello...`) with naturally varying logprobs (`-0.0000649` to `-1.126`) — NOT the feat-1 flat `-11.77`-at-every-position frozen-token signature. `finish_reason: length` with empty `message.content` is expected (GLM-5.2 defaults to thinking mode; 20-token budget was spent entirely on `reasoning_content`), not a failure. Decode ran at ~39 tok/s. Strengthened same-day via `bin/05-spike-glm-dsa-strong.sh`: multiple prompts (chit-chat/factual/code), `enable_thinking:false` to reach finished answers, each run twice for determinism — see ACC-002 for the full result. **REQ-010: llama.cpp's DSA decode path is correct on this box's SM120 GPUs.** Cross-reference: `feat-1` independently hit the same *class* of bug (vLLM's `FLASHINFER_MLA_SPARSE_DSV4` sparse-MLA decode produces the exact degenerate signature on these same SM120 GPUs, all local hypotheses ruled out, filed as upstream https://github.com/vllm-project/vllm/issues/52938) — this result is a second, independent data point supporting "vLLM/FlashInfer-specific bug," not "SM120 fundamentally broken for this kernel class"
265:- [x] Task 1.3: If output is degenerate on the first engine, repeat Task 1.2 on the next engine (llama.cpp vs SGLang vs vLLM is the SM120 sparse-attention discriminator that also informs feat-1) — depends on: Task 1.2 — status: not applicable — the first engine tried (llama.cpp) did NOT produce degenerate output (see Task 1.2/ACC-002), so the "repeat on next engine" condition never triggers. SGLang/vLLM not tested for GLM-5.2 — not needed since Phase 1's goal (find ONE working engine) is already met
266:- [x] Task 1.4: Record the outcome: which engine(s) produce coherent GLM-5.2 output on SM120, and whether the sparse-attention problem is engine-specific or SM120-fundamental (feed this back into feat-1 Task 1.4) — depends on: Task 1.2, Task 1.3 — status: done — **llama.cpp produces coherent GLM-5.2 DSA-decode output on this box's SM120 GPUs** (Task 1.2/ACC-002, strengthened via `bin/05-spike-glm-dsa-strong.sh`: deterministic, factually-correct, finished answers across chit-chat/factual/code prompts). Combined with `feat-1`'s finding that vLLM's `FLASHINFER_MLA_SPARSE_DSV4` produces the degenerate signature on the SAME GPUs for a different model (DeepSeek-V4-Flash, upstream vllm-project/vllm#52938), this is consistent with the sparse-attention problem being **engine-specific (vLLM/FlashInfer), not SM120-fundamental** — though this is corroborating evidence from a different model/engine pairing, not a direct reproduction of feat-1's exact bug. Fed back into `feat-1`'s README (cross-reference note under Task 1.4/Blockers)
270:- [x] Task 2.1: Measure actual KV-cache memory per 1K tokens at real context shapes on the chosen engine/quant — depends on: Task 1.4 — status: done — `bin/06-measure-kv-cache.sh` (adaptive ramp 4K→32K→128K→256K→512K). Two unsafe-config incidents hit and fixed before a run succeeded (see Decisions Made 2026-08-19 "KV-cache measurement MoE placement"): (1) `--cpu-moe` alone pushed ~500 GiB onto the 512 GiB system RAM, causing real swap growth — killed as a precaution (sweep attempt `2026-08-19T203936Z`, crashed at `ctx=4096`, no explicit error in the log — consistent with an external kill); (2) `--n-cpu-moe 41` alone let one GPU (CUDA2) get assigned a full ~132 GiB chunk of MoE weight before the CPU cutoff was applied, causing `cudaMalloc failed: out of memory ... buffer of size 138774596736` (sweep attempt `2026-08-19T212601Z`, crashed at `ctx=4096`). **Fixed run (`2026-08-19T220559Z`) succeeded on ALL 5 ramp sizes** with `--n-cpu-moe 54 --tensor-split 54,9,8,8`, no bisection needed:
272:  | ctx (tokens) | status | GPU mem (4 GPUs) | RAM used | load time |
290:  nearly everything on GPU/VRAM). Full data: `bin/logs/2026-08-19T220559Z-kv-cache-sweep.{txt,json}` and per-context server logs `bin/logs/2026-08-19T220559Z-kv-ctx*.log`.
292:- [x] Task 2.2: Confirm the highest-quality quant that reliably supports 350-370K context with safe margin, based on Task 2.1 (start from UD-Q5_K_XL @ 570 GB in the 896 GB pool; step to UD-Q4_K_XL only if KV headroom demands) — depends on: Task 2.1 — status: done — 2026-08-20. Task 2.1's aggregate numbers (~233-235 GiB @ 350-370K vs the 896 GB pool) are necessary but not sufficient, since `--tensor-split 54,9,8,8` splits model weight AND KV-cache growth unevenly per GPU (each hard-capped at 97,288 MiB) — so the real gate is per-GPU headroom, not the pool sum. Per-GPU `memory breakdown` lines were pulled from all 5 Task 2.1 logs.
295:already directly measured `ctx=524,288` (512K tokens, `status=ok` on all
296:4 GPUs), and 524,288 > 370,000 (REQ-003's upper bound). Since

```

---

## Assistant (Plan · Claude Sonnet 5 · 26.6s)

_Thinking:_



**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/_template/v1/README.md"
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/_template/v1/README.md</path>
<type>file</type>
<content>
1: ---
2: id: feat-NNN-slug
3: version: 1.0.0
4: status: planning
5: created: YYYY-MM-DD
6: updated: YYYY-MM-DD
7: ---
8: 
9: # Feature: [Feature Title]
10: 
11: ## Plan
12: 
13: ### Overview
14: 
15: Brief description of what this feature does and why it matters.
16: 
17: ### Requirements
18: 
19: - REQ-001: [Functional requirement]
20: - REQ-002: [Non-functional requirement]
21: - REQ-003: [Constraint or dependency]
22: 
23: ### Acceptance Criteria
24: 
25: - [ ] ACC-001: Verifies REQ-001 — [testable condition]
26: - [ ] ACC-002: Verifies REQ-002 — [testable condition]
27: - [ ] ACC-003: Verifies REQ-003 — [testable condition]
28: 
29: ### Scope
30: 
31: What is included in this feature:
32: - Item 1
33: - Item 2
34: 
35: What is explicitly out of scope:
36: - Item A
37: - Item B
38: 
39: ### Dependencies
40: 
41: - Depends on: [other feat-NNN-slug, ADR id, or external]
42: - Blocks: [other feat-NNN-slug]
43: 
44: ### Design Notes
45: 
46: Any architectural decisions, patterns, or design rationale relevant to this feature.
47: 
48: ### Related ADRs
49: 
50: - [ADR id]: [Title]
51: - [ADR id]: [Title]
52: 
53: ### Task List
54: 
55: Single, canonical breakdown of work phases and tasks. Status lives on the
56: task itself — there is no separate "planned" vs. "executed" list to keep in
57: sync; a task's line *is* its current status. Update it in place as work
58: progresses (edit, don't duplicate).
59: 
60: #### Phase 1: [Phase name]
61: - [x] Task 1.1: [description] — depends on: none — status: done (2026-08-01)
62: - [ ] Task 1.2: [description] — depends on: Task 1.1 — status: in-progress, ETA 2026-08-10
63: - [ ] Task 1.3: [description] — depends on: Task 1.2 — status: blocked (see Blockers)
64: 
65: #### Phase 2: [Phase name]
66: - [ ] Task 2.1: [description] — depends on: Task 1.3 — status: not-started
67: - [ ] Task 2.2: [description] — depends on: Task 2.1 — status: not-started
68: 
69: **Note:** If a task's scope changes mid-flight, edit its description in place;
70: rely on git history (`git log -p` on this file) to recover what was
71: originally planned, rather than keeping a second copy of the task around.
72: 
73: ## Progress
74: 
75: ### Current Status
76: 
77: **As of [YYYY-MM-DD]**: [Brief status summary]
78: 
79: ### Blockers
80: 
81: - [ ] Blocker 1 — [description, impact, mitigation]
82: - [ ] Blocker 2 — [description, impact, mitigation]
83: 
84: (Remove this section if no blockers.)
85: 
86: ### Recent Updates
87: 
88: If this section grows too long, move older entries to `history.md` in this
89: same folder and leave a pointer here, e.g.:
90: `See history.md for updates before YYYY-MM-DD.`
91: 
92: #### [YYYY-MM-DD]
93: - Completed: [what was done]
94: - Next: [what comes next]
95: - Notes: [any relevant context]
96: 
97: #### [YYYY-MM-DD]
98: - Completed: [what was done]
99: - Next: [what comes next]
100: - Notes: [any relevant context]
101: 
102: ### Decisions Made
103: 
104: - **[YYYY-MM-DD]**: [Decision] — [Rationale]
105: - **[YYYY-MM-DD]**: [Decision] — [Rationale]
106: 
107: ### Related PRs / Commits
108: 
109: - [PR #NNN](link): [description]
110: - [Commit hash](link): [description]

(End of file - total 110 lines)
</content>
```

---

## Assistant (Plan · Claude Sonnet 5 · 74.9s)

_Thinking:_



I did the necessary groundwork before drafting this — checked `feat-1`'s current blocked state (DeepSeek-V4-Flash degenerate-output bug on this exact SM120 hardware, upstream issue #52938 still open; DeepSeek-V4-Pro/ktransformers not started), `feat-2`'s actual engine (llama.cpp, not ktransformers as AGENTS.md describes), `feat-4`'s isolation pattern, and pulled the actual `qwen-community-1.0` license text. That surfaced several things that need your input before I write this file (which I can't do in plan mode anyway). Here's the draft and the open questions.

## Key findings that shape this plan

1. **License is not Apache-2.0.** `qwen-community-1.0` is permissive for internal use, but has a real carve-out: if you ever run this as a "Model as a Service" (giving *any* third party API/hosted access) or build an "AI Work Assistant" product, you need a separate license from Qwen — **unless** it stays genuinely internal with no third-party exposure to the model/outputs. Your repo's existing "anonymous, internal-network-only" posture likely satisfies this, but it's a different kind of risk than the auth question, and worth an explicit sign-off rather than silently inheriting `feat-1`'s "accepted risk" language.
2. **QSA is a direct hardware-risk analog to `feat-1`'s open bug.** `feat-1` has an unresolved, upstream-escalated bug where vLLM's SM120 sparse-attention *decode* kernel (`FLASHINFER_MLA_SPARSE_DSV4`) produces frozen/degenerate output on these exact GPUs. Qwen3.8-Flash-Next's headline new mechanism, **Qwen Sparse Attention (QSA)**, is also a novel sparse-attention decode kernel — never validated on any hardware, let alone SM120. This needs to be a hard Phase-1 gate, same pattern `feat-1`/`feat-2`/`feat-4` all used.
3. **Framework support is a bigger unknown than usual.** The HF repo tags this `qwen4_exp` — an experimental preview architecture. This box's validated vLLM is 0.26.0, and `feat-1` already found 0.27.1 introduces an *unrelated* hard SM120/DeepGEMM regression. There's a real chance no stable vLLM/SGLang release supports QSA/Gated Residual/N-gram Embedding yet, forcing a nightly/dev build — itself a known risk pattern on this hardware.
4. **Capacity is actually the easy part.** 180B total params (125B main + 51B n-gram-embedding + 4B MTP) at FP8 ≈ 180GB — fits inside the 384GB discrete VRAM with room to spare, unlike `feat-1`'s Pro slot (~800GB+, needed GPU+RAM hybrid to fit at all). The n-gram-embedding's "offload-friendly" design is a nice-to-have optimization here, not a load-bearing requirement, since GPU-only FP8 already fits.

## Draft: `feat-5-qwen3.8-flash-next-dell-7960t`

```markdown
---
id: feat-5-qwen3.8-flash-next-dell-7960t
version: 1.0.0
status: planning
created: 2026-08-27
updated: 2026-08-27
---

# Feature: On-prem Qwen3.8-Flash-Next serving on the Dell 7960T

## Plan

### Overview

Deploy `Qwen/Qwen3.8-Flash-Next` — Qwen's experimental preview of the
architecture underpinning Qwen4 (Gated DeltaNet + Qwen Sparse Attention
(QSA), Gated Residual, 51B-param N-gram Embedding, 512-expert MoE with 10
routed + 1 shared active, 125B total / 6B activated + 4B MTP = 180B total
resident params) — on the Dell 7960T, behind an OpenAI-compatible API, for
use as a coding model via OpenCode and OpenWebUI, and as a benchmark
comparison point against `feat-1`'s DeepSeek-V4 and `feat-4`'s
Qwen3.8-27B on the same box.

This is a standalone, isolated feature that coexists with `feat-1`
(DeepSeek-V4), `feat-2` (GLM-5.2), and `feat-4` (Qwen3.8-27B) on the same
Dell 7960T — it does not replace or modify any of them, including
`feat-1`'s still-unstarted DeepSeek-V4-Pro slot (which this model is
architecturally comparable to as a "hybrid GPU+RAM MoE" candidate, but
that comparison is discussion only, not scope here).

Unlike every other model deployed on this box so far, Qwen3.8-Flash-Next
ships under `qwen-community-1.0`, not Apache-2.0 — internal-only,
no-third-party-exposure use (this repo's existing posture) is expected to
clear its "Model as a Service" carve-out, but this must be explicitly
confirmed, not silently inherited from the anonymous-access precedent.

### Requirements

- REQ-001: Serve Qwen3.8-Flash-Next via an OpenAI-compatible API
  (`/v1/chat/completions`) on the Dell 7960T, isolated from `feat-1`/
  `feat-2`/`feat-4`'s install trees and systemd units (dedicated
  `/data/qwen3.8-flash-next/` tree, own venv, only the read-only HF cache
  shared)
- REQ-002: Confirm, before any deployment work, that an available
  inference framework (vLLM, SGLang, or KTransformers) actually supports
  this model's architecture (`qwen4_exp` tag: Gated DeltaNet, QSA, Gated
  Residual, N-gram Embedding, this MoE config) — treated as a hard gate,
  not assumed from the model card's own serving instructions
- REQ-003: Before any long-context or precision work, run a native/short-
  context correctness smoke test that explicitly checks for `feat-1`'s
  known degenerate-output signature (single frozen token / identical
  logprob at every decode position) — QSA is a novel sparse-attention
  decode kernel on the same SM120 GPU family where that exact bug class
  is already open and unresolved for a different sparse-attention kernel
- REQ-004: [OPEN QUESTION — see below] Context length target
- REQ-005: The endpoint must support tool-calling (required for OpenCode
  agentic use) and Qwen3.8-Flash-Next's thinking controls
  (`enable_thinking`, `reasoning_effort`: xhigh/medium/low,
  `preserve_thinking`)
- REQ-006: Determine empirically (not assumed) the precision/placement
  strategy: GPU-only FP8 (fits in 384GB VRAM with headroom), GPU-only
  NVFP4 (more headroom, less mature kernel support for this architecture),
  or a hybrid GPU+system-RAM placement exploiting the N-gram Embedding's
  offload-friendly design (KTransformers-style) — [OPEN QUESTION, see
  below]
- REQ-007: Determine empirically (not assumed) the tensor-parallel /
  GPU-count placement — `feat-4` already found this box's no-NVLink
  topology doesn't rule out TP>1 winning (TP=2 beat TP=1 by 64% for a much
  smaller model there); this model's much larger size and different
  architecture must be measured fresh
- REQ-008: Pin `Qwen/Qwen3.8-Flash-Next` to a specific Hugging Face
  revision/commit (not "latest") for reproducibility
- REQ-009: The endpoint runs unauthenticated (anonymous, no API-key/auth
  layer), internal network only — same posture as `feat-1`/`feat-2`/
  `feat-4`, AND explicitly confirmed to satisfy the `qwen-community-1.0`
  license's internal-use carve-out (no third-party exposure to the model,
  its outputs, or its capabilities)
- REQ-010: The engine runs as an on-demand systemd `--user` service
  (lingering enabled, never auto-started at boot) — matching `feat-4`'s
  "on-demand only, no auto-promoted production default" posture, given
  this model's likely large GPU footprint makes always-on coexistence
  with `feat-1`/`feat-2`/`feat-4` impractical
- REQ-011: Record the model's actual per-GPU/system-RAM memory footprint
  at the chosen precision/context, and whether any headroom remains for
  coexistence with the box's other features

### Acceptance Criteria

- [ ] ACC-001: Verifies REQ-002 — a specific framework + version is
  confirmed (via direct inspection, not assumption) to register this
  model's architecture and expose its required serving flags; if none do,
  this is recorded as a blocking finding, not silently worked around
- [ ] ACC-002: Verifies REQ-003 — native-context smoke test does NOT
  reproduce `feat-1`'s degenerate-output signature; if it does, treated as
  a blocking finding requiring escalation before any further work
- [ ] ACC-003: Verifies REQ-001/REQ-009 — service reachable via
  `/v1/chat/completions`, confirmed fully isolated from `feat-1`/`feat-2`/
  `feat-4` (their services/GPUs untouched), confirmed unauthenticated/
  internal-only by design
- [ ] ACC-004: Verifies REQ-004 — empirical test confirms the chosen
  context target works without OOM on a real filled-context prompt
- [ ] ACC-005: Verifies REQ-005 — tool-call and all three thinking-control
  modes verified via curl, then via a real OpenCode agentic session
- [ ] ACC-006: Verifies REQ-006/REQ-007 — the chosen precision and
  GPU-placement strategy is recorded with the measured data that drove
  the decision (not chosen by default)
- [ ] ACC-007: Verifies REQ-008 — deployment config records the exact HF
  revision/commit hash used
- [ ] ACC-008: Verifies REQ-010 — service is a disabled, on-demand
  `systemctl --user` unit throughout testing and use
- [ ] ACC-009: Verifies REQ-011 — a recorded decision on remaining
  headroom / coexistence feasibility with the box's other features
- [ ] ACC-010: User runs the same coding-task examples used for `feat-1`/
  `feat-2`/`feat-4` against this endpoint, for a direct quality/throughput
  comparison

### Scope

What is included:
- Framework/architecture support verification (hard gate) before any
  other work
- A dedicated, isolated install tree, venv, and systemd unit(s)
- Native-context degenerate-output smoke test (hard gate, mirroring
  `feat-1`/`feat-2`/`feat-4`)
- Empirical precision (FP8 vs. NVFP4 vs. hybrid offload) and GPU-placement
  (TP=1/2/4) decisions, each backed by measurement
- YaRN-based context extension if/when a target beyond native 262,144 is
  confirmed
- OpenWebUI/OpenCode wiring
- Explicit license-posture confirmation (internal-use carve-out)

What is explicitly out of scope:
- Any modification to `feat-1`/`feat-2`/`feat-4`'s deployments, venvs,
  systemd units, or GPU allocation
- Vision/video capability testing (text/coding only, matching this
  repo's precedent for other native VLMs)
- Treating this as a replacement for `feat-1`'s DeepSeek-V4-Pro slot —
  that remains a separate, independent decision
- Any production/always-on promotion — this stays on-demand only
- Acquiring additional hardware

### Dependencies

- Depends on: the Dell 7960T's existing driver/CUDA stack (validated by
  `feat-1`/`feat-2`/`feat-4` — driver 610.57.04, CUDA 13.3, 4x SM120
  GPUs); a framework version that actually supports `qwen4_exp`
  (unconfirmed — REQ-002); sufficient disk headroom for ~180B params at
  the chosen precision (FP8 ≈ 180GB, NVFP4 ≈ 90GB — not yet checked
  against current `/data` free space, which was 6.9TB free as of
  `feat-4`'s last measurement but has since had more written to it)
- Related (not a hard dependency): `feat-1`'s open, unresolved SM120
  sparse-attention-decode bug (vllm-project/vllm#52938) — directly
  relevant given QSA is also a sparse-attention decode kernel; `feat-2`'s
  finding that llama.cpp's DSA decode path is correct on this hardware
  while vLLM's is broken — suggests engine choice, not SM120 hardware
  itself, may again be the discriminator here, but llama.cpp/GGUF support
  for this architecture is unlikely to exist yet given how new it is
- Blocks: none

### Design Notes

- **Model facts (verified from HF 2026-08-27)**: `Qwen/Qwen3.8-Flash-Next`,
  `qwen-community-1.0`, native VLM, 125B total language-model params (6B
  activated) + 51B N-gram Embedding + 4B MTP = 180B total resident.
  Hybrid layout: 12x (3x (Gated DeltaNet -> MoE) -> 1x (QSA -> MoE)), 48
  layers. MoE: 512 experts, 10 routed + 1 shared active, expert
  intermediate dim 640. Context: 262,144 native, extensible to 1,048,576
  via the same YaRN `rope_parameters` mechanism as Qwen3.8-27B.
- **Why capacity is not the binding constraint here (contrast with
  `feat-1`'s Pro slot)**: at FP8 (~180GB), weights alone fit inside the
  384GB discrete VRAM pool with ~200GB headroom for KV cache/activations —
  unlike DeepSeek-V4-Pro's 800GB+ native footprint, which needs GPU+RAM
  hybrid placement just to exist. The N-gram Embedding's offload-friendly
  design is an optimization lever (e.g. to free GPU memory for
  coexistence with other features), not a load-bearing requirement.
- **QSA is the single largest unvalidated risk in this plan.** It is a
  brand-new sparse-attention decode kernel with no production track
  record anywhere, being tested on the exact GPU family where a
  different sparse-attention decode kernel (vLLM's `FLASHINFER_MLA_SPARSE_DSV4`) is already known-broken and escalated
  upstream. Phase 1's smoke test is a hard gate, not a formality.
- **Framework choice is genuinely open, unlike `feat-3`/`feat-4`.** vLLM
  0.26.0 (this box's validated version) almost certainly predates
  `qwen4_exp` support. The model card's own recipes point at vLLM/SGLang/
  KTransformers "latest" — Phase 0 must determine which, if any, stable
  release actually supports it, versus requiring a nightly/dev build
  (itself elevated risk, per `feat-1`'s 0.27.1 regression precedent).
- **License posture**: `qwen-community-1.0` permits internal use freely;
  the "Model as a Service" / "AI Work Assistant" carve-out requires a
  separate Qwen license only if the model/outputs/capabilities are
  exposed to a third party. This repo's existing anonymous-but-internal-
  network-only posture is expected to clear this, but is recorded here as
  an explicit confirmation, not inherited silently.

### Related ADRs

- None (infrastructure/deployment work, tracked using this repo's
  feature-folder convention, same as `feat-1`-`feat-4`)

### Task List

#### Phase 0: Framework/architecture support verification (hard gate)

- [ ] Task 0.1: Confirm disk headroom under `/data` for ~180GB (FP8) or
  ~90GB (NVFP4) of weights — depends on: none — status: not-started
- [ ] Task 0.2: For each of vLLM (latest stable + this box's existing
  0.26.0), SGLang, and KTransformers: check whether it registers this
  model's architecture tag and exposes the serving flags the model card
  documents (QSA, Gated Residual, N-gram Embedding, this MoE config) —
  depends on: none — status: not-started
- [ ] Task 0.3: If no stable release supports it, evaluate the risk/
  effort of a nightly/dev build vs. treating this feature as blocked
  pending upstream support — depends on: Task 0.2 — status: not-started
- [ ] Task 0.4: Build a fully isolated venv/install tree
  (`/data/qwen3.8-flash-next/`), independent of `feat-1`/`feat-2`/
  `feat-4`'s trees — depends on: Task 0.3 — status: not-started
- [ ] Task 0.5: Pin and download `Qwen/Qwen3.8-Flash-Next` to a specific
  HF revision — depends on: Task 0.1 — status: not-started
- [ ] Task 0.6: Confirm `feat-1`/`feat-2`/`feat-4`'s current live state
  (to avoid GPU contention during this feature's own testing) — depends
  on: none — status: not-started

#### Phase 1: Native-context correctness smoke test (hard gate)

- [ ] Task 1.1: Bring up the model at short/native context, no YaRN
  override yet — depends on: Task 0.4, Task 0.5 — status: not-started
- [ ] Task 1.2: Temperature=0 smoke test — explicitly check for `feat-1`'s
  exact degenerate-output signature; verify tool-calling and thinking-
  control modes — depends on: Task 1.1 — status: not-started
- [ ] Task 1.3: Record the outcome — if degenerate, this is a blocking
  finding requiring escalation before any further work — depends on:
  Task 1.2 — status: not-started

#### Phase 2: GPU placement + precision decision

- [ ] Task 2.1: Benchmark decode throughput/fit at candidate GPU counts
  (TP=1/2/4) and precisions (FP8, NVFP4) — depends on: Task 1.3 —
  status: not-started
- [ ] Task 2.2: Decide production placement/precision based on measured
  data — depends on: Task 2.1 — status: not-started

#### Phase 3: Context extension (target per REQ-004, once resolved)

- [ ] Task 3.1: Apply YaRN override targeting the confirmed context goal;
  measure headroom — depends on: Task 2.2 — status: not-started
- [ ] Task 3.2: Validate with a real filled-context request — depends on:
  Task 3.1 — status: not-started

#### Phase 4: Deployment + integration

- [ ] Task 4.1: Install as an on-demand, disabled `systemctl --user`
  service — depends on: Task 3.2 — status: not-started
- [ ] Task 4.2: Curl smoke test against production config — depends on:
  Task 4.1 — status: not-started
- [ ] Task 4.3: Connect OpenCode/OpenWebUI — depends on: Task 4.2 —
  status: not-started
- [ ] Task 4.4: User runs the same coding-task examples as `feat-1`/
  `feat-2`/`feat-4` for comparison — depends on: Task 4.3 —
  status: not-started
```

## Open questions before I write this

1. **Context target (REQ-004)**: match the project's `feat-1` non-negotiable of 350–370K, or push toward this model's 1M ceiling like `feat-3`/`feat-4` did? Or defer the decision to Phase 3 based on what Phase 2's measurements show is feasible?
2. **Precision/placement (REQ-006)**: should I explicitly scope in the KTransformers hybrid-offload path (exploiting the N-gram Embedding's design) as a first-class option, or treat plain GPU-only FP8/NVFP4 via vLLM/SGLang as primary and the hybrid path as a stretch goal only if capacity forces it?
3. **License sign-off (REQ-009)**: do you want me to state the internal-use conclusion as already-decided, or leave it as an open item for you to confirm once you've read the full license text yourself?
4. **Relationship to `feat-1`'s DeepSeek-V4-Pro slot**: confirmed standalone/independent, correct? (I've drafted it that way, but wanted to check since this model is architecturally the closer fit for that slot's original "hybrid GPU+RAM MoE" intent.)
5. **Feature numbering**: `feat-5-qwen3.8-flash-next-dell-7960t` — good, or do you want a different slug?

Once you've settled these, I'll write the file (outside plan mode).

---

## User

Regarding key findings:

-- 1: license is ok for us
-- 2: noted and agreed
-- 3: do we have to use vllm or can we use sth else? but otherwise noted and accepted
-- 4: is the model only FP8 or available at BF16? if latter yes, then would it makes sense to use the higher precision?

Regarding open questions:

-- 1: we test 896k (or 768k). Or is there a reason, that we cannot get that large?
-- 2: I want to see GPU-only first, then offloading with higher precision
-- 3: license is ok for us
-- 4: stand-alone as a manuel user service, depending on the VRAM amount needed and if 2 GPUs are sufficient, we use GPU0 and GPU2 and only then GPU1 and GPU3
-- 5: use #5 and create a gh issue for that with a SHORT description (max 2 lines). The details will be in the feature file.

Do you have any more questions before we can write the feature? feel free to ask

---

## Assistant (Plan · Claude Sonnet 5 · 57.2s)

_Thinking:_



**Tool: webfetch**

**Input:**
```json
{
  "url": "https://huggingface.co/models?search=Qwen3.8-Flash-Next"
}
```

**Output:**
```
                

  Models – Hugging Face   

 [![Hugging Face's logo](/front/assets/huggingface_logo-noborder.svg) Hugging Face](/)

-   [Models](/models)
-   [Datasets](/datasets)
-   [Spaces](/spaces)
-   [Buckets new](/storage)
-   [Docs](/docs)
-   [Enterprise](/enterprise)
-   [Pricing](/pricing)
-   -   Website
        
        -   [Tasks](/tasks)
        -   [HuggingChat](/chat)
        -   [Collections](/collections)
        -   [Languages](/languages)
        -   [Organizations](/organizations)
    -   Community
        
        -   [Blog](/blog)
        -   [Posts](/posts)
        -   [Daily Papers](/papers)
        -   [Hardware](/hardware)
        -   [Learn](/learn)
        -   [Discord](/join/discord)
        -   [Forum](https://discuss.huggingface.co/)
        -   [GitHub](https://github.com/huggingface)
    -   Solutions
        
        -   [Team & Enterprise](/enterprise)
        -   [Hugging Face PRO](/pro)
        -   [Enterprise Support](/support)
        -   [Inference Providers](/inference/models)
        -   [Inference Endpoints](/inference-endpoints)
        -   [Storage Buckets](/storage)
    
-   ---
    
-   [Log In](/login)
-   [Sign Up](/join)

### Edit Models filters

-   Main
-   Tasks
-   Libraries
-   Languages
-   Licenses
-   Other

Tasks

[

Text Generation

](/models?pipeline_tag=text-generation)[

Any-to-Any

](/models?pipeline_tag=any-to-any)[

Image-Text-to-Text

](/models?pipeline_tag=image-text-to-text)[

Image-to-Text

](/models?pipeline_tag=image-to-text)[

Image-to-Image

](/models?pipeline_tag=image-to-image)[

Text-to-Image

](/models?pipeline_tag=text-to-image)[

Text-to-Video

](/models?pipeline_tag=text-to-video)[

Text-to-Speech

](/models?pipeline_tag=text-to-speech)\+ 44

Parameters

Reset Parameters

  < 1B

6B

12B

32B

128B

\> 500B

< 1B

\> 500B

Libraries

[

PyTorch

](/models?library=pytorch)[

 google-tensorflow TensorFlow

](/models?library=tf)[

 JAX

](/models?library=jax)[

Transformers

](/models?library=transformers)[

Diffusers

](/models?library=diffusers)[

GGUF

](/models?library=gguf)[

MLX

](/models?library=mlx)[

Transformers.js

](/models?library=transformers.js)[

Safetensors

](/models?library=safetensors)\+ 45\+ 47\+ 44

Apps

[

vLLM

](/models?other=vllm)[

llama.cpp

](/models?other=llama.cpp)[

MLX LM

](/models?other=mlx-lm)[

LM Studio

](/models?other=lmstudio)[

Ollama

](/models?other=ollama)[

Jan

](/models?other=jan)[

Draw Things

](/models?other=drawthings)[

DiffusionBee

](/models?other=diffusionbee)[

JoyFusion

](/models?other=joyfusion)\+ 8\+ 10

Inference Providers

[

Groq

](/models?inference_provider=groq)[

Novita

](/models?inference_provider=novita)[

Cerebras

](/models?inference_provider=cerebras)[

Nscale

](/models?inference_provider=nscale)[

fal

](/models?inference_provider=fal-ai)[

Together AI

](/models?inference_provider=together)[

Fireworks

](/models?inference_provider=fireworks-ai)[

Featherless AI

](/models?inference_provider=featherless-ai)[

Zai

](/models?inference_provider=zai-org)\+ 9\+ 11\+ 10

Hardware

[Add your hardware](/settings/hardware)

Apply filters

# Models

126

Base only Inference Available Inference

Add filters

Sort:  Trending

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

#### Qwen/Qwen3.8-Flash-Next

Image-Text-to-Text • 180B • Updated about 10 hours ago • 4.81k • 3.87k



](/Qwen/Qwen3.8-Flash-Next)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/62ecdc18b72a69615d6bd857/E4lkPz1TZNLzIFr_dR273.png)

#### unsloth/Qwen3.8-Flash-Next-GGUF

Image-Text-to-Text • 177B • Updated about 9 hours ago • 4.35k • 425



](/unsloth/Qwen3.8-Flash-Next-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6215ca5692c0ecfba9186921/hrRM50-6XcdWgg2AKpENG.jpeg)

#### Qwen/Qwen3.8-Flash-Next-FP8

Image-Text-to-Text • 180B • Updated about 10 hours ago • 2.22k • 112



](/Qwen/Qwen3.8-Flash-Next-FP8)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/692f6fa22fe03c133986059c/uVcDantaDXJOwc_T93yei.png)

#### RadixArk/Qwen3.8-Flash-Next-NVFP4

Image-Text-to-Text • 120B • Updated 1 day ago • 2.3k • 37



](/RadixArk/Qwen3.8-Flash-Next-NVFP4)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/62ecdc18b72a69615d6bd857/E4lkPz1TZNLzIFr_dR273.png)

#### unsloth/Qwen3.8-Flash-Next-FP8

Image-Text-to-Text • 180B • Updated 1 day ago • 185 • 29



](/unsloth/Qwen3.8-Flash-Next-FP8)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/69cf8fa5b7bee3980535206f/_wFUtjc_L4WrMgAdpDwKn.png)

#### AtomicChat/Qwen3.8-Flash-Next-GGUF

Text Generation • 177B • Updated about 13 hours ago • 22



](/AtomicChat/Qwen3.8-Flash-Next-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/61075042abc7b48470cd233b/IQaEC-7BHhOPRMgMoKe4g.jpeg)

#### Inferact/Qwen3.8-Flash-Next-NVFP4

Image-Text-to-Text • 118B • Updated 1 day ago • 359 • 20



](/Inferact/Qwen3.8-Flash-Next-NVFP4)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/65224256377bffdc599901c9/-qy82WgzPEAjof3QPGftY.png)

#### orcarouter/Qwen3.8-Flash-Next-Uncensored-GGUF

Image-Text-to-Text • 177B • Updated about 1 hour ago • 13



](/orcarouter/Qwen3.8-Flash-Next-Uncensored-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/no-auth/1xruBtXESAdMC_4OL_n17.png)

#### Baekpica/Qwen3.8-Flash-Next-Mixed-Quant-SSD-PLE-GGUF

Image-Text-to-Text • 129B • Updated about 4 hours ago • 13



](/Baekpica/Qwen3.8-Flash-Next-Mixed-Quant-SSD-PLE-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/6a8f4ea236ddebbe39938b7c/h9dPw76exxHsfl9NWxr9R.png)

#### VnimanieAI/Qwen3.8-Flash-Next-W4A16

Image-Text-to-Text • 180B • Updated about 8 hours ago • 12



](/VnimanieAI/Qwen3.8-Flash-Next-W4A16)

[

![](/avatars/de43830d3d5e08eef2c499aad0b2d9c8.svg)

#### agentionai/Qwen3.8-Flash-Next-ROCmFP4-FAST-GGUF

Text Generation • 177B • Updated about 15 hours ago • 11



](/agentionai/Qwen3.8-Flash-Next-ROCmFP4-FAST-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/65224256377bffdc599901c9/-qy82WgzPEAjof3QPGftY.png)

#### orcarouter/Qwen3.8-Flash-Next-Uncensored

Image-Text-to-Text • 180B • Updated about 1 hour ago • 10



](/orcarouter/Qwen3.8-Flash-Next-Uncensored)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/65224256377bffdc599901c9/-qy82WgzPEAjof3QPGftY.png)

#### orcarouter/Qwen3.8-Flash-Next-Uncensored-MLX

Image-Text-to-Text • 71B • Updated about 1 hour ago • 10



](/orcarouter/Qwen3.8-Flash-Next-Uncensored-MLX)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/635c610bfa3c172ddf40d116/pgN34290L5I0dhy0W-E8V.png)

#### Sawfwair/Qwen3.8-Flash-Next-MLX-Mixed-2bit

Image-Text-to-Text • 22B • Updated about 3 hours ago • 9



](/Sawfwair/Qwen3.8-Flash-Next-MLX-Mixed-2bit)

[

![](/avatars/113568cdd9ce763f9fcc41b4b1193880.svg)

#### kingjones777/Qwen3.8-Flash-Next-ROCmFP4-STRIX\_LEAN-GGUF

Text Generation • 177B • Updated 19 minutes ago • 9



](/kingjones777/Qwen3.8-Flash-Next-ROCmFP4-STRIX_LEAN-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/699af30d096f7e8fe8d82a11/PEWX90_WdOgBjRvqhsHix.png)

#### dealignai/Qwen3.8-Flash-Next-UNCENSORED-FP8

Image-Text-to-Text • 180B • Updated about 9 hours ago • 9



](/dealignai/Qwen3.8-Flash-Next-UNCENSORED-FP8)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/62ecdc18b72a69615d6bd857/E4lkPz1TZNLzIFr_dR273.png)

#### unsloth/Qwen3.8-Flash-Next

Image-Text-to-Text • 180B • Updated 1 day ago • 88 • 8



](/unsloth/Qwen3.8-Flash-Next)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/69cee0ca2104b525e0462a7f/JhKG4G5W_MtZcFxm5_q80.png)

#### Vontra/Qwen3.8-Flash-Next-MLX-oQ4-MTP

Image-Text-to-Text • 34B • Updated about 20 hours ago • 5



](/Vontra/Qwen3.8-Flash-Next-MLX-oQ4-MTP)

[

![](/avatars/0b664c3efdbaa63a9fd8fb630a985161.svg)

#### aixiaoma/Qwen3.8-Flash-Next-W4A16

Image-Text-to-Text • 180B • Updated about 14 hours ago • 5



](/aixiaoma/Qwen3.8-Flash-Next-W4A16)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/63220adfe4399dd613997e62/ivosS3EnM5rrXi07jk7rT.jpeg)

#### quimmedes/Qwen3.8-Flash-Next-MTP-GGUF

4B • Updated 31 minutes ago • 5



](/quimmedes/Qwen3.8-Flash-Next-MTP-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/69fe5a42b6a6a96dd074cb3c/7GCl7OKbpolob_pmAfbge.png)

#### primitive-ai/Qwen3.8-Flash-Next-NVFP4

Image-Text-to-Text • 120B • Updated about 3 hours ago • 4



](/primitive-ai/Qwen3.8-Flash-Next-NVFP4)

[

![](/avatars/113568cdd9ce763f9fcc41b4b1193880.svg)

#### kingjones777/Qwen3.8-Flash-Next-ROCmFP4-STRIX-GGUF

Text Generation • 177B • Updated 19 minutes ago • 4



](/kingjones777/Qwen3.8-Flash-Next-ROCmFP4-STRIX-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/699af30d096f7e8fe8d82a11/PEWX90_WdOgBjRvqhsHix.png)

#### dealignai/Qwen3.8-Flash-Next-ABLITERATED-FP8

Image-Text-to-Text • 180B • Updated about 9 hours ago • 4



](/dealignai/Qwen3.8-Flash-Next-ABLITERATED-FP8)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/69cee0ca2104b525e0462a7f/JhKG4G5W_MtZcFxm5_q80.png)

#### Vontra/Qwen3.8-Flash-Next-MLX-4bit

Image-Text-to-Text • 34B • Updated 1 day ago • 301 • 3



](/Vontra/Qwen3.8-Flash-Next-MLX-4bit)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/69cee0ca2104b525e0462a7f/JhKG4G5W_MtZcFxm5_q80.png)

#### Vontra/Qwen3.8-Flash-Next-MLX-oQ2

Image-Text-to-Text • 23B • Updated 1 day ago • 3



](/Vontra/Qwen3.8-Flash-Next-MLX-oQ2)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/64e6d37e02dee9bcb9d9fa18/o_HhUnXb_PgyYlqJ6gfEO.png)

#### DevQuasar/Qwen.Qwen3.8-Flash-Next-GGUF

Image-Text-to-Text • 177B • Updated about 19 hours ago • 3



](/DevQuasar/Qwen.Qwen3.8-Flash-Next-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/no-auth/1xruBtXESAdMC_4OL_n17.png)

#### Baekpica/Qwen3.8-Flash-Next-Mixed-Quant-GGUF

Image-Text-to-Text • 180B • Updated about 17 hours ago • 3



](/Baekpica/Qwen3.8-Flash-Next-Mixed-Quant-GGUF)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/64ee5432f9ed75901c09a590/odGpnOKZOmkCqch45sAbm.png)

#### inference-optimization/Qwen3.8-Flash-Next-MEP50

118B • Updated about 18 hours ago • 3



](/inference-optimization/Qwen3.8-Flash-Next-MEP50)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/69fe5a42b6a6a96dd074cb3c/7GCl7OKbpolob_pmAfbge.png)

#### primitive-ai/Qwen3.8-Flash-Next-mixed-NVFP4-FP8

Image-Text-to-Text • 120B • Updated about 3 hours ago • 3



](/primitive-ai/Qwen3.8-Flash-Next-mixed-NVFP4-FP8)

[

![](https://cdn-avatars.huggingface.co/v1/production/uploads/69cee0ca2104b525e0462a7f/JhKG4G5W_MtZcFxm5_q80.png)

#### Vontra/Qwen3.8-Flash-Next-MLX-oQ3-MTP

Image-Text-to-Text • 29B • Updated about 16 hours ago • 3



](/Vontra/Qwen3.8-Flash-Next-MLX-oQ3-MTP)

-   Previous
-   [1](?p=0&sort=trending&search=Qwen3.8-Flash-Next)
-   [2](?p=1&sort=trending&search=Qwen3.8-Flash-Next)
-   [3](?p=2&sort=trending&search=Qwen3.8-Flash-Next)
-   [...](#)
-   [5](?p=4&sort=trending&search=Qwen3.8-Flash-Next)
-   [Next](?p=1&sort=trending&search=Qwen3.8-Flash-Next)

System theme

Company

[TOS](/terms-of-service) [Privacy](/privacy) [About](/huggingface) [Careers](https://apply.workable.com/huggingface/)[](/)

Website

[Models](/models) [Datasets](/datasets) [Spaces](/spaces) [Pricing](/pricing) [Docs](/docs)
```

---

## Assistant (Plan · Claude Sonnet 5 · 93.1s)

_Thinking:_



Good, and one useful thing I checked before answering #4: within ~1 day of release there are already an official `Qwen/Qwen3.8-Flash-Next-FP8` checkpoint, community NVFP4 quants (`RadixArk/Qwen3.8-Flash-Next-NVFP4`, `Inferact/...`), and — notably — `unsloth/Qwen3.8-Flash-Next-GGUF` already exists. That last one matters for point 3 below.

## Answers to your key-finding follow-ups

**3 — do we have to use vLLM?** No. The plan already treats vLLM/SGLang/KTransformers as co-equal Phase-0 candidates, none preferred by default. I'm adding **llama.cpp as a real candidate too**, not a longshot: a GGUF conversion already exists day-1 (`unsloth/Qwen3.8-Flash-Next-GGUF`), and `feat-2` already found llama.cpp's decode path avoided the exact SM120 sparse-attention bug class that broke vLLM for `feat-1` — directly relevant here since QSA is another sparse-attention decode kernel. llama.cpp's mature `--n-cpu-moe`/`--tensor-split` flags (used successfully in `feat-2`) are also a plausible mechanism for the offload strategy in point 4.

**4 — BF16 or FP8-only?** The **base repo is BF16** (that's the default/native checkpoint) — FP8/NVFP4 are separate quantized releases, not the only option. Whether BF16 "makes sense" depends on the math:

| Configuration | Footprint | Fits in 384GB (4 GPUs)? | Fits in 192GB (2 GPUs)? |
|---|---|---|---|
| Full model (180B) BF16 | 360GB | Barely — ~24GB left for KV cache, almost certainly not enough for 768K+ | No |
| Full model (180B) FP8 | 180GB | Yes, ~204GB headroom | Barely — ~12GB left, likely not enough |
| Full model (180B) NVFP4 | ~99GB | Yes, ~285GB headroom | Yes, ~93GB headroom |
| **129B (main+MTP only, n-gram embedding offloaded)** BF16 | 258GB | Yes, ~126GB headroom | **No — 258GB > 192GB even without the embedding** |

So: straight BF16 across the whole model doesn't fit with usable context headroom on any GPU count. But your own instinct (GPU-only first, then offload for higher precision) is exactly the lever that makes BF16 viable: **offloading just the 51B n-gram embedding to system RAM frees enough VRAM that the remaining 129B can run at full BF16 on 4 GPUs with ~126GB left over for KV cache** — likely comfortable for 768–896K, though QSA's real per-token cache cost is completely unmeasured anywhere and must be tested, not assumed.

## Updated open-question answers, folded into the plan

**1 — 896K/768K**: no architectural reason it can't reach that — YaRN extends to 1,048,576 via the identical mechanism as Qwen3.8-27B, and this box has far more headroom than the DGX Spark case. The real risk is whether the chosen framework's QSA implementation supports YaRN scaling correctly yet (brand-new kernel), not raw capacity. I'll set the target as **896K, falling back to 768K if headroom doesn't clear the safety-margin policy** — same step-down discipline as `feat-3`/`feat-4`.

**2 — GPU-only first, then offload for higher precision**: restructuring into two separate phases:
- **Phase 2 (GPU-only)**: test NVFP4 and FP8 (both existing official/community checkpoints) on GPU(s) only. Straight BF16 GPU-only is excluded here per the math above — not enough headroom at any GPU count.
- **Phase 3 (hybrid offload)**: move the 51B n-gram embedding to system RAM, run the remaining 129B at BF16 on GPU. Compare quality/throughput against Phase 2's quantized result — this is the real point of comparison you're after.

**4 — GPU order (GPU0+GPU2 first, GPU1+GPU3 only if needed)**: one thing to flag before you lock this in — **the arithmetic above means Phase 3's BF16-after-offload config cannot fit on 2 GPUs regardless** (258GB > 192GB); it needs at least 3, realistically 4. So: Phase 2 (quantized, GPU-only) tries GPU0+GPU2 first, escalating to all 4 only if VRAM/headroom forces it, exactly as you said. Phase 3 (offload+BF16) starts directly at 4 GPUs since 2 is arithmetically ruled out — let me know if you'd rather I still measure that ruling-out empirically instead of skipping straight to 4.

**5 — GH issue**: I'll create it once we're out of plan mode. Draft:

> **Title**: Feature: On-prem Qwen3.8-Flash-Next serving on the Dell 7960T
> **Body**: Deploy Qwen3.8-Flash-Next (Qwen4-preview architecture) on the Dell 7960T as an OpenAI-compatible endpoint for OpenCode/OpenWebUI. Details tracked in `feat-5-qwen3.8-flash-next-dell-7960t/README.md`.

Let me know if you want that title/body wording changed.

## One more question before I write this

Given Phase 3 needs at least 3-4 GPUs at BF16, and `feat-4`'s Qwen3.8-27B already occupies GPU0+GPU2 on-demand (and `feat-1`/`feat-2` can also claim GPUs when running) — do you want me to explicitly note in Dependencies/Design Notes that **Phase 3 testing requires coordinating with whoever's using the box** (i.e., confirm no other feature's service is running first), the same way `feat-4`'s Task 0.5 did? Or is that already implicit enough given REQ-010's "manual, on-demand only" posture?

Once you confirm that, I'll write the feature file and create the GitHub issue.

---

## User

-- Phase 3: write the notes and when we are there, make sure we do not accidentally stop a production service, if one is started. But continue right away when all GPUs are free.

Any more questions?

One from my side: would the system run on 3 GPUs? or does it have to be an even number?

---

## Assistant (Build · Claude Sonnet 5 · 42.7s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "cd /home/user/src/biz.dfch.LlmOps && git remote -v && gh repo view --json nameWithOwner 2>&1 | head -5"
}
```

**Output:**
```
origin	https://github.com/dfch/biz.dfch.LlmOps.git (fetch)
origin	https://github.com/dfch/biz.dfch.LlmOps.git (push)
{"nameWithOwner":"dfch/biz.dfch.LlmOps"}

```

---

## Assistant (Build · Claude Sonnet 5 · 104.9s)

Good — repo confirmed as `dfch/biz.dfch.LlmOps`, matching the existing issue links.

## Answer to your GPU-count question

No, it doesn't have to be even, but **3 GPUs is very likely architecturally invalid for tensor-parallelism here**, for the same class of reason `feat-4` already found with Qwen3.8-27B. TP sharding requires the model's head counts to divide evenly across ranks:

- **QSA**: only **2 KV heads** — cleanly divides by 1 or 2; TP=4 needs the framework to replicate each KV head across 2 ranks (a well-supported GQA pattern, but still needs confirming, not assuming).
- **Gated DeltaNet**: **16 QK heads / 48 V heads** — divides by 1, 2, 4, 8, 16 (and 48 by 1,2,3,4,6,8...), but **16 is not divisible by 3**.

Since 16 doesn't divide evenly by 3, TP=3 fails on the Gated DeltaNet side regardless of the attention side. **Valid TP sizes are almost certainly limited to 1, 2, and 4** — I'll have Phase 2 confirm this via config-arithmetic inspection (cheap, no GPU needed) rather than wasting a GPU test on TP=3, and note it as a design fact rather than silently skip it unexplained.

No further questions from me — writing the feature file and creating the issue now.

**Tool: write**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-5-qwen3.8-flash-next-dell-7960t/README.md",
  "content": "---\nid: feat-5-qwen3.8-flash-next-dell-7960t\nversion: 1.0.0\nstatus: planning\ncreated: 2026-08-27\nupdated: 2026-08-27\n---\n\n# Feature: On-prem Qwen3.8-Flash-Next serving on the Dell 7960T\n\n## Plan\n\n### Overview\n\nDeploy `Qwen/Qwen3.8-Flash-Next` — Qwen's experimental preview of the\narchitecture underpinning Qwen4 (Gated DeltaNet + Qwen Sparse Attention\n(QSA), Gated Residual, a 51B-param N-gram Embedding, and a 512-expert MoE\nwith 10 routed + 1 shared active; 125B total language-model params (6B\nactivated) + 51B N-gram Embedding + 4B MTP = 180B total resident params)\n— on the Dell 7960T, behind an OpenAI-compatible API, for use as a coding\nmodel via OpenCode and OpenWebUI, and as a benchmark comparison point\nagainst `feat-1`'s DeepSeek-V4 and `feat-4`'s Qwen3.8-27B on the same box.\n\nThis is a standalone, isolated feature that coexists with `feat-1`\n(DeepSeek-V4), `feat-2` (GLM-5.2), and `feat-4` (Qwen3.8-27B) on the same\nDell 7960T — it does not replace or modify any of them, including\n`feat-1`'s still-unstarted DeepSeek-V4-Pro slot (which this model is\narchitecturally comparable to as a \"hybrid GPU+RAM MoE-class\" candidate,\nbut that comparison is discussion only, not scope here).\n\nQwen3.8-Flash-Next ships under `qwen-community-1.0`, not Apache-2.0 like\nevery other model on this box — reviewed and explicitly accepted\n(2026-08-27): this repo's existing anonymous/internal-network-only\nposture satisfies the license's \"Model as a Service\"/\"AI Work Assistant\"\ncarve-out, since the model, its outputs, and its capabilities are never\nexposed to a third party.\n\nUnlike `feat-3`/`feat-4`'s Qwen3.8-27B, capacity is not the binding\nconstraint here — at FP8 or NVFP4 the model comfortably fits the Dell\n7960T's 384GB discrete VRAM. The open questions are (a) whether any\navailable inference framework supports this brand-new architecture at\nall yet, (b) whether QSA — a novel sparse-attention decode kernel —\nreproduces the exact degenerate-output bug class `feat-1` already hit and\nescalated upstream on this same SM120 GPU family, and (c) which\nprecision/placement strategy (GPU-only quantized vs. a hybrid placement\nthat offloads the N-gram Embedding to system RAM to allow full BF16 for\nthe rest) gives the best quality/throughput/context tradeoff.\n\n### Requirements\n\n- REQ-001: Serve Qwen3.8-Flash-Next via an OpenAI-compatible API\n  (`/v1/chat/completions`) on the Dell 7960T, fully isolated from\n  `feat-1`/`feat-2`/`feat-4`'s install trees and systemd units (dedicated\n  `/data/qwen3.8-flash-next/` tree, own venv/build, only the read-only HF\n  cache shared)\n- REQ-002: Confirm, before any deployment work, that an available\n  inference framework (vLLM, SGLang, KTransformers, or llama.cpp —\n  none preferred by default; a GGUF conversion, `unsloth/Qwen3.8-Flash-Next-GGUF`, already exists as of feature creation, making\n  llama.cpp a real candidate, not a longshot) actually supports this\n  model's architecture (`qwen4_exp` tag: Gated DeltaNet, QSA, Gated\n  Residual, N-gram Embedding, this MoE config) and exposes the flags its\n  own model card documents — treated as a hard gate, not assumed\n- REQ-003: Before any long-context or precision work, run a native/short-\n  context correctness smoke test that explicitly checks for `feat-1`'s\n  known degenerate-output signature (single frozen token / identical\n  logprob at every decode position). QSA is a novel sparse-attention\n  decode kernel being run on the exact GPU family (SM120) where a\n  different sparse-attention decode kernel (vLLM's\n  `FLASHINFER_MLA_SPARSE_DSV4`) is already known-broken and escalated\n  upstream (vllm-project/vllm#52938) — this is a hard gate, not a\n  formality\n- REQ-004: Target a **896K-token context**, falling back to **768K** if\n  896K does not clear the adopted safety-margin policy (reused from\n  `feat-3`/`feat-4`: >=15% free or >=10 GiB absolute, whichever is\n  greater). No architectural reason is known to prevent 768K-896K — YaRN\n  extends this model to 1,048,576 via the identical `rope_parameters`\n  mechanism as Qwen3.8-27B — but QSA's real per-token\n  memory/state cost is completely unmeasured anywhere and must be\n  measured, not assumed, before committing to a context size\n- REQ-005: The endpoint must support tool-calling (required for OpenCode\n  agentic use) and Qwen3.8-Flash-Next's thinking controls\n  (`enable_thinking`, `reasoning_effort`: xhigh/medium/low,\n  `preserve_thinking`)\n- REQ-006: Evaluate precision/placement in two distinct phases, in this\n  order (user decision 2026-08-27):\n  1. **GPU-only, quantized** (official `Qwen/Qwen3.8-Flash-Next-FP8` and/\n     or a community NVFP4 checkpoint, e.g. `RadixArk/Qwen3.8-Flash-Next-NVFP4`) — straight BF16 GPU-only is\n     excluded from this phase: the full 180B model at BF16 (360GB) does\n     not leave usable KV-cache headroom even across all 4 GPUs (384GB)\n  2. **Hybrid offload for higher precision**: offload the 51B N-gram\n     Embedding to system RAM (exploiting its documented\n     offload-friendly design), running the remaining 129B\n     (main model + MTP) at full BF16 on GPU (258GB, fits 4 GPUs'\n     384GB with ~126GB headroom). This is the path that makes BF16\n     viable at all on this hardware.\n     Compare quality/throughput/headroom between the two phases; no\n     precision is adopted as default before this comparison\n- REQ-007: Determine empirically (not assumed) the GPU count/placement,\n  in this preference order (user decision 2026-08-27):\n  1. For REQ-006 phase 1 (GPU-only quantized): try **GPU0+GPU2** (2 GPUs,\n     the box's two PCIe Gen5 x16 cards per `feat-4`'s finding) first;\n     escalate to all 4 GPUs (adding GPU1+GPU3) only if VRAM/headroom at\n     2 GPUs proves insufficient\n  2. For REQ-006 phase 2 (hybrid offload + BF16): **4 GPUs from the\n     start** — 258GB of GPU-resident BF16 weights does not fit in 2\n     GPUs' 192GB regardless of context/KV-cache headroom, so 2 GPUs is\n     arithmetically excluded here, not just empirically deprioritized\n  3. **TP=3 is treated as architecturally invalid, not merely\n     deprioritized**: confirmed via head-count arithmetic (cheap,\n     config-only check, no GPU test needed) before any GPU work —\n     Gated DeltaNet's 16 QK linear-attention heads are not divisible by\n     3, and QSA's 2 KV heads are not divisible by 3 either. Only TP=1,\n     2, and 4 are expected to be valid; TP=4 requires the framework to\n     support KV-head replication (2 KV heads across 4 ranks), which must\n     still be confirmed, not assumed\n- REQ-008: Pin `Qwen/Qwen3.8-Flash-Next` (and whichever quantized\n  checkpoint(s) are used) to specific Hugging Face revisions/commits (not\n  \"latest\") for reproducibility\n- REQ-009: The endpoint runs unauthenticated (anonymous, no API-key/auth\n  layer), internal network only — same posture as `feat-1`/`feat-2`/\n  `feat-4`. Confirmed (2026-08-27, user decision) to satisfy the\n  `qwen-community-1.0` license's internal-use carve-out\n- REQ-010: The engine runs as a **standalone, manually-started systemd\n  `--user` service** (lingering enabled, never auto-started at boot, no\n  variant auto-promoted to \"the\" production default) — matching\n  `feat-4`'s on-demand posture, given this model's large GPU footprint\n  makes always-on coexistence with `feat-1`/`feat-2`/`feat-4` impractical\n- REQ-011: Record the model's actual per-GPU/system-RAM memory footprint\n  at each tested precision/placement/context, and whether any headroom\n  remains for coexistence with the box's other features\n- REQ-012: Before any Phase 3 (hybrid offload) testing that needs 4\n  GPUs, check whether another feature's production service\n  (`feat-1`/`feat-2`/`feat-4`) is currently running. If one is, **wait\n  for it to be stopped by its owner — never stop another feature's\n  running service from this feature's tooling/scripts.** Proceed\n  immediately once all GPUs are confirmed free; do not add any artificial\n  delay beyond that check\n\n### Acceptance Criteria\n\n- [ ] ACC-001: Verifies REQ-002 — a specific framework + version is\n  confirmed (via direct inspection, not assumption) to register this\n  model's architecture and expose its required serving flags; if none do,\n  this is recorded as a blocking finding, not silently worked around\n- [ ] ACC-002: Verifies REQ-003 — native-context smoke test does NOT\n  reproduce `feat-1`'s degenerate-output signature; if it does, treated as\n  a blocking finding requiring escalation before any further work\n- [ ] ACC-003: Verifies REQ-001/REQ-009 — service reachable via\n  `/v1/chat/completions`, confirmed fully isolated from `feat-1`/`feat-2`/\n  `feat-4` (their services/GPUs untouched), confirmed unauthenticated/\n  internal-only by design\n- [ ] ACC-004: Verifies REQ-004 — empirical test confirms the chosen\n  context target (896K, or 768K fallback) works without OOM on a real\n  filled-context prompt\n- [ ] ACC-005: Verifies REQ-005 — tool-call and all three thinking-control\n  modes verified via curl, then via a real OpenCode agentic session\n- [ ] ACC-006: Verifies REQ-006/REQ-007 — both the GPU-only-quantized\n  phase and the hybrid-offload-BF16 phase are measured and recorded (not\n  skipped), with a final comparison and one-line rationale for whichever\n  configuration is kept as the primary reference, even if both remain\n  available on-demand\n- [ ] ACC-007: Verifies REQ-007's TP=3 exclusion — recorded as a\n  config-arithmetic finding (head-count divisibility), not an\n  unexplained gap in the tested TP sizes\n- [ ] ACC-008: Verifies REQ-008 — deployment config records the exact HF\n  revision/commit hash used for every checkpoint (base BF16, FP8, and/or\n  NVFP4) actually used\n- [ ] ACC-009: Verifies REQ-010 — service is a disabled, manually-started\n  `systemctl --user` unit throughout testing and use; no variant\n  auto-started or auto-promoted\n- [ ] ACC-010: Verifies REQ-011 — a recorded decision on remaining\n  headroom / coexistence feasibility with the box's other features, for\n  each tested configuration\n- [ ] ACC-011: Verifies REQ-012 — Phase 3 work is confirmed to have\n  waited for GPU availability where needed, with no incident of another\n  feature's running service being stopped by this feature's work\n- [ ] ACC-012: User runs the same coding-task examples used for `feat-1`/\n  `feat-2`/`feat-4` against this endpoint, for a direct quality/throughput\n  comparison\n\n### Scope\n\nWhat is included:\n\n- Framework/architecture support verification (hard gate) across vLLM,\n  SGLang, KTransformers, and llama.cpp before any other work\n- A dedicated, isolated install tree, venv/build, and systemd unit(s)\n- Native-context degenerate-output smoke test (hard gate, mirroring\n  `feat-1`/`feat-2`/`feat-4`)\n- Phase A: GPU-only quantized (FP8 and/or NVFP4) placement and throughput\n  measurement, starting at GPU0+GPU2\n- Phase B: hybrid offload (N-gram Embedding to system RAM) enabling full\n  BF16 for the remaining 129B, at 4 GPUs\n- Config-arithmetic confirmation that TP=3 is architecturally invalid\n- YaRN-based context extension targeting 896K (768K fallback)\n- OpenWebUI/OpenCode wiring\n- License-posture confirmation (internal-use carve-out) — already\n  resolved, recorded here for the record\n\nWhat is explicitly out of scope:\n\n- Any modification to `feat-1`/`feat-2`/`feat-4`'s deployments, venvs,\n  systemd units, or GPU allocation — including never stopping another\n  feature's running production service from this feature's tooling\n- Vision/video capability testing (text/coding only, matching this\n  repo's precedent for other native VLMs)\n- Treating this as a replacement for `feat-1`'s DeepSeek-V4-Pro slot —\n  that remains a separate, independent decision\n- Any production/always-on promotion — this stays on-demand,\n  manually-started only\n- Acquiring additional hardware\n\n### Dependencies\n\n- Depends on: the Dell 7960T's existing driver/CUDA stack (validated by\n  `feat-1`/`feat-2`/`feat-4` — driver 610.57.04, CUDA 13.3, 4x SM120\n  GPUs); a framework version that actually supports `qwen4_exp`\n  (unconfirmed — REQ-002); sufficient disk headroom for the checkpoint(s)\n  actually pulled (BF16 base ~360GB, FP8 ~180GB, NVFP4 ~90-100GB — not\n  all three need downloading at once; check current `/data` free space\n  fresh, since `feat-4`'s last measurement (6.9TB free) predates this\n  feature's own downloads)\n- Related (not a hard dependency): `feat-1`'s open, unresolved SM120\n  sparse-attention-decode bug (vllm-project/vllm#52938) — directly\n  relevant given QSA is also a sparse-attention decode kernel; `feat-2`'s\n  finding that llama.cpp's DSA decode path is correct on this hardware\n  while vLLM's is broken — suggests engine choice, not SM120 hardware\n  itself, may again be the discriminator here; `feat-4`'s TP=3-invalid\n  finding for a different model (Qwen3.8-27B, num_kv_heads=4) is the\n  precedent for this feature's own TP=3 exclusion (num_kv_heads=2 here)\n- Blocks: none\n\n### Design Notes\n\n- **Model facts (verified from HF 2026-08-27)**: `Qwen/Qwen3.8-Flash-Next`,\n  `qwen-community-1.0`, native VLM, 125B total language-model params (6B\n  activated) + 51B N-gram Embedding + 4B MTP = 180B total resident.\n  Hybrid layout: 12x (3x (Gated DeltaNet -> MoE) -> 1x (QSA -> MoE)), 48\n  layers. QSA: 24 Q heads / **2 KV heads**, head dim 256, MQA-style\n  indexer (4 query heads, 1 shared key head), budget 512 blocks / 2048\n  tokens. Gated DeltaNet: **16 QK heads**, 48 V heads, head dim 128. MoE:\n  512 experts, 10 routed + 1 shared active, expert intermediate dim 640.\n  Context: 262,144 native, extensible to 1,048,576 via YaRN (identical\n  `rope_parameters` shape to Qwen3.8-27B/Qwen3.8-Flash-Next family).\n- **Footprint arithmetic (why Phase A excludes BF16 and Phase B needs 4\n  GPUs)**:\n\n  | Configuration | Footprint | Fits 2 GPUs (192GB)? | Fits 4 GPUs (384GB)? |\n  |---|---|---|---|\n  | Full model (180B) BF16 | 360GB | No | Barely (~24GB left — not enough for 768K+) |\n  | Full model (180B) FP8 | 180GB | Barely (~12GB left) | Yes (~204GB headroom) |\n  | Full model (180B) NVFP4 | ~99GB | Yes (~93GB headroom) | Yes (~285GB headroom) |\n  | 129B (offload N-gram Embedding) BF16 | 258GB | **No (258GB > 192GB)** | Yes (~126GB headroom) |\n\n  This table drives REQ-006/REQ-007's phase ordering directly: Phase A\n  (GPU-only) most likely only works well at NVFP4 on 2 GPUs, with FP8 as\n  the 2-GPU stretch case and the reliable fallback at 4 GPUs; Phase B\n  (offload + BF16) is only attempted at 4 GPUs since 2 is arithmetically\n  ruled out, not just empirically deprioritized.\n- **TP=3 exclusion, precedent from `feat-4`**: `feat-4` found Qwen3.8-27B\n  could not run at TP=3 because its `num_key_value_heads=4` doesn't\n  divide by 3. This feature's QSA has only 2 KV heads (also not divisible\n  by 3) AND Gated DeltaNet has 16 QK heads (also not divisible by 3) —\n  two independent architectural reasons TP=3 is expected to be invalid,\n  not one. Confirm via config inspection before any GPU time is spent;\n  do not attempt a live TP=3 test. TP=4 needs the framework to support KV\n  -head replication (2 heads across 4 ranks) — a common, well-supported\n  GQA pattern, but must be confirmed for this specific framework/model\n  combination, not assumed from precedent alone.\n- **QSA is the single largest unvalidated risk in this plan.** It is a\n  brand-new sparse-attention decode kernel with no production track\n  record anywhere, being tested on the exact GPU family where a\n  different sparse-attention decode kernel (vLLM's\n  `FLASHINFER_MLA_SPARSE_DSV4`) is already known-broken and escalated\n  upstream. Phase 1's smoke test is a hard gate, not a formality.\n- **Framework choice is genuinely open.** vLLM 0.26.0 (this box's\n  validated version) almost certainly predates `qwen4_exp` support. The\n  model card points at vLLM/SGLang/KTransformers \"latest\" recipes without\n  a pinned minimum version in what's been reviewed so far — Phase 0 must\n  check the actual linked recipe pages, not assume parity with\n  Qwen3.8-27B's requirements. A GGUF conversion\n  (`unsloth/Qwen3.8-Flash-Next-GGUF`) already exists, making llama.cpp a\n  real candidate — worth checking given `feat-2`'s precedent that\n  llama.cpp's decode path avoided the SM120 sparse-attention bug class\n  that blocks `feat-1`'s vLLM deployment.\n- **License posture (resolved 2026-08-27)**: `qwen-community-1.0` permits\n  internal use freely; the \"Model as a Service\"/\"AI Work Assistant\"\n  carve-out requires a separate Qwen license only if the model, its\n  outputs, or its capabilities are exposed to a third party. This repo's\n  anonymous-but-internal-network-only posture clears this — explicitly\n  confirmed by the user, not silently inherited from the auth-risk\n  precedent.\n- **Phase 3 (hybrid offload) GPU-coordination rule (user decision\n  2026-08-27)**: before starting any 4-GPU Phase 3 work, check whether\n  `feat-1`/`feat-2`/`feat-4` has a production service currently running.\n  If so, **wait — do not stop it.** Proceed the moment all GPUs are\n  confirmed free, with no added delay beyond that check. This mirrors\n  `feat-4`'s Task 0.5 pre-flight check, but adds an explicit\n  non-interference guarantee since this feature is more likely to need\n  the whole box at once.\n\n### Related ADRs\n\n- None (infrastructure/deployment work, tracked using this repo's\n  feature-folder convention, same as `feat-1`-`feat-4`)\n\n### Task List\n\n#### Phase 0: Framework/architecture support verification (hard gate)\n\n- [ ] Task 0.1: Confirm disk headroom under `/data` for whichever\n  checkpoint(s) are pulled first (start with FP8 ~180GB and/or NVFP4\n  ~90-100GB; BF16 base ~360GB only if/when Phase B is reached) — depends\n  on: none — status: not-started\n- [ ] Task 0.2: For each of vLLM (this box's existing 0.26.0, and latest\n  stable), SGLang, KTransformers, and llama.cpp: check whether it\n  registers this model's architecture tag and exposes the serving flags\n  the model card documents (QSA, Gated Residual, N-gram Embedding, this\n  MoE config) — depends on: none — status: not-started\n- [ ] Task 0.3: If no stable release supports it, evaluate the risk/\n  effort of a nightly/dev build vs. treating this feature as blocked\n  pending upstream support — depends on: Task 0.2 — status: not-started\n- [ ] Task 0.4: Build a fully isolated venv/install tree\n  (`/data/qwen3.8-flash-next/`), independent of `feat-1`/`feat-2`/\n  `feat-4`'s trees — depends on: Task 0.3 — status: not-started\n- [ ] Task 0.5: Pin and download the checkpoint(s) needed for Phase 2\n  (FP8 and/or NVFP4) to a specific HF revision — depends on: Task 0.1 —\n  status: not-started\n- [ ] Task 0.6: Confirm `feat-1`/`feat-2`/`feat-4`'s current live state\n  (to avoid GPU contention during this feature's own testing) — depends\n  on: none — status: not-started\n- [ ] Task 0.7: Confirm via config-arithmetic (no GPU test) that TP=3 is\n  invalid (Gated DeltaNet's 16 QK heads and QSA's 2 KV heads are both\n  not divisible by 3); confirm the chosen framework supports TP=4's\n  required KV-head replication (2 heads across 4 ranks) — depends on:\n  Task 0.2 — status: not-started\n\n#### Phase 1: Native-context correctness smoke test (hard gate)\n\n- [ ] Task 1.1: Bring up the model at short/native context, no YaRN\n  override yet — depends on: Task 0.4, Task 0.5 — status: not-started\n- [ ] Task 1.2: Temperature=0 smoke test — explicitly check for `feat-1`'s\n  exact degenerate-output signature; verify tool-calling and thinking-\n  control modes — depends on: Task 1.1 — status: not-started\n- [ ] Task 1.3: Record the outcome — if degenerate, this is a blocking\n  finding requiring escalation before any further work — depends on:\n  Task 1.2 — status: not-started\n\n#### Phase 2: GPU-only quantized placement (FP8 / NVFP4)\n\n- [ ] Task 2.1: Benchmark NVFP4 at GPU0+GPU2 (TP=2) first — depends on:\n  Task 1.3, Task 0.7 — status: not-started\n- [ ] Task 2.2: Benchmark FP8 at GPU0+GPU2 (TP=2); expected to be tight\n  per the footprint table — depends on: Task 2.1 — status: not-started\n- [ ] Task 2.3: If either precision's headroom is insufficient at 2 GPUs,\n  escalate to all 4 GPUs (TP=4) and re-measure — depends on: Task 2.2 —\n  status: not-started\n- [ ] Task 2.4: Record the chosen GPU-only production config (precision +\n  GPU count) with measured data — depends on: Task 2.3 — status:\n  not-started\n\n#### Phase 3: Hybrid offload for full BF16 (N-gram Embedding -> system RAM)\n\n- [ ] Task 3.0: **Pre-flight GPU-availability check** — confirm whether\n  `feat-1`/`feat-2`/`feat-4` has a production service currently running.\n  If yes, wait — do not stop it. Proceed the moment all 4 GPUs are\n  confirmed free, with no added delay — depends on: Task 2.4 — status:\n  not-started\n- [ ] Task 3.1: Determine whether the chosen framework supports placing\n  only the N-gram Embedding on system RAM while keeping the rest\n  GPU-resident (KTransformers-style, or llama.cpp's `--n-cpu-moe`/\n  `--tensor-split`-style placement, per `feat-2`'s precedent) — depends\n  on: Task 3.0 — status: not-started\n- [ ] Task 3.2: Bring up the 129B (main + MTP) at BF16 across all 4 GPUs\n  with the N-gram Embedding offloaded to system RAM — depends on: Task\n  3.1 — status: not-started\n- [ ] Task 3.3: Benchmark throughput/quality and compare against Phase\n  2's chosen quantized config — depends on: Task 3.2 — status:\n  not-started\n- [ ] Task 3.4: Record the comparison and a one-line rationale for\n  whichever configuration(s) remain available on-demand — depends on:\n  Task 3.3 — status: not-started\n\n#### Phase 4: Context extension (896K target, 768K fallback)\n\n- [ ] Task 4.1: Apply YaRN override targeting 896K; measure headroom on\n  whichever configuration(s) Phase 2/3 kept — depends on: Task 2.4,\n  Task 3.4 — status: not-started\n- [ ] Task 4.2: If 896K does not clear the safety-margin policy, step\n  down to 768K and re-measure — depends on: Task 4.1 — status:\n  not-started\n- [ ] Task 4.3: Validate with a real filled-context request (built from\n  the model's own tokenizer) — depends on: Task 4.2 — status: not-started\n\n#### Phase 5: Deployment + integration\n\n- [ ] Task 5.1: Install as a standalone, manually-started, disabled\n  `systemctl --user` service (or one per kept configuration) — depends\n  on: Task 4.3 — status: not-started\n- [ ] Task 5.2: Curl smoke test against production config(s) — depends\n  on: Task 5.1 — status: not-started\n- [ ] Task 5.3: Connect OpenCode/OpenWebUI — depends on: Task 5.2 —\n  status: not-started\n- [ ] Task 5.4: User runs the same coding-task examples as `feat-1`/\n  `feat-2`/`feat-4` for comparison — depends on: Task 5.3 — status:\n  not-started\n\n**Note:** If a task's scope changes mid-flight, edit its description in place;\nrely on git history (`git log -p` on this file) to recover what was\noriginally planned, rather than keeping a second copy of the task around.\n\n## Progress\n\n### Current Status\n\n**As of 2026-08-27**: Feature scaffolded and planned. No environment work\nstarted yet.\n\n### Recent Updates\n\n#### 2026-08-27\n\n- Completed: researched Qwen3.8-Flash-Next's architecture (QSA, Gated\n  Residual, N-gram Embedding, MoE config), confirmed license\n  (`qwen-community-1.0`) and its internal-use carve-out, confirmed\n  official FP8 and community NVFP4/GGUF checkpoints already exist,\n  resolved footprint arithmetic driving the two-phase precision plan\n  (GPU-only quantized vs. hybrid-offload BF16), resolved GPU-count\n  preference order and the TP=3 architectural exclusion, resolved the\n  Phase 3 GPU-coordination rule (wait, never stop another feature's\n  running service) through discussion with user; feature folder\n  scaffolded and GitHub issue #5 created.\n- Next: begin Phase 0 (framework/architecture support verification).\n\n### Decisions Made\n\n- **2026-08-27**: `qwen-community-1.0` license accepted — this repo's\n  anonymous/internal-network-only posture satisfies the \"Model as a\n  Service\"/\"AI Work Assistant\" carve-out (no third-party exposure of the\n  model, its outputs, or its capabilities).\n- **2026-08-27**: QSA's status as a novel, unvalidated sparse-attention\n  decode kernel on the same SM120 GPU family where `feat-1` already hit\n  an unresolved sparse-attention decode bug is noted and accepted as a\n  known risk — Phase 1's smoke test is the mitigation, not a guarantee.\n- **2026-08-27**: No engine preference — vLLM, SGLang, KTransformers, and\n  llama.cpp are co-equal Phase 0 candidates; llama.cpp is elevated from\n  \"unlikely\" to a real candidate given `unsloth/Qwen3.8-Flash-Next-GGUF`\n  already exists and `feat-2`'s precedent that llama.cpp avoided the\n  SM120 sparse-attention bug class that blocks `feat-1`.\n- **2026-08-27**: Precision/placement evaluated in two ordered phases —\n  GPU-only quantized (FP8/NVFP4) first, then a hybrid offload of the\n  N-gram Embedding to system RAM specifically to enable full BF16 for\n  the remaining 129B — rather than picking one precision by default.\n- **2026-08-27**: GPU preference order — GPU0+GPU2 first for the\n  GPU-only-quantized phase (escalate to all 4 only if needed); the\n  hybrid-offload-BF16 phase starts directly at 4 GPUs since 2 GPUs\n  (192GB) cannot fit 258GB of BF16-resident weights regardless of\n  context headroom.\n- **2026-08-27**: TP=3 is treated as architecturally invalid (Gated\n  DeltaNet's 16 QK heads and QSA's 2 KV heads are both not divisible by\n  3) and will be confirmed via config arithmetic, not a live GPU test —\n  precedent: `feat-4` found the same class of exclusion for Qwen3.8-27B's\n  4 KV heads.\n- **2026-08-27**: Phase 3 (hybrid offload) must never stop another\n  feature's running production service — if one is running when Phase 3\n  work is ready to start, wait for it to be stopped by its owner, then\n  proceed immediately once all GPUs are confirmed free.\n\n### Related PRs / Commits\n\n- [Issue #5](https://github.com/dfch/biz.dfch.LlmOps/issues/5): On-prem\n  Qwen3.8-Flash-Next serving on the Dell 7960T\n</content>\n"
}
```

**Output:**
```
Wrote file successfully.
```

---

## Assistant (Build · Claude Sonnet 5 · 6.5s)

Now creating the GitHub issue:

**Tool: bash**

**Input:**
```json
{
  "command": "cd /home/user/src/biz.dfch.LlmOps && gh issue create \\\n  --title \"Feature: On-prem Qwen3.8-Flash-Next serving on the Dell 7960T\" \\\n  --body \"Deploy Qwen3.8-Flash-Next (Qwen4-preview architecture) on the Dell 7960T as an OpenAI-compatible endpoint for OpenCode/OpenWebUI. Details tracked in \\`feat-5-qwen3.8-flash-next-dell-7960t/README.md\\`.\""
}
```

**Output:**
```
https://github.com/dfch/biz.dfch.LlmOps/issues/5

```

---

## Assistant (Build · Claude Sonnet 5 · 5.5s)

_Thinking:_



I should add the `github_issue` frontmatter field to match the convention used in `feat-1`–`feat-4`. Let me fix that.

**Tool: read**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-5-qwen3.8-flash-next-dell-7960t/README.md",
  "limit": 10
}
```

**Output:**
```
<path>/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-5-qwen3.8-flash-next-dell-7960t/README.md</path>
<type>file</type>
<content>
1: ---
2: id: feat-5-qwen3.8-flash-next-dell-7960t
3: version: 1.0.0
4: status: planning
5: created: 2026-08-27
6: updated: 2026-08-27
7: ---
8: 
9: # Feature: On-prem Qwen3.8-Flash-Next serving on the Dell 7960T
10: 

(Showing lines 1-10 of 473. Use offset=11 to continue.)
</content>
```

---

## Assistant (Build · Claude Sonnet 5 · 4.7s)

**Tool: edit**

**Input:**
```json
{
  "filePath": "/home/user/src/biz.dfch.LlmOps/.specmgr/feat/feat-5-qwen3.8-flash-next-dell-7960t/README.md",
  "oldString": "---\nid: feat-5-qwen3.8-flash-next-dell-7960t\nversion: 1.0.0\nstatus: planning\ncreated: 2026-08-27\nupdated: 2026-08-27\n---",
  "newString": "---\ncreated: 2026-08-27\ngithub_issue: 5\nid: feat-5-qwen3.8-flash-next-dell-7960t\nstatus: planning\nupdated: 2026-08-27\nversion: 1.0.0\n---"
}
```

**Output:**
```
Edit applied successfully.
```

---

## Assistant (Build · Claude Sonnet 5 · 5.4s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "cd /home/user/src/biz.dfch.LlmOps && git status --short"
}
```

**Output:**
```
?? .specmgr/feat/feat-5-qwen3.8-flash-next-dell-7960t/

```

---

## Assistant (Build · Claude Sonnet 5 · 10.1s)

Done. Summary:

- **Feature file created**: `.specmgr/feat/feat-5-qwen3.8-flash-next-dell-7960t/README.md`, following the exact structure/frontmatter convention of `feat-1`–`feat-4`.
- **GitHub issue created**: [#5](https://github.com/dfch/biz.dfch.LlmOps/issues/5), short 2-line body as requested, cross-linked in both directions (frontmatter `github_issue: 5` and the "Related PRs / Commits" section).
- **Everything from our discussion is captured**: license acceptance, QSA/SM120 risk acknowledgment, framework-agnostic Phase 0 (vLLM/SGLang/KTransformers/llama.cpp, with llama.cpp elevated given the existing GGUF conversion), the two-phase precision plan (GPU-only quantized first, then hybrid N-gram-embedding offload for full BF16), GPU preference order (GPU0+GPU2 first, escalate only if needed; 4 GPUs mandatory for the BF16 phase), TP=3's architectural exclusion with the underlying arithmetic, the 896K→768K context fallback, and the Phase 3 GPU-coordination rule (wait, never stop another feature's running service).

Nothing has been committed to git — the new file is untracked (`git status` shows it as `??`). Let me know if you'd like me to commit it, or if you want to start on Phase 0 now.

---

## User

commit and push

---

## Assistant (Build · Claude Sonnet 5 · 9.6s)

_Thinking:_



**Tool: bash**

**Input:**
```json
{
  "command": "cd /home/user/src/biz.dfch.LlmOps && git status && echo --- && git log --oneline -10"
}
```

**Output:**
```
On branch dev
Your branch is up to date with 'origin/dev'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.specmgr/feat/feat-5-qwen3.8-flash-next-dell-7960t/

nothing added to commit but untracked files present (use "git add" to track)
---
5da6ad2 chore: file session logs into their feature folders, mdformat both
e6d3fc2 chore: track *.log files under feature folders as evidence, not app logs
a8360f1 feat(feat-4): deploy qwen3.8-27b on Dell 7960T, TP=2/896K production, log TP=4 hardware instability
86a815a feat(feat-3): complete qwen3.8-27b-large-context deployment and validation
24bf9b1 feat(qwen3.8): complete phase 4
4d09260 feat(qwen3.8): complete phase 2
acc9de8 feat(qwen3.8): complete phase 1
4c971e7 docs(qwen3.8): log Phase 0 completion on DGX, record Phase 1 memory blocker
0e5ad85 feat(qwen3.8): re-target deployment to Dell GB10 (DGX Spark clone)
1383396 feat(qwen3.8): add feature qwen3.8 with large context length

```

---

## Assistant (Build · Claude Sonnet 5 · 4.3s)

Commit style uses Conventional Commits with a `feat(feat-N)` scope. Following that convention:

**Tool: bash**

**Input:**
```json
{
  "command": "cd /home/user/src/biz.dfch.LlmOps && git add .specmgr/feat/feat-5-qwen3.8-flash-next-dell-7960t/ && git status --short"
}
```

**Output:**
```
A  .specmgr/feat/feat-5-qwen3.8-flash-next-dell-7960t/README.md

```

---

## Assistant (Build · Claude Sonnet 5 · 8.6s)

**Tool: bash**

**Input:**
```json
{
  "command": "cd /home/user/src/biz.dfch.LlmOps && git commit -m \"feat(feat-5): scaffold Qwen3.8-Flash-Next deployment plan for Dell 7960T\n\n- New standalone feature, isolated from feat-1/feat-2/feat-4\n- License (qwen-community-1.0) reviewed and accepted: internal/no-auth\n  posture satisfies the Model-as-a-Service/AI-Work-Assistant carve-out\n- Phase 0 hard gate: framework support check across vLLM/SGLang/\n  KTransformers/llama.cpp (none preferred by default)\n- Phase 1 hard gate: native-context smoke test for feat-1's known SM120\n  degenerate-output signature, since QSA is a novel sparse-attention\n  decode kernel on the same GPU family\n- Two-phase precision plan: GPU-only quantized (FP8/NVFP4) first, then\n  hybrid N-gram-embedding-offload to enable full BF16 on the remaining\n  129B, backed by explicit footprint arithmetic\n- GPU order: GPU0+GPU2 first for the quantized phase, 4 GPUs mandatory\n  for the BF16 phase; TP=3 excluded via head-count arithmetic\n- 896K context target with 768K fallback; Phase 3 GPU-coordination rule\n  (wait for other features' services, never stop them)\n\nRefs #5\""
}
```

**Output:**
```
[dev aa8cd00] feat(feat-5): scaffold Qwen3.8-Flash-Next deployment plan for Dell 7960T
 1 file changed, 474 insertions(+)
 create mode 100644 .specmgr/feat/feat-5-qwen3.8-flash-next-dell-7960t/README.md

```

---

## Assistant (Build · Claude Sonnet 5 · 6.1s)

**Tool: bash**

**Input:**
```json
{
  "command": "cd /home/user/src/biz.dfch.LlmOps && git push origin dev"
}
```

**Output:**
```
To https://github.com/dfch/biz.dfch.LlmOps.git
   5da6ad2..aa8cd00  dev -> dev

```

---

## Assistant (Build · Claude Sonnet 5 · 4.0s)

Committed and pushed to `dev` (`aa8cd00`). The feature file for `feat-5-qwen3.8-flash-next-dell-7960t` is now live, linked to [issue #5](https://github.com/dfch/biz.dfch.LlmOps/issues/5).

Ready to start on Phase 0 (framework/architecture support verification) whenever you want to proceed.

---

