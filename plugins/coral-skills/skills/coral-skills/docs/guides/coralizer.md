# Coralizer CLI Guide

The Coralizer CLI tool helps you turn any tool or MCP server into a Coralized agent.

Source: https://docs.coralos.ai/guides/coralizer

> **Note:**
>
> To turn MCP servers into a Coral agent, we now recommend asking a coding agent such as Codex or Claude Code to build one, using the [Koog agent template](https://github.com/Coral-Protocol/coral-koog-agent) as a reference. You get a Koog agent you can extend, instead of a generated LangChain or coral-rs project. See [Converting an MCP Server](#converting-an-mcp-server) for an example prompt. Coralizer's `link` command is still a quick way to make a local agent available to your server.

The `coralizer` CLI is a powerful tool designed to simplify the process of creating, configuring, and registering agents for the Coral OS. It provides several commands to help you manage your agents and their dependencies.

## Installation

Coralizer is published on npm as `@coral-protocol/coralizer`. Run it without installing, which needs Node.js:

```bash
npx @coral-protocol/coralizer@latest --help
```

Or install it globally to use the `coralizer` command directly:

```bash
npm install -g @coral-protocol/coralizer
coralizer --help
```

To build from source instead, use `cargo install --git https://github.com/Coral-Protocol/coralizer`.

## Core Commands

### `mcp`
Scaffold a Coral agent project from one or more MCP servers. Generates the project structure and a `coral-agent.toml` with discovered options.

Usage:

```bash
coralizer mcp <OUTPUT_PATH> <MCP_SERVERS_JSON> [-f|--framework langchain|coral-rs] [-n|--name <AGENT_NAME>]
```

Example:

```bash
coralizer mcp ./my-agent ./mcp-servers.json -f langchain -n my-mcp-agent
```

### `link`
Create a versioned symlink for the current agent (directory containing `coral-agent.toml`) into `~/.coral/agents/<name>/<version>`. This makes the agent discoverable by Coral Server's local registry.

```bash
coralizer link .
```

### `unlink`
Safely remove the versioned symlink for the current agent.

```bash
coralizer unlink .
```

### `updeletelink`
Remove all version links for an agent except the latest.

```bash
coralizer updeletelink .
```

## Using Templates

Coralizer supports multiple frameworks via templates. These include the basic structure for an agent and its `coral-agent.toml` file.

- Python: `langchain`
- Rust: `coral-rs`

## Common Workflows

### Converting an MCP Server

> **Tip:**
>
> Recommended: instead of running `coralizer mcp`, give a coding agent such as Codex or Claude Code a prompt like this:
>
> ```text
> Build a Coral agent around these MCP servers:
> <list each server and how it is started or reached>.
> Use https://github.com/Coral-Protocol/coral-koog-agent as the reference for the
> project structure, coral-agent.toml, options, and the connection to Coral.
> Follow https://docs.coralos.ai/guides/writing-agents.
>
> work with me to figure out how to idiomatically define this agent to take the related responsibilities, and define the options
> to add appropriate flexibility and reusability.
>
> Consider the amount of responsibility and information the agent is likely to deal take, and whether it could be optimal
> to define more agents.
> ```

If you have an existing MCP server, you can quickly scaffold a Coral agent using the `mcp` command.

1. Prepare an MCP servers JSON (see the Coralizer repo for format) describing your MCP server(s).
2. Generate the agent project:
   ```bash
   coralizer mcp ./my-agent ./mcp-servers.json -f langchain -n my-agent
   ```
3. Configure the agent: Edit the generated `coral-agent.toml` to set your agent's name, version, runtimes, and options.
4. Make it discoverable by the local server:
   ```bash
   cd ./my-agent
   coralizer link .
   ```

### Building a New Agent

To build a new agent from scratch:

1.  Use `mcp` to scaffold a project for your target framework using your MCP description JSON.
2.  Develop your agent logic and tools following Coral's conventions.
3.  Link the agent locally with `coralizer link .`, then create a session on your Coral Server to run it.

---

For more details on the `coralizer` CLI, see the [Coralizer GitHub repository](https://github.com/Coral-Protocol/coralizer).
