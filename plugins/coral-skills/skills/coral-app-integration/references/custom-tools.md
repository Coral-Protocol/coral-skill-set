# Custom Tools

Custom tools are the agent-to-app callback surface. They are a Coral Server primitive, not a Cloud-only feature.

## Boundary

Use custom tools only when an agent needs an application capability:

- submit a final result or artifact;
- ask for user input or approval;
- query app-owned domain data;
- write deterministic app state;
- notify the app that a workflow step is complete.

Use Coral threads/messages/waits for agent-to-agent communication.

## Runtime Mechanics

Exact schema comes from `/api_v1.json`. Current mechanics:

1. The session request defines `agentGraphRequest.customTools`.
2. Each agent receives only tools listed in `customToolAccess`.
3. HTTP tools POST arguments to the configured app URL.
4. Coral includes session/agent context in path or headers according to the current server schema.
5. The app verifies Coral's signature before trusting the payload.

Verify header names, signature format, and path behavior against the running server or source before implementing an endpoint.

## Self-Hosted Versus Cloud

Self-hosted Coral Server calls the configured app endpoint directly.

Cloud may add API key auth, tenant scoping, hostname verification, Cloud proxying, Cloud-side signing, and namespace rewriting. Check current Cloud docs/source before assuming exact behavior.

## Naming

Name tools by app semantics, but keep general skills independent of exact names.

If a repo defines exact names, follow the repo. Otherwise describe the capability and let the app boundary define the name.
