# 🚀 SOC-PME Appliance - Guide de Déploiement

## 📋 Prérequis

### Matériel Minimum
| Composant | Minimum | Recommandé |
|-----------|---------|------------|
| CPU | Intel i5/i7, 4 cores | Intel i7, 4+ cores |
| RAM | 4 GB | 8 GB |
| Stockage | 128 GB SSD | 256 GB SSD |
| Réseau | 2x NIC Gigabit | 2x NIC Gigabit |

### Système d'exploitation
- **Debian 12 (Bookworm)** - Recommandé
- Ubuntu Server 22.04 LTS

---

## 🔧 Installation Rapide (Plug & Play)

### Étape 1: Installation du Système

```bash
# Télécharger Debian 12 netinst
# https://www.debian.org/download

# Installation minimale:
# - Pas d'environnement de bureau
# - Serveur SSH uniquement
# - Définir hostname: soc-pme
```

### Étape 2: Configuration Post-Installation

```bash
# Connexion SSH
ssh root@<IP_SERVEUR>

# Mise à jour système
apt update && apt upgrade -y

# Installation des dépendances
apt install -y curl git vim htop iotop net-tools \
    ca-certificates gnupg lsb-release \
    apt-transport-https software-properties-common

# Installation Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker
usermod -aG docker $USER

# Installation Docker Compose
apt install -y docker-compose-plugin

# Vérification
docker --version
docker compose version
```

### Étape 3: Cloner SOC-in-a-Box

```bash
# Cloner le projet
cd /opt
git clone https://github.com/VOTRE-REPO/labsoc-home.git soc-pme
cd /opt/soc-pme

# Configurer les variables d'environnement
cp .env.example .env
nano .env
```

**Fichier `.env` à configurer:**
```bash
# SOC-PME Configuration
ELASTIC_PASSWORD=VotreMotDePasseSecurise2024!
KIBANA_PASSWORD=VotreMotDePasseSecurise2024!
N8N_USER=soc-admin
N8N_PASSWORD=VotreMotDePasseSecurise2024!

# Réseau
WAN_INTERFACE=eth0
LAN_INTERFACE=eth1
```

### Étape 4: Configuration Réseau VLANs

```bash
# Rendre le script exécutable
chmod +x scripts/setup-network-pme.sh

# Éditer les paramètres si nécessaire
nano scripts/setup-network-pme.sh

# Exécuter la configuration réseau
sudo ./scripts/setup-network-pme.sh

# Redémarrer pour appliquer
sudo reboot
```

### Étape 5: Démarrage du SOC

```bash
cd /opt/soc-pme

# Créer les répertoires de données
sudo mkdir -p /opt/soc-pme/data/{elasticsearch,n8n}
sudo mkdir -p /opt/soc-pme/logs/{suricata,zeek,syslog}
sudo chown -R 1000:1000 /opt/soc-pme/data

# Démarrer les services SOC
docker compose -f docker-compose-pme.yml up -d

# Vérifier le statut
docker compose -f docker-compose-pme.yml ps
```

---

## 🔌 Configuration du Switch Client

### Cisco IOS
```
! Configuration du port trunk vers SOC-PME
interface GigabitEthernet0/1
  description "SOC-PME Appliance Trunk"
  switchport trunk encapsulation dot1q
  switchport mode trunk
  switchport trunk allowed vlan 10,20,30
  switchport trunk native vlan 1
  spanning-tree portfast trunk
  no shutdown

! VLAN 10 - SOC Management
vlan 10
  name SOC-Management

! VLAN 20 - Security/DMZ
vlan 20
  name Security-DMZ

! VLAN 30 - LAN Users
vlan 30
  name LAN-Users

! Port d'accès pour poste SOC
interface GigabitEthernet0/24
  description "Poste Analyste SOC"
  switchport mode access
  switchport access vlan 10
  spanning-tree portfast
  no shutdown
```

### HP ProCurve
```
vlan 10
  name "SOC-Management"
  untagged 24
  tagged 1
  ip address 172.16.10.254 255.255.255.0
  exit

vlan 20
  name "Security-DMZ"
  tagged 1
  exit

vlan 30
  name "LAN-Users"
  tagged 1
  exit

interface 1
  name "SOC-PME-Trunk"
  exit
```

