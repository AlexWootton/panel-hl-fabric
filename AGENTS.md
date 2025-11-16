# Hyperledger Fabric - AI Agent Development Guide

**Purpose**: This file provides AI agents with essential information for contributing to Hyperledger Fabric, with specific guidance for Ona remote development environments.

**Target Audience**: AI coding agents (Claude, GPT-4, etc.) working on Fabric codebase

---

## 🚨 Critical Requirements (READ FIRST)

These requirements will **fail CI checks** if not followed:

### 1. License Headers (MANDATORY)

**Every source file MUST have an SPDX license header:**

```go
// SPDX-License-Identifier: Apache-2.0
```

Or for scripts:
```bash
# SPDX-License-Identifier: Apache-2.0
```

**Missing license headers = CI failure**. Run `make license` to check.

### 2. Use Make Commands (NEVER direct go build)

```bash
✅ make native          # Build binaries
✅ make unit-test       # Run unit tests
✅ make basic-checks    # Pre-commit checks

❌ go build ./cmd/peer  # WRONG - bypasses build system
❌ go test ./...        # WRONG - use make commands
```

**Why**: Makefile handles cross-compilation, vendoring, Docker builds, and ensures consistent builds.

### 3. Pre-Commit Checklist

Before committing, **ALWAYS run**:
```bash
make basic-checks  # License, linting, spelling, trailing spaces
make unit-test     # Unit tests
```

---

## 📁 Project Structure

```
fabric/
├── cmd/                    # CLI tools (peer, orderer, configtxgen, etc.)
├── core/                   # Core Fabric functionality
│   ├── chaincode/         # Chaincode runtime & lifecycle
│   ├── ledger/            # Ledger implementation
│   └── peer/              # Peer node implementation
├── orderer/               # Ordering service (Raft, SmartBFT)
├── common/                # Shared utilities
├── gossip/                # Gossip protocol
├── msp/                   # Membership Service Provider
├── integration/           # Integration tests (Ginkgo-based)
├── internal/              # Internal packages (not for external use)
├── sampleconfig/          # Sample configuration files
├── build/bin/             # Built binaries (after make native)
└── .gitpod/               # Ona development environment config
```

**Key Directories**:
- `cmd/` - Entry points for binaries
- `core/` - Main business logic
- `integration/` - End-to-end tests
- `internal/` - Private packages

---

## 🔨 Common Development Tasks

### Building

```bash
# Build all binaries (peer, orderer, configtxgen, etc.)
make native

# Build Docker images
make docker

# Clean build artifacts
make clean

# Clean everything (including Docker)
make clean-all
```

**Output**: Binaries are in `build/bin/`

### Testing

```bash
# Run unit tests
make unit-test

# Run tests for changed packages only (fast!)
make verify

# Run specific integration test suite
make integration-test INTEGRATION_TEST_SUITE="raft smartbft"

# Run all integration tests (~30 minutes)
make integration-test

# Run code quality checks
make basic-checks
```

### Code Quality

```bash
# Run linter (gofumpt, goimports, staticcheck)
make linter

# Check license headers
make license

# Check spelling
make spelling
```

---

## 🧪 Testing Framework

### Unit Tests

**Location**: Same directory as code, `*_test.go` files

**Framework**: Standard Go testing or Ginkgo/Gomega

**Requirements**:
- ✅ Must support parallel execution (`go test -p`)
- ✅ NO external dependencies (use mocks)
- ✅ Clean up temp directories
- ✅ Use existing test framework in package

**Example**:
```go
// SPDX-License-Identifier: Apache-2.0

package mypackage_test

import (
    "testing"
    "github.com/stretchr/testify/require"
)

func TestMyFunction(t *testing.T) {
    result := MyFunction()
    require.Equal(t, expected, result)
}
```

### Integration Tests

**Location**: `integration/` directory

**Framework**: Ginkgo/Gomega (BDD style)

**Test Suites**:
- `raft` - Raft consensus tests
- `smartbft` - SmartBFT consensus tests
- `ledger` - Ledger tests
- `pvtdata` - Private data tests
- `lifecycle` - Chaincode lifecycle tests
- `gateway` - Gateway API tests
- `e2e` - End-to-end tests
- `nwo` - Network orchestration tests

**Running Specific Suites**:
```bash
# Fast: Run only consensus tests (~5 min)
make integration-test INTEGRATION_TEST_SUITE="raft smartbft"

# Medium: Run ledger tests (~8 min)
make integration-test INTEGRATION_TEST_SUITE="ledger pvtdata"

# Slow: Run all tests (~30 min)
make integration-test
```

### Mock Generation

**Two tools** (for historical reasons):

