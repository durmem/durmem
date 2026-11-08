# Keep Kanban work safe with the Vault

<!-- loom-doc: slug=trust-and-vault; audience=both; section=kanban -->
When workers on several computers need an API key, you need a way to give it to them without
putting it in their shared assignments or conversations. The Vault stores an encrypted copy and
lets Fleet deliver it to the workers you configure.

This guide explains how that delivery works, then walks through it with a fake API key. You will
install the shared Vault key, save a credential profile and choose which workers receive it.
Finally, several workers will hash the fake value so you can check that they received the same
thing without printing it. The [Kanban overview](what-is-kanban.md) introduces the roles used here.

## Who can see what

Any worker connected to a Kanban store can read its KanbanTasks and messages, making those
records unsuitable for credentials. The Vault provides an encrypted channel for sharing secrets such as API
keys across the fleet. Computers need the shared Vault key to decrypt the saved credentials;
connecting to the Kanban store alone does not give them that key.

## What the Vault does

There are three parts to delivering a credential.

First, you create the **Vault key** once and install the same key privately on each trusted
computer. This is the initial setup that lets those computers encrypt and decrypt Vault content.

Next, you save the credentials in a named **profile**. An application secret profile holds one
or more `NAME=value` pairs, such as an API key under the name a program expects. You choose its
profile ID when saving it; `test-service` might hold the credentials for a test service.

Finally, you tell Fleet which workers should use that profile. This selection is called a
**profile assignment**. Saving `test-service` does not give it to every worker automatically:
you might assign it to test workers while giving release workers a different profile. The
coordinator records those choices in the Fleet settings.

When a worker starts its harness, its daemon decrypts the selected application profile in memory
and supplies the values as environment variables. The program can then use the API key without
the agent having to copy it from a conversation. A changed assignment takes effect when the
worker restarts.

The assignment controls what Fleet supplies by default, not what other key holders can decrypt.
Every computer with the shared key can decrypt the profiles it can retrieve. Use this mechanism
among trusted computers; it is not a way to isolate secrets from an untrusted member of the fleet.

## Keep the Vault key safe

The Fleet Vault key is **push-only**: an existing holder deliberately gives it to another trusted
computer through a separate private channel. A request posted to Kanban is not a reason to send
the key. This prevents access to the Kanban store from becoming a way to obtain Vault credentials.

If a key-holding computer is lost or compromised, stop using it and rotate the affected provider
credentials and shared key. Removing its Fleet assignment alone cannot revoke a key it already has.

The computers receiving credentials must be trusted. Fleet workers run unattended with
approval prompts disabled and can run commands as their operating-system user. Only connect
computers and repositories you trust with that access. The Vault protects credential delivery;
it does not restrict what a receiving worker can do. Output scrubbing reduces accidental leaks,
but a worker that can run code can still transform or disclose a secret. Workers sharing an
operating-system user share its Vault key file too.

## Replace the shared Vault key

When a key-holding computer is lost, compromised or no longer trusted, the remaining fleet needs
a new shared key and new provider credentials. Both changes matter: an old key holder may have
retained encrypted profiles and can still decrypt them with its old key.

The replacement involves the computers you are keeping:

1. The coordinator first stops the affected workers and lists their credential profiles. You
   need a way to supply those credentials again through their private setup flows: replacing
   the key does not re-encrypt existing profiles, and the new key cannot decrypt old ones.
2. The replacement starts on a trusted operator computer. **Run in your terminal:**

   ```sh
   durmem fleet --store kanban key-create --replace
   ```

   This replaces that computer's local Vault key and reports the file path. It needs an
   interactive terminal and asks you to type `replace`; a script or an agent's shell is refused
   and nothing changes. The old key stays in the same folder as `vault-key.replaced-<UTC time>`,
   so a mistaken replacement can be undone. Delete that file once the whole fleet has the new key,
   because it still decrypts the old profiles.
3. Each retained computer needs the same new key, transferred through a separate private
   operator channel. On each receiving computer, **run in your terminal:**

   ```sh
   durmem fleet --store kanban key-install --replace
   ```

   The same confirmation applies here, and the old key is kept the same way. The hidden prompt
   accepts the new key without putting it in command arguments. The key must
   stay out of chats and must not be sent to a removed computer or in response to a Kanban request.
4. The affected credentials also need rotation with their providers. Saving the replacements
   through the private profile setup commands creates new profile revisions encrypted with the
   new key. Your coordinator can then update the Fleet settings to use those revisions.
5. Once the retained computers have the new key and settings, the coordinator can restart the
   workers and confirm that their assigned profiles work.

A former key holder can still decrypt old profiles it retained. Replacing the shared key protects
newly saved profiles; rotating the provider credentials is what makes the old credentials unusable.

## Try it with a fake key

We will give the fake value `not-a-real-key-1234` to your `palmerpenguins` workers as the
environment variable `DEMO_KEY`. Each worker will report its SHA-256 hash—a fixed-length digest
you can compare with your own calculation. Use only the fake value in this exercise.

If you completed [Manage Kanban fleet](connect-computers.md), the shared key is already installed;
continue at step 2. If you came here to set up the key while connecting a computer, complete
step 1 first.

