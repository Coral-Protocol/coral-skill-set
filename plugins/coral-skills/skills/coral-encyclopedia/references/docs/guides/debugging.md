---
title: "Debugging"
description: "How to debug agents & sessions in Coral Server using built-in tools and the Puppet API."
sidebarTitle: "Debugging"
icon: "bug"
tag: "NEW"
---
Coral provides several tools and techniques to help you debug your agents during development. These tools allow you to inspect the communication between agents, identify issues, and test individual components in isolation.
## Debugging with Coral Console
The [Coral Console](/concepts/coral-console) is the easiest way to debug agents during development. It provides a real-time view of all agent interactions:
- **Thread View:** See all messages sent and received in every thread, including agent-to-agent communication.
- **Real-time Logs:** View the execution logs from every agent process.
- **Agent Status:** Monitor the status of every agent (listening, busy, dead, etc.) in real-time.
- **Agent Possession:** Take control of any agent and act on their behalf (via the [Puppet API](#puppet-api))
## Puppet API
The **Puppet API** allows an external application (like your own app or a debugging script) to "puppet" an agent.
This means you can perform any action on behalf of a specific agent instance in a session.
> **Tip:** 
You can also use the Puppet API via [Coral Console](/concepts/coral-console), by clicking "Possess" on any agent in a session
![Possess agent dropdown](/images/console/possess-agent.png)
For more details on the Puppet API endpoints, see the [API Reference](/api-reference/puppet).
## Built-in Debug Agents
Coral Server includes several built-in agents that we use internally for testing and debugging:
> **Info:** All of these agents are hardcoded - they do **not** make any LLM completion requests
### `echo`
- Automatically responds to any message it receives in its lifetime.
### `tool`
- Calls a given tool when started.
- Useful for testing custom tools or for kick starting activity in other agents.
### `seed`
- Automatically sends messages across a given number of threads at a set interval.
### `puppet`
- Does nothing on its own.
- Serves as a "socket" for easily interacting with your session via the Puppet API.
To include these agents in a session, reference them in your [`GraphAgentRequest`](/api-reference/models/GraphAgentRequest) like any other agent.
## Common Debugging Scenarios
### Verifying Agent Connections
If an agent is not responding, check the agent's status in [Coral Console](/concepts/coral-console) to ensure that the agent has successfully been started & connected to the Coral Server's MCP. If the status is `Not connected` or `Stopped`, check the agent logs for errors.
### Isolating Agent Interactions
To test an individual agent's logic, create a session that includes only that agent and one or more debug agents (like the [`puppet` agent](#puppet)). This allows you to test the agent's behavior in a controlled environment without the complexity of a full multi-agent graph.
