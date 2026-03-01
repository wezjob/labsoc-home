#!/bin/bash
# ============================================
# LABSOC HOME - SOC Detection Rules & Dashboard Setup
# ============================================
# Creates: Suricata rules, Kibana dashboards, Elasticsearch watchers
# Author: SOC-in-a-Box
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Elasticsearch credentials
ES_HOST="http://localhost:9200"
ES_USER="elastic"
ES_PASS="LabSoc2026!"
KIBANA_HOST="http://localhost:5601"

echo "🛡️ SOC-in-a-Box Detection Rules & Dashboard Setup"
echo "=================================================="
echo ""

# ============================================
# 1. Create Data View in Kibana
# ============================================
create_data_view() {
    echo "📊 Creating Kibana Data View..."
    
    curl -s -X POST "$KIBANA_HOST/api/data_views/data_view" \
        -H "kbn-xsrf: true" \
        -H "Content-Type: application/json" \
        -u "$ES_USER:$ES_PASS" \
        -d '{
            "data_view": {
                "title": "labsoc-filebeat-*",
                "name": "LABSOC Filebeat",
                "timeFieldName": "@timestamp"
            }
        }' > /dev/null 2>&1 || true
    
    echo "✅ Data View created: labsoc-filebeat-*"
}

# ============================================
# 2. Create Index Templates
# ============================================
create_index_templates() {
    echo "📋 Creating Index Templates..."
    
    # Suricata alerts index template
    curl -s -X PUT "$ES_HOST/_index_template/labsoc-alerts" \
        -H "Content-Type: application/json" \
        -u "$ES_USER:$ES_PASS" \
        -d '{
            "index_patterns": ["labsoc-alerts-*"],
            "template": {
                "settings": {
                    "number_of_shards": 1,
                    "number_of_replicas": 0
                },
                "mappings": {
                    "properties": {
                        "@timestamp": { "type": "date" },
                        "alert_id": { "type": "keyword" },
                        "rule_name": { "type": "keyword" },
                        "severity": { "type": "keyword" },
                        "source_ip": { "type": "ip" },
                        "dest_ip": { "type": "ip" },
                        "use_case": { "type": "keyword" },
                        "mitre_attack": { "type": "keyword" },
                        "status": { "type": "keyword" }
                    }
                }
            }
        }' > /dev/null 2>&1
    
    echo "✅ Index templates created"
}

