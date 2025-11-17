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

**Professional Tone:**
- Use professional, technical language in all documentation
- Avoid casual phrases, conversational tone, or colloquialisms
- Do not use emojis in code, scripts, or documentation

**Comments:**
- Document the "why," not the "what"
- Avoid redundant comments that restate code

**Fabric Patterns:**

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

## Branch Naming

Use feature branches from main following this pattern:
- `[initials]/[issue-id?-][short-description]`
- Example: `jd/123-add-feature` or `jd/fix-bug`
- Keep under 50 characters total

## Common Errors and Solutions

**Missing License Header:**
```bash
make license  # Check
.gitpod/scripts/fix-license-headers.sh  # Fix
```

**Vendor Out of Sync:**
```bash
go mod tidy && go mod vendor
```

**Stale Mocks:**
```bash
go generate ./path/to/package
```

## Domain-Specific Guides

- **integration/AGENTS.md** - Integration testing guidance
- **.gitpod/AGENTS.md** - Ona environment specifics

## Detailed Documentation

- **CONTRIBUTING.md** - Full contribution guidelines
- **Makefile** - Complete build system reference (see header comments)
- **staticcheck.conf** - Linting configuration
- **.gitpod/README.md** - Ona environment setup
- **.gitpod/MAINTENANCE.md** - Maintenance automation guide
- **Fabric docs** - https://hyperledger-fabric.readthedocs.io/

## Pre-Commit Checklist

- [ ] Added proper copyright headers to new files (with period)
- [ ] Added SPDX license headers to new files
- [ ] Verified professional tone in all documentation
- [ ] Ran `make basic-checks` (passed)
- [ ] Ran `make unit-test` or `make verify` (passed)
- [ ] Updated mocks if interfaces changed (`go generate`)
- [ ] Updated vendor if dependencies changed (`go mod tidy && go mod vendor`)
- [ ] Removed temporary analysis documents
- [ ] Tested changes work as expected
