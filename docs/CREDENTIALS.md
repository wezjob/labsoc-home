# SOC-in-a-Box - Credentials Reference

> **IMPORTANT**: Store these credentials in Vaultwarden after initial setup.
> Access Vaultwarden at: http://localhost:8085

## 🔐 Core Infrastructure

### Elasticsearch
- **URL**: http://localhost:9200
- **Username**: `elastic`
- **Password**: `LabSoc2026!`

### Kibana
- **URL**: http://localhost:5601
- **Username**: `elastic`
- **Password**: `LabSoc2026!`

### PostgreSQL (IRIS)
- **Host**: labsoc-postgres:5432
- **Database**: `iris_db`
- **Username**: `labsoc`
- **Password**: `LabSocDB2026!`

### PostgreSQL (Keycloak)
- **Host**: labsoc-keycloak-db:5432
- **Database**: `keycloak`
- **Username**: `keycloak`
- **Password**: `KeycloakDB2026!`

---

## 🛡️ Security & Administration

### IRIS DFIR
- **URL**: https://localhost:8443
- **Username**: `admin`
- **Password**: `d++X$mX!J6';{ONU`

### Keycloak (SSO)
- **URL**: http://localhost:8180
- **Admin Console**: http://localhost:8180/admin
- **Username**: `admin`
- **Password**: `KeycloakAdmin2026!`
- **Realm**: `soc-in-a-box` (to be created)

### Vaultwarden
- **URL**: http://localhost:8085
- **Admin Token**: `VaultwardenAdmin2026!`
- **Note**: Create user account on first access

### Nginx Proxy Manager
- **URL**: http://localhost:81
- **Email**: `admin@example.com`
- **Password**: `changeme` (change on first login)

---

## 📊 Observability

### Grafana
- **URL**: http://localhost:3000
- **Username**: `admin`
- **Password**: `GrafanaAdmin2026!`

### Prometheus
- **URL**: http://localhost:9090
- **Authentication**: None (internal only)

### Jaeger
- **URL**: http://localhost:16686
- **Authentication**: None (internal only)

---

## 🔧 Tools & Utilities

### Portainer
- **URL**: http://localhost:9000
- **Note**: Create admin account on first access

### n8n (Automation)
- **URL**: http://localhost:5678
- **Note**: Create account on first access

### Uptime Kuma
- **URL**: http://localhost:3001
- **Note**: Create admin account on first access

### Homepage Dashboard
- **URL**: http://localhost:3003
- **Authentication**: None (local access)

### Dozzle (Logs)
- **URL**: http://localhost:8087
- **Authentication**: None (read-only)

---

## 🎯 Deception & Analysis

### Cowrie (Honeypot)
- **SSH Port**: 2222
- **Telnet Port**: 2223
- **Logs**: `modules/06-red-team/deception/cowrie-logs/`

### CyberChef
- **URL**: http://localhost:8088
- **Authentication**: None

### Jupyter (Threat Hunting)
- **URL**: http://localhost:8888
- **Token**: Check logs with `docker logs labsoc-jupyter`

---

## 🔒 Vaultwarden Organization Structure

After creating your Vaultwarden account, organize credentials in these folders:

1. **Infrastructure** - Elasticsearch, PostgreSQL
2. **Security** - Keycloak, IRIS, Vaultwarden Admin
3. **Monitoring** - Grafana, Prometheus
4. **Administration** - Portainer, NPM, n8n
5. **Tools** - Jupyter, CyberChef

---

## 📋 First-Time Setup Checklist

- [ ] Access Vaultwarden (http://localhost:8085) and create account
- [ ] Import all credentials into Vaultwarden
- [ ] Access Keycloak (http://localhost:8180) and login as admin
- [ ] Access Uptime Kuma (http://localhost:3001) and create admin account
- [ ] Add all services to Uptime Kuma monitoring
- [ ] Access Portainer (http://localhost:9000) and create admin account
- [ ] Change NPM default password (http://localhost:81)
