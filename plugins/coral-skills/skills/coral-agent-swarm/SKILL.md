---
name: coral-agent-swarm
description: Use when driving a concrete Coral session through HTTP or Puppet APIs, including creating sessions, checking agent readiness, creating threads, sending messages, polling extended state, watching events, closing sessions, or coordinating agents without direct Coral MCP tools.
---

# Coral Agent Session Control

Use this when you need to operate a Coral session from outside the agents. This skill is API wiring, not a recommendation that every task should become a swarm.

For topology decisions, use `coral-coordination-topologies`. For app/conductor ownership, custom tools, or Cloud behavior, use `coral-app-integration`.

## Inputs To Establish

Before making requests, identify:

- `BASE_URL`: server URL, for example `http://localhost:5555`.
- `AUTH_KEY`: bearer token configured for this server.
- `NAMESPACE`: namespace used or created for this session.
- `SESSION_ID`: if operating an existing session.
- `PUPPET_AGENT`: agent name to use as the external message proxy, if Puppet is in the graph.
- agent registry identifiers, runtimes, options, and groups from live `/ui/docs`, `/api_v1.json`, or the user's template.

Do not assume `test`, `dev`, `demo`, or `puppet-agent` unless the server/template actually uses those values.

## Preflight

Check server readiness:

```bash
curl -fsS "$BASE_URL/api_v1.json" >/dev/null
```

If the server is not reachable, use `coral-setup`. Do not start background services from this skill.

Inspect available APIs and schemas:

```bash
echo "Docs: $BASE_URL/ui/docs"
curl -fsS "$BASE_URL/api_v1.json" > /tmp/coral-api_v1.json
```

Use the running server schema as the source of truth for payload shape.

## Create A Session

Create sessions through `POST /api/v1/local/session`. Use the JSON from Coral Console templates or `/ui/docs` when possible.

Minimal shape:

```bash
curl -fsS -X POST "$BASE_URL/api/v1/local/session" \
  -H "Authorization: Bearer $AUTH_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "agentGraphRequest": {
      "agents": [
        {
          "id": {
            "name": "<agent-name>",
            "version": "<agent-version>",
            "registrySourceId": {"type": "local"}
          },
          "name": "<session-agent-name>",
          "provider": {"type": "local", "runtime": "<runtime>"}
        }
      ],
      "groups": [["<session-agent-name>"]]
    },
    "namespaceProvider": {
      "type": "create_if_not_exists",
      "namespaceRequest": {"name": "<namespace>", "deleteOnLastSessionExit": false}
    },
    "execution": {
      "mode": "immediate",
      "runtimeSettings": {"ttl": 300000}
    }
  }'
```

Cloud may require additional budget/runtime settings. Use `coral-app-integration` for Cloud behavior.

## Wait For Readiness

Do not send task messages until target agents are connected.

Poll extended state:

```bash
curl -fsS "$BASE_URL/api/v1/local/session/$NAMESPACE/$SESSION_ID/extended" \
  -H "Authorization: Bearer $AUTH_KEY"
```

Treat these as ready enough to receive messages:

- `status.type == "running"`
- `connectionStatus.type == "connected"`
- `communicationStatus.type == "waiting_message"` or `thinking`

If an agent is `stopped`, inspect logs/state before continuing.

## Communicate Through Puppet/API

If a Puppet-style proxy agent is in the session, create a thread:

```bash
curl -fsS -X POST "$BASE_URL/api/v1/puppet/$NAMESPACE/$SESSION_ID/$PUPPET_AGENT/thread" \
  -H "Authorization: Bearer $AUTH_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "threadName": "<topic>",
    "participantNames": ["<agent-a>", "<agent-b>", "<puppet-agent>"]
  }'
```

Send messages with explicit mentions when you need deterministic wake-up/routing:

```bash
curl -fsS -X POST "$BASE_URL/api/v1/puppet/$NAMESPACE/$SESSION_ID/$PUPPET_AGENT/thread/message" \
  -H "Authorization: Bearer $AUTH_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "threadId": "<thread-id>",
    "content": "Please handle this task. @agent-a",
    "mentions": ["agent-a"]
  }'
```

Use the exact Puppet endpoint names and request body from the running server docs if they differ.

## Watch And Poll

The event stream is an optimization. The extended state endpoint is the source of truth.

After sending a message:

1. Optionally run `${SKILL_DIR}/watch_coral.sh "$BASE_URL" "$AUTH_KEY" "$NAMESPACE" "$SESSION_ID"`.
2. Always GET the extended session endpoint after the watcher exits.
3. Parse all threads for messages not yet processed.
4. Continue until the task is complete, blocked, or the session should be closed.

Never run the watcher twice in a row without reading extended state between runs.

## Close Or Clean Up

Close the session through the API when the work is done:

```bash
curl -fsS -X DELETE "$BASE_URL/api/v1/local/session/$NAMESPACE/$SESSION_ID" \
  -H "Authorization: Bearer $AUTH_KEY"
```

Do not kill broad process patterns. If a local agent process remains and the user wants it stopped, identify the exact process first and stop only that process.
