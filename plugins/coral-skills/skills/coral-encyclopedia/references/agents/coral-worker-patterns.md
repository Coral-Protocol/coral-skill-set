# Coral Worker Entry Point Patterns

Every Coral agent needs a "worker" — the main loop that connects to the Coral MCP server, waits for tasks, processes them, and sends results back. Below are working patterns for different frameworks.

## Common Pattern

All workers follow the same basic structure:

1. Receive `CORAL_CONNECTION_URL`, `CORAL_SESSION_ID`, `CORAL_AGENT_ID` from environment
2. Connect to the Coral MCP server at `CORAL_CONNECTION_URL`
3. Enter a loop: wait for mention → process task → send response → repeat

The two key MCP tools every agent uses:
- **`coral_wait_for_mention`** — Blocks until another agent mentions this agent in a thread message
- **`coral_send_message`** — Sends a message to a thread, optionally mentioning other agents

---

## Mastra (TypeScript)

### coral-worker.ts

```typescript
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
      { maxSteps: 50 },
    )
    console.log(`[${new Date().toISOString()}] Agent response:`, result.text)
  } catch (err) {
    console.error(`[${new Date().toISOString()}] Error in coral worker loop:`, err)
    await new Promise(r => setTimeout(r, 3000))
  }
}
```

### How it works
- Each loop iteration calls `agent.generate()` which instructs the LLM to call `coral_wait_for_mention`
- The LLM uses coral tools autonomously — receiving tasks, processing them, sending results
- `maxSteps: 50` allows up to 50 tool calls per generate cycle
- On error, waits 3 seconds then retries

### startup.sh (Mastra wrapper)

```bash
#!/bin/bash
AGENT_PATH="/path/to/mastra-project"

# Load .env if it exists
if [ -f "$AGENT_PATH/.env" ]; then
  set -a && source "$AGENT_PATH/.env" && set +a
fi

# Export coral environment variables
export CORAL_CONNECTION_URL="$CORAL_CONNECTION_URL"
export CORAL_SESSION_ID="$CORAL_SESSION_ID"
export CORAL_AGENT_ID="$CORAL_AGENT_ID"

# Run the worker (must cd first to resolve ESM modules correctly)
cd "$AGENT_PATH" && npx tsx --experimental-specifier-resolution=node src/coral-worker.ts my-agent-key
```

---

## Koog (Kotlin)

Koog agents use the Koog framework which handles the MCP connection and tool registration automatically. The agent connects to the Coral MCP server URL and the framework manages the communication loop.

See the [Koog template](https://github.com/Coral-Protocol/coral-koog-agent) for a complete working example.

### startup.sh (Koog)

```bash
#!/bin/bash
cd "$(dirname "$0")"
./gradlew run
```

The Gradle build passes `CORAL_CONNECTION_URL` to the agent process automatically.

---

## Python (LangChain)

See the [LangChain template](https://github.com/Coral-Protocol/langchain-agent) for a working example.

The pattern is similar: connect to Coral MCP server, register tools, enter a wait-process-respond loop.

---

## Claude Code (Special Case)

Claude Code agents don't use a traditional worker loop. Instead, the `startup.sh` launches `claude` CLI with an MCP config that points to the Coral server:

```bash
#!/bin/bash
# Write MCP config pointing to Coral
cat > /tmp/coral-mcp-$CORAL_AGENT_ID.json << EOF
{
  "mcpServers": {
    "coral": {
      "type": "streamableHttp",
      "url": "$CORAL_CONNECTION_URL"
    }
  }
}
EOF

# Launch Claude Code with coral MCP
claude --mcp-config /tmp/coral-mcp-$CORAL_AGENT_ID.json \
  --allowedTools "mcp__coral__*" \
  -p "You are a Coral agent. Use coral_wait_for_mention to receive tasks..."
```

Claude Code's own agent loop handles the wait → process → respond cycle internally.
