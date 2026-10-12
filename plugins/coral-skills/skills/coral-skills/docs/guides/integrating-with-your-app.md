# Integrating with your application

Using Coral Server from, and integrating it with your application

Source: https://docs.coralos.ai/guides/integrating-with-your-app

> **Note:**
>
> See also [this guide](../guides/production/running-in-production.md) on deploying Coral Server in production

Use the [HTTP API](../api-reference/endpoints.md#create-session) from your application to create sessions and handle results. Coral Console supports development and debugging. The public server also exposes Kotlin APIs for embedding; the HTTP integration described here works independently of your application's language.

> **Tip:**
>
> Coral Server also serves a dedicated API reference at `/ui/docs`. The OpenAPI schema is also available at `/api_v1.json`.

## Creating Sessions

The create session endpoint is one of the most important endpoints - it's how you define and instantiate graphs of agents.

While [Coral Console](../concepts/coral-console.md) has a ready-made interface over this endpoint, when integrating Coral with your application - you'll want to use this API directly.

> **Tip:**
>
> You can use the JSON available in [Coral Console's](../concepts/coral-console.md) editor pane when editing a session template - to quickly get a usable request body for your own POST to [`/api/v1/local/session`](../api-reference/endpoints.md#create-session).

Every application API call needs one of the server's [auth keys](../reference/server/auth.md) in an `Authorization: Bearer` header. Agent secrets do not authenticate these endpoints.

### Minimal request body

The body is a [`SessionRequest`](../api-reference/schemas.md#sessionrequest). It needs an `agentGraphRequest` with at least one agent, and a `namespaceProvider`.

```json
{
  "agentGraphRequest": {
    "agents": [
      {
        "id": {
          "name": "example-agent",
          "version": "0.1.0",
          "registrySourceId": { "type": "local" }
        },
        "name": "example",
        "provider": {
          "type": "local",
          "runtime": "docker"
        },
        "systemPrompt": "You are a helpful agent."
      }
    ]
  },
  "namespaceProvider": {
    "type": "create_if_not_exists",
    "namespaceRequest": {
      "name": "demo",
      "deleteOnLastSessionExit": true
    }
  },
  "execution": {
    "mode": "immediate",
    "runtimeSettings": { "ttl": 300000 }
  }
}
```

```bash
curl -X POST http://localhost:5555/api/v1/local/session \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $CORAL_TOKEN" \
  -d @session.json
```

The response contains the session's `namespace` and `sessionId`. [Sessions](../concepts/sessions.md#session-lifecycle) describes what happens from creation to termination.

## Custom Tools

There are a lot of scenarios where agents need to be given capabilities that are tightly integrated with your application. While you can hard code these kinds of tools in agents you write yourself, when using agents from other developers - this doesn't work.

For this reason, Coral Server supports passing custom MCP tools to agents at runtime.

When an agent calls one of these custom tools, Coral Server sends a request to an endpoint you provide, to know how to respond.

### Example - User Input

A common use case in applications is exposing some kind of "chat"-style agent to your end users. This can be implemented using custom tools.

One tool can request user input: Coral calls your application endpoint, and the endpoint's response supplies the user's answer to the waiting agent. A separate output tool can submit results or display progress. Long-lived user interactions need application storage and timeout handling.

As an example, the flow for a user‑input custom tool looks (roughly) like:

```mermaid
sequenceDiagram
    participant App as Application

    App-->>Coral: Create session
    create participant Agent
    Coral-->>Agent: Instantiate
    Agent->>+Coral: Call to custom user‑input tool<br>(via MCP)
    Coral->>+App: POST to associated endpoint<br>(defined by app)

    Note over App: Present the request in<br>your application's frontend
    App->>-Coral: User response from frontend

    Coral->>-Agent: Response from app endpoint<br>(the user response)
```

### Callback contract

For an HTTP custom tool, Coral POSTs the tool argument object to your configured URL with `/{sessionId}/{agentName}` appended. It supplies `X-Coral-Namespace`, `X-Coral-SessionId`, and `X-Coral-AgentName` headers. Verify the `X-Coral-Signature` header against a lowercase hexadecimal HMAC-SHA256 over the exact request body bytes, using `network.customToolSecret`. The transport can override the signature header name.

Return **HTTP 200** with the tool result. The public server wraps the response body in MCP text content. Other HTTP statuses become tool errors. Custom tool callbacks and end-report webhooks are separate contracts: end reports use `network.webhookSecret` and the exact configured URL.

Signatures cover the body, not the URL or identity headers. Use a job-specific callback URL, check the expected session and agent against application-owned state, and make result handling idempotent. Store results before returning success. The public server does not provide a durable callback queue or a delivery guarantee.

### Complete application example

The docs repository contains a runnable Node.js integration in [examples/application.mjs](https://github.com/Coral-Protocol/Docs/blob/Coral-Documentation/examples/application.mjs). It starts a callback server, verifies signatures before parsing JSON, creates a deferred session, saves the session-to-user mapping, and then starts execution. A distinct callback URL identifies each job. The example uses an in-memory map; replace it with shared durable storage for a deployed application.

After copying that file, use it from your application's trusted backend:

```javascript
import { createReportApplication } from './application.mjs';

const app = await createReportApplication({
  coralUrl: process.env.CORAL_SERVER_URL,
  token: process.env.CORAL_AUTH_TOKEN,
  callbackSecret: process.env.CORAL_CUSTOM_TOOL_SECRET,
  // For a remote server, use an HTTPS URL that forwards to this example's local listener.
  callbackBaseUrl: process.env.CALLBACK_BASE_URL,
  port: 8080
});

const job = await app.startReport('authenticated-user-id', {
  id: { name: 'report-writer', version: '1.0.0', registrySourceId: { type: 'local' } },
  name: 'writer',
  provider: { type: 'local', runtime: 'prototype' },
  options: { TASK: { type: 'string', value: 'Write a short report and call submit_report.' } }
});

let timer;
try {
  const timeout = new Promise((_, reject) => {
    timer = setTimeout(() => reject(new Error('Report timed out')), 300000);
  });
  const report = await Promise.race([job.result, timeout]);
  console.log(report);
} finally {
  clearTimeout(timer);
  await job.close();
  await app.close();
}
```

The sample uses a simple prototype to make the callback flow easy to reproduce. For production agents with custom context management or control flow, the [Koog template](../guides/quickstart.md#koog-template) is the main authoring path; the application API and callback contract stay the same.

This example uses the complete [prototype agent definition](../reference/agent/tables/runtimes/prototype.md#complete-agent-definition). For Coral Cloud, discover an available agent and use the callback verification credentials supported by that deployment; do not assume your Cloud API key is a webhook signing secret.
