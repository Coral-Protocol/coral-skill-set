<div align="center">
  <img src="assets/coral-skills-banner-logo-variant.png" alt="Coral Agent Skills banner" width="100%" />

  <h1>Coral Agent Skills</h1>

  <p>
    One installable Coral Protocol routing skill for wiring coding agents into Coral Server,
    Coral Cloud, sessions, custom tools, and multi-agent coordination patterns.
  </p>

  <p>
    <a href="https://github.com/Coral-Protocol/coral-server">Coral Server</a>
    ·
    <a href="https://docs.coralos.ai">Docs</a>
    ·
    <a href="https://youtu.be/_nqTKUwlkio?si=dInXXDaui_-rD1yv">Demo Video</a>
  </p>

  <p>
    <strong><a href="https://coralcloud.ai">Sign up for Coral Cloud</a></strong>
    and receive $30 in LLM proxy credits.
  </p>

  <a href="https://youtu.be/_nqTKUwlkio?si=dInXXDaui_-rD1yv">
    <img src="assets/coral-skills-demo-video-thumbnail.png" alt="Watch the Coral Agent Skills demo video" width="720" />
  </a>
</div>

`coral-skills` gives coding agents a single entrypoint for Coral work, then routes
them to the smallest relevant internal reference. The skill is intentionally a
wiring guide, not an application-design manifesto: it points agents toward the
current Coral runtime schema, server mechanics, Cloud/custom-tool boundaries,
agent discovery paths, session-control APIs, and coordination-topology vocabulary.

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
|---|---|
| `/coral-skills` in Claude Code, `$coral-skills` in Codex | Route any Coral Protocol request to the minimal setup, runtime-reference, agent-discovery, app-integration, session-control, Cloud/custom-tool, or topology guidance. |

## Reference Routing

The public skill is a strict router. It loads one primary reference by default
and adds a second only when the request crosses boundaries, such as Cloud plus
custom tools or app integration plus session control.

| Reference | Used for |
|---|---|
| [`coral-setup.md`](plugins/coral-skills/skills/coral-skills/references/coral-setup.md) | Installing, starting, stopping, inspecting, configuring, or troubleshooting Coral Server. |
| [`coral-runtime-reference.md`](plugins/coral-skills/skills/coral-skills/references/coral-runtime-reference.md) | Finding the current machine-readable Coral API, OpenAPI schema, endpoint shapes, manifests, and source fallback. |
| [`coralize-your-agent.md`](plugins/coral-skills/skills/coral-skills/references/coralize-your-agent.md) | Connecting developer-owned agents through Coralizer, `.coral`, `~/.coral`, `coral-agent.toml`, or config-file registry discovery. |
| [`coral-built-in-agent-setup.md`](plugins/coral-skills/skills/coral-skills/references/coral-built-in-agent-setup.md) | Installing and verifying the packaged example agent templates. |
| [`coral-session-control.md`](plugins/coral-skills/skills/coral-skills/references/coral-session-control.md) | Creating, polling, messaging, watching, inspecting, and closing concrete Coral sessions. |
| [`coral-app-integration.md`](plugins/coral-skills/skills/coral-skills/references/coral-app-integration.md) | Wiring Coral into an application while keeping runtime/session coordination separate from durable app state. |
| [`cloud-runtime.md`](plugins/coral-skills/skills/coral-skills/references/cloud-runtime.md) | Coral Cloud API keys, marketplace agents, Cloud Console payloads, LLM proxy, billing, and hosted-runtime boundaries. |
| [`custom-tools.md`](plugins/coral-skills/skills/coral-skills/references/custom-tools.md) | App callbacks, `customTools`, `customToolAccess`, `APP_BASE_URL`, application IDs, secrets, and signature verification. |
| [`setup-patterns.md`](plugins/coral-skills/skills/coral-skills/references/setup-patterns.md) | Session ownership, conductor services, self-hosted deployments, and orchestration patterns. |
| [`coral-coordination-topologies.md`](plugins/coral-skills/skills/coral-skills/references/coral-coordination-topologies.md) | Choosing or reviewing multi-agent communication structures in Coral terms. |
| [`topologies.md`](plugins/coral-skills/skills/coral-skills/references/topologies.md) | Supporting vocabulary for common and niche multi-agent coordination topologies. |

## Getting Started

1. Install the plugin for Claude Code or Codex.
2. Invoke `/coral-skills` in Claude Code or `$coral-skills` in Codex.
3. Ask for the Coral task directly: start a server, inspect a schema, coralize
   an agent, wire a Cloud custom-tool callback, operate a session, or reason
   about a coordination topology.
4. When exact API calls matter, the skill should fetch the current
   `BASE_URL/api_v1.json` or use the most relevant source fallback.

For Cloud Console exports or marketplace agents, the skill routes agents to the
Cloud runtime and custom-tool callback checklists without copying the full Cloud
API schema into the skillset.

## Prerequisites

- Claude Code or Codex.
- Node.js/npm for `npx coralos-dev@latest` and Coralizer workflows.
- Optional agent CLIs only when installing matching example templates.
- Coral Cloud credentials only when the user is working with Cloud-specific
  sessions, marketplace agents, billing, LLM proxy, or custom-tool callbacks.

## License

MIT
