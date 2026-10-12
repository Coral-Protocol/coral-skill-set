# string option type

Source: https://docs.coralos.ai/reference/agent/tables/options/string

A string option.  If you expect the value for your string to be large, it should use the
[filesystem transport](../../../../reference/agent/tables/options/string.md#filesystem-transport).

| Option value      | `transport = "fs"`        | `transport = "env"`        |
|-------------------|---------------------------|----------------------------|
| `my option value` | `my option value` (utf-8) | `my option value`, (utf-8) |

## Full example

**Single**

```toml
[options.EXAMPLE_STRING_OPTION]
type = "string"
required = false
default = "the default value of my string"
secret = false
base64 = false

display.label = "Example String Option"
display.description = "This is an example string option."
display.group = "Example Group"
display.multiline = true

# If variants are defined, min_length/max_length should not be defined
# validation.variants = ["value1", "value2", "value3"]

validation.min_length = 10
validation.max_length = 100
```

**List**

```toml
[options.EXAMPLE_STRING_OPTION]
type = "list[string]"
required = false
default = ["default value 1", "default value 2"]
secret = false
base64 = true

display.label = "Example String List Option"
display.description = "This is an example string list option."
display.group = "Example Group"
display.multiline = true

# If variants are defined, min_length/max_length should not be defined
# validation.variants = ["value1", "value2", "value3"]

validation.min_length = 1
validation.max_length = 10
```

## option.type
**required**

**Single**

```toml
type = "string"
```

**List**

```toml
type = "list[string]"
```

## option.default
**optional**

**Single**

A [PotentialStringReference](../../../../reference/types/potential-string-reference.md) specifying the default value for
this option.  If this is specified, setting `required = true` will have no effect.

```toml
default = "the default value of my string"
```

**List**

An [array](https://toml.io/en/v1.1.0#array) of
[PotentialStringReferences](../../../../reference/types/potential-string-reference.md) specifying the default value for
this option.  If this is specified, setting `required = true` will have no effect.

```toml
default = ["default value 1", "default value 2"]
```

## option.secret
**default** `false`
**optional**

A [boolean](https://toml.io/en/v1.1.0#boolean) specifying whether the value for this option should be treated as a
secret. Secret values are censored in configuration displays and the server's option-value log messages. Agent stdout/stderr is not automatically redacted.

API keys or other sensitive values should be marked as secret.

```toml
secret = true
```

## option.base64
**default** `false`
**optional**

A [boolean](https://toml.io/en/v1.1.0#boolean) specifying whether the value for this option should be sent to the agent
as a base64 encoded string.

If the option is of type `list[string]`, and `transport` is either `env` or unspecified, base64 encoding
should be abled to avoid confusing option values with the list seperating character: `,`

```toml
base64 = true
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

### option.validation.variants
**optional**

An [array](https://toml.io/en/v1.1.0#array) of [string literals](https://toml.io/en/v1.1.0#string) that specify valid
values for this option.  If `variants` is specified, the value for this option must be one of the entries in `variants`.
This is usually used to construct an enum.

```toml
validation.variants = ["value1", "value2", "value3"]
```

### option.validation.min_length
**optional**

An [integer](https://toml.io/en/v1.1.0#integer) specifying the minimum number of UTF-8 characters that must appear in string
value.

```toml
validation.min_length = 10
```

### option.validation.max_length
**optional**

An [integer](https://toml.io/en/v1.1.0#integer) specifying the maximum number of UTF-8 characters that must appear in
the string value.

```toml
validation.max_length = 100
```

### option.validation.regex
**optional**

A [string literal](https://toml.io/en/v1.1.0#string) specifying a
[regex pattern](https://docs.oracle.com/javase/8/docs/api/java/util/regex/Pattern.html) that the option value must
match fully.

```toml
validation.regex = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$"
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

### option.display.multiline
**default** `false`
**optional**

A [boolean](https://toml.io/en/v1.1.0#boolean) specifying whether Coral console should create a text field for this
option that allows multiple lines.  This is useful for prompts or other large texts.

```toml
display.multiline = true
```
