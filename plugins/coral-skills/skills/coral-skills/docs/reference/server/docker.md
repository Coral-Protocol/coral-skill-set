# Docker

Source: https://docs.coralos.ai/reference/server/docker

# Socket
**default** see below:

The default value for this is calculated in the following order, taking the first value that is specified:
1. The JVM system property `CORAL_DOCKER_SOCKET`
2. The JVM system property `docker.host`
3. The environment variable `DOCKER_SOCKET`
4. The JVM system property `docker.socket`
5. `npipe:////./pipe/docker_engine`, but only if the OS is Windows
6. `unix://$HOME/.colima/default/docker.sock` if it exists
7. `unix:///var/run/docker.sock`

- Command line: `--docker.socket="unix:///custom/path/to/docker.sock"`
- Config file: `docker.socket = "unix:///custom/path/to/docker.sock"`

The Docker socket that Coral will execute Docker runtimes via. This value should almost always be left as the default.

# Address
**default** see below:

The default value for Windows is always `host.docker.internal`.

On other systems, the default is `host.docker.internal` when `$HOME/.colima/default/docker.sock` exists, and `172.17.0.1` otherwise.

- Command line: `--docker.address="1.1.1.1"`
- Config file: `docker.address = "1.1.1.1"`

The address that Docker runtimes will use to communicate with the Coral server. Different container runtimes may use
different values to communicate with the host; if a specific container runtime is used that requires a different address, it
must be specified here.

This must also be specified if the container runtime is on another machine; in which case this address should be the
public address of the machine running the Coral server.

# Response timeout
**default** `30`

- Command line: `--docker.response-timeout=60`
- Config file: `docker.response_timeout = 60`

The number of seconds before the Coral server times out when trying to communicate with the container runtime.

# Connection timeout
**default** `30`

- Command line: `--docker.connection-timeout=60`
- Config file: `docker.connection_timeout = 60`

The number of seconds before the Coral server times out when trying to connect to the container runtime. Note
that this timeout will always be reached if the container runtime is not running.

# Max connections
**default** `1024`

- Command line: `--docker.max-connections=2000`
- Config file: `docker.max_connections = 2000`

The maximum number of connections that the Coral server can make to containers. Each agent running using a Docker
runtime requires one connection. This value should be large enough to accommodate the number of agents that will be
running on the Coral server at any one time.

# Container path separator
**default** `:`

- Command line: `--docker.container-path-separator=";"`
- Config file: `docker.container_path_separator = ";"`

The character that is used for separating multiple paths in a running container. This must be changed to `;` when running
Windows containers. This should __NOT__ be set to `;` if running Linux containers on a Windows host.

# Container name separator
**default** `/`

- Command line: `--docker.container-name-separator=";"`
- Config file: `docker.container_name_separator = ";"`

The character that is used to separate path names on a running container. This can be changed to `\` when running
Windows containers. Note that this should __NOT__ be set to `\` if running Linux containers on a Windows host.

# Container temporary directory
**default** `/tmp`

- Command line: `--docker.container-temporary-directory="/custom-tmp-directory"`
- Config file: `docker.container_temporary_directory = "/custom-tmp-directory"`

The directory on a running container that is used for temporary files.
