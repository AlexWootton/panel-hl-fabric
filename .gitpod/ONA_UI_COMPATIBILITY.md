# Ona UI Compatibility Guide

**Issue**: Ona UI does not currently support environment variables for manually triggered automations.

**Impact**: Some automations require input parameters and cannot be run from the Ona UI.

---

## Automation Compatibility Matrix

###  Fully Compatible with Ona UI (17 automations)

These automations work perfectly from the Ona UI with no variables required:

#### Build & Test
- `build-fabric` - Build all Fabric binaries
- `build-docker` - Build Docker images
- `quick-check` - Fast validation (2-5 min)
- `verify-changes` - Test changed packages only
- `test-unit` - Run all unit tests
- `test-consensus` - Raft + SmartBFT tests
- `test-ledger` - Ledger + private data tests
- `test-lifecycle` - Chaincode lifecycle tests
- `test-gateway` - Gateway + discovery tests
- `test-e2e` - End-to-end tests
- `test-integration-all` - All integration tests
- `check-code` - Full code quality checks

#### Network Operations
- `start-network` - Start test network
- `start-network-couchdb` - Start with CouchDB
- `stop-network` - Stop test network
- `restart-network` - Quick restart
- `validate-network` - Validate network is running
- `deploy-chaincode` - Deploy sample chaincode
- `setup-couchdb` - Setup CouchDB

#### Maintenance (NEW!)
- `fix-typos` - Auto-fix typos in comments/docs
- `fix-license-headers` - Auto-add missing SPDX headers
- `fix-trailing-spaces` - Auto-remove trailing spaces
- `validate-changes` - Full validation with unit tests
- `validate-changes-quick` - Quick validation (skip tests)
- `validate-commit-message` - Validate last commit message
- `generate-changelog` - Generate changelog from last tag
- `install-git-hooks` - Install pre-push/commit-msg hooks
- `check-outdated-deps` - List outdated dependencies (NEW!)

#### Cleanup
- `clean-integration-tests` - Clean test artifacts
- `clean-all` - Clean everything

**Total: 28 automations work from Ona UI**

---

###  CLI Only - Require Variables (3 automations)

These automations require environment variables and **cannot** be run from Ona UI:

1. **update-go-version** (CLI only)
   - Requires: `GO_VERSION` variable
   - Ona UI: Shows error with CLI instructions
   - CLI Usage: `GO_VERSION=1.25.4 gitpod automations task start update-go-version`
   - Direct: `.gitpod/scripts/update-go-version.sh` (interactive prompts)

2. **update-dependency** (CLI only)
   - Requires: `DEPENDENCY` and `VERSION` variables
   - Ona UI: Shows error with CLI instructions
   - CLI Usage: `DEPENDENCY=github.com/pkg/errors VERSION=v0.9.1 gitpod automations task start update-dependency`
   - Direct: `.gitpod/scripts/update-dependency.sh` (interactive prompts)
   - Alternative: Use `check-outdated-deps` to see what needs updating

3. **prepare-release** (CLI only)
   - Requires: `VERSION` variable
   - Ona UI: Shows error with CLI instructions
   - CLI Usage: `VERSION=3.1.4 gitpod automations task start prepare-release`
   - Direct: `.gitpod/scripts/prepare-release.sh` (interactive prompts)

---

## Workarounds for CLI-Only Automations

### Option 1: Use CLI with Environment Variables

```bash
# Update Go version
GO_VERSION=1.25.4 gitpod automations task start update-go-version

# Update dependency
DEPENDENCY=golang.org/x/crypto VERSION=v0.44.0 gitpod automations task start update-dependency

# Prepare release
VERSION=3.1.4 gitpod automations task start prepare-release
```

### Option 2: Run Scripts Directly with Interactive Prompts

All CLI-only scripts support interactive mode when run directly:

```bash
# Interactive Go version update
.gitpod/scripts/update-go-version.sh
# Prompts: Enter new Go version (e.g., 1.25.4):

# Interactive dependency update
.gitpod/scripts/update-dependency.sh
# Prompts: Enter dependency path:
# Prompts: Enter new version (e.g., v0.19.2):

# Interactive release preparation
.gitpod/scripts/prepare-release.sh
# Prompts: Enter new version (e.g., 3.1.4):
```

