# 🛡️ SOC-in-a-Box - Detection Use Cases

## Overview

This document describes the 10 detection use cases implemented in SOC-in-a-Box, aligned with the MITRE ATT&CK framework.

---

## UC-001: SSH Brute Force Detection

| Field | Value |
|-------|-------|
| **Severity** | High |
| **MITRE ATT&CK** | T1110 - Brute Force |
| **Data Sources** | Suricata, SSH logs |
| **Threshold** | >5 attempts/minute from same IP |

### Description
Detects multiple failed SSH authentication attempts, indicating potential brute force attacks.

### KQL Query
```kql
event_type:"alert" AND alert.signature:*SSH* AND alert.signature:*Brute*
```

### Response Actions
1. Block source IP at firewall
2. Review authentication logs
3. Check for successful logins post-attack
4. Document in IRIS DFIR

---

## UC-002: Port Scan Detection

| Field | Value |
|-------|-------|
| **Severity** | Medium |
| **MITRE ATT&CK** | T1046 - Network Service Discovery |
| **Data Sources** | Suricata, Zeek conn.log |
| **Threshold** | >20 ports in 5 seconds |

### Description
Identifies reconnaissance activities where attackers probe network services.

### KQL Query
```kql
event_type:"alert" AND alert.signature:*Scan*
```

### Response Actions
1. Identify scan type (SYN, XMAS, NULL)
2. Check source IP reputation
3. Review targeted services
4. Block if malicious

---

## UC-003: DNS Tunneling / Exfiltration

| Field | Value |
|-------|-------|
| **Severity** | High |
| **MITRE ATT&CK** | T1071.004 - Application Layer Protocol: DNS |
| **Data Sources** | Suricata, Zeek dns.log |
| **Threshold** | Query >50 characters or >100 queries/min |

### Description
Detects data exfiltration or C2 communication via DNS tunneling.

### KQL Query
```kql
event_type:"dns" AND dns.query.length > 50
```

### Response Actions
1. Analyze DNS query patterns
2. Identify encoded data
3. Block DNS to suspicious domains
4. Hunt for related malware

---

## UC-004: Malware C2 Communication

| Field | Value |
|-------|-------|
| **Severity** | Critical |
| **MITRE ATT&CK** | T1071.001 - Web Protocols, T1571 - Non-Standard Port |
| **Data Sources** | Suricata, Zeek http.log, ssl.log |
| **Indicators** | Ports 4444, 1337, suspicious User-Agents |

### Description
Identifies command and control communication patterns.

### KQL Query
```kql
dest_port:(4444 OR 1337) OR http.user_agent:*MSIE*
```

### Response Actions
1. Isolate infected host
2. Capture network traffic (PCAP)
3. Perform memory forensics
4. Identify IOCs and hunt across environment

---

## UC-005: Data Exfiltration

| Field | Value |
|-------|-------|
| **Severity** | Critical |
| **MITRE ATT&CK** | T1048 - Exfiltration Over Alternative Protocol |
| **Data Sources** | Suricata, Zeek conn.log, files.log |
| **Threshold** | Outbound transfer >10MB |

### Description
Detects large data transfers to external destinations.

### KQL Query
```kql
event_type:"flow" AND bytes_toserver > 10000000
```

### Response Actions
1. Identify data type being transferred
2. Check destination reputation
3. Review user activity
4. Preserve evidence for forensics

---

## UC-006: Lateral Movement

| Field | Value |
|-------|-------|
| **Severity** | High |
| **MITRE ATT&CK** | T1021 - Remote Services |
| **Data Sources** | Suricata, Windows Event Logs |
| **Protocols** | RDP (3389), SMB (445), WinRM (5985), SSH (22) |

### Description
Detects attackers moving through the network after initial compromise.

### KQL Query
```kql
dest_port:(3389 OR 445 OR 5985 OR 5986) AND src.ip:192.168.*
```

