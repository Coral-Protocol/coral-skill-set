# Coral Setup And App Integration Patterns

These are reusable setup families. They describe ownership boundaries, not mandatory architecture.

## Local Sandbox

Use for development, debugging, demos, and learning.

- Coral Server runs locally, usually through `npx coralos-dev@latest server start`.
- Agents run as local executables, Docker agents, prototype agents, or Coralized wrappers.
- Console and `/ui/docs` are useful inspection surfaces.
- Avoid committing local absolute paths unless the repo intentionally owns a local-only config.

## App-Owned Conductor

Use when a product backend owns session lifecycle.

- Backend creates sessions through the REST API.
- Backend stores user/work item/session mappings in its own database.
- Backend polls extended state or subscribes to events when needed.
- Custom tools carry agent outputs and app-specific requests back into the app.
- Backend closes sessions and records artifacts/results in app-owned storage.

This is a common production pattern because it keeps durable product state outside Coral.

## Self-Hosted Coral Service

Use when the app or team owns a Coral Server on a VM, container host, or cluster.

- Coral Server is deployed as a service.
- App talks to Coral over HTTP/WebSocket.
- Agent discovery is controlled through config, mounted paths, Coralizer links, or registry settings.
- Custom tools still work; they are a Coral Server primitive, not a Cloud-only feature.
- Production configs should use secure auth keys and controlled network exposure.

## Agent-Owned Session Manager

Use when an agent or agent process creates and manages Coral sessions.

- The managing agent receives explicit tools/API credentials from the application.
- It can create sessions, inspect state, send Puppet/API messages, and close sessions.
- The app should still own durable state and permission boundaries.
- This pattern is useful for recursive delegation or "agent spins up a team" workflows.

Do not assume fixed custom tool names, fixed endpoints, or universal conductor APIs. The app must define the interface.

## Cloud-Assisted Self-Hosted

Use when agents run on your own Coral Server but Cloud services are useful.

- A Coral Cloud API key can enable Cloud-backed LLM proxy behavior in server config.
- `[llm-proxy]` providers can also target OpenRouter or other provider-compatible endpoints.
- Agent hosting remains local/self-hosted unless Cloud explicitly supports the selected agent source/runtime.

## Cloud / Marketplace Runtime

Use when the session uses agents already available through Cloud/marketplace surfaces.

- Use Cloud API keys.
- Expect tenant isolation, Cloud billing controls, Cloud custom-tool verification, and Cloud-owned session end hooks.
- Do not describe this as arbitrary developer-owned agent hosting unless current Cloud docs/source confirm it.

## Workflow-Orchestrated Sessions

Use when deterministic stages matter more than one open-ended long session.

- App creates one short session per stage.
- App stores stage outputs as durable artifacts.
- Later sessions receive relevant artifacts through options, resources, or custom tools.
- Good for auditability, retry, and bounded cost.
