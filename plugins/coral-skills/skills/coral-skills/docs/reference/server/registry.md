# Registry

Source: https://docs.coralos.ai/reference/server/registry

# Local agents
**default** empty list

- Command line: `--registry.local-agents="/path/to/agent" --registry.local-agents="/all/my/agents/*"`
- Config file: `registry.local_agents = ["/path/to/agent", "/all/my/agents/*"]`

A list of paths to agents on the local machine. Any agent included in this list will be available to the Coral server
in the local agent registry source.

Consider the following directory structure:

```text
/path/to/agents/
  agent1/
    coral-agent.toml
  agent2/
    coral-agent.toml
  agent3/
    coral-agent.toml
```

Adding just `agent1` could be done with:

```toml
[registry]
local_agents = ["/path/to/agents/agent1"]
```

Adding all agents (`agent1`, `agent2` and `agent3`) could be done with:

```toml
[registry]
local_agents = ["/path/to/agents/*"]
```

Sometimes, you may want to use multiple wildcard paths, for example if you keep your agents in folders with versions:

```text
/path/to/agents/
  agent1/
    1.0.0/
      coral-agent.toml
    1.0.1/
      coral-agent.toml
  agent2/
    1.0.0/
      coral-agent.toml
    1.0.1/
      coral-agent.toml
```

This can be facilitated with:
```toml
[registry]
local_agents = ["/path/to/agents/*/*"]
```

> **Warning:**
>
> The wildcard `*` is not permitted as part of a path segment, only as a full path segment.
>
>  Good
> ```toml
> [registry]
> local_agents = ["/path/to/agents/*/*"]
> ```
>
>  Bad
> ```toml
> [registry]
> local_agents = ["/path/to/agents*"]
> ```

# Include Coral home agents
**default** `true`

- Command line: `--registry.include-coral-home-agents=false`
- Config file: `registry.include_coral_home_agents = false`

If this is set to `true`, the following directories will be added to [local agents](#local-agents):
- `${HOME}/.coral/agents/*/*`
- `${HOME}/.coral/agents/*`
- `${HOME}/.coral/agents/locallinked/*/*`

It is recommended to use this configuration option instead of manually adding the above paths to [local agents](#local-agents).

# Watch local agents
**default** `true`

- Command line: `--registry.watch-local-agents=false`
- Config file: `registry.watch_local_agents = false`

If this is set to true, modifications to local agents will be automatically detected and reloaded.

Detected changes include:
- Deletion of an agent
- Modification of an agent
- New agents (for example, those that match a path that uses a wildcard)

> **Warning:**
>
> It is possible due to a JVM limitation that changes to agents, especially those made programmatically, are not
> detected via this watch option. Consider setting [local agent rescan timer](#local-agent-rescan-timer) to a
> non-zero value.

# Local agent rescan timer

- Command line: `--registry.local-agent-rescan-timer="30s"`
- Config file: `registry.local_agent_rescan_timer = "30s"`

See [here](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.time/-duration/-companion/parse.html) for more information on the format.

If this is set to a non-zero value, the Coral server will periodically rescan the local agent registry for changes.

Scanning the filesystem can be expensive, especially if the [local agents](#local-agents) list contains many paths with
wildcards. Consider setting this to a high value or disabling it entirely.

# Include debug agents
**default** `false`

- Command line: `--registry.include-debug-agents=false`
- Config file: `registry.include_debug_agents = false`

If this is true, the Coral server [debug agents](../../guides/debugging.md#built-in-debug-agents) will be available in the
server's local agent registry source.

# Include marketplace agents
**default** `false`

- Command line: `--registry.enable-marketplace-agent-registry-source=false`
- Config file: `registry.enable_marketplace_agent_registry_source = false`

If this is true, the Coral server will be able to directly use agents from the [Marketplace](../../concepts/marketplace.md).
