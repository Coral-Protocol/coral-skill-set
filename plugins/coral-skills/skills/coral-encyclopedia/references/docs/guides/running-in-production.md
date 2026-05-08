---
title: "Running in Production"
description: "Deploying Coral Server, and securing it in production"
sidebarTitle: "Running in Production"
---
# Deploying Coral Server
The first step to running Coral Server in production is having a proper deployment of it. Exactly how you manage & deploy it depends on your application, but we offer a [docker image ](https://github.com/Coral-Protocol/coral-server/pkgs/container/coral-server) for Coral Server, and support orchestrating agents via Docker.
## Docker (recommended)
Coral Server reads its main configuration from a TOML file specified by the `CONFIG_FILE_PATH` environment variable. When running from our provided Docker image, set `CONFIG_FILE_PATH` to `/config/config.toml` and mount a directory there.
Agent discovery (the "registry") is configured inside `config.toml` via `registry.localAgents` glob patterns that point to directories containing `coral-agent.toml` files. There is no separate `REGISTRY_FILE_PATH` or `registry.toml` file.
For that reason - the easiest way to configure Coral Server, is by creating a config folder & [mounting ](https://docs.docker.com/engine/storage/bind-mounts/) that to `/config` when running:
```bash
# create your config dir, that our config.toml will live inside
mkdir my-config
touch my-config/config.toml # create an empty file for now
# (optional) create an agents directory you want the server to scan
mkdir -p agents/my-agent
# place one or more coral-agent.toml files under agents/*/
# run the server, mounting config and (optionally) your agents directory
docker run \
  -p 5555:5555 \
  -v ./my-config:/config \
  -v ./agents:/agents \
  -e CONFIG_FILE_PATH=/config/config.toml \
  ghcr.io/coral-protocol/coral-server:latest
```
Example `config.toml` snippet to scan your mounted agents directory:
```toml
[registry]
localAgents = [ "/agents/*/*" ]
watchLocalAgents = true
```
> **Warning:** 
Our provided docker image is *very* minimal! This means you should **not** (and usually can't) run agents through the `executable` runtime - and should use Docker orchestration instead.
This is intended, as Docker orchestration is more stable, reproducible & portable - well suited for production.
> **Note:** 
See [Docker in Docker](/guides/docker-in-docker) for steps to support Docker orchestration from inside Docker
## Java
Clone the repo and build the jar file:
```bash
git clone https://github.com/Coral-Protocol/coral-server.git
cd coral-server
./gradlew build --no-daemon -x test
# the resulting .jar will end up in build/libs/coral-server-[..].jar
```
During development, a default `config.toml` may be bundled as a resource. There is no separate `registry.toml`; instead, agent discovery is configured via `registry.localAgents` inside `config.toml`.
Coral Server reads its main configuration from the path in `CONFIG_FILE_PATH`. For local development, a default `config.toml` may be bundled as a resource, but there is no separate `registry.toml`. Configure agent discovery via `registry.localAgents` inside `config.toml`.
In production, we recommend you set `CONFIG_FILE_PATH` to somewhere more easily accessible (and not in the cloned repo folder):
```bash
# make a folder outside of the repo folder, that our config.toml will live inside
mkdir ../coral-config/
# and point at that folder when running Coral Server
export CONFIG_FILE_PATH=../coral-config/config.toml
java -jar "coral-server-1.1.0.jar"
```
> **Info:** You should also consider writing a [systemd service ](https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html) (or something similar) that runs your jar file for more reliable deployments.
