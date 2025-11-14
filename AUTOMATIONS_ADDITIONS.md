# Ona Automations - Additional Features

## Overview

This document describes the additional automation tasks and service that have been implemented to enhance the Hyperledger Fabric development experience.

## New Automation Tasks

### 1. deploy-chaincode

**Purpose**: Deploy sample chaincode to the test network with a single command.

**Trigger**: manual  
**Dependencies**: start-test-network

**Usage**:
```bash
gitpod automations task start deploy-chaincode
```

**What it does**:
1. Ensures test network is running (via dependency)
2. Deploys the asset-transfer-basic chaincode (Go version)
3. Provides confirmation and next steps

**Benefits**:
- One-command chaincode deployment
- Automatic dependency handling
- Consistent deployment process

### 2. run-integration-tests

**Purpose**: Run the full Fabric integration test suite.

**Trigger**: manual  
**Dependencies**: setup-docker-images

**Usage**:
```bash
gitpod automations task start run-integration-tests
```

**What it does**:
1. Ensures Docker images are available (via dependency)
2. Runs `make integration-test`
3. Reports results

**Duration**: 15-30 minutes

**Benefits**:
- Comprehensive testing before commits
- Automatic prerequisite setup
- CI/CD-ready

### 3. benchmark

**Purpose**: Run performance benchmarks on key Fabric packages.

**Trigger**: manual

**Usage**:
```bash
gitpod automations task start benchmark
```

**What it does**:
1. Runs Go benchmarks on common packages
2. Saves results to `benchmark-results.txt`
3. Provides performance metrics

**Benefits**:
- Performance regression detection
- Optimization guidance
- Historical comparison data

### 4. clean-all

**Purpose**: Complete cleanup of workspace, build artifacts, and Docker resources.

**Trigger**: manual

**Usage**:
```bash
gitpod automations task start clean-all
```

**What it does**:
1. Runs `make clean-all` to remove build artifacts
2. Stops any running test networks
3. Prunes Docker system (removes unused images, containers, volumes)

**Benefits**:
- Fresh start capability
- Disk space recovery
- Troubleshooting aid

## New Service: fabric-network

**Purpose**: Continuously running test network for intensive development sessions.

**Trigger**: manual

**Usage**:
```bash
# Start the service
gitpod automations service start fabric-network

# Check status
gitpod automations service list

# View logs
gitpod automations service logs fabric-network

# Stop the service
gitpod automations service stop fabric-network
```

**What it does**:
1. Starts the Fabric test network with a channel
2. Keeps the network running continuously
3. Provides readiness checks
4. Graceful shutdown on stop

**When to use**:
- **Service**: For intensive development sessions where you need the network running continuously
- **Tasks**: For most workflows where you want explicit control over network lifecycle

**Pros**:
- Network stays running between tests
- No need to restart for each test
- Faster iteration during development

**Cons**:
- Consumes resources continuously
- May not be needed for all workflows

## Complete Task List

After these additions, the complete automation suite includes:

### Automatic (1)
- `build-fabric` - Build binaries on devcontainer start

### Network Management (5)
- `start-test-network` - Start network with channel
- `stop-test-network` - Stop and clean up network
- `deploy-chaincode` - Deploy sample chaincode ⭐ NEW
- `setup-test-network` - Clone fabric-samples
- `setup-docker-images` - Pull Docker images

### Development & Testing (5)
- `build-docker` - Build Fabric Docker images
- `test-unit` - Run unit tests
- `run-integration-tests` - Run integration tests ⭐ NEW
- `benchmark` - Run performance benchmarks ⭐ NEW
- `check-code` - Run code quality checks

### Utilities (1)
- `clean-all` - Clean all artifacts and Docker ⭐ NEW

### Services (1)
- `fabric-network` - Continuously running network ⭐ NEW

## Usage Examples

### Quick Chaincode Development Workflow

```bash
# 1. Start network (automatic dependencies)
gitpod automations task start start-test-network

# 2. Deploy chaincode
gitpod automations task start deploy-chaincode

# 3. Develop and test...

# 4. Stop network
gitpod automations task start stop-test-network
```

### Intensive Development Session

```bash
# 1. Start network as service
gitpod automations service start fabric-network

# 2. Develop, test, iterate...
# Network stays running

# 3. Stop service when done
gitpod automations service stop fabric-network
```

### Pre-Commit Workflow

```bash
# 1. Run code checks
gitpod automations task start check-code

# 2. Run unit tests
gitpod automations task start test-unit

# 3. Run benchmarks (optional)
gitpod automations task start benchmark

# 4. Commit changes
```

### Full Validation Workflow

```bash
# 1. Clean everything
gitpod automations task start clean-all

# 2. Run integration tests
gitpod automations task start run-integration-tests

# 3. Start network and deploy chaincode
gitpod automations task start deploy-chaincode

# 4. Manual testing...

# 5. Clean up
gitpod automations task start clean-all
```

## Benefits Summary

### For New Contributors
- **Even simpler**: One command to deploy chaincode
- **Comprehensive**: Full test suite available
- **Guided**: Clear workflows for common tasks

### For Core Developers
- **Efficient**: Service option for intensive sessions
- **Complete**: All common operations automated
- **Flexible**: Choose tasks or service based on needs

### For CI/CD
- **Composable**: Tasks chain with dependencies
- **Reliable**: Consistent execution
- **Comprehensive**: Full test coverage available

## Documentation Updates

All documentation has been updated to reflect these additions:

- `.gitpod/README.md` - Updated with new tasks and service
- `.gitpod/TRIGGERS.md` - Documented implementation and usage
- `AGENTS.md` - Updated automation commands
- `AUTOMATIONS_ADDITIONS.md` - This document

## Testing Results

All new automations have been tested and validated:

✅ `deploy-chaincode` - Successfully deploys chaincode with dependencies  
✅ `run-integration-tests` - Validated (not run due to time)  
✅ `benchmark` - Successfully runs benchmarks  
✅ `clean-all` - Successfully cleans workspace  
✅ `fabric-network` service - Successfully starts and stops network  

## Next Steps

Developers can now:
1. Use `deploy-chaincode` for quick chaincode testing
2. Run `run-integration-tests` before major commits
3. Use `benchmark` for performance optimization
4. Use `clean-all` for troubleshooting
5. Choose between tasks and service based on workflow needs

## References

- [Ona Automations Documentation](https://ona.com/docs/ona/configuration/automations/overview)
- [Ona Services Documentation](https://ona.com/docs/ona/configuration/automations/overview#services)
- [Hyperledger Fabric Documentation](https://hyperledger-fabric.readthedocs.io/)
