---
name: coral-built-in-agent-setup
description: Use when installing or refreshing bundled example Coral agents such as Claude Code, Hermes, OpenClaw, or Puppet, checking their CLI prerequisites, copying bundled agent templates, or making these local agents discoverable by a Coral Server.
---

# Coral Built-In Agent Setup

This skill installs bundled local agent templates. It should not assume a Coral Server source checkout exists.

Bundled templates live in `${SKILL_DIR}/agents/`.

## Check The Server Shape

If a server is running, establish its base URL and auth key, then verify:

```bash
curl -fsS "$BASE_URL/api_v1.json" >/dev/null
```

If no server is running, installing templates is still possible, but registry verification must wait until a server is started with `coral-setup`.

## Choose Agents

Puppet is the useful default for API-driven session control. Ask before installing the optional agents:

- Puppet: lightweight HTTP proxy/test agent.
- Claude Code: requires `claude`.
- Hermes: requires `hermes`.
- OpenClaw: requires `openclaw`.

Check selected prerequisites:

```bash
echo "=== CLAUDE CODE ===" && (claude --version 2>&1 || echo "NOT_INSTALLED")
echo "=== HERMES ===" && (hermes --version 2>&1 || echo "NOT_INSTALLED")
echo "=== OPENCLAW ===" && (openclaw --version 2>&1 || echo "NOT_INSTALLED")
```

Stop if a selected agent's CLI is missing and tell the user what to install.

## Install Templates

Install selected templates under `~/.coral/agents/`.

Before overwriting an existing directory, inspect it and ask the user if they want to replace it. If installing fresh, copy the template contents into the destination directory:

```bash
mkdir -p ~/.coral/agents
mkdir -p ~/.coral/agents/puppet
cp -R "${SKILL_DIR}/agents/puppet/." ~/.coral/agents/puppet/
chmod +x ~/.coral/agents/puppet/startup.sh
```

Repeat the same copy/chmod pattern for selected optional agents:

- `${SKILL_DIR}/agents/claude-code` -> `~/.coral/agents/claude-code`
- `${SKILL_DIR}/agents/hermes` -> `~/.coral/agents/hermes`
- `${SKILL_DIR}/agents/openclaw` -> `~/.coral/agents/openclaw`

## Make Agents Discoverable

Prefer the server's current registry mechanics over editing a source checkout.

Options:

1. If the server config has `includeCoralHomeAgents = true` or default behavior scans Coral home agents, the copied templates should be discoverable.
2. If the deployment owns a config file, add exact paths or globs under `[registry] localAgents` / `local_agents`.
3. If the user wants a reproducible project-local setup, use `CONFIG_FILE_PATH` with a project-owned config file and include the bundled-agent paths there.

Do not assume the config file is at `~/.coral/coral-server/src/main/resources/config.toml`.

## Verify

When a server is running, verify through the registry API or Console using the server's live docs:

```bash
curl -fsS "$BASE_URL/api/v1/registry" \
  -H "Authorization: Bearer $AUTH_KEY"
```

Confirm the installed agent names and versions appear before using them in a session template.

## Next

Use `coral-agent-swarm` only when the user wants to drive a concrete session through the API.
