# LlmProxyProviderConfig

Source: https://docs.coralos.ai/reference/types/llm-proxy-provider-config

A definition for an LLM proxy provider.  This type is only used in the [llm-proxy.providers](../../reference/server/llm-proxy.md#providers) server config.

> **Tip:**
>
> Configuration of LLM proxy providers can be skipped by providing a [Coral Cloud API
> key](../../reference/server/cloud.md#api-key).

Any agent that has defined [LLM proxy requests](../../reference/types/agent-llm-proxy-request.md) requires the server to have a suitable LLM proxy provider configured for every request.

### name
**required**

The name of the LLM proxy provider.  This must be unique.  Application developers can request the usage of a specific LLM proxy provider by specifying this name in the [proxies map](../../api-reference/schemas.md#graphagentrequest).

### format.type
**required**

```toml
[[llm-proxy.providers]]
name = "My OpenAI Provider"
format.type = "OpenAI"
# ...
```

The LLM provider format.  Current supported types are:
- `OpenAI`
- `Anthropic`
- `DeepSeek`

### models
**optional**

```toml
[[llm-proxy.providers]]
name = "My OpenAI Provider"
format.type = "OpenAI"
models = ["gpt-4.1-mini", "gpt-5-mini"]
allow_any_model = true
# ...
```

An array of models that this provider supports.  This may be omitted if [allow_any_model](#allow_any_model) is set to `true`.  Note that if this is
empty, the default value of [allow_any_model](#allow_any_model) is `true`.

### api_key
**required**

```toml
[[llm-proxy.providers]]
name = "My OpenAI Provider"
format.type = "OpenAI"
api_key = "sk-..."
# ...
```

The API key to use for this provider.

### base_url
**required**

```toml
[[llm-proxy.providers]]
name = "My OpenAI Provider"
format.type = "OpenAI"
base_url = "https://api.openai.com"
# ...
```

The base URL to use for this provider.  Requests will be made to this URL with the path of the request appended.

The proxy appends the agent's request path without removing or inserting a version prefix. Configure the provider base and the agent SDK's base URL together.

For the built-in prototype runtime's OpenAI client (and the Koog template), requests contain `v1/chat/completions`; use `https://api.openai.com` as the provider base. Setting that provider base to `https://api.openai.com/v1` produces `/v1/v1/chat/completions`.

An SDK that sends only `chat/completions` instead needs the provider base to include `/v1`, or the SDK base URL to add `/v1` after `CORAL_PROXY_URL_<NAME>`. Confirm the actual upstream path when adapting a new client. The same rule applies to Anthropic's `/v1/messages` endpoint and other compatible providers.

The `format.type` selects request authentication and usage parsing; it does not translate arbitrary provider APIs into OpenAI or Anthropic APIs.

### timeout
**default** `10m`
**optional**

```toml
[[llm-proxy.providers]]
name = "My OpenAI Provider"
format.type = "OpenAI"
timeout = "30s"
# ...
```

See [here](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.time/-duration/-companion/parse.html) for more information on the duration format.

A timeout for requests made to this provider.  Slower providers may require a longer timeout.

### allow_any_model
**optional**

```toml
[[llm-proxy.providers]]
name = "My OpenAI Provider"
format.type = "OpenAI"
allow_any_model = true
# ...
```

If `true`, this provider will match a request for any model that matches the specified [format](#format-type).  This is useful for defining fallback providers that can handle many models, e.g., OpenRouter.

Resolution of [AgentLlmProxyRequest](../../reference/types/agent-llm-proxy-request.md) will prioritize providers that have explicitly specified a model over providers that allow any model.

The default value is `false` if [models](#models) contains at least one model and `true` otherwise.
