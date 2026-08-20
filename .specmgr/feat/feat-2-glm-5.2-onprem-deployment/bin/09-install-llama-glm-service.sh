#!/usr/bin/env bash
# Task 2.3: install (copy + daemon-reload + enable) the draft
# 08-llama-glm-5.2.service as a systemd unit. Deliberately does NOT
# `systemctl start` -- that is Task 2.4, done right after with an
# immediate curl /health + /v1/chat/completions smoke test, not bundled
# into "install".
#
# DO NOT RUN THIS YET as of 2026-08-20: 08-llama-glm-5.2.service still has
# a placeholder --ctx-size (524288, 512K -- the largest DIRECTLY measured
# Task 2.1 size) and placeholder --tensor-split/--n-cpu-moe (54,9,8,8 /
# 54, the config validated for Task 2.1/2.2). Both are pending:
#   1. Track A (bin/07-measure-kv-cache-768-896.sh) results for 768K/896K
#   2. The PCIe-topology-informed --tensor-split rebalancing discussion
#      (GPU0/GPU2 = PCIe 5.0 x16, GPU1/GPU3 = PCIe 4.0 x16)
# Re-run bin/08's own header check once those land, edit the unit's
# --ctx-size/--tensor-split/--n-cpu-moe to the finalized values, THEN
# install.
#
# Requires sudo (interactive password on this box -- `sudo -n true` fails
# non-interactively as of 2026-08-20). Run manually:
#   bash 09-install-llama-glm-service.sh
set -euo pipefail

UNIT_SRC="$(cd "$(dirname "$0")" && pwd)/08-llama-glm-5.2.service"
UNIT_NAME="llama-glm-5.2.service"
UNIT_DST="/etc/systemd/system/${UNIT_NAME}"

if [ ! -f "$UNIT_SRC" ]; then
  echo "ERROR: ${UNIT_SRC} not found" >&2
  exit 1
fi

echo "Installing ${UNIT_NAME} from ${UNIT_SRC} -- will prompt for sudo password."
sudo cp "$UNIT_SRC" "$UNIT_DST"
sudo systemctl daemon-reload
sudo systemctl enable "$UNIT_NAME"

echo
echo "Installed and enabled (NOT started). Next steps:"
echo "  - Task 2.4: sudo systemctl start ${UNIT_NAME}, then curl smoke test"
echo "    against http://<host>:8092/health and /v1/chat/completions"
echo "  - journalctl -u ${UNIT_NAME} -f   -- to follow logs during first load"
echo "    (cold load has historically taken 20-45+ min for this quant/size,"
echo "    see bin/06-measure-kv-cache.sh header -- do not assume a hang)"
