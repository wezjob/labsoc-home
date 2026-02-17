#!/bin/bash
# Script to create Kibana visualizations

KIBANA_URL="http://localhost:5601"
AUTH="elastic:LabSoc2026!"

echo "Creating Kibana Visualizations..."

# 1. Alerts by Severity (Pie)
curl -s -u $AUTH -X POST "$KIBANA_URL/api/saved_objects/visualization/viz-severity" \
  -H "kbn-xsrf: true" -H "Content-Type: application/json" \
  -d '{"attributes":{"title":"Alerts by Severity","visState":"{\"title\":\"Alerts by Severity\",\"type\":\"pie\",\"params\":{\"type\":\"pie\",\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"right\",\"isDonut\":true},\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"enabled\":true,\"type\":\"terms\",\"schema\":\"segment\",\"params\":{\"field\":\"event.severity.keyword\",\"size\":5,\"order\":\"desc\",\"orderBy\":\"1\"}}]}","uiStateJSON":"{}","kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"labsoc-data-view\",\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"}}}' > /dev/null && echo "✅ Severity Pie"

# 2. MITRE Tactics (Pie)
curl -s -u $AUTH -X POST "$KIBANA_URL/api/saved_objects/visualization/viz-mitre-tactics" \
  -H "kbn-xsrf: true" -H "Content-Type: application/json" \
  -d '{"attributes":{"title":"MITRE Tactics Distribution","visState":"{\"title\":\"MITRE Tactics\",\"type\":\"pie\",\"params\":{\"type\":\"pie\",\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"right\"},\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"enabled\":true,\"type\":\"terms\",\"schema\":\"segment\",\"params\":{\"field\":\"mitre.tactic.keyword\",\"size\":10,\"order\":\"desc\",\"orderBy\":\"1\"}}]}","uiStateJSON":"{}","kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"labsoc-data-view\",\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"}}}' > /dev/null && echo "✅ MITRE Tactics"

# 3. Top Source IPs (Bar)
curl -s -u $AUTH -X POST "$KIBANA_URL/api/saved_objects/visualization/viz-top-ips" \
  -H "kbn-xsrf: true" -H "Content-Type: application/json" \
  -d '{"attributes":{"title":"Top Source IPs","visState":"{\"title\":\"Top Source IPs\",\"type\":\"horizontal_bar\",\"params\":{\"type\":\"histogram\",\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"right\"},\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"enabled\":true,\"type\":\"terms\",\"schema\":\"segment\",\"params\":{\"field\":\"source.ip.keyword\",\"size\":10,\"order\":\"desc\",\"orderBy\":\"1\"}}]}","uiStateJSON":"{}","kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"labsoc-data-view\",\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"}}}' > /dev/null && echo "✅ Top Source IPs"

# 4. Alert Timeline (Area)
curl -s -u $AUTH -X POST "$KIBANA_URL/api/saved_objects/visualization/viz-timeline" \
  -H "kbn-xsrf: true" -H "Content-Type: application/json" \
  -d '{"attributes":{"title":"Alert Timeline","visState":"{\"title\":\"Alert Timeline\",\"type\":\"area\",\"params\":{\"type\":\"area\",\"addTooltip\":true,\"addLegend\":true,\"legendPosition\":\"right\"},\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"enabled\":true,\"type\":\"date_histogram\",\"schema\":\"segment\",\"params\":{\"field\":\"@timestamp\",\"interval\":\"auto\"}}]}","uiStateJSON":"{}","kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"labsoc-data-view\",\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"}}}' > /dev/null && echo "✅ Alert Timeline"

# 5. Rules Table
curl -s -u $AUTH -X POST "$KIBANA_URL/api/saved_objects/visualization/viz-rules-table" \
  -H "kbn-xsrf: true" -H "Content-Type: application/json" \
  -d '{"attributes":{"title":"Top Alert Rules","visState":"{\"title\":\"Top Alert Rules\",\"type\":\"table\",\"params\":{\"perPage\":10,\"showPartialRows\":false,\"showMetricsAtAllLevels\":false},\"aggs\":[{\"id\":\"1\",\"enabled\":true,\"type\":\"count\",\"schema\":\"metric\",\"params\":{}},{\"id\":\"2\",\"enabled\":true,\"type\":\"terms\",\"schema\":\"bucket\",\"params\":{\"field\":\"rule.name.keyword\",\"size\":10,\"order\":\"desc\",\"orderBy\":\"1\"}}]}","uiStateJSON":"{}","kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"labsoc-data-view\",\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[]}"}}}' > /dev/null && echo "✅ Rules Table"

echo ""
echo "All visualizations created!"
echo "Go to Kibana → Visualize Library to see them"
