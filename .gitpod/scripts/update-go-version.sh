#!/bin/bash
# Copyright IBM Corp All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Update Go version across all Hyperledger Fabric files
#
# Usage: ./update-go-version.sh <version>
# Example: ./update-go-version.sh 1.25.4

set -euo pipefail

NEW_VERSION="${1:-}"

if [ -z "$NEW_VERSION" ]; then
    echo "❌ Error: Go version required"
    echo ""
    echo "Usage: $0 <go-version>"
    echo "Example: $0 1.25.4"
    exit 1
fi

# Validate version format (X.Y.Z)
if ! echo "$NEW_VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "❌ Error: Invalid version format. Expected X.Y.Z (e.g., 1.25.4)"
    exit 1
fi

echo "🔄 Updating Go version to $NEW_VERSION..."
echo ""

# Change to repository root
cd "$(dirname "$0")/../.."

# Check if files exist
REQUIRED_FILES=(
    "go.mod"
    "tools/go.mod"
    "vagrant/golang.sh"
    ".devcontainer/Dockerfile"
    "docs/source/prereqs.md"
    "docs/source/dev-setup/devenv.rst"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Error: Required file not found: $file"
        exit 1
    fi
done

# Update go.mod files
echo "📝 Updating go.mod files..."
sed -i "s/^go [0-9.]*$/go $NEW_VERSION/" go.mod
sed -i "s/^go [0-9.]*$/go $NEW_VERSION/" tools/go.mod

# Update vagrant script
echo "📝 Updating vagrant/golang.sh..."
sed -i "s/GO_VERSION=[0-9.]*/GO_VERSION=$NEW_VERSION/" vagrant/golang.sh

# Update devcontainer
echo "📝 Updating .devcontainer/Dockerfile..."
sed -i "s/ARG GO_VERSION=[0-9.]*/ARG GO_VERSION=$NEW_VERSION/" .devcontainer/Dockerfile

# Update documentation - prereqs.md
echo "📝 Updating docs/source/prereqs.md..."
sed -i "s/go[0-9.]*\\.linux-amd64\\.tar\\.gz/go$NEW_VERSION.linux-amd64.tar.gz/g" docs/source/prereqs.md
sed -i "s/go version go[0-9.]*/go version go$NEW_VERSION/g" docs/source/prereqs.md

# Update documentation - devenv.rst (Homebrew)
echo "📝 Updating docs/source/dev-setup/devenv.rst..."
MAJOR_MINOR=$(echo "$NEW_VERSION" | cut -d. -f1,2)
sed -i "s/brew install go@[0-9.]*/brew install go@$MAJOR_MINOR/" docs/source/dev-setup/devenv.rst

# Run go mod tidy
echo ""
echo "🔧 Running go mod tidy..."
go mod tidy
(cd tools && go mod tidy)

# Run go mod vendor
echo "🔧 Running go mod vendor..."
go mod vendor

# Verify workflows use go-version-file
echo ""
echo "🔍 Verifying GitHub workflows..."
WORKFLOW_ISSUES=()

for workflow in .github/workflows/*.yml; do
    if [ -f "$workflow" ]; then
        # Check if workflow uses Go
        if grep -q "actions/setup-go" "$workflow"; then
            # Check if it uses go-version-file
            if ! grep -q "go-version-file:" "$workflow"; then
                WORKFLOW_ISSUES+=("$workflow: Missing 'go-version-file: go.mod'")
            fi
            # Check for hardcoded Go version
            if grep -q "go-version: [0-9]" "$workflow"; then
                WORKFLOW_ISSUES+=("$workflow: Has hardcoded go-version (should use go-version-file)")
            fi
        fi
    fi
done

if [ ${#WORKFLOW_ISSUES[@]} -gt 0 ]; then
    echo "⚠️  Workflow issues found:"
    for issue in "${WORKFLOW_ISSUES[@]}"; do
        echo "   ⚠️  $issue"
    done
    echo ""
    echo "   Workflows should use: go-version-file: go.mod"
    echo "   This automatically extracts the Go version from go.mod"
else
    echo "   ✅ All workflows use go-version-file: go.mod"
fi

echo ""
echo "✅ Go version updated to $NEW_VERSION"
echo ""
echo "📋 Files updated:"
echo "   - go.mod"
echo "   - tools/go.mod"
echo "   - vagrant/golang.sh"
echo "   - .devcontainer/Dockerfile"
echo "   - docs/source/prereqs.md"
echo "   - docs/source/dev-setup/devenv.rst"
echo ""
echo "📋 Next steps:"
echo "   1. Review changes: git diff"
echo "   2. Run validation: gitpod automations task start validate-changes"
echo "   3. Commit: git commit -am 'bump go to $NEW_VERSION'"
echo "   4. Create PR with title: 'bump go to $NEW_VERSION'"