### 1. Install the shared Vault key

The fleet needs one shared key, created on a trusted computer. An existing fleet uses its
current key; a new fleet starts with this command:

**Run in your terminal:**

```sh
durmem fleet --store kanban key-create
```

The command creates a local key file and reports its path. The key stays on that computer,
and its value is transferred through a separate private operator channel to each additional
trusted computer that will run Fleet workers. It must never go into a KanbanTask, message, chat
transcript or command argument.

**Run in your terminal on each receiving worker computer:**

```sh
durmem fleet --store kanban key-install
```

The command accepts the shared key at a hidden prompt. One installation for the operating-system
user running Fleet serves all its workers on that computer.

Each command confirms installation in that computer's terminal; no workers need to be running
yet. If you came from [Manage Kanban fleet](connect-computers.md#1-connect-a-trusted-computer),
the computer is now ready for the remaining connection and worker setup there. The exercise
below begins once those workers are running.

If a Vault key already exists, either command leaves it unchanged, prints a one-line message
to pass `--replace`, and exits with status 2. Use `--replace` only when deliberately replacing
the shared key as part of a coordinated rotation; every trusted computer must then receive the
new key.

The current runtime requires this key during residual preflight and installation even if you
have no credential profile to deliver. That is a current Fleet bootstrap restriction, not a need
to exchange an application secret for every job.

### 2. Store the fake key

This exercise needs at least two `palmerpenguins` workers ready on `[kanban]`; your coordinator
can confirm who is available. They may be on the same computer or different computers, as in
[Manage Kanban fleet](connect-computers.md).

The fake key will live in a profile named `demo-secrets`. Its save command runs on a trusted
computer with the shared Vault key. The CLI accepts `NAME=value` lines encoded as base64, so
the first step prepares that input. Base64 is not encryption; the save command encrypts the profile.

**Run in your terminal:**

```sh
printf 'DEMO_KEY=not-a-real-key-1234\n' | base64
```

On Windows, encode the same line in PowerShell instead:

**Run in your terminal:**

```powershell
[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("DEMO_KEY=not-a-real-key-1234`n"))
```

The same save command works on either operating system. Its hidden prompt accepts the encoded
value from the previous command:

**Run in your terminal:**

```sh
durmem fleet --store kanban profile-put-app-secrets --profile-id demo-secrets
```

The command should confirm that `demo-secrets` was stored. You can now refer to this profile by
name when asking the coordinator to give it to workers.

### 3. Assign the Vault profile to the workers

Your coordinator can now assign the saved profile to the `palmerpenguins` workers:

**Tell your coding agent:**

> Give my palmerpenguins workers the demo-secrets profile I just saved. Show me which workers
> will receive it, then apply it and check that they are ready to use it.

The coordinator finds the saved profile and handles the version and Fleet settings. You only
need its name and the workers you want to receive it. Once the coordinator confirms they are
ready, use the next steps to check that those workers received `DEMO_KEY`.

### 4. Work out the expected hash

A local hash gives you the expected result to compare with the workers' replies. The input is
the fake value `not-a-real-key-1234`, without a line ending:

**Run in your terminal:**

```sh
printf %s 'not-a-real-key-1234' | shasum -a 256
```

On Linux, `sha256sum` replaces `shasum -a 256` in that command.

On Windows, compute the same hash in PowerShell:

**Run in your terminal:**

```powershell
$demoBytes = [Text.Encoding]::UTF8.GetBytes('not-a-real-key-1234')
$demoHasher = [Security.Cryptography.SHA256]::Create()
[BitConverter]::ToString($demoHasher.ComputeHash($demoBytes)).Replace('-', '').ToLowerInvariant()
$demoHasher.Dispose()
```

The resulting 64-character digest is the value you will compare with the workers' reports.

### 5. Send one KanbanTask to every worker

The fleet can demonstrate delivery by having each worker calculate the same hash. A
[standing KanbanTask](what-is-kanban.md#run-limit) lets each suitable worker run the same
assignment once, including workers that join later. The coordinator owns the survey and ends
it when all the intended workers have replied.

**Tell your coding agent:**

> Ask every worker on [kanban] to hash the value of DEMO_KEY with SHA-256 and report its worker
> name and hash, or "missing" if it has no value. Use a standing KanbanTask and own the survey.
> Keep the value itself out of the reports.

The coordinator should show the published survey in your conversation. It names DEMO_KEY,
requests hashes rather than values, and allows one reply from each worker. A worker without the
profile reports "missing", making gaps in delivery visible too.

## Check that it worked

Once workers have submitted their results, the coordinator can collect them into one comparison:

**Tell your coding agent:**

> Collect the DEMO_KEY survey results. Which workers match this expected hash, and is anyone
> missing or different?

The request needs the expected hash you calculated in step 4.

The result table appears in your coordinator conversation, with a worker name and digest in each
reply. Every intended worker should match your calculation from step 4. A missing or different
result gives the coordinator a specific delivery problem to investigate.

Once the check is complete, the coordinator can end the survey and remove the fake profile
from workers that no longer need it.

## What next

[Maintain and troubleshoot Kanban](maintain-workers.md) covers adjusting the fleet and working
with the coordinator to resolve delivery or worker problems.
