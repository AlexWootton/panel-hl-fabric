# Ona Development Environment Documentation Index

This directory contains all documentation related to the Ona (Gitpod) development environment for Hyperledger Fabric.

## Quick Start

**New to this environment?** Start here:
1. Read [README.md](./README.md) - Quick start and setup guide
2. Review [SETUP_SUMMARY.md](./SETUP_SUMMARY.md) - Quick reference

## Documentation Files

### Getting Started
- **[README.md](./README.md)** - Quick start guide, available tools, and basic usage
- **[SETUP_SUMMARY.md](./SETUP_SUMMARY.md)** - Quick reference for setup and common commands

### Automation System
- **[TRIGGERS.md](./TRIGGERS.md)** - Comprehensive guide to automation triggers and design philosophy
- **[TRIGGERS_SUMMARY.md](./TRIGGERS_SUMMARY.md)** - Executive summary of trigger configuration
- **[AUTOMATIONS_ADDITIONS.md](./AUTOMATIONS_ADDITIONS.md)** - Details about additional automation features
- **[automations.yaml](./automations.yaml)** - Automation task definitions

### Technical Reports
- **[SERVICE_VALIDATION_REPORT.md](./SERVICE_VALIDATION_REPORT.md)** - Validation of fabric-network service (and why it was removed)
- **[VERIFICATION_RESULTS.md](./VERIFICATION_RESULTS.md)** - Complete testing and verification results

## Dev Container Documentation

Located in `../.devcontainer/`:
- **[README.md](../.devcontainer/README.md)** - Dev container configuration and tools
- **[GH_AUTH_SETUP.md](../.devcontainer/GH_AUTH_SETUP.md)** - GitHub CLI automatic authentication guide
- **[Dockerfile](../.devcontainer/Dockerfile)** - Container image definition
- **[devcontainer.json](../.devcontainer/devcontainer.json)** - Dev container configuration
- **[setup-gh-token.sh](../.devcontainer/setup-gh-token.sh)** - Automatic authentication script

## Project Guidelines

Located in repository root:
- **[AGENTS.md](../AGENTS.md)** - Project guidelines for Ona Agent and developers

## Documentation by Topic

### Setting Up Your Environment
1. [README.md](./README.md) - Environment overview
2. [SETUP_SUMMARY.md](./SETUP_SUMMARY.md) - Setup steps
3. [../.devcontainer/README.md](../.devcontainer/README.md) - Dev container details

### Using Automations
1. [README.md](./README.md#available-automations) - Available tasks
2. [TRIGGERS.md](./TRIGGERS.md) - How triggers work
3. [AUTOMATIONS_ADDITIONS.md](./AUTOMATIONS_ADDITIONS.md) - Additional features

### Understanding Design Decisions
1. [TRIGGERS.md](./TRIGGERS.md) - Trigger design philosophy
2. [SERVICE_VALIDATION_REPORT.md](./SERVICE_VALIDATION_REPORT.md) - Why no service for Fabric network
3. [VERIFICATION_RESULTS.md](./VERIFICATION_RESULTS.md) - Testing methodology

### GitHub CLI Integration
1. [../.devcontainer/GH_AUTH_SETUP.md](../.devcontainer/GH_AUTH_SETUP.md) - Complete authentication guide
2. [README.md](./README.md#using-github-cli) - Quick usage
3. [../.devcontainer/README.md](../.devcontainer/README.md#github-cli-authentication) - Troubleshooting

## Quick Reference

### Common Commands

```bash
# List all automation tasks
gitpod automations task list

# Start test network
gitpod automations task start start-test-network

# Deploy chaincode
gitpod automations task start deploy-chaincode

# Stop test network
gitpod automations task start stop-test-network

# Create a PR
gh pr create --title "Title" --body "Description"
```

### File Locations

```
.
├── .devcontainer/          # Dev container configuration
│   ├── README.md          # Dev container docs
│   ├── GH_AUTH_SETUP.md   # GitHub CLI auth guide
│   ├── Dockerfile         # Container image
│   ├── devcontainer.json  # Configuration
│   └── setup-gh-token.sh  # Auth script
│
├── .gitpod/               # Ona automation configuration
│   ├── README.md          # Quick start guide
│   ├── README_INDEX.md    # This file
│   ├── TRIGGERS.md        # Trigger documentation
│   ├── SETUP_SUMMARY.md   # Quick reference
│   ├── automations.yaml   # Task definitions
│   └── ...                # Additional docs
│
└── AGENTS.md              # Project guidelines
```

## Getting Help

### Documentation Issues
If you find issues with the documentation:
1. Check the [troubleshooting sections](./README.md#troubleshooting)
2. Review [VERIFICATION_RESULTS.md](./VERIFICATION_RESULTS.md) for known issues
3. Open an issue on GitHub

### Environment Issues
If you encounter environment problems:
1. Check [../.devcontainer/README.md](../.devcontainer/README.md#troubleshooting)
2. Review [README.md](./README.md#troubleshooting)
3. Try rebuilding the dev container

### Automation Issues
If automations aren't working:
1. Validate configuration: `gitpod automations validate .gitpod/automations.yaml`
2. Check task logs: `gitpod automations task logs <task-name>`
3. Review [TRIGGERS.md](./TRIGGERS.md) for expected behavior

## Contributing

When adding new automations or documentation:
1. Update [automations.yaml](./automations.yaml)
2. Document in [README.md](./README.md)
3. Add detailed explanation to [TRIGGERS.md](./TRIGGERS.md) if needed
4. Update this index if adding new files

## Version History

This documentation was created as part of the Ona development environment setup:
- Initial setup: 2025-11-13
- GitHub CLI integration: 2025-11-14
- Documentation reorganization: 2025-11-14

See commit history for detailed changes.
