#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Add missing SPDX license headers to source files
#
# Usage: ./fix-license-headers.sh [--check-only]

set -euo pipefail

# shellcheck source=.gitpod/scripts/common.sh
source "$(dirname "$0")/common.sh"

CHECK_ONLY=false
if [[ "${1:-}" == "--check-only" ]]; then
    CHECK_ONLY=true
fi

# Change to repository root
cd "$(dirname "$0")/../.."

verifyRepoRoot || exit 1

echo "🔍 Checking for missing license headers..."
echo ""

# License headers
GO_HEADER="// SPDX-License-Identifier: Apache-2.0"
SCRIPT_HEADER="# SPDX-License-Identifier: Apache-2.0"

# Find files without license headers
MISSING_FILES=()

# Check Go files
while IFS= read -r file; do
    if ! head -n 5 "$file" | grep -q "SPDX-License-Identifier: Apache-2.0"; then
        MISSING_FILES+=("$file")
    fi
done < <(find . -name "*.go" \
    -not -path "./vendor/*" \
    -not -path "./.git/*" \
    -not -path "./build/*" \
    -type f)

# Check shell scripts
while IFS= read -r file; do
    if ! head -n 5 "$file" | grep -q "SPDX-License-Identifier: Apache-2.0"; then
        MISSING_FILES+=("$file")
    fi
done < <(find . -name "*.sh" \
    -not -path "./vendor/*" \
    -not -path "./.git/*" \
    -not -path "./build/*" \
    -type f)

if [ ${#MISSING_FILES[@]} -eq 0 ]; then
    echo "✅ All files have license headers"
    exit 0
fi

echo "⚠️  Found ${#MISSING_FILES[@]} file(s) without license headers"
echo ""

if [ "$CHECK_ONLY" = true ]; then
    echo "Files missing license headers:"
    for file in "${MISSING_FILES[@]}"; do
        echo "   - $file"
    done
    echo ""
    echo "Run without --check-only to auto-fix"
    exit 1
fi

echo "🔧 Adding license headers..."
echo ""

FIXED_COUNT=0
for file in "${MISSING_FILES[@]}"; do
    # Determine file type and header
    if [[ "$file" == *.go ]]; then
        HEADER="$GO_HEADER"
        # Check if file starts with package or comment
        if head -n 1 "$file" | grep -q "^package\|^//"; then
            # Add header at the beginning
            echo -e "$HEADER\n" | cat - "$file" > "$file.tmp" && mv "$file.tmp" "$file"
            echo "   ✅ Fixed: $file"
            ((FIXED_COUNT++))
        fi
    elif [[ "$file" == *.sh ]]; then
        HEADER="$SCRIPT_HEADER"
        # Check if file starts with shebang
        if head -n 1 "$file" | grep -q "^#!/"; then
            # Add header after shebang
            {
                head -n 1 "$file"
                echo "$HEADER"
                tail -n +2 "$file"
            } > "$file.tmp" && mv "$file.tmp" "$file"
            echo "   ✅ Fixed: $file"
            ((FIXED_COUNT++))
        else
            # Add header at the beginning
            echo -e "$HEADER\n" | cat - "$file" > "$file.tmp" && mv "$file.tmp" "$file"
            echo "   ✅ Fixed: $file"
            ((FIXED_COUNT++))
        fi
    fi
done

echo ""
echo "✅ Added license headers to $FIXED_COUNT file(s)"
echo ""
echo "📋 Next steps:"
echo "   1. Review changes: git diff"
echo "   2. Run checks: make license"
echo "   3. Commit: git commit -am 'chore: add missing SPDX license headers'"
