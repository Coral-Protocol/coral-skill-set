# Authentication

Source: https://docs.coralos.ai/reference/server/auth

# Keys
**default** empty list

- Command line: `--auth.keys="key1" --auth.keys="key2"`
- Config file: `auth.keys = ["key1", "key2"]`

Auth keys are used to authenticate requests made to the Coral server. These keys allow full access to the Coral server and
its APIs. The keys should be kept secret.

Using the Coral console also requires a key.

> **Info:**
>
> There are no keys set by default. At least one key must be set to effectively use the Coral server.
