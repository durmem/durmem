# Maintain and troubleshoot Kanban

<!-- loom-doc: slug=maintain-workers; audience=both; section=kanban -->
A long-running project needs attention as priorities change, computers become unavailable and
workers encounter questions. Your coordinator keeps track of that work through the Kanban store,
so you can direct the project without supervising each worker.

This guide explains how to follow progress, adjust worker capacity, retire computers and recover
stalled work. It assumes you have connected a coordinator to `[kanban]` as described in
[Manage Kanban fleet](connect-computers.md). The quoted prompts below belong in that coordinator
conversation.

## Run a Kanban store well

Your coordinator needs to know what you want to achieve, what matters most and how you will
judge the result. It also needs clear approval boundaries—for example, whether it may add paid
workers or deploy a release. Within those boundaries, it can assign work, answer routine worker
questions and follow up with owners on your behalf.

Periodic checks help it keep the project moving while you are away. Your harness can schedule
these checks when you ask the coordinator to keep driving the work to completion. The coordinator
session and its scheduling service need to remain available for those checks to run.

You can return to the conversation whenever you want an update:

**Tell your coding agent:**

> How is our work on [kanban] progressing? What is finished, what is blocked, and which decisions
> do you need from me? Recommend what we should do next.

The useful answer connects activity to your goal. In the beak length report walkthrough, that
means explaining whether the design, implementation, independent reviews and tests are complete,
and where the report is available. For a release, it might mean that testing is complete and
deployment is waiting for your approval. Any question brought back to you should make clear
which decision is needed and why it matters.

## Change worker capacity

Another worker is useful when there is work ready to run in parallel. If implementation is
waiting for a design decision, adding workers will not resolve that delay. The coordinator can
look at the current assignments and recommend whether more capacity would help:

**Tell your coding agent:**

> Would another worker help with our current queue? If so, suggest where to add one and which
> harness and model to use.

Its recommendation should explain where the worker would help, which harness and model suit the
work, and any additional cost. When you already know the change you want, you can ask directly:

**Tell your coding agent:**

> Add one more Codex worker for palmerpenguins on the computer we just connected. Show me the
> proposed model and count first, and keep the other workers as they are.

After your approval, the coordinator updates the Fleet settings and confirms that the new worker
is ready. You can request a different model or fewer workers in the same conversation. A desired
total, such as “keep one worker on this computer,” makes the result clear.

In Durmem Kanban, each worker stays with one repository for its lifetime, reflecting how today's
coding harnesses run their sessions. To work in a different repository, the coordinator starts
a new worker there. These changes belong in the Kanban fleet settings managed by the coordinator,
rather than in individual workers' local files.

Fleet reports distinguish a computer that has checked in recently (**fresh**) from one that has
finished applying your settings (**converged**). A **degraded** computer has a problem completing
the change. Your coordinator should explain that problem and confirm which workers, models and
repositories are actually running.

## Stage Fleet runtime updates

A runtime hold lets the coordinator test a release on selected computers before the rest of
the fleet follows it. The residual still checks the release mirror, but refuses to install a
version newer than that computer's hold. It does not downgrade a computer or control an
operator's manual `durmem update`, plugin updates or server deployments.

**Tell your coding agent:**

> Stage the next Fleet runtime update on one canary computer per operating system. Hold the
> other computers at their current versions, confirm those holds took effect, and show me the
> canary results before lifting the rest.

The release that first adds hold support must reach every computer without holds. Its first
upgraded residual automatically installs Fleet protocol revision 7 on each board it reconciles;
this is not a later manual step. Older residuals can refuse that newer protocol until they
upgrade. The coordinator must confirm fresh reports showing every residual on a supporting
runtime and revision 7 installed in each board before publishing `[runtime_holds]` settings
for a later release. Holds cannot stage the release that first adds their support.

For each held computer, the coordinator waits for a fresh `fleet_host_status` report whose
`runtime_hold` matches the lowest applicable hold before releasing. Publication alone is not enough:
the effective hold appears in a heartbeat after the local file has been written, normally on
the next reconciliation cycle. A refused refresh logs `runtime_refresh_held` with the current,
published and held versions. After each canary reports the new runtime and completes a Kanban
turn, the coordinator removes the next group's entries and verifies their updates.

A computer connected to several boards follows the lowest hold. Each board retains its own
local hold file, so lifting one cannot override another. An unreachable board keeps its last
hold; a store-neutral reconciliation removes files for boards removed from the local registry.
A malformed or unreadable file freezes refresh at the current version and logs
`runtime_hold_unreadable`. Ask the coordinator to investigate that condition rather than
editing the files yourself. The coordinator uses compare-and-publish to avoid replacing
another operator's changes; see the [Fleet CLI reference](../reference/cli.md#fleet-config-publication).

## Retire a computer

Before a computer leaves the fleet, its unfinished work needs a new home. It may hold local
changes that have not been pushed or results that another worker needs to continue. Your
coordinator can arrange that handoff before removing its workers:

**Tell your coding agent:**

> We are retiring this computer from the fleet. Check for unfinished or unpushed work, arrange
> any handoff, and remove its workers once that work is safe.

Your request should name the computer. The coordinator then reports what happened to its work
and whether its workers have stopped. An offline computer may still need local attention when
it comes back online: a change in the Kanban store cannot stop an unreachable process.

