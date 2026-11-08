# Update Durmem
<!-- loom-onboarding-surface: update -->

Finish or checkpoint active work and preserve `~/.loom/stores.toml`. Re-run the
same secure OS installer from [INSTALL.md](INSTALL.md), then run:

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
