# Agent configuration

The `coral-agent.toml` file

Source: https://docs.coralos.ai/reference/agent

Agents are created and configured using a `coral-agent.toml` file.  Every agent in Coral (Server, Console, Cloud and
Marketplace) has exactly one `coral-agent.toml` file.

# Syntax

A `coral-agent.toml` file is written in [TOML](https://toml.io/).  This file has a single top-level field, `edition` and
configuration tables.

## Edition

The top-level `edition` field is a number indicating the edition of the `coral-agent.toml` file, allowing the Coral
server and other applications to quickly identify whether or not they are compatible.

__The current edition is 5.__ Public Coral Server 1.4.0 accepts editions 3 through 5. Older editions still need the required metadata and valid runtime/options fields.

## Tables

### [agent table](../reference/agent/tables/agent.md)

Contains basic information about the agent, such as its name and version.  This table is required, and many of its
fields are required.

### Runtimes table

An agent  __must define 1 or more__ of the following:

| Runtime                                                     | Environment             | Description                                                                       |
|-------------------------------------------------------------|-------------------------|-----------------------------------------------------------------------------------|
| [runtimes.executable](../reference/agent/tables/runtimes/executable.md) | development             | Used exclusively for development.  Cannot be used in the marketplace.             |
| [runtimes.docker](../reference/agent/tables/runtimes/docker.md)         | production              | Production runtime custom agents, highly configurable                             |
| [runtimes.prototype](../reference/agent/tables/runtimes/prototype.md)   | production, development | Limited configuration, but can be used for rapid agent prototyping and production |

### [options table](../reference/agent/tables/options.md)

The `options` table contains up to 512 unique options that allow your agent to be configured at runtime, by applications.

Options are optional; however, almost every agent will have options.  Options are for example used for:

- API keys used by LLMs
- API keys or tokens used by MCP servers
- Prompting adjustments

### [llm table](../reference/agent/tables/llm.md)

A table that describes the LLM requirements of the agent.  This table is optional; however, agents that do not use
LLM proxies will be limited in what Coral features they support.
