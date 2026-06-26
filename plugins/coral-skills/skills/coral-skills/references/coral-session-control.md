# Coral Session Control

Use this reference when an outside process needs to operate a Coral session. This is API wiring, not a recommendation to use multi-agent execution for every task.

For app ownership, custom tools, Cloud, or deployment, also read `references/coral-app-integration.md`. For topology choices, also read `references/coral-coordination-topologies.md`.

## Inputs

Establish these before sending requests:

- `BASE_URL`: server URL, for example `http://localhost:5555`.
- `AUTH_KEY`: bearer token configured for this server.
- `NAMESPACE`: namespace used or created for this session.
- `SESSION_ID`: if operating an existing session.
- `PUPPET_AGENT`: session agent name to use as an external message proxy, if the graph includes one.
- the session request template or agent graph details from the app, console, or OpenAPI schema.

Do not assume `test`, `dev`, `demo`, or `puppet-agent` unless the server/template actually uses those values.

## Preflight

Use the running server schema as the request source of truth:

```bash
curl -fsS "$BASE_URL/api_v1.json" >/dev/null
curl -fsS "$BASE_URL/api_v1.json" > /tmp/coral-api_v1.json
```

If the server is unreachable, read `references/coral-setup.md`. Do not start background services from this reference.

Inspect only the endpoint schemas needed for the task:

```bash
jq '.paths | keys[] | select(test("session|puppet|event|agent-rpc"))' /tmp/coral-api_v1.json
```

## Session Lifecycle

Use the exact path and payload from `/api_v1.json`. For a local session, the usual sequence is:

1. `POST` a session request.
2. Poll extended state until required agents are connected.
3. Create threads or send messages through Puppet/API if an outside controller is used.
4. Poll extended state or watch events until completion/blockage.
5. Close the session when finished.

Do not synthesize a large session template from memory. Prefer a template from Coral Console, the app, tests, or the OpenAPI schema.

Preserve version-sensitive fields in templates unless live validation rejects them. Common fields include top-level `budgetSettings`, per-agent `budgetSettings`, `x402Budgets`, `proxies`, `plugins`, and `annotations`.

## Readiness

```bash
curl -fsS "$BASE_URL/api/v1/local/session/$NAMESPACE/$SESSION_ID/extended" \
  -H "Authorization: Bearer $AUTH_KEY"
```

Check current state fields from the live schema. In current server versions, useful readiness signals include:

- `status.type == "running"`
- `connectionStatus.type == "connected"`
- `communicationStatus.type == "waiting_message"` or `thinking`

If an agent is `stopped`, inspect logs/state before continuing.

## Budgets And Claims

Extended state is also the budget audit surface in current Coral Server versions. When a session stops, exits early, or behaves differently than expected, inspect:

- session `runningBudget` and `budgetSettings`;
- each agent's `runningBudget` and `budgetSettings`;
- `agentClaimReceipts`, including claim type, calculated cost, and sequential claim id.

Budget values are represented in Coral budget units from the live schema, not dollars. Do not infer pricing units from memory.

Agent claim submission uses agent-authenticated RPC endpoints. Outside controllers should usually observe claim receipts through extended state rather than posting claims directly.

## Puppet Messages

When a Puppet-style proxy is part of the graph, use the live Puppet API schema for thread and message requests.

```bash
curl -fsS -X POST "$BASE_URL/api/v1/puppet/$NAMESPACE/$SESSION_ID/$PUPPET_AGENT/thread/message" \
  -H "Authorization: Bearer $AUTH_KEY" \
  -H "Content-Type: application/json" \
  --data @message.json
```

Use explicit mentions when deterministic routing matters.

## Watch And Poll

Events are an optimization. Extended state is the audit surface.

After sending work:

1. Optionally run `${SKILL_DIR}/scripts/watch_coral.sh "$BASE_URL" "$AUTH_KEY" "$NAMESPACE" "$SESSION_ID"`.
2. Always GET the extended session endpoint after the watcher exits.
3. Parse all threads for messages not yet processed.
4. Continue until the task is complete, blocked, or the session should be closed.

Do not run the watcher twice in a row without reading extended state between runs.

## Close

```bash
curl -fsS -X DELETE "$BASE_URL/api/v1/local/session/$NAMESPACE/$SESSION_ID" \
  -H "Authorization: Bearer $AUTH_KEY"
```

If cleanup requires stopping a local process, identify the exact process first. Do not kill broad process patterns.
