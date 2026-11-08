# Connect Durmem to your coding agents

<!-- loom-onboarding-surface: first-time -->

Use the [Quickstart](docs/guide/quickstart.md) for your first setup. Already connected? Follow the
instructions below to connect this computer and check your agent.

**Codex users only:** Durmem sets Codex up through the `codex` command. Before installing Durmem,
run this in your terminal:

```sh
codex --version
```

Continue when it prints a version. Otherwise, install the Codex command-line tool from
[github.com/openai/codex](https://github.com/openai/codex), open a new terminal and repeat the check.
The ChatGPT desktop app alone is not enough. Claude Code and OpenCode users can skip this check.

<!-- loom-first-time-onboarding:start -->
## 1. Install the shared Durmem CLI

Use the secure installer for your operating system to install the shared, user-level `durmem`
command. It requires no coding harness or signed-in account.

Prerequisites: macOS/Linux needs Python 3, `tar`, `sha256sum` or `shasum`, and `curl`. Windows
needs `tar` in PowerShell; the installer downloads a checksum-verified private `uv` and provisions
Durmem's own Python, so no preinstalled Python or `uv` is required.

On macOS and Linux, the installer also installs a private `uv` under `~/.loom/bin` for Durmem's
runtime. If you already have `uv` on your PATH, the installer leaves it in place and Durmem uses
its private copy.

**Run in your terminal** (macOS or Linux):

```sh
curl -fsSL https://durmem.ai/.well-known/cli/install.sh | sh
```

**Run in your terminal** (Windows PowerShell):

```powershell
irm https://durmem.ai/.well-known/cli/install.ps1 | iex
```

The installer writes to a stable per-user location, with no symlinks: `~/.loom/cli`, plus a launcher
at `~/.local/bin/durmem` (`%USERPROFILE%\.loom\bin\durmem.cmd` on Windows).

On macOS and Linux, follow the installer's printed PATH commands. On Windows, open a new terminal
window to use the updated PATH. Check the installation with `durmem --version`.

## 2. Run durmem setup once

**Run in your terminal:**

```sh
durmem setup
```

The CLI discovers installed Claude Code, Codex and OpenCode integrations with authoritative probes.
It shows the detected set before mutation, with all selected by default, and lets you opt out
before it begins to configure anything.

One run completes authentication with this server, asks for explicit [Terms](https://durmem.ai/terms)
and [Privacy](https://durmem.ai/privacy) consent, finishes provisioning, writes `stores.toml`
securely, and will verify each selected harness independently. A partial failure cannot hide
another harness result; the final restart and per-harness result summary tells you exactly what
succeeded. Restart your harness as the summary instructs, then start a new session.

Rerunning setup is idempotent. Unknown configuration or a conflict is preserved for explicit
disposition. If setup reports **no supported harness detected**, install or start Claude Code,
Codex or OpenCode and rerun `durmem setup`. For consent, account or deletion help, contact
[info@durmem.ai](mailto:info@durmem.ai).
<!-- loom-first-time-onboarding:end -->

Using Meta's Muse or OpenAI's Dot? Ask the assistant to read its setup page:
[Meta's Muse](docs/guide/connect-muse.md) or [OpenAI's Dot](docs/guide/connect-dot.md). It runs the setup and asks you for the emailed sign-in code.

## Reference

Setup writes the registry for your operating system:

- macOS / Linux: `~/.loom/stores.toml`
- Windows: `%USERPROFILE%\.loom\stores.toml`

See [Store settings](docs/reference/stores-toml.md) for the file format, or
[view your store definition](https://durmem.ai/stores?tab=stores#stores-config) on the website.

## Private installations

To host Durmem on your own network, contact [info@durmem.ai](mailto:info@durmem.ai).
If your team already has a private server, open `/docs/connect-client` on that server for the
connection guide. Ask your team for its server address. Then return to the
[Quickstart](docs/guide/quickstart.md#verify-the-harness-connection) to check your harness.
