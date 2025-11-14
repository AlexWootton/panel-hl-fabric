# Hyperledger Fabric Development Environment

This directory contains configuration for running Hyperledger Fabric in a Gitpod/Ona development environment.

## Quick Start

### 1. Environment Startup
When you start the environment, Fabric binaries are **automatically built** via the `build-fabric` automation (triggered by `postDevcontainerStart`). This takes ~2-3 minutes.

### 2. Start Test Network (One Command!)
```bash
# This single command will:
# - Clone fabric-samples (if needed)
# - Pull required Docker images (if needed)
# - Start the network with a channel
gitpod automations task start start-test-network
```

### 3. Stop Test Network
```bash
# Clean up when done
gitpod automations task start stop-test-network
```

That's it! See [TRIGGERS.md](./TRIGGERS.md) for details on automation triggers and design philosophy.

## Available Automations

### Automatic Tasks
- **build-fabric**: Build all Fabric native binaries (runs automatically on devcontainer start)

### Manual Tasks

#### Network Management
- **start-test-network**: Start Fabric test network with channel (handles all dependencies)
- **stop-test-network**: Stop and clean up test network
- **deploy-chaincode**: Deploy sample chaincode to running network
- **setup-test-network**: Clone fabric-samples repository
- **setup-docker-images**: Pull required Docker images (CouchDB, etc.)

#### Development & Testing
- **build-docker**: Build Fabric Docker images
- **test-unit**: Run unit tests
- **run-integration-tests**: Run full integration test suite
- **benchmark**: Run performance benchmarks
- **check-code**: Run linting and code checks
- **clean-all**: Clean all build artifacts and Docker resources

### Services
- **fabric-network**: Continuously running test network (alternative to start/stop tasks)

See [TRIGGERS.md](./TRIGGERS.md) for detailed explanation of trigger configuration.

### Running Tasks
```bash
# List all available tasks
gitpod automations task list

# Start a task
gitpod automations task start <task-name>

# View task logs
gitpod automations task logs <task-name>

# List task executions
gitpod automations task list-executions <task-name>
```

## Running the Test Network

### Option 1: Using Automations (Recommended)

```bash
# Start network with channel
gitpod automations task start start-test-network

# Deploy sample chaincode
gitpod automations task start deploy-chaincode

# Stop network
gitpod automations task start stop-test-network
```

### Option 2: Using Service (Continuous Running)

```bash
# Start the service
gitpod automations service start fabric-network

# Service keeps network running continuously
# Stop the service when done
gitpod automations service stop fabric-network
```

### Option 3: Manual Commands

```bash
cd /workspaces/fabric-samples/test-network

# Bring up the network
./network.sh up createChannel

# Deploy chaincode
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go

# Bring down the network
./network.sh down
```

## Development Workflow

### Building Changes
```bash
cd /workspace/fabric
make native          # Build binaries
make docker          # Build Docker images
```

### Testing
```bash
make unit-test       # Run unit tests
make integration-test # Run integration tests (requires Docker images)
```

### Code Quality
```bash
make basic-checks    # Run linting, license checks, etc.
make linter          # Run code linter
```

## Environment Variables

- `FABRIC_CFG_PATH`: Points to `/workspace/fabric/sampleconfig` for configuration files

## Troubleshooting

### Docker Issues
```bash
# Check Docker status
docker info

# Restart Docker (if needed)
sudo systemctl restart docker
```

### Build Issues
```bash
# Clean build artifacts
make clean

# Clean everything including persistent state
make clean-all

# Rebuild from scratch
make clean-all && make native
```

### Test Network Issues
```bash
cd /workspace/fabric-samples/test-network

# Bring down network and clean up
./network.sh down

# Remove all containers and volumes
docker rm -f $(docker ps -aq)
docker volume prune -f
```

## Resources

- [Fabric Documentation](https://hyperledger-fabric.readthedocs.io/)
- [Test Network Tutorial](https://hyperledger-fabric.readthedocs.io/en/latest/test_network.html)
- [Fabric Samples](https://github.com/hyperledger/fabric-samples)
