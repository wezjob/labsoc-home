#!/bin/bash
# ============================================
# LABSOC HOME - Start Zeek (Native macOS)
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Log directory (shared with Filebeat via Docker mount)
LOG_DIR="/opt/homebrew/var/log/zeek"

# Get default interface
INTERFACE="${1:-en0}"

echo "🔍 Starting Zeek on interface: $INTERFACE"
echo "=================================================="
echo "📁 Logs will be written to: $LOG_DIR"
echo "📄 Zeek will create: conn.log, dns.log, http.log, etc."
echo ""

# Create log directory
mkdir -p "$LOG_DIR/current"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  Zeek needs root privileges for packet capture."
    echo "   Running with sudo..."
    cd "$LOG_DIR/current"
    sudo /opt/homebrew/bin/zeek -i "$INTERFACE" \
        "$PROJECT_DIR/zeek/config/local.zeek"
else
    cd "$LOG_DIR/current"
    /opt/homebrew/bin/zeek -i "$INTERFACE" \
        "$PROJECT_DIR/zeek/config/local.zeek"
fi