---

## 🖥️ Accès aux Services

### Depuis un poste sur VLAN 10 (SOC)

| Service | URL | Identifiants |
|---------|-----|--------------|
| **Portail SOC** | http://172.16.10.1 | - |
| **Kibana SIEM** | http://172.16.10.1:5601 | elastic / [mot de passe .env] |
| **n8n SOAR** | http://172.16.10.1:5678 | soc-admin / [mot de passe .env] |
| **SSH Admin** | ssh root@172.16.10.1 | root / [mot de passe système] |

### Configuration DNS Locale
Ajouter dans `/etc/hosts` du poste SOC:
```
172.16.10.1  soc-pme.local
172.16.10.1  kibana.soc-pme.local
172.16.10.1  soar.soc-pme.local
172.16.10.1  portal.soc-pme.local
```

---

## 📊 Post-Installation

### 1. Importer les Dashboards Kibana

```bash
cd /opt/soc-pme

# Attendre qu'Elasticsearch soit prêt
until curl -s -u elastic:$ELASTIC_PASSWORD http://localhost:9200/_cluster/health | grep -q 'green\|yellow'; do
  echo "Waiting for Elasticsearch..."
  sleep 10
done

# Importer les dashboards
./scripts/import-dashboards.sh
```

### 2. Configurer les Règles Suricata

```bash
# Mettre à jour les règles
docker exec soc-pme-suricata suricata-update

# Recharger Suricata
docker exec soc-pme-suricata kill -USR2 $(pgrep suricata)
```

### 3. Configurer les Alertes n8n

1. Accéder à http://172.16.10.1:5678
2. Importer les workflows depuis `./n8n/workflows/`
3. Configurer les webhooks Elasticsearch

### 4. Tester la Détection

```bash
# Générer du trafic de test
curl http://testmynids.org/uid/index.html

# Vérifier les alertes dans Kibana
# Discover > Index: soc-pme-suricata-*
```

---

## 🔒 Sécurisation

### Changer les mots de passe par défaut

```bash
# Elasticsearch
docker exec -it soc-pme-elasticsearch \
  bin/elasticsearch-reset-password -u elastic -i

# Kibana system user
docker exec -it soc-pme-elasticsearch \
  bin/elasticsearch-reset-password -u kibana_system -i
```

### Activer HTTPS (Optionnel)

```bash
# Générer certificats Let's Encrypt
apt install certbot
certbot certonly --standalone -d soc-pme.votredomaine.com

# Configurer Nginx reverse proxy
apt install nginx
# Voir nginx-ssl.conf dans configs/
```

### Backup Automatique

```bash
# Ajouter au crontab
crontab -e

# Backup quotidien à 2h du matin
0 2 * * * /opt/soc-pme/scripts/backup.sh >> /var/log/soc-backup.log 2>&1
```

---

## 📈 Monitoring des Ressources

### Vérifier l'utilisation mémoire

```bash
# Vue globale
docker stats --no-stream

# Détail par conteneur
docker stats soc-pme-elasticsearch soc-pme-kibana soc-pme-suricata
```

### Alertes de ressources (n8n)

Configurer des workflows n8n pour alerter si:
- RAM > 90%
- Disque > 80%
- CPU > 95% pendant 5 min

---

## 🛠️ Dépannage

### Elasticsearch ne démarre pas

```bash
# Vérifier les logs
docker logs soc-pme-elasticsearch

# Problème de mémoire virtuelle
sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
```

### Suricata ne capture pas

```bash
# Vérifier l'interface
docker exec soc-pme-suricata suricata --list-netmap-if

# Mode promiscuous
ip link set eth1 promisc on
```

### VLANs ne fonctionnent pas

```bash
# Vérifier le module
lsmod | grep 8021q

# Vérifier les interfaces
ip -d link show eth1.10
ip -d link show eth1.20
ip -d link show eth1.30
```

---

## 📞 Support

- Documentation: `/opt/soc-pme/docs/`
- Logs: `/opt/soc-pme/logs/`
- GitHub Issues: [Lien vers votre repo]

---

*SOC-PME Appliance v1.0 - Basé sur SOC-in-a-Box*
*100% Open Source - NIST CSF Compliant*
