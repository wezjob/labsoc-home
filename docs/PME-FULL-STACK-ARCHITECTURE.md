# 🏢 SOC-PME Full Stack - Architecture Complète

## 📋 Executive Summary

**SOC-PME Full Stack** est une appliance tout-en-un pour PME incluant:
- **SOC** (Security Operations Center)
- **Nextcloud** (Cloud privé & collaboration)
- **Mailu** (Serveur de messagerie)
- **Suricata IDS/IPS** (Protection réseau)

### Spécifications Matérielles

| Composant | Minimum | Recommandé |
|-----------|---------|------------|
| CPU | Intel i7, 4 cores | Intel i7/Xeon, 6+ cores |
| RAM | **8 GB** | 16 GB |
| Stockage | 256 GB SSD | 512 GB SSD + 1TB HDD |
| Réseau | 2x NIC Gigabit | 2x NIC 2.5G |

---

## 🏗️ Architecture Réseau Complète

```
                              ┌─────────────────────────────────────────────────┐
                              │                 INTERNET (WAN)                  │
                              └────────────────────────┬────────────────────────┘
                                                       │
                                                       │ eth0 (WAN - IP Publique)
                              ┌────────────────────────▼────────────────────────┐
                              │              🛡️ SOC-PME FULL STACK              │
                              │  ════════════════════════════════════════════   │
                              │  Suricata IPS │ NFTables FW │ Traefik Proxy     │
                              │  (Inline)     │ (Stateful)  │ (SSL/TLS)         │
                              ├─────────────────────────────────────────────────┤
                              │                  DOCKER HOST                    │
                              │  ┌───────────────────────────────────────────┐  │
                              │  │ Elasticsearch │ Kibana │ n8n │ Logstash  │  │
                              │  │ Nextcloud │ Collabora │ PostgreSQL       │  │
                              │  │ Mailu (SMTP/IMAP) │ ClamAV │ Rspamd      │  │
                              │  └───────────────────────────────────────────┘  │
                              └────────────────────────┬────────────────────────┘
                                                       │ eth1 (TRUNK 802.1Q)
                                                       │
              ┌────────────────────────────────────────┼────────────────────────────────────────┐
              │                                        │                                        │
     ┌────────▼─────────┐                    ┌─────────▼─────────┐                   ┌──────────▼─────────┐
     │     VLAN 10      │                    │      VLAN 20      │                   │      VLAN 30       │
     │   🔒 SOC/ADMIN   │                    │   📧 SERVICES     │                   │   💼 LAN USERS     │
     │  172.16.10.0/24  │                    │  172.16.20.0/24   │                   │  172.16.30.0/24    │
     └────────┬─────────┘                    └─────────┬─────────┘                   └──────────┬─────────┘
              │                                        │                                        │
     ┌────────┴─────────┐                    ┌─────────┴─────────┐                   ┌──────────┴─────────┐
     │ Services SOC:    │                    │ Services PME:     │                   │ Utilisateurs:      │
     │ • Kibana SIEM    │                    │ • Nextcloud       │                   │ • Postes Windows   │
     │ • n8n SOAR       │                    │ • Collabora       │                   │ • Postes macOS     │
     │ • Homepage       │                    │ • Webmail         │                   │ • Smartphones      │
     │ • Traefik Admin  │                    │ • Mail (SMTP)     │                   │ • Imprimantes      │
     │ • SSH Admin      │                    │ • Mail (IMAP)     │                   │ • VoIP             │
     │ • Elasticsearch  │                    │ • DNS Interne     │                   │ • IoT              │
     └──────────────────┘                    └───────────────────┘                   └────────────────────┘
```

---

## 📊 Distribution des Services par VLAN

### VLAN 10 - SOC Management (172.16.10.0/24)
**Accès**: Administrateurs SOC uniquement

| Service | IP:Port | URL | Description |
|---------|---------|-----|-------------|
| Homepage | 172.16.10.1:3000 | http://portal.soc-pme.local | Portail central |
| Kibana SIEM | 172.16.10.1:5601 | http://siem.soc-pme.local | Dashboard sécurité |
| n8n SOAR | 172.16.10.1:5678 | http://soar.soc-pme.local | Automatisation |
| Elasticsearch | 172.16.10.1:9200 | - | API SIEM |
| Traefik Admin | 172.16.10.1:8081 | http://proxy.soc-pme.local | Config proxy |
| SSH | 172.16.10.1:22 | - | Administration |

### VLAN 20 - Services Collaboratifs (172.16.20.0/24)
**Accès**: Tous les utilisateurs authentifiés

| Service | IP:Port | URL | Description |
|---------|---------|-----|-------------|
| Nextcloud | 172.16.20.1:8080 | https://cloud.soc-pme.local | Cloud privé |
| Collabora | 172.16.20.1:9980 | https://office.soc-pme.local | Suite Office |
| Webmail | 172.16.20.1:8443 | https://mail.soc-pme.local | Roundcube |
| SMTP | 172.16.20.1:25/465/587 | mail.soc-pme.local | Envoi email |
| IMAP | 172.16.20.1:143/993 | mail.soc-pme.local | Réception email |
| POP3 | 172.16.20.1:110/995 | mail.soc-pme.local | Réception email |

### VLAN 30 - LAN Utilisateurs (172.16.30.0/24)
**Accès**: Utilisateurs finaux

| Service | IP | Description |
|---------|-----|-------------|
| Gateway | 172.16.30.1 | Routeur par défaut |
| DNS | 172.16.30.1 | Résolution DNS |
| DHCP | 172.16.30.100-254 | Attribution IP auto |

---

## 💾 Distribution Mémoire (8GB RAM)

