# Maintenance Automation Guide

Quick reference for automated maintenance tasks in Hyperledger Fabric.

---

## Available Automations

### 1. Update Go Version

**Purpose**: Update Go version across all Fabric files in one command.

**Usage**:
```bash
GO_VERSION=1.25.4 gitpod automations task start update-go-version
```

**Files updated**:
- `go.mod` (root and tools/)
- `vagrant/golang.sh`
- `.devcontainer/Dockerfile`
- `docs/source/prereqs.md`
- `docs/source/dev-setup/devenv.rst`

**Post-update steps**:
1. Review changes: `git diff`
2. Validate: `gitpod automations task start validate-changes`
3. Commit: `git commit -am "bump go to 1.25.4"`
4. Create PR with title: "bump go to 1.25.4"

**Time saved**: ~25 minutes per update (6 files + validation)

---

### 2. Update Go Dependency

**Purpose**: Update a Go dependency and sync vendor directory.

**Usage**:
```bash
DEPENDENCY=github.com/pkg/errors VERSION=v0.9.1 gitpod automations task start update-dependency
```

**Common dependencies**:
- `github.com/consensys/gnark-crypto`
- `github.com/docker/docker`
- `golang.org/x/crypto`
- `golang.org/x/net`

**What it does**:
1. Runs `go get <dependency>@<version>`
2. Runs `go mod tidy`
3. Updates `tools/go.mod` if needed
4. Runs `go mod vendor`

**Post-update steps**:
1. Review changes: `git diff`
2. Validate: `gitpod automations task start validate-changes`
3. Commit: `git commit -am "bump <dependency> to <version>"`
4. Create PR with title: "bump <dependency> to <version>"

**Time saved**: ~10 minutes per update

---

### 3. Fix Typos

**Purpose**: Detect and auto-fix typos in comments and documentation.

**Usage**:
```bash
# Auto-fix typos
gitpod automations task start fix-typos

# Check only (don't fix)
.gitpod/scripts/fix-typos.sh --check-only
```

**What it does**:
1. Runs `make spelling` to detect typos
2. Auto-fixes using `misspell -w`
3. Shows modified files

**Post-fix steps**:
1. Review changes: `git diff`
2. Commit: `git commit -am "chore: fix typos in comments"`
3. Create PR with title: "chore: fix typos in comments"

**Time saved**: ~10 minutes per fix

---

### 4. Validate Changes

**Purpose**: Run pre-commit validation checks (same as CI).

**Usage**:
```bash
# Full validation (includes unit tests)
gitpod automations task start validate-changes

# Quick validation (skip unit tests)
QUICK=true gitpod automations task start validate-changes
```

**Checks performed**:
1. ✅ `go.mod` is tidy
2. ✅ `vendor/` is in sync
3. ✅ License headers present
4. ✅ No spelling errors
5. ✅ Linting passes
6. ✅ Unit tests pass (unless --quick)

**When to use**:
- Before every commit
- After updating dependencies
- After making code changes

**Time saved**: ~5 minutes per commit (catches issues early)

---

### 5. Prepare Release

**Purpose**: Generate release checklist and validate version.

**Usage**:
```bash
VERSION=3.1.4 gitpod automations task start prepare-release
```

**What it does**:
1. Generates comprehensive release checklist
2. Validates version format
3. Checks if version exists in Makefile
4. Checks if git tag already exists
5. Shows current branch and uncommitted changes

**Checklist includes**:
- Pre-release validation
- Version updates
- Documentation updates
- Testing requirements
- Release process steps
- Post-release tasks

**Time saved**: ~30 minutes per release (comprehensive checklist)

---

## Workflow Examples

### Example 1: Update Go Version

```bash
# 1. Update Go version
GO_VERSION=1.25.4 gitpod automations task start update-go-version

# 2. Validate changes
gitpod automations task start validate-changes

# 3. Review and commit
git diff
git commit -am "bump go to 1.25.4"

# 4. Create PR
# (use GitHub CLI or web interface)
```

### Example 2: Update Dependency

```bash
# 1. Update dependency
DEPENDENCY=golang.org/x/crypto VERSION=v0.44.0 gitpod automations task start update-dependency

# 2. Quick validation
QUICK=true gitpod automations task start validate-changes

# 3. Review and commit
git diff
git commit -am "bump golang.org/x/crypto to v0.44.0"

# 4. Create PR
```

### Example 3: Fix Typos

```bash
# 1. Check for typos
.gitpod/scripts/fix-typos.sh --check-only

# 2. Auto-fix if found
gitpod automations task start fix-typos

# 3. Review and commit
git diff
git commit -am "chore: fix typos in comments"

# 4. Create PR
```

### Example 4: Pre-Commit Validation

```bash
# Before committing any changes
gitpod automations task start validate-changes

# If validation passes
git add .
git commit -m "your commit message"
```

---

## Direct Script Usage

All automations can also be run directly:

```bash
# Update Go version
.gitpod/scripts/update-go-version.sh 1.25.4

# Update dependency
.gitpod/scripts/update-dependency.sh github.com/pkg/errors v0.9.1

# Fix typos
.gitpod/scripts/fix-typos.sh

# Validate changes
.gitpod/scripts/validate-changes.sh
.gitpod/scripts/validate-changes.sh --quick

# Prepare release
.gitpod/scripts/prepare-release.sh 3.1.4
```

---

## Troubleshooting

### Permission Denied

```bash
chmod +x .gitpod/scripts/*.sh
```

### Automation Task Not Found

```bash
gitpod automations update .gitpod/automations.yaml
gitpod automations task list
```

### Validation Fails

Run individual checks:
```bash
make basic-checks  # License, spelling, linting
make verify        # Unit tests for changed packages
go mod tidy        # Fix go.mod
go mod vendor      # Fix vendor/
```

### Typo Fix Doesn't Work

Ensure misspell is installed:
```bash
go install github.com/client9/misspell/cmd/misspell@latest
```

---

## Best Practices

1. **Always validate before committing**
   ```bash
   gitpod automations task start validate-changes
   ```

2. **Use quick validation for fast feedback**
   ```bash
   QUICK=true gitpod automations task start validate-changes
   ```

3. **Review changes before committing**
   ```bash
   git diff
   ```

4. **Follow PR naming conventions**
   - Go version: "bump go to X.Y.Z"
   - Dependency: "bump <dependency> to <version>"
   - Typos: "chore: fix typos in comments"

5. **Run full validation before creating PR**
   ```bash
   gitpod automations task start validate-changes
   ```

---

## Time Savings Summary

| Task | Manual Time | Automated Time | Savings |
|------|-------------|----------------|---------|
| Go version update | 30 min | 5 min | 25 min |
| Dependency update | 15 min | 5 min | 10 min |
| Typo fix | 15 min | 5 min | 10 min |
| Pre-commit validation | 15 min | 10 min | 5 min |
| Release preparation | 60 min | 30 min | 30 min |

**Annual savings**: 25-35 hours (based on typical update frequency)

---

## Related Documentation

- **AUTOMATION_OPPORTUNITIES.md** - Full analysis and implementation details
- **AGENTS.md** - AI agent development guide
- **README.md** - Ona environment setup
- **Makefile** - Build system reference

---

**Last Updated**: 2025-11-17  
**Maintained By**: Ona Development Team
