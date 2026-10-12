# Running in Production

Deploying Coral Server, and securing it in production

Source: https://docs.coralos.ai/guides/production/running-in-production

# Deploying Coral Server

The first step to running Coral Server in production is having a proper deployment of it. Exactly how you manage & deploy it depends on your application, but we offer a [docker image](https://github.com/Coral-Protocol/coral-server/pkgs/container/coral-server) for Coral Server, and support orchestrating agents via Docker.

## Docker (recommended)
Coral Server reads its main configuration from a TOML file specified by the `CONFIG_FILE_PATH` environment variable. When running from our provided Docker image, set `CONFIG_FILE_PATH` to `/config/config.toml` and mount a directory there.

Agent discovery (the "registry") is configured inside `config.toml` via `registry.localAgents` glob patterns that point to directories containing `coral-agent.toml` files. There is no separate `REGISTRY_FILE_PATH` or `registry.toml` file.

Create directories for the server configuration and your agent definitions:

```bash
mkdir -p my-config agents/my-agent
# Place the agent's coral-agent.toml under agents/my-agent/.
```

Write `my-config/config.toml` before starting the server. Replace the example auth key and configure an LLM provider if your agents request one:

```toml
[auth]
keys = ["replace-with-a-long-random-key"]

[registry]
localAgents = ["/agents/*"]
includeCoralHomeAgents = false
includeDebugAgents = false
watchLocalAgents = true

[console]
enabled = false
```

For Docker agents, make the Docker daemon available as described in [Docker in Docker](../../guides/production/docker-in-docker.md). On Linux with the standard socket:

```bash
docker run --rm \
  -p 127.0.0.1:5555:5555 \
  -v "$PWD/my-config:/config:ro" \
  -v "$PWD/agents:/agents:ro" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e CONFIG_FILE_PATH=/config/config.toml \
  ghcr.io/coral-protocol/coral-server:latest
```

This binds the host-facing API to loopback. For a remote application or agents, expose the API through your deployment's network and authenticated HTTPS ingress, and configure an address that agent containers can actually reach. In particular, set `docker.address` when the default host gateway is not the machine running Coral.

Agents using filesystem option transport require their temporary files to be visible at the same host paths to the Docker daemon. With a mounted host socket, container filesystem paths are not automatically host paths; use a shared directory mounted at the same absolute path and set the server JVM's `java.io.tmpdir` there. A remote daemon needs equivalent shared storage.

> **Warning:**
>
> Our provided docker image is *very* minimal! This means you should **not** (and usually can't) run agents through the `executable` runtime - and should use Docker orchestration for custom agent code. The built-in prototype runtime is also available without a child container.
>
> This is intended, as Docker orchestration is more stable, reproducible & portable - well suited for production.

> **Note:**
>
> See [Docker in Docker](../../guides/production/docker-in-docker.md) for steps to support Docker orchestration from inside Docker

## Java

Clone the repo and build the jar file:

```bash
git clone https://github.com/Coral-Protocol/coral-server.git
cd coral-server

./gradlew build --no-daemon -x test
# the resulting .jar will end up in build/libs/coral-server-[..].jar
```

Use JDK 24. Create a configuration file containing at least `[auth]` and `keys`, as shown above, then run the actual built artifact from the repository root:

```bash
export CONFIG_FILE_PATH="$PWD/../coral-config/config.toml"
# Create and populate that file before running this command.
java -jar build/libs/coral-server-1.5.0.jar
```

For a different checkout, use the version in its `gradle.properties` and the corresponding file in `build/libs`. For reproducible deployments, select an actually published version-plus-commit image tag or pin an image digest. Do not assume a bare `1.5.0` or `v1.5.0` image tag exists; the workflow publishes branch, version-plus-commit, and build-number tags. The `latest` command above is a starting point, not a release pin.

> **Info:**
>
> You should also consider writing a [systemd service](https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html) (or something similar) that runs your jar file for more reliable deployments.
