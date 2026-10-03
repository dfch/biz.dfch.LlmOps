---
classification: null
created: '2026-10-03T11:20:46.114+02:00'
id: feat-9-vllm-load-balancer
status: planning
type: feat
updated: '2026-10-03T13:49:08.458+02:00'
version: 1.0.0
---

# Feature: Load-Balance OpenCode Sessions Across vLLM Replicas

## Plan

### Overview

We run 2 vLLM instances hosting the same model with identical parameters. Today, 4 OpenCode (OC) sessions are manually split 2-and-2 across the two instances by hand-editing each session's provider `baseURL`. This feature replaces that manual assignment with automatic load-balancing via a reverse proxy, while respecting a hard per-backend concurrency cap and (pending investigation) preserving vLLM KV-cache/prefix-cache locality for long-context conversations.

Research performed before this feature was created (see Decisions Made):
- OpenCode's own config (`opencode.json`) has no multi-backend/pool concept — `provider.*.options.baseURL` is a single URL, loaded once at startup. Load balancing must happen in front of the vLLM instances, with every OC session pointed at one single endpoint.
- Each OC assistant turn is an independent streamed HTTP request, not a long-lived connection held for the whole (8+ hour) session — confirmed via the per-request `timeout`/`headerTimeout`/`chunkTimeout` provider options in the opencode.json schema. Reverse-proxy `least_conn`/`leastconn` algorithms count active in-flight requests, not idle keep-alive sockets, so this is safe regardless of OC's HTTP client pooling behavior.
- Real risk: vLLM's automatic prefix caching (APC) is per-instance/in-GPU-memory. If a single conversation's turns land on different backends turn-to-turn, each backend must fully re-prefill the growing context from scratch — a severe cost at this repo's 350–370K-token context target. Needs empirical confirmation before finalizing routing policy.
- Of the common reverse-proxy choices, only HAProxy natively supports a hard per-backend concurrency ceiling with graceful backpressure (`maxconn` + `timeout queue`, requests queue instead of erroring past the cap). Open-source nginx's `max_conns` has no open-source queuing (NGINX Plus only); Caddy has no native per-upstream hard cap. HAProxy is the working assumption pending Phase 000 findings.

### Requirements

- REQ-001: OpenCode sessions must not require manual per-session assignment to a specific vLLM backend.

- REQ-002: No vLLM backend may receive more than 2 concurrent in-flight requests (hard cap, GPU/KV-cache capacity constraint).

- REQ-003: Requests exceeding a backend's cap must queue with a sane timeout, not hard-fail (no dropped/rejected OC turns under normal load).

- REQ-004: If vLLM automatic prefix caching is confirmed active and relevant to session context sizes, a single conversation's turns must preferentially stay pinned to the same backend to preserve KV-cache locality.

- REQ-005: The load-balancer must detect a dead/unhealthy vLLM instance and route around it without manual intervention.

- REQ-006: Backend selection should additionally account for actual per-instance GPU power draw (a proxy for real occupancy), biasing new placements away from a busier instance even when its in-flight request count alone would not indicate that, to cover load sources invisible to the proxy's own connection counter (e.g. requests that bypass the proxy, or a stalled/slow request that still holds a connection open).

### Acceptance Criteria

- [ ] ACC-001: All active OC sessions point at a single proxy endpoint; no session-level backend assignment exists anywhere in OC config.

- [ ] ACC-002: Under 4 concurrent OC sessions actively generating, each vLLM backend observes ≤2 concurrent in-flight requests (verified via proxy stats).

- [ ] ACC-003: A 5th simultaneous request (beyond the 2+2 cap) queues and eventually completes, rather than erroring.

- [ ] ACC-004: (If sticky routing is implemented per Phase 000 findings) A single long multi-turn conversation's requests all land on the same backend, and re-prefill cost does not spike turn-over-turn.

