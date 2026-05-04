---
name: coral-built-in-agent-setup
description: Install built-in agents (Claude Code, Hermes, Puppet) into the Coral Protocol environment. Use this skill after coral-server is set up and the user wants to add agents, or when the user says "install agents", "setup agents", "add claude-code agent", "add hermes agent", "built-in agents", "coral agents", or mentions setting up agents for Coral. Always trigger this skill after coral-setup completes to ask the user if they want to install built-in agents.
---

# Coral Built-in Agent Setup

This skill installs built-in agents into `~/.coral/agents/` and registers them in the Coral server config.

The bundled agent templates are in `${SKILL_DIR}/agents/` (claude-code, hermes, puppet).

## Step 0: Check if coral-server is installed

First, verify that coral-server exists:

```bash
test -f ~/.coral/coral-server/gradlew && echo "CORAL_SERVER_OK" || echo "CORAL_SERVER_NOT_FOUND"
```

- If "CORAL_SERVER_OK" → proceed to Step 1.
- If "CORAL_SERVER_NOT_FOUND" → tell the user that coral-server must be installed first, then read and follow the sibling skill `coral-setup/SKILL.md` to set it up. After coral-server setup completes, come back here and continue from Step 1.

## Step 1: Ask the user which agents to install

Tell the user:
> Coral server is ready. Would you like to install built-in agents?
> Available agents:
> - **Claude Code** — an AI coding agent powered by Anthropic's Claude
> - **Hermes** — a general-purpose AI agent by Nous Research
>
> (The **Puppet** test agent will be installed automatically.)

Wait for the user's response before proceeding.

## Step 2: Check prerequisites

For each agent the user selected, check if the required CLI tool is installed:

```bash
echo "=== CLAUDE CODE ===" && (claude --version 2>&1 || echo "NOT_INSTALLED") && echo "=== HERMES ===" && (hermes --version 2>&1 || echo "NOT_INSTALLED")
```

Parse the output:
- If Claude Code shows "NOT_INSTALLED", tell the user to install it first: https://code.claude.com/docs/en/overview
- If Hermes shows "NOT_INSTALLED", tell the user to install it first: https://hermes-agent.nousresearch.com/docs/getting-started/installation

If any selected agent is missing its CLI, stop and wait for the user to install it, then re-check. Do NOT proceed until all selected agents have their CLIs available.

Puppet has no prerequisites — it only uses `curl` and `bash`.

## Step 3: Deploy agents to ~/.coral/agents/

Create the agents directory and copy from the skill's bundled templates. For each agent to install (user-selected ones + puppet which is always installed):

```bash
mkdir -p ~/.coral/agents

# Always install puppet
cp -r ${SKILL_DIR}/agents/puppet ~/.coral/agents/puppet

# If user wants Claude Code
cp -r ${SKILL_DIR}/agents/claude-code ~/.coral/agents/claude-code

# If user wants Hermes
cp -r ${SKILL_DIR}/agents/hermes ~/.coral/agents/hermes
```

Make startup scripts executable:

```bash
chmod +x ~/.coral/agents/puppet/startup.sh
chmod +x ~/.coral/agents/claude-code/startup.sh  # if installed
chmod +x ~/.coral/agents/hermes/startup.sh       # if installed
```

## Step 4: Update config.toml

Read `~/.coral/coral-server/src/main/resources/config.toml` and update the `local_agents` list under `[registry]` to point to the new `~/.coral/` paths.

The paths should use the user's actual home directory (expand `~`). Build the list based on what was installed:

- Always include: `"<HOME>/.coral/agents/puppet"`
- If Claude Code installed: `"<HOME>/.coral/agents/claude-code"`
- If Hermes installed: `"<HOME>/.coral/agents/hermes"`

Example result in config.toml:

```toml
[registry]
local_agents = ["/Users/username/.coral/agents/claude-code", "/Users/username/.coral/agents/hermes", "/Users/username/.coral/agents/puppet"]
```

Use the Edit tool to update only the `local_agents` line. Do not modify any other part of config.toml.

## Step 5: Verify and report

Confirm the setup:

```bash
echo "=== INSTALLED AGENTS ===" && ls -d ~/.coral/agents/claude-code ~/.coral/agents/hermes ~/.coral/agents/puppet 2>/dev/null && echo "=== CONFIG CHECK ===" && grep "local_agents" ~/.coral/coral-server/src/main/resources/config.toml
```

Tell the user:
- Which agents were installed and where
- That puppet was auto-installed as a test agent
- To start the server with `cd ~/.coral/coral-server && ./gradlew run` if not already running
- Agents will auto-register when the server starts

## Step 6: Offer to try multi-agent orchestration

After reporting the setup results, ask the user:
> Would you like to try running these agents through Coral server? I can help you orchestrate a multi-agent session.

If the user says yes, read the sibling skill at `${SKILL_DIR}/../coral-agent-swarm/SKILL.md` and follow its instructions to set up and run a multi-agent session.