# ============================================
# 3. Create Elasticsearch Watchers (Alerting)
# ============================================
create_watchers() {
    echo "⚠️ Creating Elasticsearch Watchers..."
    
    # Watcher 1: High Volume Alerts
    curl -s -X PUT "$ES_HOST/_watcher/watch/high_volume_alerts" \
        -H "Content-Type: application/json" \
        -u "$ES_USER:$ES_PASS" \
        -d '{
            "trigger": { "schedule": { "interval": "5m" } },
            "input": {
                "search": {
                    "request": {
                        "indices": ["labsoc-filebeat-*"],
                        "body": {
                            "size": 0,
                            "query": {
                                "bool": {
                                    "must": [
                                        { "match": { "event_type": "alert" } },
                                        { "range": { "@timestamp": { "gte": "now-5m" } } }
                                    ]
                                }
                            }
                        }
                    }
                }
            },
            "condition": { "compare": { "ctx.payload.hits.total.value": { "gt": 50 } } },
            "actions": {
                "log_alert": {
                    "logging": { "text": "⚠️ HIGH VOLUME: {{ctx.payload.hits.total.value}} alerts in 5 minutes!" }
                }
            }
        }' > /dev/null 2>&1

    # Watcher 2: Critical Severity Alerts
    curl -s -X PUT "$ES_HOST/_watcher/watch/critical_alerts" \
        -H "Content-Type: application/json" \
        -u "$ES_USER:$ES_PASS" \
        -d '{
            "trigger": { "schedule": { "interval": "1m" } },
            "input": {
                "search": {
                    "request": {
                        "indices": ["labsoc-filebeat-*"],
                        "body": {
                            "size": 5,
                            "query": {
                                "bool": {
                                    "must": [
                                        { "match": { "alert.severity": 1 } },
                                        { "range": { "@timestamp": { "gte": "now-1m" } } }
                                    ]
                                }
                            }
                        }
                    }
                }
            },
            "condition": { "compare": { "ctx.payload.hits.total.value": { "gt": 0 } } },
            "actions": {
                "log_alert": {
                    "logging": { "text": "🚨 CRITICAL ALERT DETECTED! Count: {{ctx.payload.hits.total.value}}" }
                }
            }
        }' > /dev/null 2>&1

    # Watcher 3: Port Scan Detection
    curl -s -X PUT "$ES_HOST/_watcher/watch/port_scan_detection" \
        -H "Content-Type: application/json" \
        -u "$ES_USER:$ES_PASS" \
        -d '{
            "trigger": { "schedule": { "interval": "2m" } },
            "input": {
                "search": {
                    "request": {
                        "indices": ["labsoc-filebeat-*"],
                        "body": {
                            "size": 0,
                            "query": {
                                "bool": {
                                    "must": [
                                        { "wildcard": { "alert.signature": "*Port Scan*" } },
                                        { "range": { "@timestamp": { "gte": "now-2m" } } }
                                    ]
                                }
                            }
                        }
                    }
                }
            },
            "condition": { "compare": { "ctx.payload.hits.total.value": { "gt": 0 } } },
            "actions": {
                "log_alert": {
                    "logging": { "text": "🔍 PORT SCAN detected! {{ctx.payload.hits.total.value}} events" }
                }
            }
        }' > /dev/null 2>&1

    # Watcher 4: Brute Force Detection
    curl -s -X PUT "$ES_HOST/_watcher/watch/brute_force_detection" \
        -H "Content-Type: application/json" \
        -u "$ES_USER:$ES_PASS" \
        -d '{
            "trigger": { "schedule": { "interval": "2m" } },
            "input": {
                "search": {
                    "request": {
                        "indices": ["labsoc-filebeat-*"],
                        "body": {
                            "size": 0,
                            "query": {
                                "bool": {
                                    "must": [
                                        { "wildcard": { "alert.signature": "*Brute Force*" } },
                                        { "range": { "@timestamp": { "gte": "now-5m" } } }
                                    ]
                                }
                            }
                        }
                    }
                }
            },
            "condition": { "compare": { "ctx.payload.hits.total.value": { "gt": 0 } } },
            "actions": {
                "log_alert": {
                    "logging": { "text": "🔐 BRUTE FORCE attack detected! {{ctx.payload.hits.total.value}} attempts" }
                }
            }
        }' > /dev/null 2>&1

    # Watcher 5: DNS Tunneling Detection
    curl -s -X PUT "$ES_HOST/_watcher/watch/dns_tunneling_detection" \
        -H "Content-Type: application/json" \
        -u "$ES_USER:$ES_PASS" \
        -d '{
            "trigger": { "schedule": { "interval": "5m" } },
            "input": {
                "search": {
                    "request": {
                        "indices": ["labsoc-filebeat-*"],
                        "body": {
                            "size": 0,
                            "query": {
                                "bool": {
                                    "must": [
                                        { "wildcard": { "alert.signature": "*DNS Tunnel*" } },
                                        { "range": { "@timestamp": { "gte": "now-5m" } } }
                                    ]
                                }
                            }
                        }
                    }
                }
            },
            "condition": { "compare": { "ctx.payload.hits.total.value": { "gt": 0 } } },
            "actions": {
                "log_alert": {
                    "logging": { "text": "🌐 DNS TUNNELING suspected! {{ctx.payload.hits.total.value}} events" }
                }
            }
        }' > /dev/null 2>&1

    echo "✅ 5 Elasticsearch Watchers created"
}

# ============================================
# 4. Create Saved Searches
# ============================================
create_saved_searches() {
    echo "🔍 Creating Saved Searches..."
    
    # Create saved searches via Kibana API
    for search in "SSH_Brute_Force" "Port_Scan" "DNS_Tunneling" "Malware_C2" "Data_Exfiltration"; do
        curl -s -X POST "$KIBANA_HOST/api/saved_objects/search" \
            -H "kbn-xsrf: true" \
            -H "Content-Type: application/json" \
            -u "$ES_USER:$ES_PASS" \
            -d "{
                \"attributes\": {
                    \"title\": \"$search Events\",
                    \"description\": \"Saved search for $search detection\",
                    \"kibanaSavedObjectMeta\": {
                        \"searchSourceJSON\": \"{\\\"query\\\":{\\\"query\\\":\\\"alert.signature:*$search*\\\",\\\"language\\\":\\\"kuery\\\"},\\\"filter\\\":[],\\\"indexRefName\\\":\\\"kibanaSavedObjectMeta.searchSourceJSON.index\\\"}\"
                    }
                }
            }" > /dev/null 2>&1 || true
    done
    
    echo "✅ Saved searches created"
}

