#!/bin/bash
# ============================================
# LABSOC HOME - Analyze PCAP with Suricata
# ============================================
# Usage: ./analyze-pcap.sh <pcap_file>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [ -z "$1" ]; then
    echo "Usage: $0 <pcap_file>"
    echo "Example: $0 /path/to/capture.pcap"
    exit 1
fi

PCAP_FILE="$1"
OUTPUT_DIR="$PROJECT_DIR/suricata/data/log/pcap_$(date +%Y%m%d_%H%M%S)"

echo "🦊 Analyzing PCAP with Suricata: $PCAP_FILE"
echo "   Output: $OUTPUT_DIR"
echo "=================================================="

mkdir -p "$OUTPUT_DIR"

/opt/homebrew/bin/suricata -c "$PROJECT_DIR/suricata/config/suricata.yaml" \
    -r "$PCAP_FILE" \
    -l "$OUTPUT_DIR" \
    --set vars.address-groups.HOME_NET="[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12]"

echo ""
echo "✅ Analysis complete!"
echo "   EVE JSON: $OUTPUT_DIR/eve.json"
echo "   Fast log: $OUTPUT_DIR/fast.log"
