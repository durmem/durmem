# Troubleshooting

<!-- loom-doc: slug=troubleshooting; audience=both; section=reference -->
Find the symptom that matches what you see, then follow its cause and fix.

## `durmem` is not found

**Cause:** The CLI is not installed or this terminal has not loaded the updated PATH.

**Fix:** Open a new terminal and run `durmem --version`. If the command is still missing, follow the install steps in the Quickstart.

## Setup does not list my agent

**Cause:** Setup detects supported coding harnesses whose commands are available on this computer.

**Fix:** Install the harness, then run `durmem setup` again. To select one installed harness directly, use `durmem setup --harness codex`, `durmem setup --harness claude`, or `durmem setup --harness opencode`; `durmem setup --harness hermes` connects Hermes.

## Durmem is enabled but my agent says its tools are unavailable

**Cause:** An enabled MCP entry does not mean the server has finished starting and downloading its dependencies.

**Fix:** Let the first start finish, then start a new agent session so it loads the Durmem tools.
Check the configuration: in your terminal, run `codex mcp list` and confirm `durmem` is enabled.
This lists configured servers; it does not verify that the server started.
In Claude Code, enter `/mcp` to check the server status and confirm Durmem is connected.
Ask the agent to use Durmem again. If the tools are still missing, run `durmem setup`;
it is safe to re-run. Confirm setup reports `installed and verified` or `migrated and verified`
for your harness, then start a new session and ask the agent to use Durmem again.

## Sign-in does not finish

**Cause:** The verification code is invalid or expired, sign-in requests were throttled, or store provisioning is still running.

**Fix:** Start `durmem login` again and use the newest code from your email. If sign-in reports too many code requests, wait five minutes before requesting a new code. Web sign-in and CLI setup share limits for your email address and network, so switching between them does not reset the wait. If provisioning timed out, retry `durmem login` with the same email to check its status; the retry is safe. Sign-in and setup emails include your server’s support contact when one is configured.

## A store is missing

**Cause:** The store may not have a saved connection on this computer, or the command may be
using another selected store.

