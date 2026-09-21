---
classification: null
created: '2026-09-21 08:29:52.695Z'
id: feat-6-enp7s7-dhcp-failover
status: planning
type: feat
updated: '2026-09-21 08:29:52.695Z'
version: 1.0.0
---

# Feature: Dual-Mode DHCP Client/Server Failover on `enP7s7` (Crossover Link)

## Plan

### Overview

This system (Dell Pro Max with GB10, hostname `dgx`) has a built-in copper RJ45 Ethernet port, `enP7s7`. Today it is either plugged into a network with its own DHCP server (normal client behavior) or, in a second use case, is connected point-to-point via a crossover cable directly to one other system with no DHCP server present at all.

This feature makes `enP7s7` automatically behave as a normal DHCP client when a real DHCP server answers on the link, and as a DHCP server (address assignment only, no gateway/DNS/NAT) when no DHCP server answers within a short timeout -- the crossover-cable case. The two modes are mutually exclusive and self-selecting per cable-plug event, with no user interaction required in normal operation, plus a manual override script to force a specific mode.

Tracking issue: https://github.com/dfch/biz.dfch.LlmOps/issues/6

### Requirements

- REQ-001: When `enP7s7` is connected to a network with a working DHCP server, the system must obtain a lease and behave as an ordinary DHCP client, exactly as it does today.
- REQ-002: When `enP7s7` is connected (e.g. via crossover cable) to a single peer with no DHCP server present, and no lease is obtained within a short, bounded timeout, the system must switch to acting as a DHCP server on that interface.
- REQ-003: While acting as DHCP server, the system must assign itself `169.254.0.1/16` on `enP7s7` and hand out leases to the peer from `169.254.1.1`-`169.254.254.254` (the RFC 3927 usable block of the APIPA range), putting both systems in the same `/16` subnet.
- REQ-004: While acting as DHCP server, the leases handed out must not include a default gateway (DHCP option 3) or DNS servers (DHCP option 6); the connected peer's own default route and DNS configuration via its other interfaces must remain completely untouched.
- REQ-005: While acting as DHCP server, this system must not perform IP forwarding or NAT/MASQUERADE for traffic arriving on `enP7s7`, and no `iptables`/`nftables` rules specific to `enP7s7` are to be added.
- REQ-006: The system must correctly reset and re-evaluate (client vs. server) on every unplug/replug cycle of `enP7s7`, with no leftover process or stale IP configuration from the previous cycle.
- REQ-007: A manual override script must exist to force one of three modes on demand: `auto` (the self-selecting behavior above), `client` (DHCP-client-only, no fallback), or `server` (DHCP-server-only, regardless of whether a real DHCP server is present upstream).
- REQ-008: The dedicated DHCP-server component for `enP7s7` must not interfere with any other `dnsmasq` instances already running on this host (e.g. for Docker/libvirt bridges).

### Acceptance Criteria

- [ ] ACC-001: Plugging `enP7s7` into a network with a real DHCP server results in a normal DHCP-obtained address within the usual lease time; `ip -br addr show enP7s7` shows a non-`169.254.x.x` address.
- [ ] ACC-002: Plugging `enP7s7` via crossover cable into an idle peer with no DHCP server results, within roughly 10 seconds, in this system holding `169.254.0.1/16` and the peer obtaining a lease in `169.254.1.1`-`169.254.254.254`.
- [ ] ACC-003: In the crossover scenario, the peer's routing table shows only a link/subnet route for `169.254.0.0/16` and no default route entry attributable to this link; the peer's pre-existing default route via its other interface is unchanged.
- [ ] ACC-004: On this system, `iptables -t nat -L -n` and `nft list ruleset` show no rule referencing `enP7s7`, and no packet forwarding occurs between `enP7s7` and any other interface on this box.
- [ ] ACC-005: Unplugging and replugging `enP7s7` (in either scenario) cleanly re-runs the selection logic with no orphaned `dnsmasq` process and no stale address left on the interface.
- [ ] ACC-006: `enP7s7-net-mode auto|client|server` each produce the expected, immediately observable state via `nmcli device show enP7s7`, and `client`/`server` reliably override the automatic behavior until `auto` is selected again.
- [ ] ACC-007: The dedicated `enP7s7` `dnsmasq` instance runs isolated from any other `dnsmasq` process on the host (distinct config file, PID file, and unit name), verified via `systemctl status`/`ps` showing separate processes bound only to their respective interfaces.

