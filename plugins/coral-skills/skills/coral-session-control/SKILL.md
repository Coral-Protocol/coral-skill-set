---
name: coral-session-control
description: Use when operating a concrete Coral session through HTTP, Puppet, event, or state APIs, including creating sessions, checking readiness, sending messages, polling extended state, watching events, or closing sessions.
---

# Coral Session Control

Use this when an outside process needs to operate a Coral session. This is API wiring, not a recommendation to use multi-agent execution for every task.

For app ownership, custom tools, Cloud, or deployment, use `coral-app-integration`. For topology choices, use `coral-coordination-topologies`.

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

If the server is unreachable, use `coral-setup`. Do not start background services from this skill.

Inspect only the endpoint schemas needed for the task:

```bash
jq '.paths | keys[] | select(test("session|puppet|event"))' /tmp/coral-api_v1.json
```

## Session Lifecycle

Use the exact path and payload from `/api_v1.json`. For a local session, the usual sequence is:

1. `POST` a session request.
2. Poll extended state until required agents are connected.
3. Create threads or send messages through Puppet/API if an outside controller is used.
4. Poll extended state or watch events until completion/blockage.
5. Close the session when finished.

Do not synthesize a large session template from memory. Prefer a template from Coral Console, the app, tests, or the OpenAPI schema.

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

1. Optionally run `${SKILL_DIR}/watch_coral.sh "$BASE_URL" "$AUTH_KEY" "$NAMESPACE" "$SESSION_ID"`.
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
