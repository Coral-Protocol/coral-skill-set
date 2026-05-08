---
title: "Multi-Agent Coordination"
description: "The thread-based communication model for Coral Agents."
sidebarTitle: "Coordination"
icon: "network"
---
Multi-agent coordination in Coral Server is based on a decentralized graph architecture, where agents communicate via a thread-based model. This approach allows agents to collaborate dynamically without a single central controller.
## Thread-Based Communication
Agents in a Coral session are organized into threads. A thread is an isolated communication space where agents can exchange messages, share context, and coordinate their actions.
- **Thread Creation:** Any agent can create a new thread with a specific topic and invite other agents to participate.
- **Message Passing:** Agents send messages to threads. Messages include `text` and optional `mentionNames` to target specific agents.
- **Mentions:** Explicitly mentioning another agent in a message will wake it if it's waiting for mentions, alerting it to a specific task or request.
## Collaboration Patterns
Coral Server's architecture supports various collaboration patterns:
### Dynamic Graph Patterns
In this pattern, the developer does not explicitly plan out every interaction. Agents use their own intelligence to decide which threads to create, who to invite, and what context to share. This is well-suited for complex tasks where the path to a solution isn't fixed.
### Workflow Patterns
Developers can also enforce more structured workflows by providing agents with specific instructions and custom tools that act as checkpoints. This pattern is appropriate for algorithmic tasks where sub-problems are well-defined in advance.
## Coordination Tools
Every agent is given a standard set of MCP tools for coordination (tool IDs are prefixed with `coral_`):
| Tool                       | Purpose                                                                  |
|:---------------------------|:-------------------------------------------------------------------------|
| `coral_create_thread`      | Creates a new thread with a topic and initial participants.              |
| `coral_send_message`       | Sends a message to a thread and mentions other agents.                   |
| `coral_wait_for_mention`   | Suspends agent execution until it is mentioned in any thread.            |
| `coral_wait_for_message`   | Suspends execution until a message matching certain filters is received. |
| `coral_wait_for_agent`     | Suspends until a message arrives from a specific agent.                  |
| `coral_add_participant`    | Adds another agent to an existing thread.                                |
| `coral_remove_participant` | Removes a participant from a thread.                                     |
| `coral_close_thread`       | Closes a thread when work is complete.                                   |
## Why Graph-Based?
Traditional multi-agent systems often use a hierarchical approach, which can lead to bottlenecks and overhead. Coral's graph-based design enables direct agent-to-agent communication, which results in:
- **Higher Throughput:** Multiple agents can run concurrently without blocking.
- **Scalability:** The system scales by adding more intelligent agents rather than making models larger.
- **Safer and More Predictable Systems:** Specialized agents handle smaller, well-defined responsibilities.
For more information on the architecture, see [Coral Server](/concepts/coral-server).
