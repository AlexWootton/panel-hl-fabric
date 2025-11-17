# Integration Tests - Agent Guide

Domain-specific guidance for working with Hyperledger Fabric integration tests.

## Framework

Integration tests use Ginkgo/Gomega (BDD style).

## Running Tests

```bash
# All integration tests
make integration-test

# Specific suites
make integration-test INTEGRATION_TEST_SUITE="raft smartbft"

# Granular test suites (via automations)
gitpod automations task start test-consensus  # Raft + SmartBFT (~5 min)
gitpod automations task start test-ledger     # Ledger + private data (~8 min)
gitpod automations task start test-lifecycle  # Chaincode lifecycle (~6 min)
gitpod automations task start test-gateway    # Gateway + discovery (~5 min)
gitpod automations task start test-e2e        # End-to-end (~10 min)
```

## Test Structure

Tests are organized by functional area in subdirectories:
- `raft/` - Raft consensus tests
- `smartbft/` - SmartBFT consensus tests
- `ledger/` - Ledger tests
- `pvtdata/` - Private data tests
- `lifecycle/` - Chaincode lifecycle tests
- `gateway/` - Gateway tests
- `e2e/` - End-to-end tests
- `nwo/` - Network orchestration framework

## Network Orchestration (NWO)

The `nwo/` package provides a framework for creating test networks:

```go
network := nwo.New(nwo.BasicSolo(), testDir, client, StartPort(), components)
network.GenerateConfigTree()
network.Bootstrap()
```

Key NWO concepts:
- Network topologies defined in `nwo/topology.go`
- Peer and orderer configuration helpers
- Channel creation and chaincode deployment utilities

## Test Requirements

- Support parallel execution
- Clean up Docker containers and volumes
- Use unique port ranges (StartPort())
- Clean up temp directories
- No external dependencies

## Common Patterns

```go
// Standard test setup
var (
    testDir   string
    client    *docker.Client
    network   *nwo.Network
)

BeforeEach(func() {
    testDir, err = ioutil.TempDir("", "integration")
    Expect(err).NotTo(HaveOccurred())
    
    client, err = docker.NewClientFromEnv()
    Expect(err).NotTo(HaveOccurred())
})

AfterEach(func() {
    if network != nil {
        network.Cleanup()
    }
    os.RemoveAll(testDir)
})
```

## Debugging Tests

```bash
# Run specific test
ginkgo -focus="test name" ./integration/raft

# Verbose output
ginkgo -v ./integration/raft

# Keep artifacts on failure
PRESERVE_TEST_ARTIFACTS=true ginkgo ./integration/raft
```

## Related Documentation

- Root AGENTS.md - General Fabric development guide
- CONTRIBUTING.md - Full contribution guidelines
