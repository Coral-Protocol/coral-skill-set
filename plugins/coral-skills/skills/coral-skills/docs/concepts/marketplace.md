# Marketplace

Discover, publish, and verify agents. How the marketplace integration works.

Source: https://docs.coralos.ai/concepts/marketplace

# Marketplace Integration

The Coral marketplace lets servers discover agents, and lets agent authors publish their agents with optional pricing metadata and identity attestation.

In v1.5.0, the marketplace integration is focused on discovery and metadata. Remote execution and payments are disabled by default (see [Status](#status-v1-5-0)).

## Enable marketplace discovery on your server

Marketplace-backed registry entries are provided by the `MarketplaceAgentRegistrySource`.

- Config entry: `registry.enableMarketplaceAgentRegistrySource` (default: `false`)
- Source of truth: `RegistryConfig.kt` and `MarketplaceAgentRegistrySource.kt`

```toml config.toml
[registry]
enableMarketplaceAgentRegistrySource = true
```

When enabled, Coral Server adds a marketplace source to the local `AgentRegistry` on startup. You can list available agents grouped by registry source via the API:

```bash
curl -H "Authorization: Bearer $CORAL_TOKEN" \
  http://localhost:5555/api/v1/registry | jq
```

## Publishing agents for discovery

Agent authors publish with a standard [`coral-agent.toml`](../reference/agent.md) (edition 5). For marketplace visibility, add pricing metadata under `[marketplace.pricing]`. This metadata is validated during load. Adding the table does not publish an agent or upload its Docker image; those are separate marketplace and container-registry operations.

```toml coral-agent.toml (excerpt)
edition = 5

[agent]
name = "natural-tone-agent"
version = "1.1.0"
description = "An agent that writes in natural, conversational tone"
summary = "Natural tone writing agent"
readme = "An agent for writing natural language content."
license = { type = "spdx", expression = "MIT" }

[marketplace.pricing]
description = "A full markdown description of how the agent is priced"
currency = "USD"

[marketplace.pricing.recommendations]
min = 0.01
max = 1.50
```

Validation limits and field requirements are enforced in the marketplace pricing models (see `RegistryAgentMarketplacePricing` in `RegistryAgent.kt`), as well as core agent validation (name pattern, version semver, description lengths, etc.). If values are invalid, the server rejects the agent with a readable error.

## Identity & attestation (overview)

Marketplace entries can include identity hints (e.g., ERC‑8004 wallet and HTTPS endpoints) to support future remote execution attestation.

- Types and constraints are defined in `RegistryAgentMarketplaceSettings.kt` under `marketplace.identities.erc8004`.
- Endpoints must use HTTPS, names must match the required pattern, and wallet addresses are validated (Base58).

> **Tip:**
>
> Attestation and remote rental are under active development. See Status for current limitations.

## Using marketplace agents in sessions

Even when discovered from the marketplace, agents can still be launched locally on your server (using the image you control). In your `SessionRequest`, reference the source type:

```json
{
  "agentGraphRequest": {
    "agents": [
      {
        "id": {
          "name": "natural-tone-agent",
          "version": "1.1.0",
          "registrySourceId": { "type": "marketplace" }
        },
        "name": "writer",
        "provider": { "type": "local", "runtime": "docker" }
      }
    ],
    "customTools": {}
  }
}
```

The Registry API (`/api/v1/registry/...`) exposes marketplace items side by side with local ones, including option schemas and marketplace metadata.

## Status (v1.5.0)

- Remote providers/payments are disabled. Only `provider.type = "local"` is supported for execution on v1.5.0.
- Pricing metadata does not set session budgets. See [Budgets and claims](../concepts/budgets.md) for local usage accounting.
- Use the marketplace today primarily for discovery and metadata; execution should be local.

See also:

- [Budgets and claims](../concepts/budgets.md)
- [Security](../configuration/security.md)
- [MCP Integration](../concepts/mcp.md)
