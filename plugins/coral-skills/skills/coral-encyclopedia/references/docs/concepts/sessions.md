---
title: "Sessions"
description: "In CoralOS, a session represents a single, self-contained context for a multi-agent interaction."
sidebarTitle: "Sessions"
icon: "container"
---
Sessions represent a single, self-contained context for a multi-agent interaction. You can think of a session as a **workspace** or **conversation instance** dedicated to a particular task or user request. It encompasses the agents involved, the messages they exchange, and any temporary state or budget allocated for each agent in that session.
## Namespaces
Sessions are organized into **Namespaces**. A namespace is a container for sessions, often used to separate data between different users, applications, or environments.
- **Isolation:** Sessions in different namespaces are completely isolated from each other.
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
## Webhooks
Sessions can be configured with webhooks to notify your application of lifecycle events. For example, set `webhooks.sessionEnd` in `SessionRuntimeSettings` to receive a `SessionEndReport` when the session closes. If `extendedEndReport` is enabled, the report includes the extended session state.
## How can I create a session?
Sessions can be created through the [Coral Console interface](/concepts/coral-console) or [programmatically via the REST API](/cloud/using-api). For direct API usage, call `POST /api/v1/local/session` with a `SessionRequest`.
---
For more details on the session API, see the [API Reference](/cloud/using-api).
