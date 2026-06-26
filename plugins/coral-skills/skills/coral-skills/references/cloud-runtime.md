# Coral Cloud Runtime Boundary

Use this reference for Coral Cloud wiring. Keep exact API shapes grounded in `references/coral-runtime-reference.md`; keep Cloud-specific behavior here.

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

Default Cloud API base URL to `https://api.coralcloud.ai` only when the app or user has not provided `CORAL_CLOUD_API_URL`.

Do not use the custom-tool secret as API auth. `CORAL_CUSTOM_TOOL_SECRET` is for app callback verification.

## Cloud Invocation Signals

Treat a session request as Cloud-oriented when any of these are present:

- `registrySourceId.type: "marketplace"` on an agent id;
- a Cloud Console exported `SessionRequest` or `agentGraphRequest`;
- `CORAL_CLOUD_API_URL`, `CORAL_API_KEY`, or Cloud account/billing language;
- custom-tool env vars: `APP_BASE_URL`, `CORAL_APPLICATION_ID`, `CORAL_CUSTOM_TOOL_SECRET`.

For marketplace agents, verify availability before creating a session:

```bash
curl -fsS -H "Authorization: Bearer $CORAL_API_KEY" \
  "$CORAL_CLOUD_API_URL/api/v1/registry"
```

Inspect specific agents with the registry source and exact name/version from the request. Preserve the user's exported agent names, options, groups, and runtime settings unless current schema or live validation rejects them.

## LLM Proxy

The Coral LLM proxy can matter even when agents are self-hosted.

- A Coral Cloud API key can add Coral Cloud-backed model providers to the server's proxy resolution path.
- Server `[llm-proxy]` providers can target OpenRouter or other provider-compatible endpoints.
- Agents receive proxy URLs through Coral-provided runtime environment when their manifest declares proxy needs.

## Cloud Sessions And Billing

Cloud may enforce budget settings, balance checks, tenant namespace rewriting, and Cloud-owned lifecycle hooks. Treat these as runtime constraints, not app architecture guidance.

Budget settings are not Cloud-only. Recent Coral Server versions also expose session and per-agent budget settings, running budgets, and claim receipts in local runtime state. Use `references/coral-runtime-reference.md` and the live schema before deciding whether a budget field is Cloud-specific or server-native.

When a Cloud session fails before agents start, check auth, balance, budget settings, and agent availability before debugging custom tools or agent code.

For Cloud Console payloads, preserve Cloud-specific and version-sensitive fields even when the public OpenAPI snapshot does not include them yet. Common examples include top-level and per-agent `budgetSettings`, `x402Budgets`, `proxies`, `plugins`, `annotations`, and execution runtime settings.

For immediate Cloud execution, expect Cloud to require a positive total budget and a session exhaustion behavior that can stop the session. If session creation returns a balance or budget error, treat it as an operational blocker, not evidence that agents or custom tools are broken.

## Cloud Custom Tools

Cloud custom tools follow the same conceptual pattern as self-hosted custom tools but may add app registration, hostname verification, proxying, and Cloud-side signing.

Use `references/custom-tools.md` when the user mentions `APP_BASE_URL`, `CORAL_APPLICATION_ID`, `CORAL_CUSTOM_TOOL_SECRET`, callback endpoints, or `customTools`.
