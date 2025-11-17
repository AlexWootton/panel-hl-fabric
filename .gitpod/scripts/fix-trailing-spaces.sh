#!/bin/bash
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Remove trailing spaces from source files
#
# Usage: ./fix-trailing-spaces.sh [--check-only]

set -euo pipefail

CHECK_ONLY=false
if [ "${1:-}" = "--check-only" ]; then
    CHECK_ONLY=true
fi

# Change to repository root
cd "$(dirname "$0")/../.."

echo "Checking for trailing spaces..."
echo ""

# Find files with trailing spaces
FILES_WITH_TRAILING=()

while IFS= read -r file; do
    if grep -q '[[:space:]]$' "$file" 2>/dev/null; then
        FILES_WITH_TRAILING+=("$file")
    fi
done < <(find . \( -name "*.go" -o -name "*.sh" -o -name "*.md" -o -name "*.yaml" -o -name "*.yml" \) \
    -not -path "./vendor/*" \
    -not -path "./.git/*" \
    -not -path "./build/*" \
    -type f)

if [ ${#FILES_WITH_TRAILING[@]} -eq 0 ]; then
    echo "No trailing spaces found"
    exit 0
fi

echo "Found ${#FILES_WITH_TRAILING[@]} file(s) with trailing spaces"
echo ""

if [ "$CHECK_ONLY" = true ]; then
    echo "Files with trailing spaces:"
    for file in "${FILES_WITH_TRAILING[@]}"; do
        echo "   - $file"
    done
    echo ""
    echo "Run without --check-only to auto-fix"
    exit 1
fi

echo "Removing trailing spaces..."
echo ""

FIXED_COUNT=0
for file in "${FILES_WITH_TRAILING[@]}"; do
    # Remove trailing spaces
    sed -i 's/[[:space:]]*$//' "$file"
    echo "   Fixed: $file"
    ((FIXED_COUNT++))
done

echo ""
echo "Removed trailing spaces from $FIXED_COUNT file(s)"
echo ""
echo "Next steps:"
echo "   1. Review changes: git diff"
echo "   2. Run checks: make trailing-spaces"
echo "   3. Commit: git commit -am 'chore: remove trailing spaces'"
