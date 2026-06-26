# Coral Built-In Agent Setup

This reference covers packaged example agent manifests and startup scripts. It does not define the preferred application architecture.

Bundled templates live in `${SKILL_DIR}/assets/agents/`.

The bundled manifests may intentionally use an older supported `edition` for compatibility. When creating new manifests or updating templates for a specific server release, verify the supported edition range against the running server or local `coral-server` source before changing `edition`.

## Inputs

Choose which packaged templates to install:

- `puppet`
- `claude-code`
- `hermes`
- `openclaw`

If a server is running, establish `BASE_URL` and `AUTH_KEY` and verify:

```bash
curl -fsS "$BASE_URL/api_v1.json" >/dev/null
```

If no server is running, install templates first and verify discovery later.

## Prerequisites

Check the CLI for each selected template:

| Template | Check |
|---|---|
| `claude-code` | `claude --version` |
| `hermes` | `hermes --version` |
| `openclaw` | `openclaw --version` |
| `puppet` | inspect bundled `startup.sh` |

## Install Templates

Install selected templates under `~/.coral/agents/` unless the user asks for a project-local copy.

Before overwriting an existing destination, inspect it and ask the user if they want to replace it.

```bash
mkdir -p ~/.coral/agents
AGENT_NAME="puppet"
mkdir -p "$HOME/.coral/agents/$AGENT_NAME"
cp -R "${SKILL_DIR}/assets/agents/$AGENT_NAME/." "$HOME/.coral/agents/$AGENT_NAME/"
chmod +x "$HOME/.coral/agents/$AGENT_NAME/startup.sh"
```

## Make Agents Discoverable

Use one of the current server discovery paths:

- Coral home scan, if enabled by server config.
- `[registry]` entries in the config file passed through `CONFIG_FILE_PATH`.
- `npx @coral-protocol/coralizer@latest link .` when working from a template directory with `coral-agent.toml`.

Do not edit a Coral Server source checkout to install agents unless the user explicitly asks to work on the server repo.

## Verify

When a server is running, use the registry endpoint from its OpenAPI schema:

```bash
curl -fsS "$BASE_URL/api/v1/registry" \
  -H "Authorization: Bearer $AUTH_KEY"
```

Confirm the installed agent names and versions appear before using them in a session template.

Read `references/coral-session-control.md` only when the user wants to drive a concrete session through the API.
