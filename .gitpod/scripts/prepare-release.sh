#!/bin/bash
# Copyright IBM Corp All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Prepare release checklist and validation
#
# Usage: ./prepare-release.sh <version>
# Example: ./prepare-release.sh 3.1.4

set -euo pipefail

VERSION="${1:-}"

# Interactive mode if no version provided
if [ -z "$VERSION" ]; then
    # Check if running interactively
    if [ -t 0 ]; then
        echo "🚀 Prepare Release"
        echo ""
        
        # Show current version from Makefile
        CURRENT=$(grep "FABRIC_VER ?=" Makefile | cut -d'=' -f2 | tr -d ' ' || echo "unknown")
        echo "Current version in Makefile: $CURRENT"
        
        # Show last tag
        LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")
        echo "Last git tag: $LAST_TAG"
        echo ""
        
        read -p "Enter new version (e.g., 3.1.4): " VERSION
        
        if [ -z "$VERSION" ]; then
            echo "❌ Error: No version provided"
            exit 1
        fi
    else
        echo "❌ Error: Version required"
        echo ""
        echo "Usage: $0 <version>"
        echo "Example: $0 3.1.4"
        echo ""
        echo "Or run interactively: $0"
        exit 1
    fi
fi

# Validate version format (X.Y.Z)
if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "❌ Error: Invalid version format. Expected X.Y.Z (e.g., 3.1.4)"
    exit 1
fi

# Change to repository root
cd "$(dirname "$0")/../.."

echo "🚀 Preparing release v$VERSION"
echo ""

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "📋 Current branch: $CURRENT_BRANCH"
echo ""

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  Warning: You have uncommitted changes"
    echo "   Commit or stash them before proceeding"
    echo ""
fi

# Generate release checklist
echo "📋 Release Checklist for v$VERSION"
echo "=================================="
echo ""
echo "Pre-Release Validation:"
echo "  [ ] All CI checks passing on main/release branch"
echo "  [ ] All integration tests passing"
echo "  [ ] No known critical bugs"
echo "  [ ] Security scan completed"
echo ""
echo "Version Updates:"
echo "  [ ] Update version in Makefile (FABRIC_VER)"
echo "  [ ] Update version in common/metadata/metadata.go"
echo "  [ ] Update version in docs/source/conf.py"
echo "  [ ] Update CHANGELOG.md with release notes"
echo ""
echo "Documentation:"
echo "  [ ] Update docs/source/whatsnew.rst"
echo "  [ ] Update docs/source/releases.rst"
echo "  [ ] Review and update README.md if needed"
echo "  [ ] Check all documentation links"
echo ""
echo "Testing:"
echo "  [ ] Run full test suite: make unit-test"
echo "  [ ] Run integration tests: make integration-test"
echo "  [ ] Test Docker image builds: make docker"
echo "  [ ] Test release binaries: make release"
echo ""
echo "Release Process:"
echo "  [ ] Create release branch (if major/minor)"
echo "  [ ] Tag release: git tag -s v$VERSION -m 'Release v$VERSION'"
echo "  [ ] Push tag: git push origin v$VERSION"
echo "  [ ] Create GitHub release with notes"
echo "  [ ] Publish Docker images"
echo "  [ ] Update documentation site"
echo ""
echo "Post-Release:"
echo "  [ ] Announce release on mailing list"
echo "  [ ] Update Hyperledger wiki"
echo "  [ ] Close milestone on GitHub"
echo "  [ ] Update version for next development cycle"
echo ""

# Check if version exists in Makefile
if grep -q "FABRIC_VER ?= $VERSION" Makefile; then
    echo "✅ Version $VERSION found in Makefile"
else
    echo "⚠️  Version $VERSION not found in Makefile"
    echo "   Current version: $(grep 'FABRIC_VER ?=' Makefile | cut -d'=' -f2 | tr -d ' ')"
    echo ""
    echo "   Update with: sed -i 's/FABRIC_VER ?= .*/FABRIC_VER ?= $VERSION/' Makefile"
fi
echo ""

# Check for existing tag
if git tag | grep -q "^v$VERSION$"; then
    echo "⚠️  Tag v$VERSION already exists"
    echo "   Use a different version or delete the tag"
else
    echo "✅ Tag v$VERSION is available"
fi
echo ""

echo "📋 Next Steps:"
echo "   1. Complete the checklist above"
echo "   2. Run validation: make unit-test && make integration-test"
echo "   3. Create release PR or tag"
echo "   4. Follow release process documentation"
echo ""
echo "📚 Documentation:"
echo "   - RELEASING.md - Release process guide"
echo "   - CHANGELOG.md - Release notes template"
