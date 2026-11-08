# Manage a project

<!-- loom-doc: slug=manage-a-project; audience=both; section=tutorials -->
This tutorial shows how to turn a project goal into a plan your agent can carry out. You will group
Roadmaps into a Milestone, set their dependencies, ask the agent to do the work, and review the
results. The example uses `palmerpenguins`; the same planning steps work with your own project.

We will use the following types introduced in
[Durmem data types for coding agents](data-types-for-coding-agents.md).

A **Goal** states the outcome. A **Roadmap** is a piece of planned work toward it. A **Milestone**
collects related Roadmaps or other Milestones into a stage of the plan; dependencies let an agent
work through them in the required order.

## Before you start

Finish the [Quickstart](../guide/quickstart.md) and open the palmerpenguins project in your harness.
Continue with the `[demo]` store as the session default.

## 1. Save the goal, decision and work items

An agent needs both the outcome you want and the decisions it should respect while getting
there. Here, the outcome is a species-by-island chart, and the decision is to keep the dataset
loader's defaults. Saving these alongside the planned work lets a later session pick up the plan
without asking you to explain it again.

**Tell your coding agent:**

> I want a species-by-island penguin-count chart for our report. Keep the loader's defaults.
> Remember that goal and decision, and plan the work: calculate the counts, review the chart
> against the data, test its labels and totals, then deploy it to the team workspace.

The agent should show a Goal, the loader Decision and four Roadmap items. Read the plan and check
that it captures what you asked for. Keep the Roadmap names for the later steps.

## 2. Check that a conflicting plan stops

Ask for a plan that would cross the saved boundary. The agent should raise the conflict before it
creates or changes a plan.

**Tell your coding agent:**

> I’m considering changing the loader’s defaults. Would that conflict with the choice I made?

The agent should bring back the saved loader Decision and explain the conflict. You can then
decide whether to keep or revise the earlier choice.

## 3. Link work to milestones

A Milestone groups related work into a result you can ask the agent to deliver. Dependencies
describe which results must come first: review and testing need the chart, and deployment needs
both checks to pass. Review and testing can proceed independently once calculation is complete.

**Tell your coding agent:**

> Group this work into a Milestone called “Produce the Palmer Penguins island-count chart”.
> Review and testing need the calculated chart; deployment needs both to pass. Show me the plan
> and those dependencies.

The plan should show all four Roadmaps under the Milestone, with calculation first, review and
testing next, and deployment last. Priority says what matters most; dependencies say what must
finish before another item can begin.

## 4. Execute a Milestone and report the results

You can now ask the agent to carry out the Milestone rather than directing every step yourself.
It follows the dependencies, checks the work and reports the results.

**Tell your coding agent:**

> Carry out the Milestone “Produce the Palmer Penguins island-count chart.” Calculate the counts,
> create the chart, review it against the CSV, and test the labels and totals in dependency order.
> Save the chart as `output/penguin-counts.svg`.

Once calculation, source review, and testing are complete, their Roadmaps can be marked done.
Deployment remains open, so the Milestone is still in progress. Review the chart and test results
against your plan before accepting the completed work.

The completed work can also have a Deliverable record: a receipt linking the result, its location
and the checks that support it to the plan. This gives a later session something more useful than
an unexplained “done” status.

Compared with a harness's plan mode, Durmem's Roadmaps and Milestones let you make dependencies
explicit, adjust the plan as work progresses by adding or removing items, and distribute work
across multiple agents so independent steps can run in parallel. See
[Build a beak length report with a Kanban fleet](../kanban/penguin-walkthrough.md) for an example
of a fleet carrying a Milestone through design, independent reviews, implementation and testing.

## 5. Review progress and blockers

As work continues, you can ask for progress without reconstructing it from earlier chat messages.
The saved plan shows what is finished, what is waiting and what should happen next.

**Tell your coding agent:**

> How is the report project going? Summarize the goal, milestones, and work that is still open, with
> any blockers and next steps. Point me to the records behind the summary.

If calculation, review and testing succeeded, the summary should show those Roadmaps complete
and deployment waiting for your review. If a step could not finish, it should appear in the
remaining work with its blocker. Follow the saved records to inspect the result behind a status.

## 6. Audit one work item against evidence

When you want to inspect a completion claim, ask the agent to compare it with the actual result.
For example, the chart-label test should be supported by the generated chart and its checks.

**Tell your coding agent:**

> Show me how you tested the chart labels and totals. Does `output/penguin-counts.svg` support
> marking that Roadmap done?

The answer should connect the saved test Roadmap with the chart's three island labels, grouped
counts and total of 344. If the result differs from the plan, ask the agent to explain the gap
and update the remaining work. For an evidence problem, see
[Troubleshooting](../reference/troubleshooting.md).

For store operations, see [Manage your stores](../guide/manage-stores.md). To distribute a plan
across several agents and computers, continue with
[Kanban: coordinating complex work](../kanban/what-is-kanban.md).
