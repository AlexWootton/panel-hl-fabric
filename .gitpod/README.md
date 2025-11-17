# Hyperledger Fabric Development Environment

Complete guide for developing Hyperledger Fabric in Gitpod/Ona.

## What's New ✨

**Improved Automations** - Faster feedback and better experience:
- ⚡ **Quick validation**: `quick-check` (2-5 min) and `verify-changes` (1-3 min) for fast feedback
- 🎯 **Granular testing**: Run specific integration test suites (5-10 min) instead of all tests (30 min)
- 🌐 **Better network management**: Clean restart (no more "channel exists" errors!), CouchDB support
- 📊 **Time savings**: 67-83% reduction in test cycle time for most developers

See [AUTOMATION_ANALYSIS.md](AUTOMATION_ANALYSIS.md) for full details.

## Quick Start

### 1. Environment Startup
When you start the environment, Fabric binaries are **automatically built** (~2-3 minutes).

### 2. Start Test Network
```bash
# One command to start everything (with clean restart):
gitpod automations task start start-network
```

This automatically:
- Clones fabric-samples (if needed)
- Pulls required Docker images
- Cleans any existing network (no more "channel exists" errors!)
- Starts the network with a channel

### 3. Deploy Chaincode (Optional)
```bash
gitpod automations task start deploy-chaincode
```

### 4. Validate Network (Optional)
```bash
gitpod automations task start validate-network
```

### 5. Stop Test Network
```bash
gitpod automations task start stop-network
```

## Available Automations

### Quick Validation (NEW! ⚡)
| Task | Description | Time | Trigger |
|------|-------------|------|---------|
| `quick-check` | Linters + tests for changed packages | 2-5 min | Manual |
| `verify-changes` | Unit tests for changed packages only | 1-3 min | Manual |

### Network Management
| Task | Description | Trigger |
|------|-------------|---------|
| `start-network` | Start test network (clean restart, no errors!) | Manual |
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

### Testing - Integration (NEW! 🎯)
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

### Maintenance Automation (🔧 Phase 1 + 2A Complete)

**✅ Works from Ona UI** (no variables needed):
```bash
gitpod automations task start fix-typos
gitpod automations task start fix-license-headers
gitpod automations task start fix-trailing-spaces
gitpod automations task start validate-changes
gitpod automations task start validate-changes-quick
gitpod automations task start validate-commit-message
gitpod automations task start generate-changelog
gitpod automations task start install-git-hooks
gitpod automations task start check-outdated-deps
```

**🖥️ CLI Only** (requires variables):
```bash
GO_VERSION=1.25.4 gitpod automations task start update-go-version
DEPENDENCY=github.com/pkg/errors VERSION=v0.9.1 gitpod automations task start update-dependency
VERSION=3.1.4 gitpod automations task start prepare-release
```

**31 of 34 automations (91%)** work from Ona UI

**New in Phase 2B**:
- `check-unused-deps` - Find unused vendored dependencies
- `scan-vulnerabilities` - Security scanning with govulncheck
- `check-test-coverage` - Test coverage reporting

See [ONA_UI_COMPATIBILITY.md](ONA_UI_COMPATIBILITY.md) for workarounds and [MAINTENANCE_AUTOMATION.md](MAINTENANCE_AUTOMATION.md) for detailed usage.

### Quick Iteration (⚡)
```bash
# Fast feedback during development
gitpod automations task start quick-check        # make desk-check: linters + changed packages
gitpod automations task start verify-changes     # make verify: test changed packages only

# Before committing
gitpod automations task start check-code         # make basic-checks: all quality checks
```

**Note**: Our automations use existing Makefile targets where possible. See [MAKEFILE_INTEGRATION.md](MAKEFILE_INTEGRATION.md) for details.

### Building Changes
```bash
make native          # Build binaries
make docker          # Build Docker images
```

### Testing - Granular (NEW! 🎯)
```bash
# Run specific integration test suites (much faster!)
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
# Start network (clean restart, no errors!)
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

## Why These Triggers?

For detailed explanation of why certain tasks are automatic vs manual, see [TRIGGERS.md](./TRIGGERS.md).

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

✅ **Infrastructure**
- Docker containers are running (peers, orderer)
- Chaincode containers are deployed

✅ **Channel Operations**
- Channel exists and is accessible
- Both organization peers can connect

✅ **Chaincode Lifecycle**
- Chaincode is installed on peers
- Chaincode is committed to channel

✅ **Transaction Operations**
- Invoke transactions (InitLedger, CreateAsset)
- Query operations (GetAllAssets, ReadAsset)
- Data persistence and retrieval

### Sample Output

```
========================================
Hyperledger Fabric Test Network Validation
========================================

✅ PASS: All required Docker containers are running
✅ PASS: Channel 'mychannel' exists
✅ PASS: Chaincode 'basic' is installed
✅ PASS: Chaincode 'basic' is committed to mychannel
✅ PASS: Chaincode containers are running (2 found)
✅ PASS: Both organization peers are responsive
✅ PASS: Chaincode invocation successful (InitLedger)
✅ PASS: Chaincode query successful (found assets)
✅ PASS: Asset creation successful
✅ PASS: Asset read successful (verified created asset)

========================================
Validation Summary
========================================

Total Tests: 10
Passed: 10
Failed: 0

🎉 All tests passed! The network is fully functional.
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

- **[VALIDATION.md](./VALIDATION.md)** - Detailed network validation guide
- **[TRIGGERS.md](./TRIGGERS.md)** - Detailed automation trigger design and philosophy
- **[../.devcontainer/README.md](../.devcontainer/README.md)** - Dev container configuration
- **[../.devcontainer/GITHUB_CLI_AUTH.md](../.devcontainer/GITHUB_CLI_AUTH.md)** - GitHub CLI authentication

## Resources

- [Fabric Documentation](https://hyperledger-fabric.readthedocs.io/)
- [Test Network Tutorial](https://hyperledger-fabric.readthedocs.io/en/latest/test_network.html)
- [Contributing Guide](../CONTRIBUTING.md)
