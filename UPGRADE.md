# Update Durmem
<!-- loom-onboarding-surface: update -->

Finish or checkpoint active work and preserve `~/.loom/stores.toml`. In your terminal, run:

```bash
durmem update
durmem --version
```

`durmem update` installs the latest release from the CLI's original installation server. If you
already run the latest, it prints `Durmem <version> is already up to date.` and changes nothing; if
your installed version is newer than the published release, it prints that and changes nothing.
`durmem --version` prints the installed version as `durmem <version>`.

If `durmem update` is missing or fails, re-run the same secure OS installer from
[INSTALL.md](INSTALL.md). After either update path completes, run `durmem setup` to
refresh your coding harnesses:

```bash
durmem setup
```

The shared CLI discovers all supported harnesses again, defaults all detected
ones on, upgrades/configures each selection independently, and prints a
per-harness verification and restart summary. Reruns are idempotent. Unknown or
conflicting configuration requires an explicit disposition; setup must not
silently overwrite it or change an existing named store binding.

An ordinary update preserves hosted stores. If you already have Durmem stores on
this computer, setup uses them; otherwise it asks you to sign in. When the current
Terms or Privacy versions require renewed consent, setup shows them before it
continues. Updating an installed harness plugin through its own plugin manager does
not need setup. Never put authentication or store values in command arguments or
logs.

## Upgrading from the `loom` command

The CLI is now named `durmem`. If you installed it earlier as `loom`, run
`loom update` once; from then on use `durmem`. If that update ends by printing an
old `loom setup` line that names a former server address, ignore that line and
run `durmem setup` instead. Your existing stores keep working.

## Uninstall reference

Removing a single harness integration does not remove the shared CLI or hosted
store registry. Use that harness's supported plugin removal command, then run
`durmem setup` to verify the remaining detected integrations. Preserve
`stores.toml` unless you intentionally want to remove local hosted-store access.

Do not delete unrelated MCP, skill, hook, plugin, or user configuration. If
verification fails, see [Troubleshooting](docs/reference/troubleshooting.md).
