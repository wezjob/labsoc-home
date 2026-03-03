# 🏢 SOC-PME Appliance - Architecture & Design

## 📋 Executive Summary

**SOC-PME** est une appliance de sécurité "plug and play" conçue pour les PME, basée sur SOC-in-a-Box, optimisée pour fonctionner sur un serveur compact avec ressources limitées.

### Spécifications Matérielles Cibles
| Composant | Spécification | Optimisation |
|-----------|--------------|--------------|
| CPU | Intel i7, 4 cores | Suffisant pour IDS/IPS + SIEM |
| RAM | 4 GB | ⚠️ Critique - Stack légère requise |
| Stockage | 128 GB SSD | Rotation des logs ~30 jours |
| Réseau | 2x NIC minimum | WAN + LAN (trunk VLANs) |

---

## 🏗️ Architecture Réseau NIST CSF

```
                                    ┌─────────────────────────────────────────┐
                                    │            INTERNET (WAN)               │
                                    └────────────────┬────────────────────────┘
                                                     │
                                                     │ eth0 (WAN)
                                    ┌────────────────▼────────────────────────┐
                                    │        🛡️ SOC-PME APPLIANCE            │
                                    │    ══════════════════════════════       │
                                    │    OPNsense/Suricata Firewall+IPS       │
                                    │    (Protection périmétrique NIST)       │
                                    └────────────────┬────────────────────────┘
                                                     │ eth1 (TRUNK 802.1Q)
                                                     │
                    ┌────────────────────────────────┼────────────────────────────────┐
                    │                                │                                │
           ┌────────▼────────┐              ┌────────▼────────┐              ┌────────▼────────┐
           │   VLAN 10       │              │   VLAN 20       │              │   VLAN 30       │
           │   🔒 SOC        │              │   🛡️ SECURITE  │              │   💼 LAN        │
           │   (Management)  │              │   (DMZ/Serveurs)│              │   (Utilisateurs)│
           └─────────────────┘              └─────────────────┘              └─────────────────┘
                    │                                │                                │
           ┌────────┴────────┐              ┌────────┴────────┐              ┌────────┴────────┐
           │ • Kibana SIEM   │              │ • Serveurs Web  │              │ • Postes de     │
           │ • n8n SOAR      │              │ • Applications  │              │   travail       │
           │ • Admin Console │              │ • Messagerie    │              │ • Imprimantes   │
           │ • Logs mgmt     │              │ • DNS interne   │              │ • VoIP          │
           └─────────────────┘              └─────────────────┘              └─────────────────┘
```

---

## 🔐 Segmentation VLAN (NIST CSF - PROTECT)

### VLAN 10 - SOC Management (172.16.10.0/24)
| Service | IP | Port | Description |
|---------|-----|------|-------------|
| Gateway | 172.16.10.1 | - | Interface SOC-PME |
| Kibana SIEM | 172.16.10.10 | 5601 | Dashboard sécurité |
| n8n SOAR | 172.16.10.10 | 5678 | Automatisation |
| Elasticsearch | 172.16.10.10 | 9200 | Base de données logs |
| Admin SSH | 172.16.10.10 | 22 | Administration |

**Accès**: Uniquement depuis les postes SOC autorisés

### VLAN 20 - Sécurité/DMZ (172.16.20.0/24)
| Service | IP | Port | Description |
|---------|-----|------|-------------|
| Gateway | 172.16.20.1 | - | Interface SOC-PME |
| Serveurs internes | 172.16.20.10-50 | divers | Zone protégée |
| DNS interne | 172.16.20.53 | 53 | Résolution DNS |

**Accès**: Filtré depuis LAN, accessible depuis Internet via reverse proxy

### VLAN 30 - LAN Utilisateurs (172.16.30.0/24)
| Service | IP | Port | Description |
|---------|-----|------|-------------|
| Gateway | 172.16.30.1 | - | Interface SOC-PME |
| DHCP Range | 172.16.30.100-254 | - | Postes utilisateurs |
| Imprimantes | 172.16.30.10-20 | 9100 | Imprimantes réseau |

**Accès**: Internet via firewall, accès limité aux autres VLANs

---

## 🧱 Stack Logicielle Optimisée (4GB RAM)

### Distribution des Ressources Mémoire

```
┌─────────────────────────────────────────────────────────────┐
│                    4 GB RAM TOTAL                           │
├─────────────────────────────────────────────────────────────┤
│ OS Linux (Debian 12)           │ 512 MB      │ ████        │
│ OPNsense/Suricata IPS          │ 768 MB      │ ██████      │
│ Elasticsearch (SIEM)           │ 1024 MB     │ ████████    │
│ Logstash                       │ 384 MB      │ ███         │
│ Kibana                         │ 512 MB      │ ████        │
│ Filebeat + n8n                 │ 256 MB      │ ██          │
│ Buffer système                 │ 544 MB      │ ████        │
└─────────────────────────────────────────────────────────────┘
```

### Composants Sélectionnés

| Composant | Solution | RAM | Rôle NIST |
|-----------|----------|-----|-----------|
| **Firewall** | OPNsense (VM) ou NFTables | 768 MB | PROTECT |
| **IDS/IPS** | Suricata (inline) | inclus | DETECT |
| **SIEM** | Elasticsearch Single-Node | 1 GB | DETECT |
| **Visualisation** | Kibana | 512 MB | IDENTIFY |
| **Pipeline** | Logstash Light | 384 MB | DETECT |
| **SOAR** | n8n | 128 MB | RESPOND |
| **Collecte** | Filebeat | 64 MB | DETECT |

---

## 🔥 Options Firewall Open Source

