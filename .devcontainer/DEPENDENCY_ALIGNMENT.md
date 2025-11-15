# Dev Container Dependency Alignment

## Overview

This document explains the dependency alignment between Vagrant, CI, and the Dev Container environments for Hyperledger Fabric development.

## Comparison Matrix

| Dependency | Vagrant | CI (GitHub Actions) | Dev Container | Status |
|------------|---------|---------------------|---------------|--------|
| **Go Version** | 1.25.3 (explicit) | 1.25.3 (from go.mod) | 1.25.3 (explicit) | ✅ Aligned |
| **Build Tools** | build-essential, g++, make | Pre-installed | build-essential, g++, make | ✅ Aligned |
| **SoftHSM2** | ✅ Installed | ✅ Installed | ✅ Installed | ✅ Aligned |
| **Docker** | docker.io | Pre-installed | Docker-in-Docker | ✅ Aligned |
| **file utility** | ✅ (implicit) | Pre-installed | ✅ Installed | ✅ Aligned |
| **curl, jq** | ✅ Installed | Pre-installed | ✅ Installed | ✅ Aligned |
| **unzip** | ✅ Installed | Pre-installed | ✅ Installed | ✅ Aligned |
| **Git** | ✅ Installed | Pre-installed | ✅ Installed | ✅ Aligned |

## Key Changes Made

### 1. Go Version Management
**Problem:** Dockerfile was installing `golang-go` from Ubuntu repos (Go 1.22.2), but project requires Go 1.25.3. Additionally, the Go version was hardcoded in the Dockerfile, requiring manual sync with go.mod.

**Solution:** 
- Extract Go version from `go.mod` at build time (single source of truth)
- Download and install Go directly from go.dev
- Add symlinks to `/usr/local/bin` for easy access
- Aligns with CI's `go-version-file: go.mod` approach

**Impact:** 
- Eliminates manual version synchronization
- Prevents version drift between environments
- Matches CI and Vagrant approaches

### 2. Missing Dependencies Added

#### file utility
**Problem:** `scripts/check_trailingspaces.sh` uses `file` command to detect ASCII text files, but it wasn't installed.

**Solution:** Added `file` package to Dockerfile.

**Evidence:** Check-code automation was showing errors:
```
scripts/check_trailingspaces.sh: line 9: file: command not found
```

#### SoftHSM2
**Problem:** PKCS#11/HSM tests require SoftHSM2, which was missing from dev container.

**Solution:** 
- Install `softhsm2` package
- Initialize token with label "ForFabric" and PIN 98765432
- Set environment variables (PKCS11_LIB, PKCS11_PIN, PKCS11_LABEL)
- Matches Vagrant and CI setup exactly

#### Build Tools
**Problem:** Some packages may require compilation from source.

**Solution:** Added `build-essential`, `g++`, and `unzip` to match Vagrant setup.

### 3. Toolchain Configuration

**Problem:** When using Ubuntu's Go 1.22.2, Go's automatic toolchain selection would sometimes use Go 1.24.10 when building tools like staticcheck, causing version mismatch errors.

**Solution:**
- Install Go 1.25.3 directly in the Dockerfile (not from Ubuntu repos)
- Add `/usr/local/go/bin` to PATH with higher precedence
- No toolchain directive or GOTOOLCHAIN environment variable needed

**Impact:** With the correct Go version in PATH, all tools build with Go 1.25.3 automatically. This is the same approach used by Vagrant.

## Environment Variables

### Vagrant Setup
```bash
export GOROOT=/opt/go
export PATH=$PATH:$GOROOT/bin
export GOPATH=$HOME/go
export PATH=$PATH:$HOME/go/bin
export PKCS11_LIB="$(find /usr/lib -name libsofthsm2.so | head -1)"
export PKCS11_PIN=98765432
export PKCS11_LABEL="ForFabric"
```

### Dev Container Setup
```json
{
  "FABRIC_CFG_PATH": "${containerWorkspaceFolder}/sampleconfig",
  "GOPATH": "/home/vscode/go",
  "PATH": "${containerEnv:PATH}:/home/vscode/go/bin:/usr/local/go/bin",
  "PKCS11_PIN": "98765432",
  "PKCS11_LABEL": "ForFabric"
}
```

Note: `PKCS11_LIB` is set dynamically via `postCreateCommand` to match Vagrant's approach.

## CI Workflow Alignment

The GitHub Actions workflow uses:
```yaml
- uses: actions/setup-go@v5
  with:
    go-version-file: go.mod
```

This automatically reads the Go version from `go.mod`, ensuring CI always uses the correct version.

Our dev container now explicitly installs the same version, providing consistency across all environments.

## Testing the Changes

### Verify Go Version
```bash
go version
# Should output: go version go1.25.3 linux/amd64
```

### Verify SoftHSM2
```bash
softhsm2-util --show-slots
# Should show slot 0 with label "ForFabric"

echo $PKCS11_LIB
# Should output path to libsofthsm2.so
```

### Verify Build Tools
```bash
make basic-checks
# Should pass without errors about missing 'file' command
```

### Verify Toolchain
```bash
staticcheck -debug.version
# Should show: Compiled with Go version: go1.25.3
```

## Benefits

1. **Consistency** - All development environments (Vagrant, CI, Dev Container) now have identical dependencies
2. **Reliability** - No more missing dependencies causing test failures
3. **Performance** - Direct Go installation eliminates toolchain auto-download overhead
4. **Maintainability** - Single source of truth for Go version (go.mod)
5. **Testing** - PKCS#11 tests can now run in dev container

## GitHub CLI Authentication

The dev container includes automatic GitHub CLI authentication via `setup-gh-token.sh`:
- Extracts token from Gitpod's git credential helper
- Sets `GH_TOKEN` environment variable
- Idempotent (skips if already configured)
- Runs once per container via `postCreateCommand`

This provides seamless `gh` CLI access without manual authentication.

## Future Maintenance

When updating Go version:
1. Update `go.mod` (go directive) - **This is the single source of truth**
2. Update `vagrant/golang.sh` (GO_VERSION variable)
3. Dev container and CI will automatically pick up the change from go.mod

**Automatic Version Detection:**
- **Dev Container**: Extracts Go version from `go.mod` at build time
- **CI**: Uses `go-version-file: go.mod` in GitHub Actions
- **Vagrant**: Requires manual update (GO_VERSION variable)

Note: `tools/go.mod` will be updated automatically when you run `go mod tidy` in the tools directory.

## References

- Vagrant setup: `vagrant/` directory
- CI workflows: `.github/workflows/verify-build.yml`
- Dev container: `.devcontainer/` directory
- Go toolchain docs: https://go.dev/doc/toolchain
