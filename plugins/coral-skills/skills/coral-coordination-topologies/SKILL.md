---
name: coral-coordination-topologies
description: Use when designing or reviewing how Coral agents should communicate inside a session, including groups, threads, mentions, waits, supervisor patterns, peer networks, pipelines, blackboards, contract-net bidding, debate, handoffs, or multi-agent topology choices.
---

# Coral Coordination Topologies

Use this as communication vocabulary for mapping a required collaboration shape onto Coral primitives. It is not an app-design recommendation engine.

## Coral Primitives

- **Session**: bounded workspace for one agent graph.
- **Groups**: initial awareness/connectivity between agents.
- **Threads**: task/topic-specific communication spaces.
- **Mentions**: deterministic routing and wake-up signal.
- **Wait tools**: coordination and backpressure.
- **Custom tools**: app boundary, not ordinary agent discussion.
- **Puppet/API**: outside process or user proxy for session control.

## Reference

Read `references/topologies.md` when the user is choosing or evaluating a coordination structure.

Fast mapping:

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
| Localized transfer of control | Handoff |

## Keep Integration Separate

Topology is agent-to-agent communication inside a session. App integration is session ownership, callbacks, state, deployment, and billing.

If the question asks about custom tools, conductors, Cloud, deployment, or app-owned state, also use `coral-app-integration`.
