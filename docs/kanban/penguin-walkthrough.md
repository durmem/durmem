# Build a beak length report with a Kanban fleet

<!-- loom-doc: slug=penguin-walkthrough; audience=both; section=kanban -->

This tutorial shows how to ask a Kanban fleet to build and check a beak length report for the
`palmerpenguins` project. The report compares mean penguin beak length by species. The dataset
calls a bird's beak its **bill**, so its measurement column is `bill_length_mm`.

You will start the workflow with two prompts—one to create a Milestone and one to execute it.
The coordinator then drives the whole workflow: design, design review, implementation, independent code review,
unit tests and report generation.

Setting up a fleet takes some initial work: connecting computers, configuring authentication
and starting workers. That effort pays off because the same fleet can automate the development
process from end to end, and you can reuse it for later projects.

The same setup is even more powerful when your fleet spans harnesses, operating systems and
hardware. You can make cross-harness review and testing on several platforms part of the plan:
for example, Codex reviews Claude's implementation while workers on Linux, macOS and Windows
run the tests. The coordinator matches the work to available workers and carries those
requirements through the workflow.

## Before you start

This walkthrough builds on the workers you started in
[Manage Kanban fleet, §3: Start workers on palmerpenguins](connect-computers.md#3-start-workers-on-palmerpenguins).
The fleet needs at least two workers so the author and reviewer can be different agents. Those
workers can use different harnesses and run on the same computer or different computers.

The project plan lives in `[demo]`, while `[kanban]` coordinates the fleet. The coordinator and
workers need access to both stores. [Manage a project](../tutorials/manage-a-project.md) explains
Milestones and Roadmaps if those concepts are new to you.

Your coordinator conversation is where you will give the two prompts and receive progress
reports. Its harness needs to support scheduled wakes so the coordinator can check the work
every five minutes.

The coordinator needs the following repository and source revision when you ask it to create
the plan:

| Input | Value |
| --- | --- |
| Repository | `https://github.com/mcnakhaee/palmerpenguins.git` |
| Branch | `master` |
| Source commit | `24ab5d7ce1ed9afb54f7a304080da112f44542c8` |
| Dataset | `palmerpenguins/data/penguins.csv` |
| Measurement | `bill_length_mm`, in millimetres |

The report should show each species' mean beak length and how many valid and missing
measurements it has. The design will explain how missing measurements are handled, and the
tests will check that the implementation follows those rules.

## 1. Ask the coordinator to create the Milestone

A Milestone turns your report request into a plan the fleet can carry out. Its Roadmaps describe
the separate stages, and their dependencies show which results must be ready before the next
stage begins. Your first prompt asks the coordinator to create that plan:

**Tell your coding agent:**

> Create a Milestone in [demo] to build the Beak length report for palmerpenguins using the source
> above, with design, design review, implementation, implementation review, unit tests and report
> generation as separate Roadmaps, and show me the plan and dependencies.

The coordinator's reply should show the proposed plan and dependencies. For this report, the
workflow looks like this:

| Roadmap | Result | Depends on |
| --- | --- | --- |
| Design | Calculation rules, missing-data handling, report layout and test plan | — |
| Design review | Another worker checks the proposed approach before coding | Design |
| Implementation | Code and tests that produce the report from the CSV | Accepted design review |
| Implementation review | A worker other than the implementer checks the code and its tests | Implementation |
| Unit tests | Tests run on the requested operating systems and hardware, with results for each | Implementation |
| Report generation | The checked report, with source and verification details | Accepted implementation review and passing tests |

Code review and test execution can proceed in parallel once the implementation is ready.
Report generation waits for both. This is more useful than a flat checklist: the dependencies
tell the coordinator what it can start next and what is still blocked.

## 2. Ask the coordinator to execute the Milestone

Once you are happy with the plan, your second prompt delegates the whole Milestone. The
coordinator takes responsibility for moving it through the planned stages:

**Tell your coding agent:**

> Execute the Beak length report Milestone using the fleet on [kanban]. Have different workers
> review the design and code, preferably using another harness, and run the tests across the
> available operating systems and hardware. Set up a check every five minutes and keep driving
> the Milestone to completion, resolving blockers and review findings. Give me the final report
> and test results.

The coordinator checks the available workers, publishes KanbanTasks for the planned work and
arranges the handoffs. Workers fetch the source, produce the design and implementation, and
submit their results. You do not need to assign every stage or start each next step yourself.

For example, a Claude worker can implement the calculation and a Codex worker can review it.
The coordinator prefers a different harness when one is available. If all workers use the same
harness, a worker on another operating system or computer is preferred. The review identifies
the exact implementation commit hash, so its findings refer to the version delivered by the
implementation KanbanTask.

The coordinator also sets up the five-minute wake in its harness. Each wake is an opportunity
to check progress, handle questions and start newly unblocked work. You do not have to return
periodically to ask what is next.

## 3. Follow the work while the coordinator drives it

You can follow progress on the website or in your coordinator conversation. On your server's
Kanban page (`/kanban`), `[kanban]` shows the assignments and workers. The Milestones view for
`[demo]` shows the project plan and its progress. Your coordinator can explain that status in
ordinary language and tell you what is happening next.

For example, you can ask for an update at any time:

**Tell your coding agent:**

> How is the Beak length report Milestone going? Show me which Roadmaps are complete, what's
> running or blocked, what's next, and anything that needs a decision from me.

The coordinator should connect its summary to the plan: for example, the design and design
review are complete, implementation is running, and code review and unit tests are waiting
for that implementation. You can ask for this update without interrupting the scheduled checks.

Design review should settle the calculation rules before implementation begins. For example,
a missing beak measurement should be excluded from the mean rather than treated as zero.
The tests should cover ordinary measurements, missing values and a species with no valid
measurements. The implementation reviewer checks those choices independently, rather than
just accepting the author's claim that the tests pass.

When a reviewer finds a problem, the coordinator arranges a fix and a check of the revised
version. Problems that block the report are resolved before completion. Useful but nonurgent
improvements become follow-up Roadmaps in `[demo]`, with their importance recorded, so the
review contributes to the ongoing project plan.

The coordinator handles routine questions between workers. If a question needs your judgment,
it brings you the choice and explains its consequences. Otherwise, it continues through the
Milestone without requiring you to manage those exchanges.

## 4. Read the final result

At completion, the coordinator should give you links to the report and implementation, along
with the source commit, design and code reviews, unit-test results and any deferred Roadmaps.
The coordinator chooses the report's filename and location and tells you where to find it.
The link or path in its reply takes you to the report, which should contain:

- A mean beak length in millimetres for each species, with valid and missing measurement counts.
- The method used to handle missing measurements.
- A source revision and a reproducible way to generate the report.

The completion summary should identify a reviewer different from the implementer and show the
tests that passed on each operating system or hardware configuration, along with any requested
environment that could not be tested. The tests and report must refer to the final corrected
implementation.
The Milestone's Deliverable is the completion receipt linking this evidence to the plan.

For your own project, you can extend the same Milestone to release, deployment and monitoring,
including the approvals those stages require.

## What next

[Tour the Kanban page](kanban-board-tour.md) explains the views you can use to follow the work
visually. [Maintain and troubleshoot Kanban](maintain-workers.md) covers keeping the fleet
running and resolving problems.
