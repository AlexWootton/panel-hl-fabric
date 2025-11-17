#!/bin/bash
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Detect and fix typos in comments and documentation
#
# Usage: ./fix-typos.sh [--check-only]

set -euo pipefail

CHECK_ONLY=false
if [ "${1:-}" = "--check-only" ]; then
    CHECK_ONLY=true
fi

# Change to repository root
cd "$(dirname "$0")/../.."

echo "Checking for typos..."
echo ""

# Check if misspell is available
if ! command -v misspell &> /dev/null; then
    echo "Error: misspell tool not found"
    echo "   Install with: go install github.com/client9/misspell/cmd/misspell@latest"
    exit 1
fi

# Run misspell check
TYPOS_FOUND=false
if ! make spelling 2>&1 | tee /tmp/spelling-check.log; then
    TYPOS_FOUND=true
fi

if [ "$TYPOS_FOUND" = false ]; then
    echo "No typos found"
    exit 0
fi

if [ "$CHECK_ONLY" = true ]; then
    echo ""
    echo "Typos found (check-only mode, not fixing)"
    echo "   Run without --check-only to auto-fix"
    exit 1
fi

echo ""
echo "Attempting to fix typos..."
echo ""

# Auto-fix typos in Go files, Markdown, and reStructuredText
find . -type f \( -name "*.go" -o -name "*.md" -o -name "*.rst" \) \
    -not -path "./vendor/*" \
    -not -path "./.git/*" \
    -not -path "./build/*" \
    -exec misspell -w {} \; 2>/dev/null

# Check if any files were modified
if git diff --quiet; then
    echo "No files were modified by auto-fix"
    echo "   Some typos may require manual correction"
    exit 1
fi

echo "Typos fixed"
echo ""
echo "Files modified:"
git diff --name-only | sed 's/^/   - /'
echo ""
echo "Next steps:"
echo "   1. Review changes: git diff"
echo "   2. Run checks: make spelling"
echo "   3. Commit: git commit -am 'chore: fix typos in comments'"
echo "   4. Create PR with title: 'chore: fix typos in comments'"
