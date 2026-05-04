# Mastra Agent — Coral Integration Guide

This guide walks through connecting a Mastra (TypeScript) agent project to Coral Protocol. By the end, the agent will have coral MCP tools (like `coral_wait_for_mention` and `coral_send_message`) and can participate in multi-agent sessions.

The integration is additive — the agent still works standalone via `npm run dev` (Mastra Studio). Coral tools only activate when the agent is launched by coral-server.

## Overview

Three things are needed to coralize a Mastra agent:

1. **coral-agent.toml** — Agent manifest that coral-server reads to discover and launch the agent
2. **startup.sh** — Shell script that coral-server executes; receives `CORAL_CONNECTION_URL` and starts the Mastra agent
3. **Mastra source changes** — MCPClient connecting to coral, wired into the agent(s), plus a coral-worker entry point

## Step 1: Validate the project path

The user may provide either a project root (has `package.json`) or a bare source directory (e.g., just the `src/mastra/` folder). You must handle both cases.

```bash
AGENT_PATH="<user-provided-path>"
echo "=== PATH VALIDATION ===" && \
(test -f "$AGENT_PATH/package.json" && echo "HAS_PACKAGE_JSON") || echo "NO_PACKAGE_JSON" && \
(test -d "$AGENT_PATH/node_modules" && echo "HAS_NODE_MODULES") || echo "NO_NODE_MODULES" && \
(test -f "$AGENT_PATH/tsconfig.json" && echo "HAS_TSCONFIG") || echo "NO_TSCONFIG" && \
(test -f "$AGENT_PATH/index.ts" && grep -q "@mastra" "$AGENT_PATH/index.ts" 2>/dev/null && echo "HAS_MASTRA_INDEX") || echo "NO_MASTRA_INDEX"
```

### Case A: Project root (HAS_PACKAGE_JSON)

The path is a valid project root. Set `PROJECT_ROOT="$AGENT_PATH"` and proceed to Step 2.

If `NO_NODE_MODULES`, run `cd "$PROJECT_ROOT" && npm install` before proceeding.

### Case B: Source directory only (NO_PACKAGE_JSON + HAS_MASTRA_INDEX)

The user provided a bare `src/mastra/` directory. Create a project wrapper:

1. Create the wrapper directory:
   ```bash
   PROJECT_ROOT="<AGENT_PATH>-project"
   mkdir -p "$PROJECT_ROOT/src"
   ```

2. **Copy** the source files into the wrapper. **NEVER use symlinks** — tsx resolves physical file paths to find the nearest `package.json` for ESM/CJS mode. Symlinked files will be resolved to their physical location, where there is no `package.json`, causing tsx to default to CJS mode. This breaks top-level `await` with: `"Top-level await is currently not supported with the 'cjs' output format"`. Even adding a `{"type":"module"}` package.json at the physical path doesn't fully fix it, because `node_modules` resolution also follows the physical path.

   ```bash
   cp -r "$AGENT_PATH" "$PROJECT_ROOT/src/mastra"
   ```

3. Create `package.json`:
   ```json
   {
     "name": "mastra-agents",
     "version": "1.0.0",
     "type": "module",
     "scripts": {
       "dev": "mastra dev",
       "build": "mastra build"
     },
     "dependencies": {
       "@mastra/core": "^1.28.0",
       "@mastra/mcp": "^1.6.0",
       "@mastra/loggers": "^1.1.1",
       "@mastra/memory": "^1.17.1",
       "@mastra/libsql": "^1.9.0"
     },
     "devDependencies": {
       "tsx": "^4.21.0",
       "typescript": "^6.0.3",
       "mastra": "^1.6.3"
     }
   }
   ```
   Scan the source code for additional `@mastra/*` imports (e.g., `@mastra/duckdb`, `@mastra/evals`, `@mastra/observability`) and add them to dependencies. Also scan for other third-party imports (e.g., `zod`) and include those.

4. Create `tsconfig.json`:
   ```json
   {
     "compilerOptions": {
       "target": "ES2022",
       "module": "ES2022",
       "moduleResolution": "bundler",
       "esModuleInterop": true,
       "forceConsistentCasingInFileNames": true,
       "strict": true,
       "skipLibCheck": true,
       "noEmit": true
     },
     "include": ["src/**/*"]
   }
   ```

