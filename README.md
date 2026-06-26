# Coral Skill Set

A plugin marketplace for the [Coral Protocol](https://github.com/Coral-Protocol) skill in Claude Code and Codex.

The `coral-skills` skill is a lightweight routing guide. It gives users one invocation point, then routes agents to the minimal internal reference for Coral Server setup, runtime schema lookup, Coralizer behavior, Cloud/custom-tool wiring, session control, or topology vocabulary.

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

Confirm installation:

```bash
codex plugin list --marketplace coral-skill-set
```

## Skill

| Invocation | Description |
|------------|-------------|
| `/coral-skills` in Claude Code, `$coral-skills` in Codex | Route any Coral Protocol request to the minimal setup, runtime-reference, agent-discovery, app-integration, session-control, or topology guidance |

## Getting Started

1. Invoke `/coral-skills` in Claude Code or `$coral-skills` in Codex for Coral Server, Coral Cloud, Coralizer, custom tools, app integration, session control, or topology questions.
2. The skill routes to one or two internal references and avoids loading unrelated Coral guidance.
3. When exact API calls matter, the skill points the agent to the current `BASE_URL/api_v1.json` or the most relevant source fallback.

For Cloud Console exports or marketplace agents, the skill routes agents to the Cloud runtime and custom-tool callback checklists without copying the full Cloud API schema into the skillset.

## Prerequisites

- Claude Code or Codex.
- Node.js/npm for `npx coralos-dev@latest` and Coralizer workflows.
- Optional agent CLIs only when installing matching example templates.

## License

MIT
