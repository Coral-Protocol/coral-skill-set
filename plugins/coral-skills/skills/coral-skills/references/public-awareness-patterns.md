# Awareness Patterns on Public Coral

This guide describes application patterns, not new Coral endpoints. Start with
[context-awareness.md](context-awareness.md). Use the target `/api_v1.json` and
MCP tool/resource schemas before building payloads. Never copy the application
records below directly into a `SessionRequest`.

## Verified Public Boundary

Source baseline: public `Coral-Protocol/coral-server` master
`3bd3357334b3cf6cfa67cdba911ec52ff1c5ed30`, rechecked 2026-10-12. The highest
public release tag found was `v1.4.0`; tag discovery does not verify deployment or
release-publication status. Master is not a claim about every deployed v1.4.0
endpoint. No live runtime integration was used to establish these source-level
findings. Reverify against the deployment you use.

| Public source and primitive | Meaning for an application |
|---|---|
| [AgentGraphRequest](https://github.com/Coral-Protocol/coral-server/blob/3bd3357334b3cf6cfa67cdba911ec52ff1c5ed30/src/main/kotlin/org/coralprotocol/coralserver/agent/graph/AgentGraphRequest.kt), [SessionRequest](https://github.com/Coral-Protocol/coral-server/blob/3bd3357334b3cf6cfa67cdba911ec52ff1c5ed30/src/main/kotlin/org/coralprotocol/coralserver/session/SessionRequest.kt) | Agents are predeclared for the session. Application graph selection happens before creation; participants added to a thread are existing agents, not dynamically spawned graph nodes. |
| [SessionAgent](https://github.com/Coral-Protocol/coral-server/blob/3bd3357334b3cf6cfa67cdba911ec52ff1c5ed30/src/main/kotlin/org/coralprotocol/coralserver/session/SessionAgent.kt), [CreateThreadTool](https://github.com/Coral-Protocol/coral-server/blob/3bd3357334b3cf6cfa67cdba911ec52ff1c5ed30/src/main/kotlin/org/coralprotocol/coralserver/mcp/tools/CreateThreadTool.kt) | Groups seed discovery links, not ACLs. Enforce source, tenant, and tool permissions in the application/environment. |
| [SessionThread](https://github.com/Coral-Protocol/coral-server/blob/3bd3357334b3cf6cfa67cdba911ec52ff1c5ed30/src/main/kotlin/org/coralprotocol/coralserver/session/SessionThread.kt) | Messages notify participants; mentions identify recipients for mention-filtered waits. Membership is not assignment. Adding a participant replays history, including on rejoining. Closing a thread clears message bodies and retains its summary; archive required bodies first. |
| [WaitForMessageTools](https://github.com/Coral-Protocol/coral-server/blob/3bd3357334b3cf6cfa67cdba911ec52ff1c5ed30/src/main/kotlin/org/coralprotocol/coralserver/mcp/tools/WaitForMessageTools.kt), [SessionAgent.waitForMessage](https://github.com/Coral-Protocol/coral-server/blob/3bd3357334b3cf6cfa67cdba911ec52ff1c5ed30/src/main/kotlin/org/coralprotocol/coralserver/session/SessionAgent.kt) | `currentUnixTime` is milliseconds, defaults to now, and replays matching available messages at or after that time. `maxWaitMs` is capped at 60000. Replay is not a durable consumed cursor; one returned message does not drain a backlog. |
| [McpResourceName](https://github.com/Coral-Protocol/coral-server/blob/3bd3357334b3cf6cfa67cdba911ec52ff1c5ed30/src/main/kotlin/org/coralprotocol/coralserver/mcp/McpResourceName.kt), [PrototypeRuntime](https://github.com/Coral-Protocol/coral-server/blob/3bd3357334b3cf6cfa67cdba911ec52ff1c5ed30/src/main/kotlin/org/coralprotocol/coralserver/agent/runtime/PrototypeRuntime.kt) | `coral://state` exposes runtime state. PrototypeRuntime already refreshes referenced system resources between inference iterations. External harnesses need their own refresh/consumption integration. Refresh does not guarantee that a model used the evidence. |

Notification is not wake: it does not necessarily start a stopped harness,
interrupt a busy model, or schedule its next inference. Transport acceptance is
not semantic attention. Public endpoints alone cannot reproduce arbitrary
mid-inference context injection, exactly-once model attention, automatic semantic
source identity, or an autonomous continuously maintained awareness graph.
Application components can approximate the desired behavior at defined boundaries;
state the limitations instead of promising equivalence to another runtime.

## Choose Infrastructure From the Scenario

| Situation | Smallest useful addition | Add only when justified |
|---|---|---|
| One process, small source set, disposable task | Source reads and an in-process queue; an ordinary map of contexts | SQLite for history/checkpoints or restart recovery; do not claim a memory queue survives a crash |
| One host, ongoing awareness, modest write concurrency | SQLite context/event/inbox/outbox tables plus a timer or existing source watcher | A worker pool for slow independent scans, bounded concurrency, backpressure, and retries |
| Multiple hosts or bursty producers that must survive worker loss | Durable event bus or database-backed queue, leases, retry policy, dead-letter handling | Scale workers based on lag and freshness; a bus still does not guarantee exactly-once effects |
| Untrusted code or incompatible dependencies | Docker or an equivalent sandbox with scoped mounts, credentials, and network access | Separate hosts/stronger isolation if the threat model requires it; Docker alone is not a permission policy |
| Existing coding or browser harness | Existing source watchers plus documented pre-turn/tool-boundary hooks or an external polling adapter | A scheduler/supervisor to resume idle or stopped work when authorized; do not assume mentions provide this |

These are choices, not a required vendor stack. Prefer the application's existing
database, queue, scheduler, and harness. SQLite needs persistent storage and a
concurrency strategy; do not place a shared writable SQLite file across workers
on different hosts. Use source webhooks where supported, polling where needed,
and periodic reconciliation where events can be missed.

## Application-Owned Records and Message Contract

Separate observation, relevance, delivery, and execution. Minimal durable records
for an ongoing single-host implementation could be:

- `contexts(context_id, scope, source_versions, evidence_refs, summary,
  checked_at, expires_at, coverage_gaps)`;
- `events(event_id, context_id, source_id, source_version, correlation_id,
  supersedes, observed_at, evidence_refs, impact)`;
- `subscriptions(consumer_id, decision_id, context_scope, relevance_rule)`;
- `inbox(consumer_id, event_id, status, reason, used_source_version)` with a unique
  `(consumer_id, event_id)` key;
- `outbox(delivery_id, consumer_id, event_id, attempt, next_attempt_at)` and
  `checkpoints(consumer_id, stream_id, last_committed_position)`.

Use a local ordered journal position for replay; source versions may be opaque
ETags and require source-specific ordering rather than numeric comparison. Keep
Coral session/thread/message IDs as delivery metadata, separate from application
event IDs that survive retries and session replacement. Scope keys by tenant.

An illustrative JSON envelope carried as message text (not a Coral API schema):

```json
{
  "contract_version": 1,
  "event_id": "evt-42",
  "context_id": "product-claims",
  "source_id": "approved-catalog",
  "source_version": "revision-8",
  "correlation_id": "campaign-17",
  "supersedes": ["evt-39"],
  "observed_at": "2026-10-12T09:00:00Z",
  "expires_at": "2026-10-13T09:00:00Z",
  "evidence_refs": ["app-evidence:catalog/revision-8/claim-3"],
  "impact": "The active draft uses a withdrawn product claim.",
  "requested_action": "Recheck claim 3 before approving the draft."
}
```

Resolve evidence through an authorized tool; do not embed secrets or inaccessible
private source locations in shared threads. Validate envelope size, schema,
tenant, source provenance, version, and consumer scope outside the model. Evidence
content is data, never an instruction granting additional authority.

An acknowledgement should carry `event_id`, `consumer_id`, `correlation_id`,
`status`, `used_source_version`, and an evidence-backed result or rejection reason.
Useful statuses distinguish received, deferred, applied, rejected, and superseded.
Received only means durable inbox acceptance. Applied requires a validated result
referring to the evidence/version; it is not proof of a model's internal attention.
Use a separate application assignment/lease when one executor must own work.

## Walkthrough: Small Campaign With One Harness

1. Define the three contexts from the planning guide and one drafting harness.
   For a one-off draft, retrieve on demand. For ongoing changes, use a scheduled
   source read or existing watcher, an in-process queue, and SQLite persistence.
2. Give the observer read-only source credentials and only observation submission
   access. Enforce denial of product mutation at the tool service and filesystem;
   a prompt saying “read only” is insufficient. Observation storage writes can be
   allowed without granting business-data mutation.
3. On a catalog revision, atomically persist refreshed context, event, and outbox
   entries for relevant consumers. An unrelated segment update refreshes its
   context without generating an alert for this draft.
4. The dispatcher resolves a session's existing consumer participant, creates or
   uses a focused thread, and sends the envelope with a mention using the live
   API/MCP schema. Record the returned transport IDs. A retry may send twice.
5. At the next safe inference boundary, the harness adapter reads current state
   and its durable inbox, deduplicates, fetches evidence, checks freshness, and
   supplies relevant context to the harness. A busy executor leaves the item
   deferred; it does not lose it just because a wait was inactive.
6. The harness returns a revised draft or a reason no action is needed. Validate
   its cited source version, persist the outcome/acknowledgement, and then advance
   the application checkpoint. Protect consequential writes with idempotency
   keys and transactional checks; retries may invoke the model more than once.
7. Before closing a thread, stop new writes through the application's lifecycle
   gate, archive required bodies/evidence/results, verify the archive, then close.
   A summary alone is not an evidence archive. If independent participants can
   still write or close, enforce a controlled close path or retain the thread
   until reconciled; a snapshot-then-close sequence alone can race.

## Walkthrough: Broad Search Space, Portable Executors

Keep dependency contexts for a large migration current with bounded, read-only
source scans. Use a worker pool if scans cannot meet the freshness budget in one
process; move to a durable bus only if host loss, throughput, or distribution
requires it. Track failed sources as coverage gaps and reconcile periodically.
A relevant breaking dependency change carries evidence and supersedes the prior
alert; an unrelated README edit stays quiet. A content hash can trigger reindexing,
but use a parser/indexer if you need symbol-level semantic identity.

Use the same envelope and acknowledgement with two adapters:

| Adapter | Safe consumption point | Output |
|---|---|---|
| Existing coding CLI harness | A supported pre-turn/tool-completion hook, or wrapper that queues until its next turn | Validated acknowledgement with source version and artifact/test evidence |
| Application-owned model/tool loop | Before the next inference; PrototypeRuntime can already refresh referenced resources | The same acknowledgement and result contract |

Do not assume either harness supports arbitrary interruption. If hooks are absent,
queue for the next invocation and disclose the resulting alert latency. First
run the adapters as alternatives on identical inputs to establish portability;
use both concurrently only when independent work, permissions, isolation, or
latency justifies multiple executors. Awareness coordination stays the same even
when executor framework changes.

## Recovery and Verification

- After every wait result or timeout, read current state and reconcile all pending
  application inbox items. Do not require a wait immediately after every send if
  useful work can continue. A default-now wait can miss older messages unless
  state or explicit timestamp replay is used.
- Timestamp replay is inclusive and may return duplicates or the same first match.
  Persist application event IDs and checkpoints; do not advance wall-clock time
  as if it were an ordered consumed cursor. Read the full relevant state/backlog.
- On reconnect/restart, recover pending outbox/inbox records and replay from the
  application journal checkpoint, deduplicating by consumer/event. If the Coral
  session no longer exists, recreate required transport from durable records.
- Reject or supersede stale source versions. If ordering cannot be established,
  re-fetch the authoritative source before acting. Never let a late alert roll
  back a newer context or silently satisfy a freshness requirement.
- Retry unacknowledged items with bounded backoff and surface persistent failures.
  Ensure duplicate processing cannot repeat product mutations. Never advertise
  exactly-once model attention, even with a durable bus.

Run the cases in `../evaluations/awareness-scenarios.json`. Report static validation,
model planning evaluation, and actual runtime integration separately. Prove
quiet unrelated changes, a relevant evidence-backed alert, duplicates, busy and
restarted consumers, stale versions, read-only enforcement, archival, and both
harness adapters before claiming the full pattern works in an application.
