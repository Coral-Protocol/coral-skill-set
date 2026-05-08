# Server Configuration Reference

---
title: Server configuration
---
# Configuration tables
The Coral server is configured using configuration tables. The following tables are available:
| Table                                    | Description                                                                   |
|------------------------------------------|-------------------------------------------------------------------------------|
| [authentication](/reference/server/auth) | Configure access to the Coral server                                          |
| [console](/reference/server/console)     | Configuration for the built-in Coral console                                  |
| [debug](/reference/server/debug)         | Debugging configuration                                                       |
| [docker](/reference/server/docker)       | Docker runtime configuration                                                  |
| [logging](/reference/server/logging)     | Logging configuration                                                         |
| [network](/reference/server/network)     | Network configuration                                                         |
| [registry](/reference/server/registry)   | Agent registry configuration                                                  |
# Setting configuration options
Configuration options can be set with two different methods. Configuration options set in a higher priority method
will override options set in a lower priority method.
In order of priority, highest to lowest:
### 1. Command line
Options can be specified via the command line. Depending on how the Coral server is started, the command line options
may be specified in different ways, such as:
```bash title=Gradle
./gradlew run --args="--auth.keys=dev"
```
```bash title=NPM
npx coralos-dev@latest -- server start -- --auth.keys="dev"
```
The syntax for specifying command line options is `--<table>.<key>=<value>`, `keys` can be specified in:
- lower case
- camel case
- snake case
### 2. Configuration file
The Coral server will load a [TOML](https://toml.io/) configuration file from a path specified by the
`CONFIG_FILE_PATH` environment variable. There is no default location for the configuration file; if the environment
variable is not set, no configuration file will be loaded.
__Example:__
```bash title="Environment variables"
CONFIG_FILE_PATH=/path/to/config.toml
```
```toml title=/path/to/config.toml
[auth]
keys = ["my access key"]
```
> **Warning:** 
    If `CONFIG_FILE_PATH` is set, it must point to a valid and accessible configuration file.
    Pointing to an invalid configuration file will cause an error launching the Coral server.

---

## Auth Configuration

---
title: Authentication
---
# Keys
 empty list <br/>
<ServerConfigList table="auth" config="keys" examples={["\"key1\"", "\"key2\""]} />
Auth keys are used to authenticate requests made to the Coral server. These keys allow full access to the Coral server and
its APIs. The keys should be kept secret.
Using the Coral console also requires a key.
> **Info:** 
    There are no keys set by default. At least one key must be set to effectively use the Coral server.

---

## Network Configuration

---
title: Network
---
# Bind address
 `0.0.0.0` <br/>
<ServerConfigSingle table="network" config="bindAddress" example="&quot;111.111.111.111&quot;" />
The IP address that the Coral server will bind to. The Coral server API will be available on this address.
# External address
 value of [bind address](#bind-address) <br/>
<ServerConfigSingle table="network" config="externalAddress" example="&quot;111.111.111.111&quot;" />
The remote IP address of the Coral server. This IP address is given to Coral agents. This is useful if the Coral agents
are launched on separate machines, such as within a Kubernetes cluster.
# Bind port
 `5555` <br/>
<ServerConfigSingle table="network" config="bindPort" example="1234" />
The port that the Coral server will bind to. Only TCP traffic is used by the Coral server.
# Allow any host
 `false` <br/>
<ServerConfigSingle table="network" config="allowAnyHost" example="true" />
Controls the CORS policy for the Coral server API. This should only be set to `true` during development.
# Webhook secret
 v4 UUID <br/>
<ServerConfigSingle table="network" config="webhookSecret" example="&quot;mySecret&quot;" />
A secret used to sign webhook requests. Webhooks will contain a HmacSHA256 signature of the payload in the
`X-Coral-Signature` header. This secret should be verified by the recipient of the webhook.
# Custom tool secret
 v4 UUID <br/>
<ServerConfigSingle table="network" config="customToolSecret" example="&quot;mySecret&quot;" />
A secret used to sign agent custom tool calls. Agent custom tool calls will contain a HmacSHA256 signature of the
payload in the `X-Coral-Signature` header. This secret should be verified by the recipient of the webhook.

---

## Registry Configuration

---
title: Registry
---
# Local agents
 empty list <br/>
<ServerConfigList table="registry" config="localAgents" examples={["\"/path/to/agent\"", "\"/all/my/agents/*\""]} />
A list of paths to agents on the local machine. Any agent included in this list will be available to the Coral server
in the local agent registry source.
Consider the following directory structure:
    <Tree.Folder name="/path/to/agents" defaultOpen>
        <Tree.Folder name="agent1" defaultOpen>
            <Tree.File name="coral-agent.toml"/>
        </Tree.Folder>
        <Tree.Folder name="agent2" defaultOpen>
            <Tree.File name="coral-agent.toml"/>
        </Tree.Folder>
        <Tree.Folder name="agent3" defaultOpen>
            <Tree.File name="coral-agent.toml"/>
        </Tree.Folder>
    </Tree.Folder>
Adding just `agent1` could be done with:
```toml
[registry]
local_agents = ["/path/to/agents/agent1"]
```
Adding all agents (`agent1`, `agent2` and `agent3`) could be done with:
```toml
[registry]
local_agents = ["/path/to/agents/*"]
```
Sometimes, you may want to use multiple wildcard paths, for example if you keep your agents in folders with versions:
    <Tree.Folder name="/path/to/agents" defaultOpen>
        <Tree.Folder name="agent1" defaultOpen>
            <Tree.Folder name="1.0.0" defaultOpen>
                <Tree.File name="coral-agent.toml"/>
            </Tree.Folder>
            <Tree.Folder name="1.0.1" defaultOpen>
                <Tree.File name="coral-agent.toml"/>
            </Tree.Folder>
        </Tree.Folder>
        <Tree.Folder name="agent2" defaultOpen>
            <Tree.Folder name="1.0.0" defaultOpen>
                <Tree.File name="coral-agent.toml"/>
            </Tree.Folder>
            <Tree.Folder name="1.0.1" defaultOpen>
                <Tree.File name="coral-agent.toml"/>
            </Tree.Folder>
        </Tree.Folder>
    </Tree.Folder>
This can be facilitated with:
```toml
[registry]
local_agents = ["/path/to/agents/*/*"]
```
> **Warning:** 
    The wildcard `*` is not permitted as part of a path segment, only as a full path segment.
    <br />
     Good
    ```toml
    [registry]
    local_agents = ["/path/to/agents/*/*"]
    ```
     Bad
    ```toml
    [registry]
    local_agents = ["/path/to/agents*"]
    ```
# Include Coral home agents
 `true` <br/>
<ServerConfigSingle table="registry" config="includeCoralHomeAgents" example="false" />
If this is set to `true`, the following directories will be added to [local agents](#local-agents):
- `${HOME}/.coral/agents/*/*`
- `${HOME}/.coral/agents/*`
- `${HOME}/.coral/agents/locallinked/*/*`
It is recommended to use this configuration option instead of manually adding the above paths to [local agents](#local-agents).
# Watch local agents
 `true` <br/>
<ServerConfigSingle table="registry" config="watchLocalAgents" example="false" />
If this is set to true, modifications to local agents will be automatically detected and reloaded.
Detected changes include:
- Deletion of an agent
- Modification of an agent
- New agents (for example, those that match a path that uses a wildcard)
> **Warning:** 
    It is possible due to a JVM limitation that changes to agents, especially those made programmatically, are not
    detected via this watch option. Consider setting [local agent rescan timer](#local-agent-rescan-timer) to a
    non-zero value.
# Local agent rescan timer
<ServerConfigSingle table="registry" config="localAgentRescanTimer" example="&quot;30s&quot;" />
See [here](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.time/-duration/-companion/parse.html) for more information on the format.
If this is set to a non-zero value, the Coral server will periodically rescan the local agent registry for changes.
Scanning the filesystem can be expensive, especially if the [local agents](#local-agents) list contains many paths with
wildcards. Consider setting this to a high value or disabling it entirely.
# Include debug agents
 `true` <br/>
<ServerConfigSingle table="registry" config="includeDebugAgents" example="false" />
If this is true, the Coral server [debug agents](/guides/debugging#built-in-debug-agents) will be available in the
server's local agent registry source.
# Include marketplace agents
 `true` <br/>
<ServerConfigSingle table="registry" config="includeMarketplaceAgents" example="false" />
If this is true, the Coral server will be able to directly use agents from the [Marketplace](/concepts/marketplace).

---

## Logging Configuration

---
title: Logging
---
# Log buffer size
 `32768` <br/>
<ServerConfigSingle table="logging" config="logBufferSize" example="1000" />
The maximum number of log entries to keep in memory. This buffer is used for all log messages, including those sent by
agents. Note that the Coral console log view for an agent only applies a filter to the log buffer, so, if you desire
1000 log entries per agent, the buffer must be `1000` x `number of agents` + extra for system log entries.
Consider adjusting this value only after you experience loss of log entries in the Coral console.
# Max replay
 `2048` <br/>
<ServerConfigSingle table="logging" config="maxReplay" example="1000" />
The maximum number of log entries that will be sent to a new subscriber. Note that opening a Coral console agent log
view counts as a new subscription; this value caps the number of messages that appear in that view.
# Console log level
 `INFO` <br/>
<ServerConfigSingle table="logging" config="consoleLogLevel" example="&quot;TRACE&quot;" />
The maximum log level that will be printed to the server's console.
Valid values, in order of increasing verbosity:
- `ERROR`
- `WARN`
- `INFO`
- `DEBUG`
- `TRACE`
# File log level
 `INFO` <br/>
<ServerConfigSingle table="logging" config="fileLogLevel" example="&quot;TRACE&quot;" />
The maximum log level that will be printed to the disk. Note [enable file logging](#enable-file-logging) must be true to
write any messages to disk.
Valid values, in order of increasing verbosity:
- `ERROR`
- `WARN`
- `INFO`
- `DEBUG`
- `TRACE`
# Enable file logging
 `true` <br/>
<ServerConfigSingle table="logging" config="logToFileEnabled" example="false" />
If this is true, log messages will be written to a file on disk. The directory, number of log files, log file size and
other file logging options are further configurable using:
- [Log files directory](#log-files-directory)
- [Log file name](#log-file-name)
- [Log file name pattern](#log-file-pattern)
- [Max history](#max-history)
- [Log total size cap](#log-total-size-cap)
- [Clear log files on server start](#clear-log-files-on-server-start)
- [Max file size](#max-file-size)
- [File log level](#file-log-level)
# Log files directory
 `${HOME}/.coral/logs` <br/>
<ServerConfigSingle table="logging" config="logFilesDirectory" example="&quot;/var/log/coral&quot;" />
The directory where log files will be written. Note that the full path to a given log file may be different from the
value of this setting, see:
- [Log file name](#log-file-name)
- [Log file name pattern](#log-file-pattern)
# Log file name
 `${logFilesDirectory}/server.log` <br/>
<ServerConfigSingle table="logging" config="logFileName" example="&quot;/var/log/coral/server.log&quot;" />
The full path to the log file.  Read more [here](https://logback.qos.ch/manual/appenders.html#fileAppenderFile).
# Log file name pattern
 `${logFilesDirectory}/archive/%d{yyyy/MM, aux}/%d{yyyy-MM-dd}.%i.log.gz` <br/>
<ServerConfigSingle table="logging" config="logFileNamePattern" example="&quot;/var/log/coral/archive/%d{yyyy/MM, aux}/%d{yyyy-MM-dd}.%i.log.gz&quot;" />
The pattern for archived log files. Read more [here](https://logback.qos.ch/manual/appenders.html#tbrpFileNamePattern).
# Max history
 `12` <br/>
<ServerConfigSingle table="logging" config="maxHistory" example="20" />
The maximum number of archived log files to keep. Read more [here](https://logback.qos.ch/manual/appenders.html#tbrpMaxHistory).
# Log total size cap
 `3GB` <br/>
<ServerConfigSingle table="logging" config="logTotalSizeCap" example="&quot;1GB&quot;" />
The maximum total size of all archived log files. Read more [here](https://logback.qos.ch/manual/appenders.html#tbrpTotalSizeCap).
# Clear log files on server start
 `false` <br/>
<ServerConfigSingle table="logging" config="logClearHistoryOnStart" example="true" />
If this is true, archived log files that are configured to be deleted will be deleted when the server starts. Read more [here](https://logback.qos.ch/manual/appenders.html#tbrpCleanHistoryOnStart).
# Max file size
 `10MB` <br/>
<ServerConfigSingle table="logging" config="maxFileSize" example="&quot;5MB&quot;" />
The maximum size of the current log file; when the current log file hits this size, the log file will be archived. Read more [here](https://logback.qos.ch/manual/appenders.html#maxFileSize).

---

## Docker Configuration

---
title: Docker
---
# Socket
 see below:<br/>
The default value for this is calculated in the following order, taking the first value that is specified:
1. The environment variable `CORAL_DOCKER_SOCKET`
2. The JVM system property `docker.host`
3. The environment variable `DOCKER_SOCKET`
4. The JVM system property `docker.socket`
5. `npipe:////./pipe/docker_engine`, but only if the OS is Windows
6. `$HOME/.colima/default/docker.sock` if it exists
7. `unix:///var/run/docker.sock`
<ServerConfigSingle table="docker" config="socket" example="&quot;unix:///custom/path/to/docker.sock&quot;" />
The Docker socket that Coral will execute Docker runtimes via. This value should almost always be left as the default.
# Address
 see below:<br/>
The default value for Windows is always `host.docker.internal`.
If the operating system is not Windows and `$HOME/.colima/default/docker.sock` exists, the default value is `172.17.0.1`
<ServerConfigSingle table="docker" config="address" example="&quot;1.1.1.1&quot;" />
The address that Docker runtimes will use to communicate with the Coral server. Different container runtimes may use
different values to communicate with the host; if a specific container runtime is used that requires a different address, it
must be specified here.
This must also be specified if the container runtime is on another machine; in which case this address should be the
public address of the machine running the Coral server.
# Response timeout
 `30` <br/>
<ServerConfigSingle table="docker" config="responseTimeout" example="60" />
The number of seconds before the Coral server times out when trying to communicate with the container runtime.
# Connection timeout
 `30` <br/>
<ServerConfigSingle table="docker" config="connectionTimeout" example="60" />
The number of seconds before the Coral server times out when trying to connect to the container runtime. Note
that this timeout will always be reached if the container runtime is not running.
# Max connections
 `1024` <br/>
<ServerConfigSingle table="docker" config="maxConnections" example="2000" />
The maximum number of connections that the Coral server can make to containers. Each agent running using a Docker
runtime requires one connection. This value should be large enough to accommodate the number of agents that will be
running on the Coral server at any one time.
# Container path separator
 `:` <br/>
<ServerConfigSingle table="docker" config="containerPathSeparator" example="&quot;;&quot;" />
The character that is used for separating multiple paths in a running container. This must be changed to `;` when running
Windows containers. This should __NOT__ be set to `;` if running Linux containers on a Windows host.
# Container name separator
 `:` <br/>
<ServerConfigSingle table="docker" config="containerNameSeparator" example="&quot;;&quot;" />
The character that is used to separate path names on a running container. This can be changed to `\` when running
Windows containers. Note that this should __NOT__ be set to `\` if running Linux containers on a Windows host.
# Container temporary directory
 `/tmp` <br/>
<ServerConfigSingle table="docker" config="containerTemporaryDirectory" example="&quot;/custom-tmp-directory&quot;" />
The directory on a running container that is used for temporary files.

---

## Console Configuration

---
title: Coral Console
---
# Enable console
 `true` <br/>
<ServerConfigSingle table="console" config="enabled" example="true" />
If this is set to `false`, the Coral server will not serve the Coral console at `/ui/console`. Consider disabling this
in production environments.
# Cache path
 `${HOME}/.coral/console` <br/>
<ServerConfigSingle table="console" config="cachePath" example="&quot;/my/custom/path&quot;" />
The path that the Coral console will be downloaded to. Note: this directory should not contain anything but Coral
console files. This directory may be deleted by the Coral server when the Coral console is updated.
# Console release URL
 `https://github.com/Coral-Protocol/coral-studio/releases/download` <br/>
<ServerConfigSingle table="console" config="consoleReleaseUrl" example="&quot;https://github.com/fork-user/console/releases/download&quot;" />
The path that the Coral console versions will be downloaded from. This should only be changed if using a fork of the
Coral console.
# Console release version
 stable Console version for given Coral server version <br/>
<ServerConfigSingle table="console" config="consoleReleaseVersion" example="&quot;1.1.1-beta&quot;" />
The name of the Coral console version to download. This can be changed to use beta versions of the Coral console.
> **Warning:** 
    Not all Coral console versions are compatible with all Coral server versions. If you change this, ensure that the
    selected Coral console version remains compatible when performing Coral server upgrades.
# Bundle name
 `coral-console_${consoleReleaseVersion}.zip` <br/>
<ServerConfigSingle table="console" config="bundleName" example="&quot;1.1.1-beta&quot;" />
The name of the bundle to download. Note that if this is changed, the [console release version](#console-release-version)
will have no effect.
# Delete old versions
 `false` <br/>
<ServerConfigSingle table="console" config="deleteOldVersions" example="true" />
If this is `true`, the Coral server will delete old versions of the Coral console when it starts.
# Always download
 `false` <br/>
<ServerConfigSingle table="console" config="alwaysDownload" example="true" />
If this is true, the Coral server will always download the latest version of the Coral console even if it is already
downloaded. This can be used if a forked version of the Coral console opts to update an existing version.

---

## Debug Configuration

---
title: Debug
---
# Additional Docker environment variables
 empty map <br/>
> **Warning:** 
    This configuration option cannot be specified via the command line.
```toml
[debug.additional_docker_environment]
MY_VAR_1 = "my value"
MY_VAR_2 = "my other value"
```
A map of additional environment variables that will be set and passed to agents that use the
[Docker runtime](/reference/agent/tables/runtimes/docker). These variables will not overwrite Coral environment
variables or options.
# Additional Executable environment variables
 empty map <br/>
> **Warning:** 
    This configuration option cannot be specified via the command line.
```toml
[debug.additional_executable_environment]
MY_VAR_1 = "my value"
MY_VAR_2 = "my other value"
```
A map of additional environment variables that will be set and passed to agents that use the
[Executable runtime](/reference/agent/tables/runtimes/executable). These variables will not overwrite Coral environment
variables or options.
