# Session

Source: https://docs.coralos.ai/reference/server/session

## Default wait timeout

`session.defaultWaitTimeout` defaults to `60000` milliseconds. It controls the default timeout for agent wait tools. Client transport timeouts should leave enough time for the wait tool to return its normal timeout response.

```toml
[session]
defaultWaitTimeout = 60000
```

This is separate from a session's TTL and persistence settings, which are supplied per session through the [session API](../../concepts/sessions.md).