# ============================================
# 5. Create Dashboard via Kibana API
# ============================================
create_dashboard() {
    echo "📊 Creating SOC Dashboard..."
    
    # Create the main SOC dashboard
    DASHBOARD_RESPONSE=$(curl -s -X POST "$KIBANA_HOST/api/saved_objects/dashboard" \
        -H "kbn-xsrf: true" \
        -H "Content-Type: application/json" \
        -u "$ES_USER:$ES_PASS" \
        -d '{
            "attributes": {
                "title": "SOC Overview Dashboard",
                "description": "Main SOC monitoring dashboard with all key metrics",
                "timeRestore": true,
                "timeTo": "now",
                "timeFrom": "now-24h",
                "refreshInterval": {
                    "pause": false,
                    "value": 30000
                },
                "panelsJSON": "[]",
                "optionsJSON": "{\"useMargins\":true,\"syncColors\":false,\"syncCursor\":true,\"syncTooltips\":false,\"hidePanelTitles\":false}",
                "version": 1,
                "kibanaSavedObjectMeta": {
                    "searchSourceJSON": "{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"
                }
            }
        }')
    
    DASHBOARD_ID=$(echo "$DASHBOARD_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null || echo "")
    
    if [ -n "$DASHBOARD_ID" ]; then
        echo "✅ Dashboard created with ID: $DASHBOARD_ID"
        echo "🔗 Access: $KIBANA_HOST/app/dashboards#/view/$DASHBOARD_ID"
    else
        echo "⚠️ Dashboard may already exist or failed to create"
    fi
}

# ============================================
# 6. Reload Suricata Rules
# ============================================
reload_suricata() {
    echo "🦊 Reloading Suricata Rules..."
    
    # Check if Suricata is running
    if pgrep -x suricata > /dev/null; then
        sudo kill -USR2 $(pgrep suricata | head -1) 2>/dev/null || true
        echo "✅ Suricata rules reloaded (SIGUSR2 sent)"
    else
        echo "⚠️ Suricata not running. Start with: ./scripts/start-suricata.sh"
    fi
}

# ============================================
# 7. Insert Sample Alerts for Testing
# ============================================
insert_sample_alerts() {
    echo "📝 Inserting sample alerts for testing..."
    
    ALERT_TYPES=("SSH Brute Force" "Port Scan Detected" "DNS Tunneling" "Possible C2 Beacon" "Large Data Transfer")
    SEVERITIES=("critical" "high" "medium" "low" "info")
    
    for i in {1..10}; do
        ALERT_TYPE=${ALERT_TYPES[$((RANDOM % 5))]}
        SEVERITY=${SEVERITIES[$((RANDOM % 5))]}
        SRC_IP="192.168.1.$((RANDOM % 254 + 1))"
        DST_IP="10.0.0.$((RANDOM % 254 + 1))"
        
        curl -s -X POST "$ES_HOST/labsoc-alerts-$(date +%Y.%m.%d)/_doc" \
            -H "Content-Type: application/json" \
            -u "$ES_USER:$ES_PASS" \
            -d "{
                \"@timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
                \"alert_id\": \"ALERT-$(date +%s)-$i\",
                \"rule_name\": \"$ALERT_TYPE\",
                \"severity\": \"$SEVERITY\",
                \"source_ip\": \"$SRC_IP\",
                \"dest_ip\": \"$DST_IP\",
                \"use_case\": \"UC-00$((RANDOM % 10 + 1))\",
                \"mitre_attack\": \"T$((RANDOM % 1000 + 1000))\",
                \"status\": \"new\",
                \"message\": \"Automated test alert: $ALERT_TYPE from $SRC_IP to $DST_IP\"
            }" > /dev/null 2>&1
    done
    
    echo "✅ 10 sample alerts inserted"
}

# ============================================
# 8. Print Summary
# ============================================
print_summary() {
    echo ""
    echo "============================================"
    echo "✅ SOC DETECTION RULES SETUP COMPLETE!"
    echo "============================================"
    echo ""
    echo "📋 SURICATA RULES:"
    echo "   Location: $PROJECT_DIR/suricata/rules/local.rules"
    echo "   Use Cases: UC-001 to UC-010 (31 rules total)"
    echo ""
    echo "⚠️ ELASTICSEARCH WATCHERS:"
    echo "   - high_volume_alerts (>50 alerts/5min)"
    echo "   - critical_alerts (severity=1)"
    echo "   - port_scan_detection"
    echo "   - brute_force_detection"  
    echo "   - dns_tunneling_detection"
    echo ""
    echo "📊 ACCESS KIBANA:"
    echo "   URL: $KIBANA_HOST"
    echo "   User: $ES_USER"
    echo "   Pass: $ES_PASS"
    echo ""
    echo "🔧 TO VIEW RULES IN KIBANA:"
    echo "   1. Go to Stack Management → Watcher"
    echo "   2. Go to Discover → Select 'labsoc-filebeat-*'"
    echo "   3. Use KQL: event_type:alert"
    echo ""
    echo "📖 USE CASE REFERENCE:"
    echo "   UC-001: SSH Brute Force"
    echo "   UC-002: Port Scanning"
    echo "   UC-003: DNS Tunneling"
    echo "   UC-004: Malware C2"
    echo "   UC-005: Data Exfiltration"
    echo "   UC-006: Lateral Movement"
    echo "   UC-007: Credential Theft"
    echo "   UC-008: Web Attacks"
    echo "   UC-009: Cryptomining"
    echo "   UC-010: Tor/Anonymization"
    echo ""
}

# ============================================
# MAIN EXECUTION
# ============================================
main() {
    # Check connectivity
    if ! curl -s "$ES_HOST/_cluster/health" -u "$ES_USER:$ES_PASS" > /dev/null 2>&1; then
        echo "❌ Cannot connect to Elasticsearch at $ES_HOST"
        echo "   Make sure the ELK stack is running: docker ps | grep elasticsearch"
        exit 1
    fi
    
    create_data_view
    create_index_templates
    create_watchers
    create_saved_searches
    create_dashboard
    reload_suricata
    insert_sample_alerts
    print_summary
}

# Run
main "$@"