### Option A: OPNsense (Recommandé pour appliance dédiée)
```
┌─────────────────────────────────────────────────────────────┐
│                    SOC-PME APPLIANCE                        │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              OPNsense (Bare Metal)                    │  │
│  │  • Firewall stateful                                  │  │
│  │  • Suricata IPS intégré                               │  │
│  │  • VPN (OpenVPN, WireGuard)                           │  │
│  │  • HAProxy (reverse proxy)                            │  │
│  │  • VLAN tagging 802.1Q                                │  │
│  │  • Zenarmor (optionnel - layer 7)                     │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Docker (bhyve VM ou jail)                │  │
│  │  • Elasticsearch SIEM                                 │  │
│  │  • Kibana Dashboard                                   │  │
│  │  • n8n SOAR                                           │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

**Avantages**: OPNsense gère nativement VLANs, IPS intégré, interface web
**Inconvénients**: Nécessite VM pour Docker

### Option B: Linux + Docker (Tout-en-un)
```
┌─────────────────────────────────────────────────────────────┐
│           Debian 12 / Ubuntu Server 22.04 LTS               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                   Docker Containers                    │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐  │  │
│  │  │ Suricata    │ │ Elasticsearch│ │ Kibana          │  │  │
│  │  │ IPS/IDS     │ │ SIEM         │ │ Dashboard       │  │  │
│  │  │ (host net)  │ │              │ │                 │  │  │
│  │  └─────────────┘ └─────────────┘ └─────────────────┘  │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐  │  │
│  │  │ NFTables    │ │ n8n SOAR    │ │ Filebeat        │  │  │
│  │  │ Firewall    │ │             │ │ Log collector   │  │  │
│  │  │ (nftables)  │ │             │ │                 │  │  │
│  │  └─────────────┘ └─────────────┘ └─────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

**Avantages**: Simplicité, tout Docker, ressources optimisées
**Inconvénients**: Configuration firewall manuelle (nftables)

### Option C: Hybrid - pfSense/OPNsense + Docker Backend (Recommandé PME)
```
┌─────────────────────────────────────────────────────────────┐
│                   SOC-PME APPLIANCE                         │
│                                                             │
│  NIC1 (WAN) ──► ┌────────────────────────────────────────┐  │
│                 │           Proxmox VE (Hyperviseur)     │  │
│                 │  ┌──────────────┐  ┌─────────────────┐ │  │
│                 │  │   OPNsense   │  │  Debian + Docker│ │  │
│                 │  │   Firewall   │──│  SOC Stack      │ │  │
│                 │  │   + IPS      │  │  (SIEM, SOAR)   │ │  │
│                 │  │   (1GB RAM)  │  │  (2GB RAM)      │ │  │
│                 │  └──────────────┘  └─────────────────┘ │  │
│  NIC2 (LAN) ◄── └────────────────────────────────────────┘  │
│  (TRUNK 802.1Q)                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Matrice de Conformité NIST CSF

| Fonction NIST | Catégorie | Solution SOC-PME | Statut |
|--------------|-----------|------------------|--------|
| **IDENTIFY** | Asset Management | Filebeat + Zeek | ✅ |
| | Risk Assessment | Kibana Dashboards | ✅ |
| **PROTECT** | Access Control | OPNsense + VLANs | ✅ |
| | Data Security | Suricata IPS | ✅ |
| | Network Protection | NFTables/OPNsense | ✅ |
| **DETECT** | Anomalies | Suricata Rules | ✅ |
| | Security Monitoring | Elasticsearch SIEM | ✅ |
| | Detection Process | 10 Use Cases | ✅ |
| **RESPOND** | Response Planning | n8n Playbooks | ✅ |
| | Incident Analysis | Kibana + IRIS | ✅ |
| | Mitigation | OPNsense Block | ✅ |
| **RECOVER** | Recovery Planning | Backup Scripts | ⚠️ |
| | Improvements | Post-Incident | ⚠️ |

---

## 🚀 Déploiement Plug-and-Play

### Phase 1: Configuration Initiale (USB Boot)
1. Booter sur clé USB SOC-PME
2. Configuration réseau automatique (DHCP sur WAN)
3. Configuration VLANs via interface web
4. Import des règles de détection

### Phase 2: Intégration Réseau Client
```bash
# Switch Cisco/HP - Exemple configuration trunk
interface GigabitEthernet0/1
  description "SOC-PME TRUNK"
  switchport mode trunk
  switchport trunk allowed vlan 10,20,30
  switchport trunk native vlan 1
```

### Phase 3: Activation des Services
- [ ] Activer Suricata IPS mode inline
- [ ] Configurer DHCP pour VLAN 30
- [ ] Importer règles Suricata
- [ ] Connecter Filebeat à Elasticsearch

---

## 📈 Métriques de Performance Estimées

| Métrique | Valeur Cible | Note |
|----------|--------------|------|
| Débit WAN | 100-500 Mbps | Avec IPS actif |
| Logs/sec | ~500 EPS | Elasticsearch |
| Rétention logs | 30 jours | 128 GB SSD |
| Alertes/jour | ~100.000 | Sans tuning |
| Temps démarrage | < 5 min | Cold boot |

---

## 💰 Coût de la Solution

| Élément | Coût |
|---------|------|
| Matériel (mini-PC i7) | 400-600 € |
| Logiciels | 0 € (100% Open Source) |
| Configuration initiale | Main d'œuvre |
| Support annuel | Selon contrat MSP |

**ROI**: Solution comparable à des appliances commerciales à 5000-15000 €

---

## 🔗 Liens Utiles

- [OPNsense Documentation](https://docs.opnsense.org/)
- [Suricata User Guide](https://suricata.readthedocs.io/)
- [Elastic SIEM](https://www.elastic.co/security)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

---

*Document créé pour SOC-in-a-Box PME Appliance v1.0*
