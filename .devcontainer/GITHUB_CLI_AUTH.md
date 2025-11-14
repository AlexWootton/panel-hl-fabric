# GitHub CLI Authentication

## Overview

The GitHub CLI (`gh`) is **automatically authenticated** using your Git credentials. No manual setup required!

## Usage

Just use `gh` commands directly:

```bash
# Create a PR
gh pr create --title "Your PR title" --body "Description"

# View PRs
gh pr list

# Check out a PR
gh pr checkout <number>

# View PR details
gh pr view <number>
```

## How It Works

The dev container automatically:
1. Extracts your GitHub token from Git credential helper
2. Sets the `GH_TOKEN` environment variable
3. Configures your shell for future sessions

This happens via `postStartCommand` in `devcontainer.json`.

## Troubleshooting

### Authentication Errors

If `gh` commands fail with authentication errors:

```bash
# Re-run the setup script
bash ${containerWorkspaceFolder}/.devcontainer/setup-gh-token.sh

# Or reload your shell
exec bash
```

### Check Authentication Status

```bash
gh auth status
```

### Manual Authentication (if needed)

```bash
gh auth login
```

## Technical Details

The setup script (`.devcontainer/setup-gh-token.sh`):
- Locates Git credential file provided by Gitpod
- Extracts GitHub token (format: `gho_...`)
- Sets `GH_TOKEN` environment variable
- Adds configuration to `~/.bashrc`

The token has these scopes:
- `read:user` - Read user profile
- `repo` - Repository access
- `user:email` - Email access
- `workflow` - GitHub Actions access