5. Install dependencies:
   ```bash
   cd "$PROJECT_ROOT" && npm install
   ```

6. Set `AGENT_PATH="$PROJECT_ROOT"` for all subsequent steps (the wrapper is now the project root).

Tell the user that a wrapper project was created at `$PROJECT_ROOT`.

## Step 2: Install the MCP dependency

The `@mastra/mcp` package is required for connecting to coral's MCP server. Check if it's already installed:

```bash
cd "$PROJECT_ROOT"
grep -q "@mastra/mcp" package.json && echo "ALREADY_INSTALLED" || echo "NEEDS_INSTALL"
```

If not installed:
```bash
npm install @mastra/mcp@latest
```

Also ensure `tsx` is available as a dev dependency (used by startup.sh to run the worker entry point):
```bash
grep -q '"tsx"' package.json && echo "TSX_OK" || npm install --save-dev tsx
```

## Step 3: Scan for agents

Read the Mastra index file (typically `src/mastra/index.ts`) and look at the `agents: { ... }` object to find all registered agent keys. Also scan `src/mastra/agents/` for agent definition files to get agent names, descriptions, and **model configurations**.

Tell the user what agents were found:
> I found N agents in your project:
> - **agentKey1** — description (model: openai/gpt-5-mini)
> - **agentKey2** — description (model: openrouter/deepseek/deepseek-chat-v3-0324)
>
> I'll set up each one as a separate Coral agent. Proceed?

Wait for confirmation. The user may want to exclude some agents.

### Check required API keys

After scanning, identify model provider prefixes and their required env vars:

| Model prefix | Required env var |
|---|---|
| `openai/*` | `OPENAI_API_KEY` |
| `openrouter/*` | `OPENROUTER_API_KEY` |
| `anthropic/*` | `ANTHROPIC_API_KEY` |
| `google/*` | `GOOGLE_API_KEY` |

Check if the required keys are present:
```bash
# Check .env file
test -f "$PROJECT_ROOT/.env" && cat "$PROJECT_ROOT/.env" | grep -oE "^[A-Z_]+_KEY" || echo "NO_ENV_FILE"
```

If any required API keys are missing, warn the user:
> ⚠️ Agent **agentKey2** uses model `openrouter/deepseek/deepseek-chat-v3-0324` which requires `OPENROUTER_API_KEY`. Please add it to `$PROJECT_ROOT/.env`:
> ```
> OPENROUTER_API_KEY=your-key-here
> ```

The startup.sh template (Step 7) automatically sources `.env`, so adding keys there is sufficient. Do NOT proceed until the user confirms the keys are set — agents will crash at runtime without them.

## Step 4: Create the MCPClient module

Check if `src/mastra/mcp/coral-mcp-client.ts` already exists:
```bash
test -f "$PROJECT_ROOT/src/mastra/mcp/coral-mcp-client.ts" && echo "EXISTS" || echo "NEEDS_CREATE"
```

If it already exists, read it and verify it matches the expected pattern. If not, create it:

```bash
mkdir -p "$PROJECT_ROOT/src/mastra/mcp"
```

