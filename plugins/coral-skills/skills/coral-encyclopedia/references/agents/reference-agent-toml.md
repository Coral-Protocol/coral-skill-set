# coral-agent.toml Reference

The `coral-agent.toml` file is the manifest for every Coral agent. It tells the server how to identify, configure, and run the agent.

## Complete Annotated Example

```toml
# Schema edition — always use 3 (current)
edition = 3

[agent]
# Unique agent name — used as the identifier in the registry
# Must be unique among all agents linked to the server
name = "my-agent"

# Semantic version
version = "0.1.0"

# Short description shown in the registry and console
description = "A helpful agent that does X"

# Longer description (supports markdown)
readme = "My Agent for Coral Protocol"

# One-line summary for compact displays
summary = "Does X efficiently"

[agent.license]
# License type — currently only "spdx" is supported
type = "spdx"
# SPDX license expression
expression = "MIT"

# --- Options ---
# Options are user-configurable values passed to the agent at runtime.
# They appear in the Coral Console UI and can be set in the session creation request.

[options.auto_launch]
# Type can be: string, bool, i8, i16, i32, i64, u8, u16, u32, u64, f32, f64, blob
type = "string"
# Default value (used if not overridden in the session request)
default = "false"

# Example: API key option
# [options.api_key]
# type = "string"
# default = ""

# --- Runtimes ---
# Defines how the server launches this agent.
# Two main runtime types: executable and docker.

[runtimes.executable]
# Path to the executable (relative to agent directory or absolute)
path = "bash"
# Arguments passed to the executable
arguments = ["startup.sh"]
# MCP transport type — always "streamable_http" for Coral
transport = "streamable_http"

# --- Alternative: Docker runtime ---
# [runtimes.docker]
# image = "my-agent:latest"
# transport = "streamable_http"
# # Optional: map host ports
# ports = ["8080:8080"]
# # Optional: pass environment variables
# environment = ["API_KEY=${options.api_key}"]
```

## Environment Variables Passed to Agents

When the server launches an agent, these environment variables are automatically set:

| Variable | Description |
|----------|-------------|
| `CORAL_AGENT_ID` | Unique identifier for this agent instance in the session |
| `CORAL_SESSION_ID` | The session this agent belongs to |
| `CORAL_CONNECTION_URL` | The MCP server URL the agent should connect to |

## Runtime Types

### Executable

Runs a local process. The `path` and `arguments` define the command. The agent directory is the working directory.

### Docker

Runs the agent in a Docker container. The server manages the container lifecycle. Requires Docker to be installed and configured in the server's `config.toml`.

## Options Best Practices

- Use `auto_launch` with default `"false"` to prevent agents from auto-starting
- Pass sensitive values (API keys) as options rather than hardcoding in the agent
- Options can be set per-session in the `GraphAgentRequest.options` field
