# Maintenance Automation Guide

Quick reference for automated maintenance tasks in Hyperledger Fabric.

## Quick Reference

### Ona UI Compatible (No Variables Required)

```bash
# Code Quality
gitpod automations task start fix-typos
gitpod automations task start fix-license-headers
gitpod automations task start fix-trailing-spaces
gitpod automations task start check-code

# Validation
gitpod automations task start validate-commit-message
gitpod automations task start check-outdated-deps

# Changelog
gitpod automations task start generate-changelog

# Security and Quality
gitpod automations task start scan-vulnerabilities
gitpod automations task start check-unused-deps
gitpod automations task start check-test-coverage
```

### CLI Only (Requires Variables)

```bash
# Go version update
GO_VERSION=1.25.4 gitpod automations task start update-go-version

# Dependency update
DEPENDENCY=golang.org/x/crypto VERSION=v0.44.0 gitpod automations task start update-dependency

# Release preparation
VERSION=3.1.4 gitpod automations task start prepare-release
```

## Core Maintenance

### Update Go Version (CLI Only)

Updates Go version across all Fabric files.

**Usage:**
```bash
GO_VERSION=1.25.4 gitpod automations task start update-go-version
```

**Files updated:**
- `go.mod` (root and tools/)
- `vagrant/golang.sh`
- `.devcontainer/Dockerfile`
- `docs/source/prereqs.md`
- `docs/source/dev-setup/devenv.rst`

**Post-update:**
```bash
git diff
make basic-checks
git commit -am "bump go to 1.25.4"
```

### Update Dependency (CLI Only)

Updates Go dependency and syncs vendor directory.

**Usage:**
```bash
DEPENDENCY=golang.org/x/crypto VERSION=v0.44.0 gitpod automations task start update-dependency
```

**Post-update:**
```bash
git diff
make basic-checks
git commit -am "bump golang.org/x/crypto to v0.44.0"
```

### Check Outdated Dependencies

Lists outdated dependencies with update commands.

**Usage:**
```bash
gitpod automations task start check-outdated-deps
```

## Code Quality

### Fix Typos

Auto-fixes typos in comments and documentation.

**Usage:**
```bash
gitpod automations task start fix-typos
```

**Post-fix:**
```bash
git diff
git commit -am "chore: fix typos in comments"
```

### Fix License Headers

Auto-adds missing SPDX license headers.

**Usage:**
```bash
gitpod automations task start fix-license-headers
```

**Post-fix:**
```bash
git diff
make license
git commit -am "chore: add missing SPDX license headers"
```

### Fix Trailing Spaces

Auto-removes trailing spaces from source files.

**Usage:**
```bash
gitpod automations task start fix-trailing-spaces
```

**Post-fix:**
```bash
git diff
git commit -am "chore: remove trailing spaces"
```

## Validation

### Validate Commit Message

Validates commit message format and conventions.

**Usage:**
```bash
gitpod automations task start validate-commit-message
```

**Checks:**
- Subject line length (max 72, recommended 50)
- Subject does not end with period
- Conventional commit format (optional)
- Signed-off-by line presence
- Co-authored-by for automation

## Security and Quality

### Scan Vulnerabilities

Runs govulncheck for CVE scanning.

**Usage:**
```bash
gitpod automations task start scan-vulnerabilities
```

### Check Unused Dependencies

Checks for unused vendored dependencies.

**Usage:**
```bash
gitpod automations task start check-unused-deps
```

### Check Test Coverage

Generates test coverage reports.

**Usage:**
```bash
gitpod automations task start check-test-coverage
```

## Release Management

### Prepare Release (CLI Only)

Generates release checklist and validates version.

**Usage:**
```bash
VERSION=3.1.4 gitpod automations task start prepare-release
```

**Checklist includes:**
- Pre-release validation
- Version updates
- Documentation updates
- Testing requirements
- Release process steps
- Post-release tasks

### Generate Changelog

Generates changelog entry from commits between tags.

**Usage:**
```bash
# Generate from last tag to HEAD
gitpod automations task start generate-changelog

# Save to file
.ona/scripts/generate-changelog-entry.sh v3.1.3 HEAD > CHANGELOG_ENTRY.md
```

**Categories:**
- Features
- Bug Fixes
- Documentation
- Refactoring
- Dependencies
- Tests
- Maintenance
- Other Changes

## Git Hooks

## Workflow Examples

### Update Go Version

```bash
GO_VERSION=1.25.4 gitpod automations task start update-go-version
gitpod automations task start validate-changes
git diff
git commit -am "bump go to 1.25.4"
```

### Update Dependency

```bash
DEPENDENCY=golang.org/x/crypto VERSION=v0.44.0 gitpod automations task start update-dependency
gitpod automations task start validate-changes-quick
git diff
git commit -am "bump golang.org/x/crypto to v0.44.0"
```

### Fix Code Quality Issues

```bash
gitpod automations task start fix-typos
gitpod automations task start fix-license-headers
gitpod automations task start fix-trailing-spaces
git diff
git commit -am "chore: fix code quality issues"
```

### Pre-Commit Validation

```bash
make basic-checks
git add .
git commit -m "your commit message"
```

## Direct Script Usage

All automations can be run directly:

```bash
.ona/scripts/update-go-version.sh 1.25.4
.ona/scripts/update-dependency.sh golang.org/x/crypto v0.44.0
.ona/scripts/fix-typos.sh
.ona/scripts/prepare-release.sh 3.1.4
```

## Troubleshooting

### Permission Denied

```bash
chmod +x .ona/scripts/*.sh
```

### Automation Task Not Found

```bash
gitpod automations update .ona/automations.yaml
gitpod automations task list
```

### Validation Fails

Run individual checks:
```bash
make basic-checks
make verify
go mod tidy
go mod vendor
```

## Best Practices

1. Always validate before committing:
   ```bash
   make basic-checks
   ```

2. Test changed packages:
   ```bash
   make verify
   ```

3. Review changes before committing:
   ```bash
   git diff
   ```

4. Follow PR naming conventions:
   - Go version: "bump go to X.Y.Z"
   - Dependency: "bump <dependency> to <version>"
   - Typos: "chore: fix typos in comments"

## Time Savings

| Task | Manual | Automated | Savings | Frequency |
|------|--------|-----------|---------|-----------|
| Go version update | 30 min | 5 min | 25 min | 4-6/year |
| Dependency update | 15 min | 5 min | 10 min | 30-40/year |
| License header fix | 20 min | 5 min | 15 min | 5-10/year |
| Trailing space fix | 10 min | 2 min | 8 min | 10-15/year |
| Typo fix | 15 min | 5 min | 10 min | 10-15/year |
| Pre-commit validation | 15 min | 10 min | 5 min | Continuous |
| Changelog generation | 60 min | 30 min | 30 min | 4-6/year |
| Release preparation | 60 min | 30 min | 30 min | 4-6/year |

**Annual savings:** 50-60 hours

## Related Documentation

- **README.md** - Ona environment setup and development guide
- **VALIDATION.md** - Network validation guide
- **AGENTS.md** - AI agent development guide
- **Makefile** - Build system reference
