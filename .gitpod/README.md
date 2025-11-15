# Hyperledger Fabric Development Environment

Complete guide for developing Hyperledger Fabric in Gitpod/Ona.

## Quick Start

### 1. Environment Startup
When you start the environment, Fabric binaries are **automatically built** (~2-3 minutes).

### 2. Start Test Network
```bash
# One command to start everything:
gitpod automations task start start-test-network
```

This automatically:
- Clones fabric-samples (if needed)
- Pulls required Docker images
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
gitpod automations task start stop-test-network
```

## Available Automations

### Network Management
| Task | Description | Trigger |
|------|-------------|---------|
| `start-test-network` | Start Fabric test network with channel | Manual |
| `stop-test-network` | Stop and clean up test network | Manual |
| `deploy-chaincode` | Deploy sample chaincode | Manual |
| `validate-network` | Validate network is fully functional | Manual |
| `setup-test-network` | Clone fabric-samples repository | Manual |
| `setup-docker-images` | Pull required Docker images | Manual |

### Development & Testing
| Task | Description | Trigger |
|------|-------------|---------|
| `build-fabric` | Build all Fabric native binaries | **Automatic** (on start) |
| `build-docker` | Build Fabric Docker images | Manual |
| `test-unit` | Run unit tests | Manual |
| `run-integration-tests` | Run integration tests (~15-30 min) | Manual |
| `benchmark` | Run performance benchmarks | Manual |
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

### Building Changes
```bash
make native          # Build binaries
make docker          # Build Docker images
```

### Testing
```bash
make unit-test       # Run unit tests
make integration-test # Run integration tests (requires Docker)
make basic-checks    # Run linting, license checks, etc.
```

### Using the Test Network

#### Option 1: Automation (Recommended)
```bash
gitpod automations task start start-test-network
gitpod automations task start deploy-chaincode
# ... develop and test ...
gitpod automations task start stop-test-network
```

#### Option 2: Manual
```bash
cd /workspaces/fabric-samples/test-network
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

- **[TESTING_STRATEGY.md](./TESTING_STRATEGY.md)** - Complete guide to testing tools and when to use each
- **[VALIDATION.md](./VALIDATION.md)** - Detailed network validation guide
- **[VALIDATION_ANALYSIS.md](./VALIDATION_ANALYSIS.md)** - Analysis of validation vs. existing tests
- **[TRIGGERS.md](./TRIGGERS.md)** - Detailed automation trigger design and philosophy
- **[../.devcontainer/README.md](../.devcontainer/README.md)** - Dev container configuration
- **[../.devcontainer/DEPENDENCY_ALIGNMENT.md](../.devcontainer/DEPENDENCY_ALIGNMENT.md)** - Dependency alignment with Vagrant/CI
- **[../.devcontainer/GITHUB_CLI_AUTH.md](../.devcontainer/GITHUB_CLI_AUTH.md)** - GitHub CLI authentication

## Resources

- [Fabric Documentation](https://hyperledger-fabric.readthedocs.io/)
- [Test Network Tutorial](https://hyperledger-fabric.readthedocs.io/en/latest/test_network.html)
- [Contributing Guide](../CONTRIBUTING.md)
