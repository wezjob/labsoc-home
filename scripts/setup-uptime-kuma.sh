#!/bin/bash
# =============================================================================
# SOC-in-a-Box - Uptime Kuma Auto-Configuration via Docker
# =============================================================================

set -e

UPTIME_KUMA_URL="${UPTIME_KUMA_URL:-http://host.docker.internal:3001}"
USERNAME="${1:-admin}"
PASSWORD="${2:-SocAdmin2026!}"

cat << 'EOF' > /tmp/setup_uptime_kuma.py
#!/usr/bin/env python3
from uptime_kuma_api import UptimeKumaApi, MonitorType
import sys
import os

UPTIME_KUMA_URL = os.environ.get("UPTIME_KUMA_URL", "http://host.docker.internal:3001")
USERNAME = os.environ.get("UK_USERNAME", "admin")
PASSWORD = os.environ.get("UK_PASSWORD", "SocAdmin2026!")

MONITORS = [
    {"name": "Elasticsearch", "type": MonitorType.HTTP, "url": "http://host.docker.internal:9200", "interval": 30},
    {"name": "Kibana", "type": MonitorType.HTTP, "url": "http://host.docker.internal:5601/api/status", "interval": 60},
    {"name": "IRIS DFIR", "type": MonitorType.HTTP, "url": "https://host.docker.internal:8443", "interval": 60, "ignoreTls": True},
    {"name": "Keycloak", "type": MonitorType.HTTP, "url": "http://host.docker.internal:8180/realms/master", "interval": 60},
    {"name": "Vaultwarden", "type": MonitorType.HTTP, "url": "https://host.docker.internal:8085", "interval": 60, "ignoreTls": True},
    {"name": "Nginx Proxy Manager", "type": MonitorType.HTTP, "url": "http://host.docker.internal:81", "interval": 60},
    {"name": "Grafana", "type": MonitorType.HTTP, "url": "http://host.docker.internal:3000/api/health", "interval": 60},
    {"name": "Prometheus", "type": MonitorType.HTTP, "url": "http://host.docker.internal:9090/-/healthy", "interval": 60},
    {"name": "Jaeger", "type": MonitorType.HTTP, "url": "http://host.docker.internal:16686", "interval": 120},
    {"name": "Portainer", "type": MonitorType.HTTP, "url": "http://host.docker.internal:9000", "interval": 60},
    {"name": "n8n", "type": MonitorType.HTTP, "url": "http://host.docker.internal:5678/healthz", "interval": 60},
    {"name": "Homepage", "type": MonitorType.HTTP, "url": "http://host.docker.internal:3003", "interval": 60},
    {"name": "Dozzle", "type": MonitorType.HTTP, "url": "http://host.docker.internal:8087", "interval": 120},
    {"name": "CyberChef", "type": MonitorType.HTTP, "url": "http://host.docker.internal:8088", "interval": 120},
    {"name": "Jupyter", "type": MonitorType.HTTP, "url": "http://host.docker.internal:8888", "interval": 120},
    {"name": "Excalidraw", "type": MonitorType.HTTP, "url": "http://host.docker.internal:3002", "interval": 120},
    {"name": "Draw.io", "type": MonitorType.HTTP, "url": "http://host.docker.internal:8089", "interval": 120},
    {"name": "Cowrie SSH", "type": MonitorType.PORT, "hostname": "host.docker.internal", "port": 2222, "interval": 120},
    {"name": "Cowrie Telnet", "type": MonitorType.PORT, "hostname": "host.docker.internal", "port": 2223, "interval": 120},
]

def main():
    print("=" * 60)
    print("SOC-in-a-Box - Uptime Kuma Configuration")
    print("=" * 60)
    
    api = UptimeKumaApi(UPTIME_KUMA_URL)
    
    # Try to setup or login
    try:
        print(f"\n🔧 Setting up account: {USERNAME}")
        api.setup(USERNAME, PASSWORD)
        print("✅ Account created")
    except Exception as e:
        print(f"ℹ️  Setup skipped: {e}")
        try:
            print(f"🔑 Logging in as {USERNAME}...")
            api.login(USERNAME, PASSWORD)
            print("✅ Login successful")
        except Exception as e2:
            print(f"❌ Login failed: {e2}")
            sys.exit(1)
    
    # Get existing monitors
    existing = {m["name"] for m in api.get_monitors()}
    
    # Add monitors
    print("\n📊 Adding monitors...")
    print("-" * 40)
    
    success = 0
    skipped = 0
    
    for m in MONITORS:
        if m["name"] in existing:
            print(f"  ⏭️  {m['name']} (already exists)")
            skipped += 1
            continue
        
        try:
            params = {
                "name": m["name"],
                "type": m["type"],
                "interval": m.get("interval", 60),
                "maxretries": 3,
            }
            
            if m["type"] == MonitorType.HTTP:
                params["url"] = m["url"]
                params["accepted_statuscodes"] = ["200-299", "301", "302", "401", "403"]
                if m.get("ignoreTls"):
                    params["ignoreTls"] = True
            elif m["type"] == MonitorType.PORT:
                params["hostname"] = m["hostname"]
                params["port"] = m["port"]
            
            api.add_monitor(**params)
            print(f"  ✅ {m['name']}")
            success += 1
        except Exception as e:
            print(f"  ❌ {m['name']}: {e}")
    
    print("-" * 40)
    print(f"Results: {success} added, {skipped} skipped")
    
    # Create status page
    print("\n📄 Creating status page...")
    try:
        api.save_status_page(
            slug="soc-status",
            title="SOC-in-a-Box Status",
            publicGroupList=[{"name": "Services", "weight": 1}]
        )
        print("✅ Status page created")
    except Exception as e:
        print(f"ℹ️  Status page: {e}")
    
    api.disconnect()
    
    print("\n" + "=" * 60)
    print("✅ Configuration complete!")
    print("=" * 60)
    print("\nDashboard: http://localhost:3001")
    print("Status Page: http://localhost:3001/status/soc-status\n")

if __name__ == "__main__":
    main()
EOF

echo "🚀 Running Uptime Kuma configuration via Docker..."
echo ""

docker run --rm \
    --add-host=host.docker.internal:host-gateway \
    -e UPTIME_KUMA_URL="$UPTIME_KUMA_URL" \
    -e UK_USERNAME="$USERNAME" \
    -e UK_PASSWORD="$PASSWORD" \
    -v /tmp/setup_uptime_kuma.py:/app/setup.py:ro \
    python:3.11-slim \
    bash -c "pip install -q uptime-kuma-api && python /app/setup.py"

rm -f /tmp/setup_uptime_kuma.py
