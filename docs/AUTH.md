# Authentication (containerized CLIs)

This toolbox runs CLIs **inside** the container, but persists auth state **per project** by mounting runtime dirs.

## Where auth state lives (inside container)
- Codex: `/home/app/.codex`
- Gemini: `/home/app/.gemini`
- OpenCode: `/home/app/.local/share/opencode/auth.json` (and config in `/home/app/.config/opencode/`)
- gcloud ADC (optional): `/home/app/.config/gcloud`

The wrapper mounts these from:
`~/.cache/ai-counsel-mcp/<project-hash>/...`

## Recommended workflow
1. In your project repo, create `.ai-counsel/env` for API keys (if you use keys).
2. Run `mcp-ai-counsel --shell` from that project.
3. Do interactive logins inside the container as needed.
4. Exit; auth persists for that project.

## Codex CLI
OpenAI docs: first run prompts sign-in; also supports `codex login` / `codex logout`.  
- CLI reference includes `codex login` and `codex logout`. citeturn0search15turn0search4
- General CLI doc notes it prompts to sign in on first run. citeturn0search0

Inside container shell:
```bash
codex login
# or use API key auth (set OPENAI_API_KEY in .ai-counsel/env)
```

## OpenCode CLI
OpenCode supports:
```bash
opencode auth login
```
Credentials are stored in `~/.local/share/opencode/auth.json`. citeturn0search2turn0search6

## Gemini CLI
Gemini CLI supports several auth methods; the “Login with Google” flow opens a browser and caches credentials. citeturn0search5turn0search1

Headless option: use API keys (`GEMINI_API_KEY` / `GOOGLE_API_KEY`) via `.ai-counsel/env`. citeturn0search5turn0search1

## Claude Code / Claude CLI
Claude Code auth methods vary by deployment (Teams/Enterprise, Console, Bedrock, Vertex, etc.). citeturn0search3

If you run Claude Code CLI locally on the host, it can still call this toolbox MCP server.  
If you also run `claude` inside the container, mount its config/auth dirs (the wrapper already creates per-project mounts for this).

