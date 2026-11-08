# Local Durmem configuration

<!-- loom-doc: slug=stores-toml; audience=both; section=reference -->
Use this reference to choose a starting store for your projects and look up the local
configuration fields. It also explains how to share a store with a teammate.

Durmem keeps the registry at `~/.loom/stores.toml`. `durmem setup` and `durmem login` write it for you.
The file contains connection credentials. Keep it out of public messages and support requests;
share a specific store's block only when you intend to grant access to that store.

If the plugin is installed before you finish setup, asking your agent to list stores returns an
empty list and a reminder to run `durmem setup`. Finish [Quickstart setup](../guide/quickstart.md#2-connect-your-coding-harness)
before saving or retrieving memories.

The shortened example below shows a section name and the default only; connection fields are
omitted. Do not replace your setup-managed registry with this partial example.

```toml
default = "demo"

[demo]
```

The store name `[demo]` is passed to the command as `durmem --store demo`. The top-level `default`
is the global fallback when no command, session, or applicable Workspace mapping selects a store. An
explicit `--store` or harness session choice can select another store without changing this file.
Change the saved `default` only to select another section already in the file.

New store names are normalized to lowercase letters, numbers and underscores. If normalization
leaves no characters, the generated section name is `durmem`. Existing section names stay unchanged.

## Fields

- `default` — the global fallback section name. A Workspace mapping in this file or a session-only
  default may select another store; otherwise this setting initializes the harness session default.
  An explicit `--store` selects a store for that command. Change it only to select another section
  already in the file.
- `endpoint` — the store's connection endpoint. Setup-managed.
- `server_key` — the server's public key, used to identify the server. Setup-managed.
- `store_key` — the credential that authorizes access to the store. Anyone you give it to can access that store; share it only as part of an intentional store connection.
- `curve_public_key` and `curve_secret_key` — the connection's public and private keys. Setup-managed; keep the private key secret.
- `store` — the server-side store identifier. Setup-managed. This is distinct from the local section name.
- `description` — a short description of what the store contains, shown in the store list.
- `socks_proxy` — an optional SOCKS proxy address for the connection. Set it only when your administrator gives you one.
- `web_origin` — the HTTPS web origin used for sign-in, plugin downloads, and the WebSocket
  fallback when a proxy cannot reach the data port. Setup-managed; the canonical `endpoint`
  remains unchanged whichever route is used.
- `ca_file` — an optional path to a certificate file for a self-signed server; set it with `durmem setup --ca-file` or `durmem login --ca-file`.

You can edit `description` or `socks_proxy`. Setup manages `namespace_scheme` and `fastembed_model`;
changing these fields may break your store connection.

## Share a store

Sharing a store means giving another person its connection credentials. In your local editor,
copy the store's complete named block, such as `[demo]`, from `~/.loom/stores.toml` and send it
through a secure private channel to the teammate who should have access.

Your teammate adds that block to their own `~/.loom/stores.toml`, keeping their existing stores
and settings. If the block's name is already in use for a different store, they give the new
block a different local name rather than replacing the existing connection. A `ca_file` or
`socks_proxy` setting may need adjusting for their computer.

After restarting their harness, they can ask their agent to connect to the shared store by its
local name. This gives access to the same server-side store; it does not copy the memories into
a new store. Only the selected store's block needs to be shared, not the whole registry or its
global default and Workspace mappings.

## Pick a store for a checkout by hand

To choose a starting store by project, use two files together. The repository checkout's root `loom.toml`
names its Workspace; the global `~/.loom/stores.toml` maps that Workspace to a store. The repository's Workspace
identity stays with the checkout, while connection choices and credentials stay in your private
registry. Your agent can confirm the Workspace and show the mapping to add, but should not read
or edit the registry itself. See [Manage your stores](../guide/manage-stores.md) for that workflow.

To set the two entries yourself:

1. In the repository-root `loom.toml`, set the confirmed Workspace name:

   ```toml
   active_workspace = "my-workspace"
   ```

2. In `~/.loom/stores.toml`, map that Workspace to a store:

   ```toml
   [workspace."my-workspace"]
   loom-coding = "demo"
   ```

The mapping applies to every checkout using that Workspace. A store mapping inside `loom.toml`
is ignored: only the registry holds the Workspace-to-store choice. The default store is selected
in this order:

1. An explicit choice in a prompt for the current agent session.
2. The matching `[workspace."<name>"]` entry in `stores.toml`.
3. The `stores.toml` file's global `default`.

Use `durmem list_stores` to see stores configured on this computer. The command does not report a
coding agent's session-only default. Use `durmem login` to connect another computer, and
`durmem setup` to configure a coding agent. Ask your administrator before changing a server
endpoint or certificate setting.
