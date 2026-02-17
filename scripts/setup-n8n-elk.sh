#!/bin/bash
# ============================================
# LABSOC HOME - Setup n8n Credentials for ELK
# ============================================

echo "🔧 LabSOC - n8n + ELK Integration Setup"
echo "========================================"
echo ""

N8N_URL="http://localhost:5678"
ES_USER="elastic"
ES_PASS="LabSoc2026!"

echo "📋 Configuration:"
echo "   n8n URL: $N8N_URL"
echo "   Elasticsearch: http://localhost:9200"
echo "   User: $ES_USER"
echo ""

# Check n8n is running
echo "🔍 Checking n8n status..."
if curl -s "$N8N_URL/healthz" > /dev/null 2>&1; then
    echo "✅ n8n is running"
else
    echo "❌ n8n is not accessible at $N8N_URL"
    echo "   Make sure Docker containers are running: docker compose up -d"
    exit 1
fi

echo ""
echo "📥 To import workflows into n8n:"
echo ""
echo "1. Open n8n: http://localhost:5678"
echo "   Login: admin / LabSocN8N2026!"
echo ""
echo "2. Create Elasticsearch credentials:"
echo "   - Go to Settings > Credentials > Add Credential"
echo "   - Type: HTTP Basic Auth"
echo "   - Name: Elasticsearch"
echo "   - User: elastic"
echo "   - Password: LabSoc2026!"
echo ""
echo "3. Import workflows:"
echo "   - Go to Workflows > Import from File"
echo "   - Import these files from ~/labsoc-home/n8n/workflows/:"
echo "     • alert-monitor-elk.json"
echo "     • webhook-alert-receiver.json"
echo ""
echo "4. Activate the workflows after import"
echo ""
echo "📡 Webhook endpoint (after activating):"
echo "   POST http://localhost:5678/webhook/labsoc-alert"
echo ""
echo "🧪 Test the webhook:"
echo ""
echo "curl -X POST 'http://localhost:5678/webhook/labsoc-alert' \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{"
echo "    \"alert_id\": \"test-001\","
echo "    \"severity\": \"critical\","
echo "    \"source\": \"manual-test\","
echo "    \"rule_name\": \"Test Alert Rule\","
echo "    \"source_ip\": \"10.0.0.100\","
echo "    \"dest_ip\": \"192.168.1.1\","
echo "    \"message\": \"This is a test critical alert\""
echo "  }'"
echo ""
