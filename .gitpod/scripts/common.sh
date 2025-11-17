#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Common functions for Ona automation scripts

# Verify we're in the Fabric repository root
verifyRepoRoot() {
    if [[ ! -f "go.mod" ]] || ! grep -q "module github.com/hyperledger/fabric" go.mod 2>/dev/null; then
        echo "❌ Error: Not in Fabric repository root"
        echo "   Current directory: $(pwd)"
        echo "   Expected: Directory containing go.mod with module github.com/hyperledger/fabric"
        return 1
    fi
    return 0
}

# Check if a command is available
requireCommand() {
    local cmd="$1"
    local install_hint="${2:-}"
    
    if ! command -v "$cmd" &> /dev/null; then
        echo "❌ Error: Required command '$cmd' not found"
        if [[ -n "$install_hint" ]]; then
            echo "   Install with: $install_hint"
        fi
        return 1
    fi
    return 0
}

# Check if running interactively
isInteractive() {
    [[ -t 0 ]]
}

# Print error message and exit
fatal() {
    echo "❌ Error: $*" >&2
    exit 1
}

# Print warning message
warn() {
    echo "⚠️  Warning: $*" >&2
}

# Print info message
info() {
    echo "ℹ️  $*"
}

# Print success message
success() {
    echo "✅ $*"
}
