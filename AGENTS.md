# Hyperledger Fabric - Agent Development Guide

Target audience: AI coding agents (Claude, GPT-4, etc.)

Purpose: Enable AI agents to contribute effectively to Hyperledger Fabric codebase.

---

## CRITICAL REQUIREMENTS

These requirements cause CI failures if not followed.

### License Headers

Every source file must include SPDX license header:

```go
// SPDX-License-Identifier: Apache-2.0
```

For scripts:
```bash
# SPDX-License-Identifier: Apache-2.0
```

Missing license headers will fail CI. Check with: `make license`

### Build System

Use make commands exclusively. Never use go build directly.

```bash
make native          # Correct
go build ./cmd/peer  # Wrong - bypasses build system
```

Rationale: Makefile handles cross-compilation, vendoring, Docker builds.

### Pre-Commit Validation

Run before every commit:
```bash
make basic-checks  # License, linting, spelling, trailing spaces
make unit-test     # Unit tests (or make verify for changed packages only)
```

---

## PROJECT STRUCTURE

```
fabric/
├── cmd/                    # CLI tools (peer, orderer, configtxgen)
├── core/                   # Core functionality
│   ├── chaincode/         # Chaincode runtime and lifecycle
│   ├── ledger/            # Ledger implementation
│   └── peer/              # Peer node implementation
├── orderer/               # Ordering service (Raft, SmartBFT)
├── common/                # Shared utilities
├── gossip/                # Gossip protocol
├── msp/                   # Membership Service Provider
├── integration/           # Integration tests (Ginkgo-based)
├── internal/              # Internal packages
├── sampleconfig/          # Sample configuration files
├── build/bin/             # Built binaries (after make native)
└── .gitpod/               # Ona development environment
```

Key directories:
- `cmd/` - Binary entry points
- `core/` - Main business logic
- `integration/` - End-to-end tests
- `internal/` - Private packages (not for external use)

---

## COMMON TASKS

### Build

```bash
make native      # Build all binaries → build/bin/
make docker      # Build Docker images
make clean       # Clean build artifacts
make clean-all   # Clean everything including Docker
```

### Test

```bash
make unit-test   # Run all unit tests
make verify      # Test changed packages only (fast)
make integration-test INTEGRATION_TEST_SUITE="raft smartbft"  # Specific suite
make integration-test  # All integration tests (~30 min)
make basic-checks  # Code quality checks
```

### Code Quality

```bash
make linter    # Run gofumpt, goimports, staticcheck
make license   # Check license headers
make spelling  # Check spelling
```

---

## TESTING

### Unit Tests

Location: Same directory as code, `*_test.go` files

Framework: Standard Go testing or Ginkgo/Gomega

Requirements:
- Support parallel execution (`go test -p`)
- No external dependencies (use mocks)
- Clean up temp directories
- Use existing test framework in package

Example:
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

Location: `integration/` directory

Framework: Ginkgo/Gomega (BDD style)

Available suites:
- `raft` - Raft consensus (~5 min)
- `smartbft` - SmartBFT consensus (~5 min)
- `ledger` - Ledger tests (~8 min)
- `pvtdata` - Private data (~8 min)
- `lifecycle` - Chaincode lifecycle (~6 min)
- `gateway` - Gateway API (~5 min)
- `e2e` - End-to-end (~10 min)
- `nwo` - Network orchestration (~10 min)

Run specific suites:
```bash
make integration-test INTEGRATION_TEST_SUITE="raft smartbft"
make integration-test INTEGRATION_TEST_SUITE="ledger pvtdata"
```

### Mock Generation

Two tools exist (historical reasons):

Counterfeiter (preferred):
```go
//go:generate counterfeiter -o mocks/myinterface.go --fake-name MyInterface . MyInterface
```

Mockery (legacy):
```go
//go:generate mockery -dir . -name MyInterface -case underscore -output mocks/
```

Check existing mocks in package to determine which tool to use.

Regenerate mocks:
```bash
go generate ./path/to/package
```

---

## CODE STYLE

### Enforced by CI

- gofumpt - Stricter gofmt formatting
- goimports - Import organization
- go vet - Static analysis
- staticcheck - Additional linting (see `staticcheck.conf`)

Run locally: `make linter`

### Fabric Patterns

DO:
- Use standard library `context` package
- Use `github.com/golang/protobuf` for protobuf
- Use interfaces at component boundaries
- Generate mocks with counterfeiter or mockery

DO NOT:
- Use `golang.org/x/net/context` (deprecated)
- Use `github.com/gogo/protobuf` (deprecated)
- Create unnecessary interfaces
- Use package-level global state
- Hand-write mocks

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

## COMMON ERRORS

### Missing License Header

Error: `make license` fails
```
Error: Missing SPDX-License-Identifier in file.go
```

Solution: Add to top of file:
```go
// SPDX-License-Identifier: Apache-2.0
```

### Deprecated Package Import

Error: `make linter` fails
```
Error: use of deprecated package golang.org/x/net/context
```

Solution: Use standard library:
```go
import "context"  // Not golang.org/x/net/context
```

### Vendor Out of Sync

Error: `make native` fails
```
Error: vendor/ directory out of sync
```

