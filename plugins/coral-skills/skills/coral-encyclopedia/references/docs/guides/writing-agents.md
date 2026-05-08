---
title: "Writing Agents"
description: "How to write agents that work with Coral Server"
sidebarTitle: "Writing Agents"
icon: "bot"
---
# Prerequisites
- A running instance of [Coral Server](https://github.com/Coral-Protocol/coral-server?tab=readme-ov-file#how-to-run)
- An existing agent you want to onboard to Coral
# Modifying your agent
Agents interact with Coral sessions exclusively through a uniquely provided MCP server. All interaction with other agents is then done with the tools available through that MCP.
### Connect to Coral
Since each agent in a session is given its own MCP - your agent must receive the MCP's connection url dynamically. When running the agent through Coral Server's orchestrator, that is provided by the `CORAL_CONNECTION_URL` environment variable.
Here are some example snippets for popular Python frameworks:
> **Warning:** 
  These snippets are **not** complete implementations, or guaranteed to work as
  is for your agent! Actual integration heavily depends on your agent's existing
  implementation.
```python CAMEL-AI
from camel.toolkits.mcp_toolkit import MCPClient
from camel.utils.mcp_client import ServerConfig
coral_url = os.environ["CORAL_CONNECTION_URL"]  # Provided by Coral Server at runtime
prefer_sse = coral_url.endswith("/sse/")  # Use SSE only when the URL is an SSE endpoint
coral_mcp = MCPClient(
    ServerConfig(
        url=coral_url,
        timeout=3000000.0, # Long timeouts since wait_for_mentions, etc. can take a long time.
        sse_read_timeout=3000000.0,
        terminate_on_close=True,
        prefer_sse=prefer_sse
    ),
    timeout=3000000.0
)
```
> **Note:** 
  The server provides a per-agent MCP connection URL via `CORAL_CONNECTION_URL`. It may point to the Streamable HTTP endpoint (`/mcp/v1/{agentSecret}/mcp`) or the SSE endpoint (`/mcp/v1/{agentSecret}/sse/`). For SSE, a trailing slash is required. Do not hardcode this URL — always use the exact value provided.
### Agent Configuration
Agents have a lot of options that users would want to change. API keys, models, providers, and even sampling parameters (temperature, top_p) - are all things we want to accept dynamically.
Coral's orchestrator provides an 'option' system, that allows you - the agent developer - to expose specific typed options, and receive the values of those options as environment variables.
> **Danger:** 
  This means you should **not** load `.env` files by default, since environment
  variables should *only* be provided by Coral Server.{" "}
See [Agent Options](#agent-options) for details on how to expose your configuration options.
# Packaging your agent
Now that your agent works with Coral, to make it work with orchestration - you need to package your agent.
In the root of your agent repository/folder, create a `coral-agent.toml` file. This is the entrypoint for your agent from Coral's POV. For example, for local use of agents - these files are referenced by your coral server's `registry.toml`.
An agent definition starts with basic metadata:
```toml
edition = 3
[agent]
name = "name-of-my-agent"
version = "0.1.0" # agent version (should be semver)
description = "Description of this agent's capabilities, that is shown to other agents"
```
### Agent Options
Coral's orchestrator allows you to expose specific typed options, to be passed to your agent on instantiation as environment variables.
`options` are a map of option names, to user configurable options you want to expose.
Each option has:
### Example coral-agent.toml snippet
```toml
edition = 3
[agent]
name = "my-discord-agent"
version = "1.1.0"
[options.DISCORD_API_TOKEN]
type = "string"
required = true
secret = true
display.description = "Discord API token"
[options.DISCORD_THREAD_ID]
type = "string"
required = true
display.description = "The ID of the thread to watch"
[options.OPENROUTER_API_KEY]
type = "string"
required = true
secret = true
display.description = "An API key for OpenRouter"
```
### Agent Runtimes
Coral Server's orchestrator supports multiple 'runtimes' — ways of running agents. Supported in v1.1.0+: `docker`, `executable` (local subprocess), and `function` (server-side, internal/testing).
> **Note:** 
  It's recommended you support Docker if you intend to publish your
  agent, or export it as a remote agent (closed beta).
    ### Docker
        Running your agent via docker naturally requires your agent to be containerized.
        How you containerize your agent depends a lot on how your agent is written - what language it uses, how it manages dependencies, etc. Feel free to browse our curated list of agents [here](https://github.com/Coral-Protocol/awesome-agents-for-multi-agent-systems) for reference on packaging Python agents for Docker using [uv](https://docs.astral.sh/uv/).
        Once it is, you simply reference your image in the `coral-agent.toml`:
        ```toml
        [runtimes.docker]
        image = "name-of-docker-image" # whatever you would put in `docker run [image]`
        ```
        > **Warning:** 
            While specifiying a tag does work, we recommend you do **not** add one, since Coral Server will use the agent's defined version (as seen earlier) as the docker tag (for better reproducibility).
            This means you **must** tag your images with the agent's version when publishing to a container registry.
        For agents only intended to be ran by your own local coral servers, just having the image built & present locally is enough.
        For public agents, you need to make sure the image is available on a registry like [Docker Hub](https://hub.docker.com/) or [Github's Container registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
    ### Executable (local subprocess)
    This runtime is even more implementation dependent - since you are running a command/process directly on the same host as the server. It's also not portable, since it's hard to account for all possible system environments.
    For these reasons it's recommended you use the Docker runtime whenever possible.
    A good pattern to maximise portability is writing wrapper scripts for each OS you want to support, that handles ensuring dependencies are present/downloaded (e.g. create/enter a python virtual environment, download dependencies)
    Here's an example of a bootstrap script we use for [our agents](https://github.com/Coral-Protocol/awesome-agents-for-multi-agent-systems):
    ### Bootstrap script
    ```sh run_agent.sh
    #!/usr/bin/env bash
    set -e
    PYTHON_SCRIPT="main.py"
    # Determine script directory
    SCRIPT_DIR=$(dirname "$(realpath "$0" 2>/dev/null || readlink -f "$0" 2>/dev/null || echo "$0")")
    PROJECT_DIR="$SCRIPT_DIR"
    echo "Agent directory: $PROJECT_DIR"
    # Change to project directory
    cd "$PROJECT_DIR"
    echo "Running $PYTHON_SCRIPT..."
    uv run "$PYTHON_SCRIPT"
    ```
    Adding this runtime to your `coral-agent.toml` would look something like:
    ```toml
    [runtimes.executable]
    path = "bash"
    arguments = ["-c", "run_agent.sh"]
    # each 'word' of your command should be a separate item in the array, to minimise issues with argument parsing
    ```
### Runtime transport (agent↔server)
Agents communicate with Coral Server using MCP over HTTP. Two transport modes are supported by all runtimes:
- `streamable_http` (default)
- `sse` (legacy Server‑Sent Events)
Select the mode per runtime with the optional `transport` field in `coral-agent.toml`:
```toml
[runtimes.docker]
image = "name-of-docker-image"
transport = "streamable_http" # default
[runtimes.executable]
path = "./launch"
arguments = ["my-agent"]
transport = "sse" # opt into SSE if your agent expects it
```
# Orchestration Environment
Agents run under orchestration are provided with a set of "system" environment variables that are needed/useful to work with Coral:
| Variable | Description |
| :--- | :--- |
| `CORAL_CONNECTION_URL` | The MCP connection URL for this agent. Defaults to Streamable HTTP; may be SSE depending on the selected runtime transport. |
| `CORAL_AGENT_ID` | The unique name of the agent instance in the session. |
| `CORAL_AGENT_SECRET` | A unique secret used to authenticate with the server's MCP endpoints. |
| `CORAL_SESSION_ID` | The ID of the session the agent belongs to. |
| `CORAL_API_URL` | The URL of the Coral Server's REST API. |
| `CORAL_RUNTIME_ID` | The orchestration runtime being used (`docker`, `executable`, `function`). |
| `CORAL_SEND_CLAIMS` | Internal flag for payments/claims reporting (currently `0`). |
| `CORAL_PROMPT_SYSTEM` | Additional system instructions provided at session creation. |
| `CORAL_REMOTE_AGENT` | Present and set to `1` if this is a remote agent (not common in v1.1.0). |
# Local iteration tips
During development, we recommend:
- Use the `executable` runtime to iterate locally, or containerize early and use the `docker` runtime for parity.
- Make your agent discoverable to Coral Server with `coralizer link .` so it appears in the local registry.
- Create a session via the REST API at `POST http://localhost:5555/api/v1/local/session` to launch and test your agent.
> **Warning:** 
Do not hardcode MCP connection URLs or load `.env` overrides while running under orchestration. Always rely on the `CORAL_*` variables supplied by Coral Server.
