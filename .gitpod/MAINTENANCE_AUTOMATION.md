# Maintenance Automation Guide

Quick reference for automated maintenance tasks in Hyperledger Fabric.

** Ona UI Limitation**: Some automations require environment variables and can only be run from CLI. See [ONA_UI_COMPATIBILITY.md](ONA_UI_COMPATIBILITY.md) for details.

---

## Available Automations

### Core Maintenance (Phase 1)

### 1. Update Go Version (ENHANCED)  CLI Only

**Purpose**: Update Go version across all Fabric files in one command.

** Requires CLI**: This automation needs the `GO_VERSION` variable and cannot be run from Ona UI.

**Usage**:
```bash
# CLI with variable
GO_VERSION=1.25.4 gitpod automations task start update-go-version

# Or run directly with interactive prompts
.gitpod/scripts/update-go-version.sh
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

### 2. Update Go Dependency  CLI Only

**Purpose**: Update a Go dependency and sync vendor directory.

** Requires CLI**: This automation needs `DEPENDENCY` and `VERSION` variables and cannot be run from Ona UI.

**Usage**:
```bash
# CLI with variables
DEPENDENCY=github.com/pkg/errors VERSION=v0.9.1 gitpod automations task start update-dependency

# Or run directly with interactive prompts
.gitpod/scripts/update-dependency.sh

# Or check what's outdated first (works from Ona UI)
gitpod automations task start check-outdated-deps
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

### 4. Validate Changes  Works from Ona UI

**Purpose**: Run pre-commit validation checks (same as CI).

**Usage**:
```bash
# Full validation (includes unit tests)
gitpod automations task start validate-changes

# Quick validation (skip unit tests) - NEW!
gitpod automations task start validate-changes-quick
```

**Checks performed**:
1.  `go.mod` is tidy
2.  `vendor/` is in sync
3.  License headers present
4.  No spelling errors
5.  Linting passes
6.  Unit tests pass (unless --quick)

**When to use**:
- Before every commit
- After updating dependencies
- After making code changes

**Time saved**: ~5 minutes per commit (catches issues early)

---

### 5. Prepare Release  CLI Only

**Purpose**: Generate release checklist and validate version.

** Requires CLI**: This automation needs the `VERSION` variable and cannot be run from Ona UI.

**Usage**:
```bash
# CLI with variable
VERSION=3.1.4 gitpod automations task start prepare-release

# Or run directly with interactive prompts
.gitpod/scripts/prepare-release.sh
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

### Quality Gates (Phase 2A)

### 6. Check Outdated Dependencies  Works from Ona UI (NEW!)

**Purpose**: List outdated Go dependencies and show update commands.

**Usage**:
```bash
# Check from Ona UI or CLI
gitpod automations task start check-outdated-deps
```

**What it does**:
1. Scans all Go dependencies
2. Compares current vs latest versions
3. Shows update commands for each outdated dependency

**Output example**:
```
 Outdated dependencies found:

  📌 golang.org/x/crypto
     Current: v0.43.0
     Latest:  v0.44.0
     Update:  DEPENDENCY=golang.org/x/crypto VERSION=v0.44.0 gitpod automations task start update-dependency
```

**When to use**:
- Weekly dependency checks
- Before releases
- After security advisories

**Time saved**: ~15 minutes per check (automated discovery)

---

### 7. Fix License Headers

**Purpose**: Auto-add missing SPDX license headers to source files.

**Usage**:
```bash
# Check for missing headers
.gitpod/scripts/fix-license-headers.sh --check-only

# Auto-fix missing headers
gitpod automations task start fix-license-headers
```

**What it does**:
1. Scans Go and shell script files
2. Detects missing SPDX-License-Identifier headers
3. Adds appropriate headers based on file type
4. Handles shebang lines correctly

**Post-fix steps**:
1. Review changes: `git diff`
2. Validate: `make license`
3. Commit: `git commit -am "chore: add missing SPDX license headers"`

**Time saved**: ~15 minutes per fix (prevents CI failures)

---

### 8. Fix Trailing Spaces

**Purpose**: Auto-remove trailing spaces from source files.

**Usage**:
```bash
# Check for trailing spaces
.gitpod/scripts/fix-trailing-spaces.sh --check-only

