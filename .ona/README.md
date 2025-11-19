# Hyperledger Fabric Development Environment

Development guide for Hyperledger Fabric in Gitpod/Ona environments.

## Overview

This environment provides automated workflows for building, testing, and developing Hyperledger Fabric. Key features include:

- Automated build on environment startup
- Quick validation workflows (2-5 minutes)
- Granular integration test suites (5-10 minutes per suite)
- Test network management with automatic cleanup
- CouchDB state database support
- Maintenance automation (dependency updates, code quality fixes)

## Quick Start

### Environment Startup

Fabric binaries are automatically built on environment startup (approximately 2-3 minutes).

### Start Test Network

```bash
gitpod automations task start start-network
```

This command performs the following operations:
- Clones fabric-samples repository if not present
- Pulls required Docker images
- Cleans any existing network state
- Starts the network with a channel

### Deploy Chaincode

```bash
gitpod automations task start deploy-chaincode
```

### Validate Network

```bash
gitpod automations task start validate-network
```

### Stop Test Network

```bash
gitpod automations task start stop-network
```

## Available Automations

### Quick Validation
| Task | Description | Time | Trigger |
|------|-------------|------|---------|
| `quick-check` | Linters + tests for changed packages | 2-5 min | Manual |
| `verify-changes` | Unit tests for changed packages only | 1-3 min | Manual |

### Network Management
| Task | Description | Trigger |
|------|-------------|---------|
| `start-network` | Start test network (clean restart) | Manual |
| `start-network-couchdb` | Start network with CouchDB state database | Manual |
| `restart-network` | Quick network restart | Manual |
| `stop-network` | Stop and clean up test network | Manual |
| `deploy-chaincode` | Deploy sample chaincode | Manual |
| `validate-network` | Validate network is fully functional | Manual |
| `setup-couchdb` | Pull CouchDB image for ledger tests | Manual |

### Testing - Unit
| Task | Description | Time | Trigger |
|------|-------------|------|---------|
| `test-unit` | Run all unit tests | 15-20 min | Manual |

### Testing - Integration (New)
| Task | Description | Time | Trigger |
|------|-------------|------|---------|
| `test-consensus` | Raft + SmartBFT consensus tests | ~5 min | Manual |
| `test-ledger` | Ledger + private data tests | ~8 min | Manual |
| `test-lifecycle` | Chaincode lifecycle tests | ~6 min | Manual |
| `test-gateway` | Gateway + discovery tests | ~5 min | Manual |
| `test-e2e` | End-to-end integration tests | ~10 min | Manual |
| `test-integration-all` | ALL integration tests | ~30 min | Manual |

### Development
| Task | Description | Trigger |
|------|-------------|---------|
| `build-fabric` | Build all Fabric native binaries | **Automatic** (on start) |
| `build-docker` | Build Fabric Docker images | Manual |
| `check-code` | Run linting and code checks | Manual |

### Cleanup
| Task | Description | Trigger |
|------|-------------|---------|
| `clean-integration-tests` | Clean test binaries (~600MB) | Manual |
| `clean-all` | Clean all artifacts and Docker | Manual |

### Task Commands
```bash
# List all tasks
gitpod automations task list

# Start a task
gitpod automations task start <task-name>

# View logs
gitpod automations task logs <task-name>

# List executions
gitpod automations task list-executions <task-name>
```

## Development Workflow

### Maintenance Automation

Automated maintenance tasks for code quality, dependency management, and releases.

**Quick examples:**
```bash
# Code quality
gitpod automations task start fix-typos
gitpod automations task start fix-license-headers
make basic-checks

# Dependency management
gitpod automations task start check-outdated-deps
DEPENDENCY=golang.org/x/crypto VERSION=v0.44.0 gitpod automations task start update-dependency
```

**26 of 29 automations (90%)** work from Ona UI without variables.

See [MAINTENANCE.md](MAINTENANCE.md) for complete usage guide.

