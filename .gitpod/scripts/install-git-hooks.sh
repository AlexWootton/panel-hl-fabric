#!/bin/bash
# Copyright IBM Corp All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Install git hooks for automated validation
#
# Usage: ./install-git-hooks.sh [--uninstall]

set -euo pipefail

# Change to repository root
cd "$(dirname "$0")/../.."

UNINSTALL=false
if [ "${1:-}" = "--uninstall" ]; then
    UNINSTALL=true
fi

if [ "$UNINSTALL" = true ]; then
    echo "🗑️  Uninstalling git hooks..."
    echo ""
    
    if [ -f ".git/hooks/pre-push" ]; then
        rm .git/hooks/pre-push
        echo "   ✅ Removed pre-push hook"
    fi
    
    if [ -f ".git/hooks/commit-msg" ]; then
        rm .git/hooks/commit-msg
        echo "   ✅ Removed commit-msg hook"
    fi
    
    echo ""
    echo "✅ Git hooks uninstalled"
    exit 0
fi

echo "🔧 Installing git hooks..."
echo ""

# Create pre-push hook
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
#
# Pre-push hook: Validate changes before pushing

echo "🔍 Running pre-push validation..."
echo ""

# Run quick validation (skip unit tests for speed)
if ! QUICK=true .gitpod/scripts/validate-changes.sh --quick; then
    echo ""
    echo "❌ Pre-push validation failed"
    echo ""
    echo "Fix the issues above or use --no-verify to skip validation:"
    echo "   git push --no-verify"
    echo ""
    exit 1
fi

echo ""
echo "✅ Pre-push validation passed"
echo ""
EOF

chmod +x .git/hooks/pre-push
echo "   ✅ Installed pre-push hook"

# Create commit-msg hook
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
#
# Commit-msg hook: Validate commit message format

COMMIT_MSG_FILE="$1"
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Run validation
if ! .gitpod/scripts/validate-commit-message.sh "$COMMIT_MSG" 2>&1 | grep -q "✅"; then
    echo ""
    echo "💡 Tip: You can still commit with --no-verify if needed"
    exit 1
fi
EOF

chmod +x .git/hooks/commit-msg
echo "   ✅ Installed commit-msg hook"

echo ""
echo "✅ Git hooks installed successfully"
echo ""
echo "📋 Installed hooks:"
echo "   - pre-push: Validates changes before pushing"
echo "   - commit-msg: Validates commit message format"
echo ""
echo "💡 To bypass hooks when needed:"
echo "   git commit --no-verify"
echo "   git push --no-verify"
echo ""
echo "💡 To uninstall hooks:"
echo "   $0 --uninstall"
