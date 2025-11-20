#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Check for vendored dependencies that are no longer used
#
# Usage: ./check-unused-deps.sh

set -euo pipefail

# shellcheck source=.ona/scripts/common.sh
source "$(dirname "$0")/common.sh"

# Change to repository root
cd "$(dirname "$0")/../.."

verifyRepoRoot || exit 1

echo "Checking for unused vendored dependencies..."
echo ""
echo "This runs: make check-deps"
echo ""

# Run make check-deps
if make check-deps; then
    success "No unused dependencies found"
    exit 0
else
    echo ""
    echo "Unused dependencies detected"
    echo ""
    echo "Next steps:"
    echo "   1. Review the unused dependencies above"
    echo "   2. Remove them from go.mod if truly unused"
    echo "   3. Run: go mod tidy && go mod vendor"
    echo "   4. Commit changes"
    exit 1
fi
