# Hyperledger Fabric Development Guidelines

## Project Overview
This is the Hyperledger Fabric repository - an enterprise-grade, distributed ledger platform for building blockchain networks written in Go.

## Common Commands

### Building
- `make native` - Build all native binaries (peer, orderer, configtxgen, etc.)
- `make docker` - Build Fabric Docker images
- `make clean` - Clean build artifacts
- `make clean-all` - Clean everything including persistent state

### Testing
- `make unit-test` - Run unit tests
- `make integration-test` - Run integration tests (requires Docker)
- `make verify` - Run tests for changed packages only
- `make basic-checks` - Run linting, license checks, spelling, etc.

### Code Quality
- `make linter` - Run code linter
- `make license` - Check for license headers
- `make spelling` - Check for spelling errors

### Using Ona Automations

#### Automatic
- Binaries are **automatically built** on environment start

#### Network Management
- `gitpod automations task start start-test-network` - Start test network (one command!)
- `gitpod automations task start deploy-chaincode` - Deploy sample chaincode
- `gitpod automations task start stop-test-network` - Stop test network

#### Testing & Quality
- `gitpod automations task start test-unit` - Run unit tests
- `gitpod automations task start run-integration-tests` - Run integration tests
- `gitpod automations task start benchmark` - Run performance benchmarks
- `gitpod automations task start check-code` - Run code quality checks

#### Utilities
- `gitpod automations task start clean-integration-tests` - Clean test binaries (~600MB)
- `gitpod automations task start clean-all` - Clean all artifacts and Docker resources
- `gitpod automations task list` - List all available tasks
- See `.gitpod/TRIGGERS.md` for automation trigger details

## Key Directories
- `cmd/` - Command-line tools (peer, orderer, configtxgen, etc.)
- `core/` - Core Fabric functionality
- `orderer/` - Ordering service implementation
- `common/` - Common utilities and libraries
- `gossip/` - Gossip protocol implementation
- `msp/` - Membership Service Provider
- `integration/` - Integration tests
- `sampleconfig/` - Sample configuration files
- `build/bin/` - Built binaries (after running make native)

## Code Style
- Follow Go best practices and idioms
- Use `gofmt` for formatting
- Run `make linter` before committing
- All code must have Apache 2.0 license headers

## Development Workflow

### Making Changes
1. Create a feature branch from `main`
2. Make your changes
3. Run `make basic-checks` to verify code quality
4. Run `make unit-test` to ensure tests pass
5. Build binaries with `make native` to verify compilation

### Testing with Test Network
1. Start the network: `gitpod automations task start start-test-network`
   - This automatically clones fabric-samples, pulls images, and starts the network
2. Deploy chaincode: `cd /workspaces/fabric-samples/test-network && ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go`
3. Stop the network: `gitpod automations task start stop-test-network`

### Docker Requirements
- Docker-in-Docker is enabled in the dev container
- Use `make docker-thirdparty` to pull required images (CouchDB, etc.)
- Use `make docker` to build Fabric images

## Important Notes
- **ALWAYS** use `make` commands instead of running `go build` directly
- **ALWAYS** run `make basic-checks` before committing
- Built binaries are in `build/bin/` directory
- Configuration files are in `sampleconfig/` directory
- The test network requires fabric-samples repository (use setup-test-network automation)

## Environment Variables
- `FABRIC_CFG_PATH` - Points to configuration directory (default: `sampleconfig/`)
- `GOPATH` - Go workspace path
- `GO_VER` - Required Go version (defined in go.mod)

## Agent Guidelines for Documentation

### Temporary Documentation Management

When creating analysis, design, or implementation documents during development:

**DO**:
- ✅ Create detailed analysis documents to support PR review
- ✅ Document design decisions and rationale
- ✅ Provide implementation guides for complex changes
- ✅ Use descriptive names (e.g., `AUTOMATION_ANALYSIS.md`, `IMPLEMENTATION_PLAN.md`)

**DO NOT**:
- ❌ Commit temporary analysis documents to the repository long-term
- ❌ Leave implementation plans after the work is complete
- ❌ Keep design documents that duplicate commit messages

**Cleanup Process**:
1. Create temporary docs during development (useful for PR review)
2. Reference them in commit messages if needed
3. **Delete them before final commit** or in a cleanup commit
4. Keep only permanent documentation:
   - User-facing guides (README.md)
   - Operational procedures (TRIGGERS.md, VALIDATION.md)
   - Configuration documentation

**Rationale**:
- Temporary docs add clutter after merge
- Information is preserved in commit messages and git history
- Reduces maintenance burden
- Keeps repository focused on current, actionable documentation

**Example Cleanup**:
```bash
# Remove temporary analysis documents
rm .gitpod/AUTOMATION_ANALYSIS.md
rm .gitpod/IMPLEMENTATION_PLAN.md
rm .gitpod/TEST_ARTIFACT_ANALYSIS.md

# Commit cleanup
git add .gitpod/
git commit -m "Remove temporary analysis documents

These documents served their purpose during PR review.
The information is preserved in commit messages:
- Commit abc123: Design rationale
- Commit def456: Implementation details

Keeping only permanent documentation."
```

### Permanent vs Temporary Documentation

**Permanent** (Keep in repository):
- User guides and tutorials
- API documentation
- Configuration references
- Operational procedures
- Troubleshooting guides
- Architecture overviews (high-level, stable)

**Temporary** (Delete after use):
- Design analysis documents
- Implementation plans
- Decision records (use commit messages instead)
- Investigation notes
- Performance analysis (unless ongoing reference)
- Migration guides (after migration complete)

## Resources
- [Fabric Documentation](https://hyperledger-fabric.readthedocs.io/)
- [Test Network Tutorial](https://hyperledger-fabric.readthedocs.io/en/latest/test_network.html)
- [Contributing Guide](./CONTRIBUTING.md)
- [Ona Automations README](./.gitpod/README.md)
