#!/bin/bash
# ============================================
# LABSOC HOME - Setup Elasticsearch Watcher
# Sends alerts to n8n webhook for automation
# ============================================

ES_URL="http://localhost:9200"
ES_USER="elastic"
ES_PASS="LabSoc2026!"

echo "⚙️  Setting up Elasticsearch Watcher for n8n integration..."
echo ""

# Check if Elasticsearch is available
if ! curl -s -u "${ES_USER}:${ES_PASS}" "${ES_URL}" > /dev/null 2>&1; then
    echo "❌ Cannot connect to Elasticsearch"
    exit 1
fi

# Create the watcher for critical alerts
echo "📋 Creating Critical Alert Watcher..."
curl -s -u "${ES_USER}:${ES_PASS}" -X PUT "${ES_URL}/_watcher/watch/labsoc-critical-alerts" \
    -H "Content-Type: application/json" \
    -d '{
  "trigger": {
    "schedule": {
      "interval": "1m"
    }
  },
  "input": {
    "search": {
      "request": {
        "indices": ["labsoc-*"],
        "body": {
          "query": {
            "bool": {
              "must": [
                { "term": { "event.kind": "alert" } },
                { "terms": { "event.severity": ["critical", "high"] } },
                { "range": { "@timestamp": { "gte": "now-1m" } } }
              ],
              "must_not": [
                { "exists": { "field": "labsoc.processed" } }
              ]
            }
          },
          "size": 10
        }
      }
    }
  },
  "condition": {
    "compare": {
      "ctx.payload.hits.total.value": {
        "gt": 0
      }
    }
  },
  "actions": {
    "notify_n8n": {
      "webhook": {
        "method": "POST",
        "url": "http://labsoc-n8n:5678/webhook/labsoc-alert",
        "headers": {
          "Content-Type": "application/json"
        },
        "body": "{{#toJson}}ctx.payload{{/toJson}}"
      }
    },
    "log_action": {
      "logging": {
        "text": "LabSOC: Found {{ctx.payload.hits.total.value}} critical/high alerts - sending to n8n"
      }
    }
  },
  "metadata": {
    "name": "LabSOC Critical Alert Notifier",
    "description": "Sends critical and high severity alerts to n8n for automated response",
    "owner": "labsoc"
  }
}' | python3 -m json.tool 2>/dev/null || echo "Watcher created"

echo ""
echo "📋 Creating IOC Alert Watcher..."
curl -s -u "${ES_USER}:${ES_PASS}" -X PUT "${ES_URL}/_watcher/watch/labsoc-ioc-alerts" \
    -H "Content-Type: application/json" \
    -d '{
  "trigger": {
    "schedule": {
      "interval": "5m"
    }
  },
  "input": {
    "search": {
      "request": {
        "indices": ["labsoc-suricata-*", "labsoc-alerts"],
        "body": {
          "query": {
            "bool": {
              "should": [
                { "wildcard": { "rule.name": "*C2*" } },
                { "wildcard": { "rule.name": "*DNS*Tunnel*" } },
                { "wildcard": { "rule.name": "*Ransomware*" } },
                { "wildcard": { "rule.name": "*Lateral*" } }
              ],
              "minimum_should_match": 1,
              "filter": [
                { "range": { "@timestamp": { "gte": "now-5m" } } }
              ]
            }
          },
          "size": 20
        }
      }
    }
  },
  "condition": {
    "compare": {
      "ctx.payload.hits.total.value": {
        "gt": 0
      }
    }
  },
  "actions": {
    "notify_n8n": {
      "webhook": {
        "method": "POST",
        "url": "http://labsoc-n8n:5678/webhook/labsoc-alert",
        "headers": {
          "Content-Type": "application/json"
        },
        "body": "{{#toJson}}ctx.payload{{/toJson}}"
      }
    }
  },
  "metadata": {
    "name": "LabSOC IOC Alert Notifier",
    "description": "Detects and escalates IOC-related alerts",
    "owner": "labsoc"
  }
}' | python3 -m json.tool 2>/dev/null || echo "Watcher created"

echo ""
echo "✅ Watchers created successfully!"
echo ""
echo "📋 Active Watchers:"
curl -s -u "${ES_USER}:${ES_PASS}" "${ES_URL}/_watcher/stats" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f\"   Watcher State: {data.get('stats', [{}])[0].get('watcher_state', 'unknown')}\")
    print(f\"   Execution Thread Pool: {data.get('stats', [{}])[0].get('execution_thread_pool', {})}\")
except:
    print('   Unable to parse watcher stats')
"

echo ""
echo "📍 To test the webhook, run:"
echo "   curl -X POST http://localhost:5678/webhook/labsoc-alert \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"alert_id\": \"test-1\", \"severity\": \"critical\", \"message\": \"Test alert\"}'"
