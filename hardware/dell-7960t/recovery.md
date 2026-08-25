# NVIDIA RECOVERY PROCEDURE

Goal:
Restore working NVIDIA 595 open-driver stack on Ubuntu 22.04 with kernel 6.8.0-117-generic using the NVIDIA CUDA repository.

Symptoms this procedure fixes:

- nvidia-smi fails with "couldn't communicate with the NVIDIA driver"
- modprobe nvidia says module not found
- dkms status is empty
- system has mixed Ubuntu + NVIDIA CUDA repo packages

Pre-checks:

1. Verify Secure Boot is disabled:
   mokutil --sb-state

2. Verify GPUs are visible on PCIe:
   lspci | grep -i nvidia

3. Verify kernel:
   uname -r

Expected kernel:

- 6.8.0-117-generic

Install kernel headers:
sudo apt update
sudo apt install linux-headers-$(uname -r)

Install working NVIDIA packages from NVIDIA CUDA repo:
sudo apt install \
nvidia-dkms-open \
nvidia-firmware \
nvidia-kernel-common \
libnvidia-compute \
libnvidia-cfg1 \
libnvidia-decode \
libnvidia-gpucomp \
nvidia-persistenced

If dpkg reports firmware overwrite conflicts:
sudo dpkg -i --force-overwrite /var/cache/apt/archives/nvidia-firmware_595.71.05-1ubuntu1_amd64.deb
sudo apt-get -f install

Rebuild/verify DKMS:
sudo dkms autoinstall
dkms status

Expected:

- nvidia/595.71.05, 6.8.0-117-generic, x86_64: installed

Create repo pin file so apt keeps preferring NVIDIA CUDA repo packages:
sudo tee /etc/apt/preferences.d/nvidia-cuda-pin \<<'EOF'
Package: nvidia-dkms-open nvidia-firmware nvidia-kernel-common libnvidia-compute libnvidia-cfg1 libnvidia-decode libnvidia-gpucomp nvidia-persistenced
Pin: origin developer.download.nvidia.com
Pin-Priority: 1001
EOF

Reboot:
sudo reboot

Post-reboot validation:
dkms status
lsmod | grep nvidia
modinfo -F version nvidia
nvidia-smi

Expected post-reboot state:

- nvidia-smi works
- Driver Version: 595.71.05
- CUDA Version: 13.2
- 3 GPUs detected
- NVIDIA kernel modules loaded

Important warning:
Do NOT mix these Ubuntu multiverse packages into the active stack:

- nvidia-utils-595
- libnvidia-compute-595
- nvidia-kernel-common-595
- nvidia-firmware-595-595.71.05

Root cause of previous failures:

- Driver stack was split across two package sources:
  1. Ubuntu jammy-updates/jammy-security
  2. NVIDIA CUDA repository
- That caused dkms/open-driver packages to disappear or be replaced during apt operations.

Useful diagnostic commands:
dpkg -l | egrep 'nvidia|libnvidia'
apt-cache policy nvidia-dkms-open nvidia-firmware nvidia-kernel-common libnvidia-compute libnvidia-cfg1
find /lib/modules/$(uname -r) -type f | grep nvidia
journalctl -b -k | grep -iE 'nvidia|NVRM|dkms'
lspci | grep -i 'VGA compatible controller: NVIDIA'

Known separate issue:

- Only 3 GPUs are detected although 4 are physically installed.
- This is likely a PCIe/BIOS/hardware resource issue, not a driver installation issue.

## Missing 4th NVIDIA GPU

We found the reason that the 4th NVIDIA GPU sometimes did not show: the power cable from the mainboard to the card was defective.

## Power issue

Sometimes, `nvidia-smi` shows the NVIDIA card correctly. However, `ollama` is still not able to use the cards. This is a power management issue. We solved it with this configuration:

### Apply the GRUB fix (Fixes the reboot hang/missing GPUs)

```
bash
Copy
sudo nano /etc/default/grub  
# Change the line to:  
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash pcie_aspm=off"  
sudo update-grub  
```

