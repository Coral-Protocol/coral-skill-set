# Coral App Ownership Patterns

These are ownership shapes to recognize in a repo. They are not recommendations by themselves.

## Local Sandbox

- Coral Server runs locally, usually through `npx coralos-dev@latest server start`.
- Agents run as local executables, Docker agents, prototype agents, or Coralized wrappers.
- The machine-readable schema is local `/api_v1.json`.

## App-Owned Conductor

- Backend creates sessions through the REST API.
- Backend stores durable user/workflow/artifact state.
- Backend reads extended state/events for runtime status.
- Custom tools carry app-specific callbacks.
- Backend closes sessions.

## Self-Hosted Coral Service

- Coral Server is deployed as a service.
- App talks to Coral over HTTP/WebSocket.
- Agent discovery is explicit through config, mounted paths, Coralizer links, or registry settings.
- Custom tools are still local/self-hosted server primitives.

## Agent-Owned Session Manager

- The managing agent receives explicit tools/API credentials from the application.
- It may create sessions, inspect state, send Puppet/API messages, and close sessions.
- The app still defines permissions and durable state boundaries.
- Do not assume fixed custom tool names, fixed endpoints, or universal conductor APIs.

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
