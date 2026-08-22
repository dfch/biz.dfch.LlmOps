#!/usr/bin/env bash
# Thin wrapper: runs bin/14-smoke-test-glm-service.sh against the
# side-by-side UD-Q4_K_XL service (llama-glm-5.2-q4.service, port 8093 --
# see bin/19/bin/20) instead of Q5's default. Just sets the env vars
# bin/14 already supports; no new logic here.
#
# Prereq: llama-glm-5.2-q4.service must already be `active (running)` and
# healthy (`curl http://localhost:8093/health` -> 200) -- same requirement
# bin/14 itself checks and enforces.
#
# Run with: bash 21-smoke-test-glm-q4-service.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

exec env \
  SERVICE_UNIT=llama-glm-5.2-q4.service \
  HOST=localhost \
  PORT=8093 \
  MODEL="glm-5.2:UD-Q4_K_XL" \
  bash "${SCRIPT_DIR}/14-smoke-test-glm-service.sh"
