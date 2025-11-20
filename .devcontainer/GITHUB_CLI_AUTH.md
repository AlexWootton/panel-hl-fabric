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
2. Sets the `GH_TOKEN` environment variable for the current session
3. Adds dynamic token extraction code to `~/.bashrc` for all future shell sessions

This happens via `postCreateCommand` in `devcontainer.json` (runs once per container lifecycle).

**Key Features:**
- **One-time setup** - Runs once on container creation, not on every start
- **Dynamic token extraction** - Bashrc code automatically picks up token rotations in new shells
- **Idempotent** - Skips setup if already configured
- **Zero configuration** - Works out of the box

**Token Rotation Handling:**

The setup script adds this code to your `~/.bashrc`:
```bash
# GitHub CLI authentication
CRED_FILE=$(git config --get credential.github.com.helper 2>/dev/null | grep -oP "cat '\K[^']+")
if [ -n "$CRED_FILE" ] && [ -f "$CRED_FILE" ]; then
    export GH_TOKEN=$(grep "^password=" "$CRED_FILE" 2>/dev/null | cut -d= -f2)
fi
```

This means every new shell session automatically extracts the current token from Git credentials, so token rotation is handled without re-running the setup script.

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
