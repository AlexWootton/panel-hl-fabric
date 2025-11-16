# Ona Automations Triggers for Hyperledger Fabric

## Overview

This document explains the trigger configuration for Fabric development automations and the rationale behind each choice.

## Trigger Types

Ona supports three trigger types:

1. **`postEnvironmentStart`** - Runs every time the environment starts (including restarts)
2. **`postDevcontainerStart`** - Runs when devcontainer starts (first start + rebuilds)
3. **`manual`** - User-initiated via UI, provides on-demand execution

## Design Philosophy

Our trigger configuration follows these principles:

1. **Non-intrusive**: Don't impose workflows on developers who don't want them
2. **Fast startup**: Minimize automatic tasks to keep environment startup quick
3. **Convenient**: Make common operations easy with one-click actions
4. **Flexible**: Allow developers to choose when to run resource-intensive tasks

## Trigger Configuration

### Automatic Triggers

#### `build-fabric` - `postDevcontainerStart`

**Rationale**: Building Fabric binaries is essential for development and should happen automatically after container rebuilds to ensure developers always have fresh binaries.

**Why this trigger?**
- Runs after devcontainer rebuild, ensuring binaries match the current codebase
- Doesn't run on every environment restart (which would be wasteful)
- Takes ~2-3 minutes, acceptable for a rebuild scenario
- Developers expect a build step after container changes

**Alternative considered**: `postEnvironmentStart` - Rejected because it would rebuild on every restart, wasting time when binaries are already built.

### Manual Triggers

All other tasks use `manual` triggers to give developers full control:

#### `setup-test-network` - `manual`

**Rationale**: Not all developers need the test network. Some work on core Fabric code without running a full network.

**Why manual?**
- Cloning fabric-samples adds ~100MB to workspace
- Not required for core Fabric development
- Developers can choose when they need it
- Idempotent - safe to run multiple times

#### `setup-docker-images` - `manual`

**Rationale**: Docker images are large (CouchDB ~263MB, fabric-ccenv ~1.4GB) and not always needed.

**Why manual?**
- Saves bandwidth and time for developers not using Docker
- Only needed when running test networks or integration tests
- Can be run on-demand when required
- Images persist across environment restarts

#### `start-test-network` - `manual` (with dependencies)

**Rationale**: Starting a test network is a deliberate action that developers should control.

**Why manual?**
- Consumes system resources (3 containers)
- Not needed for all development workflows
- Developers should decide when to start/stop
- **Dependencies**: Automatically runs `setup-test-network` and `setup-docker-images` if needed

**Key feature**: This task demonstrates the power of dependencies - one click sets up everything needed for a running network.

#### `stop-test-network` - `manual`

**Rationale**: Provides a clean way to stop and clean up the test network.

**Why manual?**
- Counterpart to `start-test-network`
- Developers control when to free resources
- Cleans up containers and volumes properly

#### `build-docker` - `manual`

**Rationale**: Building Docker images is only needed for specific development scenarios.

**Why manual?**
- Takes significant time (~10-15 minutes)
- Only needed when modifying Fabric Docker images
- Most developers use pre-built images
- Resource-intensive operation

#### `test-unit` - `manual`

**Rationale**: Unit tests should be run on-demand, not automatically.

**Why manual?**
- Can take a long time (full suite: 30+ minutes)
- Developers typically run specific test packages during development
- Should be run before committing, not on every start
- Developers use `go test` directly for specific packages

#### `check-code` - `manual`

**Rationale**: Code quality checks should be run before committing, not automatically.

**Why manual?**
- Takes several minutes to complete
- Most useful before creating PRs
- Includes linting, license checks, spelling, etc.
- Developers may want to fix issues before running checks

## Usage Patterns

### Quick Start for New Developers

```bash
# Environment starts, binaries build automatically
# Wait for build-fabric to complete (~2-3 minutes)

# When ready to test:
gitpod automations task start start-test-network
# This automatically:
# 1. Clones fabric-samples (if needed)
# 2. Pulls Docker images (if needed)
# 3. Starts the network with a channel

# When done testing:
gitpod automations task start stop-test-network
```

