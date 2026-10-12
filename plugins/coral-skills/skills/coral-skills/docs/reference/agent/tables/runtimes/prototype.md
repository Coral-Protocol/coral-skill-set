# Prototype runtime

Source: https://docs.coralos.ai/reference/agent/tables/runtimes/prototype

The [Koog template](../../../../guides/quickstart.md#koog-template) is the main path for writing agents and a reference for implementations in other frameworks. Write agent code when you need custom context management, memory, control flow, or execution behavior.

Use the prototype runtime when you already know a simple prompt-and-tool loop is sufficient. It runs a Koog agent inside Coral Server with an LLM, Coral tools, and optional remote MCP tools, without a separate executable or container.

## Complete agent definition

Save this as `coral-agent.toml` and add its directory to `registry.localAgents` (or use `coralizer link .`):

```toml
edition = 5

[agent]
name = "report-writer"
version = "1.0.0"
description = "Writes reports using the tools supplied by the application"
summary = "A configurable report writer"
readme = "A prototype agent for application-provided reporting tasks."
license = { type = "spdx", expression = "MIT" }

[options.TASK]
type = "string"
required = true
display.description = "The report to produce"

[runtimes.prototype]
proxy = "MAIN"
iterations = 20
delay = 0
prompts.loop.initial.extra = { type = "option", name = "TASK" }

[[llm.proxies]]
name = "MAIN"
format.type = "OpenAI"
models = ["gpt-4.1"]
```

Configure a matching [server LLM provider](../../../../reference/server/llm-proxy.md#providers), or supply a Coral Cloud API key. Create sessions with `provider: { "type": "local", "runtime": "prototype" }`, provide `options.TASK`, and grant application tools through `customToolAccess`.

## Runtime settings

| Field | Default | Meaning |
|---|---|---|
| `proxy` | Required | Name of a request in `llm.proxies`. |
| `client` | Inferred from proxy format | `"openai"`, `"anthropic"`, or explicit `"openrouter"` in the v1.4.0 release. |
| `iterations` | `20` | Positive number of LLM/tool iterations. |
| `delay` | `0` | Nonnegative delay in milliseconds before iterations after the first. |
| `volatile` | `false` | If true, an iteration error stops the runtime; otherwise the error is logged and later iterations continue. |
| `tools` | Empty list | Additional HTTP MCP servers. Coral's own tools are included automatically. |

Model selection is constrained by the selected Koog client's known model catalogue. A proxy accepting an arbitrary model name does not guarantee the prototype client supports that model.

`proxy` and prompt values accept an inline string or `{ type = "option", name = "OPTION_NAME" }`. `iterations` and `delay` accept an inline integer or an integer option reference. Option references must name compatible options defined on this agent.

## Prompts and resources

The runtime starts with a system prompt and an initial user message. Later iterations receive the follow-up message while retaining the conversation. Prompt fields are:

- `prompts.system.base` and `prompts.system.extra`
- `prompts.loop.initial.base` and `prompts.loop.initial.extra`
- `prompts.loop.followup`

The default system prompt includes `<resource>coral://instruction</resource>` and `<resource>coral://state</resource>`. These placeholders are refreshed before each LLM call. When replacing `prompts.system.base`, include these placeholders to retain that context. Supplying `systemPrompt` on the session's agent request does not automatically append it to prototype prompts; configure the prototype's prompt fields and options explicitly.

The runtime requests tool calls from the LLM and executes those tools. Use an application-provided custom tool to return a report or request input; plain assistant text is not an application result callback.

## Additional MCP servers

```toml
[[runtimes.prototype.tools]]
type = "mcp_streamable_http"
url = "https://example.com/mcp"
auth.type = "bearer"
auth.token = { type = "option", name = "MCP_TOKEN" }

[options.MCP_TOKEN]
type = "string"
required = true
secret = true
```

Supported transports are `mcp_streamable_http` and legacy `mcp_sse`; stdio subprocess MCP servers are not supported here. Authentication supports `none`, `bearer` with `token`, and `authorization_header` with `header`. Configure HTTPS endpoints.

Prototype agents share the server process. Use Docker when you need custom agent code or container isolation. Bound execution with a session TTL as well as the iteration limit.
