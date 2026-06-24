# Coral Skill Set

A [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces) for [Coral Protocol](https://github.com/Coral-Protocol) - setup, runtime wiring, application integration, and multi-agent coordination guidance for Coral.

These skills are intended to be generalized wiring references, not an alternate opinionated app framework. When Coral Server, Coral Cloud, or Coralizer already expose runtime specifications, the skills point agents toward those sources instead of re-encoding the full API surface.

## Install

```
/plugin marketplace add Coral-Protocol/coral-skill-set
```

```
/plugin install coral-skills@coral-skill-set
```

```
/reload-plugins
```

## Skills

| Skill | Description |
|-------|-------------|
| `/coral-setup` | Start, inspect, and configure Coral Server from current runtime/docs |
| `/coral-built-in-agent-setup` | Install built-in agents (Claude Code, Hermes, Puppet) |
| `/coralize-your-agent` | Connect your own agent project to Coral (Mastra supported, more coming) |
| `/coral-agent-swarm` | Drive Coral sessions through the HTTP/Puppet API |
| `/coral-app-integration` | Choose app/server/cloud integration patterns and callback boundaries |
| `/coral-coordination-topologies` | Map common multi-agent communication topologies onto Coral primitives |
| `/coral-encyclopedia` (Preview) | Coral Protocol concept router and reference index |

## Quick Start

1. Run `/coral-setup` to start a current Coral Server and open the live docs at `http://localhost:5555/ui/docs`.
2. Run `/coral-built-in-agent-setup` or `/coralize-your-agent` to make agents discoverable by the server.
3. Use `/coral-app-integration` when wiring Coral into an application backend, Cloud-assisted flow, or self-hosted deployment.
4. Use `/coral-coordination-topologies` when deciding how agents should communicate inside a session.
5. Use `/coral-agent-swarm` when you want to drive a concrete session through the API.

## Prerequisites

- [Claude Code](https://code.claude.com/docs/en/overview) CLI
- Optional: [Hermes](https://hermes-agent.nousresearch.com/docs/getting-started/installation) CLI (for Hermes agent)
- Node.js/npm for `npx coralos-dev@latest` workflows

## License

MIT