### Apply the Modprobe fix (Fixes mid-session GPU drops)

```
bash
Copy
sudo tee /etc/modprobe.d/nvidia-power.conf <<EOF  
options nvidia NVreg_DynamicPowerManagement=0x00  
EOF
```

## Incident log

### 2026-08-25: GPU1 dropped off the bus under full 4-GPU (TP=4) load

Both fixes above were already in place on this box (confirmed live:
`GRUB_CMDLINE_LINUX_DEFAULT` contains `pcie_aspm=off`,
`/etc/modprobe.d/nvidia-power.conf` has
`NVreg_DynamicPowerManagement=0x00`) — this is a **recurrence of the same
"mid-session GPU drops" class, not prevented by the existing fixes** under
a new trigger condition neither fix had been tested against before.

**Trigger**: `feat-4-qwen3.8-27b-dell-7960t`'s session ran a diagnostic
`vllm serve --tensor-parallel-size 4` (Qwen3.8-27B BF16, all 4 GPUs
simultaneously, `CUDA_VISIBLE_DEVICES` pinned by UUID) purely to answer a
research question about single-request latency scaling across GPU counts
— not a production config (feat-4's own REQ-001 explicitly scopes TP=4
out of production; feat-1 is the only feature that normally uses all 4
GPUs, via `--tensor-parallel-size 4`, but feat-1's service was not
running at the time — it is currently blocked by an unrelated open vLLM
bug, `vllm-project/vllm#52938` — so this was the first time all 4 GPUs
were driven simultaneously under sustained real compute since the
`pcie_aspm=off`/`NVreg_DynamicPowerManagement=0x00` fixes were applied).