- [ ] ACC-005: Killing one vLLM instance mid-session causes the proxy to route all traffic to the surviving instance within one health-check interval, with no manual config change.

- [ ] ACC-006: Under real asymmetric GPU load (one instance showing sustained higher power draw than the other at similar in-flight request counts), the proxy's reported per-backend weight visibly shifts, and new-request placement measurably favors the lower-power instance.

### Scope

#### Included

- Investigation of OpenCode's actual HTTP request pattern against vLLM (connection reuse, any stable per-session identifier usable for sticky routing).

- Investigation of the 2 vLLM instances' current prefix-caching / concurrency-limit configuration.

- Reverse-proxy (HAProxy, pending confirmation) configuration: least-connections balancing, hard per-backend `maxconn 2`, request queuing, health checks, optional sticky/session-affinity.

- Deployment of the proxy as a systemd service on the Dell 7960T.

- Cutting over all existing OC sessions' provider `baseURL` to the single proxy endpoint.

- End-to-end validation (concurrency cap enforcement, failover, and — if applicable — cache-locality behavior).

#### Explicitly Out Of Scope

- Changes to the vLLM instances' own model/serving configuration beyond what's needed to confirm/enable prefix caching (that belongs to the feature(s) that originally stood up those instances).

- Authentication/authorization on the proxy or backends (both endpoints remain unauthenticated, internal-network-only, per this repo's existing non-negotiables).

- Horizontal scaling beyond 2 backends (not needed for current hardware).

### Dependencies

#### Depends On

- The 2 vLLM instances already running (stood up under their own feature(s), e.g. feat-1-deepseek-v4-onprem-deployment or similar).

#### Blocks

- None currently.

### Design Notes

Finalized after Phase 000 investigation (see Task 000.100/000.110/000.120 decisions): OpenCode sends an `x-session-affinity` header (identical value also present as `x-opencode-session-id`/`X-Session-Id`) on every request to our vLLM backends, confirmed via live packet capture. HAProxy config should combine `leastconn` placement for new sessions with `stick-table`/header-hash affinity keyed on that header so a conversation's turns stay pinned to one backend:

```
backend vllm_pool
    balance leastconn
    timeout queue 30s
    stick-table type string len 64 size 1m expire 1h
    stick on req.hdr(x-session-affinity)
    server vllm_a <host_a>:<port_a> maxconn 2 check
    server vllm_b <host_b>:<port_b> maxconn 2 check
```

(Exact `stick`/`stick-table` syntax to be validated against the installed HAProxy version during Task 100.100/100.110 -- this is a starting skeleton, not yet tested.)

#### Power-Aware Load Bias (Phase 105)

Finalized in a follow-up design conversation after Phase 100 planning (see the corresponding Decisions Made entry): connection count alone does not tell the proxy whether a backend's GPUs are actually busy -- a connection can sit open against a stalled/slow request, and any traffic that bypasses the proxy (e.g. direct curl testing against 127.0.0.1:8008/8007) is completely invisible to HAProxy's own counters. To close that gap, each backend `server` line gets an HAProxy `agent-check` pointed at a small companion daemon that reports real GPU power draw as a weight percentage, biasing `balance leastconn`'s placement without touching `maxconn`/`leastconn` itself.

Per-instance formula (GPU pairing per Task 000.100: mtp-1/8008 = GPU0+GPU2, mtp-2/8007 = GPU1+GPU3):

```
mean_watts = mean(gpu_a.power_draw + gpu_b.power_draw, over trailing 2-minute window)
load       = min(mean_watts / 600, 1.0)          # 600 = 2 x 300W card cap; clamps occasional ~302W overshoot
weight_pct = max(10, round((1 - load) * 100))    # 10% floor -- never fully excludes a backend on load alone
```

Two independent polling loops, deliberately decoupled:

- The agent's internal NVML sampler reads GPU power draw every 2s and maintains the trailing 2-minute rolling window per GPU -- this runs continuously regardless of whether HAProxy asks for anything.
- HAProxy's own `agent-check` polls the agent every 5s (`agent-inter 5s`) and gets back whatever the already-computed current weight is; the agent never re-samples NVML on that request.

Agent implementation: a single long-running Python 3.13 script (PEP 723 inline dependency metadata declaring `nvidia-ml-py`, run via `uv run`, no separate project/venv to maintain) using NVML bindings rather than shelling out to the `nvidia-smi` CLI. One process serves two asyncio TCP listeners, one per vLLM instance (proposed ports 9998 for mtp-1, 9997 for mtp-2), each implementing HAProxy's agent-check protocol (accept, write `"{weight_pct}%\n"`, close). GPU-index-to-instance mapping lives as an explicit, easily-updated config block at the top of the script (relevant if a future hardware swap re-pins GPUs, c.f. feat-0). Deployed as a single systemd service (`Restart=on-failure`), consistent with this repo's systemd-only convention.

HAProxy config addition per backend server (additive to the Phase 100 skeleton above, `maxconn`/`check`/`balance leastconn` unchanged):

```
server vllm_a 127.0.0.1:8008 maxconn 2 check agent-check agent-addr 127.0.0.1 agent-port 9998 agent-inter 5s
server vllm_b 127.0.0.1:8007 maxconn 2 check agent-check agent-addr 127.0.0.1 agent-port 9997 agent-inter 5s
```

### Related Decisions

- See "Decisions Made" below for the pre-implementation research findings that shaped this feature's scope (HAProxy selection, per-request connection model, prefix-cache locality concern).

### Task List

#### Phase 000: Investigate Before Deciding Policy

- [x] Task 000.100: Confirm the 2 vLLM instances' actual endpoints/ports and current launch flags, specifically whether `--enable-prefix-caching` (or engine-default APC) is active, and the concurrency/`--max-num-seqs` setting underlying the "max 2 concurrent" constraint.

- [x] Task 000.110: Empirically capture OpenCode's request pattern against a real vLLM endpoint (temporary logging/debug reverse proxy or packet capture during a live multi-turn OC conversation): TCP/keep-alive reuse across turns, any stable per-session identifier in headers or body, request open-duration vs. idle gaps.

- [x] Task 000.120: Record findings as a Decision below; finalize LB policy (pure `leastconn`+hard-cap vs. sticky-affinity+`leastconn`-for-new-sessions+hard-cap).

#### Phase 100: Build The Proxy Layer

- [ ] Task 100.100: Write HAProxy config: `balance leastconn`, `maxconn 2` per backend server, `timeout queue`, active health checks against both vLLM instances.

- [ ] Task 100.110: Add HAProxy `stick-table`/header-hash affinity keyed on the `x-session-affinity` request header (confirmed present on every OC request to our vLLM backends, see Task 000.110/000.120 decisions) so a conversation's turns stay pinned to one backend, while new sessions still get `leastconn` placement.

- [ ] Task 100.120: Deploy as a systemd service on the Dell 7960T (systemd-only, per repo convention).

#### Phase 105: Power-Aware Load Bias

- [ ] Task 105.100: Write the Python 3.13 agent script (`uv run`, PEP 723 inline `nvidia-ml-py` dependency): NVML-based power sampling every 2s per GPU, trailing 2-minute rolling mean, per-instance sum-of-2-GPUs/600 normalization capped at 1.0, weight formula `max(10, round((1 - load) * 100))`, two asyncio TCP listeners (ports 9998/9997) implementing HAProxy's agent-check protocol. GPU-index-to-instance mapping as an explicit, easily-updated config block (see Design Notes).

- [ ] Task 105.110: Write and install the systemd unit for the agent script (`Restart=on-failure`, per repo's systemd-only convention).

- [ ] Task 105.120: Add `agent-check agent-addr ... agent-port ... agent-inter 5s` to both backend `server` lines in the HAProxy config from Phase 100, without altering `maxconn 2`/`balance leastconn`.

- [ ] Task 105.130: Validate in isolation before cutover: deliberately saturate one vLLM instance's GPUs (e.g. drive sustained generation against it directly) while the other stays idle; confirm via HAProxy stats that the busy backend's reported weight drops (bounded by the 10% floor) and new placements measurably favor the idle one.

#### Phase 110: Cut Over OpenCode

- [ ] Task 110.100: Point every OC session's provider `baseURL` at the single proxy endpoint instead of the 2 individual vLLM URLs.

- [ ] Task 110.110: Restart each OC session (config is not hot-reloaded).

#### Phase 120: Validate

- [ ] Task 120.100: Drive 4 concurrent OC sessions; confirm via proxy stats that load splits ≤2/backend and excess requests queue rather than fail.

- [ ] Task 120.110: If sticky affinity was implemented, confirm a single long conversation stays pinned to one backend and re-prefill cost doesn't spike turn-over-turn.

- [ ] Task 120.120: Kill one vLLM instance mid-session; confirm the proxy health-checks it out and reroutes surviving sessions without hard failures.

#### Phase 130: Documentation Cleanup

- [ ] Task 130.100: Update `AGENTS.md`'s "No GitHub issues" convention line to reflect actual practice (feat-N folders are numbered from a corresponding GitHub issue N).

## Progress

### Current Status

**As of 2026-10-03 (handover point for a fresh session)**: Feature created and scoped via planning conversation; GitHub issue #9 filed for tracking. Phase 000 (Investigate Before Deciding Policy) is fully complete -- all three tasks confirmed and checked off, see the Decisions Made entries timestamped 00:00:03 through 00:00:07 for full detail. Summary for whoever picks this up next: both vLLM instances' ports/flags are confirmed (mtp-1 on 8008, mtp-2 on 8007, both `--max-num-seqs 2`, both `enable_prefix_caching=False`); OpenCode sends a ready-made `x-session-affinity` header (plus `x-opencode-session-id`/`X-Session-Id`) on every request, confirmed by live packet capture after an earlier static-analysis pass incorrectly concluded no such header existed (read the superseded-but-kept decision entry timestamped 00:00:04 for why that first pass was wrong, and the 00:00:06 entry for the correction); the finalized Phase 100 policy is `balance leastconn` + hard `maxconn 2` + HAProxy `stick-table` affinity on `x-session-affinity`, with a starting (untested) config skeleton already in this document's Design Notes section. A follow-up design conversation added **Phase 105: Power-Aware Load Bias** (sequenced after Phase 100, before Phase 110): a Python 3.13/`uv` NVML-based agent daemon feeds real GPU power draw into HAProxy's `agent-check` mechanism as a weight bias on top of `leastconn`, since connection count alone can't see proxy-bypass traffic or stalled requests. Full formula (trailing 2-min mean of summed-GPU-watts/600 capped at 1.0, 10% weight floor, independent 2s NVML-sampling/5s HAProxy-polling loops) is finalized and recorded in Design Notes; see the 00:00:08 Decisions Made entry for the reasoning behind each parameter. REQ-006/ACC-006 added accordingly. Phase 100 (Build The Proxy Layer) is still the next actionable step, starting with Task 100.100 -- Phase 105's tasks follow once the base proxy exists.

### Blockers

- **HAProxy is not installed on sys0** (checked via `which haproxy` -- not found, no systemd unit for it either, system or user scope). Task 100.100/100.120 will need to install it first (e.g. `apt install haproxy` or equivalent) before a config can be tested; this wasn't previously called out as an explicit task and should probably become its own sub-task (e.g. Task 100.090) rather than being silently folded into 100.100.
- Otherwise none. Phase 000 is complete; Phase 100 is ready to start.

### Updates

<!-- Newest entry first -- prepend new entries directly below this comment. -->

#### 2026-10-03T00:00:03.000Z - Phase 105 (Power-Aware Load Bias) added to the plan

A follow-up design conversation after Phase 100 planning identified that connection-count-based leastconn cannot see whether a backend's GPUs are genuinely busy (proxy-bypass traffic, stalled requests). Added Phase 105 to the Task List (between Phase 100 and Phase 110) covering a Python 3.13 agent daemon that reports real GPU power draw to HAProxy via agent-check, biasing leastconn's weighting without touching maxconn or leastconn itself. Full formula, both polling intervals, and the HAProxy config addition are recorded in the Design Notes section; the reasoning behind each chosen parameter (mean vs max, GPU combination, 10% floor, uv/Python 3.13 implementation choice) is recorded as a new Decisions Made entry. New REQ-006/ACC-006 added to track this requirement explicitly. Next actionable step is still Task 100.100 (HAProxy is not yet installed on sys0, see Blockers); Phase 105's tasks follow once the base proxy from Phase 100 exists.

#### 2026-10-03T00:00:02.000Z - Session handover: Phase 000 closed, Phase 100 ready, practical notes for the next agent

This feature's work so far spanned two sessions on sys0 (the Dell 7960T itself, not a remote host -- all `systemctl`/`journalctl`/`tcpdump` commands in the Decisions Made entries were run directly on this machine). Handing over to a fresh session with the following practical notes. First, HAProxy is not yet installed here (see Blockers); confirm the distro/package manager before writing Task 100.100's config so installation instructions in a sibling bin/ script, if one gets added, are accurate. Second, the tcpdump capture artifacts from Task 000.110 live under /tmp/feat9-task000110/ on this host (oc-vllm-capture.pcap, oc-vllm-capture.txt, oc-vllm-capture-timeline.txt) and are not committed to git; they were only used to extract the findings now recorded as Decisions below, so they can be deleted if disk space matters, or re-captured with bin/000110-capture-oc-vllm-traffic.sh if deeper analysis is ever needed again. Third, a tooling gotcha worth knowing: the specmgr_edit tool silently fails with an opaque "Error executing tool edit" (no detail) when a Decisions Made entry's new_str contains markdown bullet lists (`-`/`*`); keep decision prose as plain paragraphs, matching the free-form-prose style already used throughout this section, and the edit succeeds. Fourth, this environment has no passwordless sudo and a restrictive ptrace_scope (1), which blocks attaching strace to already-running processes; read-only `strings` analysis of compiled binaries (e.g. /home/user/.opencode/bin/opencode) was the fallback technique that worked for investigating OpenCode's request-building behavior, but as the superseded 00:00:04 decision entry shows, a shallow strings search can miss core/unconditional code paths if it only searches for specific expected patterns (e.g. provider-plugin hooks) -- a live capture caught what grep-for-known-patterns missed, so prefer live verification over static analysis when the two disagree. Next concrete action: Task 100.100, write and test an HAProxy config combining the `balance leastconn` + `maxconn 2` baseline with the `stick-table`/`x-session-affinity` skeleton already in this document's Design Notes section, against the two confirmed live endpoints (127.0.0.1:8008 and 127.0.0.1:8007 locally, or 192.168.1.240:8008/8007 from elsewhere on the LAN).

#### 2026-10-03T00:00:01.000Z - Phase 000 investigation complete

Confirmed live on sys0 (the Dell 7960T): both vLLM instances' ports (8008/8007), launch flags, and that prefix caching is off. A sudo tcpdump capture during live OpenCode usage confirmed persistent keep-alive connection reuse across turns and, critically, that OpenCode sends a ready-made x-session-affinity header on every request to our local vLLM backends, correcting an earlier incomplete static-analysis finding. Phase 100 policy finalized as leastconn plus hard maxconn 2 plus header-based stick-table affinity on x-session-affinity. See the three corresponding Decisions Made entries for full detail. Phase 100 (Build The Proxy Layer) is next.

#### 2026-10-03T00:00:00.000Z - Created from planning conversation

Scoped during a planning session that investigated OpenCode's config schema (no multi-backend support, per-request connection timeouts) and reverse-proxy options (HAProxy chosen as working assumption for its hard per-backend `maxconn` support). GitHub issue #9 created for tracking; this feature folder numbered to match.

### Decisions Made

<!-- Newest entry first -- prepend new entries directly below this comment. -->

#### 2026-10-03T00:00:08.000Z - Phase 105 added: power-aware load bias on top of leastconn, parameters finalized through discussion

A follow-up design conversation (after Phase 100's policy was finalized) raised a real gap: HAProxy's leastconn connection counter only reflects requests the proxy itself routed, so it cannot tell whether a backend's GPUs are actually busy for other reasons, such as direct proxy-bypassing traffic or a stalled request that still holds a connection open without doing useful work. The agreed fix is an HAProxy agent-check per backend, fed by a companion daemon reading real GPU power draw via NVML, layered as a weight bias on top of the existing balance leastconn plus hard maxconn 2 baseline rather than replacing either. Every numeric parameter was pinned down explicitly rather than guessed: aggregate function is a trailing 2-minute mean, not max, to smooth transient spikes symmetrically; the instance-level combination of its 2 pinned GPUs is sum-of-both-GPUs-raw-watts divided by 600 (2 x 300W card cap) and clamped at 1.0, which also absorbs the known occasional ~302W overshoot nvidia-smi reports; the weight floor is 10%, chosen so a backend is never fully excluded from new placements purely because of a sustained power reading, only deprioritized; HAProxy's own agent-inter poll interval is 5s. The agent's internal NVML sampling interval (2s) and HAProxy's agent-inter (5s) are deliberately independent loops: the agent continuously maintains its own rolling window regardless of how often HAProxy asks, and simply returns the latest already-computed figure on each poll. Implementation language is Python 3.13 via uv (PEP 723 inline script dependency metadata for nvidia-ml-py, no separate project/venv), explicitly preferred over a lighter shell+nvidia-smi-CLI approach for long-term maintainability, per explicit instruction even though it is a heavier dependency. This is captured as new Phase 105 (Power-Aware Load Bias), sequenced after Phase 100 (base proxy) and before Phase 110 (OC cutover) so it can be validated in isolation first. New REQ-006/ACC-006 capture the requirement and its acceptance test.

#### 2026-10-03T00:00:07.000Z - Task 000.120: Phase 000 policy finalized as leastconn-with-hard-cap plus header-based sticky affinity

With both Task 000.100 and Task 000.110 confirmed, the Phase 100 policy is finalized as follows. Baseline load balancing uses balance leastconn with a hard maxconn 2 per backend server and timeout queue for graceful backpressure, satisfying REQ-001/002/003/005 as originally planned. On top of that baseline, Phase 100 should add HAProxy stick-table (or balance hash) affinity keyed on the x-session-affinity request header confirmed in the Task 000.110 capture, so that all requests belonging to one OpenCode session consistently land on the same backend. This is recommended even though enable_prefix_caching is confirmed False on both instances today (so there is no present KV-cache benefit): the header already exists for free, OpenCode's own authors evidently intended it for this exact purpose, implementation cost in HAProxy is minimal, and it preemptively satisfies REQ-004/ACC-004 against the day prefix caching is enabled on these instances, without requiring a second pass through this feature. New sessions (no prior stick-table entry) still get placed by leastconn, so the 2-and-2 manual split this feature replaces is superseded by an equivalent-or-better automatic placement. Task 100.110 in the task list, originally conditioned on "Phase 000 confirms APC matters and a sticky key exists," should be read as triggered by the sticky-key half of that condition being satisfied, independent of the APC half, per this decision. Phase 000 is complete as of this decision.

#### 2026-10-03T00:00:06.000Z - Task 000.110 complete: live capture confirms connection reuse AND a ready-made sticky-routing header

A sudo tcpdump capture of loopback traffic on ports 8007/8008 during live multi-turn OpenCode usage (~2 minutes, saved under /tmp/feat9-task000110) produced two findings that supersede the earlier static-analysis-only conclusion below. First, no SYN or FIN/RST packets occurred at all during the capture window even though multiple HTTP request/response cycles completed on the same three sockets (ports 35000 and 37342 to 8007, port 58568 to 8008): a fresh "HTTP/1.1 200 OK" response began on an already-established connection with no new handshake, confirming OpenCode reuses a persistent HTTP/1.1 keep-alive connection across multiple chat-completion requests within a session rather than opening a new TCP connection per turn. Second, and more importantly, the captured POST /v1/chat/completions requests carry exactly the headers x-opencode-session-id, x-session-affinity, and X-Session-Id (case-insensitive), all set to the OpenCode session ID, e.g. ses_eff2ab3b9ffeIN3gf3w8hdwlnG. This directly contradicts the earlier conclusion that no stable per-session identifier exists: it does, and it is literally named x-session-affinity, clearly intended by OpenCode's own authors for exactly this purpose. The earlier static-analysis finding below only inspected provider-specific chat.headers plugin hooks (which gate behavior by providerID) and missed this: a second strings pass confirms the header injection actually lives in the core per-request header builder, unconditionally setting x-opencode-session-id for every provider, and additionally setting x-session-affinity plus X-Session-Id for every provider whose providerID does not start with "opencode" (which includes our local openai-compatible vLLM providers). The earlier decision entry is left in place for audit-trail purposes but should be read as superseded by this one. Practical implication for Phase 100: HAProxy can hash or stick-table on the x-session-affinity header to pin a conversation's turns to one backend at effectively zero implementation cost, independent of the current enable_prefix_caching=False state; this makes REQ-004 trivially satisfiable in advance of any future APC enablement, even though it is not strictly required today.

#### 2026-10-03T00:00:04.000Z - Task 000.110 (partial, superseded): no stable per-session header sent to vLLM today -- INCOMPLETE, see newer entry above

Static analysis of the installed opencode binary (strings against /home/user/.opencode/bin/opencode, read-only, no live capture) shows OpenCode calls a generic plugin.trigger("chat.headers", {sessionID, agent, model, provider, message}, {headers:{}}) hook for every chat request regardless of provider. Only two built-in provider plugins actually populate headers from it: the "openai" provider (ChatGPT OAuth, sets a session-id header to the OC session ID) and "github-copilot" (sets X-Interaction-Id). Our two local vLLM backends are configured in opencode.jsonc as the generic openai-compatible provider type (baseURL http://127.0.0.1:8008/v1 and :8007/v1), which has no built-in plugin registering a chat.headers handler. Standard OpenAI chat-completions request bodies also carry no session field. Conclusion: no stable per-session identifier is sent in headers or body to our vLLM backends today, so there is no out-of-the-box key a reverse proxy could use for sticky/session-affinity routing without adding a custom OC plugin (out of scope for this feature). Combined with the enable_prefix_caching=False finding below, this independently supports skipping sticky routing for Phase 100. The remaining part of Task 000.110, live TCP-level keep-alive/idle-gap behavior, still needs a packet capture; see bin/000110-capture-oc-vllm-traffic.sh, tracked separately since it requires sudo and a live multi-turn OC conversation to drive.

#### 2026-10-03T00:00:03.000Z - Task 000.100 confirmed: ports, launch flags, and prefix caching are OFF on both instances

Confirmed directly on sys0 (the Dell 7960T) via systemctl --user cat/status and journalctl --user -u on both live units (both active (running), ~6-day uptime as of 2026-10-03). mtp-1 runs on port 8008 with CUDA_VISIBLE_DEVICES pinned to GPU2+GPU0, --tensor-parallel-size 2, --max-model-len 917504 (896K YaRN), --max-num-seqs 2, and MTP speculative decoding. mtp-2 runs on port 8007 with CUDA_VISIBLE_DEVICES pinned to GPU1+GPU3, otherwise identical flags. Both run vLLM 0.26.0. Prefix caching is confirmed OFF on both instances: neither unit's ExecStart passes --enable-prefix-caching, and each engine's own startup log line (core.py:116 Initializing a V1 LLM engine...) explicitly states enable_prefix_caching=False; live /v1/chat/completions traffic on both instances consistently logs Prefix cache hit rate: 0.0%, consistent with APC being off rather than merely unused. --max-num-seqs 2 on each instance is confirmed as the source of the "max 2 concurrent" constraint behind REQ-002/ACC-002, a vLLM-side admission-control limit separate from and in addition to whatever cap the proxy layer adds. Host LAN IP is 192.168.1.240 (interface enp0s31f6) as of 2026-10-03, which differs from the 192.168.1.103 recorded in feat-4 (DHCP-assigned, has drifted; re-confirm at Phase 100 config time rather than trusting either historical value). Implication for REQ-004: since APC is confirmed off, there is currently no KV-cache-locality benefit to sticky routing, since a conversation bouncing between backends loses no prefix-cache state because none exists. Pure leastconn plus a hard maxconn 2 (no sticky/session-affinity layer) is sufficient for Phase 100 unless prefix caching is deliberately enabled later (out of scope per this feature's "Explicitly Out Of Scope" section).

#### 2026-10-03T00:00:02.000Z - Prefix-cache/KV-cache locality flagged as open risk

vLLM's automatic prefix caching (APC), if enabled, is per-instance and lives in GPU memory. Routing a single conversation's turns to different backends turn-to-turn would force a full re-prefill of the entire growing context on every bounce — a severe cost given this repo's 350–370K-token context target. Whether APC is actually enabled on the 2 current instances, and whether OC sessions commonly reach context sizes where this matters, is unconfirmed as of feature creation. Phase 000 must confirm this empirically before Phase 100 finalizes whether sticky/session-affinity routing is required or whether pure least-connections is sufficient.

#### 2026-10-03T00:00:01.000Z - Per-request connection model confirmed from opencode.json schema

`opencode.json`'s provider `options` expose three independent, per-request timeouts (`timeout`, `headerTimeout` default 300000ms, `chunkTimeout` default 300000ms, "between streamed SSE chunks"), all scoped to a single chat-completion call rather than a whole session. This confirms each OC assistant turn is a discrete streamed HTTP request, not one long-lived connection held open for an entire (8+ hour) session. Reverse-proxy `least_conn`/`leastconn` algorithms count active in-flight requests, not idle keep-alive sockets, so this behavior doesn't undermine least-connections accounting at the proxy layer regardless of OC's own HTTP client pooling.

#### 2026-10-03T00:00:00.000Z - HAProxy chosen as the working reverse-proxy candidate

Of the three common reverse-proxy choices (Caddy, nginx, HAProxy), only HAProxy natively supports a hard per-backend concurrency ceiling with graceful backpressure (`server ... maxconn 2` + `timeout queue`, queuing requests past the cap instead of erroring). Open-source nginx's `max_conns` has no open-source request queuing (NGINX Plus only, commercial). Caddy has no native per-upstream hard concurrency cap at all. Since this feature has a hard requirement of ≤2 concurrent requests per vLLM backend, HAProxy is the working assumption; Phase 000 may still revisit this if investigation surfaces a blocker.

### Related PRs / Commits

- [Issue #9](https://github.com/dfch/biz.dfch.LlmOps/issues/9): tracking issue for this feature.

### More Information

Explicitly out of scope for now: implementation. This feature folder captures the plan only; Phase 000 (investigation) is the next actionable step, to be picked up in a follow-up session.
