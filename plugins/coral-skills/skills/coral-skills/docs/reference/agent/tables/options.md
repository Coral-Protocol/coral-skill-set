# options table

Configuration options for an agent.

Source: https://docs.coralos.ai/reference/agent/tables/options

Options allow an agent to be configured or tweaked at runtime.  All options, unless specified as optional, will be
provided to the agent by the server as environment variables.

An agent that has required options with no default values will require the user to specify values for those options.

```toml
[options.EXAMPLE_OPTION]
type = "string"

[options.EXAMPLE_REQUIRED_OPTION]
type = "string"
required = true

[options.EXAMPLE_DEFAULT_OPTION]
type = "string"
default = "default value for this option"
```

## Requirements

- Option names must be between 1 and 256 characters
- Option names must match `^[a-zA-Z_][a-zA-Z_$0-9]*$`: start with a letter or underscore, followed by letters, digits, underscores or `$`
- An agent may only specify 512 options
- The combined size of all default values for all options may not exceed 6 MiB

## Types

All options must specify a type.  Different option types have different fields.

Available option types:

| Type                                             | List type                                                   | Description                  |
|--------------------------------------------------|-------------------------------------------------------------|------------------------------|
| [i8](../../../reference/agent/tables/options/i8.md)         | [list[i8]](../../../reference/agent/tables/options/i8.md#list)         | 8-bit signed integer         |
| [i16](../../../reference/agent/tables/options/i16.md)       | [list[i16]](../../../reference/agent/tables/options/i16.md#list)       | 16-bit signed integer        |
| [i32](../../../reference/agent/tables/options/i32.md)       | [list[i32]](../../../reference/agent/tables/options/i32.md#list)       | 32-bit signed integer        |
| [i64](../../../reference/agent/tables/options/i64.md)       | [list[i64]](../../../reference/agent/tables/options/i64.md#list)       | 64-bit signed integer        |
| [u8](../../../reference/agent/tables/options/u8.md)         | [list[u8]](../../../reference/agent/tables/options/u8.md#list)         | 8-bit unsigned integer       |
| [u16](../../../reference/agent/tables/options/u16.md)       | [list[u16]](../../../reference/agent/tables/options/u16.md#list)       | 16-bit unsigned integer      |
| [u32](../../../reference/agent/tables/options/u32.md)       | [list[u32]](../../../reference/agent/tables/options/u32.md#list)       | 32-bit unsigned integer      |
| [u64](../../../reference/agent/tables/options/u64.md)       | [list[u64]](../../../reference/agent/tables/options/u64.md#list)       | 64-bit unsigned integer      |
| [f32](../../../reference/agent/tables/options/f32.md)       | [list[f32]](../../../reference/agent/tables/options/f32.md#list)       | 32-bit floating-point number |
| [f64](../../../reference/agent/tables/options/f64.md)       | [list[f64]](../../../reference/agent/tables/options/f64.md#list)       | 64-bit floating-point number |
| [bool](../../../reference/agent/tables/options/bool.md)     | —                                                           | Boolean value                |
| [string](../../../reference/agent/tables/options/string.md) | [list[string]](../../../reference/agent/tables/options/string.md#list) | UTF-8 string                 |
| [blob](../../../reference/agent/tables/options/blob.md)     | [list[blob]](../../../reference/agent/tables/options/blob.md#list)     | Binary data                  |
