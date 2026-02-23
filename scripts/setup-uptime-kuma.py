#!/usr/bin/env python3
"""
SOC-in-a-Box - Uptime Kuma Auto-Configuration
Configures all monitors automatically via API
"""

import requests
import json
import sys
import time

UPTIME_KUMA_URL = "http://localhost:3001"

# Services to monitor
MONITORS = [
    # Core Infrastructure
    {"name": "Elasticsearch", "type": "http", "url": "http://host.docker.internal:9200", "interval": 30},
    {"name": "Kibana", "type": "http", "url": "http://host.docker.internal:5601/api/status", "interval": 60},
    
    # Security & Administration
    {"name": "IRIS DFIR", "type": "http", "url": "https://host.docker.internal:8443", "interval": 60, "ignoreTls": True},
    {"name": "Keycloak", "type": "http", "url": "http://host.docker.internal:8180/realms/master", "interval": 60},
    {"name": "Vaultwarden", "type": "http", "url": "https://host.docker.internal:8085", "interval": 60, "ignoreTls": True},
    {"name": "Nginx Proxy Manager", "type": "http", "url": "http://host.docker.internal:81", "interval": 60},
    
    # Observability
    {"name": "Grafana", "type": "http", "url": "http://host.docker.internal:3000/api/health", "interval": 60},
    {"name": "Prometheus", "type": "http", "url": "http://host.docker.internal:9090/-/healthy", "interval": 60},
    {"name": "Jaeger", "type": "http", "url": "http://host.docker.internal:16686", "interval": 120},
    
    # Tools & Utilities
    {"name": "Portainer", "type": "http", "url": "http://host.docker.internal:9000", "interval": 60},
    {"name": "n8n", "type": "http", "url": "http://host.docker.internal:5678/healthz", "interval": 60},
    {"name": "Homepage", "type": "http", "url": "http://host.docker.internal:3003", "interval": 60},
    {"name": "Dozzle", "type": "http", "url": "http://host.docker.internal:8087", "interval": 120},
    
    # Analysis Tools
    {"name": "CyberChef", "type": "http", "url": "http://host.docker.internal:8088", "interval": 120},
    {"name": "Jupyter", "type": "http", "url": "http://host.docker.internal:8888", "interval": 120},
    {"name": "Excalidraw", "type": "http", "url": "http://host.docker.internal:3002", "interval": 120},
    {"name": "Draw.io", "type": "http", "url": "http://host.docker.internal:8089", "interval": 120},
    
    # Deception - TCP Monitors
    {"name": "Cowrie SSH", "type": "port", "hostname": "host.docker.internal", "port": 2222, "interval": 120},
    {"name": "Cowrie Telnet", "type": "port", "hostname": "host.docker.internal", "port": 2223, "interval": 120},
]


def setup_account(username, password):
    """Setup initial account if not exists"""
    print(f"🔧 Setting up Uptime Kuma account...")
    
    try:
        response = requests.post(
            f"{UPTIME_KUMA_URL}/api/setup",
            json={"username": username, "password": password},
            timeout=10
        )
        if response.status_code == 200:
            print("✅ Account created successfully")
            return True
        else:
            print(f"ℹ️  Setup response: {response.text}")
            return False
    except Exception as e:
        print(f"⚠️  Setup endpoint not available (account may already exist): {e}")
        return False


def login(username, password):
    """Login and get session"""
    print(f"🔑 Logging in as {username}...")
    
    session = requests.Session()
    
    try:
        response = session.post(
            f"{UPTIME_KUMA_URL}/api/login",
            json={"username": username, "password": password},
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get("ok"):
                print("✅ Login successful")
                return session, data.get("token")
            else:
                print(f"❌ Login failed: {data.get('msg')}")
                return None, None
        else:
            print(f"❌ Login failed with status {response.status_code}")
            return None, None
    except Exception as e:
        print(f"❌ Login error: {e}")
        return None, None


def add_monitor(session, token, monitor):
    """Add a single monitor"""
    
    headers = {"Authorization": f"Bearer {token}"} if token else {}
    
    payload = {
        "name": monitor["name"],
        "type": monitor["type"],
        "interval": monitor.get("interval", 60),
        "retryInterval": 60,
        "maxretries": 3,
        "active": True,
        "accepted_statuscodes": ["200-299", "301", "302", "401", "403"]
    }
    
    if monitor["type"] == "http":
        payload["url"] = monitor["url"]
        payload["method"] = "GET"
        if monitor.get("ignoreTls"):
            payload["ignoreTls"] = True
    elif monitor["type"] == "port":
        payload["hostname"] = monitor["hostname"]
        payload["port"] = monitor["port"]
    
    try:
        response = session.post(
            f"{UPTIME_KUMA_URL}/api/add-monitor",
            json=payload,
            headers=headers,
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get("ok"):
                print(f"  ✅ {monitor['name']}")
                return True
            else:
                print(f"  ⚠️  {monitor['name']}: {data.get('msg', 'Unknown error')}")
                return False
        else:
            print(f"  ❌ {monitor['name']}: HTTP {response.status_code}")
            return False
    except Exception as e:
        print(f"  ❌ {monitor['name']}: {e}")
        return False


def create_status_page(session, token):
    """Create a public status page"""
    
    headers = {"Authorization": f"Bearer {token}"} if token else {}
    
    try:
        response = session.post(
            f"{UPTIME_KUMA_URL}/api/add-status-page",
            json={
                "slug": "soc-status",
                "title": "SOC-in-a-Box Status"
            },
            headers=headers,
            timeout=10
        )
        
        if response.status_code == 200:
            print("✅ Status page created: http://localhost:3001/status/soc-status")
        else:
            print("ℹ️  Status page may already exist")
    except Exception as e:
        print(f"ℹ️  Could not create status page: {e}")


def main():
    print("=" * 60)
    print("SOC-in-a-Box - Uptime Kuma Configuration")
    print("=" * 60)
    print()
    
    # Default credentials
    username = "admin"
    password = "SocAdmin2026!"
    
    if len(sys.argv) > 2:
        username = sys.argv[1]
        password = sys.argv[2]
    
    # Try to setup account first
    setup_account(username, password)
    
    # Login
    session, token = login(username, password)
    
    if not session:
        print()
        print("❌ Could not login to Uptime Kuma")
        print()
        print("Please create an account manually first:")
        print("  1. Go to http://localhost:3001")
        print("  2. Create admin account")
        print("  3. Run this script again with: python3 setup-uptime-kuma.py <username> <password>")
        sys.exit(1)
    
    # Add monitors
    print()
    print("📊 Adding monitors...")
    print("-" * 40)
    
    success = 0
    failed = 0
    
    for monitor in MONITORS:
        if add_monitor(session, token, monitor):
            success += 1
        else:
            failed += 1
        time.sleep(0.5)  # Rate limiting
    
    print("-" * 40)
    print(f"Results: {success} added, {failed} failed/skipped")
    
    # Create status page
    print()
    create_status_page(session, token)
    
    print()
    print("=" * 60)
    print("✅ Configuration complete!")
    print("=" * 60)
    print()
    print(f"Dashboard: {UPTIME_KUMA_URL}")
    print(f"Status Page: {UPTIME_KUMA_URL}/status/soc-status")
    print()


if __name__ == "__main__":
    main()
