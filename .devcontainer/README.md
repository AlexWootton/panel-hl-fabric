# Hyperledger Fabric Dev Container

Dev Container configuration for Hyperledger Fabric development, aligned with Vagrant and CI environments.

## Configuration Files

- **`devcontainer.json`** - Dev Container configuration
- **`Dockerfile`** - Custom image with required tools
- **`setup-gh-token.sh`** - GitHub CLI authentication setup

See [DEPENDENCY_ALIGNMENT.md](./DEPENDENCY_ALIGNMENT.md) for details on environment consistency.

## Installed Tools

- **Go 1.25.3** - Matches go.mod requirement
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

### Rebuilding

After modifying configuration files:

```bash
# Via Gitpod CLI
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

**Go tools not found:**
```bash
echo $PATH  # Should include /home/vscode/go/bin
# If not, rebuild the container
```

**GitHub CLI issues:**
See [GITHUB_CLI_AUTH.md](./GITHUB_CLI_AUTH.md)

## Resources

- [Dev Container Specification](https://containers.dev/)
- [GitHub CLI Documentation](https://cli.github.com/manual/)
