# Command reference

<!-- loom-doc: slug=cli; audience=both; section=reference -->
Use this page to look up the `durmem` commands and their main options.

## Help and version

**Run in your terminal:**

```sh
durmem --help
durmem <command> --help
durmem --version
```

Put `--version` immediately after `durmem`, before any other options. The version prints as three
numbers (major.minor.patch) and matches the Durmem plugin version. The top-level help lists
built-in commands and the available agent tools.

`durmem --version` reports the installed release as `X.Y.Z`, matching the plugin version.

## Sign in and set up

`durmem setup` signs in when needed, provisions your stores, and installs and verifies Durmem in
your selected coding harnesses. You can run it again to refresh those integrations.
`durmem hosted-setup` is another name for `durmem setup`.

For Codex, Claude Code, and OpenCode, setup checks that the configured MCP server starts and lists tools. A running
Codex desktop app must reconnect to load the installation; on Windows, quit the app from
the system tray before restarting it. Setup cannot confirm that tools appear in an already
running desktop session.

Claude Code verification accepts Windows CRLF line endings in an existing plugin cache when
its runtime content and release version match the Durmem command. Other content or version
differences still require an update before setup can verify the installation.

The comparison applies only when the installed plugin starts the Durmem command. A plugin that
does not depend on the command's runtime is not held back when that runtime is absent.

**Run in your terminal:**

```sh
durmem setup
durmem setup --harness codex --json
```

- `--email ADDR` signs in as that account even when this computer already has a credentialed
  section for the server. Its stores are added under account-specific section names; existing
  sections and the saved default stay unchanged. A section-name collision is refused.
