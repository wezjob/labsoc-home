#!/bin/bash
# ============================================
# LABSOC HOME - Analyze PCAP with Zeek
# ============================================
# Usage: ./analyze-pcap-zeek.sh <pcap_file>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [ -z "$1" ]; then
    echo "Usage: $0 <pcap_file>"
    echo "Example: $0 /path/to/capture.pcap"
    exit 1
fi

PCAP_FILE="$1"
OUTPUT_DIR="$PROJECT_DIR/zeek/data/logs/pcap_$(date +%Y%m%d_%H%M%S)"

echo "🔍 Analyzing PCAP with Zeek: $PCAP_FILE"
echo "   Output: $OUTPUT_DIR"
echo "=================================================="

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

/opt/homebrew/bin/zeek -r "$PCAP_FILE" \
    "$PROJECT_DIR/zeek/config/local.zeek"

echo ""
echo "✅ Analysis complete!"
echo "   Logs: $OUTPUT_DIR/"
ls -la "$OUTPUT_DIR"