Solution:
```bash
go mod tidy && go mod vendor
```

### Stale Mocks

Error: Tests fail with interface mismatch

Solution:
```bash
go generate ./path/to/package
```

### go.sum Stale

Error: `make basic-checks` fails
```
Error: go.sum is stale
```

Solution:
```bash
go mod tidy
```

### Port Already in Use

Error: Integration tests fail
```
Error: bind: address already in use
```

Solution:
```bash
cd /workspaces/fabric-samples/test-network
./network.sh down
```

---

## ONA ENVIRONMENT

### Automatic Tasks

Runs on environment start:
- `build-fabric` - Builds all binaries

### Quick Validation

Fast feedback for development:
```bash
gitpod automations task start quick-check      # 2-5 min: linters + changed packages
gitpod automations task start verify-changes   # 1-3 min: changed packages only
```

### Test Network

For chaincode and API development:
```bash
gitpod automations task start start-network              # Start (clean restart)
gitpod automations task start start-network-couchdb      # Start with CouchDB
gitpod automations task start deploy-chaincode           # Deploy sample
gitpod automations task start restart-network            # Quick restart
gitpod automations task start stop-network               # Stop
```

### Integration Tests

Granular test suites (faster than full suite):
```bash
gitpod automations task start test-consensus      # ~5 min: Raft + SmartBFT
gitpod automations task start test-ledger         # ~8 min: Ledger + private data
gitpod automations task start test-lifecycle      # ~6 min: Chaincode lifecycle
gitpod automations task start test-gateway        # ~5 min: Gateway + discovery
gitpod automations task start test-e2e            # ~10 min: End-to-end
gitpod automations task start test-integration-all  # ~30 min: All tests
```

### Code Quality

```bash
gitpod automations task start check-code  # Run all code quality checks
```

### Utilities

```bash
gitpod automations task list                          # List all automations
gitpod automations task start clean-integration-tests # Clean test artifacts (~300-400MB)
gitpod automations task start clean-all               # Clean everything
```

### Ona Specifics

- Test artifacts cleaned automatically after tests
- Docker-in-Docker enabled
- Binaries pre-built on environment start
- Use automations instead of manual commands (more reliable)

Resource management:
- Integration tests create ~300-400MB artifacts
- Cleanup automatic via `.gitpod/cleanup-test-artifacts.sh`
- Use `clean-integration-tests` if needed

---

## TROUBLESHOOTING

### Build Failures

Problem: `make native` fails

Solution:
```bash
make clean
make native
```

### Test Failures

Problem: Integration tests fail with "image not found"

Solution:
```bash
make docker-thirdparty
```

### Automation Issues

Problem: Automation fails with "task not found"

Solution:
```bash
gitpod automations update .gitpod/automations.yaml
```

Problem: Network won't start (channel exists error)

Solution: Use `start-network` (does clean restart automatically)
```bash
gitpod automations task start start-network
```

---

## DOCUMENTATION MANAGEMENT

### Keep in Repository

- User guides and tutorials
- API documentation
- Configuration references
- Operational procedures (README.md, TRIGGERS.md, VALIDATION.md)

### Remove After Use

- Design analysis documents
- Implementation plans
- Investigation notes
- Decision records (use commit messages instead)

Rationale: Temporary docs add clutter, duplicate commit messages, rarely referenced after merge.

Cleanup process:
```bash
rm .gitpod/ANALYSIS_DOCUMENT.md
git commit -m "Remove temporary analysis document
Information preserved in commit message."
```

---

## QUICK REFERENCE

### Development Cycle

```bash
make native              # Build
make verify              # Test changed packages
make basic-checks        # Pre-commit checks
```

### Full Validation

```bash
make unit-test           # All unit tests
make integration-test    # All integration tests
```

### Ona Quick Validation

```bash
gitpod automations task start quick-check        # Fast feedback
gitpod automations task start test-consensus     # Specific suite
```

### Test Network

```bash
gitpod automations task start start-network      # Start
gitpod automations task start deploy-chaincode   # Deploy
gitpod automations task start stop-network       # Stop
```

### Pre-Commit Checklist

- [ ] Added SPDX license headers to new files
- [ ] Ran `make basic-checks` (passed)
- [ ] Ran `make unit-test` or `make verify` (passed)
- [ ] Updated mocks if interfaces changed (`go generate`)
- [ ] Updated vendor if dependencies changed (`go mod tidy && go mod vendor`)
- [ ] Removed temporary analysis documents
- [ ] Tested changes work as expected

---

## ADDITIONAL RESOURCES

Documentation:
- [Fabric Documentation](https://hyperledger-fabric.readthedocs.io/)
- [Test Network Tutorial](https://hyperledger-fabric.readthedocs.io/en/latest/test_network.html)
- [Contributing Guide](./CONTRIBUTING.md)
- [Ona Automations README](./.gitpod/README.md)
- [Automation Triggers](./.gitpod/TRIGGERS.md)

Key files:
- `Makefile` - Build system
- `staticcheck.conf` - Linter configuration
- `.gitpod/automations.yaml` - Ona automation definitions
- `go.mod` - Go module dependencies

---

This file is maintained in version control. See git history for changes.

If this file is missing critical information or contains errors, update it and commit the changes.
