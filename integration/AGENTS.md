# Integration Tests - Agent Guide

Integration tests use Ginkgo/Gomega (BDD style).

## Running Tests

```bash
# All integration tests
make integration-test

# Specific suites
make integration-test INTEGRATION_TEST_SUITE="raft smartbft"

# Granular suites (via automations)
gitpod automations task start test-consensus
gitpod automations task start test-ledger
gitpod automations task start test-lifecycle
gitpod automations task start test-gateway
gitpod automations task start test-e2e
```

## Network Orchestration (NWO)

The `nwo/` package provides a framework for creating test networks. Key files:
- `nwo/topology.go` - Network topology definitions
- `nwo/network.go` - Network creation and management
- `nwo/fabricconfig.go` - Configuration helpers

Example usage:
```go
network := nwo.New(nwo.BasicSolo(), testDir, client, StartPort(), components)
network.GenerateConfigTree()
network.Bootstrap()
```

## Test Requirements

- Support parallel execution
- Clean up Docker containers and volumes
- Use unique port ranges with `StartPort()`
- Clean up temp directories in `AfterEach`
- No external dependencies (use mocks)

## Debugging

```bash
ginkgo -focus="test name" ./integration/raft  # Run specific test
ginkgo -v ./integration/raft                  # Verbose output
PRESERVE_TEST_ARTIFACTS=true ginkgo ./...     # Keep artifacts on failure
```
