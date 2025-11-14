# Hyperledger Fabric Development Environment Setup

## ✅ Configuration Complete

Your Hyperledger Fabric development environment is now configured with:

### 1. Dev Container Configuration
**Location**: `.devcontainer/`

**Features**:
- Ubuntu 24.04 base image
- Go, Make, Git, curl, jq pre-installed
- Docker-in-Docker enabled for running Fabric networks
- VS Code Go extension configured
- `FABRIC_CFG_PATH` environment variable set

**File**: `.devcontainer/devcontainer.json`
- Docker-in-Docker with Docker Compose v2
- Custom Dockerfile with required tools

### 2. Ona Automations
**Location**: `.gitpod/automations.yaml`

**Available Tasks**:
```bash
# Build Fabric binaries
gitpod automations task start build-fabric

# Setup test network (clones fabric-samples)
gitpod automations task start setup-test-network

# Pull Docker images (CouchDB, etc.)
gitpod automations task start setup-docker-images

# Build Docker images
gitpod automations task start build-docker

# Run unit tests
gitpod automations task start test-unit

# Run code checks
gitpod automations task start check-code

# List all tasks
gitpod automations task list
```

### 3. Project Documentation
**Files Created**:
- `AGENTS.md` - Project guidelines for Ona Agent
- `.gitpod/README.md` - Detailed setup and usage instructions
- `CONFIGURATION.md` - This file

## Quick Start

### Option 1: Using Automations (Recommended)
```bash
# 1. Build Fabric binaries
gitpod automations task start build-fabric

# 2. Setup test network
gitpod automations task start setup-test-network

# 3. Pull Docker images
gitpod automations task start setup-docker-images

# 4. Navigate to test network
cd /workspaces/fabric-samples/test-network

# 5. Start the network
./network.sh up createChannel
```

### Option 2: Manual Build
```bash
# Build binaries
make native

# Binaries will be in build/bin/
ls -lh build/bin/
```

## Next Steps

### To Rebuild Dev Container
If you need to apply the dev container changes:
1. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
2. Select "Dev Containers: Rebuild Container"
3. Wait for rebuild to complete

### To Run Test Network
```bash
# Clone fabric-samples (if not done via automation)
cd /workspaces
git clone https://github.com/hyperledger/fabric-samples.git

# Navigate to test network
cd fabric-samples/test-network

# Bring up network with channel
./network.sh up createChannel

# Deploy sample chaincode
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go

# Bring down network
./network.sh down
```

### To Run Tests
```bash
cd /workspaces/fabric

# Unit tests
make unit-test

# Integration tests (requires Docker)
make integration-test

# Code quality checks
make basic-checks
```

## Verification

### Check Built Binaries
```bash
./build/bin/peer version
./build/bin/orderer version
```

### Check Docker
```bash
docker info
docker images
```

### Check Automations
```bash
gitpod automations task list
```

## Troubleshooting

### Docker Not Available
```bash
# Check Docker status
docker info

# If Docker-in-Docker isn't working, rebuild the dev container
```

### Build Failures
```bash
# Clean and rebuild
make clean-all
make native
```

### Automation Issues
```bash
# Validate automations file
gitpod automations validate .gitpod/automations.yaml

# View task logs
gitpod automations task logs <task-name>
```

## Resources

- [Fabric Documentation](https://hyperledger-fabric.readthedocs.io/)
- [Test Network Tutorial](https://hyperledger-fabric.readthedocs.io/en/latest/test_network.html)
- [Fabric Samples](https://github.com/hyperledger/fabric-samples)
- [Contributing Guide](./CONTRIBUTING.md)
- [Ona Automations Guide](./.gitpod/README.md)
- [AGENTS.md](./AGENTS.md)

## Summary

Your environment is configured to:
- ✅ Build Fabric binaries with `make native`
- ✅ Run Docker containers for testing
- ✅ Use Ona automations for common tasks
- ✅ Run the test network from fabric-samples
- ✅ Execute unit and integration tests

**Ready to start developing!** 🚀
