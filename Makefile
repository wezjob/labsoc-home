# ============================================================
# LabSOC Home - Makefile
# Orchestration des modules selon le framework NIST
# ============================================================

.PHONY: help network all stop clean status
.DEFAULT_GOAL := help

# ============================================================
# VARIABLES
# ============================================================
COMPOSE = docker compose
MODULES_DIR = modules

# Colors
GREEN  = \033[0;32m
YELLOW = \033[0;33m
RED    = \033[0;31m
BLUE   = \033[0;34m
NC     = \033[0m

# ============================================================
# HELP
# ============================================================
help: ## Show this help
	@echo ""
	@echo "$(BLUE)╔═══════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║          🛡️  LabSOC Home - SOC Modulaire NIST                 ║$(NC)"
	@echo "$(BLUE)╚═══════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)Usage:$(NC) make [target]"
	@echo ""
	@echo "$(YELLOW)── Infrastructure ──$(NC)"
	@grep -E '^(network|all|stop|clean|status):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)── IDENTIFY (Assets, Risk, Governance) ──$(NC)"
	@grep -E '^(identify|threat-intel|compliance|asset):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)── PROTECT (Access Control, Security) ──$(NC)"
	@grep -E '^(protect|admin|vuln-audit|deception):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)── DETECT (Monitoring, Anomalies) ──$(NC)"
	@grep -E '^(detect|siem|observability|hunting):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)── RESPOND (Analysis, Mitigation) ──$(NC)"
	@grep -E '^(respond|automation|forensics|ticketing):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)── RECOVER (Recovery, Improvements) ──$(NC)"
	@grep -E '^(recover|collaboration|backup):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)── RED TEAM (Adversary Simulation) ──$(NC)"
	@grep -E '^(redteam|offensive):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

# ============================================================
# INFRASTRUCTURE
# ============================================================
network: ## Create Docker network
	@echo "$(BLUE)Creating labsoc-network...$(NC)"
	@docker network create labsoc-network 2>/dev/null || echo "Network already exists"

all: network siem observability automation ## Start core modules (SIEM + Observability + Automation)
	@echo "$(GREEN)✓ Core modules started$(NC)"

stop: ## Stop all modules
	@echo "$(RED)Stopping all modules...$(NC)"
	@for dir in $(MODULES_DIR)/*/*; do \
		if [ -f "$$dir/docker-compose.yml" ]; then \
			echo "Stopping $$dir..."; \
			$(COMPOSE) -f "$$dir/docker-compose.yml" down 2>/dev/null || true; \
		fi \
	done
	@echo "$(GREEN)✓ All modules stopped$(NC)"

clean: stop ## Stop all and remove volumes
	@echo "$(RED)Removing all volumes...$(NC)"
	@for dir in $(MODULES_DIR)/*/*; do \
		if [ -f "$$dir/docker-compose.yml" ]; then \
			$(COMPOSE) -f "$$dir/docker-compose.yml" down -v 2>/dev/null || true; \
		fi \
	done
	@docker volume prune -f
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

status: ## Show status of all modules
	@echo "$(BLUE)╔═══════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║                    Module Status                              ║$(NC)"
	@echo "$(BLUE)╚═══════════════════════════════════════════════════════════════╝$(NC)"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep labsoc || echo "No LabSOC containers running"

# ============================================================
# IDENTIFY - Assets, Risk Assessment, Governance
# ============================================================
identify: network threat-intel compliance ## Start all IDENTIFY modules
	@echo "$(GREEN)✓ IDENTIFY modules started$(NC)"

threat-intel: network ## Start Threat Intelligence (MISP, IntelOWL, OpenCTI)
	@echo "$(BLUE)Starting Threat Intelligence module...$(NC)"
	$(COMPOSE) -f $(MODULES_DIR)/01-identify/threat-intel/docker-compose.yml up -d

compliance: network ## Start Compliance (CISO Assistant)
	@echo "$(BLUE)Starting Compliance module...$(NC)"
	$(COMPOSE) -f $(MODULES_DIR)/01-identify/compliance/docker-compose.yml up -d

# ============================================================
# PROTECT - Access Control, Security Training, Data Security
# ============================================================
protect: network admin vuln-audit deception ## Start all PROTECT modules
	@echo "$(GREEN)✓ PROTECT modules started$(NC)"

admin: network ## Start Administration (Portainer, Guacamole, Authentik)
	@echo "$(BLUE)Starting Administration module...$(NC)"
	$(COMPOSE) -f $(MODULES_DIR)/02-protect/administration/docker-compose.yml up -d

vuln-audit: network ## Start Vulnerability Audit (OpenVAS, Nuclei, ZAP)
	@echo "$(BLUE)Starting Vulnerability Audit module...$(NC)"
	$(COMPOSE) -f $(MODULES_DIR)/02-protect/vulnerability-audit/docker-compose.yml up -d

deception: network ## Start Deception (Honeypots)
	@echo "$(BLUE)Starting Deception module...$(NC)"
	$(COMPOSE) -f $(MODULES_DIR)/02-protect/deception/docker-compose.yml up -d

# ============================================================
# DETECT - Anomalies, Events, Continuous Monitoring
# ============================================================
detect: network siem observability hunting ## Start all DETECT modules
	@echo "$(GREEN)✓ DETECT modules started$(NC)"

siem: network ## Start SIEM (ELK, Wazuh)
	@echo "$(BLUE)Starting SIEM module...$(NC)"
	$(COMPOSE) -f $(MODULES_DIR)/03-detect/siem/docker-compose.yml up -d

observability: network ## Start Observability (Grafana, Prometheus, Loki)
	@echo "$(BLUE)Starting Observability module...$(NC)"
	$(COMPOSE) -f $(MODULES_DIR)/03-detect/observability/docker-compose.yml up -d

hunting: network ## Start Threat Hunting (RITA, Hayabusa, Jupyter)
	@echo "$(BLUE)Starting Threat Hunting module...$(NC)"
	$(COMPOSE) -f $(MODULES_DIR)/03-detect/threat-hunting/docker-compose.yml up -d

# ============================================================
# RESPOND - Analysis, Mitigation, Communications
# ============================================================
respond: network automation forensics ticketing ## Start all RESPOND modules
	@echo "$(GREEN)✓ RESPOND modules started$(NC)"

automation: network ## Start Automation (n8n, Shuffle)
	@echo "$(BLUE)Starting Automation module...$(NC)"
	$(COMPOSE) -f $(MODULES_DIR)/04-respond/automation/docker-compose.yml up -d

forensics: network ## Start Forensics & IR (Velociraptor, CAPE, Timesketch)
	@echo "$(BLUE)Starting Forensics module...$(NC)"
	$(COMPOSE) -f $(MODULES_DIR)/04-respond/forensics-ir/docker-compose.yml up -d

ticketing: network ## Start Ticketing (Zammad)
	@echo "$(BLUE)Starting Ticketing module...$(NC)"
	$(COMPOSE) -f $(MODULES_DIR)/04-respond/ticketing/docker-compose.yml up -d

# ============================================================
# RECOVER - Recovery Planning, Improvements, Communications
# ============================================================
recover: network collaboration ## Start all RECOVER modules
	@echo "$(GREEN)✓ RECOVER modules started$(NC)"

collaboration: network ## Start Collaboration (Wiki.js, Nextcloud, Mattermost)
	@echo "$(BLUE)Starting Collaboration module...$(NC)"
	$(COMPOSE) -f $(MODULES_DIR)/05-recover/collaboration/docker-compose.yml up -d

# ============================================================
# RED TEAM - Adversary Simulation (Use with caution!)
# ============================================================
redteam: network ## Start Red Team tools (⚠️ Authorized testing only!)
	@echo "$(RED)⚠️  WARNING: Red Team tools for authorized testing only!$(NC)"
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	@echo "$(BLUE)Starting Red Team module...$(NC)"
	$(COMPOSE) -f $(MODULES_DIR)/06-redteam/offensive-tools/docker-compose.yml up -d

offensive: redteam ## Alias for redteam

# ============================================================
# PROFILES - Common combinations
# ============================================================
minimal: network siem ## Minimal setup (SIEM only)
	@echo "$(GREEN)✓ Minimal profile started$(NC)"

standard: network siem observability automation collaboration ## Standard SOC setup
	@echo "$(GREEN)✓ Standard profile started$(NC)"

full: identify protect detect respond recover ## Full SOC (all modules except Red Team)
	@echo "$(GREEN)✓ Full SOC started - $(RED)Warning: High resource usage!$(NC)"

# ============================================================
# UTILITIES
# ============================================================
logs: ## Show logs for all containers
	@docker logs -f --tail=100 $(shell docker ps -q --filter "name=labsoc")

pull: ## Pull latest images for all modules
	@echo "$(BLUE)Pulling latest images...$(NC)"
	@for dir in $(MODULES_DIR)/*/*; do \
		if [ -f "$$dir/docker-compose.yml" ]; then \
			$(COMPOSE) -f "$$dir/docker-compose.yml" pull; \
		fi \
	done

update: pull stop all ## Update and restart all running modules
	@echo "$(GREEN)✓ Update complete$(NC)"

ports: ## Show all exposed ports
	@echo "$(BLUE)Exposed ports:$(NC)"
	@docker ps --format "{{.Names}}: {{.Ports}}" | grep labsoc | sort