### Core Development Workflow

```bash
# Environment starts, binaries build automatically
# Develop and test with built binaries in build/bin/

# Run specific tests as needed:
go test ./common/util -v

# Before committing:
gitpod automations task start check-code
```

### Docker Image Development

```bash
# Environment starts, binaries build automatically

# Build Docker images:
gitpod automations task start build-docker

# Test with custom images:
gitpod automations task start start-test-network
```

## Benefits of This Configuration

### For New Contributors
- **Simple**: One command to get a running test network
- **Fast**: No waiting for unnecessary downloads on startup
- **Guided**: Clear tasks in the UI show what's available

### For Core Developers
- **Non-intrusive**: Only builds binaries automatically
- **Flexible**: Run tests and checks when needed
- **Efficient**: No wasted resources on unused features

### For CI/CD Integration
- **Composable**: Tasks can be chained with dependencies
- **Reliable**: Each task is idempotent and well-defined
- **Scriptable**: Can be triggered via CLI for automation

## Runner Behavior Differences

### AWS Runners (Suspend/Resume)
- `postDevcontainerStart` only runs on first start and rebuilds
- `postEnvironmentStart` runs on resume from suspend
- Our configuration works well: binaries persist across suspends

### Ona Desktop (Full Reboot)
- Both triggers run on every restart
- `build-fabric` will rebuild on every restart
- This is acceptable as Desktop restarts are less frequent

## Recent Improvements (November 2024)

### Major Automation Redesign

We've significantly improved the automation design based on comprehensive developer persona analysis. See [AUTOMATION_ANALYSIS.md](AUTOMATION_ANALYSIS.md) for full details.

**Key Changes**:
1. ✅ Fixed test network restart issue (no more "channel exists" errors)
2. ✅ Added fast feedback loops (`quick-check`, `verify-changes`)
3. ✅ Added granular integration test suites (5-10 min vs 30 min)
4. ✅ Added CouchDB network support for ledger developers
5. ✅ Improved network management with clean restart
6. ❌ Removed low-value automations (`setup-test-network`, `setup-docker-images`, `benchmark`)

**Impact**:
- 67-83% reduction in test cycle time
- Fast feedback for all developer personas
- Better resource utilization
- Clearer automation names and purposes

## Implemented Additions

The following tasks have been implemented based on developer feedback:

### Additional Tasks

#### Quick Validation (NEW!)
1. **`quick-check`** ✅ - Fast validation for all developers
   - **Trigger**: manual
   - **Purpose**: Linters + tests for changed packages
   - **Duration**: 2-5 minutes
   - **Usage**: `gitpod automations task start quick-check`

2. **`verify-changes`** ✅ - Test only changed packages
   - **Trigger**: manual
   - **Purpose**: Fastest test feedback
   - **Duration**: 1-3 minutes
   - **Usage**: `gitpod automations task start verify-changes`

#### Network Management (IMPROVED!)
3. **`start-network`** ✅ - Start test network (improved)
   - **Trigger**: manual
   - **Purpose**: Clean restart, no "channel exists" errors
   - **Changes**: Absorbed setup dependencies, added cleanup
   - **Usage**: `gitpod automations task start start-network`

4. **`start-network-couchdb`** ✅ - Start network with CouchDB
   - **Trigger**: manual
   - **Purpose**: Ledger development with CouchDB state database
   - **Usage**: `gitpod automations task start start-network-couchdb`

5. **`restart-network`** ✅ - Quick network restart
   - **Trigger**: manual
   - **Purpose**: Fast iteration without manual commands
   - **Duration**: ~30 seconds
   - **Usage**: `gitpod automations task start restart-network`

6. **`setup-couchdb`** ✅ - Pull CouchDB image
   - **Trigger**: manual
   - **Purpose**: Prepare for ledger tests
   - **Usage**: `gitpod automations task start setup-couchdb`