1. **Counterfeiter** (preferred for new code):
```go
//go:generate counterfeiter -o mocks/myinterface.go --fake-name MyInterface . MyInterface
```

2. **Mockery** (legacy, still used in some packages):
```go
//go:generate mockery -dir . -name MyInterface -case underscore -output mocks/
```

**Check existing mocks** in the package to determine which tool to use.

**Regenerate mocks**:
```bash
go generate ./...
```

---

## 🎨 Code Style

### Go Style Requirements

**Enforced by CI**:
- ✅ **gofumpt** - Stricter gofmt formatting
- ✅ **goimports** - Import organization
- ✅ **go vet** - Static analysis
- ✅ **staticcheck** - Additional linting (see `staticcheck.conf`)

**Run locally**:
```bash
make linter
```

### Fabric-Specific Patterns

**DO**:
- ✅ Use standard library `context` package
- ✅ Use `github.com/golang/protobuf` for protobuf
- ✅ Use interfaces at component boundaries
- ✅ Encapsulate within components
- ✅ Generate mocks with counterfeiter or mockery

**DON'T**:
- ❌ Use `golang.org/x/net/context` (deprecated)
- ❌ Use `github.com/gogo/protobuf` (deprecated)
- ❌ Create unnecessary interfaces
- ❌ Use package-level global state
- ❌ Hand-write mocks

### Import Organization

```go
import (
    // Standard library
    "context"
    "fmt"
    
    // External dependencies
    "github.com/hyperledger/fabric-protos-go/peer"
    "github.com/pkg/errors"
    
    // Internal packages
    "github.com/hyperledger/fabric/common/flogging"
    "github.com/hyperledger/fabric/core/chaincode"
)
```

---

## ⚠️ Common Pitfalls

### Critical Mistakes (Will Break CI)

1. **Missing SPDX license header**
   ```bash
   # Check before committing
   make license
   ```

2. **Using deprecated packages**
   ```go
   ❌ import "golang.org/x/net/context"
   ✅ import "context"
   
   ❌ import "github.com/gogo/protobuf/proto"
   ✅ import "github.com/golang/protobuf/proto"
   ```

3. **Not running basic-checks**
   ```bash
   # Always run before committing
   make basic-checks
   ```

4. **Using `go build` directly**
   ```bash
   ❌ go build ./cmd/peer
   ✅ make native
   ```

### Common Mistakes (Will Cause Issues)

5. **Forgetting to update vendor/**
   ```bash
   # After changing dependencies
   go mod tidy && go mod vendor
   ```

6. **Not regenerating mocks**
   ```bash
   # After changing interfaces
   go generate ./path/to/package
   ```

7. **External dependencies in unit tests**
   ```go
   ❌ func TestWithDocker(t *testing.T) { /* uses Docker */ }
   ✅ func TestWithMock(t *testing.T) { /* uses mock */ }
   ```

8. **Not cleaning up temp directories**
   ```go
   func TestMyFunction(t *testing.T) {
       tempDir, err := os.MkdirTemp("", "test")
       require.NoError(t, err)
       defer os.RemoveAll(tempDir)  // ✅ Always clean up
   }
   ```

---

## 🌐 Ona Development Environment

### Ona Automations

**Automatic** (runs on environment start):
- `build-fabric` - Builds all binaries

**Quick Validation** (fast feedback):
```bash
# 2-5 minutes: Linters + changed package tests
gitpod automations task start quick-check

# 1-3 minutes: Test only changed packages
gitpod automations task start verify-changes
```

**Test Network** (for chaincode/API development):
```bash
# Start network (clean restart, no errors)
gitpod automations task start start-network

# Start network with CouchDB (for ledger development)
gitpod automations task start start-network-couchdb

# Deploy sample chaincode
gitpod automations task start deploy-chaincode

# Quick restart
gitpod automations task start restart-network

# Stop network
gitpod automations task start stop-network
```

**Granular Integration Tests** (much faster than full suite):
```bash
# ~5 min: Consensus tests (Raft + SmartBFT)
gitpod automations task start test-consensus

# ~8 min: Ledger tests (ledger + private data)
gitpod automations task start test-ledger

# ~6 min: Lifecycle tests (chaincode lifecycle)
gitpod automations task start test-lifecycle

# ~5 min: Gateway tests (gateway + discovery)
gitpod automations task start test-gateway

# ~10 min: E2E tests (end-to-end scenarios)
gitpod automations task start test-e2e

# ~30 min: ALL integration tests
gitpod automations task start test-integration-all
```

**Code Quality**:
```bash
# Run all code quality checks
gitpod automations task start check-code
```

**Utilities**:
```bash
# List all available automations
gitpod automations task list

