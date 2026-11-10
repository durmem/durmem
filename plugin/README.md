# Durmem for Claude Code

Durmem gives Claude Code memory that lasts across sessions: what you decided, what
you learned and what is still open comes back when you start the next task.

This plugin connects Claude Code to the Durmem tool you install separately.

1. Install Durmem: https://durmem.ai/install
2. Add this plugin and restart Claude Code.

What the plugin runs, exactly:

- The hooks run the Durmem runtime that the Durmem installer put under `~/.loom` on your
  machine. They are plain scripts in this plugin: the scripts themselves download nothing and make no network call themselves. The Durmem runtime they start contacts your Durmem server to read and save your memory.
- The MCP entry runs the `durmem` command on your PATH (`durmem mcp`).

If Durmem is not installed, each hook prints the install command from https://durmem.ai/install
and lets the session continue.

Support: https://github.com/durmem/durmem/issues

Licensed under the MIT License; see LICENSE.
