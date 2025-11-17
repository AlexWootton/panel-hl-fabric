#!/bin/bash
# Copyright IBM Corp All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Validate changes before committing
# Runs the same checks as CI to catch issues early
#
# Usage: ./validate-changes.sh [--quick]

set -euo pipefail

QUICK_MODE=false
if [ "${1:-}" = "--quick" ]; then
    QUICK_MODE=true
fi

# Change to repository root
cd "$(dirname "$0")/../.."

echo "🔍 Validating changes..."
echo ""

# Track failures
FAILURES=()

# Check 1: go.mod is tidy
echo "📋 Checking go.mod is tidy..."
if ! (go mod tidy && git diff --exit-code go.mod go.sum); then
    FAILURES+=("go.mod is not tidy - run 'go mod tidy'")
else
    echo "   ✅ go.mod is tidy"
fi
echo ""

# Check 2: vendor directory is in sync
echo "📋 Checking vendor directory..."
if ! (go mod vendor && git diff --exit-code vendor/); then
    FAILURES+=("vendor/ is out of sync - run 'go mod vendor'")
else
    echo "   ✅ vendor/ is in sync"
fi
echo ""

# Check 3: License headers
echo "📋 Checking license headers..."
if ! make license; then
    FAILURES+=("license check failed - run '.gitpod/scripts/fix-license-headers.sh' to fix")
else
    echo "   ✅ License headers present"
fi
echo ""

# Check 4: Spelling
echo "📋 Checking spelling..."
if ! make spelling; then
    FAILURES+=("spelling check failed - run 'gitpod automations task start fix-typos' to fix")
else
    echo "   ✅ No spelling errors"
fi
echo ""

# Check 5: Trailing spaces
echo "📋 Checking trailing spaces..."
if ! make trailing-spaces; then
    FAILURES+=("trailing spaces found - run '.gitpod/scripts/fix-trailing-spaces.sh' to fix")
else
    echo "   ✅ No trailing spaces"
fi
echo ""

# Check 6: Linting
echo "📋 Running linter..."
if ! make linter; then
    FAILURES+=("linter failed - see output above")
else
    echo "   ✅ Linting passed"
fi
echo ""

# Check 7: Unit tests (skip in quick mode)
if [ "$QUICK_MODE" = false ]; then
    echo "📋 Running unit tests for changed packages..."
    if ! make verify; then
        FAILURES+=("unit tests failed - run 'make verify' for details")
    else
        echo "   ✅ Unit tests passed"
    fi
    echo ""
else
    echo "⏭️  Skipping unit tests (quick mode)"
    echo ""
fi

# Check 8: Commit message (if there are staged changes)
if git diff --cached --quiet; then
    echo "⏭️  No staged changes, skipping commit message check"
    echo ""
else
    echo "📋 Checking last commit message..."
    if .gitpod/scripts/validate-commit-message.sh 2>&1 | grep -q "❌"; then
        FAILURES+=("commit message validation failed - see output above")
    else
        echo "   ✅ Commit message is valid"
    fi
    echo ""
fi

# Summary
if [ ${#FAILURES[@]} -eq 0 ]; then
    echo "✅ All validation checks passed!"
    echo ""
    if [ "$QUICK_MODE" = true ]; then
        echo "💡 Run without --quick to include unit tests"
    fi
    exit 0
else
    echo "❌ Validation failed with ${#FAILURES[@]} error(s):"
    echo ""
    for failure in "${FAILURES[@]}"; do
        echo "   ❌ $failure"
    done
    echo ""
    exit 1
fi
