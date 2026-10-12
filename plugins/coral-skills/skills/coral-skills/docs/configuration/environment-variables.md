# Environment Variables Reference

Configure Coral Server and agents using environment variables.

Source: https://docs.coralos.ai/configuration/environment-variables

Coral Server and agents can be configured through environment variables. Server configuration lives in `config.toml`; there is no separate `registry.toml`.

## Coral Server Configuration

The Coral Server reads configuration from a TOML file and also supports overriding any config key via environment variables (through Hoplite's environment source). One explicit environment variable is supported for locating the primary config file:

| Variable | Description | Default |
| :--- | :--- | :--- |
| `CONFIG_FILE_PATH` | Optional path to a `config.toml` file to load on startup. A specified file must exist. | No disk file is loaded unless set; code defaults and an optional bundled `/config.toml` are also available. |

Common configuration keys and their defaults (set in code):

- `network.bindAddress`: `0.0.0.0`
- `network.bindPort`: `5555`
- `logging.logFilesDirectory`: `~/.coral/logs`
- `logging.logFileName`: `server.log` (inside `logging.logFilesDirectory`)

Overriding via environment variables:
- Use a **double underscore between table and field**, and a single underscore between words within a field: `NETWORK__BIND_PORT=5555` maps to `network.bindPort`. `NETWORK_BIND_PORT` does not override that setting.
- For the standard server build, command-line settings override environment settings, which override the file supplied through `CONFIG_FILE_PATH`.
- You can instead mount a complete `config.toml` and set `CONFIG_FILE_PATH`.

_Note:_ There are no fixed server variables like `CORAL_SERVER_BIND_ADDRESS`, `CORAL_SERVER_BIND_PORT`, `REGISTRY_FILE_PATH`, or `CORAL_DATABASE_PATH` in v1.4.0; use the config keys above or `CONFIG_FILE_PATH`.

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
| `CORAL_RUNTIME_ID` | Runtime type identifier (e.g., `docker`, `executable`). |
| `CORAL_PROMPT_SYSTEM` | Optional system prompt override, when defined for the agent. |
| `CORAL_PROXY_URL_<NAME>` | Base URL for a resolved proxy request named `<NAME>`. |
| `CORAL_PROXY_FORMAT_<NAME>` | Format for that proxy request. |
| `CORAL_PROXY_MODEL_<NAME>` | Model selected for that proxy request. |

_Notes:_
- `CORAL_SERVER_URL`, `CORAL_AGENT_NAME`, `CORAL_NAMESPACE`, `CORAL_SEND_CLAIMS`, and `CORAL_REMOTE_AGENT` are not set for local Docker/executable agents in public Server 1.4.0. Use `CORAL_API_URL`, `CORAL_AGENT_ID`, and application session metadata as appropriate.

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

For example, add `-e NETWORK__BIND_PORT=5555` to override the configured port. Environment names follow the same double-underscore mapping across deployments.
