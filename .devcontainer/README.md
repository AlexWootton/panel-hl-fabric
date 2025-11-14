# Hyperledger Fabric Dev Container

This directory contains the Dev Container configuration for Hyperledger Fabric development.

## Configuration Files

- **`devcontainer.json`** - Dev Container configuration
- **`Dockerfile`** - Custom image with required tools

## Dependency Alignment

This dev container configuration is aligned with:
- **Vagrant setup** (`vagrant/` directory) - Same Go version, build tools, and SoftHSM2
- **CI workflows** (`.github/workflows/`) - Uses `go-version-file: go.mod` approach
- **Project requirements** (`go.mod`) - Go 1.25.3 with toolchain directive

All three environments now provide consistent tooling for Fabric development.

## Installed Tools

### Core Development Tools
- **Go 1.25.3** - Go programming language (matches go.mod requirement)
- **Make** - Build automation tool
- **Git** - Version control system
- **Build Essential** - GCC, G++, and other build tools

### Container & Orchestration
- **Docker** - Container runtime (via Docker-in-Docker feature)
- **Docker Compose v2** - Multi-container orchestration

### GitHub Integration
- **GitHub CLI (gh)** - GitHub command-line tool for PR management

### Security & Cryptography
- **SoftHSM2** - Software implementation of HSM for PKCS#11 testing

### Utilities
- **curl** - HTTP client
- **jq** - JSON processor
- **file** - File type identification (required by code checks)
- **unzip** - Archive extraction

## Features

### Docker-in-Docker
Enabled via the `ghcr.io/devcontainers/features/docker-in-docker:2` feature:
- Allows running Docker containers inside the dev container
- Required for Fabric test network
- Includes Docker Compose v2

### Environment Variables
- `FABRIC_CFG_PATH`: Points to `${containerWorkspaceFolder}/sampleconfig`
- `GOPATH`: Set to `/home/vscode/go`
- `PATH`: Includes `$GOPATH/bin` and `/usr/local/go/bin` for Go tools
- `PKCS11_LIB`: Path to SoftHSM2 library (auto-detected)
- `PKCS11_PIN`: PIN for PKCS#11 token (98765432)
- `PKCS11_LABEL`: Label for PKCS#11 token (ForFabric)

### VS Code Extensions
- **golang.go** - Go language support

## Rebuilding the Container

After modifying the configuration:

1. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
2. Select "Dev Containers: Rebuild Container"
3. Wait for rebuild to complete

Or use the Gitpod CLI:
```bash
gitpod environment devcontainer rebuild
```

## GitHub CLI Authentication

The GitHub CLI is pre-installed and **automatically authenticated** using your Git credentials. No manual setup required!

See [GITHUB_CLI_AUTH.md](./GITHUB_CLI_AUTH.md) for usage examples and troubleshooting.

## Customization

To add more tools, edit the `Dockerfile`:

```dockerfile
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    your-package-here \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

To add VS Code extensions, edit `devcontainer.json`:

```json
"customizations": {
  "vscode": {
    "extensions": [
      "golang.go",
      "your-extension-id"
    ]
  }
}
```

## Troubleshooting

### Docker Not Available
If Docker is not available after rebuild:
```bash
# Check Docker status
docker info

# Restart Docker service
sudo systemctl restart docker
```

### Go Tools Not in PATH
If Go tools (like ginkgo) are not found:
```bash
# Check PATH
echo $PATH

# Should include /home/vscode/go/bin
# If not, rebuild the container
```

### GitHub CLI Not Authenticated
```bash
# Check auth status
gh auth status

# Login if needed
gh auth login
```

## Resources

- [Dev Container Specification](https://containers.dev/)
- [Docker-in-Docker Feature](https://github.com/devcontainers/features/tree/main/src/docker-in-docker)
- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
