# Connect Hermes to Durmem

<!-- loom-doc: slug=connect-hermes; audience=both; section=guide -->
This guide shows how to connect Hermes to Durmem so its agent can save and retrieve knowledge
from your stores. `durmem setup --harness hermes` connects the tools and installs shell hooks
that bring project context into the conversation and check consequential terminal commands.

First, install the `durmem` command using [Quickstart](quickstart.md#1-install-durmem). Hermes
itself must already be installed, so that `hermes` runs in your terminal.

## Sign in and set up

> **Hosted:** Sign in and set up Hermes in one step.
>
> **Run in your terminal:**
>
> ```sh
> durmem setup --harness hermes
> ```

> **Private install:** Follow the sign-in steps in
> `/docs/connect-client#sign-in-and-connect-stores` on your private server
> with your server's hostname, then run `durmem setup --harness hermes --base https://<your-server>`.

Setup backs up `~/.hermes/config.yaml` (or `$HERMES_HOME/config.yaml`) before it changes anything,
then:

- adds a `durmem` entry under `mcp_servers`, between two `durmem setup` comment lines. Re-running
  setup rewrites only that block;
- turns off Hermes's built-in memory provider (`memory_enabled`, `user_profile_enabled` and
  `provider`), so it does not compete with Durmem;
- copies the Durmem skills into `~/.hermes/skills/` (or `$HERMES_HOME/skills/`);
- adds Durmem shell hooks while preserving your existing hooks;
- runs `hermes mcp list` and `hermes mcp test durmem` to confirm that the connection works.

Setup does not choose a store for Hermes. If `config.yaml` already has an `mcp_servers.durmem`
entry that setup did not write, setup stops and leaves the file unchanged; remove that entry, or
keep it and skip setup.

If `config.yaml` is a symlink, setup leaves it unchanged; use the manual configuration below.

