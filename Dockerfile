FROM python:3.11-slim

# System deps: git for vendoring, node/npm for CLIs
RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates curl nodejs npm \
  && rm -rf /var/lib/apt/lists/*

# Non-root user
RUN useradd -m -u 1000 -s /bin/bash app
USER app
ENV HOME=/home/app
ENV NPM_CONFIG_PREFIX=/home/app/.npm-global
ENV PATH=/home/app/.local/bin:/home/app/.npm-global/bin:${PATH}
WORKDIR /work

# Install CLIs
# - Codex CLI: npm i -g @openai/codex (OpenAI docs)
# - Gemini CLI: npm i -g @google/gemini-cli (Gemini CLI docs)
# - OpenCode: npm i -g opencode-ai (OpenCode docs)
RUN npm install -g \
    @openai/codex \
    @google/gemini-cli \
    opencode-ai

# Vendored AI Counsel is expected in the build context at vendor/ai-counsel
COPY --chown=app:app vendor/ai-counsel /opt/ai-counsel
WORKDIR /opt/ai-counsel

# Python deps
RUN pip install --no-cache-dir -r requirements.txt

# Default config is mounted in at runtime by wrapper, but we ship one too.
WORKDIR /work
COPY --chown=app:app config/ai-counsel/config.yaml /opt/ai-counsel/config.yaml

# Optional extensions (future)
COPY --chown=app:app extensions /work/extensions

WORKDIR /opt/ai-counsel
CMD ["python", "-u", "server.py"]
