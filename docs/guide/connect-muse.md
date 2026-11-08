# Connect Meta's Muse to Durmem

<!-- loom-doc: slug=connect-muse; audience=both; section=guide -->
Meta's Muse is a chat assistant with its own Linux workspace. You talk to it in a chat window;
it runs commands itself, and you cannot run any. Durmem is set up the same way: you ask Muse to read this page, and Muse
installs and configures Durmem on its own. You only need to provide your email address, accept the
terms, and paste the sign-in code that Durmem emails you.

Durmem works with Muse's default network settings. Allowing direct network access in Muse's web
app under `Direct network protocols -> other TCP` is optional and can make the connection faster.

## Ask Muse to set it up

Paste this to Muse:

> Read https://durmem.ai/docs/connect-muse and set up Durmem for me.

Muse follows the steps below. You do not run any command. When Muse asks for the code from the email,
paste it into the chat: Muse cannot see your email, and codes that appear in command output are hidden from
it.

## Steps for Muse

1. Install the `durmem` command with the installer from the [Quickstart](quickstart.md#1-install-durmem):

   ```sh
   curl -fsSL https://durmem.ai/.well-known/cli/install.sh | sh
   ```

2. Run setup for Muse:

   ```sh
   durmem setup --harness muse
   ```

   Setup asks three things in turn. Ask the user in the chat, then type the answer at the prompt:

   - **Email address.** Ask the user for it.
   - **Consent.** Show the user the Privacy Policy and Terms links that setup prints. Type the
     agreement only after the user has agreed.
   - **Sign-in code.** Tell the user that a code was emailed to their address and ask them to paste it
     into the chat. Then type it at the prompt. Never read the user's mailbox, and never pass the code
     to `durmem` as an argument.

   **If you can only run one command at a time**, keep setup running in the background and answer
   it through a pipe, because setup reads each answer from its input:

   ```sh
   mkdir -p ~/durmem-setup && cd ~/durmem-setup && mkfifo in
   (sleep 1800 > in &)
   durmem setup --harness muse < in > setup.log 2>&1 &
   ```

   Read `~/durmem-setup/setup.log` between commands. When it ends with `Email address:`, send the
   address with `printf '%s\n' 'user@example.com' > ~/durmem-setup/in`. Answer the next prompts the
   same way: send `I agree` once the user has agreed to the Privacy Policy and Terms that the log
   shows, and send the emailed code when the log ends with `Verification code (hidden):`. If the log
   skips the consent prompt because the account has already agreed, send nothing for it; an extra line
   would be read as the code. Setup reads each answer as one line from the pipe, and the code you
   send never appears in the log. When the log reports the result, delete `~/durmem-setup`.

   Setup then writes the connector and skills described below and checks the connector.

   For a private Durmem server, run `durmem setup --harness muse --base https://your-server.example`
   with the server's address instead.

3. Check that the connection works. This lists the available tools:

   ```sh
   python3 ~/workspace/custom-connectors/custom.durmem/bin/client.py list-tools
   ```

   Then load the `demo` store and read from it in one session. Save the following as `seq.json`:

   ```json
   [
     {"tool": "loom_load_store", "arguments": {"name": "demo", "set_default": true}},
     {"tool": "loom_read_probe_bundle", "arguments": {"store": "demo", "query_text": "what is in this store"}}
   ]
   ```

   ```sh
   python3 ~/workspace/custom-connectors/custom.durmem/bin/client.py call-sequence --file seq.json --thread-id <this chat's id>
   ```

   If the output lists the demo store's facts, Durmem works. `list-tools` shows each tool's arguments.

## What setup puts in Muse's workspace

- `~/workspace/custom-connectors/custom.durmem/bin/client.py` is the connector client, and
  `CONNECTOR.md` beside it explains its commands. Each run starts Durmem, makes the calls you give it
  in one session, and prints JSON.
- `~/workspace/custom-skills/` receives the Durmem skills, unchanged, one folder each. They teach Muse
  how to save, search and organize memories.

## Using Durmem in each chat

Each connector invocation starts one `durmem mcp` process and closes it when the command finishes.
Use `call-sequence` to load a store and perform dependent calls together: every entry runs in that
same MCP session, where loaded-store state lives. Separate connector invocations do not share that state.
`call-sequence` stops at the first failed call, lists later calls as skipped, and exits 1; read
the error, fix the cause, and rerun the skipped calls (load the store again first, since each run
is a new session).

Pass the same `--thread-id`, this chat's id, on every call, so Durmem knows all the calls come from
one conversation.

## What Muse does not get

For approved board work, see the shared [Kanban instructions for Muse and Dot](connect-dot.md#kanban-work-with-dot-or-muse).

Muse has no lifecycle hooks, so the automatic reminders in the other harnesses do not happen: Durmem cannot
surface standing context before an action, guard risky commands, or prompt Muse to save what it learned.
Replace the first of these by hand: at the start of each chat, and again after loading a store, run
`loom_read_probe_bundle` through the connector and read what it returns. To see how Durmem works for
an agent without hooks, read
[Agents without hooks or a long-lived connection](connect-hermes.md#agents-without-hooks-or-a-long-lived-connection).

## If something goes wrong

- If setup says the sign-in code was not accepted, ask the user for a fresh code and run
  `durmem login` again.
- To update Durmem later, run `durmem update`, then `durmem setup --harness muse` again. Setup overwrites the
  connector files and adds the new skill files over the existing ones; it does not delete skill files that
  a newer version no longer ships, and it leaves everything else in the workspace alone.
- More fixes are in [Troubleshooting](../reference/troubleshooting.md).
