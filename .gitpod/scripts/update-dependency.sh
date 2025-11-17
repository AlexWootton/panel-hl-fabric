#!/bin/bash
# Copyright IBM Corp All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Update a Go dependency to a specific version
#
# Usage: ./update-dependency.sh <dependency> <version>
# Example: ./update-dependency.sh github.com/consensys/gnark-crypto v0.19.2

set -euo pipefail

DEPENDENCY="${1:-}"
VERSION="${2:-}"

# Interactive mode if no arguments provided
if [ -z "$DEPENDENCY" ] || [ -z "$VERSION" ]; then
    # Check if running interactively
    if [ -t 0 ]; then
        echo "🔄 Update Go Dependency"
        echo ""
        echo "Common dependencies:"
        echo "  1. github.com/consensys/gnark-crypto"
        echo "  2. github.com/docker/docker"
        echo "  3. golang.org/x/crypto"
        echo "  4. golang.org/x/net"
        echo "  5. Other (specify)"
        echo ""
        
        if [ -z "$DEPENDENCY" ]; then
            read -p "Enter dependency path: " DEPENDENCY
        fi
        
        if [ -z "$VERSION" ]; then
            # Show current version if available
            CURRENT=$(go list -m -json "$DEPENDENCY" 2>/dev/null | jq -r '.Version' 2>/dev/null || echo "not found")
            echo ""
            echo "Current version: $CURRENT"
            read -p "Enter new version (e.g., v0.19.2): " VERSION
        fi
        
        if [ -z "$DEPENDENCY" ] || [ -z "$VERSION" ]; then
            echo "❌ Error: Both dependency and version required"
            exit 1
        fi
    else
        echo "❌ Error: Dependency and version required"
        echo ""
        echo "Usage: $0 <dependency> <version>"
        echo "Example: $0 github.com/consensys/gnark-crypto v0.19.2"
        echo ""
        echo "Or run interactively: $0"
        exit 1
    fi
fi

# Ensure version starts with 'v' for proper semver
if [[ ! "$VERSION" =~ ^v ]]; then
    VERSION="v$VERSION"
fi

echo "🔄 Updating $DEPENDENCY to $VERSION..."
echo ""

# Change to repository root
cd "$(dirname "$0")/../.."

# Update dependency
echo "📦 Running go get..."
if ! go get "$DEPENDENCY@$VERSION"; then
    echo "❌ Error: Failed to update dependency"
    echo "   Check that the dependency and version exist"
    exit 1
fi

# Run go mod tidy
echo "🔧 Running go mod tidy..."
go mod tidy

# Check if tools/go.mod needs update
if grep -q "$DEPENDENCY" tools/go.mod 2>/dev/null; then
    echo "🔧 Updating tools/go.mod..."
    (cd tools && go get "$DEPENDENCY@$VERSION" && go mod tidy)
fi

# Run go mod vendor
echo "🔧 Running go mod vendor..."
go mod vendor

echo ""
echo "✅ Dependency updated: $DEPENDENCY@$VERSION"
echo ""
echo "📋 Files updated:"
echo "   - go.mod"
echo "   - go.sum"
echo "   - vendor/modules.txt"
echo "   - vendor/$DEPENDENCY/ (all files)"

# Show what changed
VENDOR_DIR=$(echo "$DEPENDENCY" | cut -d'/' -f1-3)
if [ -d "vendor/$VENDOR_DIR" ]; then
    echo ""
    echo "📊 Vendor changes:"
    git diff --stat vendor/"$VENDOR_DIR" 2>/dev/null || echo "   (new dependency)"
fi

echo ""
echo "📋 Next steps:"
echo "   1. Review changes: git diff"
echo "   2. Run checks: make basic-checks"
echo "   3. Run tests: make verify"
echo "   4. Commit: git commit -am 'bump $DEPENDENCY to $VERSION'"
echo "   5. Create PR with title: 'bump $DEPENDENCY to $VERSION'"
echo ""
echo "💡 Tip: Use 'gitpod automations task start validate-changes' to run checks"
