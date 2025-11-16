#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Cleanup script for integration test artifacts
#
# Usage: cleanup-test-artifacts.sh <exit_code> <test_name>
#
# Arguments:
#   exit_code  - Exit code from the test run
#   test_name  - Name of the test suite (for reporting)
#
# This script:
#   1. Removes test binaries (*.test files)
#   2. Removes chaincode test data
#   3. Runs go mod tidy to fix go.sum
#   4. Reports success/failure with test name
#   5. Exits with the original test exit code

set -euo pipefail

# Check arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <exit_code> <test_name>"
    echo "Example: $0 0 'Consensus'"
    exit 1
fi

EXIT_CODE=$1
TEST_NAME=$2

# Cleanup test artifacts
echo "Cleaning up test artifacts..."

# Remove test binaries
TEST_COUNT=$(find integration/ -name "*.test" -type f 2>/dev/null | wc -l)
if [ "$TEST_COUNT" -gt 0 ]; then
    find integration/ -name "*.test" -type f -delete 2>/dev/null || true
    echo "  Removed $TEST_COUNT test binaries"
fi

# Remove chaincode test data
if [ -d "core/chaincode/platforms/golang/testdata/pkg/" ]; then
    find core/chaincode/platforms/golang/testdata/pkg/ -type f -delete 2>/dev/null || true
    echo "  Cleaned chaincode test data"
fi

# Fix go.sum if modified by tests
go mod tidy 2>/dev/null || true
echo "  Fixed go.sum"

# Report status
echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "✅ ${TEST_NAME} tests complete and artifacts cleaned"
    exit 0
else
    echo "❌ ${TEST_NAME} tests failed (exit code: $EXIT_CODE) but artifacts cleaned"
    exit "$EXIT_CODE"
fi
