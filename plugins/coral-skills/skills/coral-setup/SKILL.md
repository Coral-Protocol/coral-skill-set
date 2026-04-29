---
name: coral-setup
description: Set up and manage the Coral Protocol server environment. Use this skill when the user wants to install Coral, start/stop Coral server, reset the Coral environment, check if Coral is running, clone/update coral-server, or prepare a fresh Coral setup. Also trigger when the user mentions "coral server", "coral setup", "coral install", "start coral", "stop coral", or "coral environment".
---

# Coral Server Setup

This skill prepares the Coral Protocol server environment in `~/.coral/`.

## Step 1: Check current state

Run this single command to check both the server process and the repo in one shot. This avoids parallel bash calls that can cancel each other when one returns a non-zero exit code:

```bash
echo "=== PROCESS CHECK ===" && (ps aux | grep -E "coral-server|coralserver" | grep -v grep || echo "NO_PROCESS_FOUND") && echo "=== PORT CHECK ===" && (lsof -ti:5555 || echo "PORT_FREE") && echo "=== REPO CHECK ===" && (mkdir -p ~/.coral && test -f ~/.coral/coral-server/gradlew && echo "REPO_EXISTS" || echo "REPO_NOT_FOUND")
```

Parse the output:
- If processes were found (not "NO_PROCESS_FOUND"), kill them: `ps aux | grep -E "coral-server|coralserver" | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null`
- If port is occupied (not "PORT_FREE"), free it: `lsof -ti:5555 | xargs kill 2>/dev/null`
- If "REPO_EXISTS" → pull latest. If "REPO_NOT_FOUND" → clone fresh.

Tell the user what you found and what actions you took.

## Step 2: Clone or update coral-server

Based on Step 1 results:

**If repo does NOT exist** — clone from GitHub:

```bash
mkdir -p ~/.coral && git clone https://github.com/Coral-Protocol/coral-server.git ~/.coral/coral-server
```

**If repo DOES exist** — pull the latest changes:

```bash
cd ~/.coral/coral-server && git pull
```

## Step 3: Verify the setup

Confirm the server is ready:

```bash
test -f ~/.coral/coral-server/gradlew && echo "SETUP_OK" || echo "SETUP_FAILED"
```

If "SETUP_OK", tell the user:
- Where coral-server is located (`~/.coral/coral-server`)
- How to start it: `cd ~/.coral/coral-server && ./gradlew run`
- That it will be available at `http://localhost:5555` once started

## Step 4: Offer to install built-in agents

After coral-server setup is complete, ask the user if they want to install built-in agents (Claude Code, Hermes). Then read and follow the skill at `coral-built-in-agent-setup/SKILL.md` (sibling directory) to proceed with agent installation.
