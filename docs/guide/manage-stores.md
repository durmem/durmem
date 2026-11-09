# Manage your stores

<!-- loom-doc: slug=manage-stores; audience=both; section=guide -->
This guide shows you how to choose and manage your organization's Durmem stores. You will connect
sessions to the right store and create or remove stores as your needs change.
A store is a database on the server where connected agents can share saved knowledge. Keeping
separate stores lets you organize that knowledge for different projects and teams.

In this guide, terminal commands appear in code blocks under **Run in your terminal**. Requests
for your coding agent appear as quoted prompts under **Tell your coding agent**.

You can also view, create, and delete stores, or replace their keys, on the Stores page at
[durmem.ai](https://durmem.ai/stores) or your private Durmem website.

## See your stores

**Run in your terminal:**

```sh
durmem list_stores
```

The list shows the exact names and descriptions of stores configured on this computer. Use a
name from the list in the commands below.

You can also ask the agent in your harness (for example, Codex, Claude Code, or OpenCode):

**Tell your coding agent:**

> List my Durmem stores and their descriptions.

## Connect to a store

An agent can connect to more than one store in a session. This is useful when your work needs
knowledge from several projects or teams. The session default is the store it uses when you do
not name one; you can use another connected store by naming it in the prompt.

To connect another named store for this session without changing its default, ask your agent to
load the exact name from the list:

**Tell your coding agent:**

> Connect to [demo] for this session, keeping my current default store.

Replace `[demo]` with a name from your list. Once connected, name the store in a prompt to use its
memories. The connection lasts for this session; its saved settings stay the same.

## Change the session default

If most of your work in this session belongs in one store, make it the session default so you
do not need to name it in every prompt:

**Tell your coding agent:**

> Please use [demo] as the default for this session. What’s the current default now?

The agent should confirm the change. This choice lasts only for the current harness session;
the saved starting store for future sessions stays the same. Replace `[demo]` with another store
name when you want to switch again.

## Choose a store for a project

A session-only choice is useful for a temporary switch. To have new sessions start in the
right store automatically, associate the project with a Workspace. A Workspace groups related
projects across repositories so they can use the same store. Different local copies, or
checkouts, of the same project can belong to different Workspaces.

Two files make that selection. The checkout's root `loom.toml` names its Workspace. Your own
`~/.loom/stores.toml` maps that Workspace to a store, so the mapping applies to every checkout
using that Workspace. If no mapping applies, the saved global default supplies the starting store.

The `loom-coding` skill guides project memory. If this checkout has no confirmed Workspace,
ask the agent to confirm one with you and record its name in the root `loom.toml`.

**Tell your coding agent:**

> Confirm this checkout's Workspace and show me the global Workspace mapping I should add to use
> [demo].

Add the mapping yourself to your global configuration. New sessions in that Workspace will use
it; an already-running session keeps its current default. The saved global default is unchanged.
A repository's `loom.toml` only names the Workspace; store mappings belong in the global registry.
See [Pick a store for a checkout](../reference/stores-toml.md#pick-a-store-for-a-checkout-by-hand).

**Check:** In a fresh session, ask the agent to report the selected Workspace and effective store.
Continue only when they match your choice.

## Create a store

For durmem.ai's hosted free-plan store and storage limits, see the
[Quickstart](quickstart.md#hosted-free-plan). Other plans and private servers may differ.

Before creating a store, choose an unused name, a short description of what it will hold, and a
domain. A domain provides guidance for capturing and retrieving memories; `CodingDomain` is for
project work and `PersonalDomain` is for personal notes. The command will not replace an existing
store. It signs in with a store you have already configured, so it cannot create your first store.
To configure your first store, run `durmem setup` as shown in the
[Quickstart](quickstart.md#2-connect-your-coding-harness).

For example, to create a new store for personal notes named `[notes]`, run this in your terminal.
Choose a different unused name if `[notes]` already appears in your list.

**Run in your terminal:**

```sh
durmem create_store --params '{"name":"notes","usage":"Personal notes","domain":"PersonalDomain"}'
```

When the command reports `status: ok`, the store is ready and appears in `durmem list_stores`.

## Turn a store into a Kanban store

Any store you already have can become a Kanban store, where agents share assignments, progress,
questions and results (see [What is Kanban?](../kanban/what-is-kanban.md)). To use a new
store for Kanban, create it as above, then ask the coordinator to convert it:

**Tell your coding agent:**

> Act as the Kanban coordinator and initialize [demo] as a Kanban store.

Replace `[demo]` with a name from your list. The agent confirms that [demo] is now a Kanban store
and loads the Kanban skill for it. Asking again changes nothing, so it is safe to repeat the
prompt if you are unsure it finished.

## Disconnect a store

You can disconnect a store from the current harness session without deleting it or removing its
saved connection, as long as it is not the session default. The store the agent started with stays
connected for the session and cannot be disconnected, even after you change the session default.
Use the example below only if `[demo]` was not the store this agent started with.

**Tell your coding agent:**

> Please disconnect [demo] from this session, but leave my default and saved connection as they
> are.

Replace `[demo]` with the store's exact name.

## Use the same store on another computer

Durmem keeps saved memories in the store, so an agent on another computer can find the same
memory when it uses the same account, server, and store. Project files are separate; make the
repository available on both computers before asking about project-specific memories.

On the computer where you saved a memory, ask for its reference—the identifier for that saved
memory:

**Tell your coding agent:**

> Can you find the goal I saved for this project in [demo] and give me its Durmem reference?

On the other computer, connect Durmem to the same account and server and make the repository
available. You can use a different harness there. Ask its agent to find the same goal in `[demo]`
and compare the returned reference with the one above: matching references identify the same
saved memory. Replace `[demo]` with the store you used. If the memory is missing, see
[Troubleshooting](../reference/troubleshooting.md).

## Remove this computer's connection

To remove a store's saved connection settings from this computer, use its configured name. This
does not delete the store or its memories. If it is the global saved default and another store is
configured, change the `default` field in `~/.loom/stores.toml` to another configured section
first. See the [global registry fields](../reference/stores-toml.md#fields).
Changing the default only for a harness session does not change this saved setting.

**Run in your terminal:**

```sh
durmem logout --store demo
```

Replace `demo` with the store name to remove. The command confirms when its saved settings are
removed. This does not revoke the server key; copies on other computers remain valid until the key
is separately replaced. To connect this computer again, follow the Quickstart with the same
account and server.

## Revoke a store key

A store key grants access to that store. If a key may have been exposed, start the replacement
process with the store's exact name:

**Run in your terminal:**

```sh
durmem revoke --params '{"section":"STORE_NAME"}'
```

Replace `STORE_NAME` with the exact store whose key you need to replace. The command prints a link
to that store's server. Open it, sign in and confirm; only then is the key replaced. Your memories
stay in the store. Every computer that used the old key must reconnect using the replacement key
in that server's Stores connection panel.

Revoking works for a store connected through your account on its server. If the command reports
that the store has no recorded server address, run `durmem login --base <server origin>` to
reconnect and try again. If it reports that the store uses a direct or legacy credential, or the
server does not support verified-account revocation, contact the server's administrator; no key
has changed.

## Back up a store

A backup is a copy of a store you own that you keep on this computer, outside Durmem. Make one
before you delete a store or replace its key.

**Run in your terminal:**

```sh
durmem backup STORE_NAME
```

Replace `STORE_NAME` with the store's exact name from `durmem list_stores`. Durmem saves the file in
the current directory as `STORE_NAME-<UTC date and time>.tar.gz`. On macOS, Linux, and Windows,
only you can read it. To save elsewhere, pass `--out FILE` with the full path to the output file, not
just a directory. The output file's parent folder must already exist. If a file with that name
already exists, Durmem stops with an error instead of overwriting it. On a filesystem without hard
links, Durmem checks for an existing file just before saving, so a file created at that same moment
by another program could be replaced.

Durmem uses the selected store's key to download its backup. A key for another store cannot
download it, even if you own both stores.

Durmem downloads the backup automatically when it is ready. The server keeps the encrypted copy
for up to 30 minutes and removes it after a complete download. An interrupted download leaves
that copy until it expires. After the copy expires or is removed, request a new backup; the
one-backup-per-hour limit still applies.

After saving the backup, Durmem prints `Backup saved to <path>` with the output file's path.

Durmem decrypts the download on this computer and checks it before saving it, so a file that
exists has passed that check. To look inside, list its contents:

**Run in your terminal:**

```sh
tar -tzf FILE
```

The archive holds the store's database, its rules and a manifest. You can back up each store once
per hour, and an archive can be at most 2 GB. Keep the file as a copy of the store. The
[CLI reference](../reference/cli.md#back-up-a-store) lists the options and exit codes.

On the hosted service, Durmem also makes a nightly backup of each hosted store on the same server.
You can download and keep a backup of your store. See the
[Privacy Policy](https://durmem.ai/privacy) for how Durmem protects your data.

## Delete a store

**This permanently destroys the named store and its contents on the server, then removes its
connection from this computer.** Check the exact store name carefully before running the command.

**Run in your terminal:**

```sh
durmem drop_store STORE_NAME --confirm STORE_NAME
```

Replace both occurrences of `STORE_NAME` with the chosen store's exact name.

The confirmation must exactly repeat the store name. If the command reports that the outcome is
unknown, check the store on its server before retrying; it may already have been deleted.

## Sign out or request account deletion

Choose **Log out** on the website to end that website session. This does not remove this
computer's store connections. To remove this computer's saved connection, see
[Remove this computer's connection](#remove-this-computers-connection).

To request deletion of a hosted account and its data, email
[info@durmem.ai](mailto:info@durmem.ai). Support may ask you to verify your identity. Do not send
passwords, sign-in codes, or store keys. Read the
[Privacy Policy](https://durmem.ai/privacy) for current details about deletion, retention, and
backups. For a private Durmem server, contact its administrator about account or data deletion.

## If something goes wrong

If a command returns an error or a pending result, check the store list or website to see whether
it finished before retrying. For a missing or locked store, or an unfinished key replacement or
deletion, see [Troubleshooting](../reference/troubleshooting.md).

## Related guides

Next, [Durmem data types for coding agents](../tutorials/data-types-for-coding-agents.md) shows
how to save different kinds of knowledge and connect related work.

For changing or removing a saved memory, see
[Inspect, correct or remove one memory](quickstart.md#inspect-correct-or-remove-one-memory)
in the Quickstart.

For a worked example of continuing unfinished work, see
[Give agents real-time reminders](../tutorials/give-agents-real-time-reminders.md#6-continue-from-a-saved-handoff).
For connection or memory
problems, use [Troubleshooting](../reference/troubleshooting.md).
