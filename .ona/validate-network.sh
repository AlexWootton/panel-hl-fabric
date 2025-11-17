#!/bin/bash
# Copyright IBM Corp All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# Hyperledger Fabric Test Network Validation Script
#
# PURPOSE: Quick health check for deployed test networks
# This script validates that an EXISTING test network is fully functional.
#
# RELATIONSHIP TO OTHER TESTS:
# - Integration Tests (integration/): Comprehensive CI/CD testing (15-30 min)
#   Use for: Full feature validation, edge cases, CI/CD pipelines
# - Test-Network Scripts (network.sh): Network deployment and setup
#   Use for: Creating and configuring networks
# - This Script: Post-deployment health checking (30-60 sec)
#   Use for: Quick validation, troubleshooting, developer feedback
#
# WHEN TO USE THIS SCRIPT:
# - After deploying the test network
# - Before starting development work
# - When troubleshooting network issues
# - To verify network health during development
# - As part of onboarding/learning workflow
#
# WHEN NOT TO USE THIS SCRIPT:
# - For comprehensive feature testing (use integration tests)
# - For CI/CD validation (use make integration-test)
# - For network deployment (use network.sh)

# Don't exit on error - we want to run all tests
set +e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TESTS_PASSED=0
TESTS_FAILED=0

# Add Fabric binaries to PATH
export PATH=/workspaces/fabric/build/bin:$PATH
export FABRIC_CFG_PATH=/workspaces/fabric/sampleconfig

# Set environment for peer commands
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/workspaces/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/workspaces/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

# Helper functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅ PASS:${NC} $1"
    ((TESTS_PASSED++))
}

print_failure() {
    echo -e "${RED}❌ FAIL:${NC} $1"
    ((TESTS_FAILED++))
}

print_info() {
    echo -e "${BLUE}ℹ INFO:${NC} $1"
}

# Test functions
test_docker_containers() {
    print_test "Checking Docker containers are running"
    
    local required_containers=("peer0.org1.example.com" "peer0.org2.example.com" "orderer.example.com")
    local all_running=true
    
    for container in "${required_containers[@]}"; do
        if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
            print_info "Container $container is running"
        else
            print_failure "Container $container is not running"
            all_running=false
        fi
    done
    
    if [ "$all_running" = true ]; then
        print_success "All required Docker containers are running"
    else
        print_failure "Some Docker containers are missing"
    fi
}

test_channel_exists() {
    print_test "Checking if channel 'mychannel' exists"
    
    local result=$(peer channel list 2>&1)
    if echo "$result" | grep -q "mychannel"; then
        print_success "Channel 'mychannel' exists"
        return 0
    else
        print_failure "Channel 'mychannel' does not exist"
        return 1
    fi
}

test_chaincode_installed() {
    print_test "Checking if chaincode is installed"
    
    local result=$(peer lifecycle chaincode queryinstalled 2>&1)
    if echo "$result" | grep -q "basic"; then
        print_success "Chaincode 'basic' is installed"
        return 0
    else
        print_failure "Chaincode 'basic' is not installed"
        return 1
    fi
}

test_chaincode_committed() {
    print_test "Checking if chaincode is committed to channel"
    
    local result=$(peer lifecycle chaincode querycommitted -C mychannel 2>&1)
    if echo "$result" | grep -q "basic"; then
        print_success "Chaincode 'basic' is committed to mychannel"
        return 0
    else
        print_failure "Chaincode 'basic' is not committed"
        return 1
    fi
}

test_chaincode_invoke() {
    print_test "Testing chaincode invocation (InitLedger)"
    
    cd /workspaces/fabric-samples/test-network
    
    # Initialize the ledger
    if peer chaincode invoke \
        -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls \
        --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" \
        -C mychannel \
        -n basic \
        --peerAddresses localhost:7051 \
        --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" \
        --peerAddresses localhost:9051 \
        --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" \
        -c '{"function":"InitLedger","Args":[]}' \
        --waitForEvent 2>&1 | grep -q "Chaincode invoke successful"; then
        print_success "Chaincode invocation successful (InitLedger)"
    else
        print_failure "Chaincode invocation failed"
    fi
}

