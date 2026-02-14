# Usage (per project)

This toolbox is meant to be installed once, then used from any project.

## 1) Build + install wrapper (one time)

```bash
cd ~/src/ai-counsel-mcp-toolbox
./bin/vendor-ai-counsel
docker build -t ai-counsel-mcp:latest .
./bin/install-global-wrapper
```

## 2) In each project: recommended folder
Create in your project:

```
.ai-counsel/
  env
  config.yaml
```

Add to `.gitignore`:
```
.ai-counsel/
```

- `.ai-counsel/env` is passed to Docker with `--env-file`.
- `.ai-counsel/config.yaml` overrides the toolbox config.

## 3) Configure MCP clients

### Claude Code
Project `.mcp.json`:

```json
{
  "mcpServers": {
    "ai-counsel": {
      "type": "stdio",
      "command": "mcp-ai-counsel",
      "args": []
    }
  }
}
```

### Codex CLI
Project `.codex/config.toml`:

```toml
[mcp_servers.ai-counsel]
command = "mcp-ai-counsel"
args = []
```

### Gemini CLI
Project `.gemini/settings.json`:

```json
{
  "mcpServers": {
    "ai-counsel": {
      "command": "mcp-ai-counsel",
      "args": []
    }
  }
}
```

### OpenCode
OpenCode reads MCP servers from `opencode.json` (project) or `~/.config/opencode/opencode.json` (global).
Example **project** `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "ai-counsel": {
      "type": "local",
      "command": ["mcp-ai-counsel"],
      "enabled": true
    }
  }
}
```

## 4) Auth inside the container
Open an interactive shell with the same per-project runtime mounts:

```bash
mcp-ai-counsel --shell
```

Then run the CLI-specific login commands (see `AUTH.md`).
