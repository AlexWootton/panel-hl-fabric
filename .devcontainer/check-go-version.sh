#!/bin/bash
# Check if the running Go version matches go.mod

set -e

# Get version from go.mod
EXPECTED_VERSION=$(grep "^go " go.mod | awk '{print $2}')

# Get running version
CURRENT_VERSION=$(go version | awk '{print $3}' | sed 's/go//')

echo "Expected Go version (from go.mod): ${EXPECTED_VERSION}"
echo "Current Go version (in container): ${CURRENT_VERSION}"

if [ "$EXPECTED_VERSION" = "$CURRENT_VERSION" ]; then
    echo "✅ Go version matches!"
    exit 0
else
    echo ""
    echo "⚠️  Go version mismatch!"
    echo ""
    echo "To update the container to Go ${EXPECTED_VERSION}:"
    echo "  gitpod environment devcontainer rebuild"
    echo ""
    echo "This will rebuild the container with the Go version from go.mod."
    echo "See .devcontainer/README.md for more details."
    exit 1
fi
