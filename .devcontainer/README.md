# Hyperledger Fabric Dev Container

This directory contains the Dev Container configuration for Hyperledger Fabric development.

## Configuration Files

- **`devcontainer.json`** - Dev Container configuration
- **`Dockerfile`** - Custom image with required tools

## Installed Tools

### Core Development Tools
- **Go 1.25.3** - Go programming language
- **Make** - Build automation tool
- **Git** - Version control system

### Container & Orchestration
- **Docker** - Container runtime (via Docker-in-Docker feature)
- **Docker Compose v2** - Multi-container orchestration

### GitHub Integration
- **GitHub CLI (gh)** - GitHub command-line tool for PR management

### Utilities
- **curl** - HTTP client
- **jq** - JSON processor

## Features

### Docker-in-Docker
Enabled via the `ghcr.io/devcontainers/features/docker-in-docker:2` feature:
- Allows running Docker containers inside the dev container
- Required for Fabric test network
- Includes Docker Compose v2

### Environment Variables
- `FABRIC_CFG_PATH`: Points to `${containerWorkspaceFolder}/sampleconfig`
- `GOPATH`: Set to `/home/vscode/go`
- `PATH`: Includes `$GOPATH/bin` for Go tools (ginkgo, etc.)

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

The GitHub CLI is pre-installed and **automatically authenticated** using your Git credentials.

### Automatic Setup

On container start, a setup script automatically:
1. Extracts your GitHub token from Git credential helper
2. Sets the `GH_TOKEN` environment variable
3. Configures your shell profile for future sessions

No manual authentication required! You can immediately use:

```bash
# Create a PR
gh pr create --title "Your PR title" --body "Description"

# View PRs
gh pr list

# Check out a PR
gh pr checkout <number>

# View PR details
gh pr view <number>
```

### Troubleshooting

If `gh` commands fail with authentication errors:

```bash
# Run the setup script manually
bash ${containerWorkspaceFolder}/.devcontainer/setup-gh-token.sh

# Or reload your shell
exec bash
```

The setup script is located at `.devcontainer/setup-gh-token.sh` and runs automatically via `postStartCommand`.

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
