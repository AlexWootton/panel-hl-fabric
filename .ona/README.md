# Ona Configuration

This directory contains configuration for Ona Agents and integrations.

## MCP Configuration

The `mcp-config.json` file configures Model Context Protocol (MCP) servers that extend Ona Agent capabilities.

### GitHub MCP Server

Enables Ona Agent to interact with GitHub beyond basic Git operations:

**Capabilities:**
- Create and manage Pull Requests
- Read PR comments and reviews
- Check GitHub Actions status and logs
- Access repository metadata

**Authentication:**
- Automatically extracts GitHub token from Gitpod's git credential helper
- Same token used by `gh` CLI (configured in `.devcontainer/setup-gh-token.sh`)
- No additional configuration required

**Security:**
- Runs in isolated Docker container
- `search_code` tool is denied for safety
- Uses read-only access where possible

**How it works:**
1. Ona Agent requests GitHub operation
2. MCP server extracts token from git credentials
3. Docker container runs GitHub MCP server with token
4. Operation executes via GitHub API
5. Results returned to Ona Agent

### Adding More MCP Servers

To add additional MCP servers (e.g., Linear, Jira), add them to the `mcpServers` object in `mcp-config.json`.

Example for Linear (requires `LINEAR_API_KEY` user secret):
```json
{
  "mcpServers": {
    "github": { ... },
    "linear": {
      "command": "/usr/local/bin/linear-mcp-go",
      "args": ["serve", "--write-access=false"],
      "name": "linear"
    }
  }
}
```

## Resources

- [Ona Best Practices - SCM Integration](https://ona.com/docs/ona/best-practices#scm-integration:-github,-gitlab,-bitbucket)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
