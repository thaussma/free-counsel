# AI Counsel MCP Toolbox (Docker, Multi-CLI)

This repo is a **toolbox** you keep checked out once (anywhere on your Mac).  
It builds a **single Docker image** that contains:

- **AI Counsel** (MCP server)
- **Codex CLI** (`@openai/codex`)
- **Gemini CLI** (`@google/gemini-cli`)
- **OpenCode CLI** (`opencode-ai`)
- (optional) **Claude Code CLI** (install separately if you want it inside the container)

Then you use a **global wrapper** (`mcp-ai-counsel`) to expose AI Counsel as an MCP server to **any project**, in parallel, with **per-project isolated auth + caches**.

---

## Quick start (humans)

### 0) Prereqs
- Docker Desktop (macOS)
- A modern shell (zsh/bash)

### 1) One-command bootstrap (recommended)
```bash
cd ~/src/ai-counsel-mcp-toolbox
./bin/bootstrap
```

What it does:
- vendors/updates AI Counsel
- builds `ai-counsel-mcp:latest` (optimized mode by default)
- installs `mcp-ai-counsel` wrapper
- creates project-local `.ai-counsel/config.yaml` and `.ai-counsel/env` from `.env.example`
- creates MCP config files for Claude/Codex/Gemini/OpenCode (create-only by default)
- imports host auth into this project's isolated runtime mounts

If host auth for a provider is missing, bootstrap prints a warning.  
Authenticate on host, then rerun `./bin/bootstrap`.

Runtime/auth cache default location:
- `<project>/.cache/ai-counsel-mcp/<basename>-<short-hash>/...`
- override with `AI_COUNSEL_RUNTIME_ROOT` if needed

Common options:
```bash
./bin/bootstrap --build-mode default
./bin/bootstrap --build-mode optimized-full
./bin/bootstrap --clients claude,codex
./bin/bootstrap --force
./bin/bootstrap --dry-run
```

### 2) Manual build path (optional)
```bash
cd ~/src/ai-counsel-mcp-toolbox
./bin/vendor-ai-counsel   # clones AI Counsel into vendor/ai-counsel (or updates it)
docker build -t ai-counsel-mcp:latest .
```

Optional optimized build (same image name/tag if you want to replace the default):
```bash
docker build -f Dockerfile.optimized -t ai-counsel-mcp:latest .
```

Optimized full build (includes heavier ML deps used by advanced convergence backends):
```bash
docker build -f Dockerfile.optimized \
  --build-arg AI_COUNSEL_INCLUDE_HEAVY_DEPS=1 \
  -t ai-counsel-mcp:latest .
```

### 3) Install the global wrapper
```bash
./bin/install-global-wrapper
# then ensure ~/bin is on PATH (zsh default often includes it; if not, add it)
```

This creates a symlink:
- `~/bin/mcp-ai-counsel` → `<this-repo>/bin/mcp-ai-counsel`

### 4) In any project: add MCP config that calls `mcp-ai-counsel`

#### Claude Code (project `.mcp.json`)
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

#### Codex CLI (project `.codex/config.toml`)
```toml
[mcp_servers.ai-counsel]
command = "mcp-ai-counsel"
args = []
```

#### Gemini CLI (project `.gemini/settings.json`)
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

#### OpenCode (project `opencode.json`)
OpenCode uses its own MCP config schema; see `docs/USAGE.md` for a working example.

---

## Per-project secrets & overrides (recommended)

Inside each **project repo**, create:

```
.ai-counsel/
  env          # environment variables (API keys), NOT committed
  config.yaml  # optional AI Counsel config override, NOT committed
```

Add to your project `.gitignore`:
```
.ai-counsel/
```

- If `.ai-counsel/env` exists, the wrapper passes it to Docker as `--env-file`.
- If `.ai-counsel/config.yaml` exists, the wrapper uses it instead of the toolbox default.

See:
- `docs/AUTH.md`
- `docs/USAGE.md`

---

## Running logins inside the container

Use:
```bash
mcp-ai-counsel --shell
```

This opens a shell in the same “per-project” container environment (same runtime mounts), so auth state is persisted.  
Then you can run, for example:
- `codex login` / `codex logout`
- `opencode auth login`
- `gemini` (first run prompts browser login if using Google login)

See `docs/AUTH.md`.

---

## Extending AI Counsel (future)

You have two strategies:

1) **Fork-first**: vendor your fork under `vendor/ai-counsel` and patch directly.
2) **Extension package** (recommended): put code in `extensions/` and add small, controlled patches to AI Counsel to load/register your extras.

See `docs/EXTENDING.md`.

---

## What gets installed and where (inside container)

- AI Counsel: `/opt/ai-counsel`
- Working project: `/work`
- Auth/caches (mounted per project by wrapper):
  - Codex: `/home/app/.codex`
  - Gemini: `/home/app/.gemini`
  - OpenCode: `/home/app/.local/share/opencode` and `/home/app/.config/opencode`
  - gcloud (optional, for ADC): `/home/app/.config/gcloud`
