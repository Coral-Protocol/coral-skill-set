# Coral Skill Set

A [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces) for [Coral Protocol](https://github.com/Coral-Protocol) — set up a Coral server, install agents, and orchestrate multi-agent swarms from inside Claude Code.

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
| `/coral-setup` | Install and configure the Coral server (`~/.coral/coral-server`) |
| `/coral-built-in-agent-setup` | Install built-in agents (Claude Code, Hermes, Puppet) |
| `/coralize-your-agent` | Connect your own agent project to Coral (Mastra supported, more coming) |
| `/coral-agent-swarm` | Orchestrate multi-agent sessions — spawn agents, send tasks, collect results |
| `/coral-encyclopedia` (Preview) | Coral Protocol knowledge hub — concepts, API reference, agent development patterns |

## Quick Start

1. Run `/coral-setup` to install the Coral server
2. Run `/coral-built-in-agent-setup` to add agents
3. Run `/coral-agent-swarm` and give it a task — it will spawn and coordinate agents for you

Ask Claude anything about Coral Protocol (e.g. "what is a coral session?", "how do I write a coral agent?") and the `coral-encyclopedia` skill will automatically provide answers from bundled documentation.

## Prerequisites

- [Claude Code](https://code.claude.com/docs/en/overview) CLI
- Optional: [Hermes](https://hermes-agent.nousresearch.com/docs/getting-started/installation) CLI (for Hermes agent)

## License

MIT
