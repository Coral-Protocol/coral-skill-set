#!/bin/bash
# This script is launched by Coral Server via executable runtime.
# Working directory is the directory containing coral-agent.toml
#
# Each session gets its own OpenClaw profile via --profile to isolate state.
# Profile creates ~/.openclaw-<name>/ with independent config and auth.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTANCE_DIR="$SCRIPT_DIR/instances/$CORAL_SESSION_ID/$CORAL_AGENT_ID"
mkdir -p "$INSTANCE_DIR"

echo "=== Coral OpenClaw Agent ==="
echo "Agent ID:       $CORAL_AGENT_ID"
echo "Session ID:     $CORAL_SESSION_ID"
echo "Connection URL: $CORAL_CONNECTION_URL"
echo "Instance dir:   $INSTANCE_DIR"

# Use a unique profile per session+agent to isolate OpenClaw state
PROFILE_NAME="coral-${CORAL_SESSION_ID}-${CORAL_AGENT_ID}"
PROFILE_DIR="$HOME/.openclaw-${PROFILE_NAME}"

echo "Profile: $PROFILE_NAME"
echo "Profile dir: $PROFILE_DIR"

# Read model from global OpenClaw config
GLOBAL_CONFIG="$HOME/.openclaw/openclaw.json"
MODEL_DEFAULT=$(python3 -c "
import json, sys
try:
    with open('$GLOBAL_CONFIG') as f:
        c = json.load(f)
    print(c.get('agents',{}).get('defaults',{}).get('model',{}).get('primary','anthropic/claude-sonnet-4-6'))
except: print('anthropic/claude-sonnet-4-6')
" 2>/dev/null)

echo "Using model: $MODEL_DEFAULT"

# Bootstrap the profile: copy global config + auth so API keys are available
if [ ! -f "$PROFILE_DIR/openclaw.json" ]; then
    mkdir -p "$PROFILE_DIR/agents/main/agent"

    # Copy global config as base
    if [ -f "$GLOBAL_CONFIG" ]; then
        cp "$GLOBAL_CONFIG" "$PROFILE_DIR/openclaw.json"
    else
        # Minimal config
        cat > "$PROFILE_DIR/openclaw.json" << CFGEOF
{
  "gateway": { "mode": "local" },
  "agents": {
    "defaults": {
      "model": { "primary": "$MODEL_DEFAULT" }
    }
  }
}
CFGEOF
    fi

    # Copy auth profiles (API keys) from global install
    GLOBAL_AUTH="$HOME/.openclaw/agents/main/agent/auth-profiles.json"
    if [ -f "$GLOBAL_AUTH" ]; then
        cp "$GLOBAL_AUTH" "$PROFILE_DIR/agents/main/agent/auth-profiles.json"
    fi
fi

# Register Coral as an MCP server in this profile
openclaw --profile "$PROFILE_NAME" mcp set coral "{\"url\":\"$CORAL_CONNECTION_URL\",\"transport\":\"streamable-http\"}"

echo "Registered Coral MCP server at: $CORAL_CONNECTION_URL"

# Write worker instructions
cat > "$INSTANCE_DIR/WORKER.md" << 'WORKER_EOF'
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

## CRITICAL: Never Exit

This is a long-running worker process. Your job is to stay alive and wait for tasks indefinitely. There is NO condition under which you should decide to exit or "pause to avoid spinning."

- If `coral_wait_for_mention` returns old/duplicate messages, that is normal — continue the Communication Loop.
- If you have been waiting a long time with no new messages, that is normal — just keep waiting.
- Even if it feels like nothing is happening, DO NOT exit. Another task could arrive at any moment.
- NEVER say "I'll pause here" or "I'll stop the loop." Your loop must run forever.

## Restrictions

- Do NOT ask the human for input or confirmation.
- Do NOT idle. Always be either working on a task or waiting for a mention.
- Do NOT exit, stop, or end your process for any reason.

## Capabilities

You have full access to tools: read/write files, run commands, search code, etc. Use whatever tools are needed to complete the task assigned to you.
WORKER_EOF

echo ">>> Auto-launching OpenClaw for worker agent: $CORAL_AGENT_ID"
SESSION_KEY="coral-${CORAL_SESSION_ID}-${CORAL_AGENT_ID}"

# First run: read instructions and start waiting
openclaw --profile "$PROFILE_NAME" agent \
    --local \
    --session-id "$SESSION_KEY" \
    --message "Read your instructions from $INSTANCE_DIR/WORKER.md then call coral_wait_for_mention to receive your task." \
    --model "$MODEL_DEFAULT" \
    --timeout 3600

# Restart loop: if openclaw exits, resume with same session
while true; do
    echo ">>> OpenClaw exited, restarting worker agent: $CORAL_AGENT_ID"
    sleep 2
    openclaw --profile "$PROFILE_NAME" agent \
        --local \
        --session-id "$SESSION_KEY" \
        --message "Read coral://state then continue to work." \
        --model "$MODEL_DEFAULT" \
        --timeout 3600
done
