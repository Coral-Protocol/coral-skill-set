# Server configuration

Source: https://docs.coralos.ai/reference/server

# Configuration tables

The Coral server is configured using configuration tables. The following tables are available:

| Table                                    | Description                                                                   |
|------------------------------------------|-------------------------------------------------------------------------------|
| [authentication](../reference/server/auth.md) | Configure access to the Coral server                                          |
| [cloud](../reference/server/cloud.md) | Coral Cloud integration |
| [llm-proxy](../reference/server/llm-proxy.md) | LLM providers, limits, and retries |
| [session](https://docs.coralos.ai/reference/server/session) | Agent wait-tool timeout |
| [console](../reference/server/console.md)     | Configuration for the built-in Coral console                                  |
| [debug](../reference/server/debug.md)         | Debugging configuration                                                       |
| [docker](../reference/server/docker.md)       | Docker runtime configuration                                                  |
| [logging](../reference/server/logging.md)     | Logging configuration                                                         |
| [network](../reference/server/network.md)     | Network configuration                                                         |
| [registry](../reference/server/registry.md)   | Agent registry configuration                                                  |

# Setting configuration options

Configuration options can be set through command-line arguments, environment variables, and a configuration file. Configuration options set in a higher priority method
will override options set in a lower priority method.

In order of priority, highest to lowest:

### 1. Command line

Options can be specified via the command line. Depending on how the Coral server is started, the command line options
may be specified in different ways, such as:

```bash title=Gradle
./gradlew run --args="--auth.keys=dev"
```

The syntax for specifying command line options is `--<table>.<key>=<value>`, `keys` can be specified in:
- lower case
- camel case
- snake case

### 2. Environment variables

Use two underscores between the table and the field: `NETWORK__BIND_PORT=5555` sets `network.bindPort`. Single underscores separate words inside a field. See the [environment variable reference](../configuration/environment-variables.md).

### 3. Configuration file

The Coral server will load a [TOML](https://toml.io/) configuration file from a path specified by the
`CONFIG_FILE_PATH` environment variable. There is no default location for the configuration file; if the environment
variable is not set, no configuration file will be loaded from disk. Custom builds can also bundle an optional `/config.toml` resource; the standard build uses code defaults.

__Example:__

```bash title="Environment variables"
CONFIG_FILE_PATH=/path/to/config.toml
```

```toml title=/path/to/config.toml
[auth]
keys = ["my access key"]
```

> **Warning:**
>
> If `CONFIG_FILE_PATH` is set, it must point to a valid and accessible configuration file.
>
> Pointing to an invalid configuration file will cause an error launching the Coral server.
