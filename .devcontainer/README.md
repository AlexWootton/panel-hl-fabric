# Hyperledger Fabric Dev Container

Dev Container configuration for Hyperledger Fabric development. This environment is aligned with Vagrant and CI configurations to ensure consistent builds and tests across all platforms.

## Configuration Files

- **`devcontainer.json`** - Dev Container configuration
- **`Dockerfile`** - Custom image with required tools
- **`setup-gh-token.sh`** - GitHub CLI authentication setup

## Installed Tools

- **Go** - Version automatically extracted from go.mod (currently 1.25.3)
- **Docker-in-Docker** - Container runtime with Docker Compose v2
- **GitHub CLI (gh)** - Automatically authenticated for PR management
- **SoftHSM2** - Software HSM for PKCS#11 testing
- **Build tools** - make, gcc, g++, git
- **Utilities** - curl, jq, file, unzip

## Environment Variables

- `FABRIC_CFG_PATH` - Points to `sampleconfig/`
- `GOPATH` - Set to `/home/vscode/go`
- `PATH` - Includes Go binaries
- `PKCS11_LIB` - Path to SoftHSM2 library (auto-detected)
- `PKCS11_PIN` - PIN for PKCS#11 token (98765432)
- `PKCS11_LABEL` - Label for PKCS#11 token (ForFabric)

## Quick Start

The container is ready to use immediately. All tools and authentication are configured automatically.

### GitHub CLI

The GitHub CLI is **automatically authenticated** using your Git credentials.

See [GITHUB_CLI_AUTH.md](./GITHUB_CLI_AUTH.md) for usage and troubleshooting.

## Common Workflows

### Updating Go Version

The Go version must be kept in sync between `go.mod` and `.devcontainer/Dockerfile`. To update:

1. **Update go.mod:**
   ```bash
   # Edit go.mod, change: go 1.25.3 → go 1.26.0
   go mod tidy
   ```

2. **Update Dockerfile:**
   ```bash
   # Edit .devcontainer/Dockerfile
   # Change: ARG GO_VERSION=1.25.3 → ARG GO_VERSION=1.26.0
   ```

3. **Rebuild (automatic prompt):**
   
   Ona will detect the Dockerfile change and prompt: **"Container configuration changed. Rebuild?"**
   
   Click "Rebuild" or run manually:
   ```bash
   gitpod environment devcontainer rebuild
   ```
   
   The rebuild process (~2-5 minutes):
   - Downloads and installs the specified Go version
   - Preserves your workspace files and git state
   - Resets installed packages and shell history

4. **Verify the new version:**
   ```bash
   go version
   # Or run the full validation suite:
   make basic-checks
   ```

**Why two places?** Keeping the version in the Dockerfile allows Ona to detect changes and automatically prompt for rebuild. This provides better UX than requiring users to remember to rebuild manually.

### Rebuilding the Container

Rebuild when you modify:
- `go.mod` (Go version)
- `.devcontainer/Dockerfile`
- `.devcontainer/devcontainer.json`

```bash
# Via Gitpod CLI (recommended)
gitpod environment devcontainer rebuild

# Or via VS Code Command Palette
# Ctrl+Shift+P → "Dev Containers: Rebuild Container"
```

## Troubleshooting

**Docker not available:**
```bash
docker info  # Check status
sudo systemctl restart docker  # Restart if needed
```

**Go version mismatch:**
```bash
go version  # Check current version
grep "^go " go.mod  # Check required version
# If mismatch, update Dockerfile and rebuild
```

**Go tools not found:**
```bash
echo $PATH  # Should include /home/vscode/go/bin
# If not, rebuild the container
```

**SoftHSM2 not working:**
```bash
softhsm2-util --show-slots  # Should show slot 0 with label "ForFabric"
echo $PKCS11_LIB  # Should show path to libsofthsm2.so
# If empty, restart the container
```

**Build or test failures:**
```bash
make basic-checks  # Run full validation suite
# This checks Go version, linting, licenses, etc.
```

**GitHub CLI issues:**
See [GITHUB_CLI_AUTH.md](./GITHUB_CLI_AUTH.md)

## Resources

- [Dev Container Specification](https://containers.dev/)
- [GitHub CLI Documentation](https://cli.github.com/manual/)
