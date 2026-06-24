# Coral Cloud Runtime Boundary

Verify Cloud behavior against current Cloud docs/source before making exact availability claims.

## Current Boundary

Do not assume Coral Cloud can host arbitrary developer-owned agents. Current practical modes are:

- developer-owned agents connected to a developer-owned local/self-hosted Coral Server;
- marketplace or Cloud-supported agents running through Coral Cloud;
- self-hosted Coral Server using Cloud services such as the Coral LLM proxy.

Treat developer-owned agent hosting on Coral Cloud as a version-sensitive capability.

## API Keys

Cloud requests use Coral API keys as bearer credentials where Cloud APIs are involved:

```http
Authorization: Bearer coral_...
```

Never commit API keys. Prefer environment variables or the user's secret manager.

## LLM Proxy

The Coral LLM proxy can matter even when agents are self-hosted.

- A Coral Cloud API key can add Coral Cloud-backed model providers to the server's proxy resolution path.
- Server `[llm-proxy]` providers can target OpenRouter or other provider-compatible endpoints.
- Agents receive proxy URLs through Coral-provided runtime environment when their manifest declares proxy needs.

## Cloud Sessions And Billing

Cloud may enforce budget settings, balance checks, tenant namespace rewriting, and Cloud-owned lifecycle hooks. Treat these as runtime constraints, not app architecture guidance.

When a Cloud session fails before agents start, check auth, balance, budget settings, and agent availability before debugging custom tools or agent code.

## Cloud Custom Tools

Cloud custom tools follow the same conceptual pattern as self-hosted custom tools but may add app registration, hostname verification, proxying, and Cloud-side signing.

Use the current Cloud API/schema/source for exact headers, URL rewriting, and signature rules.
