---
name: coral-app-integration
description: Use when wiring Coral into an application, backend, conductor service, self-hosted deployment, Cloud-assisted flow, custom tools callback, session lifecycle manager, LLM proxy, API key, billing, or app-owned state boundary.
---

# Coral App Integration

Use this skill to choose integration mechanics, not to prescribe app design. Coral is the session/runtime coordination substrate; the application usually owns identity, durable state, schedules, artifacts, and user-facing workflow.

## Pick The Runtime Shape

Read only the reference that matches the user's question:

| Question | Read |
|---|---|
| "How should this app own sessions, state, callbacks, and agents?" | `references/setup-patterns.md` |
| "How do custom tools work across local, self-hosted, and Cloud?" | `references/custom-tools.md` |
| "What is Cloud-specific today?" | `references/cloud-runtime.md` |

When exact request/response schemas matter, use a running Coral Server's `/ui/docs` or `/api_v1.json`.

## Integration Boundaries

Keep these boundaries explicit:

- Coral owns ephemeral sessions, agent graph instantiation, thread/message coordination, MCP tools/resources, runtime agent secrets, and session state inspection.
- The app usually owns users, tenants, durable workflow state, schedules, billing relationship to its own users, artifacts, notifications, and product database records.
- Custom tools are the app callback surface for agent-to-app communication.
- Session webhooks are lifecycle notifications, not a substitute for application-specific result callbacks.
- A session-managing agent is valid, but it must be given explicit tools or APIs by the application; do not assume exact tool names or endpoints exist.

## Do Not Overfit

Avoid project-specific conventions unless the user's repo already defines them.

Do not assume:

- a particular named callback tool exists;
- a conductor server runs on a fixed port;
- Cloud can host arbitrary developer-owned agents;
- Coral should own durable product state;
- every multi-agent app needs the same topology.

Instead, identify the runtime shape, inspect current docs/config/source, and map the app's required boundaries onto Coral primitives.
