#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Scan for security vulnerabilities in Go dependencies
#
# Usage: ./scan-vulnerabilities.sh

set -euo pipefail

# shellcheck source=.gitpod/scripts/common.sh
source "$(dirname "$0")/common.sh"

# Change to repository root
cd "$(dirname "$0")/../.."

verifyRepoRoot || exit 1

echo "🔒 Scanning for security vulnerabilities..."
echo ""

# Check if govulncheck is available
if ! requireCommand govulncheck "go install golang.org/x/vuln/cmd/govulncheck@latest"; then
    echo ""
    echo "💡 Alternative: Use 'make scan' if available"
    exit 1
fi

echo "Running govulncheck..."
echo ""

# Run govulncheck
if govulncheck ./...; then
    echo ""
    success "No known vulnerabilities found"
    exit 0
else
    EXIT_CODE=$?
    echo ""
    echo "❌ Vulnerabilities detected"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Review the vulnerabilities above"
    echo "   2. Update affected dependencies"
    echo "   3. Run: go mod tidy && go mod vendor"
    echo "   4. Re-scan: $0"
    echo ""
    echo "💡 For more details: govulncheck -show verbose ./..."
    exit "$EXIT_CODE"
fi