# Clean test artifacts (~300-400MB)
gitpod automations task start clean-integration-tests

# Clean everything (artifacts + Docker)
gitpod automations task start clean-all
```

### Ona-Specific Considerations

**Remote Development**:
- ✅ Use automations instead of manual commands (more reliable)
- ✅ Test artifacts are cleaned automatically after tests
- ✅ Docker-in-Docker is enabled
- ✅ Binaries are pre-built on environment start

**Resource Management**:
- Integration tests create ~300-400MB of artifacts
- Cleanup is automatic (via `.gitpod/cleanup-test-artifacts.sh`)
- Use `clean-integration-tests` if needed

**Troubleshooting**:
- If `check-code` fails after tests: Artifacts are cleaned automatically
- If network won't start: Use `start-network` (not `start-test-network`)
- If disk space issues: Run `clean-all` automation

---

## 📝 Documentation Guidelines

### Temporary vs Permanent Documentation

**Permanent** (keep in repository):
- ✅ User guides and tutorials
- ✅ API documentation
- ✅ Configuration references
- ✅ Operational procedures (README.md, TRIGGERS.md, VALIDATION.md)

**Temporary** (delete after use):
- ❌ Design analysis documents
- ❌ Implementation plans
- ❌ Investigation notes
- ❌ Decision records (use commit messages instead)

**Cleanup Process**:
```bash
# Create temporary docs during development
# Use them for PR review
# Reference them in commit messages
# Delete before final commit

rm .gitpod/ANALYSIS_DOCUMENT.md
git commit -m "Remove temporary analysis document
Information preserved in commit message."
```

**Why**: Temporary docs add clutter, duplicate commit messages, and are rarely referenced after merge.

---

## 🔍 Troubleshooting

### Build Issues

**Problem**: `make native` fails
```bash
# Solution: Clean and rebuild
make clean
make native
```

**Problem**: "vendor/ out of sync"
```bash
# Solution: Update vendor
go mod tidy && go mod vendor
```

### Test Issues

**Problem**: Integration tests fail with "image not found"
```bash
# Solution: Pull Docker images
make docker-thirdparty
```

**Problem**: `check-code` fails with "go.sum is stale"
```bash
# Solution: Run go mod tidy
go mod tidy
```

**Problem**: Tests fail with "port already in use"
```bash
# Solution: Stop test network
cd /workspaces/fabric-samples/test-network
./network.sh down
```

### Ona-Specific Issues

**Problem**: Automation fails with "task not found"
```bash
# Solution: Update automations
gitpod automations update .gitpod/automations.yaml
```

**Problem**: Network won't start (channel exists error)
```bash
# Solution: Use start-network (not start-test-network)
# start-network does clean restart automatically
gitpod automations task start start-network
```

---

## 📚 Additional Resources

### Documentation
- [Fabric Documentation](https://hyperledger-fabric.readthedocs.io/)
- [Test Network Tutorial](https://hyperledger-fabric.readthedocs.io/en/latest/test_network.html)
- [Contributing Guide](./CONTRIBUTING.md)
- [Ona Automations README](./.gitpod/README.md)
- [Automation Triggers](./.gitpod/TRIGGERS.md)

### Key Files
- `Makefile` - Build system (read this to understand targets)
- `staticcheck.conf` - Linter configuration
- `.gitpod/automations.yaml` - Ona automation definitions
- `go.mod` - Go module dependencies

### Getting Help
- Check existing issues on GitHub
- Review recent commits for similar changes
- Read test files for usage examples
- Use `make help` for available targets

---

## 🎯 Quick Reference

### Most Common Commands

```bash
# Development cycle
make native              # Build
make verify              # Test changed packages
make basic-checks        # Pre-commit checks

# Full validation
make unit-test           # All unit tests
make integration-test    # All integration tests

# Ona quick validation
gitpod automations task start quick-check        # Fast feedback
gitpod automations task start test-consensus     # Specific suite

# Test network
gitpod automations task start start-network      # Start
gitpod automations task start deploy-chaincode   # Deploy
gitpod automations task start stop-network       # Stop
```

### Critical Checklist

Before committing:
- [ ] Added SPDX license headers to new files
- [ ] Ran `make basic-checks` (passed)
- [ ] Ran `make unit-test` or `make verify` (passed)
- [ ] Updated mocks if interfaces changed (`go generate`)
- [ ] Updated vendor if dependencies changed (`go mod tidy && go mod vendor`)
- [ ] Removed temporary analysis documents
- [ ] Tested changes work as expected

---

**Last Updated**: This file is maintained in version control. See git history for changes.

**Feedback**: If this file is missing critical information or contains errors, update it and commit the changes.
