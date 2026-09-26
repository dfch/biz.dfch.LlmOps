---
classification: null
created: '2026-09-26T11:25:07.034+02:00'
id: feat-0-gpu-failure-investigation
status: planning
type: feat
updated: '2026-09-26T21:05:49.823+02:00'
version: 1.0.0
---

# Feature: GPU Failure Investigation — Dell 7960T Intermittent GPU1 (a9939c99) Fault

## Plan

### Overview

Tracks physical GPU card swaps performed on the Dell 7960T while investigating
the intermittent hardware/driver fault on the card documented in
`hardware/dell-7960t/recovery.md`'s incident log (bus `0000:34:00.0`, UUID
`GPU-a9939c99-8f16-8d51-fbda-27deb46f0c63`, historically enumerated as GPU1).
Records the exact card↔slot↔UUID↔PCIe-generation mapping before and after each
swap, and the resulting `CUDA_VISIBLE_DEVICES` UUID updates required in
`qwen3.8-27b-bf16-896k-mtp-1.service` / `-mtp-2.service` (live systemd user
units at `~/.config/systemd/user/`, not tracked in git) to keep each service
pinned to two cards of the *same* PCIe generation.

### Requirements

- REQ-001: Record the GPU card/slot/UUID/PCIe-generation mapping before and after every physical swap, as a durable audit trail for fault correlation.
- REQ-002: `mtp-1.service` and `mtp-2.service` must each pin `CUDA_VISIBLE_DEVICES` to two cards of the same PCIe generation (one service = the Gen5 x16 pair, the other = the Gen4 x16 pair).
- REQ-003: Track whether relocating the historically-faulty card (`a9939c99`) between slots changes its fault behavior, to help distinguish a card-level defect from a slot/motherboard-level one.

### Acceptance Criteria

- [x] ACC-001: BEFORE-swap and AFTER-swap-#1 (current) GPU tables recorded with Device ID, Bus-ID, UUID, PCIe generation.
- [x] ACC-002: Post-swap-#2 table confirmed via fresh `nvidia-smi -L` / `--query-gpu=index,uuid,gpu_bus_id,pcie.link.gen.max` output.
- [x] ACC-003: `mtp-1.service` / `mtp-2.service` `CUDA_VISIBLE_DEVICES` updated to match the confirmed post-swap-#2 Gen5/Gen4 pairing.
- [ ] ACC-004: The relocated faulty card is monitored under its new slot for recurrence of the "Unable to determine the device handle" / GSP-heartbeat-timeout fault class. **In progress**: 9h+ stable as of 2026-09-26 19:04 UTC (see Current Status) — kept open pending a longer observation window.

### Scope

#### Included

- GPU physical-slot swap tracking (this round: two swaps, three states).
- Card↔slot↔UUID↔PCIe-gen mapping tables.
- `mtp-1.service` / `mtp-2.service` `CUDA_VISIBLE_DEVICES` UUID updates to restore PCIe-generation-homogeneous pairing.

#### Explicitly Out Of Scope

