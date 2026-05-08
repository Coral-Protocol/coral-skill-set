---
name: coral-encyclopedia
description: Comprehensive Coral Protocol knowledge hub and reference guide. Use this skill whenever the user asks about Coral Protocol concepts, architecture, or configuration — such as "what is a session", "how do threads work", "coral-agent.toml fields", "Coral API endpoints", "coral MCP tools", "agent configuration options", "server configuration", "coral environment variables", "how to write a Coral agent", "coral debugging", "production deployment", "coral resources", "coral coordination patterns", "how do agents communicate", "what is a namespace", or any conceptual/reference question about Coral Protocol. Also use this skill when building or reviewing Coral agents and you need to look up correct API usage, configuration fields, or working code patterns. Do NOT use this skill for installing coral-server (use coral-setup), installing built-in agents (use coral-built-in-agent-setup), connecting a custom agent project (use coralize-your-agent), or running a multi-agent swarm task (use coral-agent-swarm).
---

# Coral Encyclopedia

Comprehensive knowledge hub for Coral Protocol. This skill contains bundled documentation, API reference, and agent development patterns organized in three layers.

## When to use this skill vs. sibling skills

| Question type | This skill? | Or use... |
|---|---|---|
| "What is a session/thread/namespace?" | YES | — |
| "How do I write a Coral agent?" | YES | — |
| "What API endpoints does Coral have?" | YES | — |
| "What fields go in coral-agent.toml?" | YES | — |
| "How do agents communicate via MCP?" | YES | — |
| "Install / start coral-server" | NO | coral-setup |
| "Add Claude Code / Hermes / Puppet" | NO | coral-built-in-agent-setup |
| "Connect my Mastra agent to Coral" | NO | coralize-your-agent |
| "Run a multi-agent task / swarm" | NO | coral-agent-swarm |

When a question has both a conceptual part and an action part, answer the conceptual part here first, then suggest the appropriate sibling skill for the action.

---

## Layer 1: Documentation

Bundled docs live in `${SKILL_DIR}/references/docs/`. Read the relevant file(s) based on the user's question.

### Quick reference — which doc to read

| Topic | File |
|---|---|
| Sessions, namespaces, lifecycle | `docs/concepts/sessions.md` |
| Threads, messages, participants | `docs/concepts/threads.md` |
| MCP tools (coral_*), tool list | `docs/concepts/mcp.md` |
| Multi-agent collaboration patterns | `docs/concepts/coordination.md` |
| Getting started from scratch | `docs/guides/quickstart.md` |
| Writing agents (coral-agent.toml, runtimes) | `docs/guides/writing-agents.md` |
| Debugging sessions and agents | `docs/guides/debugging.md` |
| Coralizer CLI (wrap MCP servers as agents) | `docs/guides/coralizer.md` |
| Custom tools, app integration, webhooks | `docs/guides/integrating-with-your-app.md` |
| Production deployment (Docker, Java) | `docs/guides/running-in-production.md` |
| Agent config reference (all fields) | `docs/reference/agent-config.md` |
| Server config reference (all tables) | `docs/reference/server-config.md` |
| Environment variables | `docs/reference/environment-variables.md` |
| MCP resources (coral://instruction, coral://state) | `docs/features/resources.md` |
| Full API usage guide with examples | `docs/cloud/using-api.md` |

### API Reference

For API endpoint questions, read `${SKILL_DIR}/references/api/api-endpoints-summary.md` first — it covers all endpoints with request/response JSON examples.

For schema details, check `${SKILL_DIR}/references/api/api-schemas-index.md`.

If these are insufficient, the user can access the full interactive OpenAPI spec at `http://localhost:5555/ui/docs` when coral-server is running.

---

## Layer 2: Reference Agents

For questions about writing agents or seeing working code patterns, read files in `${SKILL_DIR}/references/agents/`:

| Need | File |
|---|---|
| Create a new agent from Koog template | `agents/koog-template-guide.md` |
| Complete coral-agent.toml field reference | `agents/reference-agent-toml.md` |
| Worker entry point code patterns | `agents/coral-worker-patterns.md` |

Additional working agent examples on GitHub:
- **Koog (Kotlin)**: https://github.com/Coral-Protocol/coral-koog-agent
- **Awesome agents list**: https://github.com/Coral-Protocol/awesome-agents-for-multi-agent-systems

---

## Layer 3: Source Code Fallback

When bundled docs and examples are not enough to answer a question, clone and read the coral-server source code directly:

```bash
git clone https://github.com/Coral-Protocol/coral-server.git /tmp/coral-server-src
```

Key source directories to look at:
- `src/main/kotlin/org/coralprotocol/coralserver/mcp/` — MCP tool implementations (the actual logic behind coral_* tools)
- `src/main/kotlin/org/coralprotocol/coralserver/session/` — Session and thread management
- `src/main/kotlin/org/coralprotocol/coralserver/api/` — REST API route handlers

If the user already has coral-server installed locally (at `~/.coral/coral-server/`), read the source from there instead of cloning again.

---

## Handling ambiguous questions

If the user's question spans this skill and a sibling skill, answer the conceptual/reference part here, then suggest the sibling. For example:

> "Here's how Coral sessions and threads work [reference answer]. Would you like to set up a multi-agent session now? I can use the coral-agent-swarm skill for that."
