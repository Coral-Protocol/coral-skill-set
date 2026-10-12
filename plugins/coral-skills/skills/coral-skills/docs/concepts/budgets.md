# concepts/budgets

Source: https://docs.coralos.ai/concepts/budgets

  ---
title: "Budgets and claims"
description: "Limit what agents claim during a session, and see what they reported."
sidebarTitle: "Budgets and claims"
icon: "wallet"
---

Coral Server tracks spending in a session through budgets and claims. An agent reports each billable action as a claim against a claim type declared in its `coral-agent.toml`. The server prices the claim, deducts it from the agent's budget and then the session's, and applies the configured exhaustion policy.

Budgets are for accounting purposes and don't inherently move any money.

## Units

Budget values and claim costs are integers in **micro cents**.

| Amount | Value |
|---|---|
| USD 1.00 | `100000000` |
| USD 0.01 | `1000000` |

## Session budget

Set the shared budget on [`SessionRequest`](../api-reference/schemas.md#sessionrequest) `budgetSettings`, next to `agentGraphRequest` and `execution`:

```json
{
  "budgetSettings": {
    "budget": 100000000,
    "exhaustionBehavior": { "type": "kill_session" }
  }
}
```

(request fragment, not a complete session request. The session's exhaustion policy applies when a claim leaves the session budget at or below the policy's `minimum`, which defaults to `0`:

| Policy | Effect |
|---|---|
| `kill_agent` (default) | The claiming agent is told to exit. It is stopped if its claim set `autoKill`, which is the default, or the policy sets `"force": true`. |
| `kill_session` | The whole session is stopped after `delay`, 100 ms by default. |
| `ignore` | Claims keep being recorded past zero. |

## Agent budgets

Each agent in the graph can have its own `budgetSettings`:

```json
{
  "budgetSettings": {
    "budget": 10000000,
    "claimTypeCosts": { "FETCH_DOCUMENT": 1000000 },
    "exhaustionBehavior": { "type": "consume_session" }
  }
}
```

An agent's claims come out of its own budget first. Its exhaustion policy determines what happens next:

| Policy | Effect |
|---|---|
| `consume_session` (default) | The rest of the claim comes out of the session budget, and the session's policy applies. |
| `kill` | The agent never draws on the session budget. When its own budget falls to `minimum` or below, it is told to exit, and stopped if the claim set `autoKill` or the policy sets `"force": true`. |

`claimTypeCosts` sets the price of each claim type for this session, overriding the cost in the agent's definition.

> **Warning:**
>
> Both budgets default to zero. If an agent makes priced claims, set a budget: with the default policies, its first priced claim stops it.

## Declaring claim types

An agent declares its claim types in `coral-agent.toml`. Each claim type belongs to a dependency, which groups the options that power it:

```toml
[[dependencies]]
name = "document-service"
options = ["DOCUMENT_API_KEY"]

[[claims]]
name = "FETCH_DOCUMENT"
description = "Fetch one document"
dependency = "document-service"
cost = 1000000
```

- Every option a dependency lists must be defined in the agent's `[options]` table.
- Claim type names start with a letter or underscore, and contain only letters, digits and underscores.
- `cost` is optional. A claim type with no cost in the definition or in `claimTypeCosts` is priced at zero and does not count against any budget.

## Reporting claims

An agent reports a claim to `$CORAL_API_URL/api/v1/agent-rpc/claim`, using `CORAL_AGENT_SECRET` as its bearer token. See [the endpoint reference](../api-reference/endpoints.md#submit-an-agent-claim).

```json
{
  "claimTypeName": "FETCH_DOCUMENT",
  "quantity": 1,
  "additionalDescription": "Fetched document 123",
  "autoKill": false
}
```

- `quantity` multiplies the claim type's cost and defaults to `1`.
- `additionalDescription` is optional and truncated to 256 characters.
- `autoKill` defaults to `true`. Set it to `false` when the agent should handle exhaustion itself. It must then exit when the response's `shouldExit` is `true`. A policy with `"force": true` still stops it.

The response carries a sequential `claimId`, the `requestedAmount` and `fulfilledAmount`, the remaining agent and session budgets, and `shouldExit`.

## Limits of budget enforcement

The server checks a claim only after the agent reports it, and records the claim that crosses a limit in full. Work an agent never claims is not counted. Use the session's TTL as a separate limit on how long it can run.

## Observing usage

The [extended session state](../api-reference/endpoints.md#get-extended-session-state) includes the session's `budgetSettings` and `runningBudget`, every claim in `agentClaimReceipts`, and each agent's own budget state. Session state lives in memory, so record claims in your application if you need durable accounting. A `sessionEnd` [webhook](../concepts/sessions.md#webhooks) with `extendedEndReport` delivers the final state when the session ends.
