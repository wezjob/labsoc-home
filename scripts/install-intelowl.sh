#!/bin/bash
# ============================================
# LABSOC HOME - IntelOwl Installation Script
# ============================================
# IntelOwl requires manual installation due to complex dependencies
# This script clones and configures IntelOwl separately

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
INTELOWL_DIR="$PROJECT_DIR/intelowl-app"

echo "🦉 LABSOC HOME - Installing IntelOwl..."
echo "=================================================="

# Check prerequisites
if ! command -v git &> /dev/null; then
    echo "❌ Git is required. Please install git first."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is required. Please install Docker first."
    exit 1
fi

# Clone IntelOwl
if [ -d "$INTELOWL_DIR" ]; then
    echo "📁 IntelOwl directory exists, pulling latest..."
    cd "$INTELOWL_DIR"
    git pull
else
    echo "📥 Cloning IntelOwl..."
    git clone https://github.com/intelowlproject/IntelOwl.git "$INTELOWL_DIR"
    cd "$INTELOWL_DIR"
fi

# Copy environment file
if [ ! -f "$INTELOWL_DIR/docker/.env" ]; then
    echo "📝 Creating environment file..."
    cp "$INTELOWL_DIR/docker/.env_template" "$INTELOWL_DIR/docker/.env"
    
    # Update with LABSOC credentials
    sed -i '' "s/DJANGO_SECRET=.*/DJANGO_SECRET=labsoc-intelowl-secret-key-2026/" "$INTELOWL_DIR/docker/.env" 2>/dev/null || \
    sed -i "s/DJANGO_SECRET=.*/DJANGO_SECRET=labsoc-intelowl-secret-key-2026/" "$INTELOWL_DIR/docker/.env"
fi

# Initialize IntelOwl
echo "🔧 Initializing IntelOwl..."
cd "$INTELOWL_DIR"

# Start IntelOwl
echo "🚀 Starting IntelOwl..."
python3 start.py prod up -d

echo ""
echo "=================================================="
echo "✅ IntelOwl installed successfully!"
echo "=================================================="
echo ""
echo "📊 Access IntelOwl at: http://localhost:80"
echo ""
echo "📝 Create admin user:"
echo "   cd $INTELOWL_DIR"
echo "   docker exec -it intelowl_uwsgi python manage.py createsuperuser"
echo ""
echo "📚 Documentation: https://intelowl.readthedocs.io/"
echo ""