test_chaincode_query() {
    print_test "Testing chaincode query (GetAllAssets)"
    
    cd /workspaces/fabric-samples/test-network
    
    # Query all assets
    local result=$(peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}' 2>&1)
    
    if echo "$result" | grep -q "asset1"; then
        print_success "Chaincode query successful (found assets)"
        print_info "Sample asset data retrieved"
    else
        print_failure "Chaincode query failed or no assets found"
    fi
}

test_create_asset() {
    print_test "Testing asset creation (CreateAsset)"
    
    cd /workspaces/fabric-samples/test-network
    
    # Use a timestamp-based asset ID to avoid conflicts
    local asset_id="asset$(date +%s)"
    
    # Create a new asset
    local result=$(peer chaincode invoke \
        -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls \
        --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" \
        -C mychannel \
        -n basic \
        --peerAddresses localhost:7051 \
        --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" \
        --peerAddresses localhost:9051 \
        --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" \
        -c "{\"function\":\"CreateAsset\",\"Args\":[\"${asset_id}\",\"blue\",\"50\",\"TestOwner\",\"1000\"]}" \
        --waitForEvent 2>&1)
    
    if echo "$result" | grep -q "Chaincode invoke successful"; then
        print_success "Asset creation successful (ID: $asset_id)"
        # Store asset ID for next test
        echo "$asset_id" > /tmp/test_asset_id
    else
        print_failure "Asset creation failed"
    fi
}

test_read_asset() {
    print_test "Testing asset read (ReadAsset)"
    
    cd /workspaces/fabric-samples/test-network
    
    # Read the asset we just created
    local asset_id=$(cat /tmp/test_asset_id 2>/dev/null || echo "asset1")
    local result=$(peer chaincode query -C mychannel -n basic -c "{\"Args\":[\"ReadAsset\",\"${asset_id}\"]}" 2>&1)
    
    if echo "$result" | grep -q "TestOwner\|Tom"; then
        print_success "Asset read successful (verified asset: $asset_id)"
    else
        print_failure "Asset read failed"
    fi
    
    # Cleanup temp file
    rm -f /tmp/test_asset_id
}

test_peer_connectivity() {
    print_test "Testing peer connectivity (Org1 and Org2)"
    
    # Test Org1 peer
    if peer channel getinfo -c mychannel 2>&1 | grep -q "Blockchain info"; then
        print_info "Org1 peer is responsive"
    else
        print_failure "Org1 peer is not responsive"
        return
    fi
    
    # Switch to Org2
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/workspaces/fabric-samples/test-network/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/workspaces/fabric-samples/test-network/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
    
    # Test Org2 peer
    if peer channel getinfo -c mychannel 2>&1 | grep -q "Blockchain info"; then
        print_info "Org2 peer is responsive"
        print_success "Both organization peers are responsive"
    else
        print_failure "Org2 peer is not responsive"
    fi
    
    # Switch back to Org1
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/workspaces/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/workspaces/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

test_chaincode_containers() {
    print_test "Checking chaincode containers are running"
    
    local chaincode_containers=$(docker ps --filter "name=dev-peer" --format '{{.Names}}' | wc -l)
    
    if [ "$chaincode_containers" -ge 2 ]; then
        print_success "Chaincode containers are running ($chaincode_containers found)"
    else
        print_failure "Expected 2 chaincode containers, found $chaincode_containers"
    fi
}

# Main execution
main() {
    print_header "Hyperledger Fabric Test Network Validation"
    
    echo -e "This script will validate the test network functionality by:"
    echo -e "  • Checking Docker containers"
    echo -e "  • Verifying channel creation"
    echo -e "  • Testing chaincode deployment"
    echo -e "  • Executing chaincode transactions"
    echo -e "  • Validating peer connectivity\n"
    
    # Run all tests
    test_docker_containers
    test_channel_exists
    test_chaincode_installed
    test_chaincode_committed
    test_chaincode_containers
    test_peer_connectivity
    test_chaincode_invoke
    sleep 2  # Wait for transaction to be committed
    test_chaincode_query
    test_create_asset
    sleep 2  # Wait for transaction to be committed
    test_read_asset
    
    # Print summary
    print_header "Validation Summary"
    
    local total_tests=$((TESTS_PASSED + TESTS_FAILED))
    echo -e "Total Tests: $total_tests"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "\n${GREEN}🎉 All tests passed! The network is fully functional.${NC}\n"
        exit 0
    else
        echo -e "\n${RED}⚠️  Some tests failed. Please review the output above.${NC}\n"
        exit 1
    fi
}

# Run main function
main
