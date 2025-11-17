#!/bin/bash
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Validate changes before committing
# Wraps existing make targets with additional checks
#
# Usage: ./validate-changes.sh [--quick]

set -euo pipefail

QUICK_MODE=false
if [ "${1:-}" = "--quick" ]; then
    QUICK_MODE=true
fi

# Change to repository root
cd "$(dirname "$0")/../.."

echo "Validating changes..."
echo ""

# Track failures
FAILURES=()

# Check 1: go.mod is tidy
echo "Checking go.mod is tidy..."
if ! (go mod tidy && git diff --exit-code go.mod go.sum); then
    FAILURES+=("go.mod is not tidy - run 'go mod tidy'")
else
    echo "   go.mod is tidy"
fi
echo ""

# Check 2: vendor directory is in sync
echo "Checking vendor directory..."
if ! (go mod vendor && git diff --exit-code vendor/); then
    FAILURES+=("vendor/ is out of sync - run 'go mod vendor'")
else
    echo "   vendor/ is in sync"
fi
echo ""

if [ "$QUICK_MODE" = true ]; then
    # Quick mode: Only run linter (no tests)
    echo "Running linter checks..."
    echo ""
    if ! make linter; then
        FAILURES+=("linter failed - see output above")
        echo ""
        echo "Fix suggestions:"
        echo "   - License headers: .gitpod/scripts/fix-license-headers.sh"
        echo "   - Typos: gitpod automations task start fix-typos"
        echo "   - Trailing spaces: .gitpod/scripts/fix-trailing-spaces.sh"
    else
        echo ""
        echo "   Linter checks passed"
    fi
    echo ""
else
    # Full mode: Use make basic-checks (comprehensive checks)
    echo "Running basic checks (make basic-checks)..."
    echo ""
    if ! make basic-checks; then
        FAILURES+=("basic-checks failed - see output above")
        echo ""
        echo "Fix suggestions:"
        echo "   - License headers: .gitpod/scripts/fix-license-headers.sh"
        echo "   - Typos: gitpod automations task start fix-typos"
        echo "   - Trailing spaces: .gitpod/scripts/fix-trailing-spaces.sh"
    else
        echo ""
        echo "   Basic checks passed"
    fi
    echo ""
    
    # Run unit tests for changed packages
    echo "Running unit tests for changed packages (make verify)..."
    echo ""
    if ! make verify; then
        FAILURES+=("unit tests failed - run 'make verify' for details")
    else
        echo ""
        echo "   Unit tests passed"
    fi
    echo ""
fi

# Additional check: Commit message validation (not in make targets)
if git diff --cached --quiet; then
    echo "No staged changes, skipping commit message check"
    echo ""
else
    echo "Checking last commit message..."
    if .gitpod/scripts/validate-commit-message.sh 2>&1 | grep -q "❌"; then
        FAILURES+=("commit message validation failed - see output above")
    else
        echo "   Commit message is valid"
    fi
    echo ""
fi

# Summary
if [ ${#FAILURES[@]} -eq 0 ]; then
    echo "All validation checks passed!"
    echo ""
    if [ "$QUICK_MODE" = true ]; then
        echo "Run without --quick to include unit tests"
    fi
    exit 0
else
    echo "Validation failed with ${#FAILURES[@]} error(s):"
    echo ""
    for failure in "${FAILURES[@]}"; do
        echo "   $failure"
    done
    echo ""
    exit 1
fi
