#!/bin/bash
# ============================================
# LABSOC HOME - Startup Script
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🔵 LABSOC HOME - Starting Security Operations Center..."
echo "=================================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi

cd "$PROJECT_DIR"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Create necessary directories
echo "📁 Creating data directories..."
mkdir -p elasticsearch/data logstash/data kibana/data
mkdir -p suricata/data/log zeek/data/logs zeek/data/spool
mkdir -p n8n/data redis/data postgres/data
mkdir -p filebeat/data logs

# Set permissions for Elasticsearch
chmod -R 777 elasticsearch/data 2>/dev/null || true

# Pull images first
echo "📥 Pulling Docker images (this may take a while)..."
docker compose pull

# Start services
echo "🚀 Starting Docker containers..."
docker compose up -d

# Wait for Elasticsearch to be ready
echo "⏳ Waiting for Elasticsearch to be ready..."
max_attempts=30
attempt=0
until curl -s -u elastic:${ELASTIC_PASSWORD:-LabSoc2026!} http://localhost:9200/_cluster/health 2>/dev/null | grep -q '"status":"green"\|"status":"yellow"'; do
    attempt=$((attempt + 1))
    if [ $attempt -ge $max_attempts ]; then
        echo "⚠️  Elasticsearch is taking longer than expected. Check logs with: docker compose logs elasticsearch"
        break
    fi
    echo "   Attempt $attempt/$max_attempts - Waiting for Elasticsearch..."
    sleep 10
done

if [ $attempt -lt $max_attempts ]; then
    echo "✅ Elasticsearch is ready!"
fi

# Wait for Kibana
echo "⏳ Waiting for Kibana to be ready..."
attempt=0
until curl -s http://localhost:5601/api/status 2>/dev/null | grep -q '"level":"available"'; do
    attempt=$((attempt + 1))
    if [ $attempt -ge $max_attempts ]; then
        echo "⚠️  Kibana is taking longer than expected. Check logs with: docker compose logs kibana"
        break
    fi
    echo "   Attempt $attempt/$max_attempts - Waiting for Kibana..."
    sleep 10
done

if [ $attempt -lt $max_attempts ]; then
    echo "✅ Kibana is ready!"
fi

# Set kibana_system password
echo "🔑 Setting up Kibana system user..."
curl -s -X POST -u elastic:${ELASTIC_PASSWORD:-LabSoc2026!} \
    "http://localhost:9200/_security/user/kibana_system/_password" \
    -H "Content-Type: application/json" \
    -d "{\"password\": \"${KIBANA_PASSWORD:-LabSocKibana2026!}\"}" > /dev/null 2>&1 || true

# Create index templates
echo "📊 Creating index templates..."
curl -s -X PUT -u elastic:${ELASTIC_PASSWORD:-LabSoc2026!} \
    "http://localhost:9200/_index_template/labsoc-template" \
    -H "Content-Type: application/json" \
    -d '{
        "index_patterns": ["labsoc-*"],
        "template": {
            "settings": {
                "number_of_shards": 1,
                "number_of_replicas": 0
            }
        }
    }' > /dev/null 2>&1 || true

echo ""
echo "=================================================="
echo "✅ LABSOC HOME is ready!"
echo "=================================================="
echo ""
echo "📊 Access your services:"
echo "   • Kibana:         http://localhost:5601"
echo "   • n8n:            http://localhost:5678"
echo "   • Elasticsearch:  http://localhost:9200"
echo ""
echo "🔑 Default credentials:"
echo "   • Elastic:  elastic / LabSoc2026!"
echo "   • n8n:      admin / LabSocN8N2026!"
echo ""
echo "📝 Useful commands:"
echo "   • View logs:     docker compose logs -f"
echo "   • Stop:          ./scripts/stop.sh"
echo "   • Status:        docker compose ps"
echo ""
echo "🦉 To install IntelOwl (optional):"
echo "   ./scripts/install-intelowl.sh"
echo ""
