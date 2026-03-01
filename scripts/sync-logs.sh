#!/bin/bash
# ============================================
# LABSOC HOME - Sync Suricata/Zeek Logs
# ============================================
# This script syncs logs from native macOS tools to Docker-accessible path
# Run with: ./scripts/sync-logs.sh
# Or run continuously: ./scripts/sync-logs.sh --watch

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOGS_DIR="$PROJECT_DIR/logs"

# Source directories (native macOS via Homebrew)
SURICATA_SRC="/opt/homebrew/var/log/suricata"
ZEEK_SRC="/opt/homebrew/var/log/zeek/current"

# Destination directories (Docker-accessible)
SURICATA_DST="$LOGS_DIR/suricata"
ZEEK_DST="$LOGS_DIR/zeek/current"

sync_logs() {
    echo "🔄 Syncing Suricata/Zeek logs to Docker-accessible path..."
    
    # Create directories
    mkdir -p "$SURICATA_DST" "$ZEEK_DST"
    
    # Sync Suricata logs
    if [ -f "$SURICATA_SRC/eve.json" ]; then
        cp "$SURICATA_SRC/eve.json" "$SURICATA_DST/"
        echo "✅ Suricata: eve.json synced ($(du -h "$SURICATA_DST/eve.json" | cut -f1))"
    else
        echo "⚠️  Suricata: No eve.json found at $SURICATA_SRC"
    fi
    
    # Sync Zeek logs
    if [ -d "$ZEEK_SRC" ]; then
        for log in "$ZEEK_SRC"/*.log; do
            if [ -f "$log" ]; then
                cp "$log" "$ZEEK_DST/"
            fi
        done
        count=$(ls -1 "$ZEEK_DST"/*.log 2>/dev/null | wc -l)
        echo "✅ Zeek: $count log files synced"
    else
        echo "⚠️  Zeek: No logs found at $ZEEK_SRC"
    fi
    
    echo "📁 Logs synced to: $LOGS_DIR"
}

# Main
if [ "$1" = "--watch" ]; then
    echo "👁️  Watching for log changes (Ctrl+C to stop)..."
    while true; do
        sync_logs
        sleep 10
    done
else
    sync_logs
fi
