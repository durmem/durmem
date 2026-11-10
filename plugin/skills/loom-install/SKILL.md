---
name: loom-install
description: Install, update, uninstall, and verify Durmem for Claude Code.
---

# Durmem install for Claude Code

Durmem has two parts: the `durmem` command-line tool, installed once per computer, and this Claude
Code plugin. The plugin's hooks and its MCP entry both use the installed tool.

## Install

1. Install the Durmem tool. On macOS or Linux:

   ```bash
   curl -fsSL https://durmem.ai/.well-known/cli/install.sh | sh
   ```

   On Windows (PowerShell):

   ```powershell
   irm https://durmem.ai/.well-known/cli/install.ps1 | iex
   ```

2. Run `durmem setup` once. It signs you in, connects your store, and checks the Claude Code
   integration.
3. Start a fresh Claude Code session. Do not launch with `--bare`, and make sure `disableAllHooks`
   is absent or false. Use `/hooks` to confirm Durmem's hooks are enabled.

Your connection details live in `~/.loom/stores.toml`. It holds live credentials: never print it,
paste it into chat, or copy it into logs.

## Update

`durmem update` and `durmem --version` are part of the installed `durmem` tool (see the CLI reference at https://durmem.ai/docs). They are not listed on the install page, which shows only the installer and `durmem setup`.

Run `durmem update`, then `durmem setup`, and restart Claude Code.

## Uninstall

Remove the plugin from Claude Code's plugin manager (`/plugin`). This does not remove unrelated
MCP, skill, hook, or user configuration.

The shared `durmem` command stays on purpose, so other Durmem integrations keep working. Remove it
by hand only after uninstalling every Durmem integration: delete `~/.loom/cli` and
`~/.local/bin/durmem` on macOS or Linux, or `%USERPROFILE%\.loom\cli` and `%USERPROFILE%\.loom\bin`
on Windows (and remove that `bin` directory from your user PATH).

## Verify

1. Run `durmem --version`; it prints the installed version.
2. Confirm Claude Code's plugin list shows exactly one Durmem plugin.
3. In a fresh session, use `/hooks` to see that the plugin's hooks are present, confirm the Durmem
   skills are available, and make one read-only Durmem call such as `whoami`.
4. The first request after startup can take a little longer; that is not an error.

If Durmem tools time out on Windows, update Durmem, refresh the plugin, and start a new session; see
the [troubleshooting guide](https://durmem.ai/docs/troubleshooting#durmem-tools-time-out-in-codex-or-claude-code-windows).
