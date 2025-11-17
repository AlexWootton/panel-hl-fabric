#!/bin/bash
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Generate changelog entry from recent commits
#
# Usage: ./generate-changelog-entry.sh [since-tag] [until-tag]
#        ./generate-changelog-entry.sh v3.1.3 HEAD

set -euo pipefail

# Change to repository root
cd "$(dirname "$0")/../.."

SINCE_TAG="${1:-}"
UNTIL_TAG="${2:-HEAD}"

if [ -z "$SINCE_TAG" ]; then
    # Get the most recent tag
    SINCE_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    if [ -z "$SINCE_TAG" ]; then
        echo "Error: No tags found. Please specify a starting tag."
        echo ""
        echo "Usage: $0 <since-tag> [until-tag]"
        echo "Example: $0 v3.1.3 HEAD"
        exit 1
    fi
    echo "Generating changelog from $SINCE_TAG to $UNTIL_TAG"
else
    echo "Generating changelog from $SINCE_TAG to $UNTIL_TAG"
fi
echo ""

# Get commits
COMMITS=$(git log --pretty=format:"%h %s" "$SINCE_TAG..$UNTIL_TAG" 2>/dev/null)

if [ -z "$COMMITS" ]; then
    echo "No commits found between $SINCE_TAG and $UNTIL_TAG"
    exit 0
fi

# Categorize commits
FEATURES=()
FIXES=()
CHORES=()
DOCS=()
REFACTORS=()
TESTS=()
DEPS=()
OTHER=()

while IFS= read -r commit; do
    HASH=$(echo "$commit" | awk '{print $1}')
    MSG=$(echo "$commit" | cut -d' ' -f2-)
    
    # Categorize by prefix or content
    if [[ "$MSG" =~ ^feat(\(.*\))?:|^add\ |^Add\  ]]; then
        FEATURES+=("- $MSG (#$HASH)")
    elif [[ "$MSG" =~ ^fix(\(.*\))?:|^Fix\  ]]; then
        FIXES+=("- $MSG (#$HASH)")
    elif [[ "$MSG" =~ ^docs(\(.*\))?:|^Update.*tutorial|^Update.*documentation ]]; then
        DOCS+=("- $MSG (#$HASH)")
    elif [[ "$MSG" =~ ^refactor(\(.*\))?:|^Refactor\  ]]; then
        REFACTORS+=("- $MSG (#$HASH)")
    elif [[ "$MSG" =~ ^test(\(.*\))?:|^Add.*test ]]; then
        TESTS+=("- $MSG (#$HASH)")
    elif [[ "$MSG" =~ ^bump\ |^Bump\ |dependency|dependencies ]]; then
        DEPS+=("- $MSG (#$HASH)")
    elif [[ "$MSG" =~ ^chore(\(.*\))?:|^chore:\ fix\ typo ]]; then
        CHORES+=("- $MSG (#$HASH)")
    else
        OTHER+=("- $MSG (#$HASH)")
    fi
done <<< "$COMMITS"

# Generate changelog
echo "## Changelog"
echo ""

if [ ${#FEATURES[@]} -gt 0 ]; then
    echo "### Features"
    echo ""
    for item in "${FEATURES[@]}"; do
        echo "$item"
    done
    echo ""
fi

if [ ${#FIXES[@]} -gt 0 ]; then
    echo "### Bug Fixes"
    echo ""
    for item in "${FIXES[@]}"; do
        echo "$item"
    done
    echo ""
fi

if [ ${#DOCS[@]} -gt 0 ]; then
    echo "### Documentation"
    echo ""
    for item in "${DOCS[@]}"; do
        echo "$item"
    done
    echo ""
fi

if [ ${#REFACTORS[@]} -gt 0 ]; then
    echo "### Refactoring"
    echo ""
    for item in "${REFACTORS[@]}"; do
        echo "$item"
    done
    echo ""
fi

if [ ${#DEPS[@]} -gt 0 ]; then
    echo "### Dependencies"
    echo ""
    for item in "${DEPS[@]}"; do
        echo "$item"
    done
    echo ""
fi

if [ ${#TESTS[@]} -gt 0 ]; then
    echo "### Tests"
    echo ""
    for item in "${TESTS[@]}"; do
        echo "$item"
    done
    echo ""
fi

if [ ${#CHORES[@]} -gt 0 ]; then
    echo "### Maintenance"
    echo ""
    for item in "${CHORES[@]}"; do
        echo "$item"
    done
    echo ""
fi

if [ ${#OTHER[@]} -gt 0 ]; then
    echo "### Other Changes"
    echo ""
    for item in "${OTHER[@]}"; do
        echo "$item"
    done
    echo ""
fi

# Statistics
TOTAL_COMMITS=$(echo "$COMMITS" | wc -l)
echo "---"
echo ""
echo "Statistics:"
echo "   - Total commits: $TOTAL_COMMITS"
echo "   - Features: ${#FEATURES[@]}"
echo "   - Bug fixes: ${#FIXES[@]}"
echo "   - Documentation: ${#DOCS[@]}"
echo "   - Dependencies: ${#DEPS[@]}"
echo "   - Other: $((${#REFACTORS[@]} + ${#TESTS[@]} + ${#CHORES[@]} + ${#OTHER[@]}))"
echo ""
echo "Tip: Redirect output to a file:"
echo "   $0 $SINCE_TAG $UNTIL_TAG > CHANGELOG_ENTRY.md"
