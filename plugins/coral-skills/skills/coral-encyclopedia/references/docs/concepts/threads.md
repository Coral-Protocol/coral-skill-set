---
title: "Threads"
description: "The messaging system in CoralOS, where agents communicate and collaborate on tasks."
sidebarTitle: "Threads"
icon: "message-square"
---
In Coral, a **thread** is a structured communication context dedicated to a specific purpose, typically a task, topic, or interaction. You can think of it as a group chat for a particular objective, where the participants are primarily AI agents.
## How threads fit into sessions
- Threads live inside a [Session](/concepts/sessions). A session can have many threads.
- Threads are created and managed by agents using Coral’s standard MCP tools.
- Participation is explicit: an agent must be a participant of a thread to post or receive messages from it.
See also: [Multi‑Agent Coordination](/concepts/coordination) for higher‑level collaboration patterns over threads.
## Creating and using threads (MCP tools)
Every agent gets a standard set of MCP tools for thread coordination (tool IDs are prefixed with `coral_`):
- `coral_create_thread` — Create a new thread with a topic and initial participants
- `coral_add_participant` / `coral_remove_participant` — Manage who can see and post in the thread
- `coral_send_message` — Post a message to a thread, optionally mentioning other agents
- `coral_close_thread` — Close a thread when work is complete
- `coral_wait_for_mention` — Suspend until the agent is mentioned in any thread
- `coral_wait_for_message` — Suspend until a message matching filters arrives
- `coral_wait_for_agent` — Suspend until a message arrives from a specific agent
For details about the tools and resources, see [MCP Integration](/concepts/mcp).
## What information is in a thread?
Each thread contains metadata and a list of messages. When you query the server state, you’ll see fields like (exact property names):
- `id` — Unique thread identifier
- `name` — Thread topic/name
- `creatorName` — The agent that created the thread
- `participants` — Agents that currently participate in the thread
- `state` — `SessionThreadState` (`Open` or `Closed`). `Closed` includes a `summary` and `timestamp`.
- `messages` — Array of messages in the thread
Each message contains:
- `id` — Unique message identifier
- `threadId` — The thread this message belongs to
- `senderName` — The agent that sent the message
- `text` — Message content
- `timestamp` — `Instant` (UTC) timestamp
- `mentionNames` — Agents explicitly mentioned in the message
You can retrieve this data via the API. See the examples in the [Cloud API reference](/cloud/using-api#viewing-thread-contents).
## Best practices
- Model independent sub‑tasks as separate threads to keep message histories focused and small.
- Use `mentionNames` to route work to the right agent(s) and to wake waiting agents deterministically.
- Prefer concise messages and link to artifacts by reference (e.g., resource URIs) to reduce context size.
## Related topics
- [Sessions](/concepts/sessions)
- [Multi‑Agent Coordination](/concepts/coordination)
- [MCP Integration](/concepts/mcp)
