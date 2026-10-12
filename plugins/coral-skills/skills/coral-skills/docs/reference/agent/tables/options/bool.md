# bool option type

Source: https://docs.coralos.ai/reference/agent/tables/options/bool

A boolean option.  Booleans should use the [environment transport](../../../../reference/agent/tables/options/bool.md#environment-transport)
as they are never large enough to use the [filesystem transport](../../../../reference/agent/tables/options/bool.md#filesystem-transport).

> **Note:**
>
> Booleans do not have a list type

| Option value | `transport = "fs"` | `transport = "env"` |
|--------------|--------------------|---------------------|
| `true`       | `0x01`             | `1`                 |
| `false`      | `0x00`             | `0`                 |
|              | (binary)           | (utf-8 string)      |

## Full example

```toml
[options.EXAMPLE_BOOL_OPTION]
type = "bool"
required = false
default = true

display.label = "Example Boolean Option"
display.description = "This is an example boolean option."
display.group = "Example Group"
```

## option.type
**required**

```toml
type = "bool"
```

## option.default
**optional**

A [boolean](https://toml.io/en/v1.1.0#boolean) specifying the default value for this option.

```toml
default = true
```

## option.required
**default** `false`
**optional**

If `required = true` this option is __not__ optional and must be specified.  Setting `required = true` for an option
that has a default value has no effect.

```toml
required = true
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
