---
name: coral-setup
description: Use when installing, starting, stopping, inspecting, or configuring Coral Server, including npx coralos-dev, CONFIG_FILE_PATH, local server docs, auth keys, registry paths, production deployment, or deciding between local, self-hosted, and Cloud-assisted setup.
---

# Coral Setup

Use current runtime commands and live server docs as the source of truth. Do not patch Coral Server source from this skill unless the user explicitly asks to work on the server repo.

## First Check

From the user's intended project directory, inspect whether a server is already available:

```bash
curl -fsS http://localhost:5555/api_v1.json >/dev/null && echo "CORAL_SERVER_READY" || echo "CORAL_SERVER_NOT_READY"
```

If it is ready, open or reference:

- Console: `http://localhost:5555/ui/console`
- Docs: `http://localhost:5555/ui/docs`
- OpenAPI schema: `http://localhost:5555/api_v1.json`

Use the auth key configured for that server. Do not assume `dev` or `test` unless the current command/config set it.

## Local Development Server

For a disposable or development server, prefer the current npm launcher:

```bash
npx coralos-dev@latest server start -- --auth.keys=dev
```

Keep the process in the foreground unless the user explicitly asks for a persistent background service. Logs in the foreground are part of the debugging surface.

If the user wants a config file:

1. Create a project-local TOML config, for example `./coral-config.toml`.
2. Start with `CONFIG_FILE_PATH=./coral-config.toml npx coralos-dev@latest server start`.
3. Put server settings in `[auth]`, `[network]`, `[registry]`, `[llm-proxy]`, and `[cloud]` according to the live docs.

Useful config facts:

- CLI flags override config file values.
- `CONFIG_FILE_PATH` points to the TOML file; there is no default config path.
- Registry entries live under `[registry]`.
- `includeCoralHomeAgents = true` scans Coral home agent links by default.
- `localAgents`/`local_agents` can point at directories or whole-path wildcard segments containing `coral-agent.toml`.

## Agent Discovery

There are two valid ways to make agents discoverable:

| Pattern | Use when | Mechanism |
|---|---|---|
| Coralizer link | The agent already has `coral-agent.toml` and should be available to local servers on the machine | Run `npx @coral-protocol/coralizer@latest link .` from the agent directory. This creates a versioned link under `~/.coral/agents/...`. |
| Config file registry | The app or deployment should own exactly which agents a server sees | Add paths/globs under `[registry]` in the config file passed through `CONFIG_FILE_PATH`. |

Use Coralizer for developer ergonomics. Use config-file registry entries for reproducible app, CI, VM, or container deployments.

## Production / Self-Hosted

For production or shared environments, read `coral-encyclopedia` docs:

- `docs/guides/running-in-production.md`
- `docs/reference/server-config.md`
- live server docs at `/ui/docs`

General production rules:

- Use a secure auth key.
- Do not expose a development auth key publicly.
- Prefer Docker/runtime-managed services over ad hoc background shell processes.
- Keep app/product state outside Coral unless Coral explicitly owns that runtime data.
- Use app-owned logs/metrics for durable observability, and use Coral state/logs for session inspection.

## Coral Cloud Boundary

Current Cloud use does not automatically mean developer-owned agents are hosted by Coral Cloud. For now, distinguish:

- Your own agents on your own local/self-hosted Coral Server.
- Marketplace/Cloud-supported agents on Coral Cloud.
- Cloud-assisted self-hosting, especially the Coral LLM proxy via `[cloud] apiKey` or configured `[llm-proxy]` providers.

For Cloud-specific runtime behavior, use `coral-app-integration`.

## Stop / Cleanup

If you started the server in the current foreground terminal, stop it with Ctrl-C.

If the user asks you to stop a background server, identify the exact process and port first:

```bash
ps aux | grep -E "coral-server|coralos-dev" | grep -v grep
lsof -nP -iTCP:5555 -sTCP:LISTEN
```

Only kill the specific process you started or the process the user identifies.
