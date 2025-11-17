# Hyperledger Fabric - Agent Development Guide

Target audience: AI coding agents (Claude, GPT-4, etc.)

Purpose: Quick reference for stable patterns and critical requirements. For detailed information, refer to authoritative source files.

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

See `Makefile` header comments for complete list of targets.

### Build

```bash
make native      # Build all binaries → build/bin/
make docker      # Build Docker images
make clean       # Clean build artifacts
```

### Test

```bash
make unit-test   # Run all unit tests
make verify      # Test changed packages only (fast)
make integration-test INTEGRATION_TEST_SUITE="<suite>"  # Specific suite
make basic-checks  # Code quality checks
```

For available integration test suites, see `integration/` directory structure.

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

Run specific suites:
```bash
make integration-test INTEGRATION_TEST_SUITE="raft smartbft"
```

For available suites and details, explore the `integration/` directory.

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

### Documentation and Comments

**Copyright Headers:**
All files must include proper copyright format with period:
```go
// Copyright the Hyperledger Fabric contributors. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
```

For scripts:
```bash
# Copyright the Hyperledger Fabric contributors. All rights reserved.
#
# SPDX-License-Identifier: Apache-2.0
```

**Professional Tone:**
- Use professional, technical language in all documentation
- Avoid casual phrases, conversational tone, or colloquialisms
- Do not use emojis in code, scripts, or documentation
- Exception: Emojis may be used in user-facing UI elements if appropriate

**Comments:**
- Document the "why," not the "what"
- Avoid redundant comments that restate code
- Only add comments to clarify non-obvious logic or trade-offs

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

Solution: Add to top of file:
```go
// SPDX-License-Identifier: Apache-2.0
```

### Deprecated Package Import

Error: `make linter` fails

Solution: Use standard library:
```go
import "context"  // Not golang.org/x/net/context
```

### Vendor Out of Sync

Error: `make native` fails

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

Solution:
```bash
go mod tidy
```

---

## ONA ENVIRONMENT

The `.gitpod/` directory contains automation configurations for development workflows.

### Quick Commands

```bash
# List available automations
gitpod automations task list

# Fast validation
gitpod automations task start quick-check
gitpod automations task start verify-changes

# Test network
gitpod automations task start start-network
gitpod automations task start stop-network
```

For complete automation details, see `.gitpod/README.md`.

---

## DOCUMENTATION MANAGEMENT

### Keep in Repository

- User guides and tutorials
- API documentation
- Configuration references
- Operational procedures

### Remove After Use

- Design analysis documents
- Implementation plans
- Investigation notes
- Decision records (use commit messages instead)

Rationale: Temporary docs add clutter, duplicate commit messages, rarely referenced after merge.

---

## QUICK REFERENCE

### Development Cycle

```bash
make native              # Build
make verify              # Test changed packages
make basic-checks        # Pre-commit checks
```

### Pre-Commit Checklist

- [ ] Added proper copyright headers to new files (with period)
- [ ] Added SPDX license headers to new files
- [ ] Verified professional tone in all documentation (no emojis, no casual language)
- [ ] Ran `make basic-checks` (passed)
- [ ] Ran `make unit-test` or `make verify` (passed)
- [ ] Updated mocks if interfaces changed (`go generate`)
- [ ] Updated vendor if dependencies changed (`go mod tidy && go mod vendor`)
- [ ] Removed temporary analysis documents
- [ ] Tested changes work as expected

---

## AUTHORITATIVE SOURCES

When this guide conflicts with or lacks detail, refer to:

- **Build system**: `Makefile` (header comments list all targets)
- **Ona environment**: `.gitpod/README.md`
- **Integration tests**: `integration/` directory structure
- **Code style**: `staticcheck.conf`
- **Dependencies**: `go.mod`
- **Contributing**: `CONTRIBUTING.md`
- **Fabric docs**: https://hyperledger-fabric.readthedocs.io/

---

This file contains stable patterns and critical requirements. For implementation details, timings, and specific configurations, always refer to the authoritative source files listed above.
