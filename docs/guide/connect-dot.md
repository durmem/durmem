# Connect OpenAI's Dot to Durmem

<!-- loom-doc: slug=connect-dot; audience=both; section=guide -->
OpenAI's Dot in ChatGPT can save and retrieve project knowledge through Durmem using
commands in its own workspace.
You ask Dot to set it up; Dot runs the commands. You only need to provide your email address,
accept the terms, and relay the sign-in code from your email when Dot asks.

## Ask Dot to set it up

Paste this to Dot:

> Read https://durmem.ai/docs/connect-dot and set up Durmem for me.

The following steps are for Dot, not commands for you to run.

## Steps for Dot

1. Install the `durmem` command using the [Quickstart installer](quickstart.md#1-install-durmem).
   Follow its PATH instructions, then check `durmem --version`.
2. Run `durmem setup --harness dot` in your terminal. Setup asks three things in turn. Ask the user
   in the chat, then type the answer at the prompt:

   - **Email address.** Ask the user for it.
   - **Consent.** Show the user the Privacy Policy and Terms links that setup prints. Type the
     agreement only after the user has agreed.
   - **Sign-in code.** Tell the user that a code was emailed to their address and ask them to paste
     it into the chat. Then type it at the prompt. Never read the user's mailbox, and never pass the
     code to `durmem` as an argument.

   **If you can only run one command at a time**, keep setup running in the background and answer
   it through a pipe, because setup reads each answer from its input:

   ```sh
   mkdir -p ~/durmem-setup && cd ~/durmem-setup && mkfifo in
   (sleep 1800 > in &)
   durmem setup --harness dot < in > setup.log 2>&1 &
   ```

   Read `~/durmem-setup/setup.log` between commands. When it ends with `Email address:`, send the
   address with `printf '%s\n' 'user@example.com' > ~/durmem-setup/in`. Answer the next prompts the
   same way: send `I agree` once the user has agreed to the Privacy Policy and Terms that the log
   shows, and send the emailed code when the log ends with `Verification code (hidden):`. If the log
   skips the consent prompt because the account has already agreed, send nothing for it; an extra line
   would be read as the code. Setup reads each answer as one line from the pipe, and the code you
   send never appears in the log. When the log reports the result, delete `~/durmem-setup`.

   For a private server, add `--base https://your-server.example`, using the user's server
   address. Existing credentials for that server can be reused by setup, which then asks for none
   of the above.
3. Setup installs the shared connector at `~/.loom/connectors/dot/bin/client.py` and the Durmem
   skills under `~/.loom/skills/`. It checks that the connector can list tools. Read the installed
   `loom-primitives` and `loom-coding` skills before using memory.
4. Verify the current chat identity and read the practice store `[demo]`. Save this as `seq.json`:

   ```json
   [
     {"tool": "whoami", "arguments": {"harness": "dot"}},
     {"tool": "loom_load_store", "arguments": {"name": "demo", "set_default": true}},
     {"tool": "loom_read_probe_bundle", "arguments": {"store": "demo", "query_text": "what is in this store"}}
   ]
   ```

   `durmem setup` downloads the search model once; if setup warned that it could not, the first
   search or save downloads it and can take about a minute. In the result, `current_facts` holds the
   facts that apply now. Facts that were retracted or replaced appear only under `stale_context`;
   they are not matches. Run the sequence with the actual ID of this Dot conversation:

   ```sh
   python3 ~/.loom/connectors/dot/bin/client.py call-sequence --file seq.json --thread-id '<current conversation id>'
   ```

   Memory tools work without `--thread-id`; `whoami` and Kanban worker steps need this chat's
   current conversation ID passed with that option. The validation found no verified way for Dot
   to retrieve the ID, so if it is not in Dot's available context, tell the user and skip Kanban
   worker steps. Do not guess or reuse another chat's ID.

## Use memory in each chat

Each connector invocation starts one `durmem mcp` process and closes it when the command finishes.
Use `call-sequence` to load a store and perform dependent calls together: every entry runs in that
same MCP session, where loaded-store state lives. Separate connector invocations do not share that state,
so load the store again in each new invocation before making calls that depend on it.
`call-sequence` stops at the first failed call, lists later calls as skipped, and exits 1; read
the error, fix the cause, and rerun the skipped calls (load the store again first, since each run
is a new session).

When provided, the connector sends `--thread-id` as request `_meta.threadId`.
`list-tools` shows the available tools and their argument schemas.

Dot has no Durmem lifecycle hooks, so the hook-based reminders in
[Give agents real-time reminders](../tutorials/give-agents-real-time-reminders.md) do not run
automatically for Dot. At the start of a chat and before relevant work, retrieve and read the saved
context yourself. Ask the user what project knowledge they want to save, then use the installed
skills to save it and read it back. This is command-based MCP access, not native plugin registration
or automatic context injection. To see how Durmem works for an agent without hooks, read
[Agents without hooks or a long-lived connection](connect-hermes.md#agents-without-hooks-or-a-long-lived-connection).

## Kanban work with Dot or Muse

Dot and Muse can work on an existing `[kanban]` board in an explicitly approved conversation.
Read the installed `loom-kanban` skill first and follow its enrollment and action rules. Keep the
coding store as the memory default and connect the board separately with `set_default=false`.

On each user-authorized turn or wake: heartbeat, read `kanban_my_actions`, handle queued actions
in rank order, then claim the highest-ranked task whose capability checks actually hold. Work
the run and submit its result when complete, or checkpoint progress before ending the turn.
Acknowledge directed messages in that turn. Use the current chat ID on every connector call;
Muse uses `harness="muse"` where Dot uses `harness="dot"`.

This integration does not schedule another wake or install a Fleet worker. When the conversation
is not running, it is not an unattended worker; return for another authorized turn to continue.

## Update the connection

Run `durmem update`, then `durmem setup --harness dot` again (with your private `--base` if needed).
Setup refreshes the client and skills. For connection problems, see
[Troubleshooting](../reference/troubleshooting.md).
