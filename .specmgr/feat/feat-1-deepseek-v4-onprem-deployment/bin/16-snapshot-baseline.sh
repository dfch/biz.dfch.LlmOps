#!/usr/bin/env bash
# Step 0 of the Task 1.4 unblock plan (2026-08-19T08:04:27Z session):
# capture the current degenerate-output state as a byte-exact, reproducible
# reference BEFORE any further experiment, so every subsequent diagnostic
# (bin/17+) is compared against a frozen known-bad baseline rather than
# against prose in the README.
#
# This script changes nothing about the service or environment -- it only
# reads and records:
#   1. the exact live ExecStart block of the unit,
#   2. `pip freeze` of the serving venv (vLLM/flashinfer/torch/CUDA wheels),
#   3. `nvidia-smi` (driver, CUDA, per-GPU memory),
#   4. the temperature=0 smoke-test response (the degenerate signature:
#      `<|begin_of_sentence|>` at logprob -11.769736289978027 at every
#      decode position).
#
# The baseline is written to a timestamped file under bin/baselines/ so it
# can be diffed against later runs. Safe to run repeatedly.
#
# Run with: bash 16-snapshot-baseline.sh
#   (no sudo needed -- read-only; uses sudo only if the unit file is not
#    world-readable)

set -euo pipefail

UNIT=/etc/systemd/system/vllm-deepseek-v4-flash.service
VENV=/data/vllm/.venv
ENDPOINT=http://127.0.0.1:8000/v1/chat/completions
MODEL=deepseek-ai/DeepSeek-V4-Flash

STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
OUTDIR="$(cd "$(dirname "$0")" && pwd)/baselines"
OUT="${OUTDIR}/${STAMP}-degenerate.txt"

mkdir -p "$OUTDIR"

{
  echo "=============================================================="
  echo "DeepSeek-V4-Flash Task 1.4 baseline snapshot"
  echo "captured: ${STAMP}"
  echo "=============================================================="
  echo

  echo "== 1. Live ExecStart block =="
  sudo sed -n '/^ExecStart=/,/^ExecReload=/p' "$UNIT" | head -n -1 || \
    sed -n '/^ExecStart=/,/^ExecReload=/p' "$UNIT" | head -n -1
  echo

  echo "== 2. Environment= lines (PATH, HF_HUB_OFFLINE, etc.) =="
  sudo grep '^Environment=' "$UNIT" || grep '^Environment=' "$UNIT" || true
  echo

  echo "== 3. pip freeze (vLLM / flashinfer / torch / nvidia-cuda-*) =="
  "${VENV}/bin/pip" freeze | grep -Ei 'vllm|flashinfer|^torch|nvidia-cuda|deepgemm|tilelang' || \
    "${VENV}/bin/pip" freeze
  echo

  echo "== 4. nvidia-smi =="
  nvidia-smi
  echo

  echo "== 5. temperature=0 smoke test (10 tokens, logprobs) =="
  echo "-- request --"
  cat <<'JSON'
{
  "model": "deepseek-ai/DeepSeek-V4-Flash",
  "messages": [{"role": "user", "content": "Say hello in one short sentence."}],
  "temperature": 0,
  "max_tokens": 10,
  "logprobs": true,
  "top_logprobs": 1
}
JSON
  echo "-- response --"
  curl -s "$ENDPOINT" \
    -H 'Content-Type: application/json' \
    -d "{
      \"model\": \"${MODEL}\",
      \"messages\": [{\"role\": \"user\", \"content\": \"Say hello in one short sentence.\"}],
      \"temperature\": 0,
      \"max_tokens\": 10,
      \"logprobs\": true,
      \"top_logprobs\": 1
    }" || echo "(curl failed -- is the service up? systemctl status vllm-deepseek-v4-flash.service)"
  echo
} | tee "$OUT"

echo
echo "Baseline written to: $OUT"
echo "Diff future diagnostic runs against this file to confirm whether the"
echo "degenerate signature changed."
