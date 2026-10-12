# Docker in Docker

Orchestrating Docker agents from inside Docker

Source: https://docs.coralos.ai/guides/production/docker-in-docker

In order to allow Coral Server to spin up containers while being inside a Docker container itself, we need to mount the host's Docker socket into our container.

Since Docker behaves differently on each platform - exactly how to do this varies:

> **Note:**
>
> You can override the host Docker socket that Coral Server uses via:
>
> - Environment variable: `DOCKER_SOCKET`
> - JVM system properties: `CORAL_DOCKER_SOCKET`, `docker.socket`, or `docker.host`
>
> By default, on Windows, Coral will use `npipe:////./pipe/docker_engine`; on macOS with Colima it will use `unix://~/.colima/default/docker.sock`; otherwise `unix:///var/run/docker.sock`.

# Linux

Mounting `/var/run/docker.sock` should be enough to give the server the ability to spin up containers.

```bash
docker run -v /var/run/docker.sock:/var/run/docker.sock ...
```

# macOS

We recommend you install [colima](https://github.com/abiosoft/colima) for a nicer experience. With colima, you can mount `~/.colima/default/docker.sock`:

```bash
docker run -v "$HOME/.colima/default/docker.sock:/var/run/docker.sock" ...
```

Without colima, you can mount `~/.docker/run/docker.sock` to the container:

```bash
docker run -v "$HOME/.docker/run/docker.sock:/var/run/docker.sock" ...
```

# Windows

On Windows, Docker uses a named pipe by default. Prefer mapping the named pipe into the container:

```bash
docker run \
  -v "//./pipe/docker_engine://./pipe/docker_engine" \
  ...
```

If you are using WSL2 or a setup that exposes a Unix socket, you may also mount `//var/run/docker.sock`:

```bash
docker run -v "//var/run/docker.sock://var/run/docker.sock" ...
```
