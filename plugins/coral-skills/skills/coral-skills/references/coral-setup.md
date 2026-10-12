# Coral Setup

Use current runtime commands and the running server's OpenAPI schema as source of truth. Do not patch Coral Server source from this skill unless the user explicitly asks to work on the server repo.

## Check Existing Server

From the intended project directory:

```bash
BASE_URL="${BASE_URL:-http://localhost:5555}"
curl -fsS "$BASE_URL/api_v1.json" >/dev/null && echo "CORAL_SERVER_READY" || echo "CORAL_SERVER_NOT_READY"
```

If ready:

- machine schema: `$BASE_URL/api_v1.json`
- human docs: `$BASE_URL/ui/docs`
- console: `$BASE_URL/ui/console`

Use the auth key configured for that server. Do not assume `dev` or `test` unless the current command/config set it.

## Start Local Server

For local development, run the server from source as `docs/guides/quickstart.md` shows. It needs JDK 24 and Git:

```bash
git clone https://github.com/Coral-Protocol/coral-server
cd coral-server
./gradlew run --args="--auth.keys=dev"
```

Agents that use the LLM proxy need a provider: pass a Coral Cloud API key with `--cloud.api-key`, or configure providers as `docs/reference/server/llm-proxy.md` describes. Do not use `npx coralos-dev`; its published version lags the server releases.

Keep the process in the foreground unless the user explicitly asks for a persistent background service. Logs in the foreground are part of the debugging surface.

With a config file, set `CONFIG_FILE_PATH` to it before starting. `docs/reference/server.md` lists the configuration tables.

## Agent Discovery

A deployed server gets its agents from its deployment. List agent directories under `registry.localAgents` in the config file passed through `CONFIG_FILE_PATH`, and ship those directories in the image or a mounted volume. Agents are never added to a running deployment as part of doing work.

On a developer's machine, `npx @coral-protocol/coralizer@latest link .` in an agent directory is a shortcut. It creates a versioned link under `~/.coral/agents/...`, which local servers scan by default.

## Self-Hosted Setup

For a self-hosted server, follow `docs/guides/production/running-in-production.md`, and make only source-backed claims:

- use the published Docker image with Docker-runtime agents; the image cannot run executable-runtime agents;
- use secure auth keys;
- keep config explicit through environment variables or `CONFIG_FILE_PATH`;
- verify the deployed server's `/api_v1.json` before generating API calls.

For Cloud-specific behavior, read `references/coral-app-integration.md`.

## Stop / Cleanup

If you started the server in the current foreground terminal, stop it with Ctrl-C.

If the user asks you to stop a background server, identify the exact process and port first:

```bash
ps aux | grep -E "coral-server|coralos-dev" | grep -v grep
lsof -nP -iTCP:5555 -sTCP:LISTEN
```

Only kill the specific process you started or the process the user identifies.
