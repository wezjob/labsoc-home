# Uptime Kuma - Configuration des Monitors

> **URL**: http://localhost:3001
> **Configuration requise**: Créer un compte admin lors du premier accès

## Monitors à ajouter

### 🔧 Infrastructure Core

| Nom | Type | URL/Host | Port | Intervalle |
|-----|------|----------|------|------------|
| Elasticsearch | HTTP | http://localhost:9200 | - | 30s |
| Kibana | HTTP | http://localhost:5601/api/status | - | 60s |
| PostgreSQL (IRIS) | TCP | localhost | 5432 | 60s |
| PostgreSQL (Keycloak) | TCP | localhost | 5433 | 60s |

### 🛡️ Sécurité & Administration

| Nom | Type | URL/Host | Port | Intervalle |
|-----|------|----------|------|------------|
| IRIS DFIR | HTTP(S) | https://localhost:8443 | - | 60s |
| Keycloak | HTTP | http://localhost:8180/realms/master | - | 60s |
| Vaultwarden | HTTP | http://localhost:8085 | - | 60s |
| Nginx Proxy Manager | HTTP | http://localhost:81 | - | 60s |

### 📊 Observabilité

| Nom | Type | URL/Host | Port | Intervalle |
|-----|------|----------|------|------------|
| Grafana | HTTP | http://localhost:3000/api/health | - | 60s |
| Prometheus | HTTP | http://localhost:9090/-/healthy | - | 60s |
| Jaeger | HTTP | http://localhost:16686 | - | 120s |
| Loki | HTTP | http://localhost:3100/ready | - | 120s |

### 🔧 Outils & Utilitaires

| Nom | Type | URL/Host | Port | Intervalle |
|-----|------|----------|------|------------|
| Portainer | HTTP | http://localhost:9000/api/status | - | 60s |
| n8n | HTTP | http://localhost:5678/healthz | - | 60s |
| Homepage | HTTP | http://localhost:3003 | - | 60s |
| Dozzle | HTTP | http://localhost:8087 | - | 120s |

### 🎯 Analyse & Collaboration

| Nom | Type | URL/Host | Port | Intervalle |
|-----|------|----------|------|------------|
| CyberChef | HTTP | http://localhost:8088 | - | 120s |
| Jupyter | HTTP | http://localhost:8888 | - | 120s |
| Excalidraw | HTTP | http://localhost:3002 | - | 120s |
| Draw.io | HTTP | http://localhost:8089 | - | 120s |

### 🎭 Deception

| Nom | Type | URL/Host | Port | Intervalle |
|-----|------|----------|------|------------|
| Cowrie SSH | TCP | localhost | 2222 | 120s |
| Cowrie Telnet | TCP | localhost | 2223 | 120s |

---

## Configuration rapide

### Étape 1: Premier accès
1. Accéder à http://localhost:3001
2. Créer un compte administrateur
3. Sélectionner la langue (Français disponible)

### Étape 2: Ajouter les monitors
1. Cliquer sur **+ Ajouter un nouveau monitor**
2. Choisir le type (HTTP/TCP)
3. Configurer l'URL et l'intervalle
4. Activer les options:
   - ✅ Accepter les certificats auto-signés (pour IRIS)
   - ✅ Status codes acceptés: 200-299, 301, 302, 401, 403

### Étape 3: Créer une page de statut
1. Menu **Pages de statut**
2. **+ Nouvelle page de statut**
3. Slug: `soc-status`
4. Titre: `SOC-in-a-Box Status`
5. Ajouter tous les monitors

---

## Notifications recommandées

| Type | Usage |
|------|-------|
| Webhook | Intégration avec n8n |
| Telegram | Alertes temps réel |
| Email (SMTP) | Rapports quotidiens |
| Discord/Slack | Équipe SOC |

### Webhook n8n
- URL: `http://labsoc-n8n:5678/webhook/uptime-kuma`
- Méthode: POST
- Content-Type: application/json

---

## Groupes de monitors suggérés

```
📁 SOC-in-a-Box
├── 📁 Infrastructure
│   ├── Elasticsearch
│   ├── Kibana
│   └── PostgreSQL
├── 📁 Sécurité
│   ├── IRIS DFIR
│   ├── Keycloak
│   └── Vaultwarden
├── 📁 Observabilité
│   ├── Grafana
│   ├── Prometheus
│   └── Jaeger
├── 📁 Outils
│   ├── Portainer
│   ├── n8n
│   └── Homepage
└── 📁 Deception
    ├── Cowrie SSH
    └── Cowrie Telnet
```
