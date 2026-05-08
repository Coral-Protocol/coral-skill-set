# Agent Configuration Reference

## Agent Metadata (coral-agent.toml)

---
title: "Agent configuration"
description: "The `coral-agent.toml` file"
---
Agents are created and configured using a `coral-agent.toml` file.  Every agent in Coral (Server, Console, Cloud and
Marketplace) has exactly one `coral-agent.toml` file.
# Syntax
A `coral-agent.toml` file is written in [TOML](https://toml.io/).  This file has a single top level field, `edition` and
3 tables.
## Edition
The top-level `edition` field is a number indicating the edition of the `coral-agent.toml` file, allowing the Coral
server and other applications to quickly identify whether or not they are compatible.
__The current edition is 4__
## Tables
### 1. [agent table](/reference/agent/tables/agent)
Contains basic information about the agent, such as its name and version.  This table is required, and many of its
fields are required.
### 2. [runtimes table](/reference/agent/tables/runtimes)
An agent  __must define 1 or more__ of the following:
| Runtime                                                     | Environment             | Description                                                                       |
|-------------------------------------------------------------|-------------------------|-----------------------------------------------------------------------------------|
| [runtimes.executable](/reference/agent/runtimes/executable) | development             | Used exclusively for development.  Cannot be used in the marketplace.             |
| [runtimes.docker](/reference/agent/runtimes/docker)         | production              | Production runtime custom agents, highly configurable                             |
| [runtimes.prototype](/reference/agent/runtimes/prototype)   | production, development | Limited configuration, but can be used for rapid agent prototyping and production |
### 3. [options table](/reference/agent/tables/options)
The `options` table contains up to 512 unique options that allow your agent to be configured at runtime, by applications.
Options are optional; however, almost every agent will have options.  Options are for example used for:
- API keys used by LLMs
- API keys or tokens used by MCP servers
- Prompting adjustments

---

## Agent Fields

---
title: "[agent]"
description: "General agent information"
icon: table
---
## agent.name
A [string](https://toml.io/en/v1.1.0#string) defining the name for the agent.
```toml
[agent]
name = "my-agent"
```
__Requirements__
- At least one character
- No more than 32 characters
- Must start with a lowercase alphanumeric character
- All characters must be alphanumeric or `-`
## agent.version
A [string](https://toml.io/en/v1.1.0#string) defining the version of the agent.
```toml
[agent]
version = "1.0.0"
```
__Requirements__
- At least one character
- No more than 32 characters
- Must be a valid [semantic version](https://semver.org/)
## agent.description
A [PotentialStringReference](/reference/agent/types/potential-string-reference) description for this agent.  This
description is exclusively used by LLMs.  This description is only a default and may be overridden at runtime.  Agent
descriptions are provided to agents in the state resource.
```toml
[agent]
description = "An agent with web search capabilities"
```
__Requirements__
- At least one character
- No more than 1024 characters
## agent.capabilities
An [array](https://toml.io/en/v1.1.0#array) of capabilities.
```toml
[agent]
capabilities = ["resources", "tool_refreshing"]
```
This is a placeholder field.  Currently, this has no use.
__Requirements__
- All entries must be one of the following:
  - `resources`
  - `tool_refreshing`
- Must not contain duplicates
## agent.readme
A [PotentialStringReference](/reference/agent/types/potential-string-reference) readme for this agent.  This readme
is displayed in the Coral marketplace and in Coral console.  The summary is not provided in the state resource.  In
Coral console and in Coral marketplace the readme supports markdown.
```toml
[agent]
readme = """
A long descriptive readme for my agent.
"""
```
__Requirements__
- At least one character
- No more than 4096 characters
## agent.summary
A [PotentialStringReference](/reference/agent/types/potential-string-reference) summary for this agent.  This summary
is displayed in the Coral marketplace and in Coral console.  The summary is not provided in the state resource.
```toml
[agent]
summary = "An agent with web search capabilities"
```
__Requirements__
- At least one character
- No more than 256 characters
## agent.license
The license for this agent.  Licenses may be specified as an [SPDX expression](https://spdx.github.io/spdx-spec/v2.3/SPDX-license-expressions/)
or text via the [PotentialStringReference](/reference/agent/types/potential-string-reference) type.
The license will be displayed in the Coral marketplace.
    ##### SPDX
        ```toml
        [agent.license]
        type = "spdx"
        expression = "MIT"
        ```
        __Requirements__
        - The expression must be valid.  See [here](https://spdx.github.io/spdx-spec/v2.3/SPDX-license-expressions)
        for more information.
    ##### Text
        ```toml
        [agent.license]
        type = "text"
        text = { type = "file", path = "LICENSE.TXT" }
        ```
        __Requirements__
        - The license text must not be larger than 2 MiB
## agent.keywords
An [array](https://toml.io/en/v1.1.0#array) of [string](https://toml.io/en/v1.1.0#string) keywords to describe this
agent.  These keywords are used by the Coral marketplace and the Coral console agent registry to search for agents.
```toml
[agent]
keywords = ["web", "search"]
```
__Requirements__
- Each keyword must contain at least one character
- Each keyword must not contain more than 256 characters
- Must not contain duplicates
- Must not contain more than 64 keywords
## agent.links
A [table](https://toml.io/en/v1.1.0#table) of [strings](https://toml.io/en/v1.1.0#string), where the key is the
link name and the value is the link URL.  These links are displayed in the Coral marketplace and in the Coral console.
```toml
[agent]
links.github = "https://github.com/coral-Protocol/coral-server"
links.home = "https://www.coralos.ai"
```
__Requirements__
- Link names must start with an alphabetic character
- Link names must contain only alphanumeric characters, underscores (`_`) and dashes (`-`)
- Link names must be at least one character long and at most 32 characters long
- Link values must be at least one character long and at most 256 characters long
- Link values must be a valid URL
- Link values must be either `https`, `mailto` or `tel`
- No more than 16 links may be specified

---

## Runtime: Executable

---
title: Executable runtime
---
> **Warning:** Executable runtimes are not permitted on the Coral marketplace
Executable runtimes can be configured to run an executable of your choice. This is a useful development runtime,
allowing you to run your agent without containerizing it first.
# Full example
    ##### Python
        ```toml
        [runtimes.executable]
        path = "python3"
        arguments = ["main.py"]
        transport = "streamable_http" # default value
        ```
    ##### TypeScript
        ```toml
        [runtimes.executable]
        path = "bun"
        arguments = ["run", "src/index.ts"]
        transport = "streamable_http" # default value
        ```
    ##### Rust
        ```toml
        [runtimes.executable]
        path = "cargo"
        arguments = ["run", "--release"]
        transport = "streamable_http" # default value
        ```
<CommonEnvironment runtime="executable" />
### Other environment variables
- An environment variable for every defined [agent option](/reference/agent/options)
- All the environment variables the Coral server was launched with
- All environment variables configured in the Coral server's [debug.additionalExecutableEnvironment](/reference/server/config/debug#additional-executable-environment) configuration field
# Configuration
### runtimes.executable.path
__Example__
```toml
[runtimes.executable]
path = "bootstrap"
```
> **Warning:** 
    Arguments cannot be provided in the path. All arguments must be provided via [runtimes.executable.arguments](#runtimes-executable-arguments)
A [string](https://toml.io/en/v1.1.0#string) representing the path to the executable. This can be:
- A name of an executable/script on your systems `PATH` environment variable
- An executable, relative to the `coral-agent.toml` file
- An absolute path to an executable/script
__Requirements__:
- The executable path must be between 1 and 4096 characters long.
> **Info:** 
    On Windows, the Coral server will try to append the extensions:
    - `.exe`
    - `.cmd`
    - `.bat`
    To the executable path. If no files are found with these extensions, it will fallback to the specified path with no
    extension.
    This is a useful feature when developing an agent that requires a bootstrap script.
    Consider the following structure:
        <Tree.Folder name="my-agent" defaultOpen>
            <Tree.Folder name="src" defaultOpen>
                <Tree.File name="..."/>
            </Tree.Folder>
            <Tree.File name="coral-agent.toml"/>
            <Tree.File name="bootstrap"/>
            <Tree.File name="bootstrap.bat"/>
        </Tree.Folder>
    The example will execute the `bootstrap` file (use a [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) in this file) on Unix
    and the `bootstrap.bat` on Windows.
### runtimes.executable.arguments
An [array](https://toml.io/en/v1.1.0#array) of [strings](https://toml.io/en/v1.1.0#string)
denoting the arguments to pass to [runtimes.executable.path](#runtimes-executable-path)
__Example__
```toml
[runtimes.executable]
path = "npm"
arguments = ["run", "start"]
```
__Requirements__:
- No more than 1024 arguments can be provided.
- The total size of all arguments must not exceed 2 KiB
### runtimes.executable.transport {#transport}
 `streamable_http` <br/>
__Example__
```toml
[runtimes.executable]
transport = "sse"
```
<CommonTransport />

---

## Runtime: Docker

---
title: Docker runtime
---
In Coral, (Docker) containers are the preferred production execution environment for Coral agents. The Docker runtime is
a way of configuring the Coral server to run your agent using a Docker image.
Running Docker agents on your Coral server may require additional configuration, see [the Docker config](/reference/server/config/docker) for more information.
> **Info:** 
    If you are running the Coral server using Docker, you must set up [Docker in Docker](/guides/production/docker-in-docker)
# Full example
```toml
[runtimes.docker]
image = "myusername/myagent"
command = ["--custom-command", "123"]
transport = "streamable_http" # default value
```
<CommonEnvironment runtime="docker" />
### Other environment variables
- An environment variable for every defined [agent option](/reference/agent/options)
- All the environment variables the Coral server was launched with
- All environment variables configured in the Coral server's [debug.additionalDockerEnvironment](/reference/server/config/debug#additional-docker-environment) configuration field
# Configuration
### runtimes.docker.image
__Example__
```toml
[runtimes.docker]
image = "myusername/myagent"
```
A [string](https://toml.io/en/v1.1.0#string) representing the Docker image name to run for this agent. If no tag is
specified, the [version of the agent](/reference/agent/tables/agent#agent-version) will be used as a tag. It is
recommended to __not__ specify a tag in this field and allow the agent version to control which Docker image is used.
### runtimes.docker.command
__Example__
```toml
[runtimes.docker]
command = ["--custom-command", "123"]
```
An [array](https://toml.io/en/v1.1.0#array) of [strings](https://toml.io/en/v1.1.0#string) overriding the default
command ran in the Docker container. Leave this field empty to use the command specified in the Docker image.
### runtimes.docker.transport {#transport}
 `streamable_http` <br/>
__Example__
```toml
[runtimes.docker]
transport = "sse"
```
<CommonTransport />