### Option 3: Use Helper Automations

For dependency updates, use the helper automation first:

```bash
# 1. Check what's outdated (works from Ona UI)
gitpod automations task start check-outdated-deps

# 2. Copy the update command from output
# 3. Run in CLI with the specific dependency and version
```

---

## Design Decisions

### Why Not Auto-Detect Latest Versions?

**Considered**: Auto-detect latest Go version or dependency versions

**Rejected because**:
- Latest version may not be desired (breaking changes)
- Requires external API calls (golang.org/dl, pkg.go.dev)
- May fail due to network issues
- Developers should consciously choose versions

**Solution**: Keep as CLI-only with clear error messages

### Why Split validate-changes?

**Before**: Single automation with optional `QUICK=true` flag

**After**: Two separate automations
- `validate-changes` - Full validation (default)
- `validate-changes-quick` - Skip unit tests

**Rationale**: 
- Common use case (quick feedback during development)
- No variables needed
- Clear intent from automation name

### Why Add check-outdated-deps?

**Problem**: Can't run `update-dependency` from Ona UI

**Solution**: Add automation that lists what needs updating
- Works from Ona UI (no variables needed)
- Shows current vs latest versions
- Provides copy-paste commands for CLI

**Benefit**: Discover what needs updating without CLI access

---

## Error Messages

When CLI-only automations are run from Ona UI, they show helpful error messages:

```
 This automation requires the GO_VERSION environment variable

  CLI Usage:
   GO_VERSION=1.25.4 gitpod automations task start update-go-version

📝 Or run the script directly with interactive prompts:
   .gitpod/scripts/update-go-version.sh

  Note: This automation cannot be run from the Ona UI
   Use the CLI or run the script directly instead
```

---

## Recommendations for Ona UI Users

### Daily Development Workflow (All from Ona UI)

1. **Before starting work**:
   - `start-network` - Start test network
   - `check-outdated-deps` - Check for updates

2. **During development**:
   - `validate-changes-quick` - Quick validation
   - `fix-typos` - Fix typos as you go
   - `fix-trailing-spaces` - Clean up formatting

3. **Before committing**:
   - `validate-changes` - Full validation
   - `validate-commit-message` - Check commit message

4. **After committing**:
   - `stop-network` - Clean up

### Release Workflow (Mix of UI and CLI)

1. **From Ona UI**:
   - `generate-changelog` - Generate changelog
   - `validate-changes` - Final validation
   - `test-integration-all` - Full test suite

2. **From CLI**:
   - `VERSION=3.1.4 gitpod automations task start prepare-release`
   - Follow release checklist

### Dependency Update Workflow

1. **From Ona UI**:
   - `check-outdated-deps` - See what's outdated

2. **From CLI** (copy commands from output):
   - `DEPENDENCY=... VERSION=... gitpod automations task start update-dependency`

3. **From Ona UI**:
   - `validate-changes` - Verify changes
   - `test-unit` - Run tests

---

## Future Improvements

### When Ona UI Supports Variables

If Ona UI adds support for environment variables:

1. **Remove "(CLI only)" from descriptions**
2. **Remove error message blocks**
3. **Keep interactive mode in scripts** (still useful for direct execution)
4. **Update this document** to reflect new capabilities

### Potential Enhancements

1. **Specific dependency automations** (no variables needed):
   - `update-golang-crypto-latest` - Update golang.org/x/crypto to latest
   - `update-docker-latest` - Update docker/docker to latest
   - Trade-off: More automations vs flexibility

2. **Version selection UI** (if Ona adds support):
   - Dropdown for Go versions
   - Dropdown for common dependencies
   - Would require Ona platform changes

---

## Summary

**28 of 31 automations (90%)** work perfectly from Ona UI with no limitations.

**3 automations (10%)** require CLI access but have workarounds:
- Clear error messages with instructions
- Interactive mode when run directly
- Helper automations to discover what needs updating

**Recommendation**: Use Ona UI for daily development workflow, CLI for version/dependency updates.

---

**Last Updated**: 2025-11-17  
**Status**: Optimized for Ona UI compatibility
