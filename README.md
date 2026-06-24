# Coral Skill Set

A plugin marketplace for [Coral Protocol](https://github.com/Coral-Protocol) skills in Claude Code and Codex.

These skills are lightweight wiring guides. They point agents to the current Coral Server schema, Coralizer behavior, Cloud/runtime boundaries, and app integration seams instead of copying Coral's full API or prescribing product architecture.

## Install For Claude Code

```text
/plugin marketplace add Coral-Protocol/coral-skill-set
```

```text
/plugin install coral-skills@coral-skill-set
```

```text
/reload-plugins
```

## Install For Codex

From the Codex CLI:

```bash
codex plugin marketplace add Coral-Protocol/coral-skill-set
codex plugin add coral-skills@coral-skill-set
```

For branch testing:

```bash
codex plugin marketplace add Coral-Protocol/coral-skill-set --ref agentskills-v2
codex plugin add coral-skills@coral-skill-set
```

Confirm installation:

```bash
codex plugin list --marketplace coral-skill-set
```

## Skills

| Skill | Description |
|-------|-------------|
| `/coral-runtime-reference` | Locate the current machine-readable Coral API/schema/source of truth |
| `/coral-setup` | Start, stop, inspect, and configure Coral Server |
| `/coralize-your-agent` | Link or wrap a developer-owned agent for Coral discovery |
| `/coral-built-in-agent-setup` | Copy and verify packaged example agent templates |
| `/coral-session-control` | Operate Coral sessions through REST, Puppet, events, and extended state |
| `/coral-app-integration` | Identify app, conductor, Cloud Console, marketplace-agent, custom-tool, and durable-state boundaries |
| `/coral-coordination-topologies` | Map communication topology vocabulary onto Coral session primitives |

## Getting Started

1. Use `/coral-setup` to start or inspect Coral Server.
2. Use `/coral-runtime-reference` to fetch the current `BASE_URL/api_v1.json` before generating exact API calls.
3. Use `/coralize-your-agent` or `/coral-built-in-agent-setup` to make agents discoverable.
4. Use `/coral-app-integration` when the question crosses into app-owned state, callbacks, Cloud, or deployment.
5. Use `/coral-coordination-topologies` only when the communication structure itself is the question.
6. Use `/coral-session-control` when operating a concrete session through HTTP/Puppet APIs.

For Cloud Console exports or marketplace agents, `/coral-app-integration` routes agents to the Cloud runtime and custom-tool callback checklists without copying the full Cloud API schema into the skillset.

## Prerequisites

- Claude Code or Codex.
- Node.js/npm for `npx coralos-dev@latest` and Coralizer workflows.
- Optional agent CLIs only when installing matching example templates.

## License

MIT
