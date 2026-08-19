#!/usr/bin/env bash
# Reports progress of the bin/00-download-glm-quants.sh download: bytes done
# vs. expected total for each quant (spike/target/fallback), a live transfer
# rate sample, and ETA for the quant currently in progress.
#
# Safe to run any time, any number of times, while the download is running
# or after it's done.
#
# Run with: bash 04-dl-status.sh

set -euo pipefail

DEST_ROOT=/data/llama_cpp/models/GLM-5.2-GGUF
SAMPLE_SECONDS=15

echo "== hf download process =="
if pgrep -af "hf download unsloth/GLM-5.2-GGUF" > /dev/null; then
  pgrep -af "hf download unsloth/GLM-5.2-GGUF"
else
  echo "(not currently running)"
fi
echo

python3 - "$DEST_ROOT" "$SAMPLE_SECONDS" <<'PYEOF'
import os
import sys
import time

dest_root, sample_seconds = sys.argv[1], float(sys.argv[2])

# Expected on-disk totals per quant (unsloth memory table / measured via HF tree API, 2026-08-19)
QUANTS = [
    ("UD-IQ1_S",   217e9, "Phase 1 spike"),
    ("UD-Q5_K_XL", 562e9, "Phase 2 target"),
    ("UD-Q4_K_XL", 467e9, "Phase 2 fallback"),
]

def quant_bytes(quant: str) -> int:
    total = 0
    # Finished shards land directly under DEST_ROOT/<quant>/
    final_dir = os.path.join(dest_root, quant)
    if os.path.isdir(final_dir):
        for f in os.listdir(final_dir):
            if f.endswith(".gguf"):
                total += os.path.getsize(os.path.join(final_dir, f))
    # In-flight shards live under DEST_ROOT/.cache/huggingface/download/<quant>/*.incomplete
    incomplete_dir = os.path.join(dest_root, ".cache", "huggingface", "download", quant)
    if os.path.isdir(incomplete_dir):
        for f in os.listdir(incomplete_dir):
            if f.endswith(".incomplete"):
                total += os.path.getsize(os.path.join(incomplete_dir, f))
    return total

print(f"{'quant':<12} {'role':<18} {'done':>10} {'target':>10} {'pct':>7}")
snapshot1 = {}
for quant, target, role in QUANTS:
    done = quant_bytes(quant)
    snapshot1[quant] = done
    pct = done / target * 100
    print(f"{quant:<12} {role:<18} {done/1e9:>7.1f} GB {target/1e9:>7.0f} GB {pct:>6.1f}%")

total_done = sum(snapshot1.values())
total_target = sum(t for _, t, _ in QUANTS)
print(f"{'TOTAL':<12} {'':<18} {total_done/1e9:>7.1f} GB {total_target/1e9:>7.0f} GB {total_done/total_target*100:>6.1f}%")

# Find the quant currently being written to (largest incomplete-dir mtime), sample its rate
active = None
best_mtime = -1
for quant, _, _ in QUANTS:
    incomplete_dir = os.path.join(dest_root, ".cache", "huggingface", "download", quant)
    if os.path.isdir(incomplete_dir):
        for f in os.listdir(incomplete_dir):
            if f.endswith(".incomplete"):
                m = os.path.getmtime(os.path.join(incomplete_dir, f))
                if m > best_mtime:
                    best_mtime = m
                    active = quant

if active is None:
    print("\nNo quant currently in-flight (either done, or not started).")
    sys.exit(0)

print(f"\n== Sampling transfer rate for active quant '{active}' over {sample_seconds:.0f}s ==")
b1 = quant_bytes(active)
time.sleep(sample_seconds)
b2 = quant_bytes(active)
rate = (b2 - b1) / sample_seconds

target = dict((q, t) for q, t, _ in QUANTS)[active]
print(f"rate: {rate/1e6:.2f} MB/s")
if rate > 0 and b2 < target:
    eta_s = (target - b2) / rate
    mins = eta_s / 60
    print(f"ETA for '{active}': {mins:.1f} min ({mins/60:.1f} h)")
elif b2 >= target:
    print(f"'{active}' appears complete.")
else:
    print("rate is 0 -- download may be paused/stalled, or between-file transition; rerun to confirm.")
PYEOF
