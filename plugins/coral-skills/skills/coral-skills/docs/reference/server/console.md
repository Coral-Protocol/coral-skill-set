# Coral Console

Source: https://docs.coralos.ai/reference/server/console

# Enable console
**default** `true`

- Command line: `--console.enabled=true`
- Config file: `console.enabled = true`

If this is set to `false`, the Coral server will not serve the Coral console at `/ui/console`. Consider disabling this
in production environments.

# Cache path
**default** `${HOME}/.coral/console`

- Command line: `--console.cache-path="/my/custom/path"`
- Config file: `console.cache_path = "/my/custom/path"`

The path that the Coral console will be downloaded to. Note: this directory should not contain anything but Coral
console files. This directory may be deleted by the Coral server when the Coral console is updated.

# Console release URL
**default** `https://github.com/Coral-Protocol/console/releases/download`

- Command line: `--console.console-release-url="https://github.com/fork-user/console/releases/download"`
- Config file: `console.console_release_url = "https://github.com/fork-user/console/releases/download"`

The path that the Coral console versions will be downloaded from. This should only be changed if using a fork of the
Coral console.

# Console release version
**default** stable Console version for given Coral server version

- Command line: `--console.console-release-version="1.1.1-beta"`
- Config file: `console.console_release_version = "1.1.1-beta"`

The name of the Coral console version to download. This can be changed to use beta versions of the Coral console.

> **Warning:**
>
> Not all Coral console versions are compatible with all Coral server versions. If you change this, ensure that the
> selected Coral console version remains compatible when performing Coral server upgrades.

# Bundle name
**default** `coral-console_${consoleReleaseVersion}.zip`

- Command line: `--console.bundle-name="1.1.1-beta"`
- Config file: `console.bundle_name = "1.1.1-beta"`

The name of the bundle to download. Note that if this is changed, the [console release version](#console-release-version)
will have no effect.

# Delete old versions
**default** `false`

- Command line: `--console.delete-old-versions=true`
- Config file: `console.delete_old_versions = true`

If this is `true`, the Coral server will delete old versions of the Coral console when it starts.

# Always download
**default** `false`

- Command line: `--console.always-download=true`
- Config file: `console.always_download = true`

If this is true, the Coral server will always download the latest version of the Coral console even if it is already
downloaded. This can be used if a forked version of the Coral console opts to update an existing version.
