#!/bin/bash
# ============================================
# LABSOC HOME - Start Suricata (Native macOS)
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Log directory (shared with Filebeat via Docker mount)
LOG_DIR="/opt/homebrew/var/log/suricata"

# Get default interface
INTERFACE="${1:-en0}"

echo "🦊 Starting Suricata on interface: $INTERFACE"
echo "=================================================="
echo "📁 Logs will be written to: $LOG_DIR"
echo "📄 EVE JSON logs: $LOG_DIR/eve.json"
echo ""

# Create log directory
mkdir -p "$LOG_DIR"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  Suricata needs root privileges for packet capture."
    echo "   Running with sudo..."
    sudo /opt/homebrew/bin/suricata -c "$PROJECT_DIR/suricata/config/suricata.yaml" \
        -i "$INTERFACE" \
        -l "$LOG_DIR" \
        --set vars.address-groups.HOME_NET="[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12]"
else
    /opt/homebrew/bin/suricata -c "$PROJECT_DIR/suricata/config/suricata.yaml" \
        -i "$INTERFACE" \
        -l "$LOG_DIR" \
        --set vars.address-groups.HOME_NET="[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12]"
fi
