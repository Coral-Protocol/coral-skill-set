# LLM proxying

Source: https://docs.coralos.ai/concepts/proxy

LLM proxying is a process where agents send requests to an intermediate server rather than directly to an LLM provider.
The intermediate server analyzes LLM requests and responses to provide additional features to agents and applications.

CoralOS has two distinct LLM proxies, for Coral Cloud and Coral Server.

# Coral Cloud

Coral Cloud is a service that allows users to quickly run Coral sessions using managed Coral servers.  All costs associated with
Coral Cloud sessions consume Coral Cloud tokens. One of the ways that Coral Cloud centralizes cost is by providing an LLM proxy.

The Coral Cloud LLM proxy allows Coral users to make LLM requests that consume Coral Cloud tokens rather than various
other tokens from other providers.

The Coral Cloud LLM proxy can be used in the Coral server by adding an API key to the Coral server's config file:
```toml
[cloud]
api_key = "my Coral Cloud API key"
```

Read more about Cloud configuration on the server [here](../reference/server/cloud.md).

# Coral Server

The Coral server also offers an LLM proxy to the agents that it runs.  Passing LLM traffic through the Coral server
provides a number of benefits, such as:

- Automatic agent telemetry collection
- Eliminating the agent's need to hold LLM provider keys
- Agent cost control
- Agent model and provider substitution
- LLM provider fallbacks
- LLM provider key cycling

Read more about how to configure agents to use the Coral server LLM proxy [here](../reference/agent/tables/llm.md#llm-proxies) and how to
configure LLM proxies on the Coral server [here](../reference/server/llm-proxy.md).
