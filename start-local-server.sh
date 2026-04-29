#!/bin/bash
# Quick start script for local git mirror server

set -e

echo "🚀 Starting Local Git Mirror Server..."
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not in PATH"
    exit 1
fi

echo "✅ Docker found: $(docker --version)"
echo ""

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "⚠️  docker-compose not found, trying 'docker compose'..."
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

# Build and start
echo "🔨 Building Docker image..."
$COMPOSE_CMD build

echo ""
echo "🌐 Starting container..."
$COMPOSE_CMD up -d

echo ""
echo "⏳ Waiting for server to initialize..."
sleep 5

# Check if running
if $COMPOSE_CMD ps | grep -q "pimpl-git-mirror"; then
    echo "✅ Container is running"
else
    echo "❌ Container failed to start"
    $COMPOSE_CMD logs pimpl-git-mirror
    exit 1
fi

echo ""
echo "🧪 Testing server..."
if curl -s http://localhost:45139/ > /dev/null; then
    echo "✅ Server is responding on port 45139"
else
    echo "⚠️  Server not responding yet (still initializing)"
    echo "   Check status with: docker logs pimpl-git-mirror"
fi

echo ""
echo "📋 Server Information:"
echo "   URL: http://127.0.0.1:45139"
echo "   Git clone: http://127.0.0.1:45139/git/pimpl.git"
echo "   Status: docker-compose ps"
echo "   Logs: docker logs -f pimpl-git-mirror"
echo ""
echo "🎉 Local server started! Next steps:"
echo "   1. Wait 1-2 minutes for initial GitHub sync"
echo "   2. Run: ./sync-remotes.sh"
echo "   3. Check status with git commands"
echo ""
