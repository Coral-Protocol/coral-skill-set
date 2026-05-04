---
name: coralize-your-agent
description: Connect any AI agent project to the Coral Protocol multi-agent network. Use this skill when the user wants to "coralize" an agent, "connect to coral", "add my agent to coral", "register agent with coral", "make my agent work with coral", "coral integration", "coral MCP setup", or mentions integrating their own custom agent (not a built-in one) with Coral Protocol. Currently supports Mastra framework agents, with more frameworks coming soon.
---

# Coralize Your Agent

This skill walks the user through connecting their existing AI agent project to the Coral Protocol, so it can participate in multi-agent sessions alongside other Coral-connected agents.

A single project may contain multiple agents. Each agent gets its own wrapper directory under `~/.coral/agents/<agent-name>/` with a `coral-agent.toml` and `startup.sh`, while the actual agent code stays in the user's project.

Currently supported frameworks:
- **Mastra** (TypeScript)

More frameworks will be added over time.

## Step 0: Check if coral-server is installed

First, verify that coral-server exists:

```bash
test -f ~/.coral/coral-server/gradlew && echo "CORAL_SERVER_OK" || echo "CORAL_SERVER_NOT_FOUND"
```

- If "CORAL_SERVER_OK" -> proceed to Step 1.
- If "CORAL_SERVER_NOT_FOUND" -> tell the user that coral-server must be installed first, then read and follow the sibling skill `coral-setup/SKILL.md` to set it up. After coral-server setup completes, come back here and continue from Step 1.

## Step 1: Ask for the agent project path

Ask the user:
> What's the path to your agent project?

Wait for their response. The path should be an absolute path to a directory containing an agent project.

## Step 2: Detect the agent framework

Go to the provided path and identify the framework. Check the path itself and its parent/child directories for signature files — the user may provide either the project root or a source subdirectory:

```bash
AGENT_PATH="<user-provided-path>"
echo "=== CHECKING FRAMEWORK ===" && \
(test -f "$AGENT_PATH/package.json" && grep -q "@mastra" "$AGENT_PATH/package.json" && echo "FRAMEWORK: mastra") || \
(test -f "$AGENT_PATH/index.ts" && grep -q "@mastra" "$AGENT_PATH/index.ts" && echo "FRAMEWORK: mastra (source dir)") || \
echo "FRAMEWORK: unknown"
```

Detection rules:
- **Mastra**: `package.json` contains `@mastra` dependencies, OR `index.ts` imports from `@mastra` (source directory — the reference guide handles this case)
- **Unknown**: If none of the above match, tell the user their framework isn't supported yet and list what is supported

If the framework is detected, confirm with the user:
> I detected this is a **Mastra** agent project. I'll set it up for Coral integration. Proceed?

Wait for confirmation before continuing.

## Step 3: Apply framework-specific integration

Based on the detected framework, read the corresponding reference guide and follow **all** its steps. The reference guide handles everything end-to-end: validating the project path, installing dependencies, scanning for agents, wiring coral tools, creating the coral worker entry point, checking API keys, and creating wrapper directories under `~/.coral/agents/`.

- **Mastra**: Read `${SKILL_DIR}/references/mastra.md` and follow all steps.

The reference guide will produce a list of agent wrapper paths under `~/.coral/agents/` — carry these forward to Step 4.

## Step 4: Register in coral-server config

Read `~/.coral/coral-server/src/main/resources/config.toml` and add **each** agent's wrapper path to the `local_agents` list under `[registry]`.

Use the Edit tool to update only the `local_agents` line. Do not modify any other part of config.toml. Make sure not to add duplicates — check if any paths are already in the list first.

Example — if you set up 3 agents from a Mastra project:

```toml
local_agents = [...existing..., "/Users/username/.coral/agents/weather-agent", "/Users/username/.coral/agents/coder-agent", "/Users/username/.coral/agents/researcher-agent"]
```

## Step 5: Verify and report

Tell the user:
- How many agents were discovered and set up
- What files were created (in their project and under `~/.coral/agents/`)
- That the agents are now registered with coral-server
- To start (or restart) coral-server with: `cd ~/.coral/coral-server && ./gradlew run`
- The agents will be auto-launched by coral-server when a session requests them
- They can still run their agents standalone without coral — the integration is additive

## Step 6: Offer to try multi-agent orchestration

After reporting the setup results, ask the user:
> Would you like to try running these agents through Coral server? I can help you orchestrate a multi-agent session.

If the user says yes, read the sibling skill at `${SKILL_DIR}/../coral-agent-swarm/SKILL.md` and follow its instructions to set up and run a multi-agent session.
