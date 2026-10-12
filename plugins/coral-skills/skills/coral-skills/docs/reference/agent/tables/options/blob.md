# blob option type

Source: https://docs.coralos.ai/reference/agent/tables/options/blob

A blob option.  Blobs should be used for options that might contain binary data. Blobs should use the
[filesystem transport](../../../../reference/agent/tables/options/blob.md#filesystem-transport).

| Option value      | `transport = "fs"`                             | `transport = "env"`    |
|-------------------|------------------------------------------------|------------------------|
| `my option value` | `6D 79 20 6F 70 74 69 6F 6E 20 76 61 6C 75 65` | `bXkgb3B0aW9uIHZhbHVl` |
|                   | (binary)                                       | (base64, by default)   |

## Full example

**Single**

```toml
[options.EXAMPLE_BLOB_OPTION]
type = "blob"
transport = "fs"
required = false
default = { type = "file", path = "image.png" }

display.label = "Example Blob Option"
display.description = "This is an example blob option."
display.group = "Example Group"

validation.min_size = { size = 1.0, unit = "KiB" }
validation.max_size = { size = 1.0, unit = "MiB" }
```

**List**

```toml
[options.EXAMPLE_BLOB_OPTION]
type = "list[blob]"
transport = "fs"
required = false
default = [
    { type = "file", path = "icon1.png" },
    { type = "file", path = "icon2.png" }
]

display.label = "Example Blob List Option"
display.description = "This is an example blob list option."
display.group = "Example Group"

validation.min_size = { size = 1.0, unit = "KiB" }
validation.max_size = { size = 2.0, unit = "KiB" }
```

## option.type
**required**

**Single**

```toml
type = "blob"
```

**List**

```toml
type = "list[blob]"
```

## option.default
**optional**

**Single**

A [PotentialStringReference](../../../../reference/types/potential-string-reference.md) specifying the default value for this
option.  If this is specified, setting `required = true` will have no effect.  File or URL references will by default have `base64 = true`

```toml
default = { type = "file", path = "image.png" }
```

**List**

An [array](https://toml.io/en/v1.1.0#array) of [PotentialStringReferences](../../../../reference/types/potential-string-reference.md)
specifying the default value for this option.  If this is specified, setting `required = true` will have no effect.
File or URL references will by default have `base64 = true`

```toml
default = [
    { type = "file", path = "image1.png" },
    { type = "file", path = "image2.png" }
]
```

## option.required
**default** `false`
**optional**

If `required = true` this option is __not__ optional and must be specified.  Setting `required = true` for an option
that has a default value has no effect.

```toml
required = true
```

## option.validation

The server performs option validation before running an agent.  The Coral server will never launch an agent with option
values that do not pass the validation rules given for an option.

The absence of a validation rule indicates that the absent validation rule should not be performed.  No validation rules
have default values.

For list types, validation will be performed on each item on the list.  A single invalid item will reject the entire list.

### option.validation.min_size
**optional**

A [ByteSize](../../../../reference/types/byte-size.md) value specifying the
minimum number of bytes in the blob.

```toml
validation.min_size = "1.0 KiB"
```

### option.validation.max_size
**optional**

A [ByteSize](../../../../reference/types/byte-size.md) value specifying the
maximum number of bytes in the blob.

```toml
validation.max_size = "1.0 MiB"
```

## option.transport
**default** `env`
**optional**

Controls how the option value is sent to the agent.

### Environment transport

```toml
transport = "env"
```

The environment transport will _send_ the option value to the agent via an environment variable.  The name of the
environment variable will match the option name, and the value will be encoded in UTF-8.

For lists, multiple values will be sent delimited by a comma `,`.  It is recommended to use `option.base64 = true` when
there is a chance the value will contain a comma.

### Filesystem transport

```toml
transport = "fs"
```

The filesystem transport will _send_ the option value to the agent via a file.  An environment variable matching the name
of this option will be _sent_ to the agent, the value of the environment variable will be the path to the file that
contains the value for the option.

For lists, multiple files will be created.  A list of paths will be provided in the environment variable, delimited by
either:
- `;` on Windows
- `:` on Unix-like operating systems

## option.display

Display options are used to configure how the option should render in the Coral console.  They may also be used in other
third-party interfaces.

### option.display.label
**optional**

A [string literal](https://toml.io/en/v1.1.0#string) specifying the label for this option.  Coral console will display this label instead of the
option's name if it is specified.

```toml
display.label = "My option"
```

### option.display.description
**optional**

A [string literal](https://toml.io/en/v1.1.0#string) specifying a description for this option.  The description will
appear as a tooltip for this option in the Coral console.

```toml
display.description = "My option is used for ..."
```

### option.display.group
**optional**

A [string literal](https://toml.io/en/v1.1.0#string) specifying the group that this option belongs to.  Options with the same group will appear
grouped in the Coral console.

```toml
display.group = "Prompts"
```
