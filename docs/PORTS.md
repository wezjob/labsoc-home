# 🔌 LabSOC Home - Port Reference

## Quick Reference

| Port Range | Module |
|------------|--------|
| 3000-3999 | Observability & Collaboration |
| 5000-5999 | SIEM & Automation |
| 8000-8999 | Web UIs |
| 9000-9999 | APIs & Admin |
| 10000+ | Special services |

## 📊 IDENTIFY - Assets, Risk, Governance

| Service | Port | Protocol | Description |
|---------|------|----------|-------------|
| MISP | 8443 | HTTPS | Threat Intelligence Platform |
| MISP | 8080 | HTTP | Redirect to HTTPS |
| IntelOWL | 8001 | HTTP | Threat Analysis API/UI |
| OpenCTI | 8002 | HTTP | Cyber Threat Intelligence |
| CISO Assistant | 8003 | HTTP | GRC Platform |

## 🛡️ PROTECT - Access Control, Security

| Service | Port | Protocol | Description |
|---------|------|----------|-------------|
| Portainer | 9443 | HTTPS | Docker Management |
| Portainer | 9000 | HTTP | Docker Management |
| Guacamole | 8005 | HTTP | Remote Desktop Gateway |
| Webmin | 10000 | HTTPS | System Administration |
| Uptime Kuma | 3001 | HTTP | Service Monitoring |
| Authentik | 9006 | HTTP | SSO Identity Provider |
| Authentik | 9444 | HTTPS | SSO Identity Provider |
| Greenbone GSA | 9392 | HTTPS | OpenVAS Web UI |
| OWASP ZAP | 8004 | HTTP | Web App Scanner UI |
| OWASP ZAP | 8090 | HTTP | ZAP API |
| Cowrie SSH | 2222 | TCP | SSH Honeypot |
| Cowrie Telnet | 2223 | TCP | Telnet Honeypot |
| Elasticpot | 9201 | HTTP | Fake Elasticsearch |

## 🔍 DETECT - Monitoring, Anomalies

| Service | Port | Protocol | Description |
|---------|------|----------|-------------|
| Elasticsearch | 9200 | HTTP | Search API |
| Elasticsearch | 9300 | TCP | Transport |
| Kibana | 5601 | HTTP | SIEM Dashboard |
| Logstash | 5044 | TCP | Beats Input |
| Logstash | 5045 | TCP | Syslog Input |
| Wazuh Dashboard | 5602 | HTTPS | XDR Dashboard |
| Wazuh Agent | 1514 | TCP/UDP | Agent Events |
| Wazuh Enrollment | 1515 | TCP | Agent Registration |
| Wazuh API | 55000 | HTTPS | Management API |
| Grafana | 3000 | HTTP | Dashboards |
| Prometheus | 9090 | HTTP | Metrics |
| AlertManager | 9093 | HTTP | Alert Management |
| Node Exporter | 9100 | HTTP | Host Metrics |
| cAdvisor | 8084 | HTTP | Container Metrics |
| Loki | 3100 | HTTP | Log Aggregation |
| Jaeger | 16686 | HTTP | Tracing UI |
| Jupyter Hunting | 8888 | HTTP | Threat Hunting Notebooks |

## 🚨 RESPOND - Analysis, Mitigation

| Service | Port | Protocol | Description |
|---------|------|----------|-------------|
| n8n | 5678 | HTTP | Workflow Automation |
| Shuffle | 3443 | HTTPS | SOAR Platform |
| Shuffle | 3080 | HTTP | SOAR Platform |
| IRIS DFIR | 443 | HTTPS | Incident Response (iris-web) |
| Velociraptor | 8889 | HTTPS | Endpoint IR GUI |
| Velociraptor | 8000 | gRPC | Frontend |
| CAPE | 8007 | HTTP | Malware Sandbox |
| Timesketch | 5000 | HTTP | Timeline Analysis |
| CyberChef | 8008 | HTTP | Data Analysis |
| Zammad | 8009 | HTTP | Helpdesk |

## 📚 RECOVER - Recovery, Documentation

| Service | Port | Protocol | Description |
|---------|------|----------|-------------|
| Wiki.js | 3002 | HTTP | Documentation |
| Nextcloud | 8081 | HTTP | File Sharing |
| Mattermost | 8065 | HTTP | Team Chat |
| Excalidraw | 8082 | HTTP | Whiteboard |
| Draw.io | 8086 | HTTP | Diagrams |

## ⚔️ RED TEAM - Adversary Simulation

| Service | Port | Protocol | Description |
|---------|------|----------|-------------|
| Caldera | 8088 | HTTP | MITRE Adversary Emulation |
| Caldera Agent | 7010-7012 | TCP | Agent Callbacks |
| Infection Monkey | 5100 | HTTP | Breach Simulation |
| Gophish Admin | 3333 | HTTP | Phishing Admin |
| Gophish Server | 8085 | HTTP | Phishing Landing |
| Mythic | 7443 | HTTPS | C2 Framework |
| Sliver | 31337 | TCP | C2 Multiplayer |
| Kali/Metasploit | 4444 | TCP | Default Listener |

## 🔒 Security Notes

1. **Production**: Use reverse proxy (Traefik/Nginx) with TLS
2. **Firewall**: Only expose necessary ports externally
3. **Red Team**: Isolate on separate network segment
4. **Honeypots**: Deploy on DMZ network
5. **Management**: Restrict access to admin ports (9000s, 10000)
