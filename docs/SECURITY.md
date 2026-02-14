# Security notes

This setup is safer than “let the LLM run shell on your host”, but it is still powerful.

## Why containerize
- Limits filesystem exposure to the mounted project directory + per-project runtime directories.
- Keeps host secrets out of reach unless you mount them.
- Makes it easy to wipe/recreate environments.

## Recommended guardrails
- Do not mount your full home directory.
- Prefer API keys in `.ai-counsel/env` with least-privilege scopes.
- Keep `.ai-counsel/` and runtime directories out of git.
- Run on trusted code when using any “agent that can run commands” modes.

Gemini CLI had a reported security issue related to allow-listed command execution; Google fixed versions, but the moral is: sandboxing matters. citeturn0news38