### Quick Iteration
```bash
# Fast feedback during development
gitpod automations task start quick-check        # make desk-check: linters + changed packages
gitpod automations task start verify-changes     # make verify: test changed packages only

# Before committing
gitpod automations task start check-code         # make basic-checks: all quality checks
```

**Note**: Our automations use existing Makefile targets where possible to avoid duplication and leverage upstream-maintained validation logic.

### Building Changes
```bash
make native          # Build binaries
make docker          # Build Docker images
```

### Testing - Granular (New)
```bash
# Run specific integration test suites (faster)
gitpod automations task start test-consensus     # ~5 min: Raft + SmartBFT
gitpod automations task start test-ledger        # ~8 min: Ledger + private data
gitpod automations task start test-lifecycle     # ~6 min: Chaincode lifecycle
gitpod automations task start test-gateway       # ~5 min: Gateway + discovery
gitpod automations task start test-e2e           # ~10 min: End-to-end tests

# Or run everything (slower)
gitpod automations task start test-integration-all  # ~30 min: ALL tests
```

### Testing - Traditional
```bash
make unit-test       # Run unit tests
make integration-test # Run integration tests (requires Docker)
make basic-checks    # Run linting, license checks, etc.
```

### Using the Test Network

#### Option 1: Automation (Recommended)
```bash
# Start network (clean restart)
gitpod automations task start start-network

# Deploy chaincode
gitpod automations task start deploy-chaincode

# ... develop and test ...

# Quick restart if needed
gitpod automations task start restart-network

# Stop when done
gitpod automations task start stop-network
```

#### Option 2: With CouchDB (for ledger development)
```bash
gitpod automations task start start-network-couchdb
# CouchDB UI: http://localhost:5984/_utils (admin/adminpw)
gitpod automations task start deploy-chaincode
# ... develop and test ...
gitpod automations task start stop-network
```

#### Option 3: Manual
```bash
cd /workspaces/fabric-samples/test-network
./network.sh down  # Clean first to avoid errors
./network.sh up createChannel
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go
# ... develop and test ...
./network.sh down
```

## Environment Details

### Installed Tools
- **Go 1.25.3** - Matches project requirements
- **Docker** - Container runtime (Docker-in-Docker)
- **Docker Compose v2** - Multi-container orchestration
- **Make** - Build automation
- **Git** - Version control
- **GitHub CLI (gh)** - Pre-authenticated
- **SoftHSM2** - PKCS#11 testing
- **Build tools** - gcc, g++, make

### Environment Variables
- `FABRIC_CFG_PATH`: `/workspaces/fabric/sampleconfig`
- `GOPATH`: `/home/vscode/go`
- `PATH`: Includes `$GOPATH/bin` and `/usr/local/go/bin`
- `PKCS11_LIB`: Auto-detected SoftHSM2 library path
- `PKCS11_PIN`: `98765432`
- `PKCS11_LABEL`: `ForFabric`

### Key Directories
- `/workspaces/fabric` - Fabric source code
- `/workspaces/fabric/build/bin` - Built binaries
- `/workspaces/fabric-samples` - Sample applications and test network
- `/workspaces/fabric/sampleconfig` - Configuration files



## Network Validation

The `validate-network` automation provides **quick health checks** for your deployed Fabric network. This complements but does not replace comprehensive integration tests.

```bash
gitpod automations task start validate-network
```

### Validation vs. Integration Tests

| Feature | validate-network | Integration Tests |
|---------|-----------------|-------------------|
| **Purpose** | Health checking | Comprehensive testing |
| **Time** | 30-60 seconds | 15-30 minutes |
| **Use Case** | Quick validation | CI/CD, full coverage |
| **Network** | Tests existing | Creates & destroys |
| **When** | After deployment | CI/CD pipelines |

