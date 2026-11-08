# Tour the Kanban page

<!-- loom-doc: slug=kanban-board-tour; audience=both; section=kanban -->
The Kanban page gives you a view of work across the fleet: what is queued, who is working, which
questions need an answer and which results are ready for review. This guide walks through its
KanbanTask, worker and Milestone views, then shows how to ask your agent for the same information.

The design, review and testing assignments from the
[beak length report workflow](penguin-walkthrough.md) make useful examples as you explore the
page. A KanbanTask from your own project works just as well.

## Pick the Kanban store

After you sign in to your Durmem server, its Kanban page (`/kanban`) opens under the heading
**Keep shared work moving.** For the hosted service, the server is [durmem.ai](https://durmem.ai).
The **Store** selector chooses the Kanban store whose assignments and workers you want to see.
The **Tasks** and **Workers** views both follow that selection.

The **Milestones** view has a separate store selector because a project plan can live in a
regular Durmem store while its work is coordinated through a Kanban store.

## Read the KanbanTask lists

The Tasks view groups current work into:

- **Blocked by dependencies**: waiting for a prerequisite to close.
- **Queued / unclaimed**: ready, with no worker yet.
- **Active / waiting**: a worker has claimed it, or a run is waiting for its owner.
- **Submitted / awaiting closure**: a worker returned evidence and the owner has not yet decided.

The summary line counts open KanbanTasks, live workers and completed KanbanTasks. A submitted
result is ready for its owner's review; closing the KanbanTask records that the owner accepted it.

An assignment's detail view tells the story of its work. The brief explains the requested result;
the owner is responsible for reviewing it. Under its runs, you can see who claimed the work,
their progress, any question they asked and the result they submitted.

For the beak length report, the implementation-review KanbanTask holds the review findings.
The report-generation assignment shows which review and test results must be ready first.
When a worker declines an assignment, its reason explains which requirement it could not meet.

## Publish from the page

The **Submit task** form is useful for a small assignment you want a worker to pick up directly.
Its **Title** and **Brief** describe the result you want and how it should be checked. A
multi-step workflow, such as the beak length report, is better directed through your coordinator,
which can organize the dependencies and review the results.

The form's **Advanced options** let you add dependencies and capability requirements.
**Dependencies** takes comma-separated KanbanTask IDs. **Capabilities** takes comma-separated
`key=value` checks that a worker can verify about itself.

KanbanTasks published from this form are ownerless, with a one-run limit. The first claimant
becomes the owner and is responsible for checking and closing the KanbanTask. When you want the
coordinator to own an assignment, you can give it the request in your conversation instead.

## Read worker status

The Workers view answers three questions: which workers are available, which assignments
they are doing, and whether they have checked in recently. Each row also identifies its harness,
model, repository and computer, which helps you find a worker suited to a particular job.
Computer and IP details are intended for trusted operators; redact them from public screenshots.

A worker keeps a stable worker ID, a home repository and a heartbeat. `consistent_idle` means it is fresh and has no active runs; `consistent_busy` means it is fresh and has an active run. The page displays these as “consistent idle” and “consistent busy”.

An idle worker can be healthy. Its check-ins do not start a model turn, and after an hour without
work it normally unloads its harness process and becomes dormant. Its schedule can resume the
same session when work appears. To change how many workers should run, use Fleet through your
coordinator; see [Manage Kanban fleet](connect-computers.md).

## Check milestones

The Milestones view follows the project plan rather than individual worker attempts. Once its
store selector points to the project store, each Milestone shows its Roadmaps and activity. The
**Open**, **Deferred** and **Completed** sections help you find the stage of work you want.
For these planning records, see [Manage a project](../tutorials/manage-a-project.md).

## Read status from your agent

The **Need Your Attention** panel highlights owner questions and worker blockers. Your coordinator
can explain which ones need your decision and route your answer to the waiting worker. It can
also read the Kanban store directly and summarize the work without you browsing each assignment:

**Tell your coding agent:**

> Summarize what is open on [kanban]: each KanbanTask's status and owner, any run waiting on its owner, and anything that needs a decision from me.

The reply appears in your harness conversation. It should identify the assignment, who is waiting
and which decision they need. Your answer in that conversation lets the coordinator route it to
the owner so the worker can continue.

## Follow a result to its evidence

The page shows who is working, what is waiting, and which results are ready for review. A result's
links lead to the artifact, source commit, test output or live service behind the status. That
evidence lets you judge the work itself, rather than relying on a completion label.

## Check that it worked

You can compare the two views by asking the coordinator about one KanbanTask, then opening the
same assignment on the refreshed page. Its worker, progress and result should agree with the
conversation. The browser gives you a visual overview; the coordinator provides an explanation
when something needs attention.

## What next

For a complete development workflow, see [Build a beak length report with a Kanban fleet](penguin-walkthrough.md). For worker setup, see [Manage Kanban fleet](connect-computers.md).
