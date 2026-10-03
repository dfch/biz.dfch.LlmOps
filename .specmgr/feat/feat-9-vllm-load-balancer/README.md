---
classification: null
created: '2026-10-03T11:20:46.114+02:00'
id: feat-9-vllm-load-balancer
status: planning
type: feat
updated: '2026-10-03T11:20:46.114+02:00'
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

### Acceptance Criteria

- [ ] ACC-001: All active OC sessions point at a single proxy endpoint; no session-level backend assignment exists anywhere in OC config.

- [ ] ACC-002: Under 4 concurrent OC sessions actively generating, each vLLM backend observes ≤2 concurrent in-flight requests (verified via proxy stats).

- [ ] ACC-003: A 5th simultaneous request (beyond the 2+2 cap) queues and eventually completes, rather than erroring.

- [ ] ACC-004: (If sticky routing is implemented per Phase 000 findings) A single long multi-turn conversation's requests all land on the same backend, and re-prefill cost does not spike turn-over-turn.

- [ ] ACC-005: Killing one vLLM instance mid-session causes the proxy to route all traffic to the surviving instance within one health-check interval, with no manual config change.

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

Candidate HAProxy skeleton (to be finalized after Phase 000 investigation):

```
backend vllm_pool
    balance leastconn
    timeout queue 30s
    server vllm_a <host_a>:<port_a> maxconn 2 check
    server vllm_b <host_b>:<port_b> maxconn 2 check
```

If Phase 000 confirms a usable per-session sticky key (e.g. a stable header/body field OC sends, or an API-key-per-session scheme we introduce deliberately), add a `stick-table`/cookie-based affinity layer so new sessions still get least-conn placement but existing conversations stay pinned for KV-cache reuse.

### Related Decisions

- See "Decisions Made" below for the pre-implementation research findings that shaped this feature's scope (HAProxy selection, per-request connection model, prefix-cache locality concern).

### Task List

#### Phase 000: Investigate Before Deciding Policy

- [ ] Task 000.100: Confirm the 2 vLLM instances' actual endpoints/ports and current launch flags, specifically whether `--enable-prefix-caching` (or engine-default APC) is active, and the concurrency/`--max-num-seqs` setting underlying the "max 2 concurrent" constraint.

- [ ] Task 000.110: Empirically capture OpenCode's request pattern against a real vLLM endpoint (temporary logging/debug reverse proxy or packet capture during a live multi-turn OC conversation): TCP/keep-alive reuse across turns, any stable per-session identifier in headers or body, request open-duration vs. idle gaps.

- [ ] Task 000.120: Record findings as a Decision below; finalize LB policy (pure `leastconn`+hard-cap vs. sticky-affinity+`leastconn`-for-new-sessions+hard-cap).

#### Phase 100: Build The Proxy Layer

- [ ] Task 100.100: Write HAProxy config: `balance leastconn`, `maxconn 2` per backend server, `timeout queue`, active health checks against both vLLM instances.

- [ ] Task 100.110: If Phase 000 confirms APC matters and a sticky key exists, add `stick-table`/cookie-based affinity so a conversation's turns stay pinned to one backend while new sessions still get `leastconn` placement.

- [ ] Task 100.120: Deploy as a systemd service on the Dell 7960T (systemd-only, per repo convention).

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

**As of 2026-10-03**: Feature created and scoped via planning conversation; GitHub issue #9 filed for tracking. No implementation has started — Phase 000 investigation is the next step.

### Blockers

- None yet. Tasks 000.100/000.110 require access to the Dell 7960T and the live vLLM endpoints to proceed.

### Updates

<!-- Newest entry first -- prepend new entries directly below this comment. -->

#### 2026-10-03T00:00:00.000Z - Created from planning conversation

Scoped during a planning session that investigated OpenCode's config schema (no multi-backend support, per-request connection timeouts) and reverse-proxy options (HAProxy chosen as working assumption for its hard per-backend `maxconn` support). GitHub issue #9 created for tracking; this feature folder numbered to match.

### Decisions Made

<!-- Newest entry first -- prepend new entries directly below this comment. -->

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