#### Granular Integration Testing (NEW!)
7. **`test-consensus`** ✅ - Consensus tests only
   - **Trigger**: manual
   - **Suites**: raft, smartbft
   - **Duration**: ~5 minutes
   - **Usage**: `gitpod automations task start test-consensus`

8. **`test-ledger`** ✅ - Ledger tests only
   - **Trigger**: manual
   - **Suites**: ledger, pvtdata, pvtdatapurge
   - **Duration**: ~8 minutes
   - **Usage**: `gitpod automations task start test-ledger`

9. **`test-lifecycle`** ✅ - Lifecycle tests only
   - **Trigger**: manual
   - **Suites**: lifecycle, devmode, pluggable
   - **Duration**: ~6 minutes
   - **Usage**: `gitpod automations task start test-lifecycle`

10. **`test-gateway`** ✅ - Gateway tests only
    - **Trigger**: manual
    - **Suites**: gateway, discovery, gossip
    - **Duration**: ~5 minutes
    - **Usage**: `gitpod automations task start test-gateway`

11. **`test-e2e`** ✅ - End-to-end tests only
    - **Trigger**: manual
    - **Suites**: e2e, nwo, sbe, msp
    - **Duration**: ~10 minutes
    - **Usage**: `gitpod automations task start test-e2e`

12. **`test-integration-all`** ✅ - All integration tests (renamed)
    - **Trigger**: manual
    - **Purpose**: Comprehensive integration testing
    - **Duration**: 15-30 minutes
    - **Note**: Renamed from `run-integration-tests`
    - **Usage**: `gitpod automations task start test-integration-all`

#### Other Tasks
13. **`deploy-chaincode`** ✅ - Deploy sample chaincode to test network
    - **Trigger**: manual
    - **Purpose**: One-command chaincode deployment
    - **Usage**: `gitpod automations task start deploy-chaincode`

14. **`clean-all`** ✅ - Clean all build artifacts and Docker resources
    - **Trigger**: manual
    - **Purpose**: Complete cleanup of workspace
    - **Actions**: Removes build artifacts, stops networks, prunes Docker
    - **Usage**: `gitpod automations task start clean-all`

### Removed Tasks

The following tasks were removed as low-value or redundant:

1. **`setup-test-network`** ❌ - Absorbed into `start-network`
2. **`setup-docker-images`** ❌ - Absorbed into `start-network`
3. **`benchmark`** ❌ - Too generic, low value

### Why No Service for Fabric Network?

A `fabric-network` service was initially considered but **removed after validation** because the service model is not appropriate for the Fabric test network.

**Problem Identified**:
- The `network.sh up createChannel` script is a setup tool, not a long-running daemon
- The script completes and exits with code 0 after starting Docker containers
- Ona services expect a foreground process that stays running
- The service stops immediately even though the network containers keep running
- This creates confusion: service shows "STOPPED" but network is actually running

**Technical Details**:
```
Service Start → network.sh up createChannel → Containers start → Script exits
                                                                    ↓
                                              Service stops (exitCode=0)
                                                                    ↓
                                              Containers keep running ✓
```

**Why Tasks Are Better**:
- `start-test-network` task: Starts network and exits cleanly
- Network containers continue running independently
- `stop-test-network` task: Stops network when needed
- Clear lifecycle: start → network runs → stop
- No confusion about service state vs network state

**Recommendation**: Use `start-test-network` and `stop-test-network` tasks. The network stays running between tasks, providing the same benefit as a service would, but with clearer semantics.

## Conclusion

This trigger configuration balances convenience with flexibility:

- **Automatic**: Only essential tasks (building binaries)
- **Manual**: Everything else, giving developers control
- **Dependencies**: Smart chaining makes complex operations simple
- **Non-intrusive**: Respects different development workflows

The configuration makes standing up a test network simple (one command) while not imposing on developers who don't need it.

## References

- [Ona Automations Documentation](https://ona.com/docs/ona/configuration/automations/overview)
- [Trigger Types](https://ona.com/docs/ona/configuration/automations/overview#triggers)
- [Best Practices](https://ona.com/docs/ona/configuration/automations/overview#best-practices-for-using-triggers)
