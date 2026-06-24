---
name: coral-encyclopedia
description: Use when answering Coral Protocol concept, API, configuration, MCP tool, resource, session, namespace, thread, agent manifest, or server reference questions, especially when the answer should be grounded in bundled docs or the live Coral Server docs rather than app-specific examples.
---

# Coral Encyclopedia

Use this as a router to Coral runtime facts. Prefer current Coral Server docs and schemas over copied explanations whenever they are available.

## Source Order

1. If a Coral Server is running, use the live docs at `http://localhost:5555/ui/docs` and schema at `http://localhost:5555/api_v1.json`.
2. If a local Coral Server checkout is available, inspect its source for behavior that is not clear from docs.
3. Use the bundled docs in `${SKILL_DIR}/references/docs/` for offline orientation and stable concepts.
4. Use the bundled API summaries in `${SKILL_DIR}/references/api/` for endpoint discovery, then verify against live docs when exact payload shape matters.

Do not treat this skill as an alternate product spec. If docs and current server behavior differ, state the difference and prefer current runtime behavior.

## Skill Routing

| Need | Use |
|---|---|
| Sessions, namespaces, threads, MCP tools, API schemas, resources, agent config | `coral-encyclopedia` |
| Install/start/inspect Coral Server | `coral-setup` |
| Link or wrap a developer-owned agent | `coralize-your-agent` |
| Install bundled example agents | `coral-built-in-agent-setup` |
| Drive a session through REST/Puppet APIs | `coral-agent-swarm` |
| Wire Coral into an app backend, self-hosted service, Cloud-assisted flow, callbacks, custom tools, session ownership | `coral-app-integration` |
| Choose multi-agent communication topology or map known MAS patterns onto Coral primitives | `coral-coordination-topologies` |

When a user asks a mixed question, answer the factual Coral concept here, then load the sibling skill for the integration or topology decision.

## Bundled Docs

Bundled docs live in `${SKILL_DIR}/references/docs/`. Read the relevant file based on the user's question.

| Topic | File |
|---|---|
| Sessions, namespaces, lifecycle | `docs/concepts/sessions.md` |
| Threads, messages, participants | `docs/concepts/threads.md` |
| MCP tools (coral_*), tool list | `docs/concepts/mcp.md` |
| Coral's thread-based coordination model | `docs/concepts/coordination.md` |
| Getting started from scratch | `docs/guides/quickstart.md` |
| Writing agents (coral-agent.toml, runtimes) | `docs/guides/writing-agents.md` |
| Debugging sessions and agents | `docs/guides/debugging.md` |
| Coralizer CLI (wrap MCP servers as agents) | `docs/guides/coralizer.md` |
| Custom tools, app integration, webhooks | `docs/guides/integrating-with-your-app.md` |
| Production deployment (Docker, Java) | `docs/guides/running-in-production.md` |
| Agent config reference | `docs/reference/agent-config.md` |
| Server config reference | `docs/reference/server-config.md` |
| Environment variables | `docs/reference/environment-variables.md` |
| MCP resources (`coral://instruction`, `coral://state`) | `docs/features/resources.md` |
| Cloud API usage snapshot | `docs/cloud/using-api.md` |

## API Reference

For endpoint questions, read `${SKILL_DIR}/references/api/api-endpoints-summary.md` first.

For schema details, check `${SKILL_DIR}/references/api/api-schemas-index.md`.

If exact payloads matter, verify against `http://localhost:5555/ui/docs` or `http://localhost:5555/api_v1.json` from the running server.

## Reference Agents

For questions about writing agents or seeing working code patterns, read files in `${SKILL_DIR}/references/agents/`:

| Need | File |
|---|---|
| Create a new agent from Koog template | `agents/koog-template-guide.md` |
| Complete coral-agent.toml field reference | `agents/reference-agent-toml.md` |
| Worker entry point code patterns | `agents/coral-worker-patterns.md` |

Additional public examples:

- Koog (Kotlin): https://github.com/Coral-Protocol/coral-koog-agent
- Awesome agents list: https://github.com/Coral-Protocol/awesome-agents-for-multi-agent-systems

## Source Fallback

When bundled docs and examples are not enough, inspect Coral Server source directly:

```bash
git clone https://github.com/Coral-Protocol/coral-server.git /tmp/coral-server-src
```

Useful source directories:

- `src/main/kotlin/org/coralprotocol/coralserver/mcp/`
- `src/main/kotlin/org/coralprotocol/coralserver/session/`
- `src/main/kotlin/org/coralprotocol/coralserver/routes/`

If the user already has Coral Server installed locally, prefer that checkout over cloning another copy.
