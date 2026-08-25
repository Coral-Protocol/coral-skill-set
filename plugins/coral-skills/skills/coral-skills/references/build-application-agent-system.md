# Build a Coral Agent System for an Application

Use this when the user wants Coral added to a product or wants an agent graph built, not merely when they ask how one endpoint works. The normal result is an implemented, runnable slice in the user's repository with observable Coral coordination.

## Match the Requested Work

- For a review or architecture question, inspect and explain; do not mutate the app.
- For a build or change request, implement the graph, application integration, and proportional tests.
- For a runtime test, create only the bounded session needed for proof and close it afterward unless the user asks to keep it alive.

Do not stop at a diagram when the user asked for a working system. Do not create external accounts, credentials, paid resources, or production deployments without the required authorization.

## Start From the Application Contract

Before naming agents, establish these facts from the request and repository:

1. **Ingress** — who or what starts the work: a person, API request, scheduled job, event, or another agent.
2. **Outcome** — the result the application must receive, including its format and acceptance rule.
3. **Durable state** — records, artifacts, approvals, and history that must outlive a Coral session.
4. **Capabilities** — data sources, tools, models, browsers, code execution, or specialist knowledge required.
5. **Authority** — which operations are read-only, reversible, approval-gated, or externally consequential.
6. **Operating envelope** — latency, budget, TTL, concurrency, privacy, and failure expectations.

Infer these from the repository where possible. Ask one compact set of questions only when missing answers would materially change the implementation or require new authority.

## Separate Roles From Agent Implementations

A named role does not automatically need its own codebase.

- Reuse one agent implementation with different instance names, descriptions, prompts, options, and tool access when roles share the same runtime and capabilities.
- Create a distinct agent package when it needs different dependencies, credentials, runtime isolation, model policy, tools, or an independently deployable lifecycle.
- Keep deterministic validation, permissions, and product state in application code. Do not delegate invariants to prompts.
- Give each agent a responsibility with a clear completion or escalation condition. Avoid decorative personas that do not change decisions or capabilities.

For a brand-new Coral-native agent, prefer the current official Koog template when it fits the repository:

```bash
npm create koog <agent-name> --packageName=<package.name>
```

Verify the command and requirements against the current `Coral-Protocol/coral-koog-agent` template before running it. Preserve an existing framework when the application already has working agents; Coral can connect those agents without a framework rewrite.

## Design the Communication Graph

Map collaboration onto Coral primitives:

- **Puppet or application API** represents the outside user or process entering the session.
- **Agents** hold responsibilities, capabilities, and local decision authority.
- **Groups** establish initial awareness and allowed collaboration, not chronological stages.
- **Threads** are created around live tasks, questions, proposals, critiques, and handoffs.
- **Mentions** route responsibility and wake the relevant participant.
- **Custom tools** cross the application boundary for controlled reads, writes, callbacks, and final results.

Prefer the least restrictive graph that still respects privacy and tool boundaries. Do not default to a linear pipeline merely because work can be described as steps. Use a pipeline only when deterministic stage gates are the actual requirement. For open-ended team reasoning, use a peer or supervisor-plus-peer graph and allow agents to open focused threads as the work develops.

Create an agent only when at least one is true:

- it contributes distinct expertise or evidence;
- it has unique tool or data access;
- it owns a decision, critique, or approval boundary;
- it needs isolation for cost, security, or failure containment.

Otherwise keep the responsibility inside an existing agent or deterministic application code.

## Make Dynamic Graph Composition Testable

When the application selects specialists from user answers, tenant settings, or task context, introduce an application-owned `AgentSystemSpec` (or equivalent typed object) between product inputs and the Coral session payload. It should describe the intended agents, responsibilities, groups, allowed tools, ingress, result contract, and operating envelope without pretending to be the runtime's `SessionRequest`.

- Normalize product signals before graph selection; do not bury routing rules in a long prompt.
- Keep an explicit allowlist from product signals to registry identities, versions, tools, and policy presets.
- Let an LLM classify ambiguous context or recommend candidates, but let deterministic application policy validate the final graph.
- Record why each specialist was selected so the product and its operators can explain the composition.
- Unit-test representative, edge, and conflicting input combinations against the normalized spec.
- Compile the validated spec into the target runtime's live session schema only at the Coral boundary.