**Fix:** Run `durmem list_stores` to see the stores configured on this computer. If the store is absent, connect the account with `durmem login`; if it is listed, select it with `--store NAME` for a memory command or [choose it as the session default](../guide/manage-stores.md#change-the-session-default).

## A new chat does not use a saved fact

**Cause:** A direct memory lookup can work while automatic recall does not surface that fact. Hooks retrieve selected memories for the current prompt or action; they do not add every saved fact to every chat.

**Fix:** First ask the agent to retrieve the fact from the store and Project where it was saved.
If it finds the fact, check the automatic-recall setup: the checkout's `loom.toml` should name
the intended Workspace, and the selected store should have the repository's membership path.
Use the [Quickstart scope check](../guide/quickstart.md#choose-this-sessions-default-store) to
confirm or complete those settings. Then check that the harness was restarted after setup and
that its hooks are enabled; see [Give agents real-time reminders](../tutorials/give-agents-real-time-reminders.md).

## A saved memory is wrong or unwanted

**Cause:** The statement may have changed, been wrong when saved, or belong to another store or
project.

**Fix:** Read its exact text, reference and project links first. Follow
[Inspect, correct or remove one memory](../guide/quickstart.md#inspect-correct-or-remove-one-memory).
A changed statement preserves the earlier value as history; a false statement needs a correction.
Retracting a record removes it from ordinary reads, not necessarily from history or backups.
Check the current result again from a fresh session in the same store and project.

## A store command times out

**Cause:** `create_store`, `unlock_store` and `drop_store` can take longer than the command waits. The server may still finish the job.

**Fix:** Run `durmem list_stores`, or check **Manage** on the website, before you retry. Retry only if the change did not happen.

## A store stays locked

**Cause:** A store can remain locked if the server could not reopen its encrypted storage after
maintenance.

**Fix:** Contact your server administrator or support if the server cannot reopen the storage. If the
store is explicitly still locked, you can try `durmem unlock_store --params '{"section":"NAME"}'`
with its exact name. If it remains unavailable, contact your administrator; hosted users can
[open an issue on GitHub](https://github.com/durmem/durmem/issues).

In Windows PowerShell 5.1, replace `NAME` with the locked store's exact name and pass the JSON through a UTF-8 file without a byte-order mark:

**Run in your terminal:**

```powershell
[System.IO.File]::WriteAllText((Join-Path $PWD 'params.json'), '{"section":"NAME"}', [System.Text.UTF8Encoding]::new($false))
durmem unlock_store --params-file ./params.json
```

## Durmem cannot reach the server

**Cause:** The selected store points to the wrong server, the network or proxy blocks the connection, or the server's certificate is not trusted.

**Fix:** Check the selected store with `durmem list_stores`. For sign-in, specify the correct HTTPS server with `durmem login --base URL`; for a self-signed certificate, add `--ca-file PEM`. Ask your administrator for the server URL, proxy, or certificate path.

If an older hosted connection still lists the service's former address, `durmem setup` updates the endpoint and web origin to `durmem.ai`. It adds a web origin if needed, preserves your store and credentials, and keeps an exact copy of the first pre-migration file next to `stores.toml` as `stores.toml.pre-durmem-migration`. Restart your harness afterward. If setup cannot edit the file safely, run `durmem login --base https://durmem.ai` with the same account to refresh it.

An older Durmem plugin that was installed from the service's former address is replaced by `durmem setup` the same way. If setup instead says the old `loom` marketplace is "not verifiably Durmem's", that marketplace was added from some other address, so setup changed nothing. If it is yours, run the two removal commands the message prints, then run `durmem setup` again.

## Saving or searching fails while downloading the embedding model

**Cause:** `durmem setup` and `durmem login` download a local embedding model once (about 70 MB).
If that download failed, they print a warning and the first save or semantic search downloads it
instead, which can take close to a minute. A proxy can block this download even when Durmem can reach your stores. An `InvalidURL: Invalid port`
error can also come from IPv6 entries in `NO_PROXY` or `no_proxy`.

**Fix:** Check that your proxy allows the model download. Durmem accepts bracketed IPv6
exclusions such as `[::1]` by normalizing them for the download, then restores the original
environment values. If the error persists, check `HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY`
and their lowercase equivalents with your administrator. Keep proxy credentials out of
shared diagnostics, restart your harness after changing its environment, and retry the save
or search.

If setup warned that it could not download the search model and your environment reaches the
internet through a SOCKS proxy (`ALL_PROXY=socks5://...`), the first save or search downloads the
model through that proxy. The Python that runs Durmem needs SOCKS support to do that. Durmem's
own launchers include it. If the error mentions `socksio`,
that Python lacks it, as in a separate interpreter such as Hermes's virtual environment; the error
prints the `uv pip install` command that adds it.

## Sign-in works but Durmem cannot reach your stores (sandboxed or proxy-only networks)

**Symptom:** On cloud agent VMs that allow only HTTPS through a proxy, `durmem setup` and sign-in
succeed (HTTPS) but every store call fails. `durmem residual --store kanban install` stops at its
first server check. The error names the route that failed, for example `direct TCP
cannot reach the Durmem server at tcp://durmem.ai:7443: the peer did not send a ZeroMQ greeting; it
answered 'Other TCP connections is turned off'` (or `the peer sent no ZeroMQ greeting` when the
gateway says nothing), so it does not point at your sign-in. An install that predates this message
waits 30 s and then says `key not accepted or server unreachable`; sign-in is fine in that case too.

**Cause:** Sign-in uses HTTPS, while store calls use the server's data port. For durmem.ai,
that port is 7443. Some proxies allow only HTTPS port 443, rather than the server's data port.

**Fix:** Use the proxy settings supplied by your environment or administrator. Durmem first
tries direct TCP, then tries the proxy in `HTTPS_PROXY` or `https_proxy` if direct TCP cannot
connect or the connection does not answer like a Durmem server (some gateways accept a connection and then drop it or answer with a text notice; the error then quotes what answered). If that tunnel is refused or does not reach the data service, Durmem tries a secure
WebSocket connection through the same proxy to the server's saved HTTPS origin. The server
must support this fallback. `NO_PROXY` exclusions are honored for the configured data endpoint;
an explicit `socks_proxy` setting in `stores.toml` takes precedence over automatic route selection.
Proxy URLs may include Basic authentication credentials. Keep those credentials private when
sharing diagnostics. Restart the harness after changing its proxy environment.

If the error says `proxy refused CONNECT to host:port (HTTP 407)`, check proxy authentication.
If the error says the WebSocket upgrade "was redirected … to another origin", the saved web origin is a retired address; run `durmem login` (it refreshes your saved stores from the server) or `durmem setup`, then restart your harness. `durmem update` only updates the program and does not change this file. Durmem never follows that redirect.
If the WSS step also fails, ask your administrator whether WebSocket Upgrade to the server's
HTTPS origin is permitted and supported. A successful website request alone does not prove
store access. The same connection path applies to private servers; their HTTPS origin and
certificate may differ. If the error names a missing `web_origin`, refresh the connection with
`durmem login --base https://YOUR_SERVER`, using your actual server address. For a private
certificate, retain the `--ca-file` used during setup; do not disable certificate verification.

The selected route stays fixed for that client process. A dropped connection does not cause
Durmem to resend a request through another route: if a write times out, its outcome may be
unknown. Check the saved result before retrying. If the error says
`native proxy socket shutdown is pending`, the old connection has not finished closing;
restart the harness before making another request. The WebSocket relay forwards the existing
encrypted store connection; it does not replace store authorization or hide memories
from the server operator.

## Setup reports “provisioning failed” after the email code

Your account may already have been created even if setup could not retrieve its
connection settings. Run `durmem setup` again with the same email address and
server URL. This retrieves your existing stores; do not delete them to retry.

If the error repeats, contact your administrator or [open an issue on GitHub](https://github.com/durmem/durmem/issues)
with the output of `durmem --version` and the time of the attempt. Do not send
email codes, store keys, or your `stores.toml` file.

## Hooks do not run

**Cause:** The harness is using its configuration from before setup, or its hook integration is disabled.

**Fix:** If the agent's startup diagnostics report a missing local `loom.toml`, follow the
[Quickstart store selection](../guide/quickstart.md#choose-this-sessions-default-store). For a missing or
ambiguous membership path, check the path for your current store and Project using
[the Quickstart scope check](../guide/quickstart.md#choose-this-sessions-default-store).
If Codex stopped running hooks after a Durmem update, it may need renewed trust for changed hook
definitions; open `/hooks` in Codex and trust the current Durmem hooks.
Otherwise, run `durmem setup` to install and verify the harness integration, then restart the
harness or open a new session so it loads the updated configuration.

## Setup reports an unusable private runtime

Rerun the installer from the server you originally used. If setup still cannot repair
the runtime, contact support. Setup preserves the existing environment instead of clearing
it while it may be in use.

## Windows command or setup issues

**Cause:** This PowerShell window or harness session was open before setup updated the command path or store connection.

**Fix:** Open a new PowerShell window and run `durmem --version`. Restart the harness after setup so it reads the updated connection. On Windows, fully quit the Codex or ChatGPT desktop app from the system tray before reopening it; closing its window may leave it running. Use the PowerShell install steps in the Quickstart.

## Durmem tools time out in Codex or Claude Code (Windows)

**Cause:** Earlier Durmem releases could leave every Durmem tool call waiting until it timed out on Windows, even though `durmem` commands in the terminal answered at once.

**Fix:** Update Durmem and refresh the plugin, then start a new agent session.

**Run in your terminal:**

```sh
durmem update
```

Then follow the next section to refresh the Codex plugin, or run `durmem setup` again for Claude Code, and start a new session. Ask the agent to use Durmem; its tools should answer within a few seconds.

## Setup says the Codex plugin runtime differs from the Durmem command (Windows)

**Cause:** On Windows, Git can check the Codex plugin out with Windows line endings, so its files no longer match the ones the `durmem` command installed. Setup then reports that the Durmem plugin is installed but its server is not running. The fix ships in both the server's plugin and the `durmem` command, so a computer that installed earlier needs both refreshed, in this order.

**Fix:** First update the `durmem` command, because the old one cannot recognize the corrected plugin. Open a new terminal so the update takes effect. Then remove the old Durmem plugin and its marketplace from Codex, so Codex fetches a fresh copy, and run setup again.

**Run in your terminal:**

```sh
durmem update
```

Open a new terminal, then run:

```sh
codex plugin remove loom@durmem
codex plugin marketplace remove durmem
durmem setup
```

If `durmem update` tells you to close Durmem and agent sessions, close them first, then open a new PowerShell window and run the installer command it prints.

If `durmem update` is missing or fails, rerun the installer from the server you originally used, following the [Quickstart](../guide/quickstart.md), then continue with the second block. If setup still fails, run `durmem setup` again from a new terminal so it finds the `durmem` command.

## Codex cannot read Durmem skills on Windows

If a command to read an installed Durmem skill is rejected as `blocked by policy`, check
`codex doctor --json` and the active session's permissions. A disabled Windows sandbox
backend can cause this rejection even for a read-only command.

If the backend is disabled, check whether your device supports the native MXC sandbox.
With Codex CLI 0.162.0 or later, run the
[official compatibility probe](https://learn.chatgpt.com/docs/windows/windows-sandbox#mxc-compatibility)
from your project folder.

**Run in your terminal** (PowerShell on Windows):

```powershell
codex -c windows.sandbox=mxc sandbox --include-managed-config --permission-profile :workspace -- cmd.exe /d /c echo MXC_OK
$LASTEXITCODE
```

Continue only if it prints `MXC_OK` and exit code `0`. To start a read-only Codex session
with that sandbox:

**Run in your terminal** (PowerShell on Windows):

```powershell
codex --sandbox read-only -c windows.sandbox=mxc
```

This setting allowed an installed Durmem skill to be read on a tested Windows device.
If MXC is unavailable or blocked by policy, ask your administrator to provision a permitted
Windows sandbox. Keep sandbox boundaries in place.

## Setup cannot verify the Codex marketplace checkout

Durmem checks that Codex's Durmem marketplace checkout contains its tracked files. Setup stops if
the `.git` metadata is missing or Git cannot complete that check. If the message says Git could not
inspect the checkout or timed out, confirm `git --version` works in the same terminal; if it does
not, install Git or add it to `PATH`. Then run setup again. If `.git` is missing on macOS or Linux,
remove the marketplace registration and let Codex clone it again. On Windows, first shorten
`CODEX_HOME` using the instructions below.

**Run in your terminal** (macOS or Linux):

```sh
codex plugin marketplace remove durmem
durmem setup
```

## Setup says the Codex marketplace checkout is incomplete (Windows)

Setup checks that Codex downloaded every Durmem plugin file, and stops with `the durmem marketplace
checkout ... is incomplete` when files are missing. On Windows this happens when the path of your
Codex folder, `CODEX_HOME`, is too long for the longest plugin file name. Codex still reports success,
so Durmem stops before it installs a plugin with files missing. The message gives the length of your
`CODEX_HOME`; a folder such as `C:\codex` is short enough.

If `codex plugin marketplace add` fails with `Filename too long` on Windows, run
`durmem setup` to add the marketplace through the supported path. You can also shorten
`CODEX_HOME` and try the command again using the steps below.

Codex keeps its settings and sign-in in that folder, so copy it to a short path that does not exist
yet rather than starting an empty one. Remove the incomplete checkout, copy the folder Codex is
using now (your `CODEX_HOME`, or `.codex` in your user folder when it is not set), and point
`CODEX_HOME` at the copy.

**Run in your terminal** (PowerShell on Windows):

```powershell
codex plugin marketplace remove durmem
$source = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { "$env:USERPROFILE\.codex" }
Copy-Item -Recurse $source C:\codex
[Environment]::SetEnvironmentVariable("CODEX_HOME", "C:\codex", "User")
```

Open a new terminal and run `durmem setup` again. It adds the marketplace under the shorter path.

## Codex fails to start its sandbox on Ubuntu 24.04

On Ubuntu 24.04 or later, if Codex reports `bwrap: Operation not permitted` or a uid-map permission error, follow the [official sandbox prerequisites](https://learn.chatgpt.com/docs/sandboxing#prerequisites). Install Codex using the [official CLI instructions](https://learn.chatgpt.com/docs/codex/cli) if needed. Do not use `danger-full-access` as the default remedy or disable Codex's sandbox. The documented Ubuntu remedy installs bubblewrap and Ubuntu's additional AppArmor profile; if that profile is unavailable or your administrator disallows it, stop and consult the prerequisites or administrator. These remedy commands have not been verified end to end on a fresh Ubuntu host.

**Run in your terminal, outside the failing Codex session:**

```bash
sudo apt update
sudo apt install bubblewrap apparmor-profiles apparmor-utils
sudo install -m 0644 /usr/share/apparmor/extra-profiles/bwrap-userns-restrict /etc/apparmor.d/bwrap-userns-restrict
sudo apparmor_parser -r /etc/apparmor.d/bwrap-userns-restrict
```

This profile allows unprivileged user namespaces for bwrap only and does not disable AppArmor's restriction globally. Restart Codex with its normal sandbox enabled.

## I am still stuck

Run `durmem --version` and `durmem list_stores`, then share the error text, operating system, and coding agent with your administrator. Remove keys, tokens, email codes, and other credentials before sharing diagnostics. Hosted users can [open an issue on GitHub](https://github.com/durmem/durmem/issues); private users should contact their administrator.
