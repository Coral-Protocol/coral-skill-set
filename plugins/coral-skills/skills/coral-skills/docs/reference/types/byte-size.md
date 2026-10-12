# ByteSize

A type for describing a number of bytes.

Source: https://docs.coralos.ai/reference/types/byte-size

The ByteSize type is used when a configuration field requires a size in bytes.

Sizes are specified by combining a [floating point number](https://toml.io/en/v1.1.0#float) with a [size unit](#available-size-units).

For example, 10 KiB can be specified as an inline table:

```toml
size = { size = 10.0, unit = "KiB" }
```

Or as a string:
```toml
size = "10.0 KiB"
```

This will result in a size of 10,240 bytes.

### Available size units

| Unit   | Name      | Size in Bytes           |
|--------|-----------|-------------------------|
| B      | BYTE      | 1                       |
| KiB    | KIBIBYTE  | 1,024                   |
| MiB    | MEBIBYTE  | 1,048,576               |
| GiB    | GIBIBYTE  | 1,073,741,824           |
| kB     | KILOBYTE  | 1,000                   |
| MB     | MEGABYTE  | 1,000,000               |
| GB     | GIGABYTE  | 1,000,000,000           |

> **Warning:**
>
> The size will be rounded to the nearest byte.
