---
title: "Environment Variables Reference"
description: "Configure Coral Server and agents using environment variables."
sidebarTitle: "Environment Variables"
icon: "gears"
---
Coral Server and agents can be configured through a set of environment variables. These are useful for setting secrets, providing configurations in Docker environments, and overriding values in `config.toml` or `registry.toml`.
## Coral Server Configuration
The Coral Server reads configuration from a TOML file and also supports overriding any config key via environment variables (through Hoplite's environment source). One explicit environment variable is supported for locating the primary config file:
| Variable | Description | Default |
| :--- | :--- | :--- |
| `CONFIG_FILE_PATH` | Optional path to a `config.toml` file to load on startup. | none (falls back to bundled `/config.toml`) |
Common configuration keys and their defaults (set in code):
- `network.bindAddress`: `0.0.0.0`
- `network.bindPort`: `5555`
- `logging.logFilesDirectory`: `~/.coral/logs`
- `logging.logFileName`: `server.log` (inside `logging.logFilesDirectory`)
Overriding via environment variables:
- Hoplite maps environment variables to configuration keys. Exact names depend on the mapping strategy in your environment/shell. As a rule of thumb, you can uppercase and underscore the path (e.g., `NETWORK_BIND_PORT=5555`).
- When uncertain, prefer mounting a `config.toml` and using `CONFIG_FILE_PATH` to avoid portability issues.
_Note:_ There are no fixed server variables like `CORAL_SERVER_BIND_ADDRESS`, `CORAL_SERVER_BIND_PORT`, `REGISTRY_FILE_PATH`, or `CORAL_DATABASE_PATH` in v1.1.0; use the config keys above or `CONFIG_FILE_PATH`.
## Agent Configuration
When Coral Server orchestrates an agent (e.g., via Docker), it passes several environment variables to the agent process. These are used to provide the agent with session-specific context and credentials.
### Standard Agent Variables
| Variable | Description |
| :--- | :--- |
| `CORAL_CONNECTION_URL` | Connection URL for the agent to reach the server's MCP endpoint (SSE or Streamable HTTP), resolved per runtime and address context. |
| `CORAL_AGENT_ID` | The unique agent name within the session. |
| `CORAL_AGENT_SECRET` | Secret used by the agent to authenticate with the MCP server. |
| `CORAL_SESSION_ID` | The session ID the agent belongs to. |
| `CORAL_API_URL` | Base URL for the Coral API, resolved per runtime/address context. |
| `CORAL_SEND_CLAIMS` | Always set to `"0"`. |
| `CORAL_RUNTIME_ID` | Runtime type identifier (e.g., `docker`, `executable`, `function`). |
| `CORAL_PROMPT_SYSTEM` | Optional system prompt override, when defined for the agent. |
| `CORAL_REMOTE_AGENT` | Optional flag set to `"1"` when the agent runs remotely. |
_Notes:_
- `CORAL_SERVER_URL`, `CORAL_AGENT_NAME`, and `CORAL_NAMESPACE` are not set by the server in v1.1.0. Use `CORAL_API_URL`, `CORAL_AGENT_ID`, and session metadata respectively.
### Agent-Specific Options
Custom options defined in the `coral-agent.toml` for an agent are also passed as environment variables by default (if `transport = "env"`).
For example, if an agent has an option named `OPENAI_API_KEY`:
```toml
[options.OPENAI_API_KEY]
type = "string"
required = true
```
The agent will receive an environment variable named `OPENAI_API_KEY` containing the value provided by the user.
## Tips for Docker
When running Coral Server in Docker, prefer mounting a config file and pointing the server to it:
```bash
docker run \
  -p 5555:5555 \
  -v $(pwd)/config.toml:/config.toml \
  -e CONFIG_FILE_PATH=/config.toml \
  ghcr.io/coral-protocol/coral-server:latest
```
You can still override individual settings via environment variables (per Hoplite mapping), but using a mounted config avoids naming differences across environments.