```
┌───────────────────────────────────────────────────────────────────────────┐
│                           8 GB RAM TOTAL                                  │
├───────────────────────────────────────────────────────────────────────────┤
│ Composant                    │ RAM      │ Graphique                       │
├──────────────────────────────┼──────────┼─────────────────────────────────┤
│ OS Linux (Debian 12)         │  512 MB  │ ████                            │
│ Suricata IDS/IPS             │  512 MB  │ ████                            │
│ Elasticsearch SIEM           │ 1280 MB  │ ██████████                      │
│ Kibana                       │  640 MB  │ █████                           │
│ Logstash                     │  384 MB  │ ███                             │
│ Nextcloud + PHP-FPM          │  768 MB  │ ██████                          │
│ Collabora Online             │  512 MB  │ ████                            │
│ Mailu Stack (6 containers)   │ 1152 MB  │ █████████                       │
│ ClamAV Antivirus             │  512 MB  │ ████                            │
│ PostgreSQL                   │  256 MB  │ ██                              │
│ Redis                        │   96 MB  │ █                               │
│ n8n SOAR                     │  192 MB  │ ██                              │
│ Traefik + Homepage           │  128 MB  │ █                               │
│ Buffer système               │ 1076 MB  │ ████████                        │
└──────────────────────────────┴──────────┴─────────────────────────────────┘
                                TOTAL: ~8 GB
```

---

## 🔐 Matrice de Flux Réseau (Firewall Rules)

### Flux Autorisés

| Source | Destination | Ports | Protocole | Description |
|--------|-------------|-------|-----------|-------------|
| Internet | VLAN 20 | 25,465,587 | TCP | SMTP entrant |
| Internet | VLAN 20 | 80,443 | TCP | Web (Nextcloud, Mail) |
| VLAN 30 | VLAN 20 | 80,443,25,587,993 | TCP | Services collaboratifs |
| VLAN 30 | Internet | 80,443 | TCP | Web navigation |
| VLAN 30 | VLAN 20 | 53 | UDP | DNS |
| VLAN 10 | Tous | Tous | TCP/UDP | Administration |
| VLAN 20 | Internet | 25,465,587 | TCP | SMTP sortant |

### Flux Bloqués

| Source | Destination | Raison |
|--------|-------------|--------|
| VLAN 30 | VLAN 10 | Protection SOC |
| Internet | VLAN 10 | Protection SOC |
| Internet | VLAN 30 | Protection LAN |

---

## 🛡️ Conformité NIST CSF

| Fonction | Catégorie | Composant | Status |
|----------|-----------|-----------|--------|
| **IDENTIFY** | Asset Management | Filebeat, Nextcloud | ✅ |
| | Risk Assessment | Kibana Dashboards | ✅ |
| **PROTECT** | Access Control | NFTables, VLANs | ✅ |
| | Data Security | Suricata IPS, ClamAV | ✅ |
| | Information Protection | Nextcloud encryption | ✅ |
| **DETECT** | Anomalies | Suricata Rules | ✅ |
| | Security Monitoring | ELK SIEM | ✅ |
| | Detection Process | 10+ Use Cases | ✅ |
| **RESPOND** | Response Planning | n8n Playbooks | ✅ |
| | Incident Analysis | Kibana Investigation | ✅ |
| | Mitigation | Auto-block via n8n | ✅ |
| **RECOVER** | Recovery Planning | Backups | ⚠️ |
| | Communications | Email, Nextcloud | ✅ |

---

## 📁 Structure des Fichiers

```
/opt/soc-pme/
├── docker-compose-pme-full.yml     # Stack complète
├── .env.pme-full                   # Variables d'environnement
├── suricata/
│   ├── config/suricata.yaml
│   └── rules/
│       ├── local.rules
│       └── mail-nextcloud.rules   # Règles mail/cloud
├── logstash/
│   └── config/pipeline/
│       ├── suricata.conf
│       ├── syslog.conf
│       ├── mail.conf              # Logs Mailu
│       └── nextcloud.conf         # Logs Nextcloud
├── homepage/
│   └── config/
│       ├── services.yaml
│       ├── settings.yaml
│       ├── widgets.yaml
│       └── bookmarks.yaml
├── scripts/
│   ├── setup-network-pme.sh
│   ├── init-multi-db.sh
│   └── backup.sh
└── data/
    ├── elasticsearch/
    ├── nextcloud/
    ├── mailu/
    └── postgres/
```

---

## 🚀 Déploiement Rapide

```bash
# 1. Cloner
git clone https://github.com/VOTRE-REPO/labsoc-home.git /opt/soc-pme
cd /opt/soc-pme

# 2. Configurer
cp .env.pme-full .env
nano .env  # Modifier les mots de passe!

# 3. Réseau
chmod +x scripts/setup-network-pme.sh
sudo ./scripts/setup-network-pme.sh

# 4. Démarrer
docker compose -f docker-compose-pme-full.yml up -d

# 5. Vérifier
docker compose -f docker-compose-pme-full.yml ps
```

---

## 💰 Comparaison Coûts

| Solution | Coût Matériel | Coût Logiciel/an | Total 3 ans |
|----------|--------------|------------------|-------------|
| **SOC-PME Full Stack** | 600-1000 € | 0 € | **600-1000 €** |
| Fortinet FortiGate + FortiMail | 2000 € | 3000 €/an | 11000 € |
| Microsoft 365 E5 (10 users) | - | 4200 €/an | 12600 € |
| Sophos XGS + Central | 3000 € | 2500 €/an | 10500 € |

**Économie estimée: 10 000 - 12 000 € sur 3 ans**

---

*SOC-PME Full Stack v1.0 - 100% Open Source - NIST CSF Compliant*
