# Custom Tools

Custom tools are a Coral Server runtime primitive. They are not specific to marketplace agents and not specific to Coral Cloud.

## When To Use

Use custom tools when an agent needs to cross the application boundary:

- submit a final result or artifact;
- ask for user input or approval;
- query app-owned domain data;
- write deterministic app state;
- notify the app that a workflow step is complete.

Do not use custom tools for ordinary agent-to-agent discussion inside Coral. Use threads, messages, mentions, and waits for that.

## Runtime Mechanics

At session creation, the app defines `agentGraphRequest.customTools`. Each agent receives only the tools named in its `customToolAccess`.

For HTTP custom tools, Coral Server:

1. registers the tool on the target agent's MCP server;
2. lets the agent call the tool like any other MCP tool;
3. POSTs the tool arguments to the configured URL;
4. appends `/{sessionId}/{agentName}` to the URL path;
5. signs the raw JSON payload with `network.customToolSecret`;
6. sends Coral context headers such as namespace, session id, and agent name.

The app endpoint should verify the HMAC signature over the raw request body before trusting the payload.

## Self-Hosted Versus Cloud

Self-hosted Coral Server posts directly to the configured URL.

Coral Cloud adds:

- API key auth and tenant scoping;
- hostname/application verification;
- Cloud proxying of custom tool requests;
- Cloud-side signing to the registered application secret;
- Cloud namespace rewriting.

The high-level pattern is the same: custom tools are the callback surface from agents to the app.

## Design Boundary

Name tools by app semantics, but do not make a general skill depend on those names.

Good general guidance:

- "Define a custom tool for final report submission."
- "Grant only the writer agent access to that tool."
- "Verify `X-Coral-Signature` before processing."

Bad general guidance:

- "Call this exact app-specific callback tool."
- "Assume this exact app-specific callback endpoint exists."
- "Assume a conductor exposes a fixed session creation tool."

If a repo already defines exact tool names, follow that repo. Otherwise ask or infer from the app's requirements.
