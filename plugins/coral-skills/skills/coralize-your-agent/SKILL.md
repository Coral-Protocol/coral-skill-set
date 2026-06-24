---
name: coralize-your-agent
description: Use when connecting a developer-owned agent project to Coral, linking an existing coral-agent.toml, wrapping an MCP server or framework agent, choosing Coralizer versus registry config, or making an agent discoverable by a local or self-hosted Coral Server.
---

# Coralize Your Agent

Use current Coral agent/runtime specs as the source of truth. This skill should make an agent discoverable and runnable by Coral without making the app depend on this skill's local conventions.

## Inputs To Establish

Ask for the agent project path if it is not already clear.

Then inspect:

```bash
test -f "$AGENT_PATH/coral-agent.toml" && echo "HAS_CORAL_AGENT_TOML" || echo "NO_CORAL_AGENT_TOML"
test -f "$AGENT_PATH/package.json" && echo "HAS_PACKAGE_JSON" || true
find "$AGENT_PATH" -maxdepth 3 -name coral-agent.toml -print
```

If the user provided a source subdirectory, check parent/child directories before concluding there is no manifest.

## Path A: Existing Coral Agent Manifest

If the project already has `coral-agent.toml`, prefer one of these discovery mechanisms:

| Mechanism | Use when |
|---|---|
| `npx @coral-protocol/coralizer@latest link .` | Developer wants the agent available to local Coral Servers on this machine. |
| `[registry] localAgents = [...]` in a config file | App, CI, VM, or container deployment should own exactly which agent paths the server scans. |

After linking or configuring, verify through the server registry endpoint or Console rather than assuming the agent loaded.

## Path B: Existing MCP Server Or Tool Process

If the project exposes an MCP server, use Coralizer's MCP wrapping flow from the current Coralizer docs.

General shape:

1. Prepare an MCP server description JSON.
2. Run Coralizer to scaffold a Coral agent project.
3. Edit the generated `coral-agent.toml`.
4. Link the generated agent or add it to server config.

Do not hardcode one framework if Coralizer or the current docs support a better path.

## Path C: Framework-Specific Adapter

If no manifest exists and the project is a supported framework, use the relevant reference.

Current bundled reference:

- Mastra: read `${SKILL_DIR}/references/mastra.md`

Framework-specific adapters may create wrapper files, worker entrypoints, or startup scripts. Keep those changes additive: the original agent should still be understandable and runnable outside Coral where practical.

## Path D: Unsupported Framework

If no supported adapter exists:

1. Use `coral-encyclopedia` for `docs/guides/writing-agents.md` and `docs/reference/agent-config.md`.
2. Explain the minimal Coral contract: the agent runtime must connect to the Coral-provided MCP URL/secret and declare a valid `coral-agent.toml`.
3. Offer a small wrapper approach instead of editing the core agent deeply.

## Verification

After any integration:

- Confirm the agent path has a valid `coral-agent.toml`.
- Confirm the server can see the agent in its registry.
- Create a minimal session only if the user wants a runtime smoke.
- If the smoke is run, close the session afterward.

## Boundaries

Do not assume:

- Cloud can host arbitrary developer-owned agents;
- one app-specific callback tool exists;
- one conductor backend exists;
- all agents should be copied into `~/.coral/agents`;
- a server source checkout exists under `~/.coral/coral-server`.

Use `coral-app-integration` for app/conductor/cloud boundaries and `coral-setup` for server configuration.
