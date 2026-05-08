---
title: "Coral Cloud 1 Page API Reference"
description: "1 Page with everything you need to get started with Coral Cloud API"
sidebarTitle: "Coral Cloud API"
icon: "cloud"
---
# Coral Cloud API
Coral Cloud is a managed platform that lets you orchestrate agents on-demand via a convenient HTTP API.
# Getting keys
[//]: # (LLMs: You should have been given an API key already and not need to set one up via any web interface)
To get started, you need to get an API key. You can find your API keys [here](https://coralcloud.ai/account)
# Primer on Coral
Coral lets you orchestrate agents. Agent types are called registryAgents. These are the agents available to create in a session.
## Sessions
In Coral, agents don't exist outside sessions. You create a session in response to some transient need for agents like a user pressing a button (or something less transient like them loading a page or a work item entering the queue), and coral instantly creates a fresh instance of each of those agents.
The session will have a TTL (time to live) specified in milliseconds, and when that elapses, each agent is then permanently destroyed.
It's also possible to manually end a session early, if for example you know the work is completed or isn't completable.
An agent instance in a session has total autonomy and runs in a loop, where it may take an action of its choice each iteration, remembering everything from previous iterations in the same session. They may have a max number of iterations per session configurable as an option.
### Agent Communication
Coral agents are given tools to be able to collaborate with each other. These tools allow for slack-like communication, where threads can be created with a topic in mind, and participants can be added by agents.
The send message tool they are given includes a 'mentions' parameter, allowing other agents to be explicitly mentioned by name.
Agents may call a "wait for mentions" tool that will cause the agent to sleep until they are mentioned or a timeout duration elapses.
Agents are fully aware of these tools and how to use them, and it is sometimes appropriate to give them application-specific instructions that refer to the specifics of these tools.
### Groups
Agents in a session are made passively aware of all of the agents that share a group of them. Groups are essentially a way of describing the edges in the graph of agents that are connected by default in a session. An agent may be a member of many groups. You don't need to wait for any connected agents to come online, each connected part of the graph is asleep until each agent has connected and is ready.
### Custom tools / Agent-Application communication
On top of the default set of tools given to each agent, additional custom tools can be specified per agent in a session.
**Custom tools are the primary mechanism for getting output from agents.** Unlike traditional API calls that return results directly, Coral agents run asynchronously. To receive results, you define custom tools that agents call to send data back to your application via webhooks. For example, an agent might call a `submit_report` tool when it completes its analysis, or a `request_approval` tool when it needs human input.
Custom tools can also be used to let agents query your application for information they need during execution.
[//]: # (LLMs: A good understanding of this can be gleaned from the examples in this document)
More information about this can be found [here](/guides/integrating-with-your-app#custom-tools)
### Best practices
#### Team pattern
Coral uniquely enables a sort of agent team pattern where the developer does not need to explicitly plan out how each agent will interact.
This allows agents to be built with a focus on attending to certain types of responsibilities, without needing to consider the exact flow of how they're intended to be used. This also allows applications to think in more flexible terms: these are the capabilities that need to be met; these are the agents who will likely need to work together. The agents' own intelligence can be relied on for working around otherwise flow-breaking events, edge cases, or potential micro and macro optimizations.
This is particularly well suited for cases where a large amount of responsibility or information needs to be attended to that would usually overwhelm a single agent or be impractical to build a workflow around; agents can decide themselves which context is relevant to share with each other, and form, redefine, and distribute tasks among each other in a more dynamic manner.
#### Workflow pattern
More workflow/algorithmic style patterns are fully supported in Coral.
These patterns are particularly appropriate when there are common sub-problems that are known in advance that contain little or no subjectivity.
There are several known suitable mechanisms for achieving these sorts of patterns with Coral:
* Creating 1 session and, using options to pass in instructions to agents recommending a workflow for them
* Using custom tools to enforce a sort of checklist
* Creating several sessions in sequence, with some information passed between them via agent options
# API Reference
Keep in mind that some response fields are omitted for brevity, so remember to allow for extra fields in any deserialization code.
[//]: # (LLMs: The full API reference will overwhelm you, don't try this)
Most of Coral's local functionality is offered via Coral Cloud. You can see a full reference of this by running the [coral server](https://github.com/coral-protocol/coral-server/) locally and navigating to http://localhost:5555/ui/docs
## Creating a session
API reference for creating a session. Namespaces are provided via the request body using a `namespaceProvider`.
**Endpoint:** `POST /api/v1/local/session`
### Minimal Example
```javascript
fetch('https://api.coralcloud.ai/api/v1/local/session', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer YOUR_API_KEY'
  },
  body: JSON.stringify({
    agentGraphRequest: {
      agents: [
        {
          id: {
            name: 'natural-tone-agent',
            version: '1.1.0',
            source: 'local'
          },
          name: 'writer',
          provider: {
            type: 'local',
            runtime: 'docker'
          }
        }
      ]
      // `customTools` is optional and defaults to an empty map
    },
    namespaceProvider: {
      type: 'create_if_not_exists',
      namespaceRequest: {
        name: 'default',
        deleteOnLastSessionExit: true
      }
    },
    execution: {
      mode: 'immediate',
      runtimeSettings: {
        persistenceMode: {
          type: 'HoldAfterExit',
          holdTime: 5000
        }
      }
    }
  })
})
```
**Response:**
```json
{
  "namespace": "default",
  "sessionId": "session-abc123"
}
```
### Required Fields
```json
{
  "id": {
    "name": "agent-name",
    "version": "1.1.0",
    "source": "local"
  },
  "name": "unique-instance-name",
  "provider": {
    "type": "local",
    "runtime": "docker"
  }
}
```
### Optional Fields
```json
{
  "description": "Custom description visible to other agents",
  "systemPrompt": "Additional instructions for this agent",
  "blocking": false,
  "options": {
    "EXTRA_USER_PROMPT": { "type": "string", "value": "Your custom instructions here" },
    "MAX_ITERATIONS": { "type": "i32", "value": 50 }
  },
  "customToolAccess": ["tool_name_1", "tool_name_2"],
  "plugins": [ { "type": "close_session_tool" } ]
}
```
### Agent Groups
Groups define which agents are aware of each other and can communicate by default.
```json
{
  "agentGraphRequest": {
    "agents": [
      { "name": "agent1" },
      { "name": "agent2" },
      { "name": "agent3" },
      { "name": "agent4" },
      { "name": "agent5" }
    ],
    "groups": [
      ["agent1", "agent2", "agent3"],
      ["agent4", "agent5"]
    ]
  }
}
```
- Agents in the same group can see each other and create threads together
- An agent can be in multiple groups
- Groups don't start until all `blocking: true` agents have connected
### Custom Tools Definition
**Note:** The `customTools` field in `agentGraphRequest` is optional and defaults to an empty object.
```json
{
  "agentGraphRequest": {
    "agents": [],
    "groups": [],
    "customTools": {
      "tool_name": {
        "transport": {
          "type": "http",
          "url": "https://your-app.com/webhook",
          "signatureHeader": "X-Coral-Signature"
        },
        "schema": {
          "name": "tool_name",
          "description": "What this tool does (shown to agents)",
          "inputSchema": {
            "type": "object",
            "properties": {
              "param1": { "type": "string", "description": "..." },
              "param2": { "type": "number", "description": "..." }
            },
            "required": ["param1"]
          },
          "outputSchema": {
            "type": "object",
            "properties": {
              "success": { "type": "boolean" },
              "data": { "type": "string" }
            },
            "required": ["success"]
          }
        }
      }
    }
  }
}
```
Note: Depending on your deployment, additional identifying context (such as session or agent) may be provided by the server via headers or structured payloads. Always verify webhook auth and signature handling on your endpoint.
To grant an agent access to a custom tool, add the tool name to the agent's `customToolAccess` array.
### Session Runtime Settings
```json
{
  "sessionRuntimeSettings": {
    "ttl": 300000,
    "persistenceMode": {
      "mode": "hold_after_exit",
      "duration": 60000
    },
    "webhooks": {
      "sessionEnd": {
        "url": "https://your-app.com/api/session-complete"
      }
      }
    }
}
```
## Example: Getting output from agents using custom tools
This example shows how to create a session with a custom tool that allows an agent to submit a report back to your application. **This is the standard pattern for retrieving results from Coral agents.**
### Client-side: Creating the session
```javascript
// Store session-to-user mappings
const sessionUserMap = new Map();
const response = await fetch('https://api.coralcloud.ai/api/v1/local/session', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer YOUR_API_KEY'
  },
  body: JSON.stringify({
    agentGraphRequest: {
      agents: [
        {
          id: {
            name: 'natural-tone-agent',
            version: '1.1.0',
            source: 'local'
          },
          name: 'report-writer',
          provider: {
            type: 'local',
            runtime: 'docker'
          },
          customToolAccess: ['submit_report'],
          options: {
            EXTRA_USER_PROMPT: {
              type: 'string',
              value: 'Analyze Q4 sales data and create a summary report'
            }
          }
        }
        // ... other agents
      ],
      groups: [
        ['report-writer']
      ],
      customTools: {
        submit_report: {
          transport: {
            type: 'http',
            url: 'https://your-app.com/api/coral-webhook',
            signatureHeader: 'X-Coral-Signature'
          },
          schema: {
            name: 'submit_report',
            description: 'Submit a completed report to the application',
            inputSchema: {
              type: 'object',
              properties: {
                title: {
                  type: 'string',
                  description: 'The title of the report'
                },
                content: {
                  type: 'string',
                  description: 'The report content in markdown format'
                }
              },
              required: ['title', 'content']
            },
            outputSchema: {
              type: 'object',
              properties: {
                success: {
                  type: 'boolean'
                },
                reportId: {
                  type: 'string'
                }
              },
              required: ['success']
            }
          }
        }
      }
    },
    namespaceProvider: {
      type: 'create_if_not_exists',
      namespaceRequest: {
        name: 'default',
        deleteOnLastSessionExit: true
      }
    },
    execution: {
      mode: 'immediate'
    }
  })
});
const { sessionId } = await response.json();
// Map the session to the current user/tenant
sessionUserMap.set(sessionId, currentUserId);
```
### Server-side: Handling the custom tool webhook (Deno)
When the agent calls the `submit_report` tool, Coral will make an HTTP POST request to your webhook URL with `/{sessionId}/{agentId}` appended to the end.
**Important:** Make sure you reliably map session IDs back to users/tenants to prevent mixing up user data.
```text
// Store session-to-user mappings (use a database in production)
const sessionUserMap = new Map<string, string>();
serve(async (req) => {
  const url = new URL(req.url);
  const pathParts = url.pathname.split('/').filter(Boolean);
  // Extract sessionId and agentId from URL
  // e.g., /api/coral-webhook/{sessionId}/{agentId}
  const sessionId = pathParts[pathParts.length - 2];
  const agentId = pathParts[pathParts.length - 1];
  // Map sessionId to your user/tenant
  const userId = sessionUserMap.get(sessionId);
  if (!userId) {
    return new Response(JSON.stringify({
      success: false,
      error: 'Invalid session'
    }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' }
    });
  }
  // Parse the tool input from the request body
  const { title, content } = await req.json();
  // Handle the report submission
  // ... your application logic here ...
  // Return the response matching your outputSchema
  return new Response(JSON.stringify({
    success: true,
    reportId: 'report-123'
  }), {
    headers: { 'Content-Type': 'application/json' }
  });
});
```
## List all sessions
**Endpoint:** `GET /api/v1/session`
Returns all sessions across all namespaces.
### Example:
```javascript
fetch('https://api.coralcloud.ai/api/v1/session', {
  headers: {
    'Authorization': 'Bearer YOUR_API_KEY'
  }
})
```
**Response:**
```json
[
  {
    "namespace": "default",
    "sessions": [
      {
        "sessionId": "session-abc123",
        "closing": false
      },
      {
        "sessionId": "session-def456",
        "closing": true
      }
    ]
  }
]
```
## List sessions in namespace
**Endpoint:** `GET /api/v1/session/{namespace}`
Returns all sessions in a specific namespace.
### Example:
```javascript
fetch('https://api.coralcloud.ai/api/v1/session/default', {
  headers: {
    'Authorization': 'Bearer YOUR_API_KEY'
  }
})
```
**Response:**
```json
[
  {
    "sessionId": "session-abc123",
    "closing": false
  },
  {
    "sessionId": "session-def456",
    "closing": true
  }
]
```
## Get session state
**Endpoint:** `GET /api/v1/session/{namespace}/{sessionId}`
Returns the complete current state of a session including all agents, threads, and messages.
### Example:
```javascript
fetch('https://api.coralcloud.ai/api/v1/local/session/default/session-abc123', {
  headers: {
    'Authorization': 'Bearer YOUR_API_KEY'
  }
})
```
**Response:**
```json
{
  "id": "session-abc123",
  "namespace": "default",
  "timestamp": 1704067200000,
  "closing": false,
  "agents": [
    {
      "name": "writer",
      "registryAgentIdentifier": {
        "name": "natural-tone-agent",
        "version": "1.1.0",
        "source": "local"
      },
      "isConnected": true,
      "isWaiting": false,
      "description": "An agent that writes in natural tone",
      "links": ["researcher"]
    }
  ],
  "threads": [
    {
      "id": "thread-123",
      "name": "Research Discussion",
      "creatorName": "researcher",
      "participants": ["researcher", "writer"],
      "state": {
        "state": "open"
      },
      "messages": [
        {
          "id": "msg-1",
          "threadId": "thread-123",
          "senderName": "researcher",
          "text": "Here are my findings on AI developments",
          "timestamp": 1704067200000,
          "mentionNames": ["writer"]
        }
      ]
    }
  ]
}
```
## Inspecting agent status
The session state response includes an `agents` array with the current status of each agent. This is useful for monitoring agent health and debugging.
### Agent State Fields
| Field | Type | Description |
|-------|------|-------------|
| `name` | string | The unique instance name given to this agent in the session |
| `registryAgentIdentifier` | object | Reference to the agent's registry entry (name, version, source) |
| `isConnected` | boolean | `true` after the agent process launched and connected to Coral's MCP server |
| `isWaiting` | boolean | `true` when the agent is waiting for a message from another agent |
| `description` | string | The agent's description, visible to other agents in the session |
| `links` | string[] | List of other agent names this agent is aware of (from groups) |
### Example: Polling for agent readiness
```javascript
async function waitForAgentsReady(namespace, sessionId, timeoutMs = 30000) {
  const startTime = Date.now();
  while (Date.now() - startTime < timeoutMs) {
    const response = await fetch(
      `https://api.coralcloud.ai/api/v1/local/session/${namespace}/${sessionId}`,
      { headers: { 'Authorization': 'Bearer YOUR_API_KEY' } }
    );
    const state = await response.json();
    const allConnected = state.agents.every(agent => agent.isConnected);
    if (allConnected) {
      return state.agents;
    }
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
  throw new Error('Timeout waiting for agents to connect');
}
```
### Example: Checking if agents are idle
```javascript
async function areAgentsIdle(namespace, sessionId) {
  const response = await fetch(
    `https://api.coralcloud.ai/api/v1/local/session/${namespace}/${sessionId}`,
    { headers: { 'Authorization': 'Bearer YOUR_API_KEY' } }
  );
  const state = await response.json();
  // All agents are idle if they're all waiting for messages
  return state.agents.every(agent => agent.isWaiting);
}
```
## Viewing thread contents
The session state response includes a `threads` array containing all communication threads and their messages. This enables you to observe agent collaboration in real-time.
### Thread Fields
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique thread identifier |
| `name` | string | Thread topic/name |
| `creatorName` | string | Name of the agent that created the thread |
| `participants` | string[] | List of agent names participating in the thread |
| `state` | object | Either `{ "state": "open" }` or `{ "state": "closed", "summary": "..." }` |
| `messages` | array | List of messages in the thread |
### Message Fields
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique message identifier |
| `threadId` | string | ID of the thread this message belongs to |
| `senderName` | string | Name of the agent that sent the message |
| `text` | string | Message content |
| `timestamp` | number | Unix timestamp (milliseconds) |
| `mentionNames` | string[] | List of agent names mentioned in this message |
### Example: Getting all messages from a session
```javascript
async function getSessionMessages(namespace, sessionId) {
  const response = await fetch(
    `https://api.coralcloud.ai/api/v1/session/${namespace}/${sessionId}`,
    { headers: { 'Authorization': 'Bearer YOUR_API_KEY' } }
  );
  const state = await response.json();
  // Flatten all messages from all threads, sorted by timestamp
  const allMessages = state.threads
    .flatMap(thread => thread.messages.map(msg => ({
      ...msg,
      threadName: thread.name
    })))
    .sort((a, b) => a.timestamp - b.timestamp);
  return allMessages;
}
```
### Example: Streaming thread updates (polling)
```javascript
async function* streamThreadUpdates(namespace, sessionId, pollIntervalMs = 2000) {
  let lastMessageId = null;
  while (true) {
    const response = await fetch(
      `https://api.coralcloud.ai/api/v1/session/${namespace}/${sessionId}`,
      { headers: { 'Authorization': 'Bearer YOUR_API_KEY' } }
    );
    if (!response.ok) {
      if (response.status === 404) break; // Session closed
      throw new Error(`Failed to fetch session: ${response.status}`);
    }
    const state = await response.json();
    // Find new messages
    for (const thread of state.threads) {
      for (const message of thread.messages) {
        if (lastMessageId === null || message.timestamp > lastMessageId) {
          yield { thread, message };
          lastMessageId = message.timestamp;
        }
      }
    }
    if (state.closing) break;
    await new Promise(resolve => setTimeout(resolve, pollIntervalMs));
  }
}
// Usage
for await (const { thread, message } of streamThreadUpdates('default', 'session-abc123')) {
  console.log(`[${thread.name}] ${message.senderName}: ${message.text}`);
}
```
### Example: Finding threads by participant
```javascript
async function getThreadsWithAgent(namespace, sessionId, agentName) {
  const response = await fetch(
    `https://api.coralcloud.ai/api/v1/session/${namespace}/${sessionId}`,
    { headers: { 'Authorization': 'Bearer YOUR_API_KEY' } }
  );
  const state = await response.json();
  return state.threads.filter(thread =>
    thread.participants.includes(agentName)
  );
}
```
## Close a session
**Endpoint:** `DELETE /api/v1/session/{namespace}/{sessionId}`
Closes an active session, cancelling all running agents.
### Example:
```javascript
fetch('https://api.coralcloud.ai/api/v1/session/default/session-abc123', {
  method: 'DELETE',
  headers: {
    'Authorization': 'Bearer YOUR_API_KEY'
  }
})
```
**Response:** 200 OK (empty body)
## List agents
**Endpoint:** `GET /api/v1/registry`
Lists all agent types available in the registry.
### Example:
```javascript
fetch('https://api.coralcloud.ai/api/v1/registry', {
  headers: {
    'Authorization': 'Bearer YOUR_API_KEY'
  }
})
```
**Response:**
```json
[
  {
    "identifier": {
      "type": "local"
    },
    "timestamp": 1767109139139,
    "agents": [
      {
        "name": "living-knowledge-agent",
        "versions": ["0.1.0"]
      },
      {
        "name": "natural-tone-agent",
        "versions": ["1.1.0"]
      }
    ]
  }
]
```
## Inspect an agent
**Endpoint:** `GET /api/v1/registry/{source}/{agentName}/{version}`
Returns detailed information about a specific agent including its options, capabilities, and configuration schema.
**Sources:**
- `local` - Agents provided by Coral Cloud
- `marketplace` - Community marketplace agents
- `linked/{serverName}` - Agents from a linked server
### Example:
```javascript
fetch('https://api.coralcloud.ai/api/v1/registry/local/natural-tone-agent/1.1.0', {
  headers: {
    'Authorization': 'Bearer YOUR_API_KEY'
  }
})
```
**Response:**
```json
{
  "registryAgent": {
    "info": {
      "description": "An agent that communicates in natural, conversational tone",
      "capabilities": ["resources"],
      "identifier": {
        "name": "natural-tone-agent",
        "version": "1.1.0",
        "registrySourceId": {
          "type": "local"
        }
      }
    },
    "runtimes": {
      "docker": {
        "image": "coral/natural-tone-agent:1.1.0",
        "command": ["python", "agent.py"]
      }
    },
    "options": {
      "EXTRA_USER_PROMPT": {
        "type": "string",
        "required": false,
        "description": "Additional instructions or context for the agent",
        "display": {
          "label": "Extra Instructions",
          "description": "Custom instructions to guide the agent's behavior",
          "multiline": true
        },
        "transport": "env"
      },
      "MAX_ITERATIONS": {
        "type": "i32",
        "required": false,
        "description": "Maximum number of iterations before the agent stops",
        "default": 50,
        "validation": {
          "min": 1,
          "max": 200
        },
        "transport": "env"
      }
    },
    "exportSettings": {
      "docker": {
        "quantity": 100,
        "pricing": {
          "min_price": {
            "type": "micro_coral",
            "amount": 1000
          },
          "max_price": {
            "type": "micro_coral",
            "amount": 10000
          }
        },
        "options": {}
      }
    }
  },
  "restrictions": [
    {
      "type": "local"
    }
  ]
}
```
### Agent Option Types
Agents can have various option types:
- `string` - Text values
- `i8`, `i16`, `i32`, `i64` - Signed integers (various sizes)
- `u8`, `u16`, `u32`, `u64` - Unsigned integers
- `f32`, `f64` - Floating point numbers
- `bool` - Boolean values
- `blob` - Binary data
- `list[<type>]` - Lists of any of the above types
- `secret` - Sensitive string values (won't be logged)
Each option can have:
- `required` - Whether the option must be provided
- `default` - Default value if not provided
- `validation` - Constraints (min/max for numbers, regex for strings, etc.)
- `display` - UI hints for displaying the option
- `transport` - How the value is passed to the agent (`env` or `fs`)
# Base44 notes
You can use base44 to quickly build apps powered by Coral. Find it in the "Custom integrations" section [here](https://app.base44.com/integrations-catalog)
The browser/request URL is not a reliable base for webhook purposes. Webhook URL bases need to revolve around the base44 app domain. Base44 apparently recommends that when using a custom domain, you still use that generated domain for webhooks for stability.
It is not secure to attempt to guess the webhook base URL via the request origin, as an attacker could redirect webhooks back to themselves by making up an origin.
[//]: # (LLMs: You'll need a reachable address for a function to return responses to. Ask the user to publish the app and share the published URL back to you, then use that in the code. Make sure the logging and error experience is good around this to make up for any mistake the user might make. Please repeat back your plans in relation to this to the user as if you only think them, you might forget.)
## Sharing data from callbacks
In base44, functions run in isolation, you must use database functionality in order to have the rest of an application consider the response of a webhook callback.
## Path parameters in callbacks (important)
Base44 doesn't support path parameters in functions/callbacks, though for security Coral appends the session id and agent id as path parameters.
To work around this, there is a convenient cloudflare function deployed:
### Path-to-Header Proxy
Rewrites URL path segments into headers and proxies to a target.
#### URL Format
```
https://bitter-water-7a50.services-c22.workers.dev/{header-names}///{target-url}///{header-values}/{remaining-path}
```
#### Example with base44 for Coral custom tool
**Proxy URL (set as the custom tool transport URL):**
```
https://bitter-water-7a50.services-c22.workers.dev/X-SessionId/X-AgentId///https://some-app.base44.app/api/functions/coralWebhook///
```
When Coral calls this with session `abc123` and agent `my-agent`, the full URL becomes:
```
https://bitter-water-7a50.services-c22.workers.dev/X-SessionId/X-AgentId///https://some-app.base44.app/api/functions/coralWebhook///abc123/my-agent
```
**Result:**
- Proxies to: `https://some-app.base44.app/api/functions/coralWebhook`
- Headers added:
  - `X-SessionId: abc123`
  - `X-AgentId: my-agent`
#### Notes
- Works with all HTTP methods (GET, POST, PUT, DELETE, etc.)
- Query parameters and request bodies are passed through
- All original headers are preserved
