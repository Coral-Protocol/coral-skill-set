# AgentLlmProxyRequest

An agent's request for an LLM proxy.

Source: https://docs.coralos.ai/reference/types/agent-llm-proxy-request

An AgentLlmProxyRequest is a type used exclusively in the [llm.proxies](../../reference/agent/tables/llm.md#llm-proxies) array to specify the requirement of an LLM proxy.

In [Docker](../../reference/agent/tables/runtimes/docker.md) and [Executable](../../reference/agent/tables/runtimes/executable.md) runtimes, a resolved LLM proxy request sets
`CORAL_PROXY_URL_<NAME>`, `CORAL_PROXY_FORMAT_<NAME>`, and `CORAL_PROXY_MODEL_<NAME>`. For example, the request:

```toml
[[llm.proxies]]
name = "MAIN"
format.type = "OpenAI"
models = ["gpt-5.3", "gpt-5.2", "gpt-5"]
```

Could produce the following environment variables:
```bash
# Should be used as the baseURL in LLM requests
CORAL_PROXY_URL_MAIN=...

CORAL_PROXY_FORMAT_MAIN=OpenAI
CORAL_PROXY_MODEL_MAIN=gpt-5.2
````

> **Warning:**
>
> The server will not launch agents that it cannot resolve proxies for!

### name
**required**

```toml
[[llm.proxies]]
name = "MAIN"
format.type = "OpenAI"
```

The name of the proxy request.

__Requirements__
- The name must be between 1 and 32 characters long.
- The name must contain only uppercase alphanumeric characters and underscores.
- The name must be unique.

### format.type
**required**

The LLM request format.  Current supported types are:
- `OpenAI`
- `Anthropic`
- `DeepSeek`

```toml
[[llm.proxies]]
name = "MAIN"
format.type = "Anthropic"
```

### models
**required**

A list of models that this request will accept.  Only one of the listed models will be used.

__Requirements__
- The name of a model must be between 1 and 128 characters long.
- There must be 32 or fewer models listed.
