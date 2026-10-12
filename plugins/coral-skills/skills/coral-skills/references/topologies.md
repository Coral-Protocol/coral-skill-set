# Multi-Agent Topologies For Coral

Use these as communication vocabulary. These describe communication, not an org chart or a reason to create more agents. Start with bounded awareness contexts and one capable harness; justify multiple executors independently. Pick only when the user's problem or repo already implies the shape.

## Peer / Network Graph

All relevant agents can discover or directly communicate with each other.

Map to Coral:

- Put peers in the same group.
- Let agents create threads for subtopics.
- Use mentions to target notifications; use application acknowledgements for assignment.

## Supervisor

A manager agent delegates to workers and synthesizes results.

Map to Coral:

- Put the supervisor in groups with all workers.
- Workers may only need threads with the supervisor.
- If final callbacks exist, grant them through explicit custom tool access.

## Hierarchical Teams

Supervisors manage subteams; a top-level supervisor coordinates team outputs.

Map to Coral:

- Use groups to seed subteam discovery, never enforce access control.
- Use separate threads for subteam work and cross-team handoff.

## Pipeline

Work moves through fixed stages.

Map to Coral:

- A conductor or manager creates stage-specific threads.
- Enforce stage gates in application code or controlled custom tools.
- Durable stage state should be external if it must outlive the session.

## Blackboard

Agents contribute opportunistically to shared external state.

Map to Coral:

- Keep the blackboard in app-owned storage, not in thread history alone.
- Expose read/write operations through custom tools or app APIs.
- Use threads for negotiation and explanation around blackboard updates.

## Pub-Sub / Topic Routing

Agents publish and react to topic-specific events.

Map to Coral:

- Use threads as topic channels.
- Use mentions or app/Puppet messages as notification signals; harness scheduling and consumption remain separate.
- Consider one topic per durable workstream rather than one giant thread.

## Contract-Net / Task Bidding

An announcer offers work; candidate agents bid; one or more are awarded the task.

Map to Coral:

- Announcer creates a task thread.
- Candidate agents reply with capability/cost/plan.
- Announcer mentions selected agents and records the award.

## Debate / Critique

Agents produce independent arguments or reviews before synthesis.

Map to Coral:

- Use separate proposal and critique threads when independence matters.
- Use a judge/synthesizer agent or app conductor to decide.
- Preserve dissent if the output is audit-sensitive.

## Handoff

Agents locally decide which agent should take over next.

Map to Coral:

- Describe handoff intent in prompts; enforce allowed assignments and permissions in application code.
- Use mentions as transfer signals.
- Keep a visible thread trail of why control moved.

## External References

- LangGraph multi-agent architectures: https://github.com/langchain-ai/langgraphjs/blob/a0964fbd/docs/docs/concepts/multi_agent.md
- LangChain multi-agent patterns: https://docs.langchain.com/oss/python/langchain/multi-agent
- AutoGen group chat: https://microsoft.github.io/autogen/dev/user-guide/core-user-guide/design-patterns/group-chat.html
- AutoGen handoffs: https://microsoft.github.io/autogen/stable/user-guide/core-user-guide/design-patterns/handoffs.html
- Blackboard systems, Nii 1986: http://i.stanford.edu/pub/cstr/reports/cs/tr/86/1123/CS-TR-86-1123.pdf
- Contract Net Protocol, Smith 1980: https://dl.acm.org/doi/10.1109/TC.1980.1675516
