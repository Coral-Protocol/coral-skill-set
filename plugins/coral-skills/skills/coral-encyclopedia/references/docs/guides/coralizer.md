---
title: "Coralizer CLI Guide"
description: "The Coralizer CLI tool helps you turn any tool or MCP server into a Coralized agent."
sidebarTitle: "Coralizer"
icon: "terminal"
---
The `coralizer` CLI is a powerful tool designed to simplify the process of creating, configuring, and registering agents for the Coral OS. It provides several commands to help you manage your agents and their dependencies.
## Installation
Install the `coralizer` CLI using `cargo`:
```bash
cargo install --git https://github.com/Coral-Protocol/coralizer
```
Verify the installation:
```bash
coralizer --version
```
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