**Symptom**: ~1 minute into model warmup (Gated DeltaNet kernel warmup,
`qwen_gdn_linear_attn.py`'s `_warmup_prefill_kernels`), Worker_TP2 (the
rank mapped to GPU1 in this launch's `CUDA_VISIBLE_DEVICES` ordering)
raised `torch.AcceleratorError: CUDA error: unspecified launch failure`,
repeated 3x (matching `Restart=on-failure`'s retries) before the
diagnostic was stopped by the operator. Kernel log
(`journalctl -k`) shows cascading `NVRM: kgmmuInvalidateTlb_GM107: TLB invalidation failed` / `NVRM: GPU3 _issueRpcAndWait: rpcSendMessage failed with status 0x0000000f` errors — the GSP-firmware RPC channel to
GPU3 also started failing at the same time GPU1 went unreachable,
suggesting a shared failure domain (PCIe root complex / power delivery),
not an isolated single-card fault.

**Resulting state (as of incident time)**: `nvidia-smi` reports
`Unable to determine the device handle for GPU1: 0000:34:00.0: Unknown Error` — GPU1 no longer enumerates as a device at all (though
`lspci -s 34:00.0` still shows the card present on the PCIe bus, just
unresponsive at the driver level). GPU0/GPU2/GPU3 remained visible via
`nvidia-smi` but showed a stuck, abnormal `100% GPU-Util`/`P0` reading
with 0 MiB used and zero processes for several minutes after — likely a
side effect of the driver's global state being disturbed by GPU1's fault,
not real compute (no vLLM/NCCL processes were left running; `systemctl --user stop`'s `KillMode=control-group` had already cleaned those up).
`nvidia-smi --gpu-reset` against GPU1's PCI address failed with the same
"Unknown Error" (a reset requires the device to have a valid handle in
the first place). No non-interactive `sudo` was available in that
session, so no further recovery (module reload, PCI-level reset, or
reboot) was attempted — **the box was left in this degraded state,
GPU1 unusable, for the user to physically inspect/recover.**

**Recommended next steps (not yet performed)**:

1. Physically check GPU1's power cable/seating — the existing "Missing
   4th NVIDIA GPU" entry above already documents a defective-power-cable
   root cause for a similar symptom on this same box, on a different GPU
   slot; worth ruling out on GPU1 too before assuming it's purely a
   driver/firmware issue.
2. A reboot is the most likely full recovery path (this doc's own GRUB
   fix note above is literally titled "Fixes the reboot hang/missing
   GPUs" — a hung/dropped GPU rejoining after reboot is the expected
   behavior of that fix, not evidence it failed outright; it may simply
   not cover a live mid-session drop under this specific 4-GPU
   simultaneous-load trigger).
3. After reboot, re-run the Post-reboot validation commands above
   (`nvidia-smi`, all 4 GPUs expected) before trusting any GPU for
   compute again, and specifically re-check GPU1 and GPU3 (the pair
   implicated in this incident) rather than assuming a clean `nvidia-smi`
   listing means full recovery.
4. Consider whether `NVreg_DynamicPowerManagement=0x00` and
   `pcie_aspm=off` are sufficient under genuine 4-GPU simultaneous
   full-power load, or whether this workload class (all 4 GPUs at once,
   sustained tensor-parallel compute) needs an additional power-delivery
   or BIOS-level investigation — the existing fixes were validated against
   whatever workload originally triggered them, which may not have been
   this demanding.

**Resolution (2026-08-25, same day)**: user physically inspected GPU1
(step 1 above) and fixed the hardware fault, then rebooted. Post-reboot
validation re-run and confirmed clean:

- `nvidia-smi`: all 4 GPUs enumerate, all idle at normal `P8`/0%-util/
  near-0-MiB (no repeat of the stuck `100% GPU-Util`/`P0` reading seen
  right after the incident), no leftover processes.
- `dkms status` / `lsmod | grep nvidia` / `modinfo -F version nvidia`:
  driver `610.57.04` loaded cleanly on kernel `6.8.0-138-generic`.
- `journalctl -k -b`: fresh boot (`uptime -s` = 2026-08-25 19:24:59) shows
  the driver loading on all 4 PCIe addresses (`16:00.0`, `34:00.0`
  [GPU1], `ac:00.0`, `ca:00.0` [GPU3]) with **zero** NVRM/Xid errors — no
  repeat of the `kgmmuInvalidateTlb`/`rpcSendMessage failed` cascade.
- Both fixes from this doc survived the reboot: `/proc/cmdline` still
  contains `pcie_aspm=off`; `/etc/modprobe.d/nvidia-power.conf` still has
  `NVreg_DynamicPowerManagement=0x00`.
- `nvidia-smi topo -m`: unchanged, all pairs still `NODE` (no NVLink), as
  expected — the incident did not alter the physical topology.
- As an extra confidence check beyond the generic validation above,
  `feat-4-qwen3.8-27b-dell-7960t`'s production `qwen3.8-27b-bf16-896k.service` (TP=2 on GPU2+GPU0 — the pair whose driver state was
  "clearly disturbed" per this incident's own note, even though not
  directly implicated) was started for real: loaded BF16 weights cleanly
  (~29.9 GiB on each of GPU0/GPU2), `/health` returned 200, `/v1/models`
  confirmed `max_model_len: 917504`, a temperature=0 chat completion
  returned correct, coherent output, then `systemctl --user stop` cleanly
  returned it to `inactive (dead)` with all 4 GPUs back to ~0 MiB used.

**Root cause remains unconfirmed** (item 1's power-cable/seating check on
GPU1 was the fix the user applied, consistent with this doc's own
"Missing 4th NVIDIA GPU" precedent, but this was not independently
re-verified here beyond the fact that the symptom cleared after physical
inspection + reboot) — item 4 (whether the existing power/ASPM fixes are
sufficient under sustained genuine 4-GPU simultaneous load) remains an
open question for any *future* TP=4 attempt; this resolution only
confirms recovery to a clean, idle 4-GPU state, not a re-test of the
TP=4 trigger condition itself.

**TP=4 trigger condition re-tested (2026-08-25, same session)**: re-ran
the exact same `qwen3.8-27b-bf16-tp4-bench.service` diagnostic that
originally triggered this incident, under close live monitoring
(`journalctl -k -f` tailed throughout, GPU polled every ~6s through the
specific Gated DeltaNet warmup window that failed before). This time it
completed cleanly end-to-end: engine init/graph-capture in 78.68s, zero
NVRM/Xid errors, healthy API server, and a full `vllm bench serve` run
(128 requests, 64 concurrency) succeeded with 0 failures. Service was
stopped cleanly afterward, all 4 GPUs confirmed back to idle. **This is
one clean run, not a stress-test campaign** — it demonstrates the
specific original trigger no longer reproduces the fault post-repair,
but does not by itself prove item 4 (sustained 4-GPU load /
power-delivery headroom) is fully resolved; a single successful
~54-second benchmark is a much lighter load than, e.g., a long-running
production TP=4 service would put on the box. Detail and throughput
numbers recorded in `feat-4-qwen3.8-27b-dell-7960t`'s README (Design
Notes, "TP=4 re-attempt" entry).

### 2026-08-25 (same day): GPU1 dropped off the bus a second time, under TP=4 single-request load

**This recurred on the very next TP=4 attempt**, immediately after the
successful batched (64-concurrency) TP=4 run above — the very next test
was a single-request (concurrency=1) `vllm bench serve` against the
same `qwen3.8-27b-bf16-tp4-bench.service` (still TP=4, all 4 GPUs, same
unit, no config change from the run that had just succeeded cleanly).
GPU1 went unreachable again (`Unable to determine the device handle for GPU1: 0000:34:00.0: Unknown Error`) partway through the benchmark
(4/5 requests completed per the tqdm progress before it happened).
Kernel log this time explicitly names the failure:
`NVRM: GPU1 tmrGetTimeEx_GH100: NVRM-RC: Consistently Bad TimeLo value` /
`_kgspIsHeartbeatTimedOut: Heartbeat timed out` /
`_kgspRpcRecvPoll: GSP RM heartbeat timed out`, followed by **`NVRM: Xid 154` on all 4 GPUs, each with `GPU recovery action changed from 0x0 (None) to 0x2 (OS Reboot)`** — i.e. the driver itself flagged that a
reboot is the expected recovery path for all 4 cards, not just GPU1.
GPU0/2/3 again showed the same abnormal stuck `100% GPU-Util`/`P0`(→P1)
reading seen in the first incident, with no real processes/compute
behind it.

**This time, unlike the first incident, `systemctl --user stop` on the
diagnostic unit succeeded cleanly** (`KillMode=control-group` tore down
the worker processes without hanging), leaving no leftover vLLM
processes and all 4 GPUs' memory freed (2/2/10 MiB on GPU0/2/3) — only
GPU1 itself remains unreachable, and GPU0/2/3's util-reading anomaly
persists exactly as before (cosmetic/stuck-metric, not real load).

**Not investigated further this session, by explicit user decision** —
the user is stopping engineering work here and will validate the actual
production config (TP=2, GPU0+GPU2 only — TP=4 was never a production
target, see `feat-4`'s REQ-001) themselves, in a real-life test outside
this session. Combined with the first incident, this is now **two-for-two**
TP=4 attempts on this box ending in a GPU1 hardware/driver fault
(one during 64-concurrency load, one during concurrency=1 load) versus
**one-for-one clean TP=4 run** (the batched 64-concurrency benchmark
that completed successfully just before this). This inconsistency (same
config, same unit, back-to-back — one run clean, the very next one
failed) points toward a marginal/intermittent fault (heat-soak, a
borderline power/seating margin that only sometimes trips, or a
GSP-firmware race condition under TP=4's inter-GPU synchronization
specifically) rather than something reliably reproducible on a fixed
trigger. **Recommendation for any future TP=4 investigation**: treat
TP=4 on this box as unreliable until a longer soak test (repeated
back-to-back runs, not a single success) demonstrates otherwise — do
not conclude from one clean run that the fault is resolved. Production
scope is unaffected either way (REQ-001 already excludes TP=4).
