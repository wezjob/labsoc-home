#!/bin/bash
# ============================================
# SOC-PME Full Stack - Backup Script
# Sauvegarde tous les services critiques
# ============================================

set -e

# Configuration
BACKUP_DIR="/opt/soc-pme/backups"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Créer répertoire de backup
mkdir -p $BACKUP_DIR/$DATE

echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║       SOC-PME Backup - $DATE        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"

# ============================================
# 1. Backup PostgreSQL (Nextcloud + Mailu)
# ============================================
echo -e "\n${YELLOW}[1/6] Backup PostgreSQL databases...${NC}"
docker exec soc-pme-postgres pg_dumpall -U socpme | gzip > $BACKUP_DIR/$DATE/postgres_all.sql.gz
echo -e "${GREEN}✓ PostgreSQL backup complete${NC}"

# ============================================
# 2. Backup Elasticsearch
# ============================================
echo -e "\n${YELLOW}[2/6] Backup Elasticsearch indices...${NC}"
# Créer snapshot repository si pas existant
curl -s -X PUT "http://localhost:9200/_snapshot/backup" \
  -H "Content-Type: application/json" \
  -u elastic:${ELASTIC_PASSWORD:-SecureSocPme2024!} \
  -d '{
    "type": "fs",
    "settings": {
      "location": "/usr/share/elasticsearch/backup"
    }
  }' > /dev/null 2>&1 || true

# Créer snapshot
curl -s -X PUT "http://localhost:9200/_snapshot/backup/snapshot_$DATE?wait_for_completion=true" \
  -u elastic:${ELASTIC_PASSWORD:-SecureSocPme2024!} > /dev/null

echo -e "${GREEN}✓ Elasticsearch snapshot created${NC}"

# ============================================
# 3. Backup Nextcloud
# ============================================
echo -e "\n${YELLOW}[3/6] Backup Nextcloud data...${NC}"
# Activer mode maintenance
docker exec -u www-data soc-pme-nextcloud php occ maintenance:mode --on 2>/dev/null || true

# Backup data
tar -czf $BACKUP_DIR/$DATE/nextcloud_data.tar.gz \
  -C /var/lib/docker/volumes/labsoc-home_nextcloud-data/_data . 2>/dev/null

# Désactiver mode maintenance
docker exec -u www-data soc-pme-nextcloud php occ maintenance:mode --off 2>/dev/null || true

echo -e "${GREEN}✓ Nextcloud backup complete${NC}"

# ============================================
# 4. Backup Mailu
# ============================================
echo -e "\n${YELLOW}[4/6] Backup Mailu data...${NC}"
tar -czf $BACKUP_DIR/$DATE/mailu_mail.tar.gz \
  -C /var/lib/docker/volumes/labsoc-home_mailu-mail/_data . 2>/dev/null || true
tar -czf $BACKUP_DIR/$DATE/mailu_dkim.tar.gz \
  -C /var/lib/docker/volumes/labsoc-home_mailu-dkim/_data . 2>/dev/null || true

echo -e "${GREEN}✓ Mailu backup complete${NC}"

# ============================================
# 5. Backup n8n Workflows
# ============================================
echo -e "\n${YELLOW}[5/6] Backup n8n workflows...${NC}"
tar -czf $BACKUP_DIR/$DATE/n8n_data.tar.gz \
  -C /var/lib/docker/volumes/labsoc-home_n8n-data/_data . 2>/dev/null || true

echo -e "${GREEN}✓ n8n backup complete${NC}"

# ============================================
# 6. Backup Configuration Files
# ============================================
echo -e "\n${YELLOW}[6/6] Backup configuration files...${NC}"
tar -czf $BACKUP_DIR/$DATE/config.tar.gz \
  /opt/soc-pme/*.yml \
  /opt/soc-pme/.env* \
  /opt/soc-pme/suricata/config \
  /opt/soc-pme/suricata/rules \
  /opt/soc-pme/logstash/config \
  /opt/soc-pme/homepage/config \
  2>/dev/null

echo -e "${GREEN}✓ Configuration backup complete${NC}"

# ============================================
# Cleanup old backups
# ============================================
echo -e "\n${YELLOW}Cleaning up old backups (>${RETENTION_DAYS} days)...${NC}"
find $BACKUP_DIR -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \; 2>/dev/null || true

# ============================================
# Summary
# ============================================
BACKUP_SIZE=$(du -sh $BACKUP_DIR/$DATE | cut -f1)

echo -e "\n${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           Backup Complete!                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Location: ${YELLOW}$BACKUP_DIR/$DATE${NC}"
echo -e "Size: ${YELLOW}$BACKUP_SIZE${NC}"
echo ""
echo "Files created:"
ls -lh $BACKUP_DIR/$DATE/