# Auto-fix trailing spaces
gitpod automations task start fix-trailing-spaces
```

**What it does**:
1. Scans source files (Go, shell, YAML, Markdown)
2. Detects trailing spaces
3. Removes trailing spaces

**Post-fix steps**:
1. Review changes: `git diff`
2. Validate: `make trailing-spaces`
3. Commit: `git commit -am "chore: remove trailing spaces"`

**Time saved**: ~10 minutes per fix (prevents CI failures)

---

### 9. Validate Commit Message

**Purpose**: Validate commit message format and conventions.

**Usage**:
```bash
# Validate last commit
gitpod automations task start validate-commit-message

# Validate specific message
MESSAGE="bump go to 1.25.4" gitpod automations task start validate-commit-message
```

**What it checks**:
1. Subject line length (max 72, recommended 50)
2. Subject doesn't end with period
3. Conventional commit format (optional)
4. Signed-off-by line presence
5. Co-authored-by for automation

**When to use**:
- Before creating PR
- After writing commit message
- As part of git hooks

**Time saved**: ~5 minutes per commit (catches format issues early)

---

### 10. Generate Changelog

**Purpose**: Generate changelog entry from commits between tags.

**Usage**:
```bash
# Generate from last tag to HEAD
gitpod automations task start generate-changelog

# Generate between specific tags
SINCE_TAG=v3.1.3 UNTIL_TAG=HEAD gitpod automations task start generate-changelog

# Save to file
.gitpod/scripts/generate-changelog-entry.sh v3.1.3 HEAD > CHANGELOG_ENTRY.md
```

**What it does**:
1. Extracts commits between tags
2. Categorizes by type (features, fixes, docs, etc.)
3. Formats as markdown
4. Provides statistics

**Categories**:
- Features
- Bug Fixes
- Documentation
- Refactoring
- Dependencies
- Tests
- Maintenance
- Other Changes

**Time saved**: ~30 minutes per release (automated categorization)

---

### 11. Install Git Hooks

**Purpose**: Install pre-push and commit-msg validation hooks.

**Usage**:
```bash
# Install hooks
gitpod automations task start install-git-hooks

# Uninstall hooks
.gitpod/scripts/install-git-hooks.sh --uninstall
```

**Hooks installed**:
1. **pre-push**: Runs quick validation before pushing
   - Checks go.mod, vendor, license, spelling, trailing spaces, linting
   - Skips unit tests for speed
   - Can bypass with `git push --no-verify`

2. **commit-msg**: Validates commit message format
   - Checks message format and conventions
   - Can bypass with `git commit --no-verify`

**When to use**:
- One-time setup for development environment
- Catches issues before pushing to remote
- Enforces commit message standards

**Time saved**: ~10 hours/year (prevents push-fix-push cycles)

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

| Task | Manual Time | Automated Time | Savings | Frequency |
|------|-------------|----------------|---------|-----------|
| Go version update | 30 min | 5 min | 25 min | 4-6/year |
| Dependency update | 15 min | 5 min | 10 min | 30-40/year |
| License header fix | 20 min | 5 min | 15 min | 5-10/year |
| Trailing space fix | 10 min | 2 min | 8 min | 10-15/year |
| Typo fix | 15 min | 5 min | 10 min | 10-15/year |
| Pre-commit validation | 15 min | 10 min | 5 min | Continuous |
| Commit message validation | 10 min | 2 min | 8 min | Continuous |
| Changelog generation | 60 min | 30 min | 30 min | 4-6/year |
| Release preparation | 60 min | 30 min | 30 min | 4-6/year |
| Git hooks (one-time) | 30 min | 5 min | 25 min | One-time |

**Annual savings**: 40-50 hours (Phase 1 + Phase 2A combined)

---

## Related Documentation

- **AUTOMATION_OPPORTUNITIES.md** - Full analysis and implementation details
- **AGENTS.md** - AI agent development guide
- **README.md** - Ona environment setup
- **Makefile** - Build system reference

---

**Last Updated**: 2025-11-17  
**Maintained By**: Ona Development Team
