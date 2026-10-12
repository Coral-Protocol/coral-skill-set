# Budgets and payments

Local budget accounting, agent claims, and the distinction from remote settlement.

Source: https://docs.coralos.ai/concepts/payments

Public Coral Server 1.4.0 supports local session budgets and agent claims. These counters are distinct from Coral Cloud billing, marketplace pricing metadata, and on-chain settlement. Configuring a local budget does not itself transfer money.

## Budget units and placement

Budget values use **micro cents**: `100000000` represents USD 1.00 and `1000000` represents USD 0.01. Set the session budget on `SessionRequest.budgetSettings`, alongside `agentGraphRequest` and `execution`:

```json
{
  "budgetSettings": {
    "budget": 100000000,
    "exhaustionBehavior": { "type": "kill_session" }
  }
}
```

This is a request fragment, not a complete session request. Budget settings are separate from `execution.runtimeSettings`, which contains TTL and state-retention settings.

Each `GraphAgentRequest` can also have `budgetSettings`:

```json
{
  "budgetSettings": {
    "budget": 10000000,
    "claimTypeCosts": { "FETCH_DOCUMENT": 1000000 },
    "exhaustionBehavior": { "type": "consume_session" }
  }
}
```

An agent starts with its own budget, then follows its exhaustion policy. `consume_session` allows it to use the shared session budget; `kill` requests that it stop. Session policies are `ignore`, `kill_agent`, and `kill_session`.

Budgets default to zero. The default agent policy is `consume_session`; the default session policy is `kill_agent` with `force = false`. Treat these as accounting/cooperation defaults, not a hard spending ceiling. Forced termination settings, in-flight requests, and claims made after an action affect how closely accounting bounds actual external costs. Set a TTL as a separate lifetime limit.

## Declaring and reporting claims

An agent definition can group options under dependencies and declare named claim types:

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

The referenced option must exist in the agent's `[options]` table. Applications may override a claim type's unit cost through `claimTypeCosts`.

Agents report usage through `POST /api/v1/agent-rpc/claim`, authenticating with `CORAL_AGENT_SECRET` as the bearer token:

```json
{
  "claimTypeName": "FETCH_DOCUMENT",
  "quantity": 1,
  "additionalDescription": "Fetched document 123",
  "autoKill": false
}
```

The response includes the requested and fulfilled amounts, remaining agent/session budgets, and `shouldExit`. An agent that chooses cooperative handling must act on `shouldExit`; application-configured forced termination can still stop it.

Extended session state exposes `runningBudget`, `agentClaimReceipts`, and each agent's budget state. Consume session events or persist application records when you need durable accounting; retained session state is in memory.

## Marketplace and remote settlement

Marketplace pricing describes an agent; it is not proof of a working remote-rental service. Use `provider.type = "local"` for public-server execution. In v1.4.0, the HTTP router registers `POST /api/v1/agent-rental/reserve` and `GET /api/v1/agent-rental/wallet`. Reservation handling is unimplemented; the wallet endpoint returns the configured wallet address or HTTP 403 if none is configured. These endpoints were removed after the v1.4.0 tag and do not provide a working remote-rental flow in that release.

[x402](../features/payments-x402.md) is an experimental, separate integration. Local budget claims should not be presented as a supported end-to-end remote escrow or payout service.
