# LLM proxy

Source: https://docs.coralos.ai/reference/server/llm-proxy

# Retry attempts
**default** `0`

- Command line: `--llm-proxy.retry-max-attempts=10`
- Config file: `llm-proxy.retry_max_attempts = 10`

If configured to be a value greater than 0, failed proxied LLM requests made to the Coral Server will be retried up to the specified number of times.

The delay between retries is exponential, see:
- [Retry base delay](#retry-base-delay)
- [Retry delay exponent](#retry-delay-exponent)
- [Retry attempts](#retry-attempts)
- [Retry max delay](#retry-max-delay).

# Retry base delay
**default** `1s`

- Command line: `--llm-proxy.retry-base-delay="3s"`
- Config file: `llm-proxy.retry_base_delay = "3s"`

See [here](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.time/-duration/-companion/parse.html) for more information on the duration format.

If an LLM proxy request fails to reach the configured LLM provider, the request may be retried.

This value serves as the initial delay for the first retry, and, for every subsequent retry, the delay will be increased exponentially by [Retry delay exponent](#retry-delay-exponent).

With the following configuration:

- [Retry base delay](#retry-base-delay) of `1s`
- [Retry delay exponent](#retry-delay-exponent) of `2.0`
- [Retry max delay](#retry-max-delay) of `10s`

Delays between retries will be:
1. `1s`
2. `2s`
3. `4s`
4. `8s`
5. `10s`

# Retry delay exponent
**default** `2.0`

- Command line: `--llm-proxy.retry-delay-exponent=2.0`
- Config file: `llm-proxy.retry_delay_exponent = 2.0`

The exponent applied to [Retry base delay](#retry-base-delay) between retries.  The exponent is applied after the first retry.  The value must be a floating point number.

# Retry max delay
**default** `10s`

- Command line: `--llm-proxy.retry-max-delay="30s"`
- Config file: `llm-proxy.retry_max_delay = "30s"`

See [here](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.time/-duration/-companion/parse.html) for more information on the duration format.

The maximum delay between retries.  This caps the exponential delay configured with [Retry base delay](#retry-base-delay) and [Retry delay exponent](#retry-delay-exponent).

# Max request size
**default** `20MiB`

- Command line: `--llm-proxy.max-request-size="10KiB"`
- Config file: `llm-proxy.max_request_size = "10KiB"`

A [ByteSize](../../reference/types/byte-size.md) value representing the maximum size of a request that can be proxied to an LLM provider.  Requests made larger
than this size will be rejected.

# Max response size
**default** `80MiB`

- Command line: `--llm-proxy.max-response-size="1MiB"`
- Config file: `llm-proxy.max_response_size = "1MiB"`

A [ByteSize](../../reference/types/byte-size.md) value representing the maximum size of a response that can be read from a proxied LLM provider.  Responses larger
than this size will be rejected, and the LLM request will receive an error.

# Max stream size
**default** `80MiB`

- Command line: `--llm-proxy.max-stream-size="1MiB"`
- Config file: `llm-proxy.max_stream_size = "1MiB"`

A [ByteSize](../../reference/types/byte-size.md) value representing the maximum size of a response that can be read from a proxied LLM provider via an SSE stream.  This value
is cumulative across the lifetime of the SSE stream.  Responses larger than this size will be rejected, and the LLM request will receive an error.

# Providers
**default** empty array

> **Tip:**
>
> Setting a [Coral Cloud API key](../../reference/server/cloud.md#api-key) will automatically configure Coral Server LLM
> proxies for supported Coral Cloud LLM providers and models.

> **Warning:**
>
> LLM Proxy providers cannot be configured from the command line.

```toml
[[llm-proxy.providers]]
name = "My OpenAI Provider"
format.type = "OpenAI"
api_key = "..."
base_url = "https://api.openai.com"
models = ["gpt-4.1-mini", "gpt-5-mini"]

[[llm-proxy.providers]]
name = "Default Anthropic"
format.type = "Anthropic"
api_key = "..."
base_url = "https://api.anthropic.com"
models = ["claude-opus-4-6", "claude-sonnet-4-0"]
```

These base URLs assume clients that send the `/v1/...` path, including the built-in prototype OpenAI client. See [base URL composition](../../reference/types/llm-proxy-provider-config.md#base_url) when using a different SDK.

An array of [LlmProxyProviderConfig](../../reference/types/llm-proxy-provider-config.md) objects.
