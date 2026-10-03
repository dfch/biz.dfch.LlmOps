#!/usr/bin/env bash
# feat-9-vllm-load-balancer, Task 000.110
#
# Captures loopback traffic between OpenCode and the two vLLM backends
# (qwen3.8-27b-bf16-896k-mtp-1 on port 8008, -mtp-2 on port 8007) so we can
# inspect, after the fact:
#   - whether OC reuses one TCP connection (same source port) across the
#     turns of a single conversation, or opens a new one per turn
#   - request open-duration vs. idle gaps between turns
#   - (belt-and-suspenders) any custom header OC might send, even though
#     static analysis of the opencode binary already showed no session
#     header is injected for the generic "openai-compatible" provider type
#     that our local vLLM backends use (see feat-9 README, Decisions Made)
#
# Usage:
#   sudo ./000110-capture-oc-vllm-traffic.sh [out_dir] [capture_seconds]
#
# While this is running, drive a live multi-turn OpenCode conversation
# against one of the qwen3.8-27b-bf16-896k-mtp-1/-2 models (several turns,
# with a deliberate pause of 10-20s between some of them to see idle-gap
# behavior).
#
# Requires root (raw socket capture) -- run with sudo.

set -euo pipefail

OUT_DIR="${1:-/tmp/feat9-task000110}"
CAPTURE_SECONDS="${2:-120}"
PCAP="${OUT_DIR}/oc-vllm-capture.pcap"
ASCII="${OUT_DIR}/oc-vllm-capture.txt"
TIMELINE="${OUT_DIR}/oc-vllm-capture-timeline.txt"

if [[ "${EUID}" -ne 0 ]]; then
    echo "This script needs root (raw packet capture). Re-run with sudo." >&2
    exit 1
fi

mkdir -p "${OUT_DIR}"

echo "Capturing loopback tcp ports 8007 and 8008 for ${CAPTURE_SECONDS}s -> ${PCAP}"
echo "Drive a live multi-turn OpenCode conversation against a qwen3.8-27b-bf16-896k-mtp-1/-2 model NOW."
echo "(Include a few turns with a 10-20s pause between them to observe idle-gap behavior.)"
echo

timeout "${CAPTURE_SECONDS}" tcpdump -i lo -s 0 -w "${PCAP}" 'tcp port 8007 or tcp port 8008' || true

echo
echo "Capture complete: ${PCAP}"
echo "Rendering readable dumps..."

tcpdump -r "${PCAP}" -A -q > "${ASCII}" 2>&1 || true
tcpdump -r "${PCAP}" -tttt -n > "${TIMELINE}" 2>&1 || true

echo
echo "Done. Review:"
echo "  ${ASCII}"
echo "      -- headers/body content; check 'grep -i \"^x-\" ${ASCII}' for any custom header OC sends"
echo "  ${TIMELINE}"
echo "      -- per-packet timestamps + 4-tuples; same source port repeating across turns"
echo "         of one conversation => keep-alive/connection reuse; a new source port each"
echo "         turn => a fresh TCP connection per turn. Gaps between a turn's last packet"
echo "         and the next turn's first packet show the real idle duration between turns."
