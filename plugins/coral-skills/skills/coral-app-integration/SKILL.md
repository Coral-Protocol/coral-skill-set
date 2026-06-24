---
name: coral-app-integration
description: Use when wiring Coral into an application, backend, conductor service, self-hosted deployment, Cloud-assisted flow, custom tools callback, session lifecycle manager, LLM proxy, API key, billing, or app-owned state boundary.
---

# Coral App Integration

Use this skill to identify integration boundaries. It should not prescribe product architecture.

## Load Only What Applies

Read only the reference that matches the user's question:

| Question | Read |
|---|---|
| Session ownership, app state, conductor process, self-hosting | `references/setup-patterns.md` |
| Agent-to-app callbacks or app tools | `references/custom-tools.md` |
| Cloud API key, LLM proxy, billing, marketplace/cloud runtime | `references/cloud-runtime.md` |

When exact request/response schemas matter, use `coral-runtime-reference` and the running server's `/api_v1.json`.

## Integration Boundaries

Keep these boundaries explicit:

- Coral owns ephemeral sessions, agent graph instantiation, thread/message coordination, MCP tools/resources, runtime agent secrets, and session state inspection.
- The app usually owns users, tenants, durable workflow state, schedules, billing relationship to its own users, artifacts, notifications, and product database records.
- Custom tools are the app callback surface for agent-to-app communication.
- Session webhooks are lifecycle notifications, not a substitute for application-specific result callbacks.
- A session-managing agent is valid, but it must be given explicit tools or APIs by the application; do not assume exact tool names or endpoints exist.

## Guardrails

Do not assume any of these unless the user's repo, config, or live docs define them:

- a particular named callback tool exists;
- a conductor server runs on a fixed port;
- Cloud can host arbitrary developer-owned agents;
- Coral should own durable product state;
- every multi-agent app needs the same topology.
