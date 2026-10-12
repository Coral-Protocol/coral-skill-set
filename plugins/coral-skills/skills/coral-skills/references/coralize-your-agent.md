# Coralize Your Agent

Use current Coral agent/runtime specs as the source of truth. The goal is discovery and runtime wiring, not framework-specific app rewrites.

## Inspect

Ask for the agent project path if it is not already clear.

Then inspect:

```bash
test -f "$AGENT_PATH/coral-agent.toml" && echo "HAS_CORAL_AGENT_TOML" || echo "NO_CORAL_AGENT_TOML"
test -f "$AGENT_PATH/package.json" && echo "HAS_PACKAGE_JSON" || true
find "$AGENT_PATH" -maxdepth 3 -name coral-agent.toml -print
```

If the user provided a source subdirectory, check parent/child directories before concluding there is no manifest.

## Existing Manifest

If the project already has `coral-agent.toml`, prefer one of these discovery mechanisms:

| Mechanism | Use when |
|---|---|
| `npx @coral-protocol/coralizer@latest link .` | Developer wants the agent available to local Coral Servers on this machine. |
| `[registry] localAgents = [...]` in a config file | App, CI, VM, or container deployment should own exactly which agent paths the server scans. |

After linking or configuring, verify through the server registry endpoint or Console rather than assuming the agent loaded.

## MCP Server Or Tool Process

To give Coral agents access to MCP servers, build a Koog agent around them. Do not use Coralizer's `mcp` scaffolding; it generates LangChain or coral-rs projects.

1. Use https://github.com/Coral-Protocol/coral-koog-agent as the reference for project structure, `coral-agent.toml`, options, and the Coral MCP connection. Start a new project with `npm create koog` as shown in `docs/guides/quickstart.md`, or adapt the structure inside the existing repo.
2. Connect the MCP servers as tool sources alongside Coral's own tools. Expose their URLs and credentials as typed options, never `.env` files.
3. Meet the contract in `docs/guides/writing-agents.md`, then make the agent discoverable through `registry.localAgents` or `coralizer link`.

If the MCP servers are reachable over HTTP and a simple LLM tool loop is enough, the prototype runtime can list them under `tools` without code. See `docs/reference/agent/tables/runtimes/prototype.md`.

## No Manifest

If no manifest exists and the project is not an MCP server:

1. Fetch the current server schema with `references/coral-runtime-reference.md`.
2. Read current Coral agent manifest/runtime docs from the running server or source checkout.
3. Add the smallest wrapper or entrypoint needed for the agent runtime to connect to Coral's MCP URL/secret.
4. Add `coral-agent.toml`.
5. Make the manifest discoverable through Coralizer link or config registry.

Do not import framework-specific steps from memory. Use the user's repo and current Coral docs/source.

## Verification

After any integration:

- Confirm the agent path has a valid `coral-agent.toml`.
- Confirm the server can see the agent in its registry.
- Create a minimal session only if the user wants a runtime smoke.
- If the smoke is run, close the session afterward.

## Boundaries

Do not assume:

- Cloud can host arbitrary developer-owned agents;
- one app-specific callback tool exists;
- one conductor backend exists;
- all agents should be copied into `~/.coral/agents`.

Read `references/coral-app-integration.md` for app/conductor/cloud boundaries and `references/coral-setup.md` for server configuration.
