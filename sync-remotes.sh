#!/bin/bash
# Mirror sync between GitHub (primary) and Local Server (mirror)

set -e

echo "🔄 Starting mirror synchronization..."
echo ""

# Fetch from GitHub (primary source)
echo "📥 Fetching from GitHub (origin)..."
git fetch origin

# Fetch from local server (mirror)
echo "📥 Fetching from local server (mirror)..."
git fetch local

# Show status
echo ""
echo "✅ Sync complete!"
echo ""
echo "Current branch: $(git rev-parse --abbrev-ref HEAD)"
echo ""
echo "Branch status:"
git branch -v

echo ""
echo "📊 Remotes:"
git remote -v