This separation lets the product evolve its graph logic without coupling durable business rules to a changing runtime payload.

## Keep Coral and Application Ownership Clear

Coral owns the ephemeral coordination runtime: graph instantiation, agent connections, groups, threads, messages, mentions, runtime secrets, and session inspection.

The application normally owns users, tenants, source permissions, durable workflow state, artifacts, audit records, product billing, schedules, and published results. Persist important outputs explicitly; do not treat thread history as the only product database.

Use an application conductor when a product needs to:

- create the session for a user or job;
- select agent instances and role options;
- send the initial Puppet or API message;
- receive a structured result through a controlled callback;
- expose progress without leaking private prompts or credentials;
- renew, cancel, or close the session;
- store the durable product result.

## Build From the Live Runtime Contract

Before writing session payloads or client types, read `references/coral-runtime-reference.md` and fetch the target server's `/api_v1.json`. Generate or write only the fields supported by that runtime. Do not rely on a remembered `SessionRequest` shape, manifest edition, registry endpoint, or event schema.

For each agent instance, resolve from the live schema and registry:

- registry identity and version;
- instance name and responsibility;
- runtime/provider selection;
- options and role prompt;
- group membership;
- allowed custom tools;
- budget, blocking behavior, and plugin requirements when supported.

Preserve user- or Console-exported payload fields unless the runtime rejects them.

## Implementation Slice

Adapt the file layout to the application instead of imposing a new framework. A useful first working slice normally includes:

1. **Agent runtime** — a current `coral-agent.toml` plus runnable entrypoint, or a verified existing/marketplace agent.
2. **Graph builder** — application code that compiles product context into agent instances, groups, options, tool access, TTL, and budgets.
3. **Session client** — create, inspect, send, wait/watch, and close operations using the live API contract.
4. **Ingress adapter** — Puppet or API logic that places the user's actual task into the session.
5. **Result contract** — a custom tool or app-owned endpoint for the final structured outcome when the product needs one.
6. **State adapter** — persistence for durable status and artifacts, separate from Coral's session state.
7. **Observability** — session/thread identifiers and useful progress events exposed without secrets.
8. **Tests** — static contract tests plus a bounded runtime smoke when a runtime is available.

Do not create empty abstractions for all eight when the requested slice is smaller. Do not hide a simulated answer behind a healthy-looking connection state.

## Custom Tools and Safety

When agents need to act on the application, read `references/custom-tools.md` before implementing callbacks.

- Give each agent only the custom tools it needs.
- Verify Coral request signatures before processing a callback.
- Validate tenant, session, agent, and resource scope in application code.
- Separate read tools from write tools.
- Require product approvals at the application boundary for consequential writes.
- Return structured, bounded results; never expose provider credentials or raw private source locations to the thread.

## Runtime Proof

Treat a successful build as necessary but insufficient. Verify as much of this chain as the available environment permits:

1. Agent manifests validate and contain no committed secrets.
2. The target Coral registry resolves every requested agent identity and version.
3. A session is created with the intended groups, options, tools, TTL, and budget.
4. Required agents reach a connected or ready state; report partial connection honestly.
5. The real ingress path places a task in the session.
6. At least two participants exchange an actual thread message when collaboration is part of the design.
7. Mentions or handoffs reach the intended agent.
8. The application receives the final result through its real contract.
9. Durable output is stored by the application, not only left in a thread.
10. Timeout, unavailable-agent, invalid-callback, and cancellation paths fail visibly and recover safely.
11. The session closes or follows the requested hold/TTL policy.

Use Coral Console or the session/event API to show the real thread when visual inspection would add confidence. Do not call a graph live based only on a frontend badge, a mocked response, or session creation without connected agents and messages.

## Completion Report

Tell the user:

- what was implemented in the application and agent packages;
- which topology and ownership boundaries were chosen, and why;
- which runtime evidence was observed;
- what remains unverified or needs credentials, Cloud configuration, or deployment authority;
- how to inspect the session or rerun the smoke test.

Keep architecture claims tied to code and live evidence. A designed graph, a registered graph, and a successfully collaborating session are three different completion states.
