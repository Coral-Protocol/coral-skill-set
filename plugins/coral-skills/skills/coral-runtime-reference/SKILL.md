---
name: coral-runtime-reference
description: Use when answering Coral API, OpenAPI schema, endpoint, payload, config, MCP tool, resource, session, namespace, thread, agent manifest, or Coral Server source-of-truth questions.
---

# Coral Runtime Reference

Use this skill to locate the current machine-readable Coral runtime specification. Do not treat skill text as an API reference.

## Source Order

For API shape, use this order:

1. Target running server: `GET $BASE_URL/api_v1.json`.
2. Latest public docs snapshot: `GET https://docs.coralos.ai/api_v1.json`.
3. Local `coral-server` checkout source when generated schema and behavior disagree.
4. Local Cloud source or schema only when the user explicitly has access and the question is Cloud-specific.
5. DeepWiki for repository orientation only, never as schema authority.

`$BASE_URL/ui/docs` is the human Scalar UI over `$BASE_URL/api_v1.json`. Use it when the user asks for docs, but prefer the raw JSON for agent work.

## Machine Ingestion

Fetch once per task and query structurally:

```bash
BASE_URL="${BASE_URL:-http://localhost:5555}"
curl -fsS "$BASE_URL/api_v1.json" > /tmp/coral-api_v1.json
shasum -a 256 /tmp/coral-api_v1.json
jq '.openapi, .info, (.paths | keys), (.components.schemas | keys)' /tmp/coral-api_v1.json
```

When exact payloads matter:

- inspect the endpoint under `.paths`;
- resolve `$ref` entries under `.components.schemas`;
- check required fields and discriminators before sending requests;
- record whether the schema came from local runtime or hosted docs.

Do not paste large OpenAPI documents into the conversation. Extract only the endpoint, method, schema, or field needed for the current task.

## Cloud Schema Stance

Use `https://docs.coralos.ai/api_v1.json` as the public machine-readable baseline for Cloud-facing work when no running target server schema is available.

Cloud Console exports and Cloud runtime behavior can temporarily include fields not yet present in the public schema. Do not strip or reject unknown fields from user-provided Cloud payloads solely because the public snapshot omits them. Preserve fields such as `budgetSettings`, `x402Budgets`, `plugins`, `annotations`, and execution settings unless live validation rejects them.

For Cloud invocation, marketplace agents, billing, LLM proxy, or custom-tool callback behavior, also use `coral-app-integration`.

## Source Fallback

When schema and runtime behavior disagree, inspect the current `coral-server` source:

- REST routes: `src/main/kotlin/org/coralprotocol/coralserver/routes/api/v1/`
- OpenAPI route registration: `src/main/kotlin/org/coralprotocol/coralserver/modules/ktor/`
- session/runtime state: `src/main/kotlin/org/coralprotocol/coralserver/session/`
- MCP tools/resources: `src/main/kotlin/org/coralprotocol/coralserver/mcp/`

Prefer an existing local checkout. Clone the public repo only when no local checkout exists and source inspection is necessary.

## Routing

- Use `coral-setup` for starting or configuring Coral Server.
- Use `coralize-your-agent` for agent discovery and manifest wiring.
- Use `coral-session-control` for REST/Puppet session operation.
- Use `coral-app-integration` for app boundaries, custom tools, Cloud, and deployment wiring.
- Use `coral-coordination-topologies` for communication topology vocabulary.
