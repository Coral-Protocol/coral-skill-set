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

For local development, use the current launcher:

```bash
npx coralos-dev@latest server start -- --auth.keys=dev
```

Keep the process in the foreground unless the user explicitly asks for a persistent background service. Logs in the foreground are part of the debugging surface.

With a config file:

```bash
CONFIG_FILE_PATH=./coral-config.toml npx coralos-dev@latest server start
```

Use the current server config reference from `references/coral-runtime-reference.md` or the local source before writing non-trivial config.

## Agent Discovery

There are two valid ways to make agents discoverable:

| Pattern | Use when | Mechanism |
|---|---|---|
| Coralizer link | The agent already has `coral-agent.toml` and should be available to local servers on the machine | Run `npx @coral-protocol/coralizer@latest link .` from the agent directory. This creates a versioned link under `~/.coral/agents/...`. |
| Config file registry | The app or deployment should own exactly which agents a server sees | Add paths/globs under `[registry]` in the config file passed through `CONFIG_FILE_PATH`. |

Use Coralizer for developer ergonomics. Use config-file registry entries for reproducible app, CI, VM, or container deployments.

## Self-Hosted Setup

For a self-hosted server, make only source-backed claims:

- inspect the current image/package/start command;
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
