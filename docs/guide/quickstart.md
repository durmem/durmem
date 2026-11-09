# Quickstart

<!-- loom-doc: slug=quickstart; audience=both; section=guide -->
This guide shows you how to set up and use Durmem for a coding project. You will save goals and
findings from one coding session, then use them in a fresh session.

Read [Why Durmem](what-is-durmem.md) first for the basic concepts. OpenAI's Dot in ChatGPT
uses a command-based connection with manual context retrieval; see
[Connect OpenAI's Dot to Durmem](connect-dot.md) for its setup and differences.

You need a coding harness—Claude Code, Codex or OpenCode—installed to follow this guide. Throughout
these guides, terminal commands appear in code blocks under **Run in your terminal**. Requests to the agent
running in your harness appear as quoted prompts under **Tell your coding agent**.

Durmem needs outbound HTTPS for sign-in. For store access, it first tries the server's data port
(7443 on durmem.ai), directly or through your environment's HTTPS proxy. If that port is blocked,
it can use a secure WebSocket connection on the server's HTTPS origin when the server supports it.
A private server may use a different data port. See
[proxy-only networks](../reference/troubleshooting.md#sign-in-works-but-durmem-cannot-reach-your-stores-sandboxed-or-proxy-only-networks)
if sign-in works but store calls fail.

**Codex users only** (Claude Code and OpenCode readers: skip this check). Durmem sets Codex up through
the `codex` command, so confirm you have it before you install Durmem.

**Run in your terminal:**

```sh
codex --version
```

Continue only if this prints a version. If it does not, install the Codex command-line tool from
[github.com/openai/codex](https://github.com/openai/codex); the ChatGPT desktop app alone is not enough.
Then open a new terminal and run the check again.

> **Private install:** Start with the private-server guide at `/docs/connect-client`
> (“Connect a computer to your private server”). After its connection check, continue at
> [Verify the harness connection](#verify-the-harness-connection), then
> [Open the project](#3-open-the-palmerpenguins-project-in-your-harness). Use your private server and the same store throughout.

## 1. Install Durmem

> **Private install:** Use the client installer on your private server, following
> its "Install the client" section
> (`/docs/connect-client#install-the-client`) on your private server. Check that `durmem --version` prints a version.

> **Hosted:** Install and connect to durmem.ai.
>
> Install the `durmem` command, the main tool for managing your Durmem installation and setting up
> your coding harnesses.
>
> On macOS and Linux, the installer needs Python 3, `curl`, `tar`, and `sha256sum` or `shasum`
> already on your computer. It installs a private `uv` under `~/.loom/bin` for Durmem's runtime;
> if you already have `uv` on your PATH, the installer leaves it in place and Durmem uses its
> private copy. On Windows the installer needs only `tar` in PowerShell and provides its own
> private `uv` and Python.
>
> On macOS and Linux, check that Python 3 is present before you install: run `python3 --version`
> in your terminal. A new Mac does not include it. If the command is not found, install Apple's Command Line Tools with
> `xcode-select --install`, or install Python 3 from python.org or Homebrew. On Linux, install it
> with your package manager, for example `sudo apt install python3` on Ubuntu or Debian. Then open
> a new terminal and run the install line below.
>
> Before installing on Windows, run `tar --version` in PowerShell and check that it prints a
> version. Windows 10 1803 and later include `C:\Windows\System32\tar.exe`. If the command is not
> found, make sure `C:\Windows\System32` is on PATH; if `tar.exe` is missing, update Windows.
> Open a new PowerShell window and retry the check before installing.
>
> **Run in your terminal** (macOS or Linux):
>
> ```sh
> curl -fsSL https://durmem.ai/.well-known/cli/install.sh | sh
> ```
>
> **Run in your terminal** (PowerShell on Windows):
>
> ```powershell
> irm https://durmem.ai/.well-known/cli/install.ps1 | iex
> ```
>
> If you arrived from a campaign link, the installer keeps only that short campaign label in
> `~/.loom/source` so your sign-up can be counted; delete that file to remove it.
>
> On macOS and Linux, make `durmem` available in this terminal before anything else. If the
> installer used its own uv, it writes `~/.loom/env` and usually adds a line to your shell
> profile; if it could not update the profile, it prints the line to add yourself. Open a new
> terminal, or run `. "$HOME/.loom/env"` in this one. If you already had uv on PATH, whether you
> need to act depends on `~/.local/bin`: if it is already on your PATH, the installer prints
> nothing and `durmem` works as soon as it is installed; if it is not, the installer prints two
> commands: run both in your terminal (the first adds the PATH line to your profile, the second
> sets it for this shell). On Windows the installer updates PATH for you; open a new terminal
> window to use it. Then check the installation:
>
> **Run in your terminal:**
>
> ```sh
> durmem --version
> ```
>
> When it prints a version number, Durmem is installed.
>
> If PowerShell still says `durmem` is not recognized, use its full path:
>
> **Run in your terminal** (PowerShell on Windows):
>
> ```powershell
> & "$HOME\.loom\bin\durmem.cmd" --version
> ```

## 2. Connect your coding harness

> **Private install:** Complete the sign-in steps in
> `/docs/connect-client#sign-in-and-connect-stores` on your private server
> with your server's address, then check the harness connection below.

> **Hosted:** Connect your harness to durmem.ai.
>
> Run setup to sign in to Durmem and connect your harness:
>
> **Run in your terminal:**
>
> ```sh
> durmem setup --base https://durmem.ai
> ```
>
> If you used the full-path fallback above, use it for setup too:
>
> **Run in your terminal** (PowerShell on Windows):
>
> ```powershell
> & "$HOME\.loom\bin\durmem.cmd" setup --base https://durmem.ai
> ```
>
> Follow setup's prompts to select your harness, accept the terms, and sign in with the code emailed
> to you. Setup creates your account if you don't have one yet. The prompts come in this order:
>
> 1. `Select your harness:` lists the harnesses it found. Press Enter to install Durmem for all of
>    them, or type the names you want. Setup skips this prompt when you name a harness with
>    `--harness`, as shown below.
> 2. `Email address:` is where Durmem sends your sign-in code.
> 3. Links to the Privacy Policy and the Terms of Service appear, followed by the prompt
>    `Type 'I agree' to accept the Privacy Policy and Terms of Service:`. Type `I agree` to accept
>    them. Setup emails the code only after you accept. It skips this step only when this computer is
>    already signed in to the same server with the same email and the server shows that you
>    accepted the current terms; on a new computer, setup asks again.
> 4. `Verification code (hidden):` is where you enter the code from the email. Paste the code and
>    press Enter. The characters do not appear as you type or paste them, so a blank prompt is
>    normal.
>
> If this computer already has stores for another Durmem account, add `--email ADDR` to
> `durmem setup` to sign in to the account you choose. `durmem login --email ADDR` does the same
> sign-in without installing harness integrations. Both commands keep the hidden verification-code
> prompt and add the account's stores under account-specific names while preserving existing
> connections.
>
> While your stores are still being created, setup prints `Setting up your Durmem stores (this usually
> takes about 30 seconds)...` and waits. An account that already has its stores continues without
> that wait.
>
> After sign-in and store setup succeed, setup downloads the search model (about 70 MB) to your
> local cache, preparing your first save or search. If setup warns that it could not download the
> model, the first save or search downloads it instead and can take about a minute.
>
> When setup finishes, restart your harness as setup instructs. On Windows, fully quit the
> Codex or ChatGPT desktop app from its system tray menu before reopening it; closing the
> window alone can leave it running.
>
> This signs you in to Durmem, not your harness's model provider. Keep using your existing
> harness sign-in or API-key setup to chat with the agent.
>
> If you want to name a harness in the command, use `claude`, `codex` or `opencode` after
> `--harness`, for example `durmem setup --base https://durmem.ai --harness claude`. For Hermes,
> Muse or Dot, follow their own pages under [Other harnesses](#other-harnesses).

### Save and recall one memory from the terminal

You can check that Durmem is working before you open a harness. Save one memory in the practice
store, then find it again.

**Run in your terminal:**

```sh
durmem --store demo loom_save --params '{"entity":"Finding(\"first success\")","content":"My first Durmem memory"}'
```

The command prints a `fact_id`. Now search the practice store for the text you saved:

**Run in your terminal:**

```sh
durmem loom_query --params '{"namespace":"demo_root","rule_name":"text_search","args":["first Durmem memory",[],"or"]}'
```

The result includes the memory you just saved with `"current_status":"current"`.

### Verify the harness connection

The Loom engine powers Durmem's memory storage and recall.
The plugin is `loom@durmem`; the MCP connection is `durmem`. MCP (Model Context Protocol) lets
your agent call Durmem tools to save and retrieve memories. After restarting your harness, check
that the connection is listed:

- **Claude Code:** start a new session. In Claude Code (not a terminal), enter `/hooks`. Durmem's hooks are listed with source
  `Plugin`. In your terminal, run `claude mcp list` and find the line that starts with
  `plugin:loom:durmem: ` and ends with ` - ✔ Connected`.
- **Codex:** if Codex asks whether to trust hooks from `loom@durmem`, choose to trust them
  permanently. Until you trust the hooks, setup prints `Durmem hook warning: Codex reports the Durmem
  preToolUse hook untrusted (current definition not approved); open /hooks and review and trust the
  current Durmem hooks.` The hooks are installed but not yet trusted. Start `codex`, enter `/hooks`,
  review the Durmem hooks and trust them; the warning stops once they are trusted. In your terminal,
  run `codex mcp list --json` and check that the `durmem` entry is enabled. Some Durmem updates
  change hook definitions, so Codex may ask you to trust the hooks again; open `/hooks` in Codex
  and trust the current Durmem hooks.

  To let your agent save and recall memories, approve Durmem's tool calls when prompted in an
  interactive Codex session. This is separate from trusting hooks. If you want Codex to approve
  Durmem's tools automatically by default in future sessions, set
  `default_tools_approval_mode = "approve"` under
  `[plugins."loom@durmem".mcp_servers.durmem]` in `~/.codex/config.toml`, then restart Codex.
  This setting applies only to Durmem's tools.

  On Windows, if Codex cannot read the installed Durmem skills because a command is
  `blocked by policy`, check its Windows sandbox before continuing. On compatible devices,
  `windows.sandbox=mxc` enabled a read-only skill command; follow the
  [Windows sandbox check](../reference/troubleshooting.md#codex-cannot-read-durmem-skills-on-windows).

  On Ubuntu 24.04, see [Troubleshooting](../reference/troubleshooting.md#codex-fails-to-start-its-sandbox-on-ubuntu-2404)
  if Codex reports a sandbox error.
- **OpenCode:** restart OpenCode. The first time OpenCode starts with the plugin installed, it
  downloads `@opencode-ai/plugin`, OpenCode's plugin support package, from registry.npmjs.org.
  This package lets OpenCode load plugins, including the Durmem integration. On a computer that cannot reach the registry,
  start-up waits about 70 seconds each time until it can. In your terminal, run `opencode mcp list` and
  check that `durmem` is listed. The plugin starts its installed launcher directly.


## 3. Open the `palmerpenguins` project in your harness

We use the public `palmerpenguins` repository as the example throughout the Durmem guides and tutorials.
You can replace it with your own project if you prefer. To set up the sample repository:

**Run in your terminal:**

```sh
git clone https://github.com/mcnakhaee/palmerpenguins.git
cd palmerpenguins
```

Start your harness in the project folder. For Claude Code, run:

**Run in your terminal:**

```sh
claude
```

For Codex (now part of ChatGPT), run `codex`. For OpenCode, run `opencode`.
Continue this guide in your harness's chat.

## 4. Save to a Durmem store

A Durmem store is a database on the server that holds saved memories. With the hosted service,
your database lives on durmem.ai. You can use multiple stores with different access permissions,
so each team or project can control who accesses its data. See [Manage your stores](manage-stores.md)
for creating and managing stores. Here, we will use the practice store named `[demo]`, which is
automatically created when you sign up.

### Choose this session's default store

Your session default is the store your agent uses when you do not name a store explicitly in a
prompt. Square brackets identify a store name: `[demo]` means the store named `demo`. The brackets
are optional, but we recommend them to make prompts clear.

**Tell your coding agent:**

> Use [demo] as the default store for this session.

This choice applies only to the current session; it does not change the default store when the
agent starts next time. To choose the starting store for future sessions,
see [Choose a store for a project](manage-stores.md#choose-a-store-for-a-project).

Next, confirm the project scope: the repository, Project, Workspace and Organization
that this memory belongs to. This identifies the project each memory is about when a store holds
knowledge from several projects. The `loom-coding` skill guides this check. If the checkout is new,
confirm the names before your agent creates its scope records. For example, your `palmerpenguins`
repository could belong to a Project called “Penguin report”, within a Workspace called “Data
analysis” that groups related projects, under an Organization called “Research team” for your
team or account. Confirm your own names with the agent; these names are examples.

**Tell your coding agent:**

> Is Durmem ready to save things for this repository in [demo]? Check the project scope,
> and ask me to confirm anything missing before setting it up.

Answer any questions from your agent, then continue when it confirms the project scope in `[demo]`.

### Import existing project instructions

If your project already has instructions in `CLAUDE.md` or `AGENTS.md`, we recommend saving their
guidance in Durmem so agents can continue working under the same rules across sessions and harnesses.
Each typed memory is a record with a category, such as a Goal for an outcome or a Directive for
a standing instruction. Use this prompt to review what to save:

**Tell your coding agent:**

> Read this project's CLAUDE.md and AGENTS.md if present. Propose the durable decisions,
> instructions, conventions and goals worth remembering in Durmem. Show me the proposed typed
> memories and their source-file references first. Skip duplicates and secrets.

Review and approve the agent's proposals before asking it to save them to `[demo]`.

Now add something useful about the project to Durmem. For example, set a goal:

**Tell your coding agent:**

> Save this to Durmem in [demo] as my current goal for this project: I’m preparing a bar chart
> of penguin counts by species and island for Friday’s team update.

The agent should confirm that it saved the goal for the `palmerpenguins` project.

## 5. Connect and read from a store

Once a fact is written to a store, other agents connected to that store can read it.

Open a fresh harness session in the same repository. You can use a different harness or computer.

**Tell your coding agent:**

> Use [demo] as the default store for this session.

Then ask:

**Tell your coding agent:**

> Read my current goal for this project from Durmem in [demo], then help me plan my next step.

Check that the plan cites the goal you saved in the earlier session. You can also ask for a count
of the facts already stored in `[demo]`:

**Tell your coding agent:**

> Show me a count of all the facts stored in [demo] by their types.

### Inspect, correct or remove one memory

Plans change, and saved memories often need updating. Continuing the example above, suppose the
team update moves from Friday to Monday. First, ask the agent to find the saved goal:

**Tell your coding agent:**

> Show me the palmerpenguins goal we saved in [demo], with its reference.

The reference identifies that exact memory. Once you have found it, tell the agent what changed:

**Tell your coding agent:**

> The chart is now for Monday's team update. Please update the goal.

Ask the agent to read back the current goal; it should now say Monday. Durmem keeps the earlier
goal as history so you can trace the change. If a saved statement was wrong from the start,
tell the agent it was a mistake and ask it to correct that record instead.

You can also remove an unwanted memory. Try this with a practice note:

**Tell your coding agent:**

> Save an info note in [demo] that says "Delete me: practice note" and show me its reference.

Then ask:

**Tell your coding agent:**

> Retract that info note and check that it no longer appears as a current memory.

Retraction removes the note from ordinary reads. If an update or retraction does not appear to
work, see
[Troubleshooting](../reference/troubleshooting.md#a-saved-memory-is-wrong-or-unwanted).

## 6. Check your stores

A team can set up multiple stores for different projects or functions. Ask your agent which
stores are available to your organization:

**Tell your coding agent:**

> What Durmem stores are available to my organization? Show me their names and descriptions.

On durmem.ai, sign-up creates three starter stores: `[demo]`, `[coding]` and `[kanban]`. If you
have not added or deleted any stores, these are the three you should see under your account.

### Hosted free plan

On durmem.ai, the hosted free plan includes up to five stores and 200 MB of storage across them.
The starter stores (`[coding]`, `[demo]`, and `[kanban]`) count toward the five-store limit. Other
plans and private servers may have different limits.

## You're set up

- Next: [Manage your stores](manage-stores.md) explains how to connect, organize and manage the
  stores your agents use.

## If something goes wrong

- **`durmem` is not found after installing.** On macOS and Linux, run the PATH command the
  installer printed, then try again. On Windows, open a new terminal window and try again.
- **Setup doesn't list your harness.** Install the harness first, then run setup again.
- **Codex hook errors after a plugin update:** A session that was already running can report hook errors mentioning a missing `loom_codex_hook.py` or `resolve_uv.sh`. After updating the plugin, start a new Codex session.
- **The new chat doesn't use what you saved.** Ask it to "find the goal I saved for this
  project". If it finds the goal, memory is working. See
  [Troubleshooting](../reference/troubleshooting.md) for why a chat may not use it on its own.

## Update or remove Durmem

### Update Durmem

To replace an old `loom` command with `durmem`, update it once:

**Run in your terminal:**

```sh
loom update
```

Then use `durmem` in your terminal, scripts and scheduled commands. The installer removes
recognized old `loom` launchers and leaves no `loom` alias. If `loom update` is missing or fails,
rerun the installer from the server you originally used, following [Install Durmem](#1-install-durmem).
Follow its PATH instructions and printed setup command, then restart your coding harnesses.
Keep existing `~/.loom` paths, `stores.toml`, `loom_*` tools and `loom-*` skills under their current names.

If you already have `durmem`, update it with:

**Run in your terminal:**

```sh
durmem update
```

If you already have the latest release, `durmem update` says so and changes nothing. Otherwise it
installs the latest release, and when it finishes its last setup reminder includes your server's
address. Copy only the
command between `Next: run ` and ` to refresh your coding harnesses.`; those phrases are not part
of the command. Keep any quotes around the launcher path or server address.

> **Hosted:** The setup command for durmem.ai is:
>
> **Run in your terminal:**
>
> ```sh
> durmem setup --base https://durmem.ai
> ```

> **Private install:** On your private server, use the sign-in steps in
> `/docs/connect-client#sign-in-and-connect-stores`
> with your own server's address. If PowerShell cannot find `durmem`, use the full-path
> setup command in [Connect your coding harness](#2-connect-your-coding-harness), keeping your server's
> address. After setup, restart your harnesses. On Windows, quit the Codex or ChatGPT desktop app
> from the system tray before reopening it. `durmem --version` shows the version you now have.


### Remove Durmem

To preview what would be removed:

**Run in your terminal:**

```sh
durmem uninstall --dry-run
```

If the summary is right, run `durmem uninstall`. It removes the `durmem` command and Durmem's
setup in your coding harnesses, and stops any Kanban workers running on this computer.
It keeps your hosted account and stores, with all their memories, and your `stores.toml`, so you
can reinstall later and pick up where you left off.

## Other harnesses

For Hermes, follow [Connect Hermes to Durmem](connect-hermes.md). For chat assistants that set
themselves up, follow [Connect Meta's Muse to Durmem](connect-muse.md) or
[Connect OpenAI's Dot to Durmem](connect-dot.md). For a client that can only connect to a web
address, see [Connect an MCP client over the web](hosted-mcp-endpoint.md).

Questions or problems? [Open an issue on GitHub](https://github.com/durmem/durmem/issues).
