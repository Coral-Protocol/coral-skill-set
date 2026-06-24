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

## Session Request Wiring

Define tools once at `agentGraphRequest.customTools`, then grant them explicitly:

```json
{
  "agentGraphRequest": {
    "customTools": {
      "submit_result": {
        "transport": {
          "type": "http",
          "url": "https://app.example.com/api/coral/submit-result",
          "signatureHeader": "X-Coral-Signature"
        },
        "inputSchema": { "type": "object" },
        "outputSchema": { "type": "object" }
      }
    },
    "agents": [
      { "name": "worker", "customToolAccess": ["submit_result"] }
    ]
  }
}
```

Agents can only call custom tools listed in their own `customToolAccess`.

## Self-Hosted Versus Cloud

Self-hosted Coral Server calls the configured app endpoint directly.

Cloud may add API key auth, tenant scoping, hostname verification, Cloud proxying, Cloud-side signing, and namespace rewriting. Check current Cloud docs/source before assuming exact behavior.

For Cloud custom tools, treat these environment variables as separate concerns:

| Variable | Role |
|---|---|
| `CORAL_API_KEY` | Bearer auth for Cloud API/session calls |
| `APP_BASE_URL` | Public app origin reachable by Cloud; use a tunnel URL for local testing |
| `CORAL_APPLICATION_ID` | Plaintext value your app must serve at `GET /_coral/verification` |
| `CORAL_CUSTOM_TOOL_SECRET` | HMAC secret for verifying incoming callback payloads |
| `ALLOW_UNSIGNED_CORAL_CALLBACKS` | Local-only escape hatch; keep false for Cloud runs |

Before creating a Cloud session with custom tools:

```bash
curl -fsS "$APP_BASE_URL/_coral/verification"
```

The response must exactly equal `CORAL_APPLICATION_ID`, with no JSON wrapper.

For Cloud callbacks:

- use a URL under `APP_BASE_URL`, not `localhost`;
- expect Cloud to proxy the callback and append `/{sessionId}/{agentName}` to the configured path;
- also read `X-Coral-Namespace`, `X-Coral-SessionId`, and `X-Coral-AgentName` when present;
- verify `X-Coral-Signature` before trusting the payload;
- compute HMAC-SHA256 over the raw request body using `CORAL_CUSTOM_TOOL_SECRET`; Cloud application secrets are commonly provided as hex strings, so decode hex before using the key when appropriate.

## Naming

Name tools by app semantics, but keep general skills independent of exact names.

If a repo defines exact names, follow the repo. Otherwise describe the capability and let the app boundary define the name.
