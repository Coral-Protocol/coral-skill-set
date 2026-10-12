# [agent]

General agent information

Source: https://docs.coralos.ai/reference/agent/tables/agent

## agent.name
**required**

A [string](https://toml.io/en/v1.1.0#string) defining the name for the agent.

```toml
[agent]
name = "my-agent"
```

__Requirements__
- At least one character
- No more than 32 characters
- Must match `^[a-z0-9]([a-z0-9]*(-[a-z0-9]+)*)?$`: lowercase letters/digits separated by single dashes, without a leading or trailing dash

## agent.version
**required**

A [string](https://toml.io/en/v1.1.0#string) defining the version of the agent.

```toml
[agent]
version = "1.0.0"
```

__Requirements__
- At least one character
- No more than 24 characters
- Must be a valid [semantic version](https://semver.org/)

## agent.description
**required**

A [PotentialStringReference](../../../reference/types/potential-string-reference.md) description for this agent.  This
description is exclusively used by LLMs.  This description is only a default and may be overridden at runtime.  Agent
descriptions are provided to agents in the state resource.

```toml
[agent]
description = "An agent with web search capabilities"
```
__Requirements__
- At least one character
- No more than 1024 characters

## agent.capabilities
**optional**

An [array](https://toml.io/en/v1.1.0#array) of capabilities.

```toml
[agent]
capabilities = ["resources", "tool_refreshing"]
```

This is a placeholder field.  Currently, this has no use.

__Requirements__

- All entries must be one of the following:
  - `resources`
  - `tool_refreshing`
- Must not contain duplicates

## agent.readme
**required**

A [PotentialStringReference](../../../reference/types/potential-string-reference.md) readme for this agent.  This readme
is displayed in the Coral marketplace and in Coral console.  The summary is not provided in the state resource.  In
Coral console and in Coral marketplace the readme supports markdown.

```toml
[agent]
readme = """
A long descriptive readme for my agent.
"""
```

__Requirements__
- At least one character
- No more than 4096 characters

## agent.summary
**required**

A [PotentialStringReference](../../../reference/types/potential-string-reference.md) summary for this agent.  This summary
is displayed in the Coral marketplace and in Coral console.  The summary is not provided in the state resource.

```toml
[agent]
summary = "An agent with web search capabilities"
```

__Requirements__
- At least one character
- No more than 256 characters

## agent.license
**required**

The license for this agent.  Licenses may be specified as an [SPDX expression](https://spdx.github.io/spdx-spec/v2.3/SPDX-license-expressions/)
or text via the [PotentialStringReference](../../../reference/types/potential-string-reference.md) type.

The license will be displayed in the Coral marketplace.

**SPDX**

```toml
[agent.license]
type = "spdx"
expression = "MIT"
```

__Requirements__
- The expression must be valid.  See [here](https://spdx.github.io/spdx-spec/v2.3/SPDX-license-expressions)
for more information.

**Text**

```toml
[agent.license]
type = "text"
text = { type = "file", path = "LICENSE.TXT" }
```

__Requirements__
- The license text must not be larger than 2 MiB

## agent.keywords
**optional**

An [array](https://toml.io/en/v1.1.0#array) of [string](https://toml.io/en/v1.1.0#string) keywords to describe this
agent.  These keywords are used by the Coral marketplace and the Coral console agent registry to search for agents.

```toml
[agent]
keywords = ["web", "search"]
```

__Requirements__
- Each keyword must contain at least one character
- Each keyword must not contain more than 64 characters
- Must not contain duplicates
- Must not contain more than 256 keywords

## agent.links
**optional**

A [table](https://toml.io/en/v1.1.0#table) of [strings](https://toml.io/en/v1.1.0#string), where the key is the
link name and the value is the link URL.  These links are displayed in the Coral marketplace and in the Coral console.

```toml
[agent]
links.github = "https://github.com/coral-Protocol/coral-server"
links.home = "https://www.coralos.ai"
```

__Requirements__
- Link names must start with an alphabetic character
- Link names must contain only alphanumeric characters, underscores (`_`) and dashes (`-`)
- Link names must be at least one character long and at most 32 characters long
- Link values must be at least one character long and at most 256 characters long
- Link values must be a valid URL
- Link values must be either `https`, `mailto` or `tel`
- No more than 16 links may be specified
