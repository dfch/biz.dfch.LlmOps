#!/usr/bin/env bash
# Downloads the GLM-5.2 GGUF quants needed for this feature, in priority
# order, from the pinned `unsloth/GLM-5.2-GGUF` revision:
#
#   1. UD-IQ1_S   (~217 GB) -- Phase 1 SM120 correctness spike (Task 1.1-1.4)
#   2. UD-Q5_K_XL (~562 GB) -- Phase 2 target quant (REQ-005, near-lossless)
#   3. UD-Q4_K_XL (~467 GB) -- Phase 2 fallback quant (REQ-005)
#
# Total ~1.25 TB; /data has 8.2 TB free as of 2026-08-19 (df -h /data).
#
# Repo is public (MIT), so no HF_TOKEN is required, but set one if you have
# it for higher rate limits/faster transfer:
#   export HF_TOKEN=hf_...
#
# `hf download` resumes partial/interrupted downloads on re-run, so this
# script is safe to re-run or Ctrl-C and continue later. Each stage is
# independent -- if you only need the spike quant right now, run:
#   bash 00-download-glm-quants.sh UD-IQ1_S
#
# Meant to run for hours; start it under tmux/screen/nohup so it survives a
# disconnect, e.g.:
#   tmux new -s glm-download
#   bash 00-download-glm-quants.sh
#   (Ctrl-b d to detach, `tmux attach -t glm-download` to check back in)

set -euo pipefail

HF_BIN=hf
REPO=unsloth/GLM-5.2-GGUF
REVISION=abc55e72527792c6e77069c99b4cb7de16fa9f23  # pinned 2026-08-19 (Task 0.5)
DEST_ROOT=/data/llama_cpp/models/GLM-5.2-GGUF

# Order matters: spike quant first (unblocks Phase 1), then target, then
# fallback (both needed for Phase 2 quant selection per Task 2.2).
ALL_QUANTS=(UD-IQ1_S UD-Q5_K_XL UD-Q4_K_XL)
QUANTS=("${@:-${ALL_QUANTS[@]}}")

LOGDIR="$(cd "$(dirname "$0")" && pwd)/logs"
mkdir -p "$LOGDIR"

echo "== Disk space on /data before download =="
df -h /data

for QUANT in "${QUANTS[@]}"; do
  DEST="${DEST_ROOT}/${QUANT}"
  LOG="${LOGDIR}/$(date -u +%Y-%m-%dT%H%M%SZ)-${QUANT}.log"
  mkdir -p "$DEST"

  echo
  echo "=============================================================="
  echo "Downloading ${REPO} @ ${REVISION} :: ${QUANT}"
  echo "  -> ${DEST}"
  echo "  log: ${LOG}"
  echo "=============================================================="

  "$HF_BIN" download "$REPO" \
    --revision "$REVISION" \
    --include "${QUANT}/*" \
    --local-dir "$DEST_ROOT" \
    2>&1 | tee "$LOG"

  echo "-- ${QUANT} done, on-disk size: --"
  du -sh "$DEST"
done

echo
echo "== Disk space on /data after download =="
df -h /data
echo
echo "All requested quants downloaded under ${DEST_ROOT}."
echo "Record the pinned revision (${REVISION}) in the README's Task 0.5 /"
echo "ACC-006 once the quant to actually deploy is confirmed."
