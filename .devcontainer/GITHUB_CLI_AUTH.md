# GitHub CLI Authentication

## Overview

The GitHub CLI (`gh`) is **automatically authenticated** using your Git credentials. No manual setup required!

## Usage

```bash
# Create a PR
gh pr create --title "Your PR title" --body "Description"

# View and manage PRs
gh pr list
gh pr checkout <number>
gh pr view <number>

# Check authentication status
gh auth status
```

## How It Works

The dev container automatically:
1. Extracts your GitHub token from Git credential helper (provided by Gitpod)
2. Sets the `GH_TOKEN` environment variable
3. Configures your shell for future sessions with dynamic token extraction

This happens via `postCreateCommand` in `devcontainer.json` (runs once per container).

**Key Features:**
- **Idempotent** - Skips setup if already authenticated
- **Dynamic token extraction** - Automatically picks up token rotations
- **Zero configuration** - Works out of the box

## Troubleshooting

If `gh` commands fail with authentication errors:

```bash
# Re-run the setup script
bash .devcontainer/setup-gh-token.sh

# Or reload your shell
exec bash

# Manual authentication (if needed)
gh auth login
```

## Technical Details

The setup script extracts the GitHub token from Gitpod's git credential helper and makes it available to the `gh` CLI. The token includes these scopes:
- `read:user` - Read user profile
- `repo` - Repository access
- `user:email` - Email access
- `workflow` - GitHub Actions access
