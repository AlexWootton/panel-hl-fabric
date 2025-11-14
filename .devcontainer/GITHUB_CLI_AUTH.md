# GitHub CLI Automatic Authentication

## Overview

The dev container automatically configures GitHub CLI authentication using your existing Git credentials. No manual `gh auth login` required!

## How It Works

### 1. Git Credential Helper

Gitpod/Ona provides Git credentials via a credential helper:

```bash
$ git config --get credential.github.com.helper
!f() { cat '/usr/local/gitpod/shared/git-secrets/...'; }; f
```

This credential file contains:
- `username`: oauth2
- `password`: Your GitHub token (gho_...)
- `scm_type`: github

### 2. Automatic Setup Script

The `.devcontainer/setup-gh-token.sh` script:

1. Locates the Git credential file
2. Extracts the GitHub token
3. Sets `GH_TOKEN` environment variable
4. Adds configuration to `~/.bashrc` for persistence

### 3. Dev Container Integration

The `devcontainer.json` includes:

```json
{
  "postStartCommand": "bash ${containerWorkspaceFolder}/.devcontainer/setup-gh-token.sh"
}
```

This runs automatically when the container starts.

## Token Scopes

The automatically provided token has these scopes:
- `read:user` - Read user profile information
- `repo` - Full control of private repositories
- `user:email` - Access user email addresses
- `workflow` - Update GitHub Action workflows

**Note**: The token is missing `read:org` scope, which is only needed for organization-level operations. All repository operations (PR creation, viewing, etc.) work fine.

## Usage

### No Authentication Needed

After container start, `gh` commands work immediately:

```bash
# Create a PR
gh pr create --title "My PR" --body "Description"

# View PRs
gh pr list

# Check out a PR
gh pr checkout 123

# View PR details
gh pr view 123

# Merge a PR
gh pr merge 123
```

### Verify Authentication

```bash
# Check authentication status
gh auth status

# Should show:
# ✓ Logged in to github.com account <username> (GH_TOKEN)
```

## Troubleshooting

### Authentication Not Working

If `gh` commands fail with authentication errors:

**Solution 1: Run setup script manually**
```bash
bash .devcontainer/setup-gh-token.sh
```

**Solution 2: Reload shell**
```bash
exec bash
```

**Solution 3: Set GH_TOKEN manually**
```bash
export GH_TOKEN=$(grep "^password=" $(git config --get credential.github.com.helper | sed 's/.*cat //;s/[^/]*$//' | tr -d "';" | xargs -I {} find {} -type f 2>/dev/null | head -1) | cut -d= -f2)
```

### Missing Scopes Error

If you see "missing required scope 'read:org'":

This is expected and doesn't affect repository operations. The `read:org` scope is only needed for organization-level commands like `gh org list`.

For repository operations (PR creation, viewing, etc.), the existing scopes are sufficient.

### Token Not Found

If the setup script reports "Git credential file not found":

1. Verify you're in a Gitpod/Ona environment
2. Check that Git operations work: `git push`
3. If Git works but token extraction fails, contact support

## Security

### Token Storage

- Token is stored by Gitpod/Ona in a secure location
- Only accessible to your user within the container
- Not committed to the repository
- Automatically rotated by Gitpod/Ona

### Token Exposure

The setup script:
- Does NOT log the token value
- Sets it as an environment variable (not visible in process lists)
- Adds it to `.bashrc` (user-specific, not shared)

### Best Practices

- Never commit the token to version control
- Don't share the token value
- Don't log or echo the token
- Use `gh` commands instead of direct API calls when possible

## Implementation Details

### Setup Script Location

`.devcontainer/setup-gh-token.sh`

### Script Logic

```bash
1. Find credential file from git config
2. Extract password field (GitHub token)
3. Export GH_TOKEN for current session
4. Add to ~/.bashrc for future sessions
5. Verify authentication with gh auth status
```

### Dev Container Configuration

`devcontainer.json`:
```json
{
  "postStartCommand": "bash ${containerWorkspaceFolder}/.devcontainer/setup-gh-token.sh"
}
```

Runs after container starts, before user interaction.

## Alternative: Manual Authentication

If you prefer manual authentication or need different scopes:

```bash
# Login with browser
gh auth login

# Login with token
echo "your-token" | gh auth login --with-token

# Refresh scopes
gh auth refresh -h github.com -s read:org
```

Manual authentication will override the automatic setup.

## References

- [GitHub CLI Manual](https://cli.github.com/manual/)
- [GitHub Token Scopes](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps)
- [Dev Container postStartCommand](https://containers.dev/implementors/json_reference/#lifecycle-scripts)

## Summary

✅ **Automatic**: No manual authentication required  
✅ **Secure**: Uses existing Git credentials  
✅ **Persistent**: Configured in shell profile  
✅ **Transparent**: Works immediately after container start  
✅ **Flexible**: Can be overridden with manual authentication if needed
