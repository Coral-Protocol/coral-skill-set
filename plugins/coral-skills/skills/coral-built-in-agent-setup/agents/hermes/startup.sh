#!/bin/bash
# This script is launched by Coral Server via executable runtime.
# Working directory is the directory containing coral-agent.toml
#
# Each session gets its own subdirectory under instances/<session-id>/<agent-id>.
# HERMES_HOME is set to the instance dir so each Hermes instance gets its own config.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTANCE_DIR="$SCRIPT_DIR/instances/$CORAL_SESSION_ID/$CORAL_AGENT_ID"
mkdir -p "$INSTANCE_DIR"

echo "=== Coral Hermes Agent ==="
echo "Agent ID:       $CORAL_AGENT_ID"
echo "Session ID:     $CORAL_SESSION_ID"
echo "Connection URL: $CORAL_CONNECTION_URL"
echo "Instance dir:   $INSTANCE_DIR"

# Extract model settings from global hermes config
GLOBAL_CONFIG="$HOME/.hermes/config.yaml"
MODEL_DEFAULT=$(python3 -c "
import yaml, sys
try:
    with open('$GLOBAL_CONFIG') as f:
        c = yaml.safe_load(f)
    print(c.get('model', {}).get('default', 'claude-opus-4-6'))
except: print('claude-opus-4-6')
" 2>/dev/null)
MODEL_PROVIDER=$(python3 -c "
import yaml, sys
try:
    with open('$GLOBAL_CONFIG') as f:
        c = yaml.safe_load(f)
    print(c.get('model', {}).get('provider', 'anthropic'))
except: print('anthropic')
" 2>/dev/null)

echo "Using model: $MODEL_DEFAULT via $MODEL_PROVIDER"

# Create per-instance config.yaml with coral MCP server + global model settings
cat > "$INSTANCE_DIR/config.yaml" << EOF
model:
  default: $MODEL_DEFAULT
  provider: $MODEL_PROVIDER

agent:
  max_turns: 150
  tool_use_enforcement: auto

mcp_servers:
  coral:
    url: "$CORAL_CONNECTION_URL"
    timeout: 1200
    connect_timeout: 30
EOF

# Copy API keys from global hermes env
if [ -f "$HOME/.hermes/.env" ]; then
    cp "$HOME/.hermes/.env" "$INSTANCE_DIR/.env"
fi

# Copy auth.json from global hermes (for provider auth)
if [ -f "$HOME/.hermes/auth.json" ]; then
    cp "$HOME/.hermes/auth.json" "$INSTANCE_DIR/auth.json"
fi

# Set HERMES_HOME to this instance directory
export HERMES_HOME="$INSTANCE_DIR"

# Write worker SOUL.md
cat > "$INSTANCE_DIR/SOUL.md" << 'WORKER_EOF'
# Coral Worker Agent

You are a worker agent in a Coral multi-agent session.

## Startup

Your first action MUST be to call `coral_wait_for_mention` to receive your task assignment.

## Communication Loop

Follow this exact loop every time you wait for messages:

1. Call `coral_wait_for_mention`
2. After it returns (whether with a message or a timeout), ALWAYS read `coral://state` resource to check for any messages you may have missed
3. If you find unread messages in the state that you haven't processed yet, handle them
4. Go back to step 1

This is critical because messages can arrive while you are not waiting, and `coral_wait_for_mention` only catches messages that arrive DURING the wait. The `coral://state` resource records ALL messages in threads you participate in.

## Communication Rules

- After EVERY message you send via `coral_send_message`, you MUST immediately enter the Communication Loop above
- Do NOT wait for human input. You are fully autonomous.
- Follow instructions from other agents completely.
- When your task is done, send a completion message mentioning the requester, then enter the Communication Loop for further instructions.

## Restrictions

- Do NOT ask the human for input or confirmation.
- Do NOT idle. Always be either working on a task or waiting for a mention.

## Capabilities

You have full access to tools: read/write files, run commands, search code, etc. Use whatever tools are needed to complete the task assigned to you.
WORKER_EOF

echo ">>> Auto-launching Hermes for worker agent: $CORAL_AGENT_ID"
exec hermes chat -q "call coral_wait_for_mention" --yolo
