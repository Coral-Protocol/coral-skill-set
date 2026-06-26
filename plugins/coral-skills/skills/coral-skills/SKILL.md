---
name: coral-skills
description: >-
  Use for any Coral Protocol task: installing, starting, stopping, inspecting,
  or configuring Coral Server; locating OpenAPI/API/schema/source-of-truth docs;
  coralizing or linking agents; installing bundled agent templates; wiring apps,
  Cloud, marketplace agents, custom tools, callbacks, Fly/deployment, API keys,
  LLM proxy, billing, or app-owned state; operating concrete sessions through
  REST, Puppet, events, or extended state; and designing Coral
  coordination/topology. Routes strictly to the minimal internal reference files
  needed for the request.
---

# Coral Skills

Use this as the single entry point for Coral Protocol work. This skill is a router. It should load only the reference file or files needed for the request, then act from those instructions and the live Coral runtime schema.

## Strict Routing

Choose the smallest applicable set:

| User intent | Read |
|---|---|
| Install, start, stop, inspect, configure, or troubleshoot Coral Server | `references/coral-setup.md` |
| API, OpenAPI, schema, endpoint, payload, namespace, MCP tool/resource, runtime state, agent manifest source of truth | `references/coral-runtime-reference.md` |
| Connect a developer-owned agent, Coralizer, `.coral`, `~/.coral`, `coral-agent.toml`, config-file agent discovery | `references/coralize-your-agent.md` |
| Install, refresh, or verify packaged example agent templates | `references/coral-built-in-agent-setup.md` |
| Create, poll, message, inspect, watch, or close a concrete Coral session | `references/coral-session-control.md` |
| App integration, conductor services, durable app state, self-hosting, deployment, Cloud Console payloads, marketplace agents, API keys, billing, LLM proxy | `references/coral-app-integration.md` |
| Custom tools, app callbacks, `APP_BASE_URL`, `CORAL_APPLICATION_ID`, `CORAL_CUSTOM_TOOL_SECRET`, signatures | `references/custom-tools.md` |
| Cloud runtime, marketplace agents, Cloud API key, Cloud billing, Cloud Console payloads | `references/cloud-runtime.md` |
| Session ownership, conductor process, self-hosted deployment, workflow orchestration | `references/setup-patterns.md` |
| Communication topology or multi-agent architecture vocabulary | `references/coral-coordination-topologies.md` |

## Loading Rules

- Read one primary reference by default.
- Read a second reference only when the user request crosses boundaries. Examples:
  - Cloud custom tools: `references/cloud-runtime.md` plus `references/custom-tools.md`.
  - App-owned session lifecycle: `references/coral-app-integration.md` plus `references/coral-session-control.md`.
  - Exact Cloud/session payloads: `references/cloud-runtime.md` plus `references/coral-runtime-reference.md`.
  - Topology that must be implemented through sessions: `references/coral-coordination-topologies.md` plus `references/coral-session-control.md`.
- Do not load every Coral reference to "be safe".
- Prefer live machine-readable sources over prose. When exact API shapes matter, use `references/coral-runtime-reference.md` and the target server's `/api_v1.json`.
- Preserve user-provided session payload fields unless the live schema or runtime rejects them.
- Keep app architecture boundaries explicit: Coral owns runtime/session coordination; applications own durable product state and artifacts unless the app says otherwise.

## Reference Inventory

- `references/coral-setup.md`
- `references/coral-runtime-reference.md`
- `references/coralize-your-agent.md`
- `references/coral-built-in-agent-setup.md`
- `references/coral-session-control.md`
- `references/coral-app-integration.md`
- `references/cloud-runtime.md`
- `references/custom-tools.md`
- `references/setup-patterns.md`
- `references/coral-coordination-topologies.md`
- `references/topologies.md`

Resources:

- `scripts/watch_coral.sh`
- `assets/agents/`
