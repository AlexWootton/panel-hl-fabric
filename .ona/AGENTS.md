# Ona Environment - Agent Guide

Ona-specific commands and automations for Hyperledger Fabric development.

## Automation Commands

```bash
# List available automations
gitpod automations task list

# Validation
gitpod automations task start quick-check
gitpod automations task start verify-changes

# Test network
gitpod automations task start start-network
gitpod automations task start stop-network
gitpod automations task start validate-network

# Code quality fixes
gitpod automations task start fix-typos
gitpod automations task start fix-license-headers
gitpod automations task start fix-trailing-spaces

# Security and quality
gitpod automations task start scan-vulnerabilities
gitpod automations task start check-test-coverage
gitpod automations task start check-unused-deps
```

## Key Paths

- `/workspaces/fabric` - Repository root
- `/workspaces/fabric/build/bin` - Built binaries
- `/workspaces/fabric-samples` - Test network and samples

## Detailed Documentation

- `README.md` - Complete automation reference
- `MAINTENANCE.md` - Maintenance automation guide
- `VALIDATION.md` - Network validation guide
