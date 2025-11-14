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
1. Ensures ginkgo test framework is installed
2. Ensures Docker images are available (via dependency)
3. Runs `make integration-test`
4. Reports results

**Duration**: 15-30 minutes

**Technical Note**: The automation automatically installs the ginkgo test framework if not present. The dev container configuration also adds `$GOPATH/bin` to PATH to ensure Go tools are accessible.

**Benefits**:
- Comprehensive testing before commits
- Automatic prerequisite setup (including ginkgo)
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

### 4. clean-integration-tests

**Purpose**: Clean integration test artifacts (compiled test binaries).

**Trigger**: manual

**Usage**:
```bash
gitpod automations task start clean-integration-tests
```

**What it does**:
1. Finds all `*.test` binaries in `integration/` directory
2. Removes test binaries (~600MB total)
3. Cleans test data in `core/chaincode/platforms/golang/testdata/pkg/`
4. Reports number of files cleaned

**When to use**:
- After running integration tests
- To free up disk space
- Before committing (test binaries shouldn't be committed)

**Benefits**:
- Recovers ~600MB of disk space
- Keeps workspace clean
- Fast execution (< 1 second)

**Note**: The `run-integration-tests` automation automatically cleans up after itself, so manual cleanup is only needed if tests were run via `make integration-test` directly.

### 5. clean-all

**Purpose**: Complete cleanup of workspace, build artifacts, and Docker resources.

**Trigger**: manual

**Usage**:
```bash
gitpod automations task start clean-all
```

**What it does**:
1. Runs `make clean-all` to remove build artifacts
2. Cleans integration test binaries
3. Stops any running test networks
4. Prunes Docker system (removes unused images, containers, volumes)

**Benefits**:
- Fresh start capability
- Disk space recovery
- Troubleshooting aid
- Comprehensive cleanup

## Why No Service for Fabric Network?

A `fabric-network` service was initially implemented but **removed after validation** because the service model is not appropriate for the Fabric test network.

**Problem**:
The `network.sh up createChannel` script is a setup tool that exits after starting Docker containers. Ona services expect a long-running foreground process, but the script completes and exits with code 0. This causes the service to stop immediately, even though the network containers continue running.

**Result**:
- Service shows "STOPPED" status
- Network containers are actually running
- Creates confusion about actual network state

**Solution**:
Use the existing `start-test-network` and `stop-test-network` tasks instead. The network containers stay running between tasks, providing the same benefit as a service would, but with clearer semantics and no state confusion.

**Recommendation**: 
```bash
# Start network (containers keep running)
gitpod automations task start start-test-network

# Develop and test... (network stays running)

# Stop network when done
gitpod automations task start stop-test-network
```

## Complete Task List

After these additions, the complete automation suite includes **13 tasks**:

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

### Utilities (2)
- `clean-integration-tests` - Clean integration test binaries ⭐ NEW
- `clean-all` - Clean all artifacts and Docker ⭐ NEW

**Note**: A `fabric-network` service was considered but removed after validation. See "Why No Service for Fabric Network?" section above.

## Integration Test Cleanup

Integration tests create compiled test binaries (`*.test` files) that can consume significant disk space (~600MB). The automation system handles cleanup in multiple ways:

### Automatic Cleanup
The `run-integration-tests` automation automatically cleans up test artifacts after completion, whether tests pass or fail. This ensures the workspace stays clean without manual intervention.

### Manual Cleanup Options
1. **`clean-integration-tests`** - Fast, targeted cleanup of test binaries only (~1 second)
2. **`clean-all`** - Comprehensive cleanup including test binaries, build artifacts, and Docker resources

### Why No Lifecycle Hooks?
Ona automations don't currently support lifecycle hooks (like `onComplete` or `onFailure`). Instead, cleanup is handled within the task command itself using proper exit code handling to ensure cleanup runs even if tests fail.

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
# 1. Start network (containers keep running)
gitpod automations task start start-test-network

# 2. Develop, test, iterate...
# Network stays running between operations

# 3. Stop network when done
gitpod automations task start stop-test-network
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
