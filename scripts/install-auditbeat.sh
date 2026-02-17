#!/bin/bash
# ============================================
# LABSOC HOME - Install & Configure Auditbeat
# Host-based Intrusion Detection for macOS
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
AUDITBEAT_VERSION="8.11.0"

echo "🛡️  LabSOC - Auditbeat Installation (HIDS)"
echo "=============================================="
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed. Please install it first."
    exit 1
fi

# Check if Elasticsearch is running
echo "📡 Checking Elasticsearch connection..."
if ! curl -s -u elastic:LabSoc2026! http://localhost:9200 > /dev/null 2>&1; then
    echo "❌ Cannot connect to Elasticsearch. Make sure Docker containers are running."
    echo "   Run: cd $PROJECT_DIR && docker compose up -d"
    exit 1
fi
echo "✅ Elasticsearch is running"

# Check if Auditbeat is already installed
if command -v auditbeat &> /dev/null; then
    echo "✅ Auditbeat is already installed"
    auditbeat version
else
    echo "📦 Installing Auditbeat via Homebrew..."
    brew tap elastic/tap 2>/dev/null || true
    brew install elastic/tap/auditbeat-full
fi

# Create log directory
echo "📁 Creating log directory..."
sudo mkdir -p /opt/homebrew/var/log/auditbeat
sudo chown -R $(whoami) /opt/homebrew/var/log/auditbeat

# Copy configuration
echo "📝 Copying configuration..."
AUDITBEAT_CONFIG_DIR="/opt/homebrew/etc/auditbeat"
sudo mkdir -p "$AUDITBEAT_CONFIG_DIR"
sudo cp "$PROJECT_DIR/auditbeat/config/auditbeat.yml" "$AUDITBEAT_CONFIG_DIR/auditbeat.yml"

# Test configuration
echo "🔍 Testing configuration..."
sudo auditbeat test config -c "$AUDITBEAT_CONFIG_DIR/auditbeat.yml"

# Setup dashboards and index templates
echo "📊 Setting up Kibana dashboards and index templates..."
sudo auditbeat setup -c "$AUDITBEAT_CONFIG_DIR/auditbeat.yml" --dashboards 2>/dev/null || echo "⚠️  Dashboard setup skipped (may already exist)"
sudo auditbeat setup -c "$AUDITBEAT_CONFIG_DIR/auditbeat.yml" --index-management 2>/dev/null || true

echo ""
echo "✅ Auditbeat installation complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Start Auditbeat:    sudo auditbeat -c $AUDITBEAT_CONFIG_DIR/auditbeat.yml"
echo "   2. Or run as service:  sudo brew services start elastic/tap/auditbeat-full"
echo ""
echo "🔒 Auditbeat will monitor:"
echo "   - File integrity (FIM) for critical directories"
echo "   - Running processes"
echo "   - Network connections (sockets)"
echo "   - Login events"
echo "   - User accounts"
echo ""
echo "📊 View data in Kibana:"
echo "   http://localhost:5601 → Discover → auditbeat-*"
