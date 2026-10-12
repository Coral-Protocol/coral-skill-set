# Security

Auth keys, request signing, and agent secrets in Coral Server 1.5.0.

Source: https://docs.coralos.ai/configuration/security

This page explains how authentication and request signing work in Coral Server, and how agent secrets are handled at runtime.

# Authentication keys (server API)

- Source of truth: `AuthConfig.kt`
- Configuration source: `config.toml` (via Hoplite in `ConfigModule.kt`)

Application REST APIs accept server auth keys as bearer tokens. Console also uses a session cookie; WebSocket routes have their own token/cookie connection forms. A server auth key grants access across namespaces, so enforce end-user authorization in your application.

```toml
# config.toml (excerpt)
[auth]
# A list of accepted bearer tokens for server APIs
keys = ["dev-token-123", "another-token"]
```

Use one of these tokens in the `Authorization: Bearer ...` header when calling APIs such as `/api/v1/local/session` or `/api/v1/registry`.

> **Warning:**
>
> Keep tokens secret. Do not commit them to source control.

# Request signing for webhooks and custom tools

- Source of truth: `NetworkConfig.kt` (`webhookSecret`, `customToolSecret`), `LocalSessionManager.handleSessionClose`, `GraphAgentToolTransport.Http`, and `HttpSignatureUtils.kt`

Coral signs JSON payloads for server‑initiated webhooks (e.g., `sessionEnd`) and for HTTP‑based custom tool requests. Verify signatures on your server to prevent spoofing.

```toml
# config.toml (excerpt)
[network]
# Used to sign webhook payloads (e.g., sessionEnd)
webhookSecret = "CHANGE-ME-32-CHARS"

# Used to sign custom tool callouts to your HTTP endpoints
customToolSecret = "CHANGE-ME-ANOTHER-SECRET"
```

Verification pattern (default header and algorithm):

```text
X-Coral-Signature: lowercase_hex(HMAC-SHA256(secret, rawBodyBytes))
```

Use `webhookSecret` for session-end reports and `customToolSecret` for custom tool calls. Signatures cover only the body, not path parameters or identity headers; correlate callbacks through application-owned job state. The default signature header is `X-Coral-Signature`. For HTTP custom tools, you may override the header name via the transport’s `signatureHeader` option; otherwise the default is used.

> **Tip:**
>
> See the examples in [Integrating with your app](../guides/integrating-with-your-app.md#custom-tools). Always verify request signatures in production.

# SessionAgentSecret (agent → server)

- Source of truth: `SessionAgent.kt` and `LocalSessionManager.issueAgentSecret`

For each agent instance in a session, Coral issues a unique `SessionAgentSecret`. This secret authenticates the agent when connecting to the MCP server (Streamable HTTP or legacy SSE).

Properties:

- Random per agent instance
- Only valid for the lifetime of the session
- Revoked automatically when the session ends

Best practices for agent authors:

- Read `CORAL_AGENT_SECRET` from the environment provided by the orchestrator
- Use the supplied MCP URL; use the secret as a bearer token only for agent RPC endpoints
- Do not log or transmit the secret elsewhere

Related env vars (set by the orchestrator):

| Variable | Purpose |
| :-- | :-- |
| `CORAL_CONNECTION_URL` | MCP transport URL to connect to |
| `CORAL_AGENT_ID` | Unique name of this agent instance in the session |
| `CORAL_AGENT_SECRET` | Secret used to authenticate to Coral’s MCP endpoints |
| `CORAL_SESSION_ID` | Session identifier |
| `CORAL_API_URL` | Coral Server REST API base URL |

# CORS and CSRF considerations

The server’s CORS policy is controlled by `NetworkConfig.allowAnyHost` (default: `false`).

```toml
[network]
allowAnyHost = false # set true only for local development
```

Set `allowAnyHost = false` in production and explicitly configure your reverse proxy/frontend to call Coral from trusted origins.

# Checklist

- [ ] Use strong random `auth.keys`, rotate regularly
- [ ] Set `webhookSecret` and `customToolSecret` to strong values
- [ ] Verify webhook signatures in your app
- [ ] Never log `CORAL_AGENT_SECRET`
- [ ] Keep `allowAnyHost = false` in production

The [runnable application example](../guides/integrating-with-your-app.md#complete-application-example) verifies the raw-body signature and rejects tampered payloads.
