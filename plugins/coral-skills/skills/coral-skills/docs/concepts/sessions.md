# Sessions

In CoralOS, a session represents a single, self-contained context for a multi-agent interaction.

Source: https://docs.coralos.ai/concepts/sessions

Sessions represent a single, self-contained context for a multi-agent interaction. You can think of a session as a **workspace** or **conversation instance** dedicated to a particular task or user request. It encompasses the agents involved, the messages they exchange, and any temporary state or budget allocated for each agent in that session.

## Namespaces

Sessions are organized into **Namespaces**. A namespace is a container for sessions, often used to separate data between different users, applications, or environments.

- **Organisation:** Agent communication is scoped to a session. Namespaces organise sessions; they are not per-tenant API credentials. A server `auth.keys` token can access all namespaces, so your application must enforce user and tenant access.
- **Persistence:** Namespaces can be configured to persist even after all sessions within them have ended, or to be deleted automatically on the last session exit.

## Session Lifecycle

1.  **Creation:** Create a session via `POST /api/v1/local/session` with a `SessionRequest` body. Namespaces are handled by `namespaceProvider` in the request (e.g., `CreateIfNotExists` or `UseExisting`). The response contains a `SessionIdentifier` (`sessionId`, `namespace`).
2.  **Launching:** Agents are orchestrated (e.g., via Docker or local executables) and connect to the Coral Server's MCP endpoints.
3.  **Active:** Agents collaborate using the thread-based communication model.
4.  **Closing:** The session can be closed manually, or it will close automatically when its Time To Live (TTL) expires.
5.  **Persistence:** After closing, a session can be held for a specified duration based on `SessionPersistenceMode`.

## Persistence Modes

Coral Server supports different session persistence modes (set on `SessionRuntimeSettings.persistenceMode`) to control how long a session remains accessible after it ends. Use `SessionRuntimeSettings.ttl` to bound overall lifetime.

- **SessionPersistenceMode.None:** The session is deleted immediately after all agents have finished.
- **SessionPersistenceMode.HoldAfterExit:** The session is kept for a fixed duration after its agents exit.
- **SessionPersistenceMode.MinimumTime:** The session will exist for at least a specified total duration (including runtime).

These modes retain state **in memory**. They do not store sessions durably or restore them after a server restart. Retained sessions report `status.type = "closing"`; once removed, reads return 404. Export results to your own storage through custom tools or an end-report webhook.

For immediate execution, settings belong under `execution.runtimeSettings`:

```json
{
  "execution": {
    "mode": "immediate",
    "runtimeSettings": {
      "ttl": 300000,
      "persistenceMode": { "mode": "hold_after_exit", "duration": 60000 }
    }
  }
}
```

The default TTL is unset and persistence defaults to `none`. Set both deliberately. To store a session-to-job mapping before agents can call your application, create with `execution: { "mode": "defer" }`, persist the returned identifier, then POST runtime settings directly to `/api/v1/local/session/{namespace}/{sessionId}`.

## Webhooks

Sessions can be configured with webhooks to notify your application of lifecycle events. For example, set `webhooks.sessionEnd` in `SessionRuntimeSettings` to receive a `SessionEndReport` when the session closes. If `extendedEndReport` is enabled, the report includes the extended session state.

## How can I create a session?

Sessions can be created through the [Coral Console interface](../concepts/coral-console.md) or [programmatically via the REST API](../cloud/using-api.md). For direct API usage, call `POST /api/v1/local/session` with a `SessionRequest`.

---

For more details on the session API, see the [API Reference](../cloud/using-api.md).
