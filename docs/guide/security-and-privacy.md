# Security and privacy

<!-- loom-doc: slug=security-and-privacy; audience=both; section=guide -->
This guide explains where Durmem keeps your memories, what leaves your computer, and who can
access the data. Use it to choose between the hosted service and a private server and to protect
the project knowledge you save.

## What Durmem stores, and where

Saved memories live in a database on the Durmem server you connect to: durmem.ai or your team's
private server. Your computer keeps the connection settings and credentials in
`~/.loom/stores.toml`.

## What leaves your computer

Durmem sends new memories and search requests to that server. To find related memories, it
computes embeddings—numeric representations of text—on your computer. The embedding model
runs locally. `durmem setup` and `durmem login` download its files from Hugging Face to prepare
your first save or search. If either command warns that it could not download the model, your
first save or search downloads it instead and can take close to a minute.

Depending on your coding agent and model, conversation content may also be sent to the agent's
provider. Check that provider's privacy terms; using a private Durmem server does not change this
data flow.

Claude Code and Codex may contact their plugin marketplace to check whether a newer Durmem plugin
is available. This update check does not send memory content.

By default, Durmem disables third-party usage reporting by the local libraries it uses to download
and run its embedding model.

## Who can read your data

Hosted stores are encrypted at rest and in transit. The service decrypts memory content to answer
your agent's requests, so the Durmem operator and hosting administrators may be able to read it.
This means the hosted service does not provide end-to-end encryption. See the
[Privacy Policy](https://durmem.ai/privacy) for how hosted data is used and retained.

Running a private Durmem server on your own computer and network is a supported deployment mode.
You control access, storage, backups, and retention, and are responsible for securing the server
and its data. If someone else operates your team's private server, ask them about those policies;
the hosted privacy policy does not govern that installation.

## Sharing and recovery limits

To give a trusted teammate access to a store, share that store's configuration block from
`~/.loom/stores.toml` through a secure private channel. They add the block to their own
`stores.toml` to connect to the same store. The block contains credentials that grant access;
share only the intended store's block, not your whole configuration file. See
[Share a store](../reference/stores-toml.md#share-a-store) for the steps.

To recover data later, [open an issue on GitHub](https://github.com/durmem/durmem/issues)
before deleting it. Your operator manages recovery on a private
server.

## Protect your account

- Do not save passwords, API keys, sign-in codes, or other secrets as memories.
- Keep `~/.loom/stores.toml` private and never paste its contents into a chat, issue, or screenshot.
- On a shared computer, remove its saved store connection when you finish. Signing out of the
  website alone only ends the website session; it does not remove the saved connection. See
  [Remove this computer's connection](manage-stores.md#remove-this-computers-connection).
- If a store key may have been exposed, use [Manage your stores](manage-stores.md) to replace it.

## Report a security issue

For a Durmem software vulnerability or exposed credential, email
[info@durmem.ai](mailto:info@durmem.ai). For a hosted-service issue, include steps to reproduce it;
for a private-server issue, notify its administrator first. Do not include keys, sign-in codes,
personal data, or private logs.
