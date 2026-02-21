#!/bin/bash
# =============================================================================
# SOC-in-a-Box - Uptime Kuma Auto-Configuration Script
# =============================================================================
# This script adds all SOC services to Uptime Kuma monitoring
# Requires: curl, jq
# Usage: ./configure-uptime-kuma.sh <username> <password>
# =============================================================================

set -e

UPTIME_KUMA_URL="${UPTIME_KUMA_URL:-http://localhost:3001}"
USERNAME="${1:-admin}"
PASSWORD="${2:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check dependencies
command -v curl >/dev/null 2>&1 || { log_error "curl is required"; exit 1; }
command -v jq >/dev/null 2>&1 || { log_error "jq is required. Install with: brew install jq"; exit 1; }

if [ -z "$PASSWORD" ]; then
    echo -n "Enter Uptime Kuma password: "
    read -s PASSWORD
    echo
fi

# =============================================================================
# Uptime Kuma API Functions
# =============================================================================

# Login and get token
login() {
    log_info "Logging in to Uptime Kuma..."
    RESPONSE=$(curl -s -X POST "${UPTIME_KUMA_URL}/api/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"${USERNAME}\",\"password\":\"${PASSWORD}\"}")
    
    TOKEN=$(echo "$RESPONSE" | jq -r '.token // empty')
    if [ -z "$TOKEN" ]; then
        log_error "Login failed. Please check credentials."
        log_error "Response: $RESPONSE"
        exit 1
    fi
    log_info "Login successful"
}

# Add HTTP monitor
add_monitor() {
    local name="$1"
    local url="$2"
    local method="${3:-GET}"
    local interval="${4:-60}"
    
    log_info "Adding monitor: $name -> $url"
    
    RESPONSE=$(curl -s -X POST "${UPTIME_KUMA_URL}/api/add-monitor" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${TOKEN}" \
        -d "{
            \"name\": \"${name}\",
            \"type\": \"http\",
            \"url\": \"${url}\",
            \"method\": \"${method}\",
            \"interval\": ${interval},
            \"retryInterval\": 60,
            \"maxretries\": 3,
            \"accepted_statuscodes\": [\"200-299\", \"301\", \"302\", \"401\", \"403\"],
            \"active\": true
        }")
    
    MONITOR_ID=$(echo "$RESPONSE" | jq -r '.monitorID // empty')
    if [ -n "$MONITOR_ID" ]; then
        log_info "  ✓ Monitor added (ID: $MONITOR_ID)"
    else
        ERROR=$(echo "$RESPONSE" | jq -r '.msg // "Unknown error"')
        if [[ "$ERROR" == *"already"* ]] || [[ "$ERROR" == *"exist"* ]]; then
            log_warn "  → Monitor already exists"
        else
            log_warn "  → Could not add: $ERROR"
        fi
    fi
}

# Add TCP monitor for non-HTTP services
add_tcp_monitor() {
    local name="$1"
    local host="$2"
    local port="$3"
    local interval="${4:-60}"
    
    log_info "Adding TCP monitor: $name -> $host:$port"
    
    RESPONSE=$(curl -s -X POST "${UPTIME_KUMA_URL}/api/add-monitor" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${TOKEN}" \
        -d "{
            \"name\": \"${name}\",
            \"type\": \"port\",
            \"hostname\": \"${host}\",
            \"port\": ${port},
            \"interval\": ${interval},
            \"retryInterval\": 60,
            \"maxretries\": 3,
            \"active\": true
        }")
    
    MONITOR_ID=$(echo "$RESPONSE" | jq -r '.monitorID // empty')
    if [ -n "$MONITOR_ID" ]; then
        log_info "  ✓ Monitor added (ID: $MONITOR_ID)"
    else
        ERROR=$(echo "$RESPONSE" | jq -r '.msg // "Unknown error"')
        log_warn "  → $ERROR"
    fi
}

# Create status page
create_status_page() {
    log_info "Creating status page..."
    
    curl -s -X POST "${UPTIME_KUMA_URL}/api/add-status-page" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${TOKEN}" \
        -d '{
            "slug": "soc-status",
            "title": "SOC-in-a-Box Status",
            "description": "Real-time status of all SOC services",
            "published": true
        }' >/dev/null 2>&1 || log_warn "Status page may already exist"
}

# =============================================================================
# Main Configuration
# =============================================================================

log_info "=============================================="
log_info "SOC-in-a-Box - Uptime Kuma Configuration"
log_info "=============================================="

login

log_info ""
log_info "Adding Core Infrastructure monitors..."
log_info "----------------------------------------------"
add_monitor "Elasticsearch" "http://host.docker.internal:9200" "GET" 30
add_monitor "Kibana" "http://host.docker.internal:5601/api/status" "GET" 60

log_info ""
log_info "Adding Security & Administration monitors..."
log_info "----------------------------------------------"
add_monitor "IRIS DFIR" "https://host.docker.internal:8443" "GET" 60
add_monitor "Keycloak" "http://host.docker.internal:8180/health" "GET" 60
add_monitor "Vaultwarden" "http://host.docker.internal:8085" "GET" 60
add_monitor "Nginx Proxy Manager" "http://host.docker.internal:81" "GET" 60

log_info ""
log_info "Adding Observability monitors..."
log_info "----------------------------------------------"
add_monitor "Grafana" "http://host.docker.internal:3000/api/health" "GET" 60
add_monitor "Prometheus" "http://host.docker.internal:9090/-/healthy" "GET" 60
add_monitor "Jaeger" "http://host.docker.internal:16686" "GET" 60

log_info ""
log_info "Adding Tools & Utilities monitors..."
log_info "----------------------------------------------"
add_monitor "Portainer" "http://host.docker.internal:9000/api/status" "GET" 60
add_monitor "n8n" "http://host.docker.internal:5678/healthz" "GET" 60
add_monitor "Uptime Kuma" "http://host.docker.internal:3001" "GET" 60
add_monitor "Homepage" "http://host.docker.internal:3003" "GET" 60
add_monitor "Dozzle" "http://host.docker.internal:8087" "GET" 60

log_info ""
log_info "Adding Analysis Tools monitors..."
log_info "----------------------------------------------"
add_monitor "CyberChef" "http://host.docker.internal:8088" "GET" 60
add_monitor "Jupyter" "http://host.docker.internal:8888" "GET" 60
add_monitor "Excalidraw" "http://host.docker.internal:3002" "GET" 120
add_monitor "Draw.io" "http://host.docker.internal:8089" "GET" 120

log_info ""
log_info "Adding Deception monitors..."
log_info "----------------------------------------------"
add_tcp_monitor "Cowrie SSH" "host.docker.internal" 2222 120
add_tcp_monitor "Cowrie Telnet" "host.docker.internal" 2223 120

log_info ""
log_info "Adding Network Security monitors..."
log_info "----------------------------------------------"
add_tcp_monitor "Suricata (via logs)" "host.docker.internal" 9200 120

# Create status page
log_info ""
create_status_page

log_info ""
log_info "=============================================="
log_info "Configuration complete!"
log_info "=============================================="
log_info "Access Uptime Kuma: ${UPTIME_KUMA_URL}"
log_info "Status Page: ${UPTIME_KUMA_URL}/status/soc-status"
log_info "=============================================="