**Use validate-network for:**
- Quick health checks during development
- Troubleshooting network issues
- Verifying deployment success
- Daily development workflow

**Use integration tests for:**
- Comprehensive feature validation
- CI/CD pipelines
- Testing edge cases
- Full regression testing

### What It Tests

 **Infrastructure**
- Docker containers are running (peers, orderer)
- Chaincode containers are deployed

 **Channel Operations**
- Channel exists and is accessible
- Both organization peers can connect

 **Chaincode Lifecycle**
- Chaincode is installed on peers
- Chaincode is committed to channel

 **Transaction Operations**
- Invoke transactions (InitLedger, CreateAsset)
- Query operations (GetAllAssets, ReadAsset)
- Data persistence and retrieval

### Sample Output

```
========================================
Hyperledger Fabric Test Network Validation
========================================

 PASS: All required Docker containers are running
 PASS: Channel 'mychannel' exists
 PASS: Chaincode 'basic' is installed
 PASS: Chaincode 'basic' is committed to mychannel
 PASS: Chaincode containers are running (2 found)
 PASS: Both organization peers are responsive
 PASS: Chaincode invocation successful (InitLedger)
 PASS: Chaincode query successful (found assets)
 PASS: Asset creation successful
 PASS: Asset read successful (verified created asset)

========================================
Validation Summary
========================================

Total Tests: 10
Passed: 10
Failed: 0

🎉 All tests passed. The network is fully functional.
```

### When to Use

- **After deployment** - Verify network is working correctly
- **Before development** - Ensure clean starting state
- **Troubleshooting** - Identify specific component failures
- **CI/CD** - Automated health checks

## Common Tasks

### Run Code Checks
```bash
gitpod automations task start check-code
# Or manually:
make basic-checks
```

### Run Unit Tests
```bash
gitpod automations task start test-unit
# Or manually:
make unit-test
```

### Run Integration Tests
```bash
gitpod automations task start run-integration-tests
# Or manually:
make integration-test
```

### Clean Up Artifacts
```bash
# Clean integration test binaries (~600MB)
gitpod automations task start clean-integration-tests

# Clean everything
gitpod automations task start clean-all
```

## GitHub CLI

The GitHub CLI is pre-installed and **automatically authenticated** using your Git credentials.

```bash
# Create a PR
gh pr create --title "Your PR title" --body "Description"

# View PRs
gh pr list

# Check out a PR
gh pr checkout <number>
```

See [../.devcontainer/GITHUB_CLI_AUTH.md](../.devcontainer/GITHUB_CLI_AUTH.md) for details.

## Troubleshooting

### Docker Not Available
```bash
docker info
# If fails, restart Docker:
sudo systemctl restart docker
```

### Binaries Not Found
```bash
# Check if build completed:
ls -la build/bin/

# Rebuild if needed:
make native
```

### Test Network Issues
```bash
# Check if network is running:
docker ps

# Validate network health:
gitpod automations task start validate-network

# Clean up and restart:
gitpod automations task start stop-test-network
gitpod automations task start start-test-network
```

### Integration Tests Fail
```bash
# Ensure ginkgo is built:
make gotool.ginkgo

# Ensure Docker images are available:
make docker-thirdparty
```

## Additional Documentation

- **[MAINTENANCE.md](./MAINTENANCE.md)** - Maintenance automation guide
- **[VALIDATION.md](./VALIDATION.md)** - Network validation guide
- **[../.devcontainer/README.md](../.devcontainer/README.md)** - Dev container configuration
- **[../.devcontainer/GITHUB_CLI_AUTH.md](../.devcontainer/GITHUB_CLI_AUTH.md)** - GitHub CLI authentication

## Resources

- [Fabric Documentation](https://hyperledger-fabric.readthedocs.io/)
- [Test Network Tutorial](https://hyperledger-fabric.readthedocs.io/en/latest/test_network.html)
- [Contributing Guide](../CONTRIBUTING.md)
