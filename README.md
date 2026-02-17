# 🛡️ LabSOC Home

**Security Operations Center (SOC) complet pour environnement home-lab**

[![ELK Stack](https://img.shields.io/badge/ELK-8.11.0-blue)](https://www.elastic.co/)
[![Suricata](https://img.shields.io/badge/Suricata-8.0.3-orange)](https://suricata.io/)
[![Zeek](https://img.shields.io/badge/Zeek-8.1.1-green)](https://zeek.org/)
[![n8n](https://img.shields.io/badge/n8n-SOAR-purple)](https://n8n.io/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED)](https://docker.com/)

---

## 📋 Description

LabSOC Home est une infrastructure SOC complète déployable sur macOS avec Docker Desktop. Elle intègre :

- **ELK Stack** - Collecte, analyse et visualisation des logs
- **Suricata** - IDS/IPS avec détection de signatures
- **Zeek** - Analyse réseau et métadonnées
- **n8n** - SOAR pour automatisation des réponses
- **Auditbeat** - HIDS pour surveillance de l'hôte

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         LabSOC Home                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                       │
│  │ Suricata │  │   Zeek   │  │Auditbeat │   (Native macOS)      │
│  │  (IDS)   │  │(Network) │  │  (HIDS)  │                       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘                       │
│       │             │             │                              │
│       └─────────────┼─────────────┘                              │
│                     ▼                                            │
│  ┌─────────────────────────────────┐                            │
│  │           Filebeat              │  (Docker)                   │
│  │        Log Collector            │                             │
│  └──────────────┬──────────────────┘                             │
│                 ▼                                                │
│  ┌─────────────────────────────────┐                            │
│  │           Logstash              │  (Docker)                   │
│  │      Pipeline Processing        │                             │
│  └──────────────┬──────────────────┘                             │
│                 ▼                                                │
│  ┌─────────────────────────────────┐                            │
│  │        Elasticsearch            │  (Docker)                   │
│  │     Search & Analytics          │                             │
│  └──────────────┬──────────────────┘                             │
│                 │                                                │
│      ┌──────────┴──────────┐                                    │
│      ▼                     ▼                                    │
│  ┌──────────┐       ┌──────────┐                                │
│  │  Kibana  │       │   n8n    │                                │
│  │  (SIEM)  │       │  (SOAR)  │                                │
│  └──────────┘       └──────────┘                                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## 🚀 Installation

### Prérequis

- macOS (Apple Silicon ou Intel)
- Docker Desktop installé et en cours d'exécution
- Homebrew installé
- 8GB RAM minimum recommandé

### Installation rapide

```bash
# 1. Cloner le repo
git clone https://github.com/wezjob/labsoc-home.git
cd labsoc-home

# 2. Démarrer les containers Docker
./scripts/start.sh

# 3. Installer Suricata et Zeek (natifs)
brew install suricata zeek

# 4. Installer Auditbeat (HIDS)
./scripts/install-auditbeat.sh
```

## 📦 Services

| Service | Port | Description |
|---------|------|-------------|
| Elasticsearch | 9200 | Moteur de recherche et stockage |
| Kibana | 5601 | Interface de visualisation |
| Logstash | 5044, 5514 | Traitement des logs |
| n8n | 5678 | Automatisation SOAR |
| Redis | 6379 | Cache |
| PostgreSQL | 5432 | Base de données n8n |

## 🔐 Identifiants par défaut

| Service | Utilisateur | Mot de passe |
|---------|-------------|--------------|
| Elasticsearch | elastic | LabSoc2026! |
| Kibana | elastic | LabSoc2026! |
| n8n | admin | LabSocN8N2026! |
| PostgreSQL | labsoc | LabSocDB2026! |

> ⚠️ **Important** : Changez ces mots de passe en production !

## 📂 Structure du projet

```
labsoc-home/
├── docker-compose.yml          # Configuration Docker
├── .env                        # Variables d'environnement
├── elasticsearch/
│   └── config/elasticsearch.yml
├── kibana/
│   ├── config/kibana.yml
│   └── dashboards/             # Dashboards exportés
├── logstash/
│   └── config/
│       ├── logstash.yml
│       ├── pipelines.yml
│       └── pipeline/           # Configurations pipeline
│           ├── main.conf       # Beats (Filebeat, Auditbeat)
│           ├── suricata.conf   # Logs Suricata
│           ├── zeek.conf       # Logs Zeek
│           └── syslog.conf     # Syslog
├── filebeat/
│   └── config/filebeat.yml
├── auditbeat/
│   └── config/auditbeat.yml    # HIDS configuration
├── suricata/
│   └── config/suricata.yaml
├── zeek/
│   └── config/
│       ├── local.zeek
│       ├── node.cfg
│       └── networks.cfg
├── rules/
│   └── local.rules             # Règles Suricata personnalisées
├── n8n/
│   ├── workflows/              # Workflows SOAR
│   └── data/                   # Données n8n
├── scripts/
│   ├── start.sh                # Démarrer tous les services
│   ├── stop.sh                 # Arrêter les services
│   ├── start-suricata.sh       # Démarrer Suricata (natif)
│   ├── start-zeek.sh           # Démarrer Zeek (natif)
│   ├── start-auditbeat.sh      # Démarrer Auditbeat (HIDS)
│   ├── generate-test-alerts.sh # Générer alertes de test
│   ├── setup-alerting.sh       # Configurer les alertes
│   └── backup.sh               # Sauvegarde
└── logs/                       # Logs locaux
```

## 🎯 Utilisation

### Démarrer l'infrastructure

```bash
# Démarrer Docker containers
./scripts/start.sh

# Vérifier les services
docker ps --filter "name=labsoc"
```

### Démarrer la capture réseau

```bash
# Suricata (IDS) - nécessite sudo
./scripts/start-suricata.sh en0

# Zeek (Network Analysis) - nécessite sudo
./scripts/start-zeek.sh en0

# Auditbeat (HIDS) - nécessite sudo
./scripts/start-auditbeat.sh
```

### Accéder aux interfaces

- **Kibana** : http://localhost:5601 (elastic/LabSoc2026!)
- **n8n** : http://localhost:5678 (admin/LabSocN8N2026!)
- **Elasticsearch** : http://localhost:9200

### Générer des alertes de test

```bash
./scripts/generate-test-alerts.sh
```

## 🔍 Intégration n8n ↔ ELK

### Configuration n8n

1. Ouvrir http://localhost:5678
2. Créer un credential HTTP Basic Auth :
   - Nom : `Elasticsearch`
   - User : `elastic`
   - Password : `LabSoc2026!`
3. Importer les workflows depuis `n8n/workflows/`

### Workflows disponibles

| Workflow | Description |
|----------|-------------|
| `alert-monitor-elk.json` | Poll Elasticsearch toutes les 5 min pour nouvelles alertes |
| `webhook-alert-receiver.json` | Reçoit des alertes via webhook |

### Architecture d'automatisation

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Suricata/   │────▶│ Elasticsearch│────▶│    n8n     │
│ Zeek/Audit  │     │   (index)   │     │  (polling) │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                    ┌──────────────────────────┼──────────────┐
                    │                          │              │
                    ▼                          ▼              ▼
             ┌──────────┐              ┌──────────┐    ┌──────────┐
             │ Escalate │              │   Log    │    │ Respond  │
             │ Incident │              │ Processed│    │  Action  │
             └──────────┘              └──────────┘    └──────────┘
```

## 📊 Dashboards Kibana

### Créer le Data View

1. Menu ☰ → Stack Management → Data Views
2. Create data view : `labsoc-*`
3. Time field : `@timestamp`

### Visualisations recommandées

- **Total Events** : Metric count
- **Events by Source** : Pie chart par `labsoc.source`
- **Events by Severity** : Bar chart par `event.severity`
- **Timeline** : Line chart avec `@timestamp`
- **Top Source IPs** : Table avec `source.ip`

## 🛠️ Règles de détection Suricata

Le fichier `rules/local.rules` contient 15 règles personnalisées :

| SID | Description |
|-----|-------------|
| 1000001 | SSH Brute Force |
| 1000002 | DNS Tunneling |
| 1000003 | Large File Exfiltration |
| 1000004-5 | Suspicious Ports (4444, 1337) |
| 1000006 | TOR Network |
| 1000007 | Crypto Mining |
| 1000008 | ICMP Tunnel |
| 1000009 | C2 Beaconing |
| 1000010 | Lateral Movement (SMB) |
| 1000011 | Ransomware Activity |
| 1000012-13 | Phishing Domains |
| 1000014 | PowerShell Download |
| 1000015 | SQL Injection |

## 🔒 Sécurité

### Authentification

- ✅ Elasticsearch xpack.security activé
- ✅ Authentification requise pour tous les services
- ✅ Mots de passe complexes par défaut

### Réseau

- ⚠️ HTTP uniquement (pas de TLS) - environnement de dev
- Services sur réseau Docker isolé
- Ports exposés uniquement sur localhost

### Recommandations production

1. Activer TLS/HTTPS
2. Changer tous les mots de passe par défaut
3. Configurer un reverse proxy (nginx/traefik)
4. Limiter les accès réseau

## 📝 Logs

Les logs sont stockés dans :

- **Suricata** : `/opt/homebrew/var/log/suricata/`
- **Zeek** : `/opt/homebrew/var/log/zeek/current/`
- **Auditbeat** : `/opt/homebrew/var/log/auditbeat/`

## 🐛 Dépannage

### Docker containers ne démarrent pas

```bash
# Vérifier les logs
docker compose logs -f

# Redémarrer
./scripts/stop.sh && ./scripts/start.sh
```

### Suricata/Zeek ne capturent pas

```bash
# Vérifier l'interface réseau
networksetup -listallhardwareports

# Utiliser la bonne interface
./scripts/start-suricata.sh en0  # WiFi
./scripts/start-suricata.sh en1  # Ethernet
```

### Elasticsearch health rouge

```bash
# Vérifier l'état
curl -u elastic:LabSoc2026! http://localhost:9200/_cluster/health?pretty

# Augmenter la mémoire si nécessaire
# Modifier ES_JAVA_OPTS dans docker-compose.yml
```

## 📜 Licence

MIT License - Voir [LICENSE](LICENSE)

## 👤 Auteur

- GitHub: [@wezjob](https://github.com/wezjob)

---

🛡️ **LabSOC Home** - Votre SOC personnel pour l'apprentissage et les tests de sécurité.