```typescript
import { MCPClient } from '@mastra/mcp'

const coralUrl = process.env.CORAL_CONNECTION_URL

export const coralMcpClient = coralUrl
  ? new MCPClient({
      id: 'coral-mcp-client',
      timeout: 1200000, // 20 minutes — coral_wait_for_mention blocks until a message arrives
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
- The `timeout: 1200000` (20 minutes) is critical — `coral_wait_for_mention` blocks until a message arrives, and the default MCPClient timeout (60s) is too short

## Step 5: Wire coral tools into the agents

For each agent defined in `src/mastra/agents/`, check if coral tools are already wired in. If not, import `getCoralTools` and spread the coral tools into the agent's `tools` config.

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

## Step 6: Configure per-agent storage paths

**This step is critical when the project contains multiple agents.** All agents from the same project share the same working directory. DuckDB only allows one process to hold a file lock — if multiple agents try to open the same `.duckdb` file, all but the first will crash with:

> `Error: IO Error: Could not set lock on file "mastra.duckdb": Conflicting lock is held in node (PID XXXX)`

Fix this by modifying the storage configuration in `src/mastra/index.ts` to use per-agent paths via the `CORAL_AGENT_ID` environment variable (automatically set by coral-server for each agent instance):

```typescript
storage: new MastraCompositeStore({
  id: 'composite-storage',
  default: new LibSQLStore({
    id: "mastra-storage",
    url: `file:./mastra-${process.env.CORAL_AGENT_ID || 'default'}.db`,
  }),
  domains: {
    observability: await new DuckDBStore({
      path: `./mastra-obs-${process.env.CORAL_AGENT_ID || 'default'}.duckdb`,
    }).getStore('observability'),
  }
}),
```

Key points:
- `CORAL_AGENT_ID` is unique per agent instance, so each gets its own database files
- The fallback `'default'` ensures standalone mode (`npm run dev`) still works
- `DuckDBStore` uses the `path` parameter (not `url`) for its constructor
- `LibSQLStore` uses the `url` parameter with `file:` prefix
- If the project only has a single agent, this step is still recommended for safety

**Only modify storage entries that use file-based paths** (DuckDB, LibSQL with `file:` URLs). Remote storage (e.g., Turso URLs) does not need this change.

If the project does not use DuckDB (no `@mastra/duckdb` import), skip the DuckDB part. If it does not use `MastraCompositeStore`, adapt the pattern to whatever storage is used.

## Step 7: Create the coral worker entry point

Check if `src/coral-worker.ts` already exists:
```bash
test -f "$PROJECT_ROOT/src/coral-worker.ts" && echo "EXISTS" || echo "NEEDS_CREATE"
```

If it exists, verify it accepts an agent key argument. If not, create it:

```typescript
// src/coral-worker.ts
import { mastra } from './mastra/index.js'

const agentKey = process.argv[2]
if (!agentKey) {
  console.error('Usage: coral-worker.ts <agentKey>')
  process.exit(1)
}

const agent = mastra.getAgent(agentKey)

while (true) {
  try {
    const result = await agent.generate(
      'Call coral_wait_for_mention to receive your next task. Once you receive a task, complete it fully using your available tools, then send a completion message via coral_send_message and wait for the next task.',
      {
        maxSteps: 50,
      },
    )
    console.log(`[${new Date().toISOString()}] Agent response:`, result.text)
  } catch (err) {
    console.error(`[${new Date().toISOString()}] Error in coral worker loop:`, err)
    await new Promise(r => setTimeout(r, 3000))
  }
}
```

How the worker loop works:
- Each iteration calls `agent.generate()` which instructs the LLM to call `coral_wait_for_mention`
- The LLM uses coral tools autonomously — receiving tasks, processing them with its own tools, and sending back results
- `maxSteps: 50` allows the agent to make up to 50 tool calls per generate cycle
- If the generate call completes or errors out, the loop retries automatically

## Step 8: Create wrapper directories under ~/.coral/agents/

For **each** agent discovered in the project, create a wrapper directory under `~/.coral/agents/<agent-name>/` containing two files:

### coral-agent.toml

```toml
edition = 3

[agent]
name = "<agent-name>"
version = "0.1.0"
description = "<agent description from the project>"

readme = "<agent-name> for Coral Protocol"
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

### startup.sh

Each wrapper's `startup.sh` points back to the user's project and passes the specific agent key.

**IMPORTANT:** The script must `cd` to the project directory before running `npx tsx`. Without `cd`, `npx` may use a globally cached tsx version that doesn't respect the project's `package.json` `"type": "module"` setting, causing CJS/ESM mode errors.

