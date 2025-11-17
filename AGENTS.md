# Hyperledger Fabric - Agent Development Guide

Quick reference for AI coding agents working on Hyperledger Fabric.

## Critical Requirements

**License Headers:**
Every source file must include SPDX license header:
```go
// SPDX-License-Identifier: Apache-2.0
```

**Build System:**
Use make commands exclusively. Never use `go build` directly.
```bash
make native          # Correct
go build ./cmd/peer  # Wrong - bypasses build system
```

**Pre-Commit Validation:**
```bash
make basic-checks  # License, linting, spelling, trailing spaces
make unit-test     # Unit tests (or make verify for changed packages only)
```

## Common Commands

```bash
# Build
make native              # Build all binaries
make docker              # Build Docker images

# Test
make unit-test           # Run all unit tests
make verify              # Test changed packages only (fast)
make integration-test    # Run integration tests

# Code Quality
make basic-checks        # All quality checks
make linter              # Run linters
make license             # Check license headers
make spelling            # Check spelling
```

## Project Structure

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
├── integration/           # Integration tests (see integration/AGENTS.md)
├── internal/              # Internal packages
└── .gitpod/               # Ona environment (see .gitpod/AGENTS.md)
```

## Code Style

**Copyright Headers:**
```go
// Copyright the Hyperledger Fabric contributors. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
```

**Documentation:**
- Use professional, technical language
- Do not use emojis in code, scripts, or documentation
- Document the "why," not the "what"

**Fabric Patterns:**
- Use standard library `context` (not `golang.org/x/net/context`)
- Use `github.com/golang/protobuf` (not `github.com/gogo/protobuf`)
- Generate mocks with counterfeiter or mockery (never hand-write)

## Branch Naming

Use feature branches from main following this pattern:
- `[initials]/[issue-id?-][short-description]`
- Example: `jd/123-add-feature` or `jd/fix-bug`
- Keep under 50 characters total

## Quick Fixes

```bash
.gitpod/scripts/fix-license-headers.sh  # Add missing license headers
.gitpod/scripts/fix-typos.sh            # Fix typos
.gitpod/scripts/fix-trailing-spaces.sh  # Remove trailing spaces
go mod tidy && go mod vendor            # Sync vendor directory
go generate ./path/to/package           # Regenerate mocks
```

## Validation

Before committing, run:
```bash
make basic-checks  # All quality checks
make verify        # Test changed packages
```

Or use git hooks for automatic validation:
```bash
gitpod automations task start install-git-hooks
```

## Domain-Specific Guides

- **integration/AGENTS.md** - Integration testing
- **.gitpod/AGENTS.md** - Ona environment

## Detailed Documentation

- **CONTRIBUTING.md** - Contribution guidelines
- **Makefile** - Build system (see header comments)
- **.gitpod/MAINTENANCE.md** - Maintenance automation
- **Fabric docs** - https://hyperledger-fabric.readthedocs.io/
