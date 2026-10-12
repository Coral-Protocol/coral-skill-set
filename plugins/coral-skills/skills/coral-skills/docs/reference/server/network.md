# Network

Source: https://docs.coralos.ai/reference/server/network

# Bind address
**default** `0.0.0.0`

- Command line: `--network.bind-address="111.111.111.111"`
- Config file: `network.bind_address = "111.111.111.111"`

The IP address that the Coral server will bind to. The Coral server API will be available on this address.

# External address
**default** value of [bind address](#bind-address)

- Command line: `--network.external-address="111.111.111.111"`
- Config file: `network.external_address = "111.111.111.111"`

The remote IP address of the Coral server. This IP address is given to Coral agents. This is useful if the Coral agents
are launched on separate machines, such as within a Kubernetes cluster.

# Bind port
**default** `5555`

- Command line: `--network.bind-port=1234`
- Config file: `network.bind_port = 1234`

The port that the Coral server will bind to. Only TCP traffic is used by the Coral server.

In v1.5.0, command-line conversion of this unsigned value rejects ports above 32767. Configure higher ports as a numeric `bindPort` in `config.toml`; that file-based path supports them.

# Allow any host
**default** `false`

- Command line: `--network.allow-any-host=true`
- Config file: `network.allow_any_host = true`

Controls the CORS policy for the Coral server API. This should only be set to `true` during development.

# Webhook secret
**default** v4 UUID

- Command line: `--network.webhook-secret="mySecret"`
- Config file: `network.webhook_secret = "mySecret"`

A secret used to sign webhook requests. Webhooks will contain a HmacSHA256 signature of the payload in the
`X-Coral-Signature` header. This secret should be verified by the recipient of the webhook.

# Custom tool secret
**default** v4 UUID

- Command line: `--network.custom-tool-secret="mySecret"`
- Config file: `network.custom_tool_secret = "mySecret"`

A secret used to sign agent custom tool calls. Agent custom tool calls will contain a HmacSHA256 signature of the
payload in the `X-Coral-Signature` header. This secret should be verified by the recipient of the webhook.
