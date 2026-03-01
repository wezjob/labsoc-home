# 📋 Cahier des Charges
## SOC Analyst Assistant - Application Web

**Version:** 1.0  
**Date:** 27 Février 2026  
**Projet:** SOC-in-a-Box Integration  

---

## 📑 Table des Matières

1. [Contexte et Objectifs](#1-contexte-et-objectifs)
2. [Périmètre Fonctionnel](#2-périmètre-fonctionnel)
3. [Architecture Technique](#3-architecture-technique)
4. [Spécifications Fonctionnelles Détaillées](#4-spécifications-fonctionnelles-détaillées)
5. [Intégrations avec SOC-in-a-Box](#5-intégrations-avec-soc-in-a-box)
6. [Interface Utilisateur (UI/UX)](#6-interface-utilisateur-uiux)
7. [Sécurité et Conformité](#7-sécurité-et-conformité)
8. [Livrables et Planning](#8-livrables-et-planning)

---

## 1. Contexte et Objectifs

### 1.1 Contexte

L'application **SOC Analyst Assistant** s'intègre dans l'écosystème **SOC-in-a-Box** existant, qui comprend :
- **ELK Stack** (Elasticsearch 8.11, Kibana, Logstash, Filebeat)
- **Suricata/Zeek** pour la détection d'intrusions
- **IRIS DFIR** pour la réponse aux incidents
- **n8n** pour l'automatisation SOAR
- **Keycloak** pour l'authentification SSO

### 1.2 Objectifs Principaux

| # | Objectif | Description |
|---|----------|-------------|
| 1 | **Assistance à l'Analyse** | Guider les analystes N1 dans l'analyse des logs et la qualification des alertes |
| 2 | **Gestion des SOPs** | Centraliser et rendre accessibles les procédures opérationnelles standard |
| 3 | **Formation Continue** | Fournir des exemples pratiques et des exercices en temps réel |
| 4 | **Suivi des Performances** | Mesurer et tracker le travail des analystes |
| 5 | **Standardisation** | Assurer une méthodologie cohérente pour tous les analystes |

### 1.3 Utilisateurs Cibles

| Rôle | Description | Besoins |
|------|-------------|---------|
| **Analyste N1 Junior** | Débutant (0-6 mois) | Guidance maximale, exemples détaillés |
| **Analyste N1 Confirmé** | Expérimenté (6-24 mois) | Accès rapide aux SOPs, autonomie |
| **Lead/Superviseur SOC** | Manager équipe | Suivi équipe, métriques, rapports |
| **Administrateur** | Gestion plateforme | Configuration SOPs, workflows |

---

## 2. Périmètre Fonctionnel

### 2.1 Modules Principaux

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        SOC ANALYST ASSISTANT                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐           │
│  │  📊 DASHBOARD    │  │  🚨 ALERTES      │  │  📋 SOP CENTER   │           │
│  │  Vue d'ensemble  │  │  Queue & Triage  │  │  Procédures      │           │
│  │  KPIs temps réel │  │  Investigation   │  │  Playbooks       │           │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘           │
│                                                                              │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐           │
│  │  🎓 GUIDE MODE   │  │  📈 ANALYTICS    │  │  👤 MON ESPACE   │           │
│  │  Assistance IA   │  │  Métriques       │  │  Tâches          │           │
│  │  Exemples live   │  │  Performance     │  │  Progression     │           │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘           │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Fonctionnalités par Module

#### Module 1: Dashboard Central
- [ ] Vue temps réel des alertes en attente
- [ ] KPIs: MTTR, MTTD, alertes traitées/jour
- [ ] Statut des services SOC-in-a-Box
- [ ] Fil d'activité de l'équipe

#### Module 2: Gestion des Alertes
- [ ] Queue d'alertes avec priorisation automatique
- [ ] Interface d'investigation guidée
- [ ] Enrichissement automatique (IOC, VirusTotal, etc.)
- [ ] Soumission de résultats structurés

#### Module 3: Centre SOP
- [ ] Bibliothèque de procédures organisée par catégorie
- [ ] Éditeur WYSIWYG pour création/modification
- [ ] Versioning et historique des modifications
- [ ] Recherche plein texte

#### Module 4: Mode Guidé (Guide Mode)
- [ ] Assistance contextuelle basée sur le type d'alerte
- [ ] Exemples pratiques avec logs réels
- [ ] Checklist interactives
- [ ] Suggestions d'actions IA

#### Module 5: Analytics & Reporting
- [ ] Tableaux de bord de performance par analyste
- [ ] Rapports d'équipe (shift, hebdo, mensuel)
- [ ] Tendances et patterns d'alertes
- [ ] Export PDF/CSV

#### Module 6: Espace Personnel
- [ ] Mes tâches assignées
- [ ] Mon historique d'analyse
- [ ] Ma progression et badges
- [ ] Mes notes personnelles

---

## 3. Architecture Technique

### 3.1 Stack Technologique

```
┌─────────────────────────────────────────────────────────────────┐
│                         FRONTEND                                 │
│  Next.js 14 + React 18 + TypeScript + Tailwind CSS + shadcn/ui │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                          BACKEND                                 │
│  Node.js + Express/Fastify + TypeScript + Prisma ORM            │
└─────────────────────────────────────────────────────────────────┘
                              │
            ┌─────────────────┼─────────────────┐
            ▼                 ▼                 ▼
┌───────────────────┐ ┌───────────────┐ ┌───────────────────────┐
│   PostgreSQL      │ │    Redis      │ │   Elasticsearch       │
│   (Main DB)       │ │   (Cache)     │ │   (Logs & Search)     │
└───────────────────┘ └───────────────┘ └───────────────────────┘
```

### 3.2 Intégration SOC-in-a-Box

| Service | Intégration | Usage |
|---------|-------------|-------|
| **Elasticsearch** | REST API | Récupération alertes Suricata/Zeek |
| **Kibana** | iFrame/Links | Visualisations détaillées |
| **IRIS DFIR** | REST API | Création/MAJ incidents |
| **n8n** | Webhooks | Déclenchement workflows automatisés |
| **Keycloak** | OIDC/OAuth2 | Authentification SSO |
| **Vaultwarden** | API | Récupération secrets |

### 3.3 Schéma de Données Principal

```sql
-- Utilisateurs (synchronisé avec Keycloak)
Users {
  id: UUID PK
  keycloak_id: VARCHAR
  email: VARCHAR
  role: ENUM(analyst_junior, analyst_senior, lead, admin)
  team_id: FK
  created_at: TIMESTAMP
}

-- Alertes (enrichies depuis Elasticsearch)
Alerts {
  id: UUID PK
  elasticsearch_id: VARCHAR
  title: VARCHAR
  severity: ENUM(critical, high, medium, low, info)
  status: ENUM(new, assigned, investigating, resolved, escalated, false_positive)
  assigned_to: FK Users
  source: VARCHAR(suricata, zeek, filebeat, etc.)
  raw_log: JSONB
  enrichment_data: JSONB
  created_at: TIMESTAMP
  updated_at: TIMESTAMP
}

-- Investigations (résultats d'analyse)
Investigations {
  id: UUID PK
  alert_id: FK Alerts
  analyst_id: FK Users
  sop_used: FK SOPs
  checklist_results: JSONB
  findings: TEXT
  conclusion: ENUM(true_positive, false_positive, needs_escalation)
  actions_taken: JSONB
  time_spent_minutes: INT
  created_at: TIMESTAMP
}

-- SOPs (Procédures Opérationnelles)
SOPs {
  id: UUID PK
  title: VARCHAR
  category: VARCHAR
  alert_types: VARCHAR[]
  content_markdown: TEXT
  checklist: JSONB
  examples: JSONB
  version: INT
  status: ENUM(draft, published, archived)
  created_by: FK Users
  created_at: TIMESTAMP
  updated_at: TIMESTAMP
}

-- Tâches assignées
Tasks {
  id: UUID PK
  analyst_id: FK Users
  alert_id: FK Alerts (nullable)
  type: ENUM(investigate_alert, review_sop, training, other)
  description: TEXT
  due_date: TIMESTAMP
  status: ENUM(pending, in_progress, completed)
  priority: INT
}

-- Analytics / Métriques
AnalystMetrics {
  id: UUID PK
  analyst_id: FK Users
  date: DATE
  alerts_processed: INT
  avg_resolution_time_min: FLOAT
  true_positives: INT
  false_positives: INT
  escalations: INT
}
```

---

## 4. Spécifications Fonctionnelles Détaillées

### 4.1 Module Alertes - Workflow Complet

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   NOUVELLE   │────▶│   ASSIGNÉE   │────▶│  EN COURS    │────▶│   RÉSOLUE    │
│    ALERTE    │     │              │     │ INVESTIGATION│     │              │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
       │                    │                    │                    │
       │                    │                    │                    │
       ▼                    ▼                    ▼                    ▼
  Auto-triage         Notification        Mode Guidé            Rapport
  Priorisation        Analyste            SOP suggéré           Métriques
  Enrichissement      Timer démarré       Checklist             Feedback
```

### 4.2 Interface Investigation Guidée

Pour chaque type d'alerte, l'analyste voit :

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 🚨 ALERTE: SSH Brute Force Attempt                          [HIGH] [OPEN]  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│ ┌─────────────────────────────────┐  ┌─────────────────────────────────────┐│
│ │ 📋 INFORMATIONS                 │  │ 🎯 SOP RECOMMANDÉ                   ││
│ │                                 │  │                                     ││
│ │ Source IP: 192.168.1.100        │  │ SOP-SEC-001: SSH Brute Force        ││
│ │ Dest IP: 10.0.0.50              │  │ Response                            ││
│ │ Tentatives: 47 en 60s           │  │                                     ││
│ │ Timestamp: 2026-02-27 14:32:15  │  │ [📖 Ouvrir le SOP]                  ││
│ │ Rule: LABSOC SSH Brute Force    │  │                                     ││
│ └─────────────────────────────────┘  └─────────────────────────────────────┘│
│                                                                              │
│ ┌───────────────────────────────────────────────────────────────────────────┐│
│ │ ✅ CHECKLIST D'INVESTIGATION                                              ││
│ │                                                                           ││
│ │ □ Vérifier si l'IP source est connue (asset interne, VPN, etc.)          ││
│ │ □ Consulter l'historique des connexions de l'IP source                   ││
│ │ □ Vérifier si des connexions SSH ont réussi                              ││
│ │ □ Identifier le compte ciblé                                             ││
│ │ □ Vérifier les logs système de la machine cible                          ││
│ │ □ Déterminer si c'est un scan automatisé ou ciblé                        ││
│ └───────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
│ ┌───────────────────────────────────────────────────────────────────────────┐│
│ │ 💡 EXEMPLE PRATIQUE                                                       ││
│ │                                                                           ││
│ │ Voici comment rechercher l'historique de l'IP dans Kibana:               ││
│ │ ┌─────────────────────────────────────────────────────────────────────┐  ││
│ │ │ source.ip: "192.168.1.100" AND event.category: "authentication"    │  ││
│ │ └─────────────────────────────────────────────────────────────────────┘  ││
│ │ [🔍 Exécuter dans Kibana] [📋 Copier]                                    ││
│ └───────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
│ ┌───────────────────────────────────────────────────────────────────────────┐│
│ │ 📝 MES FINDINGS                                                           ││
│ │                                                                           ││
│ │ [________________________________________________]                        ││
│ │                                                                           ││
│ │ Conclusion: ○ True Positive  ○ False Positive  ○ Escalation requise      ││
│ │                                                                           ││
│ │ Actions: □ Bloquer IP  □ Notifier propriétaire  □ Créer incident IRIS    ││
│ │                                                                           ││
│ │                               [💾 Soumettre Investigation]                ││
│ └───────────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 Catégories de SOPs

| Catégorie | Code | Exemples |
|-----------|------|----------|
| **Authentification** | SOP-AUTH-XXX | Brute Force, Failed Logins, Suspicious Auth |
| **Réseau** | SOP-NET-XXX | DNS Tunneling, Data Exfil, Port Scan |
| **Malware** | SOP-MAL-XXX | Crypto Mining, C2 Communication, Ransomware |
| **Web** | SOP-WEB-XXX | SQL Injection, XSS, Web Shell |
| **Endpoint** | SOP-END-XXX | Process Injection, Privilege Escalation |
| **Cloud** | SOP-CLD-XXX | AWS/Azure/GCP Suspicious Activity |

### 4.4 Système de Gamification

Pour motiver les analystes juniors :

| Badge | Condition | Points |
|-------|-----------|--------|
| 🌟 Premier Pas | Première alerte résolue | 10 |
| 🔥 En Feu | 10 alertes/jour | 50 |
| 🎯 Précision | 95% accuracy sur 50 alertes | 100 |
| 📚 Expert SOP | Tous les SOPs consultés | 75 |
| ⚡ Velocité | MTTR < 5 min sur 20 alertes | 150 |
| 🏆 Champion | Top performer du mois | 500 |

---

## 5. Intégrations avec SOC-in-a-Box

### 5.1 Elasticsearch - Récupération des Alertes

```typescript
// Exemple de query pour récupérer les alertes Suricata
const getAlerts = async () => {
  const response = await esClient.search({
    index: 'suricata-*,zeek-*',
    body: {
      query: {
        bool: {
          must: [
            { range: { '@timestamp': { gte: 'now-24h' } } },
            { exists: { field: 'alert.signature' } }
          ]
        }
      },
      sort: [{ '@timestamp': 'desc' }],
      size: 100
    }
  });
  return response.hits.hits;
};
```

### 5.2 IRIS DFIR - Création d'Incident

```typescript
// Création automatique d'incident lors d'escalation
const createIrisIncident = async (alert: Alert, investigation: Investigation) => {
  const response = await fetch('https://localhost:8443/api/v2/cases', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${IRIS_API_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      case_name: `[${alert.severity}] ${alert.title}`,
      case_description: investigation.findings,
      case_soc_id: alert.id,
      classification_id: mapSeverityToClassification(alert.severity)
    })
  });
  return response.json();
};
```

### 5.3 n8n - Webhooks d'Automatisation

```yaml
# Workflows n8n déclenchés par l'application
workflows:
  - name: "Alert Enrichment"
    trigger: "Nouvelle alerte assignée"
    actions:
      - VirusTotal lookup
      - AbuseIPDB check
      - Shodan info
      - Update alert enrichment_data

  - name: "Escalation Notification"
    trigger: "Alerte escaladée"
    actions:
      - Create IRIS incident
      - Send Slack notification
      - Email SOC Lead

  - name: "Shift Report"
    trigger: "Fin de shift (schedule)"
    actions:
      - Compile analyst metrics
      - Generate PDF report
      - Send to management
```

### 5.4 Keycloak - Configuration SSO

```yaml
# Configuration OIDC pour Keycloak
keycloak:
  realm: "labsoc"
  client_id: "soc-assistant"
  client_secret: "${KEYCLOAK_CLIENT_SECRET}"
  issuer: "http://localhost:8180/realms/labsoc"
  
  role_mapping:
    "soc-admin": "admin"
    "soc-lead": "lead"
    "soc-analyst-senior": "analyst_senior"
    "soc-analyst": "analyst_junior"
```

---

## 6. Interface Utilisateur (UI/UX)

### 6.1 Design System

| Élément | Spécification |
|---------|---------------|
| **Framework CSS** | Tailwind CSS + shadcn/ui |
| **Thème** | Dark mode par défaut (SOC-friendly) |
| **Couleurs Sévérité** | Critical: #DC2626, High: #F97316, Medium: #EAB308, Low: #22C55E, Info: #3B82F6 |
| **Police** | Inter (UI) + JetBrains Mono (logs/code) |
| **Responsive** | Desktop-first, support tablette |

### 6.2 Navigation Principale

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 🛡️ SOC Assistant    [🔍 Recherche...]    [🔔 3]  [👤 John D.]  [⚙️]        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────┐                                                             │
│  │ 📊 Dashboard│                                                            │
│  │ 🚨 Alertes  │◀── Active                                                  │
│  │ 📋 SOPs     │                                                            │
│  │ 🎓 Guide    │                                                            │
│  │ 📈 Analytics│                                                            │
│  │ 👤 Mon Espace│                                                           │
│  │ ────────── │                                                             │
│  │ ⚙️ Admin   │                                                             │
│  └────────────┘                                                             │
│                                                                              │
│                    [ZONE DE CONTENU PRINCIPAL]                              │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.3 Wireframes Clés

#### Dashboard
- 4 KPI cards en haut (Alertes en attente, MTTR, Traitées aujourd'hui, Score équipe)
- Graphique d'activité sur 24h
- Liste des 10 dernières alertes
- Panel "Mes tâches"

#### Queue d'Alertes
- Filtres (sévérité, source, statut, assigné)
- Tableau avec colonnes: Sévérité, Titre, Source, Timestamp, Assigné, Actions
- Bulk actions (assigner, clôturer)
- Quick preview au hover

---

## 7. Sécurité et Conformité

### 7.1 Exigences de Sécurité

| Exigence | Implementation |
|----------|----------------|
| **Authentification** | SSO via Keycloak (OIDC), MFA obligatoire |
| **Autorisation** | RBAC (Role-Based Access Control) |
| **Audit Trail** | Logging complet des actions dans Elasticsearch |
| **Chiffrement** | TLS 1.3 en transit, AES-256 au repos |
| **Session** | Timeout 30min inactivité, refresh tokens |
| **API** | Rate limiting, JWT validation |

### 7.2 Rôles et Permissions

| Permission | Junior | Senior | Lead | Admin |
|------------|:------:|:------:|:----:|:-----:|
| Voir alertes | ✅ | ✅ | ✅ | ✅ |
| Traiter alertes | ✅ | ✅ | ✅ | ✅ |
| Escalader | ✅ | ✅ | ✅ | ✅ |
| Créer incident IRIS | ❌ | ✅ | ✅ | ✅ |
| Éditer SOPs | ❌ | ❌ | ✅ | ✅ |
| Voir analytics équipe | ❌ | ❌ | ✅ | ✅ |
| Gérer utilisateurs | ❌ | ❌ | ❌ | ✅ |
| Configuration système | ❌ | ❌ | ❌ | ✅ |

---

## 8. Livrables et Planning

### 8.1 Phases de Développement

| Phase | Durée | Livrables |
|-------|-------|-----------|
| **Phase 1: MVP** | 4 semaines | Auth SSO, Dashboard, Queue alertes basique |
| **Phase 2: Core** | 4 semaines | Investigation guidée, SOPs, Soumission résultats |
| **Phase 3: Analytics** | 3 semaines | Métriques, Rapports, Gamification |
| **Phase 4: IA/Guide** | 3 semaines | Suggestions IA, Mode guidé avancé |
| **Phase 5: Polish** | 2 semaines | Tests, Documentation, Déploiement |

### 8.2 Structure du Projet

```
soc-assistant/
├── apps/
│   └── web/                    # Application Next.js
│       ├── app/                # App Router
│       │   ├── (auth)/         # Pages authentification
│       │   ├── dashboard/      # Dashboard
│       │   ├── alerts/         # Module alertes
│       │   ├── sops/           # Module SOPs
│       │   ├── analytics/      # Module analytics
│       │   └── api/            # API Routes
│       ├── components/         # Composants React
│       ├── lib/                # Utilitaires
│       └── prisma/             # Schéma DB
├── packages/
│   ├── ui/                     # Composants partagés
│   ├── elasticsearch/          # Client ES
│   └── integrations/           # Clients IRIS, n8n
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
└── docs/
    └── api/                    # Documentation API
```

### 8.3 Endpoints API Principaux

```yaml
# Authentication
POST   /api/auth/login          # Login via Keycloak
POST   /api/auth/logout         # Logout
GET    /api/auth/me             # User info

# Alerts
GET    /api/alerts              # Liste alertes (paginated)
GET    /api/alerts/:id          # Détail alerte
PATCH  /api/alerts/:id          # Update status/assignment
POST   /api/alerts/:id/enrich   # Trigger enrichment

# Investigations
POST   /api/investigations      # Créer investigation
GET    /api/investigations/:id  # Détail investigation
PATCH  /api/investigations/:id  # Update investigation

# SOPs
GET    /api/sops                # Liste SOPs
GET    /api/sops/:id            # Détail SOP
POST   /api/sops                # Créer SOP (Lead/Admin)
PUT    /api/sops/:id            # Update SOP
GET    /api/sops/suggest/:alertType  # SOP recommandé

# Analytics
GET    /api/analytics/me        # Mes stats
GET    /api/analytics/team      # Stats équipe (Lead)
GET    /api/analytics/kpis      # KPIs dashboard

# Tasks
GET    /api/tasks               # Mes tâches
POST   /api/tasks               # Créer tâche
PATCH  /api/tasks/:id           # Update tâche
```

---

## 9. Critères d'Acceptation

### 9.1 Performance

| Métrique | Objectif |
|----------|----------|
| Time to First Byte | < 200ms |
| Chargement page | < 2s |
| Rafraîchissement alertes | Temps réel (WebSocket) |
| Recherche SOPs | < 500ms |

### 9.2 Disponibilité

- Uptime cible: 99.5%
- Monitoring via Uptime Kuma existant
- Logs centralisés dans ELK

### 9.3 Tests

| Type | Couverture |
|------|------------|
| Unit Tests | > 80% |
| Integration Tests | Tous les endpoints API |
| E2E Tests | Parcours critiques (login, investigation complète) |

---

## 10. Prochaines Étapes

1. **Validation** - Confirmer ce cahier des charges
2. **Setup Projet** - Initialiser le repo avec la structure
3. **Phase 1** - Développer le MVP (Auth + Dashboard + Alertes)
4. **Review** - Point d'étape après Phase 1

---

*Document préparé pour intégration avec SOC-in-a-Box (labsoc-home)*