### Scope

#### Included

- Two NetworkManager connection profiles bound to `enP7s7`: DHCP-client (`ipv4.method=auto`, `may-fail=no`, short `dhcp-timeout`, higher `autoconnect-priority`) and static DHCP-server (`ipv4.method=manual`, `169.254.0.1/16`, `never-default=yes`, no gateway/DNS, lower `autoconnect-priority`).
- A standalone `dnsmasq` instance dedicated to `enP7s7`, serving address-only leases (no router/DNS options) from `169.254.1.1`-`169.254.254.254`.
- A NetworkManager dispatcher script that starts/stops that dedicated `dnsmasq` instance based on which of the two `enP7s7` profiles is currently active, so automatic fallback and manual override share one source of truth.
- A manual override script, `enP7s7-net-mode {auto|client|server}`.
- Validation/testing of all the above against real hardware.

#### Explicitly Out Of Scope

- Any of the other five Ethernet interfaces on this host (`enx9c69d3758c88`, `enp1s0f0np0`, `enp1s0f1np1`, `enP2p1s0f0np0`, `enP2p1s0f1np1`) -- this feature is scoped to `enP7s7` only.
- Internet connection sharing, NAT, or routing the crossover peer's traffic anywhere beyond this link -- explicitly rejected, see Decisions Made.
- Any change to Wi-Fi (`wlP9s9`) configuration or this system's own default route.
- Any change to Docker/libvirt bridge networking or their own `dnsmasq` instances, beyond confirming no interference (REQ-008 / ACC-007).
- Cluster/fabric networking over the high-speed "Other" port-type NICs (`enp1s0f0np0`/`np1`, `enP2p1s0f0np0`/`np1`) -- unrelated hardware, not a standard-copper crossover-cable scenario.

### Dependencies

#### Depends On

- `dnsmasq` package (already installed on this host: `dnsmasq 2.91`).
- NetworkManager 1.46+ (already active and managing all Ethernet interfaces on this host).

#### Blocks

- None known at this time.

### Design Notes

**Why not NetworkManager's built-in `ipv4.method=shared`?** `shared` mode is NetworkManager's Internet Connection Sharing (ICS) feature. It bundles three independent mechanisms as one package deal: a static IP on the shared interface, an internal `dnsmasq` DHCP server that hands the client this box's own IP as both the DHCP router (gateway) option and the DNS option, and `iptables` MASQUERADE rules plus IP forwarding so that gateway is actually usable. There is no NM knob to keep the addressing while omitting the gateway/DNS options and the NAT rules -- the whole point of `shared` is to share an uplink. Since REQ-004 and REQ-005 explicitly rule out a pushed gateway/DNS and any NAT/forwarding, `shared` cannot be used here.

**Chosen design instead: `manual` plus standalone `dnsmasq`.** DHCP address assignment, the gateway/DNS DHCP options, and NAT/forwarding are three genuinely independent mechanisms. Address assignment is controlled by dnsmasq's lease pool (`169.254.1.1`-`169.254.254.254`, mask `/16`). The gateway option (DHCP option 3) and the DNS option (DHCP option 6) are each an explicit dnsmasq config directive, and both are simply omitted entirely -- no `dhcp-option=router`, no `dhcp-option=dns`. NAT/IP forwarding is controlled by `iptables`/`nftables` and `sysctl net.ipv4.ip_forward`, and is not configured for `enP7s7` at all.

A standards-compliant DHCP client receiving a lease with no router option installs only a link-scope subnet route for that interface and never touches its default route -- satisfying REQ-004 by construction, not by convention. `ipv4.never-default=yes` on this system's own server profile is a matching safety net so this box's own default route is never affected by this interface either.

