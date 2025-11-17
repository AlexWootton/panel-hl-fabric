# Ona Environment - Agent Guide

Domain-specific guidance for working in the Hyperledger Fabric Ona development environment.

## Quick Commands

```bash
# List available automations
gitpod automations task list

# Fast validation
gitpod automations task start quick-check        # 2-5 min
gitpod automations task start verify-changes     # 1-3 min

# Test network
gitpod automations task start start-network
gitpod automations task start stop-network
gitpod automations task start validate-network

# Maintenance
gitpod automations task start fix-typos
gitpod automations task start fix-license-headers
gitpod automations task start validate-changes
```

## Environment Details

**Installed Tools:**
- Go 1.25.3
- Docker (Docker-in-Docker)
- Docker Compose v2
- Make, Git, GitHub CLI (gh)
- SoftHSM2 for PKCS#11 testing

**Key Directories:**
- `/workspaces/fabric` - Fabric source code
- `/workspaces/fabric/build/bin` - Built binaries
- `/workspaces/fabric-samples` - Sample applications and test network

**Environment Variables:**
- `FABRIC_CFG_PATH`: `/workspaces/fabric/sampleconfig`
- `GOPATH`: `/home/vscode/go`

## Automations

Fabric binaries are automatically built on environment startup (~2-3 minutes).

For complete automation details, see:
- `README.md` - Full automation reference
- `MAINTENANCE.md` - Maintenance automation guide
- `VALIDATION.md` - Network validation guide
- `automations.yaml` - Automation definitions

## Common Workflows

### Start Development
```bash
# Environment starts, binaries build automatically
# Wait for build-fabric to complete

# Start test network when ready
gitpod automations task start start-network
```

### Pre-Commit Validation
```bash
gitpod automations task start validate-changes
```

### Fix Code Quality Issues
```bash
gitpod automations task start fix-typos
gitpod automations task start fix-license-headers
gitpod automations task start fix-trailing-spaces
```

## Related Documentation

- Root AGENTS.md - General Fabric development guide
- README.md - Complete Ona environment guide
- MAINTENANCE.md - Maintenance automation reference
