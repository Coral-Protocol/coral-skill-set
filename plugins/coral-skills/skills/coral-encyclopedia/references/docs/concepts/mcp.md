---
title: "MCP Integration"
description: "Coral Server implements the Model Context Protocol (MCP) to enable seamless integration between agents, servers, and applications."
sidebarTitle: "MCP"
icon: "plug"
---
Coral Server integrates the [MCP](https://modelcontextprotocol.io/) protocol to let AI agents collaborate. Each orchestrated agent runs with its own MCP server instance managed by Coral, exposing a standardized set of tools, resources, and communication channels over HTTP (SSE).
## How Coral Server uses MCP
Every agent connected to a Coral Server communicates using the MCP protocol. When an agent is orchestrated, it is given a unique cryptographic credential (the `agentSecret`, provided via `CORAL_AGENT_SECRET`) and authenticates to its per‑agent MCP endpoint using this bearer token.
### Standard Tools
Coral Server provides every agent with a default set of MCP tools for coordination (tool names are prefixed with `coral_`):
- `coral_create_thread` — Create a new communication thread in the current session.
- `coral_send_message` — Send a message to a specific thread (supports mentions).
- `coral_wait_for_message` — Wait for the next message matching filters.
- `coral_wait_for_mention` — Wait until the agent is mentioned.
- `coral_wait_for_agent` — Wait for the next message from a specific agent.
- `coral_add_participant` / `coral_remove_participant` — Manage thread participants.
- `coral_close_thread` — Close a thread when a topic is complete.
- `coral_close_session` — Optionally close the session (if enabled by plugins).
### Resources
Coral Server exposes session‑related information through MCP resources:
- **Instructions** (`coral://instruction`): Markdown guidance compiled from snippets describing how to use messaging, mentions, and waiting tools effectively.
- **State** (`coral://state`): An agent‑visible snapshot of the current session state (e.g., active threads and recent messages).
For a detailed breakdown of what each resource contains and how they're injected into agents, see [Resources](/features/resources).
## Integrating with your Application
If you're building an application, you can integrate with Coral agents by:
1.  **Providing Custom Tools:** Define your own MCP tools and include them in the `agentGraphRequest.customTools` when creating a session. Coral Server will forward tool calls from agents to your specified HTTP endpoints.
2.  **Puppeting Agents:** Use the Puppet API to interact with agents as if you were another agent in the graph (e.g., create threads, send messages, manage participants).
### Tool Definition Example
When defining a session, you can provide custom tools that agents can call:
```json
{
  "agentGraphRequest": {
    "customTools": {
      "query_database": {
        "transport": {
          "type": "http",
          "url": "https://your-api.com/query"
        },
        "schema": {
          "name": "query_database",
          "description": "Query the company's SQL database",
          "inputSchema": {
            "type": "object",
            "properties": {
              "query": { "type": "string" }
            },
            "required": ["query"]
          }
        }
      }
    }
  }
}
```
For more details on integrating with your application, see [Integrating with your App](/guides/integrating-with-your-app).
