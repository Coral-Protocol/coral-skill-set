# Debug

Source: https://docs.coralos.ai/reference/server/debug

# Additional Docker environment variables
**default** empty map

> **Warning:**
>
> This configuration option cannot be specified via the command line.

```toml
[debug.additional_docker_environment]
MY_VAR_1 = "my value"
MY_VAR_2 = "my other value"
```

A map of additional environment variables that will be set and passed to agents that use the
[Docker runtime](../../reference/agent/tables/runtimes/docker.md). These variables will not overwrite Coral environment
variables or options.

# Additional Executable environment variables
**default** empty map

> **Warning:**
>
> This configuration option cannot be specified via the command line.

```toml
[debug.additional_executable_environment]
MY_VAR_1 = "my value"
MY_VAR_2 = "my other value"
```

A map of additional environment variables that will be set and passed to agents that use the
[Executable runtime](../../reference/agent/tables/runtimes/executable.md). These variables will not overwrite Coral environment
variables or options.
