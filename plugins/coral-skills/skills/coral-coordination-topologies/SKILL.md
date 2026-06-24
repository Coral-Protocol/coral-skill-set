---
name: coral-coordination-topologies
description: Use when designing or reviewing how Coral agents should communicate inside a session, including groups, threads, mentions, waits, supervisor patterns, peer networks, pipelines, blackboards, contract-net bidding, debate, handoffs, or multi-agent topology choices.
---

# Coral Coordination Topologies

Use established multi-agent communication patterns as references, then map them onto Coral primitives. Do not invent a topology from "agents can talk to each other" alone.

## Coral Primitives

- **Session**: bounded workspace for one agent graph.
- **Groups**: initial awareness/connectivity between agents.
- **Threads**: task/topic-specific communication spaces.
- **Mentions**: deterministic routing and wake-up signal.
- **Wait tools**: coordination and backpressure.
- **Custom tools**: app boundary, not ordinary agent discussion.
- **Puppet/API**: outside process or user proxy for session control.

## Pick A Topology

Read `references/topologies.md` when the user is choosing or evaluating a coordination structure.

Quick selection:

| Need | Topology |
|---|---|
| Open-ended collaboration among peers | Peer/network graph |
| Central control and clear ownership | Supervisor |
| Teams of specialists with local managers | Hierarchical teams |
| Deterministic stage gates | Pipeline |
| Shared evolving solution state | Blackboard |
| Event-driven loose coupling | Pub-sub/topic routing |
| Task allocation among capable agents | Contract-net/task bidding |
| Robust review or judgment | Debate/critique |
| Localized transfer of control | Handoff/swarm |

## Keep Integration Separate

Topology is about agent-to-agent communication inside Coral. App integration is about who owns session lifecycle, callbacks, state, deployment, and billing.

If the question asks about custom tools, conductors, Cloud, deployment, or app-owned state, also use `coral-app-integration`.
