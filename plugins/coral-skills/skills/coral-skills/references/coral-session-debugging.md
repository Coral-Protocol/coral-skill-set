# Debugging a Coral Session

Use this reference to inspect or test a session while developing or debugging an agent or an application. In production, an application creates sessions and receives results through custom tools. Nothing in this file belongs in that path.

For app ownership, custom tools, Cloud, or deployment, read `references/coral-app-integration.md` instead.

## Inputs

Establish these before sending requests:

- `BASE_URL`: server URL, for example `http://localhost:5555`.
- `AUTH_KEY`: one of the server's configured auth keys.
- `NAMESPACE` and `SESSION_ID`: the session to inspect, from the create-session response.

Do not assume `test`, `dev`, or `demo` unless the server or template actually uses those values.

## Preflight

Use the running server schema as the request source of truth:

```bash
curl -fsS "$BASE_URL/api_v1.json" > /tmp/coral-api_v1.json
jq '.paths | keys[] | select(test("session|puppet"))' /tmp/coral-api_v1.json
```

If the server is unreachable, read `references/coral-setup.md`. Do not start background services from this reference.

## Creating a Test Session

Build the request the way the application would. Start from a Coral Console template export or the application's own request code, not from memory. `docs/guides/integrating-with-your-app.md` has a minimal request, and `docs/concepts/sessions.md` describes the lifecycle from creation to termination.

The deployed server must already have every agent the request names. If one is missing, fix the deployment's agent configuration; see `references/coral-setup.md`.

## Agent Status

```bash
curl -fsS "$BASE_URL/api/v1/local/session/$NAMESPACE/$SESSION_ID/extended" \
  -H "Authorization: Bearer $AUTH_KEY"
```

Extended state is the audit surface. Useful signals in current server versions:

- `status.type == "running"`;
- `connectionStatus.type == "connected"`;
- `communicationStatus.type` of `waiting_message` or `thinking`.

If an agent is `stopped`, read its logs in Coral Console or the state before changing anything else.

## Budgets and Claims

If an agent stops early, check its budget before its code. Extended state shows:

- the session's `budgetSettings` and `runningBudget`;
- each agent's `budgetSettings` and `runningBudget`;
- every claim in `agentClaimReceipts`, with its claim type, cost, and sequential id.

Budget values are micro cents. `docs/concepts/budgets.md` explains the units, the defaults, and the exhaustion policies. With default settings, an agent's first priced claim stops it.

## Test Messages

Coral Console's Possess action, or the Puppet API, can post messages as one of the session's agents. Use them only to exercise an agent in a test session. An application gives agents their task through options and system prompts, not Puppet messages.

```bash
curl -fsS -X POST "$BASE_URL/api/v1/puppet/$NAMESPACE/$SESSION_ID/$AGENT_NAME/thread/message" \
  -H "Authorization: Bearer $AUTH_KEY" \
  -H "Content-Type: application/json" \
  --data @message.json
```

Take the message body shape from the live schema. Use explicit mentions when you need a specific agent to wake.

## Close

Close test sessions when finished:

```bash
curl -fsS -X DELETE "$BASE_URL/api/v1/local/session/$NAMESPACE/$SESSION_ID" \
  -H "Authorization: Bearer $AUTH_KEY"
```

If cleanup requires stopping a local process, identify the exact process first. Do not kill broad process patterns.
