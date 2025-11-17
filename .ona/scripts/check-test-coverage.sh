#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Generate and display test coverage report
#
# Usage: ./check-test-coverage.sh [--html]

set -euo pipefail

# shellcheck source=.ona/scripts/common.sh
source "$(dirname "$0")/common.sh"

# Change to repository root
cd "$(dirname "$0")/../.."

verifyRepoRoot || exit 1

HTML_MODE=false
if [[ "${1:-}" == "--html" ]]; then
    HTML_MODE=true
fi

echo "Generating test coverage report..."
echo ""

# Generate coverage profile
echo "Running tests with coverage..."
if ! make profile 2>&1 | tail -20; then
    echo ""
    echo "Failed to generate coverage profile"
    exit 1
fi

echo ""
echo "📈 Coverage Summary:"
echo ""

# Display coverage summary
if [[ -f "coverage.txt" ]]; then
    # Calculate total coverage
    TOTAL_COVERAGE=$(go tool cover -func=coverage.txt | grep total | awk '{print $3}')
    echo "   Total Coverage: $TOTAL_COVERAGE"
    echo ""
    
    # Show top 10 packages by coverage
    echo "   Top 10 packages by coverage:"
    go tool cover -func=coverage.txt | grep -v "total:" | sort -k3 -rn | head -10 | \
        awk '{printf "   %s: %s\n", $1, $3}'
    echo ""
    
    # Show bottom 10 packages by coverage
    echo "   Bottom 10 packages by coverage:"
    go tool cover -func=coverage.txt | grep -v "total:" | sort -k3 -n | head -10 | \
        awk '{printf "   %s: %s\n", $1, $3}'
    echo ""
    
    if [[ "$HTML_MODE" == true ]]; then
        echo "Generating HTML report..."
        go tool cover -html=coverage.txt -o coverage.html
        success "HTML report generated: coverage.html"
        echo ""
        echo "Open coverage.html in a browser to view detailed coverage"
    fi
    
    success "Coverage report generated"
else
    echo "Coverage file not found"
    exit 1
fi
