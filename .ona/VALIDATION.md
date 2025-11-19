# Network Validation Guide

## Purpose and Scope

The `.ona/scripts/validate-network.sh` script provides **quick health checks** for deployed Fabric test networks. It complements but does not replace other testing infrastructure:

| Tool | Purpose | When to Use |
|------|---------|-------------|
| **.ona/scripts/validate-network.sh** | Post-deployment health check | After deployment, troubleshooting, quick validation |
| **Integration Tests** | Comprehensive CI/CD testing | Full feature validation, CI/CD pipelines |
| **Test-Network Scripts** | Network deployment | Creating and configuring networks |

### What This Script Does NOT Do

-  Replace comprehensive integration tests
-  Test edge cases or failure scenarios
-  Validate internal APIs
-  Create or destroy networks
-  Test all Fabric features

### What This Script DOES Do

-  Validate existing network health
-  Provide quick feedback (30-60 seconds)
-  Identify specific failure points
-  Test end-to-end transaction flow
-  Verify deployment success

## Quick Validation

Run the comprehensive validation suite:

```bash
gitpod automations task start validate-network
```

Or run the script directly:

```bash
.ona/scripts/validate-network.sh
```

## What Gets Tested

### 1. Infrastructure Layer
-  Docker containers (peer0.org1, peer0.org2, orderer)
-  Chaincode containers (dev-peer containers)

### 2. Network Layer
-  Channel creation and accessibility
-  Peer connectivity for both organizations
-  Orderer service availability

### 3. Chaincode Lifecycle
-  Chaincode installation on peers
-  Chaincode commitment to channel
-  Chaincode container deployment

### 4. Transaction Layer
-  Invoke operations (InitLedger, CreateAsset)
-  Query operations (GetAllAssets, ReadAsset)
-  Data persistence across peers
-  Transaction endorsement and ordering

## Understanding Results

### All Tests Pass (10/10)
```
🎉 All tests passed! The network is fully functional.
```

Your network is ready for:
- Development and testing
- Chaincode deployment
- Application integration
- Performance testing

### Some Tests Fail

The validation script will show which specific tests failed:

```
 FAIL: Container peer0.org1.example.com is not running
```

Common failure scenarios:

#### Network Not Started
```
 FAIL: Container peer0.org1.example.com is not running
```
**Solution:** Start the network
```bash
gitpod automations task start start-test-network
```

#### Chaincode Not Deployed
```
 FAIL: Chaincode 'basic' is not installed
```
**Solution:** Deploy chaincode
```bash
gitpod automations task start deploy-chaincode
```

#### Peer Connectivity Issues
```
 FAIL: Org1 peer is not responsive
```
**Solution:** Check Docker logs and restart
```bash
docker logs peer0.org1.example.com
gitpod automations task start stop-test-network
gitpod automations task start start-test-network
```

## Manual Testing

If you prefer to test specific components manually:

### Check Docker Containers
```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

Expected output:
```
NAMES                           STATUS
peer0.org2.example.com         Up X minutes
peer0.org1.example.com         Up X minutes
orderer.example.com            Up X minutes
dev-peer0.org1...basic_1.0     Up X minutes
dev-peer0.org2...basic_1.0     Up X minutes
```

### Check Channel
```bash
export PATH=/workspaces/fabric/build/bin:$PATH
export FABRIC_CFG_PATH=/workspaces/fabric/sampleconfig
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/workspaces/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/workspaces/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer channel list
```

Expected output:
```
Channels peers has joined: 
mychannel
```

### Check Chaincode
```bash
peer lifecycle chaincode queryinstalled
```

Expected output:
```
Installed chaincodes on peer:
Package ID: basic_1.0:..., Label: basic_1.0
```

### Query Chaincode
```bash
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
```

Expected output: JSON array of assets

### Invoke Chaincode
```bash
cd /workspaces/fabric-samples/test-network

peer chaincode invoke \
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
  -c '{"function":"InitLedger","Args":[]}'
```

Expected output:
```
Chaincode invoke successful. result: status:200
```

## Validation Script Details

### Location
`.ona/scripts/validate-network.sh`

### Requirements
- Fabric binaries built (`make native`)
- Test network running
- Chaincode deployed (for full validation)

### Exit Codes
- `0` - All tests passed
- `1` - One or more tests failed

### Environment Variables Used
```bash
PATH=/workspaces/fabric/build/bin:$PATH
FABRIC_CFG_PATH=/workspaces/fabric/sampleconfig
CORE_PEER_TLS_ENABLED=true
CORE_PEER_LOCALMSPID=Org1MSP
CORE_PEER_TLS_ROOTCERT_FILE=...
CORE_PEER_MSPCONFIGPATH=...
CORE_PEER_ADDRESS=localhost:7051
```

## Integration with CI/CD

The validation script can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Validate Fabric Network
  run: |
    .ona/scripts/validate-network.sh
  timeout-minutes: 5
```

```yaml
# Example GitLab CI
validate-network:
  script:
    - .ona/scripts/validate-network.sh
  timeout: 5m
```

## Troubleshooting

### Script Hangs
- Check if Docker is running: `docker info`
- Check if peers are responsive: `docker logs peer0.org1.example.com`
- Timeout is set to 120 seconds for invoke operations

### Permission Denied
```bash
chmod +x .ona/scripts/validate-network.sh
```

### Peer Command Not Found
```bash
export PATH=/workspaces/fabric/build/bin:$PATH
# Or rebuild binaries:
make native
```

### TLS Certificate Errors
- Ensure network was started with TLS enabled (default)
- Check certificate paths in environment variables
- Restart network if certificates are stale

## Best Practices

1. **Run validation after deployment**
   ```bash
   gitpod automations task start deploy-chaincode
   gitpod automations task start validate-network
   ```

2. **Run validation before development**
   - Ensures clean starting state
   - Identifies issues early

3. **Run validation after changes**
   - After modifying chaincode
   - After network configuration changes
   - After peer restarts

4. **Include in documentation**
   - Add validation step to README
   - Include in onboarding guides
   - Reference in troubleshooting docs

## Additional Resources

- [README.md](./README.md) - Main development guide
- [MAINTENANCE.md](./MAINTENANCE.md) - Maintenance automation guide
- [Fabric Test Network Tutorial](https://hyperledger-fabric.readthedocs.io/en/latest/test_network.html)