**Why the APIPA range (`169.254.0.0/16`)?** `169.254.0.0/24` and `169.254.255.0/24` are reserved by RFC 3927 and excluded from IPv4LL self-assignment, so `169.254.0.1` for this system is a safe, collision-free static pick. Leases are scoped to the RFC-sanctioned usable block (`169.254.1.1`-`169.254.254.254`), avoiding the reserved edges. As a bonus, RFC 3927 explicitly forbids routers from forwarding packets to/from `169.254.0.0/16` addresses off the local link, so even a misconfigured peer that somehow added a static route through this box would have that traffic dropped by any standards-compliant router upstream -- defense in depth for free.

**Fallback mechanism: NetworkManager profile priority, not a custom poller.** Two profiles are kept on `enP7s7` at all times in `auto` mode: a higher-priority DHCP-client profile with `may-fail=no` and a short `dhcp-timeout` (~10s), and a lower-priority static/server profile. NM retries profiles for a device in priority order on every carrier-up event; if the top-priority (client) profile's IPv4 configuration fails within its timeout, NM's own autoconnect logic falls through to the next-priority (server) profile -- no custom link-state polling script is needed for the core client/server decision. A NetworkManager dispatcher script only needs to start/stop the dedicated `dnsmasq` instance in step with whichever profile NM actually activates.

**Manual override script.** `enP7s7-net-mode {auto|client|server}` flips `connection.autoconnect`/`connection.autoconnect-priority` on the two profiles and force-activates the requested one via `nmcli`, reusing the exact same profiles/activation path as the automatic case so there is a single source of truth for what should be running.

### Related Decisions

- See "Decisions Made" below for the interface choice, the NAT/no-NAT decision, and the APIPA subnet decision -- no separate ADR/DEC docs were created for this feature; the decisions are small enough to log inline here.

### Task List

#### Phase 1: NetworkManager Profiles

- [ ] Task 1.1: Create `enP7s7-dhcp-client` connection profile (`ipv4.method=auto`, `ipv4.may-fail=no`, `ipv4.dhcp-timeout=10`, `connection.autoconnect-priority=10`, bound to `enP7s7`).
- [ ] Task 1.2: Create `enP7s7-dhcp-server` connection profile (`ipv4.method=manual`, `ipv4.addresses=169.254.0.1/16`, `ipv4.never-default=yes`, no gateway/DNS, `connection.autoconnect-priority=0`, bound to `enP7s7`).
- [ ] Task 1.3: Confirm the pre-existing auto-generated "Kabelgebundene Verbindung 3" profile for `enP7s7` is disabled/removed so it cannot compete with the two new profiles.

#### Phase 2: Dedicated dnsmasq Instance

- [ ] Task 2.1: Write `/etc/dnsmasq.d/enP7s7-crossover.conf` (or an isolated conf-dir) with `interface=enP7s7`, `bind-interfaces`, `dhcp-range=169.254.1.1,169.254.254.254,255.255.0.0,12h`, `port=0`, `no-resolv`, and no `dhcp-option=router`/`dhcp-option=dns` entries.
- [ ] Task 2.2: Create a systemd unit for this instance, isolated from the system-wide `dnsmasq.service` and from any Docker/libvirt `dnsmasq` processes (distinct config, PID file, unit name); disabled/stopped by default.

#### Phase 3: Dispatcher Integration

- [ ] Task 3.1: Add a NetworkManager dispatcher script (`/etc/NetworkManager/dispatcher.d/`) that, on `enP7s7` up/down events, starts the dedicated `dnsmasq` unit when the server profile is the active connection and stops it otherwise.

#### Phase 4: Manual Override Script

- [ ] Task 4.1: Write `enP7s7-net-mode {auto|client|server}` implementing the three modes described in Design Notes, plus a status/current-mode display.

#### Phase 5: Validation

- [ ] Task 5.1: Verify REQ-001/ACC-001 -- real network, normal DHCP client behavior unchanged.
- [ ] Task 5.2: Verify REQ-002/REQ-003/ACC-002 -- crossover cable to an idle peer, fallback to server mode within ~10s, correct addressing on both sides.
- [ ] Task 5.3: Verify REQ-004/ACC-003 -- peer's routing table has no default route or gateway attributable to this link; peer's existing default route is unaffected.
- [ ] Task 5.4: Verify REQ-005/ACC-004 -- no NAT/forwarding rules or traffic for `enP7s7` on this system.
- [ ] Task 5.5: Verify REQ-006/ACC-005 -- clean state across multiple unplug/replug cycles, including switching between the two scenarios.
- [ ] Task 5.6: Verify REQ-007/ACC-006 -- all three modes of `enP7s7-net-mode` behave as documented.
- [ ] Task 5.7: Verify REQ-008/ACC-007 -- no interference with other `dnsmasq` instances on the host.

