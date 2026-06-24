# Coral Cloud Runtime Notes

This file captures Cloud-specific behavior that affects agents and app integrations. Verify against current Cloud docs/source when exact availability matters.

## Current Capability Boundary

Do not assume Coral Cloud can host arbitrary developer-owned agents. Current practical modes are:

- developer-owned agents connected to a developer-owned local/self-hosted Coral Server;
- marketplace or Cloud-supported agents running through Coral Cloud;
- self-hosted Coral Server using Cloud services such as the Coral LLM proxy.

Treat developer-owned agent hosting on Coral Cloud as a version-sensitive capability.

## API Keys

Cloud requests use Coral API keys as bearer credentials:

```http
Authorization: Bearer coral_...
```

Never commit API keys. Prefer environment variables or the user's secret manager.

## LLM Proxy

The Coral LLM proxy is Cloud-relevant even when agents are self-hosted.

- A Coral Cloud API key can add Coral Cloud-backed model providers to the server's proxy resolution path.
- Server `[llm-proxy]` providers can target OpenRouter or other provider-compatible endpoints.
- Agents receive proxy URLs through Coral-provided environment variables when their manifest declares LLM proxy needs.
- Use the proxy when Cloud billing/centralized model access is intended.
- Use direct provider keys only when the deployment intentionally bypasses Cloud proxy behavior.

## Cloud Sessions And Billing

Cloud may enforce budget settings, balance checks, tenant namespace rewriting, and Cloud-owned lifecycle hooks.

When a Cloud session fails before agents start, check auth, balance, budget settings, and agent availability before debugging custom tools or agent code.

## Cloud Custom Tools

Cloud custom tools follow the same conceptual pattern as self-hosted custom tools but add app registration and hostname verification.

Expect Cloud to:

- validate application hostnames;
- rewrite custom tool URLs through a Cloud proxy;
- append session and agent path parameters;
- forward Coral headers;
- sign payloads for the registered application secret.

Use Cloud custom tools for agent-to-app callbacks. Do not rely on user-specified session-end webhooks as the main app result path when Cloud owns lifecycle hooks.
