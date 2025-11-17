#!/bin/bash
# Copyright IBM Corp All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Validate commit message format
#
# Usage: ./validate-commit-message.sh [commit-message]
#        ./validate-commit-message.sh  (validates last commit)

set -euo pipefail

# Change to repository root
cd "$(dirname "$0")/../.."

# Get commit message
if [ -n "${1:-}" ]; then
    COMMIT_MSG="$1"
else
    COMMIT_MSG=$(git log -1 --pretty=%B)
fi

echo "🔍 Validating commit message..."
echo ""
echo "Message:"
echo "---"
echo "$COMMIT_MSG"
echo "---"
echo ""

# Extract first line (subject)
SUBJECT=$(echo "$COMMIT_MSG" | head -n 1)

# Validation rules
ERRORS=()
WARNINGS=()

# Rule 1: Subject line should not be empty
if [ -z "$SUBJECT" ]; then
    ERRORS+=("Subject line is empty")
fi

# Rule 2: Subject line should be <= 72 characters (warning if > 50)
SUBJECT_LENGTH=${#SUBJECT}
if [ "$SUBJECT_LENGTH" -gt 72 ]; then
    ERRORS+=("Subject line too long ($SUBJECT_LENGTH chars, max 72)")
elif [ "$SUBJECT_LENGTH" -gt 50 ]; then
    WARNINGS+=("Subject line is long ($SUBJECT_LENGTH chars, recommended max 50)")
fi

# Rule 3: Subject should not end with a period
if [[ "$SUBJECT" =~ \.$ ]]; then
    WARNINGS+=("Subject line should not end with a period")
fi

# Rule 4: Check for common patterns (informational)
CONVENTIONAL_COMMIT=false
if [[ "$SUBJECT" =~ ^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\(.+\))?:\ .+ ]]; then
    CONVENTIONAL_COMMIT=true
fi

if [[ "$SUBJECT" =~ ^(bump|add|remove|update|fix|improve|enhance|refactor)\ .+ ]]; then
    # Common Fabric patterns - acceptable
    :
elif [ "$CONVENTIONAL_COMMIT" = false ]; then
    WARNINGS+=("Consider using conventional commit format: type(scope): description")
fi

# Rule 5: Check for sign-off (Fabric requirement)
if ! echo "$COMMIT_MSG" | grep -q "^Signed-off-by:"; then
    WARNINGS+=("Missing Signed-off-by line (required for Fabric contributions)")
fi

# Rule 6: Check for Co-authored-by if using Ona
if echo "$COMMIT_MSG" | grep -qi "ona\|automation\|script"; then
    if ! echo "$COMMIT_MSG" | grep -q "^Co-authored-by: Ona"; then
        WARNINGS+=("Consider adding: Co-authored-by: Ona <no-reply@ona.com>")
    fi
fi

# Report results
if [ ${#ERRORS[@]} -gt 0 ]; then
    echo "❌ Commit message validation failed:"
    echo ""
    for error in "${ERRORS[@]}"; do
        echo "   ❌ $error"
    done
    echo ""
    exit 1
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo "⚠️  Commit message has warnings:"
    echo ""
    for warning in "${WARNINGS[@]}"; do
        echo "   ⚠️  $warning"
    done
    echo ""
fi

if [ ${#WARNINGS[@]} -eq 0 ]; then
    echo "✅ Commit message is valid"
    if [ "$CONVENTIONAL_COMMIT" = true ]; then
        echo "   ✅ Uses conventional commit format"
    fi
fi

echo ""
echo "📚 Commit message guidelines:"
echo "   - Keep subject line under 50 characters (max 72)"
echo "   - Use imperative mood (\"add feature\" not \"added feature\")"
echo "   - Don't end subject with a period"
echo "   - Separate subject from body with blank line"
echo "   - Include Signed-off-by line for contributions"
echo ""
echo "📚 Common Fabric patterns:"
echo "   - bump <dependency> to <version>"
echo "   - add <feature>"
echo "   - fix <issue>"
echo "   - chore: <maintenance task>"
echo "   - docs: <documentation update>"
