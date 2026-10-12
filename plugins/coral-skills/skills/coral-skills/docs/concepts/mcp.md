# MCP Integration

Coral Server implements the Model Context Protocol (MCP) to enable seamless integration between agents, servers, and applications.

Source: https://docs.coralos.ai/concepts/mcp

Coral Server integrates the [MCP](https://modelcontextprotocol.io/) protocol to let AI agents collaborate. Each orchestrated agent receives its own MCP endpoint. Streamable HTTP is the default transport; legacy SSE is also supported.

## How Coral Server uses MCP

When an agent is orchestrated, `CORAL_CONNECTION_URL` contains its MCP endpoint and a unique agent secret in the URL path. Connect using that exact URL and do not log it. Agent secrets also authenticate agent RPC requests; application REST requests use a server `auth.keys` bearer token.

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

For a detailed breakdown of what each resource contains and how they're injected into agents, see [Resources](../features/resources.md).

## Integrating with your Application

If you're building an application, you can integrate with Coral agents by:
1.  **Providing Custom Tools:** Define your own MCP tools and include them in the `agentGraphRequest.customTools` when creating a session. Coral Server will forward tool calls from agents to your specified HTTP endpoints.
2.  **Debugging with Puppet:** During development, use the Puppet API to create threads, send messages, and manage participants on behalf of an agent. Use custom tools for application input and output.

### Tool Definition Example

This fragment defines a custom tool. Include it alongside the session's `agents` array and grant access with `customToolAccess: ["query_database"]` on each agent that needs it:

```json
{
  "agentGraphRequest": {
    "customTools": {
      "query_database": {
        "transport": {
          "type": "http",
          "url": "https://your-api.com/query"
        },
        "description": "Query the company's SQL database",
        "inputSchema": {
          "type": "object",
          "properties": {
            "query": { "type": "string" }
          },
          "required": ["query"]
        },
        "outputSchema": { "type": "object" }
      }
    }
  }
}
```

For more details on integrating with your application, see [Integrating with your App](../guides/integrating-with-your-app.md).
