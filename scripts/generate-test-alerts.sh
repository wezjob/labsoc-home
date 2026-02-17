#!/bin/bash
# generate-test-alerts.sh - Génère des alertes de test pour LabSOC

ES_URL="http://localhost:9200"
ES_USER="elastic"
ES_PASS="LabSoc2026!"

echo "🚨 Génération d'alertes de test pour LabSOC..."

# Fonction pour créer un événement
create_event() {
    local data="$1"
    curl -s -u "${ES_USER}:${ES_PASS}" \
        -X POST "${ES_URL}/labsoc-alerts/_doc" \
        -H "Content-Type: application/json" \
        -d "$data" > /dev/null
}

# Alerte Suricata - SSH Brute Force
create_event '{
    "@timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'",
    "event.kind": "alert",
    "event.category": ["intrusion_detection"],
    "event.severity": "high",
    "rule.name": "ET SCAN Potential SSH Scan",
    "rule.id": "2001219",
    "source.ip": "192.168.1.100",
    "source.port": 54321,
    "destination.ip": "10.0.0.50",
    "destination.port": 22,
    "network.protocol": "tcp",
    "labsoc.source": "suricata",
    "suricata.alert.category": "Attempted Administrator Privilege Gain",
    "message": "SSH brute force attack detected from 192.168.1.100"
}'
echo "✅ SSH Brute Force alert"

# Alerte Suricata - DNS Tunneling
create_event '{
    "@timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'",
    "event.kind": "alert",
    "event.category": ["intrusion_detection"],
    "event.severity": "critical",
    "rule.name": "LABSOC DNS Tunneling Detected",
    "rule.id": "1000002",
    "source.ip": "10.0.0.25",
    "source.port": 49152,
    "destination.ip": "8.8.8.8",
    "destination.port": 53,
    "network.protocol": "udp",
    "labsoc.source": "suricata",
    "dns.question.name": "exfil.malicious-domain.com",
    "message": "Potential DNS tunneling - unusually long DNS query detected"
}'
echo "✅ DNS Tunneling alert"

# Alerte Zeek - Suspicious Connection
create_event '{
    "@timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'",
    "event.kind": "alert",
    "event.category": ["network"],
    "event.severity": "medium",
    "rule.name": "Zeek Notice: Scan::Port_Scan",
    "source.ip": "192.168.1.150",
    "destination.ip": "10.0.0.0/24",
    "network.protocol": "tcp",
    "labsoc.source": "zeek",
    "zeek.notice.note": "Scan::Port_Scan",
    "message": "Port scan detected from 192.168.1.150 targeting internal network"
}'
echo "✅ Port Scan alert"

# Alerte Suricata - C2 Communication
create_event '{
    "@timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'",
    "event.kind": "alert",
    "event.category": ["malware"],
    "event.severity": "critical",
    "rule.name": "LABSOC Potential C2 Beaconing",
    "rule.id": "1000009",
    "source.ip": "10.0.0.42",
    "source.port": 51234,
    "destination.ip": "185.220.101.1",
    "destination.port": 443,
    "network.protocol": "tcp",
    "labsoc.source": "suricata",
    "threat.indicator.type": "ipv4-addr",
    "message": "Potential C2 beaconing activity - regular interval connections to suspicious IP"
}'
echo "✅ C2 Beaconing alert"

# Alerte Zeek - Data Exfiltration
create_event '{
    "@timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'",
    "event.kind": "alert",
    "event.category": ["network"],
    "event.severity": "high",
    "rule.name": "Large Outbound Transfer",
    "source.ip": "10.0.0.33",
    "source.port": 48765,
    "destination.ip": "203.0.113.50",
    "destination.port": 443,
    "network.protocol": "tcp",
    "network.bytes": 524288000,
    "labsoc.source": "zeek",
    "message": "Large data transfer (500MB) to external IP detected"
}'
echo "✅ Data Exfiltration alert"

# Alerte Suricata - Ransomware
create_event '{
    "@timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'",
    "event.kind": "alert",
    "event.category": ["malware"],
    "event.severity": "critical",
    "rule.name": "LABSOC Ransomware Activity Detected",
    "rule.id": "1000011",
    "source.ip": "10.0.0.55",
    "destination.ip": "10.0.0.1",
    "destination.port": 445,
    "network.protocol": "tcp",
    "labsoc.source": "suricata",
    "file.extension": "encrypted",
    "message": "Ransomware activity - suspicious SMB traffic with encryption patterns"
}'
echo "✅ Ransomware alert"

# Alerte - TOR Usage
create_event '{
    "@timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'",
    "event.kind": "alert",
    "event.category": ["network"],
    "event.severity": "medium",
    "rule.name": "LABSOC TOR Network Usage",
    "rule.id": "1000006",
    "source.ip": "10.0.0.88",
    "source.port": 39876,
    "destination.ip": "185.220.101.34",
    "destination.port": 9001,
    "network.protocol": "tcp",
    "labsoc.source": "suricata",
    "message": "TOR network connection detected from internal host"
}'
echo "✅ TOR Usage alert"

# Alerte - Phishing
create_event '{
    "@timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'",
    "event.kind": "alert",
    "event.category": ["intrusion_detection"],
    "event.severity": "high",
    "rule.name": "LABSOC Phishing Domain Access",
    "rule.id": "1000013",
    "source.ip": "10.0.0.77",
    "destination.ip": "198.51.100.99",
    "destination.port": 443,
    "network.protocol": "tcp",
    "labsoc.source": "suricata",
    "url.domain": "login-microsoft-secure.malicious.com",
    "message": "User accessed known phishing domain mimicking Microsoft login"
}'
echo "✅ Phishing alert"

# Alerte - Cryptomining
create_event '{
    "@timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'",
    "event.kind": "alert",
    "event.category": ["malware"],
    "event.severity": "medium",
    "rule.name": "LABSOC Crypto Mining Activity",
    "rule.id": "1000007",
    "source.ip": "10.0.0.99",
    "source.port": 45678,
    "destination.ip": "pool.mining-monero.com",
    "destination.port": 3333,
    "network.protocol": "tcp",
    "labsoc.source": "suricata",
    "message": "Cryptocurrency mining activity detected - connection to mining pool"
}'
echo "✅ Cryptomining alert"

# Alerte - Lateral Movement
create_event '{
    "@timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'",
    "event.kind": "alert",
    "event.category": ["intrusion_detection"],
    "event.severity": "critical",
    "rule.name": "LABSOC Lateral Movement Detected",
    "rule.id": "1000010",
    "source.ip": "10.0.0.42",
    "source.port": 51234,
    "destination.ip": "10.0.0.50",
    "destination.port": 445,
    "network.protocol": "tcp",
    "labsoc.source": "suricata",
    "message": "Lateral movement detected - SMB connection between internal hosts"
}'
echo "✅ Lateral Movement alert"

echo ""
echo "🎉 10 alertes de test créées avec succès!"
echo ""
echo "📊 Vérification:"
curl -s -u "${ES_USER}:${ES_PASS}" "${ES_URL}/labsoc-alerts/_count" | python3 -c "import sys,json; print(f\"   Nombre d'alertes: {json.load(sys.stdin)['count']}\")"
echo ""
echo "👉 Accède à Kibana: http://localhost:5601"
echo "   Menu → Discover → Sélectionne 'LabSOC - All Logs'"
