# Coral App Ownership Patterns

These are ownership shapes to recognize in a repo. They are not recommendations by themselves.

## Local Sandbox

- Coral Server runs on the developer's machine, from source or the published Docker image, as in `docs/guides/quickstart.md`.
- The server finds agents through `registry.localAgents` or Coralizer links on that machine.
- The machine-readable schema is local `/api_v1.json`.

## Application Backend

- Backend creates sessions through the REST API.
- Backend stores durable user/workflow/artifact state.
- Backend reads extended state/events for runtime status.
- Custom tools carry app-specific callbacks.
- Backend closes sessions.

## Self-Hosted Coral Service

- Coral Server is deployed as a service.
- App talks to Coral over HTTP/WebSocket.
- Agents ship with the deployment: `registry.localAgents` in `config.toml` points at agent directories in the image or a mounted volume. Coralizer links are a developer-machine convenience, not a deployment mechanism.
- Custom tools are still local/self-hosted server primitives.

## Cloud-Assisted Self-Hosted

- Agents run on a local/self-hosted Coral Server.
- A Coral Cloud API key may enable Cloud-backed LLM proxy behavior in server config.
- `[llm-proxy]` providers can also target OpenRouter or other provider-compatible endpoints.

## Cloud / Marketplace Runtime

- Sessions use agents available through Cloud/marketplace surfaces.
- Expect Cloud API keys, tenant isolation, billing controls, and Cloud custom-tool verification.
- Do not describe this as arbitrary developer-owned agent hosting unless current Cloud docs/source confirm it.

## Workflow-Orchestrated Sessions

- An outside workflow creates one or more bounded sessions.
- Durable stage outputs live outside Coral.
- Later sessions receive artifacts through options, resources, or custom tools.
