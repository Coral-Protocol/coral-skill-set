# Multi-Agent Topologies For Coral

Use these as design references. They are not Coral product requirements.

## Peer / Network Graph

All relevant agents can discover or directly communicate with each other.

Map to Coral:

- Put peers in the same group.
- Let agents create threads for subtopics.
- Use mentions to route work and wake agents.

Use for exploratory research, creative synthesis, and tasks without a fixed decomposition.

Watch for context sprawl, duplicated work, and unclear termination.

## Supervisor

A manager agent delegates to workers and synthesizes results.

Map to Coral:

- Put the supervisor in groups with all workers.
- Workers may only need threads with the supervisor.
- Give the supervisor responsibility for closing threads or calling final custom tools.

Use for controllability, auditability, or user-facing orchestration.

Watch for supervisor bottlenecks and lossy summarization of worker results.

## Hierarchical Teams

Supervisors manage subteams; a top-level supervisor coordinates team outputs.

Map to Coral:

- Use groups to encode subteam visibility.
- Use separate threads for subteam work and cross-team handoff.
- Keep final synthesis owned by a top-level manager or app conductor.

Use for broad tasks with separable workstreams.

Watch for slow escalation and over-summarized intermediate context.

## Pipeline

Work moves through fixed stages.

Map to Coral:

- The app conductor or a manager agent creates stage-specific threads.
- Each stage has explicit entry criteria and output shape.
- Custom tools or app state can enforce stage gates.

Use for compliance, extraction, enrichment, deterministic review, and repeatable production workflows.

Watch for brittle handoffs when upstream output is ambiguous.

## Blackboard

Agents contribute opportunistically to shared external state.

Map to Coral:

- Keep the blackboard in app-owned storage, not in thread history alone.
- Expose read/write operations through custom tools or app APIs.
- Use threads for negotiation and explanation around blackboard updates.

Use for open-ended problem solving with partial hypotheses, evidence, or artifacts.

Watch for conflict resolution, stale reads, and unclear ownership of final state.

## Pub-Sub / Topic Routing

Agents publish and react to topic-specific events.

Map to Coral:

- Use threads as topic channels.
- Use mentions or app/Puppet messages as deterministic wake-up signals.
- Consider one topic per durable workstream rather than one giant thread.

Use for event-driven flows and loosely coupled specialists.

Watch for missed wake-ups if agents rely on passive reading instead of waits/mentions.

## Contract-Net / Task Bidding

An announcer offers work; candidate agents bid; one or more are awarded the task.

Map to Coral:

- Announcer creates a task thread.
- Candidate agents reply with capability/cost/plan.
- Announcer mentions selected agents and records the award.

Use when capability, cost, or load varies by agent.

Watch for negotiation overhead on small tasks.

## Debate / Critique

Agents produce independent arguments or reviews before synthesis.

Map to Coral:

- Use separate proposal and critique threads when independence matters.
- Use a judge/synthesizer agent or app conductor to decide.
- Preserve dissent if the output is audit-sensitive.

Use for design review, risk analysis, adversarial reasoning, and quality gates.

Watch for performative disagreement and runaway rounds.

## Handoff / Swarm

Agents locally decide which agent should take over next.

Map to Coral:

- Encode allowed handoffs in agent prompts/descriptions.
- Use mentions as transfer signals.
- Keep a visible thread trail of why control moved.

Use when local expertise should determine routing.

Watch for loops and loss of termination criteria.

## External References

- LangGraph multi-agent architectures: https://github.com/langchain-ai/langgraphjs/blob/a0964fbd/docs/docs/concepts/multi_agent.md
- LangChain multi-agent patterns: https://docs.langchain.com/oss/python/langchain/multi-agent
- AutoGen group chat: https://microsoft.github.io/autogen/dev/user-guide/core-user-guide/design-patterns/group-chat.html
- AutoGen handoffs: https://microsoft.github.io/autogen/stable/user-guide/core-user-guide/design-patterns/handoffs.html
- Blackboard systems, Nii 1986: http://i.stanford.edu/pub/cstr/reports/cs/tr/86/1123/CS-TR-86-1123.pdf
- Contract Net Protocol, Smith 1980: https://dl.acm.org/doi/10.1109/TC.1980.1675516
