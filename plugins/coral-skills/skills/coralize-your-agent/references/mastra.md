# Mastra Agent — Coral Integration Guide

This guide walks through connecting a Mastra (TypeScript) agent project to Coral Protocol. By the end, the agent will have coral MCP tools (like `coral_wait_for_mention` and `coral_send_message`) and can participate in multi-agent sessions.

The integration is additive — the agent still works standalone via `npm run dev` (Mastra Studio). Coral tools only activate when the agent is launched by coral-server.

## Overview

Three things are needed to coralize a Mastra agent:

1. **coral-agent.toml** — Agent manifest that coral-server reads to discover and launch the agent
2. **startup.sh** — Shell script that coral-server executes; receives `CORAL_CONNECTION_URL` and starts the Mastra agent
3. **Mastra source changes** — MCPClient connecting to coral, wired into the agent(s), plus a coral-worker entry point

## Step 1: Install the MCP dependency

The `@mastra/mcp` package is required for connecting to coral's MCP server. Add it to the project:

```bash
cd <AGENT_PATH>
npm install @mastra/mcp@latest
```

Also add `tsx` as a dev dependency (used by startup.sh to run the worker entry point):

```bash
npm install --save-dev tsx
```

## Step 2: Create coral-agent.toml

Create `coral-agent.toml` in the project root. This is the manifest that coral-server reads to discover the agent.

Replace `<agent-name>` with a descriptive kebab-case name and update the description to match what the agent does:

```toml
edition = 3

[agent]
name = "<agent-name>"
version = "0.1.0"
description = "<what this agent does>"

readme = "<one-line summary> for Coral Protocol"
summary = "<one-line summary>"

[agent.license]
type = "spdx"
expression = "MIT"

[options.auto_launch]
type = "string"
default = "false"

[runtimes.executable]
path = "bash"
arguments = ["startup.sh"]
transport = "streamable_http"
```

Key fields:
- `name` — How other agents in the coral network will refer to this agent
- `runtimes.executable` — Tells coral-server to run `bash startup.sh` to start the agent
- `transport = "streamable_http"` — The MCP transport protocol used for communication

## Step 3: Create the MCPClient module

Create `src/mastra/mcp/coral-mcp-client.ts`:

```typescript
import { MCPClient } from '@mastra/mcp'

const coralUrl = process.env.CORAL_CONNECTION_URL

export const coralMcpClient = coralUrl
  ? new MCPClient({
      id: 'coral-mcp-client',
      servers: {
        coral: {
          url: new URL(coralUrl),
        },
      },
    })
  : null

export async function getCoralTools() {
  if (!coralMcpClient) return {}
  return await coralMcpClient.listTools()
}
```

How this works:
- When coral-server launches the agent, it sets `CORAL_CONNECTION_URL` as an environment variable pointing to the coral MCP server for this session
- The MCPClient connects to that URL and provides coral tools (like `coral_wait_for_mention`, `coral_send_message`)
- When `CORAL_CONNECTION_URL` is not set (e.g., running locally via `npm run dev`), the client is `null` and `getCoralTools()` returns an empty object — so the agent works normally without coral

## Step 4: Wire coral tools into the agent

For each agent defined in `src/mastra/agents/`, import `getCoralTools` and spread the coral tools into the agent's `tools` config.

Example — if the agent file currently looks like:

```typescript
import { Agent } from '@mastra/core/agent'
import { myTool } from '../tools/my-tool'

export const myAgent = new Agent({
  id: 'my-agent',
  name: 'My Agent',
  instructions: `You are a helpful assistant...`,
  model: 'openai/gpt-5-mini',
  tools: { myTool },
})
```

Update it to:

```typescript
import { Agent } from '@mastra/core/agent'
import { myTool } from '../tools/my-tool'
import { getCoralTools } from '../mcp/coral-mcp-client'

const coralTools = await getCoralTools()

export const myAgent = new Agent({
  id: 'my-agent',
  name: 'My Agent',
  instructions: `You are a helpful assistant...

      ## Coral Multi-Agent Communication

      If you have coral tools available (coral_wait_for_mention, coral_send_message, etc.),
      you are a worker agent in a Coral multi-agent session.

      - Your first action MUST be to call coral_wait_for_mention to receive your task assignment.
      - After completing a task, send a completion message via coral_send_message mentioning the requester.
      - Then call coral_wait_for_mention again to wait for the next task.
      - After every coral_wait_for_mention returns, read coral://state resource to check for missed messages.
      - Do NOT wait for human input when in coral mode. You are fully autonomous.
`,
  model: 'openai/gpt-5-mini',
  tools: { myTool, ...coralTools },
})
```

Key changes:
- Import `getCoralTools` and call it at module level with `await`
- Spread `...coralTools` into the `tools` object alongside existing tools
- Add coral communication instructions to the agent's `instructions` field, explaining how to use `coral_wait_for_mention` and `coral_send_message`

The coral instructions are written conditionally ("if you have coral tools available") so the agent still behaves normally in standalone mode.

## Step 5: Verify the build

Run a type check to make sure everything compiles:

```bash
cd <AGENT_PATH> && npx tsc --noEmit
```

Fix any type errors before proceeding. Common issues:
- Missing `@mastra/mcp` installation (Step 1)
- Incorrect agent key in `coral-worker.ts` (Step 5)
- Top-level `await` requires `"module": "nodenext"` or similar in `tsconfig.json` (Mastra projects already have this)

## Standalone mode

After coralization, the agent still works standalone:

```bash
npm run dev  # Starts Mastra Studio at localhost:4111
```

When running standalone, `CORAL_CONNECTION_URL` is not set, so `getCoralTools()` returns `{}` and the agent works with just its original tools. The coral instructions in the agent's prompt are conditional and won't affect standalone behavior.

## Troubleshooting

### MCP timeout on coral_wait_for_mention

If you see `MCP error -32001: Request timed out`, the MCPClient's default timeout (60s) is too short for `coral_wait_for_mention` which blocks waiting for messages. Increase the timeout in `coral-mcp-client.ts`:

```typescript
export const coralMcpClient = coralUrl
  ? new MCPClient({
      id: 'coral-mcp-client',
      timeout: 1200000, // 20 minutes
      servers: {
        coral: {
          url: new URL(coralUrl),
        },
      },
    })
  : null
```

### Module not found errors in .mastra/output

If `npm run dev` fails with `Cannot find package '@mastra/mcp'`, clear the Mastra build cache and restart:

```bash
rm -rf <AGENT_PATH>/.mastra
npm run dev
```

### Agent appears twice in logs

The `startup.sh` and `coral-worker.ts` both print startup banners. This is one agent with two log statements, not two agents. Remove the banner from `coral-worker.ts` if it's confusing.