- Root-cause diagnosis of the underlying driver/hardware fault itself (tracked in `hardware/dell-7960t/recovery.md`'s incident log).
- Any other feature's production services (`qwen3.8-27b-bf16-896k.service`, feat-4 Phase 7 GPU3 standby, etc.) — untouched by this work.

### Dependencies

#### Depends On

- `hardware/dell-7960t/recovery.md` — GPU1 fault incident history (2026-08-25 ×2, 2026-08-27, 2026-09-21).

#### Blocks

- Safe restart of `mtp-1.service` / `mtp-2.service` with correct PCIe-generation-homogeneous pinning after the physical swaps.

### Design Notes

**Card identity vs. slot identity**: `nvidia-smi` index and PCI bus-id are
**slot-based** (assigned by whichever physical card sits in that motherboard
slot); UUID is **card-based** (burned into the card, travels with it across
slots). Both `mtp-1`/`mtp-2` pin GPUs by UUID in `CUDA_VISIBLE_DEVICES`, so a
physical swap changes which *index/bus-id* a UUID reports under, without
requiring a service-file edit — **unless** the swap changes which PCIe
generation a pinned pair now sits on, which is exactly what happened here.

Fixed slot properties (unchanged across all swaps in this round):

- `0000:16:00.0` (Device 0) — Gen5 x16
- `0000:34:00.0` (Device 1) — Gen4 x16
- `0000:AC:00.0` (Device 2) — Gen5 x16
- `0000:CA:00.0` (Device 3) — Gen4 x16

#### State 1 — ORIGINAL (before any swap)

| Device ID | Bus-ID | UUID | PCIe Gen |
|---|---|---|---|
| GPU0 | `0000:16:00.0` | `GPU-5200c9f6-a6bc-e388-2bfc-0e6ddce48ad4` | Gen5 x16 |
| GPU1 | `0000:34:00.0` | `GPU-a9939c99-8f16-8d51-fbda-27deb46f0c63` (**faulty**) | Gen4 x16 |
| GPU2 | `0000:AC:00.0` | `GPU-7eea2a46-7ce4-e288-ab02-783dc5c5c9ea` | Gen5 x16 |
| GPU3 | `0000:CA:00.0` | `GPU-780fe0cd-17a5-153d-bd3c-766d6c1c120e` | Gen4 x16 |

- `mtp-1.service` (GPU0+GPU2, **homogeneous Gen5**): UUIDs `GPU-7eea2a46-...,GPU-5200c9f6-...`
- `mtp-2.service` (GPU1+GPU3, **homogeneous Gen4**): UUIDs `GPU-a9939c99-...,GPU-780fe0cd-...`

#### State 2 — AFTER SWAP #1

Physical swap performed: cards `GPU-7eea2a46-...` and `GPU-780fe0cd-...`
(previously GPU2/GPU3) exchanged slots.

| Device ID | Bus-ID | UUID | PCIe Gen |
|---|---|---|---|
| GPU0 | `0000:16:00.0` | `GPU-5200c9f6-a6bc-e388-2bfc-0e6ddce48ad4` | Gen5 x16 |
| GPU1 | `0000:34:00.0` | `GPU-a9939c99-8f16-8d51-fbda-27deb46f0c63` (**faulty, unmoved**) | Gen4 x16 |
| GPU2 | `0000:AC:00.0` | `GPU-780fe0cd-17a5-153d-bd3c-766d6c1c120e` | Gen5 x16 |
| GPU3 | `0000:CA:00.0` | `GPU-7eea2a46-7ce4-e288-ab02-783dc5c5c9ea` | Gen4 x16 |

- `mtp-1.service` (unchanged `CUDA_VISIBLE_DEVICES`, now resolves to **GPU3+GPU0 — MIXED Gen4+Gen5**)
- `mtp-2.service` (unchanged `CUDA_VISIBLE_DEVICES`, now resolves to **GPU1+GPU2 — MIXED Gen4+Gen5**)

> Note: the faulty card (`a9939c99`) was **not** part of swap #1 — it remains
> at GPU1/`34:00.0`/Gen4 throughout State 2.

#### State 3 — AFTER SWAP #2 (CONFIRMED via live `nvidia-smi` / `nvidia-smi -L`, 2026-09-26)

Physical actions performed: (1) both services stopped, (2) swap #1 undone —
`GPU-780fe0cd-...` and `GPU-7eea2a46-...` swapped back to their original
slots, (3) additionally swapped `GPU-5200c9f6-...` (GPU0) and
`GPU-a9939c99-...` (GPU1), (4) system started.

Confirmed table — matches the prior prediction exactly:

| Device ID | Bus-ID | UUID | PCIe Gen |
|---|---|---|---|
| GPU0 | `0000:16:00.0` | `GPU-a9939c99-8f16-8d51-fbda-27deb46f0c63` (**faulty, relocated to Gen5**) | Gen5 x16 |
| GPU1 | `0000:34:00.0` | `GPU-5200c9f6-a6bc-e388-2bfc-0e6ddce48ad4` | Gen4 x16 |
| GPU2 | `0000:AC:00.0` | `GPU-7eea2a46-7ce4-e288-ab02-783dc5c5c9ea` | Gen5 x16 |
| GPU3 | `0000:CA:00.0` | `GPU-780fe0cd-17a5-153d-bd3c-766d6c1c120e` | Gen4 x16 |

No processes were resident on any GPU at capture time (both services were
stopped for the swap), consistent with `0 MiB` used / no compute processes in
the `nvidia-smi` output.

Homogeneous re-pinning applied (confirmed on-disk in both service files,
`systemctl --user daemon-reload` run):

- `mtp-1.service` (Gen5 pair) → `CUDA_VISIBLE_DEVICES=GPU-a9939c99-...,GPU-7eea2a46-...`
- `mtp-2.service` (Gen4 pair) → `CUDA_VISIBLE_DEVICES=GPU-5200c9f6-...,GPU-780fe0cd-...`

**Intentional** (user decision, 2026-09-26): the faulty card (`a9939c99`) is
deliberately relocated off its long-standing Gen4 slot onto the Gen5 pair, to
test whether the fault is card-linked or slot/motherboard-linked (REQ-003).
`mtp-1.service` (the Gen5 pair) now pins the faulty card going forward.

### Task List

#### Phase 1: State capture and physical swap #2

- [x] Task 1.1: Record State 1 (original, pre-swap) table.
- [x] Task 1.2: Record State 2 (current, post-swap-#1) table.
- [x] Task 1.3: Stop `mtp-1.service` and `mtp-2.service`.
- [x] Task 1.4: Swap GPU2(`AC`/`780fe0cd`) and GPU3(`CA`/`7eea2a46`) cards back.
- [x] Task 1.5: Swap GPU0(`16`/`5200c9f6`) and GPU1(`34`/`a9939c99`) cards.
- [x] Task 1.6: Start system; capture fresh `nvidia-smi --query-gpu=index,uuid,gpu_bus_id,pcie.link.gen.max --format=csv`.
- [x] Task 1.7: Confirm State 3 (actual) against the State 3 (predicted) table above; update this doc with the confirmed table.

#### Phase 2: Service reconfiguration

- [x] Task 2.1: Update `mtp-1.service`'s `CUDA_VISIBLE_DEVICES` to the confirmed Gen5 UUID pair.
- [x] Task 2.2: Update `mtp-2.service`'s `CUDA_VISIBLE_DEVICES` to the confirmed Gen4 UUID pair.
- [x] Task 2.3: `systemctl --user daemon-reload`; start and validate both services (`/health`, a test completion on each port).
- [ ] Task 2.4: Monitor the faulty card under its new slot for recurrence of the enumeration-drop fault; log any recurrence back into `hardware/dell-7960t/recovery.md`'s incident log. **Ongoing** — 9h+ clean as of 2026-09-26 19:04 UTC, see Current Status.

## Progress

### Current Status

**As of 2026-09-26 19:04 UTC**: Both `mtp-1.service` (Gen5 pair, now includes
the relocated faulty card `a9939c99`, port 8008) and `mtp-2.service` (Gen4
pair, port 8007) are `active (running)` since `2026-09-26 11:43 CEST` —
**~9h uptime**. Both `/health` endpoints return `200`. Both are actively
serving `/v1/chat/completions` traffic with normal MTP speculative-decoding
metrics (draft-acceptance rates in the 16–77% range across requests, in line
with the previously-validated MTP behavior). `journalctl -k` (kernel log)
shows **no Xid/NVRM errors** on any of the 4 GPUs in that window — i.e. no
recurrence yet of the "Unable to determine the device handle" /
GSP-heartbeat-timeout fault class on the relocated card. **System is stable
so far under the new Gen5/Gen4 pairing.** REQ-003's card-vs-slot question
remains open pending a longer observation window; ACC-004/Task 2.4 stay
unchecked until that window has elapsed without recurrence.

### Blockers

- None — both services running and healthy. Only open item is continued passive monitoring (Task 2.4 / ACC-004) for fault recurrence on the relocated card.

### Updates

<!-- Newest entry first -- prepend new entries directly below this comment. -->

#### 2026-09-26 19:04:47.000Z - Both services started and validated; 9h stable, no fault recurrence yet

Confirmed both `mtp-1.service` and `mtp-2.service` were started (active since
`2026-09-26 11:43 CEST`, ~9h ago) and are healthy: `/health` returns `200` on
both port 8008 (mtp-1) and port 8007 (mtp-2); both are serving real
`/v1/chat/completions` traffic with normal SpecDecoding/MTP metrics logged.
Checked `journalctl -k` for the last several hours across the whole system:
no Xid/NVRM GPU errors on any of the four cards, including the relocated
faulty card (`a9939c99`, now GPU0/Gen5/`mtp-1.service`). Marked Task 2.3 done.
Task 2.4/ACC-004 (fault-recurrence monitoring) left open/ongoing — this is
an encouraging early signal, not yet a long enough window to close out
REQ-003's card-vs-slot question.

#### 2026-09-26 09:41:50.000Z - Swap #2 confirmed; mtp-1/mtp-2 re-pinned

User performed swap #2 (GPU0↔GPU1, undoing swap #1's GPU2↔GPU3) and provided
fresh `nvidia-smi`/`nvidia-smi -L` output, which matched the previously
predicted State 3 table exactly. Recorded State 3 as CONFIRMED (was
PLANNED). Updated `CUDA_VISIBLE_DEVICES` in both
`~/.config/systemd/user/qwen3.8-27b-bf16-896k-mtp-1.service` (now
`GPU-a9939c99-...,GPU-7eea2a46-...`, the Gen5 pair, now including the
relocated faulty card) and `-mtp-2.service` (now
`GPU-5200c9f6-...,GPU-780fe0cd-...`, the Gen4 pair), and ran
`systemctl --user daemon-reload`. Confirmed no other qwen/mtp units
(including production `qwen3.8-27b-bf16-896k.service`) were active,
so no GPU-sharing conflict exists for either unit at this time.

#### 2026-09-26 09:22:21.000Z - Created; States 1 and 2 recorded

Captured the original (pre-swap) and current (post-swap-#1) GPU
card/slot/UUID/PCIe-generation mapping, cross-referenced against
`mtp-1.service`/`mtp-2.service`'s live `CUDA_VISIBLE_DEVICES`. Found that
swap #1 (GPU2↔GPU3 cards) put both services into a mixed-PCIe-generation
state; planned a second swap (GPU0↔GPU1) to restore homogeneity, which will
also relocate the historically-faulty card (`a9939c99`) from its long-standing
Gen4 slot onto the Gen5 pair.

### Decisions Made

<!-- Newest entry first -- prepend new entries directly below this comment. -->

#### 2026-09-26 09:22:21.000Z - Relocate the faulty card (a9939c99) to a Gen5 slot on purpose

User decision: swap #2 intentionally moves the historically-faulty card
(`GPU-a9939c99-...`, always Gen4 so far) into a Gen5 x16 slot (predicted:
GPU0/`16:00.0`), to distinguish a card-level defect from a
slot/motherboard-level one. `mtp-1.service` (the Gen5 pair) will therefore
pin the faulty card going forward.

#### 2026-09-26 09:22:21.000Z - Track GPU swaps as their own feature, separate from recovery.md's incident log

`hardware/dell-7960t/recovery.md`'s incident log documents the *fault
occurrences* themselves; this feature tracks the *swap-driven investigation*
(card relocations + service re-pinning) as a distinct, task-tracked effort,
since it spans multiple physical actions and a follow-up service
reconfiguration rather than a single incident write-up.

### Related PRs / Commits

- N/A

### More Information

Faulty card's full incident history: `hardware/dell-7960t/recovery.md`
("Incident log" section, entries 2026-08-25 ×2, 2026-08-27, 2026-09-21).
Service files (not tracked in git):
`~/.config/systemd/user/qwen3.8-27b-bf16-896k-mtp-1.service`,
`~/.config/systemd/user/qwen3.8-27b-bf16-896k-mtp-2.service`.
