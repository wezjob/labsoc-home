#!/bin/bash
# ============================================
# LABSOC HOME - Update Rules Script
# ============================================

set -e

echo "🔄 LABSOC HOME - Updating Detection Rules..."
echo "=================================================="

# Update Suricata rules
echo "📥 Updating Suricata rules..."
docker exec labsoc-suricata suricata-update

# Reload Suricata rules
echo "🔄 Reloading Suricata rules..."
docker exec labsoc-suricata suricatasc -c reload-rules

echo ""
echo "✅ Rules updated successfully!"
echo ""
