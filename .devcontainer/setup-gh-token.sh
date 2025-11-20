#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Setup GitHub CLI authentication using git credential helper

# Skip if already configured
if gh auth status &>/dev/null; then
    echo "GitHub CLI already authenticated"
    exit 0
fi

# Extract credential file path from git config
CRED_FILE=$(git config --get credential.github.com.helper 2>/dev/null | grep -oP "cat '\K[^']+")

if [ -z "$CRED_FILE" ] || [ ! -f "$CRED_FILE" ]; then
    echo "Warning: Git credential file not found"
    exit 1
fi

# Extract GitHub token from credential file
GITHUB_TOKEN=$(grep "^password=" "$CRED_FILE" 2>/dev/null | cut -d= -f2)

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Warning: Could not extract GitHub token from credential file"
    exit 1
fi

# Set GH_TOKEN for current session
export GH_TOKEN="$GITHUB_TOKEN"

# Add dynamic token extraction to shell profile for future sessions
if ! grep -q "# GitHub CLI authentication" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'EOF'

# GitHub CLI authentication
CRED_FILE=$(git config --get credential.github.com.helper 2>/dev/null | grep -oP "cat '\K[^']+")
if [ -n "$CRED_FILE" ] && [ -f "$CRED_FILE" ]; then
    export GH_TOKEN=$(grep "^password=" "$CRED_FILE" 2>/dev/null | cut -d= -f2)
fi
EOF
fi

echo "GitHub CLI authenticated successfully"
gh auth status 2>&1 | head -5