Restart Hermes when setup finishes and review the first-use hook consent prompts below. Continue at
[Open the project](quickstart.md#3-open-the-palmerpenguins-project-in-your-harness)
in Quickstart to save and recall your first memory.

Hermes has a session-specific identity for Kanban work. Use the current conversation's native
session ID when a Durmem tool asks for `native_conversation_id`; Durmem identifies it as
`hermes@<session id>`. This identity goes stale when the Hermes session ends, so start a new
session before doing more Kanban work.

## Enable reminders and command checks

Hermes asks for consent the first time each configured shell hook runs. Review and approve the
Durmem command, `durmem hook --harness hermes`. Setup does not enable `hooks_auto_accept` or
approve hooks for you. Until you approve them, the MCP tools can work without the reminders or
command checks.

Gateway and other headless sessions, such as Telegram, have no terminal for the consent prompt;
their hooks do not run until you approve them. Open Hermes in a terminal once and approve each
displayed Durmem hook. `hermes hooks` has no approve command. If you have reviewed every pending
hook for this Hermes profile, the documented per-run `hermes --accept-hooks chat` option accepts
the unseen hooks for that invocation. It does not set a persistent auto-accept preference.

The first model call brings in the project's starting context; later prompts bring in relevant
saved guidance. Before a consequential `terminal` command, the shared attestation check can block
the call until the agent declares which standing memories it consulted. This checks that the agent
looked, not whether the command has your approval.

Hermes currently consumes reminder text from its before-model hook, but not from its before-tool
or after-tool hooks. Tool-event advisory text is therefore not delivered to the agent; ask it to
retrieve relevant guidance explicitly when needed. The integration also has no pre-compaction
capture hook. On Hermes versions without `post_compaction`, it cannot automatically re-prime after
compaction: ask the agent to refresh its project context, or start a fresh session.

To inspect the configured hooks, **run in your terminal:**

```sh
hermes hooks list
```

The list should show the Durmem command for `on_session_start`, `pre_llm_call`, `pre_tool_call`
and `post_tool_call`. Run `hermes hooks doctor` to check that the approved hooks are healthy.
See [Choose a store for a project](manage-stores.md#choose-a-store-for-a-project) to select the
coding store and project scope used by reminders.

## Configure by hand

If setup cannot be used, add this entry to `~/.hermes/config.yaml` (or `$HERMES_HOME/config.yaml`):

```yaml
mcp_servers:
  durmem:
    command: durmem
    args:
      - mcp
    enabled: true
```

Add this block too, so Hermes's built-in memory provider does not compete with Durmem:

```yaml
memory:
  memory_enabled: false
  user_profile_enabled: false
  provider: ''
```

This example does not name a store, so Hermes uses your configured default store. After connecting Hermes, use `loom_list_stores()` to check the section names, and load the one you want with `loom_load_store`.

For the reminders and command checks, also add these entries under `hooks:`. If an event already
has commands, add Durmem to that event's list rather than replacing them:

```yaml
hooks:
  on_session_start:
    - command: durmem hook --harness hermes
  pre_llm_call:
    - command: durmem hook --harness hermes
  pre_tool_call:
    - command: durmem hook --harness hermes
  post_tool_call:
    - command: durmem hook --harness hermes
```

Hermes also needs the Durmem skills in `~/.hermes/skills/` (or `$HERMES_HOME/skills/`) before it starts. Your Durmem server
publishes them in its plugin repository, which you can clone without signing in. In that
clone, the Hermes bundle is the only folder under `plugins/hermes/`, and its `skills/` folder
holds what Hermes needs. For a private server, replace `https://durmem.ai` with your server's address.

**Run in your terminal:**

```sh
git clone --depth 1 https://durmem.ai/durmem-plugin.git ~/durmem-plugin
mkdir -p "${HERMES_HOME:-$HOME/.hermes}/skills"
cp -R ~/durmem-plugin/plugins/hermes/*/skills/. "${HERMES_HOME:-$HOME/.hermes}/skills/"
```

Restart Hermes, then check the connection.

**Run in your terminal:**

```sh
hermes mcp list
hermes mcp test durmem
```

The list should include `durmem`, and the connection test should confirm that it responds.

## Agents without hooks or a long-lived connection

This section shows how to use Durmem from an agent whose Durmem lifecycle hooks are not wired, or that opens a
new MCP connection for every command it runs. Durmem still works with such
agents, with two adjustments.

A store you load stays loaded only for the MCP session that loaded it. An agent that connects
anew for each command would lose the store between commands, so it should start `durmem mcp`
once and send the load and the calls that depend on it over that one session. Each call should
also carry the conversation's id as `_meta.threadId`. Durmem matches that id to the agent's id,
`<harness>@<id>` (for example `hermes@<conversation id>`), in `whoami` and in Kanban owner
checks. A client that cannot send it can set the harness's session environment variable instead
(`HERMES_SESSION_ID` for Hermes).

For Kanban worker steps, ask Hermes to run `echo $HERMES_SESSION_ID` in its terminal and pass that
value as `native_conversation_id` when it calls `whoami`. Hermes changes the id when it compresses
the conversation, so read it again afterwards.

Without approved hooks, the automatic reminders do not happen: Durmem cannot surface
standing context before an action or guard risky commands. Replace the first of these by hand.
At the start of each conversation, and again after loading a store, the agent should read what
this call returns, with the loaded store and a short description of the task in hand:

```text
loom_read_probe_bundle(store="<store name>", query_text="what I am about to work on")
```

## Update or remove the connection

After running `durmem update`, run `durmem setup --harness hermes` again to refresh the skills,
then restart Hermes. If you configured Hermes by hand, copy the skills again as above
(`git -C ~/durmem-plugin pull` first).

`durmem uninstall` removes only the marked MCP and hook entries that setup wrote. An entry you added by hand, the
`memory` settings and the skills setup copied to `$HERMES_HOME/skills/` (or `~/.hermes/skills/`
by default) stay in place; remove them yourself if you no longer want them.
