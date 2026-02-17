#!/bin/bash
# ============================================
# LABSOC HOME - Setup Kibana Alerting Rules
# Free alternative to Elasticsearch Watcher
# ============================================

KIBANA_URL="http://localhost:5601"
ES_USER="elastic"
ES_PASS="LabSoc2026!"

echo "⚙️  Setting up Kibana Alerting Rules..."
echo ""

# Check Kibana is available
if ! curl -s -u "${ES_USER}:${ES_PASS}" "${KIBANA_URL}/api/status" > /dev/null 2>&1; then
    echo "❌ Cannot connect to Kibana"
    exit 1
fi

echo "✅ Kibana is accessible"
echo ""

# Create connector for n8n webhook
echo "📋 Creating Webhook Connector for n8n..."
CONNECTOR_RESPONSE=$(curl -s -u "${ES_USER}:${ES_PASS}" \
    -X POST "${KIBANA_URL}/api/actions/connector" \
    -H "kbn-xsrf: true" \
    -H "Content-Type: application/json" \
    -d '{
      "connector_type_id": ".webhook",
      "name": "n8n LabSOC Webhook",
      "config": {
        "url": "http://labsoc-n8n:5678/webhook/labsoc-alert",
        "method": "post",
        "headers": {
          "Content-Type": "application/json"
        }
      },
      "secrets": {}
    }')

CONNECTOR_ID=$(echo "$CONNECTOR_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('id', 'error'))" 2>/dev/null)

if [ "$CONNECTOR_ID" != "error" ] && [ -n "$CONNECTOR_ID" ]; then
    echo "✅ Connector created: $CONNECTOR_ID"
else
    echo "⚠️  Connector may already exist or there was an issue"
    echo "   Response: $CONNECTOR_RESPONSE"
    # Try to get existing connector
    CONNECTOR_ID=$(curl -s -u "${ES_USER}:${ES_PASS}" \
        "${KIBANA_URL}/api/actions/connectors" \
        -H "kbn-xsrf: true" | python3 -c "
import sys,json
data = json.load(sys.stdin)
for c in data:
    if 'n8n' in c.get('name', '').lower():
        print(c['id'])
        break
" 2>/dev/null)
fi

echo ""
echo "📋 Creating Alert Rule for Critical Events..."
curl -s -u "${ES_USER}:${ES_PASS}" \
    -X POST "${KIBANA_URL}/api/alerting/rule" \
    -H "kbn-xsrf: true" \
    -H "Content-Type: application/json" \
    -d "{
      \"name\": \"LabSOC - Critical Alert Monitor\",
      \"consumer\": \"alerts\",
      \"tags\": [\"labsoc\", \"security\", \"critical\"],
      \"rule_type_id\": \".es-query\",
      \"schedule\": {
        \"interval\": \"1m\"
      },
      \"params\": {
        \"index\": [\"labsoc-*\"],
        \"timeField\": \"@timestamp\",
        \"esQuery\": \"{\\\"query\\\":{\\\"bool\\\":{\\\"must\\\":[{\\\"term\\\":{\\\"event.kind\\\":\\\"alert\\\"}},{\\\"terms\\\":{\\\"event.severity\\\":[\\\"critical\\\",\\\"high\\\"]}}]}}}\",
        \"size\": 100,
        \"timeWindowSize\": 5,
        \"timeWindowUnit\": \"m\",
        \"threshold\": [1],
        \"thresholdComparator\": \">=\"
      },
      \"actions\": [],
      \"enabled\": true
    }" | python3 -c "
import sys,json
try:
    data = json.load(sys.stdin)
    if 'id' in data:
        print(f\"✅ Alert rule created: {data['id']}\")
    else:
        print(f\"⚠️  Response: {data}\")
except Exception as e:
    print(f\"Error parsing response: {e}\")
"

echo ""
echo "========================================"
echo "📋 Summary"
echo "========================================"
echo ""
echo "Since Elasticsearch Watcher requires a license, we use:"
echo ""
echo "1. ✅ n8n Scheduled Workflow (polls ES every 5 min)"
echo "   - Workflow: alert-monitor-elk.json"
echo ""
echo "2. ✅ n8n Webhook Receiver (receives external alerts)"  
echo "   - Webhook: http://localhost:5678/webhook/labsoc-alert"
echo "   - Workflow: webhook-alert-receiver.json"
echo ""
echo "3. ✅ Kibana Alerting Rule (monitors critical alerts)"
echo "   - Rule: LabSOC - Critical Alert Monitor"
echo "   - Check: Menu → Stack Management → Rules"
echo ""
echo "📍 Import n8n workflows:"
echo "   1. Go to http://localhost:5678"
echo "   2. Login: admin / LabSocN8N2026!"
echo "   3. Create HTTP Basic Auth credential:"
echo "      Name: Elasticsearch"
echo "      User: elastic"
echo "      Password: LabSoc2026!"
echo "   4. Import workflows from ~/labsoc-home/n8n/workflows/"
echo ""
