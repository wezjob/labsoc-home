#!/bin/bash
# ============================================
# LABSOC HOME - Backup Script
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_DIR/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "💾 SOC-in-a-Box - Creating Backup..."
echo "=================================================="

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup Elasticsearch indices
echo "📊 Backing up Elasticsearch data..."
curl -s -X PUT -u elastic:${ELASTIC_PASSWORD:-LabSoc2026!} \
    "http://localhost:9200/_snapshot/labsoc_backup" \
    -H "Content-Type: application/json" \
    -d "{
        \"type\": \"fs\",
        \"settings\": {
            \"location\": \"/usr/share/elasticsearch/backup\"
        }
    }" > /dev/null 2>&1 || true

curl -s -X PUT -u elastic:${ELASTIC_PASSWORD:-LabSoc2026!} \
    "http://localhost:9200/_snapshot/labsoc_backup/snapshot_$TIMESTAMP?wait_for_completion=true" > /dev/null

# Backup configurations
echo "📁 Backing up configurations..."
tar -czf "$BACKUP_DIR/config_$TIMESTAMP.tar.gz" \
    -C "$PROJECT_DIR" \
    elasticsearch/config \
    kibana/config \
    logstash/config \
    suricata/config \
    zeek/config \
    rules \
    .env

# Backup n8n workflows
echo "📋 Backing up n8n workflows..."
tar -czf "$BACKUP_DIR/n8n_$TIMESTAMP.tar.gz" \
    -C "$PROJECT_DIR" \
    n8n/data

echo ""
echo "✅ Backup completed!"
echo "   Location: $BACKUP_DIR"
echo ""