- `--harness codex|claude|opencode|muse|dot|hermes` selects a harness without the selection prompt.
  Repeat it to select more than one. `muse` and `dot` need no installed program: Meta's Muse
  puts its connector and skills in `~/workspace`; OpenAI's Dot installs them under `~/.loom`.
  `hermes` needs the `hermes` program: setup adds a marked `mcp_servers.durmem` block to
  `~/.hermes/config.yaml` (or `$HERMES_HOME/config.yaml`) and `durmem uninstall` removes only that block.
  If the managed block markers are nested or unmatched, setup and uninstall preserve the config and
  ask you to repair the markers before trying again.
  See [Connect Meta's Muse to Durmem](../guide/connect-muse.md) or
  [Connect OpenAI's Dot to Durmem](../guide/connect-dot.md).
  See also [Connect Hermes to Durmem](../guide/connect-hermes.md).
- `--base URL` selects the HTTPS server. Setup uses the supplied URL first, then the single recorded `web_origin`, `LOOM_WEB_BASE`, and `https://durmem.ai`.
- `--ca-file PEM` trusts a self-signed certificate for that server and records its path.
- `--json` writes one JSON result to stdout; setup still prompts, with prompts and progress on stderr.

`durmem login` signs in and writes store connections to `~/.loom/stores.toml` without installing agent integrations. Use it on another computer or after logout.

If an install link from a campaign set `LOOM_SOURCE`, the installer keeps only that short label in `~/.loom/source`, and setup sends it with the sign-up so the visit can be counted. Delete `~/.loom/source` to remove it.

**Run in your terminal:**

```sh
durmem login
durmem login --base https://durmem.ai --json
```

Login accepts `--email ADDR`, `--base URL`, `--ca-file PEM`, and `--json`. `--email` explicitly
chooses the account to sign in as, including when other stores are already configured. Its base
selection is `--base`, then `LOOM_WEB_BASE`, then `https://durmem.ai`.

## Store and installation commands

- `durmem list_stores` lists stores configured on this computer; it does not report a coding agent's session-only default.
- `durmem logout --store NAME` removes one store connection from this computer. The server key stays valid elsewhere until separately replaced. To log out of the saved default while other stores remain, choose another saved default first.
- `durmem revoke --params '{"section":"NAME"}'` starts owner-verified replacement of that store's key. It returns a confirmation link; the key changes only after the owner confirms. After replacement, reconnect every computer using the old key. The store's data is unchanged.
- `durmem update` installs the latest release from the CLI's original installation server, or says that you are already up to date, or that your installed version is newer than the published one, and changes nothing; after an update, run `durmem setup` to refresh your harness integrations.
- `durmem drop_store SECTION --confirm SECTION` destroys that server-side store and removes its local section. This is irreversible; `--confirm` must exactly repeat the section name. Optional `--json` prints one result; `--base URL` must match the section's recorded server origin.
- `durmem uninstall` removes Durmem and stops this computer's workers, while keeping `stores.toml` and hosted data. Use `--dry-run` to preview verified local removals.
- Kanban operators: `durmem fleet` and `durmem residual` run Fleet; your coding agent runs them for you through the `loom-kanban-fleet` skill. See the [Kanban manual](../kanban/what-is-kanban.md).

Durmem no longer installs the five repository-specific documentation helpers:
`documentation-diataxis`, `documentation-review`, `documentation-structure`,
`documentation-verify`, and `loom-doc`. They remain available to Durmem source
maintainers.

In Windows PowerShell 5.1, pass JSON in a file because inline JSON loses its double quotes when passed to a native command. For `logout` or `revoke`, replace `NAME` with the section name and create `params.json` as UTF-8 without a byte-order mark:

**Run in your terminal:**

```powershell
[System.IO.File]::WriteAllText((Join-Path $PWD 'params.json'), '{"section":"NAME"}', [System.Text.UTF8Encoding]::new($false))
```

Then run `durmem logout --params-file ./params.json` to remove that connection, or `durmem revoke --params-file ./params.json` to request its key replacement.

`drop_store` exits with `0` on success, `2` on error, or `3` when the outcome is unknown; check the server before retrying an unknown outcome. `setup` and `login` exit with `0` on success, `1` if cancelled, `2` on error, and `3` for a partial result.

An agent-tool command exits with `0` when the call completes and `2` when it cannot run, for example because of a wrong parameter or a connection that does not answer within 30 seconds. It exits with `3` when it runs but returns an unsuccessful result, a declaration is rejected before anything is declared, or any item in a batch fails. The exception is an unknown store passed to `durmem logout --store NAME`, which exits with `1`. Pressing Ctrl-C exits with `130`. A batch still prints its full JSON result, so read it to see which items succeeded.

## Agent-tool store routing

For agent tools, `--store NAME` supplies a parameter only when that tool exposes a `store` parameter. A tool with a `namespace` parameter selects the store through that namespace; omit `--store` and pass `namespace` in `--params` or `--params-file`. Tools without a `store` or `namespace` parameter do not accept `--store`; use their documented parameters instead.

## Fleet config publication

Your coordinator manages Fleet desired settings with:

```sh
durmem fleet --store kanban config-publish --file desired.toml --base-revision N
```

Replace `N` with the current revision returned by `durmem fleet --store kanban show`
(`0` before the first publication). A mismatch refuses publication with “reload and retry”;
reload the settings and reconcile the changes before retrying. Omitting `--base-revision`
keeps unconditional publication available. The CLI initializes the Fleet protocol before
saving, through `initialize_fleet_store`; it does not initialize the Kanban protocol.
An upgraded residual also initializes Fleet revision 7 automatically when it reconciles a
board. Older residuals can then refuse the newer protocol until upgraded, so initialization
is not a manual step deferred until every residual has upgraded.

The optional TOML table `[runtime_holds]` maps host UUIDs to release strings in
`major.minor.patch` form (an initial `v` is also accepted). A host without an entry follows
the mirror unless another board holds it. Use holds only after every residual supports them
and the board's Fleet gate is revision 7. See [Stage Fleet runtime updates](../kanban/maintain-workers.md#stage-fleet-runtime-updates)
for the two-step rollout and the status checks required before releasing.

## Back up a store

Save a verified copy of a store you own on your local computer. The archive contains its database and rules. It is encrypted on the server's disk and decrypted on your computer.

**Run in your terminal:**

```sh
durmem backup STORE [--out FILE] [--base URL]
durmem backup palmerpenguins --out ./palmerpenguins.tar.gz
```

Without `--out`, the file lands in the current directory as `<store>-<UTC date and time>.tar.gz`. An existing output file is refused. On filesystems without hard links, a file created by another program between the final check and save can be replaced.

The command uses the store's connected server. If you pass `--base URL`, it must match that server's origin.
It automatically uses the selected store's key for the download. A key for another store cannot
download the backup, even if you own both stores.

The command downloads the backup as soon as it is ready. The server keeps the encrypted copy for
up to 30 minutes and removes it after a complete download. An interrupted download leaves that
copy until it expires. After expiry or removal, request a new backup; the one-request-per-hour
limit still applies.

Backups are owner-only, limited to 2 GB and one request per store per hour. The snapshot is crash-consistent per file; the database and rules are captured separately. `backup` exits with `0` on success and `2` on error.
