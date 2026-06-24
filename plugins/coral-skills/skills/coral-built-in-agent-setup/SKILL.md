---
name: coral-built-in-agent-setup
description: Use when installing, refreshing, or verifying the bundled Coral example agent templates in this plugin, including Puppet, Claude Code, Hermes, and OpenClaw local agent manifests.
---

# Coral Built-In Agent Setup

This skill copies packaged example agent manifests and startup scripts. It does not define the preferred application architecture.

Bundled templates live in `${SKILL_DIR}/agents/`.

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
cp -R "${SKILL_DIR}/agents/$AGENT_NAME/." "$HOME/.coral/agents/$AGENT_NAME/"
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

Use `coral-session-control` only when the user wants to drive a concrete session through the API.