### Response Actions
1. Map lateral movement path
2. Identify compromised credentials
3. Check for privilege escalation
4. Contain affected systems

---

## UC-007: Credential Theft

| Field | Value |
|-------|-------|
| **Severity** | Critical |
| **MITRE ATT&CK** | T1003 - OS Credential Dumping |
| **Data Sources** | Suricata, HTTP logs |
| **Indicators** | Mimikatz, pwdump, gsecdump downloads |

### Description
Detects attempts to download credential harvesting tools.

### KQL Query
```kql
http.uri:*mimikatz* OR http.uri:*pwdump* OR http.uri:*gsecdump*
```

### Response Actions
1. Immediately block download
2. Check if file was executed
3. Reset potentially compromised credentials
4. Perform AD security assessment

---

## UC-008: Web Application Attacks

| Field | Value |
|-------|-------|
| **Severity** | Medium-High |
| **MITRE ATT&CK** | T1190 - Exploit Public-Facing Application |
| **Data Sources** | Suricata, Web server logs |
| **Attack Types** | SQL Injection, XSS, Path Traversal, Command Injection |

### Description
Detects common web application attack patterns.

### KQL Query
```kql
event_type:"http" AND (http.uri:*SELECT* OR http.uri:*UNION* OR http.uri:*script* OR http.uri:*../* )
```

### Response Actions
1. Review WAF logs
2. Check for successful exploits
3. Patch vulnerable applications
4. Implement rate limiting

---

## UC-009: Cryptomining Detection

| Field | Value |
|-------|-------|
| **Severity** | Medium |
| **MITRE ATT&CK** | T1496 - Resource Hijacking |
| **Data Sources** | Suricata, Process monitoring |
| **Indicators** | Stratum protocol, Mining pool ports (3333, 14444) |

### Description
Identifies unauthorized cryptocurrency mining activity.

### KQL Query
```kql
dest_port:(3333 OR 14444) OR http.response_body:*coinhive*
```

### Response Actions
1. Identify affected systems
2. Terminate mining processes
3. Remove malware/scripts
4. Review how mining software was introduced

---

## UC-010: Tor / Anonymization

| Field | Value |
|-------|-------|
| **Severity** | Medium |
| **MITRE ATT&CK** | T1090.003 - Multi-hop Proxy |
| **Data Sources** | Suricata, Firewall logs |
| **Indicators** | Ports 9001, 9030, VPN service domains |

### Description
Detects usage of Tor or VPN services that may indicate policy violations or malicious activity.

### KQL Query
```kql
dest_port:(9001 OR 9030) OR tls.sni:*vpn*
```

### Response Actions
1. Review user's role and need for anonymization
2. Check for policy violations
3. Investigate potential insider threat
4. Block if unauthorized

---

## 📊 Detection Matrix

| Use Case | Suricata SID Range | Severity | Auto-Alert |
|----------|-------------------|----------|------------|
| UC-001 | 1000001-1000002 | High | ✅ |
| UC-002 | 1000003-1000005 | Medium | ✅ |
| UC-003 | 1000006-1000008 | High | ✅ |
| UC-004 | 1000009-1000012 | Critical | ✅ |
| UC-005 | 1000013-1000015 | Critical | ✅ |
| UC-006 | 1000016-1000019 | High | ✅ |
| UC-007 | 1000020-1000021 | Critical | ✅ |
| UC-008 | 1000022-1000025 | Medium-High | ✅ |
| UC-009 | 1000026-1000028 | Medium | ✅ |
| UC-010 | 1000029-1000031 | Medium | ✅ |

---

## 🔗 Related Resources

- [MITRE ATT&CK Framework](https://attack.mitre.org/)
- [Sigma Rules Repository](https://github.com/SigmaHQ/sigma)
- [Suricata Documentation](https://suricata.readthedocs.io/)
- [Elastic Security](https://www.elastic.co/security)
