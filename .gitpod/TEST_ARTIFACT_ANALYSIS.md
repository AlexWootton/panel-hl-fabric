# Test Artifact Cleanup Analysis

## Issue Summary

The `check-code` automation failed with:
```
Files /workspaces/fabric/go.sum and check_deps.sh-HETNK/go.sum differ
It appears go.sum is stale. Please run 'go mod tidy' and 'go mod vendor'.
```

## Root Cause Analysis

### What Happened

1. **Integration tests ran** (`test-consensus` automation)
2. **Ginkgo downloaded test dependencies** during test execution
3. **go.sum was modified** with transitive test dependencies:
   - `github.com/alecthomas/kingpin/v2 v2.4.0` (added)
   - `github.com/xhit/go-str2duration/v2 v2.1.0` (added)
4. **check-code ran** and detected go.sum was "stale"
5. **check_deps.sh failed** because `go mod tidy` would remove these test-only deps

### Why This Happens

The `scripts/check_deps.sh` script:
```bash
# Copy go.mod and go.sum to temp directory
cp go.mod go.sum temp/

# Run go mod tidy (removes unused deps)
go mod tidy -modfile=temp/go.mod

# Compare - fails if different
diff go.sum temp/go.sum
```

When integration tests run:
- Ginkgo/test tools download their own dependencies
- These get added to go.sum temporarily
- They're not in go.mod (test-only transitive deps)
- `go mod tidy` removes them
- Diff fails

### Test Artifacts Created

Integration tests create several types of artifacts:

1. **Test Binaries** (*.test files)
   - Location: `integration/*/`
   - Size: ~25MB each
   - Example: `integration/raft/raft.test`, `integration/smartbft/smartbft.test`

2. **Chaincode Test Data**
   - Location: `core/chaincode/platforms/golang/testdata/pkg/`
   - Size: Variable
   - Contains: Compiled test chaincode packages

3. **Modified go.sum** (temporary)
   - Location: Root directory
   - Modification: Transitive test dependencies added
   - Reverts: After `go mod tidy`

4. **Docker Containers** (if tests fail mid-run)
   - Naming: `dev-peer*`, test network containers
   - Cleanup: Usually automatic, but can persist

5. **Docker Volumes** (if tests fail mid-run)
   - Naming: Test-specific volumes
   - Cleanup: Usually automatic, but can persist

## Current Cleanup Status

### ✅ Cleaned Automatically

**test-integration-all** has cleanup:
```yaml
make integration-test
EXIT_CODE=$?

echo "Cleaning up integration test artifacts..."
find integration/ -name "*.test" -type f -delete 2>/dev/null || true
find core/chaincode/platforms/golang/testdata/pkg/ -type f -delete 2>/dev/null || true
```

### ❌ NOT Cleaned Automatically

**Granular test automations** (test-consensus, test-ledger, test-lifecycle, test-gateway, test-e2e):
- No cleanup step
- Test binaries persist
- Chaincode test data persists
- go.sum modifications persist

**clean-integration-tests** automation exists but:
- Must be run manually
- Not automatic after tests

## When Will This Reoccur?

### High Probability Scenarios

1. **After running any granular integration test** (test-consensus, test-ledger, etc.)
   - Then running check-code
   - Frequency: Every time this sequence happens

2. **After running test-integration-all**
   - If cleanup fails for any reason
   - If new test suites are added without cleanup

3. **After interrupted test runs**
   - Ctrl+C during tests
   - Timeout during tests
   - Test failures that prevent cleanup

### Low Probability Scenarios

1. **After running unit tests**
   - Unit tests don't modify go.sum
   - No integration test artifacts

2. **After building binaries**
   - Build doesn't run tests
   - No artifacts created

3. **After network operations**
   - start-network, deploy-chaincode, etc.
   - No test artifacts

## Impact Assessment

### Disk Space

Test artifacts can accumulate:
- Each test binary: ~25MB
- 9 integration test suites: ~225MB total
- Chaincode test data: ~50-100MB
- **Total potential**: ~300-400MB

### Developer Experience

**Negative impacts**:
1. ❌ Confusing error messages ("go.sum is stale")
2. ❌ check-code fails unexpectedly
3. ❌ Manual intervention required (`go mod tidy`)
4. ❌ Disk space consumed unnecessarily
5. ❌ Unclear when/why cleanup is needed

**Positive impacts**:
1. ✅ Test binaries can be reused (faster re-runs)
2. ✅ Debugging easier with artifacts present

### CI/CD Impact

In CI/CD environments:
- Fresh environment each run
- Artifacts don't accumulate
- Not a problem

In persistent dev environments (Ona/Gitpod):
- Artifacts accumulate over time
- Can cause issues
- **This is the problem we're solving**

## Solution Options

### Option 1: Add Cleanup to All Test Automations (Recommended)

**Approach**: Add cleanup step to each granular test automation

**Pros**:
- Consistent behavior across all test automations
- No manual intervention needed
- Disk space managed automatically
- Matches test-integration-all behavior

**Cons**:
- Slightly longer execution time (~1-2 seconds)
- Can't reuse test binaries for debugging

**Implementation**:
```yaml
test-consensus:
  command: |
    make integration-test INTEGRATION_TEST_SUITE="raft smartbft"
    EXIT_CODE=$?
    
    # Cleanup
    find integration/ -name "*.test" -type f -delete 2>/dev/null || true
    find core/chaincode/platforms/golang/testdata/pkg/ -type f -delete 2>/dev/null || true
    
    exit $EXIT_CODE
```

