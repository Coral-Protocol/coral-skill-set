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

## Step 3: Patch the Long field schema bug

The coral-server uses schema-kenerator to auto-generate JSON schemas for MCP tool inputs. For Kotlin `Long` fields, it produces `minimum: -9223372036854775808` and `maximum: 9223372036854775807`, which exceed the 32-bit integer range. The Anthropic API rejects these with `"tools.N.custom.input_schema: int too big to convert"`, causing Claude Code agents to crash immediately on startup.

The affected fields are `currentUnixTime: Long` and `maxWaitMs: Long` in `WaitForMessageTools.kt`. The fix is to strip out-of-range `minimum`/`maximum` constraints from the generated schema before it reaches the API.

Apply the patch to `McpToolManager.kt`:

```bash
MCPTOOL="$HOME/.coral/coral-server/src/main/kotlin/org/coralprotocol/coralserver/mcp/McpToolManager.kt"
test -f "$MCPTOOL" && echo "FILE_FOUND" || echo "FILE_NOT_FOUND"
```

If "FILE_FOUND", use the Edit tool to make two changes to `McpToolManager.kt`:

**Change 1: Add imports.** Find the existing import block and add two imports after `import kotlinx.serialization.json.JsonObject`:

```kotlin
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.longOrNull
```

(If these imports already exist, skip this change — the patch may have been applied previously.)

**Change 2: Add the sanitizer function and wire it in.** Add this function right before the existing `inline fun <reified In> buildToolSchema()` function:

```kotlin
/**
 * Strips `minimum` and `maximum` constraints from integer properties whose values exceed
 * the 32-bit signed integer range. The schema-kenerator library auto-generates Long-range
 * bounds (±9.2e18) for Kotlin Long fields, which the Anthropic API rejects with
 * "int too big to convert".
 */
@PublishedApi
internal fun sanitizeProperties(properties: JsonObject): JsonObject {
    val intMax = Int.MAX_VALUE.toLong()
    val intMin = Int.MIN_VALUE.toLong()

    val sanitized = properties.mapValues { (_, propElement) ->
        val propObj = propElement as? JsonObject ?: return@mapValues propElement
        val keysToStrip = mutableSetOf<String>()
        for (key in listOf("minimum", "maximum")) {
            val bound = (propObj[key] as? JsonPrimitive)?.longOrNull
            if (bound != null && (bound < intMin || bound > intMax)) {
                keysToStrip.add(key)
            }
        }
        if (keysToStrip.isEmpty()) propElement
        else JsonObject(propObj.filterKeys { it !in keysToStrip })
    }
    return JsonObject(sanitized)
}
```

Then, inside `buildToolSchema()`, find the return statement and change `properties = properties` to `properties = sanitizeProperties(properties)`:

```kotlin
// Before (original):
    return ToolSchema(
        required = required.map { it.jsonPrimitive.content },
        properties = properties
    )

// After (patched):
    return ToolSchema(
        required = required.map { it.jsonPrimitive.content },
        properties = sanitizeProperties(properties)
    )
```

**Important notes:**
- The function must be `@PublishedApi internal` (not `private`) because it is called from a `public inline` function. Using `private` will cause a Kotlin compilation error: "Public-API inline function cannot access non-public-API function."
- To verify the patch was applied correctly, you can check that the file contains `sanitizeProperties`: `grep -c "sanitizeProperties" "$MCPTOOL"` — this should return 2 or more (the function definition + the call site).

## Step 4: Configure config.toml

Create or overwrite the server configuration file. First, determine the user's home directory:

```bash
echo $HOME
```

First, fetch the latest coral-studio (console) release version from GitHub:

```bash
CONSOLE_VERSION=$(curl -sL https://api.github.com/repos/Coral-Protocol/coral-studio/releases/latest | grep '"tag_name"' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
echo "Latest coral-studio version: $CONSOLE_VERSION"
```

If the API call fails or returns empty, fall back to `"v0.3.11"`.

Then write the config file, replacing `<HOME>` with the actual home directory path and `<CONSOLE_VERSION>` with the version fetched above:

```bash
cat > ~/.coral/coral-server/src/main/resources/config.toml << CONFIGEOF
[docker]
# Use host.docker.internal for WSL
address = "host.docker.internal"
socket = "unix:///var/run/docker.sock"

[network]
bind_address = "0.0.0.0"
external_address = "0.0.0.0"
bind_port = 5555
allow_any_host = true

[session]
defaultWaitTimeout = 240000

[auth]
keys = ["test"]

[registry]
include_debug_agents = true
local_agents = []

[console]
consoleReleaseVersion = "$CONSOLE_VERSION"
CONFIGEOF
```

Note: The `local_agents` list is empty for now — it will be populated later when built-in agents are installed via the `coral-built-in-agent-setup` skill. The `[console]` section pins the coral-studio UI to the latest release version.

## Step 5: Verify the setup

Confirm the server is ready:

```bash
test -f ~/.coral/coral-server/gradlew && echo "SETUP_OK" || echo "SETUP_FAILED"
```

If "SETUP_OK", tell the user:
- Where coral-server is located (`~/.coral/coral-server`)
- How to start it: `cd ~/.coral/coral-server && ./gradlew run`
- That it will be available at `http://localhost:5555` once started

## Step 6: Offer to install built-in agents

After coral-server setup is complete, ask the user if they want to install and setup built-in agents (Claude Code, Hermes). Then read and follow the skill at `coral-built-in-agent-setup/SKILL.md` (sibling directory) to proceed with agent installation and setup.

## Step 7: Offer to connect the user's own agent

After built-in agent setup is complete (or if the user skips it), ask the user:
> Do you have your own agent project that you'd like to connect to Coral? I can help integrate it so it can participate in multi-agent sessions.

If the user says yes, read and follow the sibling skill at `${SKILL_DIR}/../coralize-your-agent/SKILL.md` to walk them through the integration.
