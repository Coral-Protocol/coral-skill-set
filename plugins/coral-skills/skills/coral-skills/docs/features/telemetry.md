# Telemetry

Observe public Coral Server sessions, logs, and LLM proxy usage.

Source: https://docs.coralos.ai/features/telemetry

Public Coral Server 1.5.0 exposes session state, logs, and session events. It does **not** expose the historical `POST /api/v1/telemetry/{sessionId}` or per-message telemetry GET endpoints. Those paths return 404. A Console screenshot or feature from another release does not establish an API contract for the server you are running.

## What is available

- `GET /api/v1/local/session/{namespace}/{sessionId}/extended` returns agent status, threads, messages, and agent budget state.
- The LLM proxy emits `llm_proxy_call` session events with the agent name, model, provider request name, HTTP status, and input/output token usage when the provider supplies it.
- Session events include runtime start/stop, thread messages, Docker container lifecycle, and budget claims.
- Agent stdout/stderr and server diagnostics are available through the logging system and Console. Configure retention and levels in [Logging](../reference/server/logging.md).

These interfaces observe requests that pass through Coral. Calls an agent makes directly to an external LLM provider are outside the Coral proxy's visibility.

## Application results and durable records

Use [custom tools](../guides/integrating-with-your-app.md#custom-tools) for application results. Configure an [end-report webhook](../concepts/sessions.md#webhooks) to export session state, and store records in your own application. Session retention and the log replay buffer are bounded; they are not durable telemetry storage.

Console capabilities depend on the Console release paired with your server. See [Console configuration](../reference/server/console.md) and [Debugging](../guides/debugging.md).
