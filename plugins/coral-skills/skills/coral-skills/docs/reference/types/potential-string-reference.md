# PotentialStringReference

A string.  The string's value can optionally be a reference to a file, URL or constant

Source: https://docs.coralos.ai/reference/types/potential-string-reference

## Inline

An inline value for a `PotentialStringReference` can be specified as a [string literal](https://toml.io/en/v1.1.0#string):

```toml
value = "my string value"
```

Or explicitly with a discriminated table.  Example using a discriminated [inline table](https://toml.io/en/v1.1.0#inline-table):

```toml
value = { type = "string", value = "my string value" }
```

## File

File references may be used to define the value of a `PotentialStringReference`.  File references will be resolved by
the Coral server, relative to the `coral-agent.toml` file.  For example, given the following structure:

```text
my-agent/
  coral-agent.toml
  README.MD
```

The value of `README.MD` could be used as a value with this syntax:

```toml
value = { type = "file", path = "README.MD" }
```

### Input and output encoding

Encoding settings are nested under `input` and `output`; top-level `encoding` and `base64` fields are not the encoding contract.

To read a Windows-1251 text file:

```toml
value.type = "file"
value.path = "README.MD"
value.input.charset = "windows-1251"
```

`input.base64 = true` decodes base64 before reading text. `output.base64 = true` encodes the resulting value as base64. Each side also accepts `charset`; the default charset is UTF-8. These settings apply to inline strings, files, URLs, and constants.

```toml
value.type = "file"
value.path = "README.MD"
value.input.charset = "windows-1251"
value.output.charset = "utf-8"
value.output.base64 = true
```

Blob defaults use a specialised serializer: inline values are base64 strings, while file and URL references are encoded to base64 by default. See [blob options](../../reference/agent/tables/options/blob.md).

## URL

A URL reference uses `url` instead of `path`, with the same `input` and `output` encoding settings:

```toml
value = { type = "url", url = "https://my-server.com/my-agent/1.0.0/README.MD" }
```

File and URL references are resolved by the server when loading the definition. In contexts where file or URL references are disabled, loading fails rather than forwarding the unresolved reference to the agent.

## Constant references

Constant references are a special type of string reference that provides a mechanism for using a Coral server-provided string
constant as a value.  These are especially useful in prototype runtimes.

Constant references can be accessed via name:

```toml
value.type = "constant"
value.name = "PROTOTYPE_DEFAULT_SYSTEM_PROMPT"
```

The following constants are available:

`PROTOTYPE_DEFAULT_SYSTEM_PROMPT`

The default value for `runtimes.prototype.prompts.system.base`

`PROTOTYPE_DEFAULT_LOOP_INITIAL_BASE_PROMPT`

The default value for `runtimes.prototype.prompts.loop.initial.base`

`PROTOTYPE_DEFAULT_LOOP_FOLLOWUP_PROMPT`

The default value for `runtimes.prototype.prompts.loop.followup`

`CORAL_STATE_RESOURCE_URI`

The MCP URI for the Coral state resource

`CORAL_INSTRUCTION_RESOURCE_URI`

The MCP URI for the Coral instruction resource
