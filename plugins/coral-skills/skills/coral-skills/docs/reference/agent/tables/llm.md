# [llm]

Agent LLM requirements

Source: https://docs.coralos.ai/reference/agent/tables/llm

### llm.proxies
**optional**

An array of [AgentLlmProxyRequest](../../../reference/types/agent-llm-proxy-request.md) describing requests for LLM proxies to be used by this
agent. The [AgentLlmProxyRequest](../../../reference/types/agent-llm-proxy-request.md) page serves as the documentation for this array.

All proxies listed must be satisfied for the server to launch the agent. Application developers that attempt to create
sessions with agents that request unavailable proxies will receive an error.

```toml
[[llm.proxies]]
name = "OPENAI"
format.type = "OpenAI"
models = ["gpt-5"]

[[llm.proxies]]
name = "ANTHROPIC"
format.type = "Anthropic"
models = ["claude-3-opus"]
```

__Requirements__
- There may be at most 16 proxy requests defined.
