# Plan From Awareness, Then Choose Executors

Use this for natural-language requirements and first-run education. Distributed
awareness means keeping the right bounded knowledge current across a search
space and exposing relevant evidence to decisions. It does not require a cast
of named personas, a process per context, or continuous model calls.

## A Planning Conversation

For “build agents to help with marketing,” ask what decisions and deliverables
matter, what sources support them, how quickly those sources change, and who is
allowed to read or act. Infer answers from the repository first. A useful answer:

> We need current product claims, customer evidence, and channel constraints.
> Keep these as three maintained contexts with evidence links and expiry rules.
> One capable harness with search and document tools can retrieve the relevant
> contexts and draft a campaign. Publication remains an application-controlled
> action. Start there and measure quality, freshness, cost, and completion time.
> Add an observer only if ongoing source changes justify its maintenance cost.

Avoid starting with a CMO, sales representative, social manager, and support
agent. Labels do not establish independent work or new information. Domain
expertise can be a retrieval source, validation rule, or tool in the same harness.

## Produce a Context Map

Write a small application-owned plan before selecting a communication topology:

| Context | Source boundary | Maintained facts and evidence | Freshness/coverage | Consumers and relevance |
|---|---|---|---|---|
| Product claims | Approved catalog and release notes | Supported claims, versioned citations, unresolved contradictions | Refresh on release; report missing products | Campaign drafting; alert only if a claim used in an active draft changes |
| Customer evidence | Consented research for this tenant | Aggregated findings, evidence references, confidence | Daily check; show sampled cohorts and gaps | Campaign drafting; alert on material changes to its selected segment |
| Channel constraints | Approved channel policy sources | Constraints and effective dates | Recheck before publication | Draft validation; notify when a chosen channel's rules invalidate the draft |

These are example policies, not universal polling frequencies. Negotiate staleness
budgets from the decision's needs. Track `checked_at` separately from source
version and last material change: an unchanged source may still be freshly checked.
A failed scan is unknown coverage, not “nothing changed.” Keep unsupported claims
and uncertain relevance visible rather than manufacturing certainty.

A maintained context contains a bounded scope, source references/versions,
evidence pointers, a compact summary, coverage gaps, freshness status, and an
update policy. Consumer subscriptions identify active decisions, required sources,
notification thresholds, and expiry. A context-awareness graph is an
application-level map of these dependencies; it is not the Coral agent graph.
Keep unrelated information out of consumer prompts and threads, even when an
observer can read a larger search space. Summarize with retrievable evidence
instead of broadcasting full source contents.

## Selective Notification

1. Detect candidate changes with source APIs, hooks, scheduled reads, or watchers.
2. Compare source versions; deduplicate repeated observations.
3. Refresh only affected contexts and invalidate claims whose evidence changed.
4. Evaluate relevance against active decisions and explicit subscriptions.
5. Notify with the changed claim, evidence, impact, uncertainty, and required next
   step only when it crosses the threshold. Otherwise update context quietly.
6. Expire or supersede obsolete alerts; consumers verify freshness before acting.

Use deterministic scope and version checks before optional model relevance
classification. Record the reason for notifying or staying quiet. A byte/file hash
is a change detector, not PSI (program structure interface) semantic identity:
comments, moves, renames, and symbol changes require language-aware indexing or
explicit stable IDs if those distinctions matter. Public messaging supplies
neither semantic source identity nor an automatic dependency graph.

## Three Planning Examples

**Small campaign, stable sources.** “Draft an email and landing page from these
five approved documents.” One harness, bounded retrieval, and an in-memory context
map may suffice. Add SQLite only if history or restart recovery matters. No event
bus, containers, or extra model agents are required. Validate claims and measure
time/cost against the existing manual or single-harness workflow.

**Large changing search space.** “Keep a migration plan current across 200 packages
and external dependency notices.” Partition awareness by dependency domain and
source permissions; each context tracks coverage, versions, and evidence. Read-only
watchers update these contexts, and one coding harness subscribes only to the
packages in its current task. Bound scans, summaries, and refresh costs. Notify
about a breaking API used by the plan, but stay quiet about unrelated formatting.
Additional observers can share a worker pool without becoming additional
executors. Compare missed relevant changes and alert noise with broad retrieval.

**Justified multiple executors.** “Validate two independent platform builds and
produce a release recommendation within a short deadline.” Separate executors
can run independent tests with platform-specific dependencies and scoped
credentials, then report results against the same source version. Shared awareness
contexts supply dependency changes to both. Use isolated environments when tests
execute untrusted code. An application gate reconciles evidence and approvals;
no executor receives release authority merely because it is named “release
manager.” Measure parallel latency gains against cost and coordination failures.

## Keep the Two Decisions Independent

| Awareness design | Executor design | When useful |
|---|---|---|
| A few retrieved contexts | One existing harness | Bounded, mostly stable task |
| Many maintained contexts with selective alerts | One existing harness | Broad changing sources, one current line of execution |
| Shared maintained contexts and contract | Multiple harnesses | Independent work, permission separation, isolation, or measured latency benefit |

Use [public-awareness-patterns.md](public-awareness-patterns.md) to implement the
chosen design. Explain which behavior is supplied by Coral, built by the
application/harness, optional, or unavailable as an exact endpoint equivalent.

## Acceptance and Value

Define success before expanding: evidence-backed task correctness, source coverage,
freshness at decision time, missed relevant changes, useful-alert precision,
alert acknowledgement delay, cost per useful decision, and completion latency.
Compare the same inputs and acceptance criteria against one capable harness.
Count uncertainty and stale evidence as failures or explicit blocks, not silent
success. Remove contexts or executors that cost more than the measured benefit.
Run the planning rubrics in `../evaluations/awareness-scenarios.json`; static
fixtures alone cannot demonstrate that a model follows this guidance.