Fleet keeps a retiring worker's repository clone and its Git metadata if any local branch tip is
not reachable from a verified current remote branch, or if the clone or a linked task worktree
has uncommitted files or a stash. It also keeps linked task worktrees outside Fleet's work
directory or ones it cannot inspect or remove safely. The coordinator reports retained work so
it can be inspected and handed off before the clone is removed. Fleet keeps the clone when it
cannot verify the remote, such as when the remote is unavailable or its local tracking
information is out of date. Restore access and refresh the clone before retrying.

Once the handoff and worker removal are complete, the person managing that computer can remove
the schedule for its Fleet residual, the background process that manages its workers. A lost or
compromised computer also requires an access review: its access must be revoked and affected 
credentials, including the
[shared Vault key](trust-and-vault.md#replace-the-shared-vault-key), replaced. The coordinator
can perform such tasks on your behalf.

## Ask the coordinator to investigate

When progress stops, you can describe the problem to your coordinator just as you would to a
teammate. It can investigate assignments, worker updates, unanswered questions and Fleet reports;
you do not need to diagnose the fault first. The assignment or computer name helps it find the
right work.

**Tell your coding agent:**

> Our beak length report on [kanban] seems stuck. Can you find out why and get it moving again?
> Let me know if you need a decision or something done on one of the computers.

With access to the affected computer, the coordinator can also inspect local errors. Its reply
should explain what caused the delay, what it repaired and what still needs your help.

If you lose the coordinator conversation, a fresh harness session connected to the same Kanban
store can take over when you ask it to act as coordinator. That session can use a different
harness or computer. The saved assignments, progress and results give it the information to
continue.

## Understand what is waiting

A quiet fleet is not always a stalled fleet. The coordinator can distinguish work waiting on a
prerequisite from a worker that needs attention. These are common situations you may see:

| What you see | What it may mean | What you may need to do |
| --- | --- | --- |
| An assignment has no worker | It is waiting for an earlier result or a worker with the right access or capabilities. | Decide whether to add capacity or change the requested work. |
| A worker is waiting for an answer | It needs a decision before it can continue. | Answer the question in your coordinator conversation. |
| A worker is idle | It may have no suitable work, or its harness may be dormant between jobs. | Usually nothing; ask the coordinator if you expected it to be working. |
| A computer has not applied a Fleet change | Its background process may be offline or unable to complete the change. | Help with local access or sign-in if the coordinator asks. |
| A worker cannot use a credential | Its sign-in, Vault key or selected profile may need attention. | Complete any private authentication or key-setup step yourself. |

Between assignments, a healthy worker may unload its harness and resume it when new work
arrives. On Windows, scheduled workers require the operating-system user to be signed in.

## Recover a stuck run

Sometimes a worker disappears while it holds an assignment. Kanban reserves the assignment for
that worker's run for a limited time, called a **lease**, so another worker does not duplicate
the work. Progress updates renew the lease. A run waiting for its owner's answer has a 12-hour
lease and can resume when the question is answered. Once a lease expires, another worker can
claim the assignment if its run limits allow.

Before arranging a replacement, the coordinator checks the worker's last progress report,
questions and heartbeat. An unanswered question may be the only obstacle. A worker that is still
available may instead need help with its harness or account usage limit; ending its reservation
would not solve that problem.

When the worker really is gone, you can ask the coordinator to release its assignment early.
This is possible for a run that is working or waiting for its owner when the worker has been
retired or has not checked in for at least an hour. The coordinator verifies those conditions
before expiring the run. An unknown worker status or missing heartbeat history is not enough.

The coordinator then confirms that another suitable worker can take over with the saved progress
and artifacts. Those records matter because the replacement has its own conversation, not the
previous worker's context.

Expiry lets unfinished work continue; cancellation tells the fleet that you no longer want the
assignment completed. Expiring a run does not change a finished result.

## When the coordinator needs your help

Your coordinator can handle routine repairs, but some problems need access or a decision only
you can provide. Its request should identify the affected computer or assignment and explain
what you need to do.

Typical requests include:

- Sign in again to a harness account, or bring an offline computer back online.
- Give it access to a computer it cannot inspect remotely.
- Choose how to handle unfinished work that prevents a worker checkout from being changed.
- Approve a change outside the current authorization, such as paid work or deployment.
- Install a Vault key through the private setup process in [the Vault guide](trust-and-vault.md#1-install-the-shared-vault-key).

Sign-in and key entry happen through the appropriate local sign-in or hidden-input flow, rather
than in the coordinator conversation or shared Kanban messages. Once that private step is
complete, a reply to your coordinator lets it continue.

## Confirm the work is moving again

Recovery is complete when the affected work resumes, not just when a process restarts. You can
ask your coordinator to check the result:

**Tell your coding agent:**

> Check that the work is moving and the fleet matches my request. What changed, and is anything
> still waiting for me?

For the beak length report, that means a worker has resumed its assignment or submitted a result.
For a Fleet change, it means the requested workers are available with the intended settings.

If the problem remains, the coordinator can prepare a summary for your server administrator or
support, covering the symptom, attempted repairs and remaining blocker. Any diagnostic excerpts
shared with that summary should have credentials and private information removed.

## What next

[The multi-agent walkthrough](penguin-walkthrough.md) shows the fleet carrying a project through
to completion. [Tour the Kanban page](kanban-board-tour.md) explains how to follow that work
in the browser.