```bash
#!/bin/bash
# Coral wrapper for <agent-name>
# Points to the Mastra project at <PROJECT_ROOT>

AGENT_PATH="<absolute-path-to-project-root>"

echo "=== Coral <agent-name> ==="
echo "Agent ID:       $CORAL_AGENT_ID"
echo "Session ID:     $CORAL_SESSION_ID"
echo "Connection URL: $CORAL_CONNECTION_URL"

# Ensure dependencies are installed
if [ ! -d "$AGENT_PATH/node_modules" ]; then
  echo ">>> Installing dependencies..."
  cd "$AGENT_PATH" && npm install
fi

# Load .env file if it exists
if [ -f "$AGENT_PATH/.env" ]; then
  set -a
  source "$AGENT_PATH/.env"
  set +a
fi

# Export coral environment variables
export CORAL_CONNECTION_URL="$CORAL_CONNECTION_URL"
export CORAL_SESSION_ID="$CORAL_SESSION_ID"
export CORAL_AGENT_ID="$CORAL_AGENT_ID"

echo ">>> Starting <agent-name> as Coral worker..."
cd "$AGENT_PATH"
exec npx tsx "$AGENT_PATH/src/coral-worker.ts" <agentKey>
```

Replace `<agent-name>` with the kebab-case agent name, `<PROJECT_ROOT>` with the absolute path to the project root, and `<agentKey>` with the Mastra agent key (e.g., if `agents: { weatherAgent }`, use `weatherAgent`).

Make all startup scripts executable:

```bash
chmod +x ~/.coral/agents/<agent-name>/startup.sh
```

## Step 9: Verify the build

Run a type check to make sure everything compiles:

```bash
cd "$PROJECT_ROOT" && npx tsc --noEmit
```

Fix any type errors before proceeding. Common issues:
- Missing `@mastra/mcp` installation (Step 2)
- Incorrect agent key in `coral-worker.ts` (Step 7)
- Top-level `await` requires `"module": "ES2022"` or similar in `tsconfig.json` (Mastra projects already have this)

## Standalone mode

After coralization, the agent still works standalone:

```bash
npm run dev  # Starts Mastra Studio at localhost:4111
```

When running standalone, `CORAL_CONNECTION_URL` is not set, so `getCoralTools()` returns `{}` and the agent works with just its original tools. The coral instructions in the agent's prompt are conditional and won't affect standalone behavior.

## Troubleshooting

### "Top-level await is currently not supported with the 'cjs' output format"

This happens when tsx treats the file as CommonJS instead of ESM. Two common causes:

1. **Symlinked source files**: tsx resolves symlinks to their physical location and looks for the nearest `package.json` there. If the physical path has no `package.json` with `"type": "module"`, tsx defaults to CJS mode. **Fix:** Replace symlinks with actual file copies (`cp -r` instead of `ln -s`).

2. **Missing `"type": "module"` in package.json**: Ensure the project's `package.json` has `"type": "module"`.

### "Could not set lock on file mastra.duckdb"

Multiple Mastra agents from the same project are trying to open the same DuckDB file. DuckDB only allows one process to hold the lock.

**Fix:** Apply per-agent storage paths using `CORAL_AGENT_ID` (see Step 6).

### "Could not find API key process.env.OPENROUTER_API_KEY"

The agent uses a model that requires an API key not present in the environment.

**Fix:** Create a `.env` file in the project root with the required key:
```
OPENROUTER_API_KEY=your-key-here
```
The `startup.sh` template automatically sources `.env` files. Common keys: `OPENAI_API_KEY`, `OPENROUTER_API_KEY`, `ANTHROPIC_API_KEY`.

### MCP timeout on coral_wait_for_mention

If you see `MCP error -32001: Request timed out`, the MCPClient's default timeout (60s) is too short for `coral_wait_for_mention` which blocks waiting for messages. The `coral-mcp-client.ts` template in Step 4 already sets `timeout: 1200000` (20 minutes). If you're using an older version, update it.

### Module not found errors in .mastra/output

If `npm run dev` fails with `Cannot find package '@mastra/mcp'`, clear the Mastra build cache and restart:

```bash
rm -rf "$PROJECT_ROOT/.mastra"
npm run dev
```

### Agent appears twice in logs

The `startup.sh` and `coral-worker.ts` both print startup banners. This is one agent with two log statements, not two agents. Remove the banner from `coral-worker.ts` if it's confusing.

### startup.sh: npx uses wrong tsx version

If `npx tsx` picks up a globally cached version instead of the project-local one, the ESM configuration may not be respected. **Fix:** Ensure `startup.sh` runs `cd "$AGENT_PATH"` before `exec npx tsx`. This makes npx prefer the project-local `node_modules/.bin/tsx`.
