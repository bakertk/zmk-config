#!/bin/bash
# Setup Git Hooks for ZMK Config
# 
# This script installs the pre-commit hook that automatically
# syncs generic keymaps before each commit

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔧 Setting up Git hooks...${NC}"
echo ""

# Get the repo root
REPO_ROOT=$(git rev-parse --show-toplevel)
HOOKS_DIR="$REPO_ROOT/.git/hooks"
PRE_COMMIT_HOOK="$HOOKS_DIR/pre-commit"
SOURCE_HOOK="$REPO_ROOT/scripts/pre-commit"

# Check if source hook exists
if [ ! -f "$SOURCE_HOOK" ]; then
    echo "❌ Error: scripts/pre-commit not found"
    exit 1
fi

# Backup existing pre-commit hook if it exists
if [ -f "$PRE_COMMIT_HOOK" ]; then
    echo "📦 Backing up existing pre-commit hook..."
    mv "$PRE_COMMIT_HOOK" "$PRE_COMMIT_HOOK.backup"
    echo "   Saved to: $PRE_COMMIT_HOOK.backup"
    echo ""
fi

# Create symlink to our hook
echo "🔗 Installing pre-commit hook..."
ln -sf "$SOURCE_HOOK" "$PRE_COMMIT_HOOK"
chmod +x "$PRE_COMMIT_HOOK"

echo ""
echo -e "${GREEN}✓ Git hooks installed successfully!${NC}"
echo ""
echo "📋 What this does:"
echo "   • Before each commit, automatically syncs:"
echo "     - generic_3x5.keymap → generic_3x6.keymap"
echo "     - Both keymaps → .dtsi files"
echo "   • Adds synced files to your commit"
echo "   • Ensures all boards stay in sync"
echo ""
echo "💡 To disable temporarily:"
echo "   git commit --no-verify"
echo ""
echo "🗑️  To uninstall:"
echo "   rm $PRE_COMMIT_HOOK"
echo ""