### Option 2: Add Post-Test Cleanup Automation

**Approach**: Create a new automation that runs after tests

**Pros**:
- Centralized cleanup logic
- Can be run on-demand
- Doesn't slow down tests

**Cons**:
- Requires manual trigger
- Easy to forget
- Doesn't solve go.sum issue

**Implementation**:
```yaml
cleanup-test-artifacts:
  name: "cleanup-test-artifacts"
  description: "Clean up test binaries and artifacts"
  command: |
    find integration/ -name "*.test" -type f -delete
    find core/chaincode/platforms/golang/testdata/pkg/ -type f -delete
    go mod tidy
    echo "✅ Test artifacts cleaned"
```

### Option 3: Add go mod tidy to check-code

**Approach**: Make check-code fix go.sum automatically

**Pros**:
- Fixes the immediate problem
- No changes to test automations
- Simple implementation

**Cons**:
- Doesn't clean test binaries
- Modifies files during check (unexpected)
- Masks the underlying issue
- Not idempotent

**Implementation**:
```yaml
check-code:
  command: |
    go mod tidy  # Fix go.sum first
    make basic-checks
```

### Option 4: Document and Accept

**Approach**: Document that developers should run cleanup manually

**Pros**:
- No code changes
- Preserves test binaries for debugging
- Simple

**Cons**:
- Poor developer experience
- Easy to forget
- Accumulates artifacts
- Doesn't solve the problem

## Recommendation

**Implement Option 1: Add Cleanup to All Test Automations**

### Rationale

1. **Consistency**: All test automations behave the same way
2. **Automatic**: No manual intervention required
3. **Predictable**: Developers know artifacts are cleaned
4. **Matches existing pattern**: test-integration-all already does this
5. **Solves go.sum issue**: Cleanup includes `go mod tidy`

### Enhanced Implementation

Add comprehensive cleanup to all test automations:

```yaml
test-consensus:
  command: |
    cd /workspaces/fabric
    
    # ... existing setup ...
    
    make integration-test INTEGRATION_TEST_SUITE="raft smartbft"
    EXIT_CODE=$?
    
    # Cleanup test artifacts
    echo "Cleaning up test artifacts..."
    find integration/ -name "*.test" -type f -delete 2>/dev/null || true
    find core/chaincode/platforms/golang/testdata/pkg/ -type f -delete 2>/dev/null || true
    
    # Fix go.sum if modified by tests
    go mod tidy 2>/dev/null || true
    
    if [ $EXIT_CODE -eq 0 ]; then
      echo "✅ Consensus tests complete and artifacts cleaned"
    else
      echo "❌ Consensus tests failed (exit code: $EXIT_CODE) but artifacts cleaned"
      exit $EXIT_CODE
    fi
```

### Benefits

1. ✅ **Prevents check-code failures** - go.sum is always clean
2. ✅ **Manages disk space** - artifacts don't accumulate
3. ✅ **Better UX** - no manual cleanup needed
4. ✅ **Consistent** - all tests behave the same
5. ✅ **Transparent** - clear output about cleanup

### Trade-offs

1. ⚠️ **Slightly slower** - adds 1-2 seconds per test run
2. ⚠️ **Can't reuse binaries** - must rebuild for re-runs
3. ⚠️ **Less debugging info** - artifacts removed immediately

These trade-offs are acceptable because:
- 1-2 seconds is negligible compared to 5-10 minute test runs
- Test binaries are rarely reused in practice
- Developers can disable cleanup if needed for debugging

## Implementation Plan

### Phase 1: Update Granular Test Automations

Update these automations with cleanup:
1. test-consensus
2. test-ledger
3. test-lifecycle
4. test-gateway
5. test-e2e

### Phase 2: Test and Validate

1. Run each test automation
2. Verify artifacts are cleaned
3. Verify go.sum is clean
4. Run check-code after each test
5. Confirm no failures

### Phase 3: Document

1. Update AUTOMATION_ANALYSIS.md
2. Add note about automatic cleanup
3. Document how to disable cleanup for debugging

### Phase 4: Monitor

1. Track disk space usage
2. Monitor check-code success rate
3. Gather developer feedback

## Alternative: Debugging Mode

For developers who need test artifacts for debugging, provide an environment variable:

```yaml
test-consensus:
  command: |
    # ... run tests ...
    
    # Cleanup unless debugging
    if [ "${SKIP_TEST_CLEANUP:-false}" != "true" ]; then
      echo "Cleaning up test artifacts..."
      # ... cleanup commands ...
    else
      echo "⚠️  Skipping cleanup (SKIP_TEST_CLEANUP=true)"
    fi
```

Usage:
```bash
# Normal run (with cleanup)
gitpod automations task start test-consensus

# Debug run (keep artifacts)
SKIP_TEST_CLEANUP=true gitpod automations task start test-consensus
```

## Conclusion

Test artifact cleanup is currently inconsistent:
- ✅ test-integration-all has cleanup
- ❌ Granular tests don't have cleanup
- ❌ go.sum modifications cause check-code failures

**Recommendation**: Add cleanup to all granular test automations to provide consistent, predictable behavior and prevent check-code failures.

**Impact**: Minimal (1-2 seconds per test), but significantly improves developer experience and prevents confusing errors.
