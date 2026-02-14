# Extending AI Counsel (adapters + new MCP tools)

You want to add:
- new **CLI adapters** (e.g. `vibe` for Mistral)
- new **MCP tools** (image generation, chat, review helpers)

## Strategy A: Fork-first (simplest)
- Fork AI Counsel
- Point `bin/vendor-ai-counsel` at your fork
- Add adapters/tools directly inside AI Counsel
Pros: zero glue.  
Cons: you carry a fork, must rebase.

## Strategy B: Extension package (clean separation, recommended)
Keep upstream AI Counsel vendored as-is and put your additions in:
- `extensions/ai_counsel_ext/adapters/`
- `extensions/ai_counsel_ext/tools/`

Then add a very small patch to AI Counsel startup to load your extension (two common patterns):
1. **Import hook**: in `server.py` (or a config-loaded module), import `ai_counsel_ext` and call a `register()` function.
2. **Wrapper server**: create `server_ext.py` that imports AI Counsel server and registers extras, then run that as your container CMD.

This repo currently ships the `extensions/` folder as a place to grow into Strategy B.

## Adding a CLI adapter (concept)
A CLI adapter usually needs:
- executable name (`vibe`)
- args template (include `{prompt}` and optional `{model}`)
- timeout and retries
You then add it under `adapters:` in `config.yaml`.

## Adding a new MCP tool (concept)
A new tool should:
- have a narrow surface (typed params)
- run inside the container with clear filesystem boundaries
- return structured results (JSON-friendly)

Keep new tools “safe-by-default”:
- explicit allowlists
- no implicit network egress unless needed
- timeouts and output caps

