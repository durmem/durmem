# Manage Kanban fleet

<!-- loom-doc: slug=connect-computers; audience=both; section=kanban -->
Your Kanban fleet can bring together agents on your laptop, a development server or other
computers. Once a computer joins the fleet, you can ask the coordinator to start workers there,
give them a Git repository to work in, and change their number as your project needs change.

In this guide, you will connect a computer to `[kanban]`, start a worker on the `palmerpenguins`
repository, and ask it to return a result. This gives you a working fleet for the larger workflow
in the next guide.

Fleet manages each computer through a small background program called the **residual**. It
receives the coordinator's worker settings, prepares the repository and starts the harness
sessions. You set up the computer once; after that, the coordinator manages its workers through
the shared Kanban store.

## 1. Connect a trusted computer

As the operator, you direct the fleet by talking to its coordinator in your main harness
session. The [Kanban introduction](what-is-kanban.md) explains how that coordinator works with
owners and workers. The setup below happens on the computer you want to add to the fleet; later, you will
return to your coordinator conversation to start workers on it.

That computer needs Durmem, Git and the harnesses you want its workers to use. The
[Quickstart](../guide/quickstart.md) covers installing Durmem and connecting your account.
That computer needs HTTPS for sign-in and a connection to the store gateway: directly to its
data port (`7443` for durmem.ai), or through a configured HTTPS proxy. Durmem tries HTTP CONNECT
first, then a secure WebSocket connection to the server's saved HTTPS origin (usually port
`443`) when the server supports that fallback. See
[proxy-only networks](../reference/troubleshooting.md#sign-in-works-but-durmem-cannot-reach-your-stores-sandboxed-or-proxy-only-networks)
for proxy settings and errors.

Fleet currently runs Claude Code (`claude`), Codex (`codex`) and OpenCode (`opencode`) workers.
Hermes can use Durmem's Kanban tools during a session, but it cannot run as a Fleet-managed
worker. Hermes identity belongs to one session and goes stale when that session ends. See
[Connect Hermes](../guide/connect-hermes.md) for its session and hook behavior.

If Durmem is already installed on this computer, you can connect the account and list its stores:

**Run in your terminal:**

```sh
durmem login
durmem list_stores
```

The list should include `[kanban]`, the shared store this computer will join in this guide.
You can use another name: any Durmem store can be initialized as a Kanban store. The
[initialization instructions](../guide/manage-stores.md#turn-a-store-into-a-kanban-store) explain
how to prepare an existing or newly created store. If you choose another store, its name replaces
`kanban` in the commands and `[kanban]` in the prompts below.

Workers need access both to Durmem and to the model provider behind their harness. Unlike your
interactive coordinator, they run unattended, so they reuse saved credentials rather than asking
you to sign in for each session. Those credentials may be a long-lived token, an API key or a
saved account sign-in, depending on the harness. The choice also determines billing: model work
authenticated with an API key can be billed per request.

Fleet uses a shared Vault key to exchange encrypted worker credentials. The
[Vault setup](trust-and-vault.md#1-install-the-shared-vault-key) explains how to install that key
privately on this computer. Residual preflight requires it even if your planned work needs no
application secrets. The key stays on the participating computers, not in a Durmem store.

A **Vault profile** is a named set of credentials you choose to supply to selected workers.
For example, a profile named `test-secret` could hold an API key for a test service used by both
Codex and Claude workers. You choose which workers receive each profile, so different roles can
use different credentials. The [Vault guide](trust-and-vault.md) covers saving application
secrets, assigning profiles and who can decrypt them.

### Set up worker authentication

The following sections cover the authentication choices for each harness. Only the harnesses
you intend to run need this setup. Their credentials must be available to the operating-system
user running the worker harness, so its workers can continue across sessions and restarts. Tokens and keys
may need renewal or rotation later.

#### Codex: sign in with ChatGPT

ChatGPT-backed Codex workers reuse a local Codex sign-in. Each worker computer needs its own
sign-in under the user running the workers; your coordinator's sign-in on another computer does not
carry over. The usual browser-based flow starts with:

**Run in your terminal on the computer being connected:**

```sh
codex login
```

The command opens a browser for ChatGPT sign-in. A remote or headless computer can instead use
device-code login, which lets you complete that sign-in in a browser on another computer:

**Run in that computer's terminal:**

```sh
codex login --device-auth
```

The command displays a link and a one-time code. You open that link in your own browser, sign in
and enter the code. This method requires device-code login to be enabled in your ChatGPT account
or workspace. Either way, the following command confirms whether this computer is signed in:

**Run in the worker computer's terminal:**

```sh
codex login status
```

Codex saves authentication locally and refreshes its tokens. Workers running as that same
user reuse it; you do not sign into each worker session. Fleet checks this
local authentication rather than distributing a Codex login through the Vault.
For details, see [OpenAI's authentication guide](https://learn.chatgpt.com/docs/auth).

If you use an OpenAI API key instead, run `codex login --with-api-key`; it reads the key from
standard input. API usage is billed separately from your ChatGPT subscription.

#### OpenCode: authenticate the provider

OpenCode workers use the provider credentials saved for their operating-system user. Its login
command guides you through the selected provider's authentication flow; the second command lists
the saved providers so you can confirm the connection.

**Run in the worker computer's terminal:**

```sh
opencode auth login
opencode auth list
```

#### Claude Code: supply a token or API key

Claude Code workers can receive a subscription setup token or an Anthropic API key through a
Vault profile. After the shared Vault key is installed, you can save either credential and tell
the coordinator which workers should receive it. The examples below use `test-secret` as the
profile name; an existing suitable profile works too.

**With a Claude subscription**, a long-lived setup token lets workers use the subscription
without an interactive sign-in for each session:

**Run in your terminal:**

```sh
claude setup-token
```

After you complete the sign-in flow, Claude provides the token. This command saves it in the
Vault through a hidden prompt:

**Run in a terminal on a computer with the shared Vault key:**

```sh
durmem fleet --store kanban profile-put-claude --profile-id test-secret
```

**With an Anthropic API key**, the corresponding command accepts the key through a hidden prompt:

**Run in a terminal on a computer with the shared Vault key:**

```sh
durmem fleet --store kanban profile-put-claude --profile-id test-secret --kind api-key
```

The profile uses one of these two methods. API-key workloads use Anthropic's API billing, which is separate from the Anthropic subscription.

When you ask the coordinator to start Claude workers in step 3, you can name `test-secret` as
their profile. Fleet supplies its credential when those workers start. Each computer running
them needs the shared Vault key to decrypt it. Their first check-in will let the coordinator
confirm that authentication is working.

To rotate a credential, rerun the matching profile command and enter the new token or API key when prompted. Then ask the coordinator to update the workers' desired configuration to the new profile revision and republish it; Fleet supplies the new credential to those workers when they next start.

### Run preflight and install the residual

Once its store connection is ready, this computer can run the residual. Preflight
checks its prerequisites, installation starts the background program, and status shows the
local result. An interactive terminal lets you answer any remaining authentication prompts:

If Fleet state already exists on this computer, installation starts the residual immediately
with the selected store's current desired configuration. The residual can update, start or stop
existing workers during its first reconciliation.

**Run in your terminal:**

```sh
durmem residual preflight
durmem residual --store kanban install
durmem residual status
```

Here, `--store kanban` names the `[kanban]` store for the installation command.

Preflight checks the local connection registry, Vault key and dependencies across configured
stores and, on Linux, that cron is available. On success it prints `Fleet residual preflight: OK`; when a
check fails it prints a one-line reason and exits with status 1. Installation also checks authentication
for the harnesses configured on this computer.
If the selected store has no published Fleet configuration, there are no configured harnesses
to authenticate, so installation can proceed without a harness sign-in. Workers you configure
later still need the relevant sign-in above. If credentials are missing for configured harnesses,
the interactive installer offers the relevant sign-in or credential setup and checks again before
installing. Its output identifies anything still missing; the harness sections above explain how
to provide those credentials.

Once those checks pass, installation creates the operating-system schedule and starts one
residual daemon for this computer. Cloud computers and containers follow the same steps; they
need a supported native harness, persistent state, authentication, and an operating-system scheduler
so workers can continue running unattended.

The output of `durmem residual status` should report a `host_id`,
`process_model` of `resident_daemon`, `schedule_installed: true`, a live `pid`, and
`vault_key_installed: true`. Together, these show that the local daemon is running and has its
Vault key; the coordinator will check its connection to the fleet next. On Windows,
the scheduled workers require the operating-system user to be signed in.

## 2. Ask the coordinator to check the computer

The local setup is complete. In your coordinator conversation, you can now ask whether the
computer has joined the fleet. It appears before any workers are started, so this first check
confirms that the residual is connected and ready to receive settings.

**Tell your coding agent:**

> Show me the computers and workers connected to [kanban]. Has the computer I just added checked
> in, and is anything preventing it from starting workers?

The new computer should appear with a recent residual report. It will have no workers until you
assign them in the next step. The coordinator can show computer IDs, configuration revisions and
errors when you need to investigate a connection.

## 3. Start workers on palmerpenguins

The coordinator can now start workers on the connected computer. It needs to know the repository,
branch, harness, model and worker count. We will start with one worker on `palmerpenguins`; you
can use your own repository in the same way. A private repository also needs Git access from each
worker computer. Use these example settings when you ask the coordinator to start a worker on [kanban]:

| Setting | Practice value |
| --- | --- |
| Repository URL | `https://github.com/mcnakhaee/palmerpenguins.git` |
| Repository name | `palmerpenguins` |
| Branch | `master` |
| Worker count | One on one computer |

**Tell your coding agent:**

> Add one palmerpenguins worker using the repository and branch above on the computer I just connected. Show me which harness and model
> it will use before applying the change. Plan to add a new worker on the new computer and keep my other workers as they are.

Once the worker starts, your coordinator should show its harness, model and the worker count.

After you approve the change, the coordinator publishes the Fleet settings. The computer's
residual receives the repository URL, branch and worker count, creates managed clones, and starts
the harness sessions in them. You do not need to clone the repository for each worker yourself;
the residual does that automatically.
A later KanbanTask can specify the exact source revision needed for its assignment.

## 4. Check the workers and change their number

Starting a process is only part of the setup: the worker also needs to connect to `[kanban]` and
be ready for assignments. Your coordinator can show whether the computer has applied the latest
settings and whether its workers are checking in:

**Tell your coding agent:**

> Check that each palmerpenguins computer has applied the latest Fleet revision and that the worker is checking in with the requested model and repository. Tell me which are idle or busy and whether any computer is degraded.

The report appears in your coordinator conversation. It should show the requested model and
repository for each worker, whether it is idle or busy, and any computer that needs attention.

You can change capacity through the same conversation—for example, “Add a second palmerpenguins
worker on that computer,” or “Reduce it to one worker again.” The coordinator updates the
existing Fleet settings and checks that the computer has applied them. A count of zero retires
those Fleet-managed workers. Changes go through Fleet so its saved settings and the running
workers stay in agreement. The [maintenance guide](maintain-workers.md#change-worker-capacity)
covers model and repository changes too.

You can also choose a different LLM model for a worker—for example, ask the coordinator to
switch a Codex worker from Sol to Luna. The coordinator confirms the exact model supported by
that harness before applying the change. Each worker's current model appears in the status
report, so you can see whether it is running with the model you requested.

## 5. Run your first read-only KanbanTask

Your worker is connected; now a small assignment will confirm that it can read the repository
and return a useful result. One worker is enough for this check. The following details identify
the exact dataset and keep the exercise read-only:

| Input | Value |
| --- | --- |
| Repository | `https://github.com/mcnakhaee/palmerpenguins.git` |
| Remote and branch | `origin`, `master` |
| Full commit | `24ab5d7ce1ed9afb54f7a304080da112f44542c8` |
| CSV path inside the repository | `palmerpenguins/data/penguins.csv` |
| Write boundary | Read-only counting; no pushed changes |

**Tell your coding agent:**

> Ask one worker on [kanban] to count the Adelie penguins in the dataset above. Have it report
> the source revision, how it counted and the total number of data rows too.

The coordinator posts a KanbanTask to `[kanban]`, where a suitable worker can claim it. The
worker reads the dataset and submits its count with the source revision and method. You can
follow its progress in the coordinator conversation or ask your harness to check periodically
using its scheduling feature.

## Check that it worked

The submitted result gives the coordinator something to compare with the original data. You
can ask for that final check in the same conversation:

**Tell your coding agent:**

> Compare the worker's submission with the CSV in the repo and check that the result is correct.

## What next

Your fleet can now receive work, run it in the repository and return a checked result. In
[Build a beak length report with a Kanban fleet](penguin-walkthrough.md), you will use the same
setup for a complete design, review, implementation and testing workflow.
