#!/bin/bash
# ============================================
# LABSOC HOME - Start Auditbeat (HIDS)
# ============================================

set -e

AUDITBEAT_CONFIG="/opt/homebrew/etc/auditbeat/auditbeat.yml"

echo "🛡️  Starting Auditbeat (HIDS)..."
echo "=================================="

# Check if config exists
if [ ! -f "$AUDITBEAT_CONFIG" ]; then
    echo "❌ Configuration not found: $AUDITBEAT_CONFIG"
    echo "   Run: ./scripts/install-auditbeat.sh first"
    exit 1
fi

# Check if already running
if pgrep -x "auditbeat" > /dev/null; then
    echo "⚠️  Auditbeat is already running"
    echo "   PID: $(pgrep -x auditbeat)"
    echo ""
    echo "   To stop: sudo pkill auditbeat"
    exit 0
fi

echo "📊 Monitoring:"
echo "   - File Integrity (FIM)"
echo "   - Processes"
echo "   - Network Sockets"
echo "   - Login Events"
echo "   - User Accounts"
echo ""
echo "📁 Logs: /opt/homebrew/var/log/auditbeat/"
echo "📤 Output: Logstash (localhost:5044)"
echo ""

# Start auditbeat
if [ "$EUID" -ne 0 ]; then
    echo "⚠️  Auditbeat needs root privileges for system monitoring."
    echo "   Running with sudo..."
    sudo auditbeat -c "$AUDITBEAT_CONFIG" -e
else
    auditbeat -c "$AUDITBEAT_CONFIG" -e
fi
