#!/bin/bash
# ============================================
# LABSOC HOME - Stop Script
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🔴 LABSOC HOME - Stopping Security Operations Center..."
echo "=================================================="

cd "$PROJECT_DIR"

# Stop all containers
docker-compose down

echo ""
echo "✅ All services stopped."
echo ""
echo "💡 To remove all data as well, run:"
echo "   docker-compose down -v"
echo ""