## Progress

### Current Status

**As of 2026-09-21**: Planning complete (this document). No implementation has started yet -- Phases 1-5 above are all pending.

### Blockers

- None at this time.

### Updates

<!-- Newest entry first -- prepend new entries directly below this comment. -->

#### 2026-09-21 12:00:00.000Z - Created

Feature created from a design discussion covering dual-mode DHCP client/server behavior on `enP7s7`, the NAT-vs-DHCP-serving distinction, and the APIPA-based addressing scheme. Implementation not yet started.

### Decisions Made

<!-- Newest entry first -- prepend new entries directly below this comment. -->

#### 2026-09-21 12:03:00.000Z - Scoped to enP7s7 only

Of the six Ethernet-type interfaces on this host, only `enP7s7` and `enx9c69d3758c88` are standard copper (Twisted Pair) ports; the remaining four (`enp1s0f0np0`/`np1`, `enP2p1s0f0np0`/`np1`) are high-speed non-copper fabric ports unrelated to a crossover-cable scenario. `enP7s7`, the built-in onboard port, was confirmed as the intended target; the USB dongle (`enx9c69d3758c88`) and the fabric ports are explicitly out of scope for this feature.

#### 2026-09-21 12:02:00.000Z - NetworkManager native priority fallback, not a custom poller

Chose two NetworkManager connection profiles on `enP7s7` (DHCP-client, higher `autoconnect-priority`, `may-fail=no`, short `dhcp-timeout`; and the static/server profile, lower priority) over a hand-rolled link-state polling script. NM's own autoconnect logic already retries profiles for a device in priority order on every carrier-up event and falls through to the next profile when the top one's IPv4 configuration fails within its timeout -- a native, documented NM behavior, reducing the amount of custom logic to just the small pieces NM has no equivalent for: starting the dedicated `dnsmasq` instance, and the manual `enP7s7-net-mode` override.

#### 2026-09-21 12:01:00.000Z - APIPA 169.254.0.0/16 as the crossover subnet, host at .0.1

Chose the RFC 3927 APIPA/link-local range for the crossover link, with this system fixed at `169.254.0.1/16` (inside the reserved-from-autoconfig `169.254.0.0/24` block, so no self-assigning client can ever collide with it) and leases served from the RFC-sanctioned usable block `169.254.1.1`-`169.254.254.254`. This also gets a free defense-in-depth property: RFC 3927 forbids routers from forwarding `169.254.0.0/16` traffic off the local link, so even a misconfigured peer route would not actually be forwarded anywhere by standards-compliant equipment upstream.

#### 2026-09-21 12:00:00.000Z - Address-only DHCP server, no NAT, no pushed gateway/DNS

Rejected NetworkManager's built-in `ipv4.method=shared` (Internet Connection Sharing) because it inseparably bundles DHCP addressing with a pushed gateway/DNS option and NAT/IP-forwarding rules. Chose `ipv4.method=manual` (static `169.254.0.1/16`, `never-default=yes`) plus a standalone `dnsmasq` instance that omits the router and DNS DHCP options entirely, so the connected peer only ever receives an address and subnet route -- its own default route and DNS configuration via its other, unrelated interfaces are left completely untouched, and no NAT/forwarding is configured for this interface on this system.

### Related PRs / Commits

- Tracking issue: https://github.com/dfch/biz.dfch.LlmOps/issues/6

### More Information

This feature does not touch this host's other interfaces (Wi-Fi, Docker bridges, or the high-speed fabric NICs) and does not affect this host's own default route or DNS configuration. See Design Notes above for the detailed rationale distinguishing DHCP address assignment, DHCP gateway/DNS options, and NAT/IP-forwarding as three independent mechanisms.
