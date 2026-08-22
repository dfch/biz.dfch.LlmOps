#!/usr/bin/env bash
# Thin wrapper: runs bin/15-measure-pcie-vs-throughput.sh against the
# side-by-side UD-Q4_K_XL service (llama-glm-5.2-q4.service, port 8093 --
# see bin/19/bin/20) instead of Q5's default. Just sets the env vars
# bin/15 already supports; no new logic here. (Mirrors bin/21's wrapper
# pattern for bin/14.)
#
# Prereq: llama-glm-5.2-q4.service must already be `active (running)` and
# healthy (`curl http://localhost:8093/health` -> 200) -- same requirement
# bin/15 itself checks and enforces. Does not start/stop anything.
#
# Run with: bash 22-measure-pcie-vs-throughput-q4.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

exec env \
  HOST=localhost \
  PORT=8093 \
  MODEL="glm-5.2:UD-Q4_K_XL" \
  bash "${SCRIPT_DIR}/15-measure-pcie-vs-throughput.sh"
