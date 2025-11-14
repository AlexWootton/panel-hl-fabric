# Ona Automations Triggers - Rationale

## What Changed

Added intelligent trigger configuration to Fabric automations to make standing up a test network simple and fast, without imposing on developers who don't want it.

## Key Improvements

### 1. Automatic Binary Building
- **Trigger**: `postDevcontainerStart`
- **Task**: `build-fabric`
- **Benefit**: Binaries are always fresh after container rebuilds, no manual intervention needed

### 2. One-Command Test Network
- **New Task**: `start-test-network`
- **Dependencies**: Automatically runs `setup-test-network` and `setup-docker-images`
- **Benefit**: Single command goes from zero to running network with channel

### 3. Clean Shutdown
- **New Task**: `stop-test-network`
- **Benefit**: Properly cleans up containers and volumes

### 4. All Other Tasks Manual
- Gives developers full control over when to run resource-intensive operations
- No unwanted automatic downloads or builds
- Respects different development workflows

## Quick Start

```bash
# 1. Start environment (binaries build automatically)
# Wait ~2-3 minutes for build-fabric to complete

# 2. Start test network (one command!)
gitpod automations task start start-test-network

# 3. Develop and test...

# 4. Stop test network
gitpod automations task start stop-test-network
```

## Task List

| Task | Trigger | Purpose |
|------|---------|---------|
| `build-fabric` | `postDevcontainerStart` | Build binaries automatically |
| `start-test-network` | `manual` | Start network (with dependencies) |
| `stop-test-network` | `manual` | Stop and clean up network |
| `setup-test-network` | `manual` | Clone fabric-samples |
| `setup-docker-images` | `manual` | Pull Docker images |
| `build-docker` | `manual` | Build Fabric Docker images |
| `test-unit` | `manual` | Run unit tests |
| `check-code` | `manual` | Run code quality checks |

## Design Philosophy

1. **Non-intrusive**: Only essential tasks run automatically
2. **Fast startup**: Minimal automatic operations
3. **Convenient**: Complex operations simplified with dependencies
4. **Flexible**: Developers control resource-intensive tasks

## Documentation

- **`.gitpod/TRIGGERS.md`** - Detailed explanation of trigger choices and rationale
- **`.gitpod/README.md`** - Updated with new quick start workflow
- **`AGENTS.md`** - Updated with automation usage patterns

## Testing Results

✅ All automations validated and tested:
- `build-fabric` trigger configuration verified
- `start-test-network` successfully starts network with dependencies
- `stop-test-network` properly cleans up resources
- Dependencies work correctly (setup-test-network + setup-docker-images)

## Benefits

### For New Contributors
- **3 minutes to running network** (vs 10+ minutes manual)
- **One command** instead of 5-6 separate steps
- **Clear UI** showing available operations

### For Core Developers
- **No interference** with existing workflows
- **Fast startup** - only builds binaries
- **On-demand** testing and validation

### For Everyone
- **Consistent** - same experience across all environments
- **Documented** - clear explanation of choices
- **Flexible** - easy to customize for specific needs

## Next Steps

Developers can now:
1. Start environment and get automatic binary builds
2. Run `start-test-network` when ready to test
3. Focus on development without manual setup overhead
4. Use other manual tasks as needed for their workflow

See `.gitpod/TRIGGERS.md` for complete documentation.
