# AI Working Guide (for LLMs)

You are operating in the **AI Counsel MCP Toolbox** repository.

## Goal
Build and run a Docker image that provides:
- AI Counsel as an MCP server (stdio)
- CLIs: Codex, Gemini, OpenCode (plus optional Claude CLI)
- A global wrapper (`mcp-ai-counsel`) that any project can call as an MCP server.

## Key files
- `Dockerfile` – builds the all-in-one image (python + node CLIs).
- `bin/mcp-ai-counsel` – **global wrapper**. Called by MCP clients from arbitrary projects.
- `config/ai-counsel/config.yaml` – default adapter config used unless overridden by a project `.ai-counsel/config.yaml`.
- `docs/AUTH.md` – how auth persists per project.
- `docs/EXTENDING.md` – how to add adapters/tools cleanly.

## How the wrapper works
When run inside a project directory:
- hashes the current `$PWD`
- creates per-project runtime dirs under `~/.cache/ai-counsel-mcp/<hash>/...`
- mounts project to `/work`
- mounts runtime dirs to `/home/app/...` paths for each CLI
- launches `ai-counsel-mcp:latest` as a stdio MCP server

This design allows **parallel** use across multiple projects without credential/caching collisions.

## “Don’t surprise the user”
- Never modify files outside `/work`.
- Never assume secrets exist; if missing, instruct the user to add `.ai-counsel/env` in the project.
- Keep MCP usage safe: timeouts, limited command execution, and disable hooks where available.

## Extension approach
Prefer adding new CLI adapters or MCP tools by:
- implementing them under `extensions/ai_counsel_ext/`
- documenting the patch points in `docs/EXTENDING.md`
- keeping vendored upstream minimal and updateable.

