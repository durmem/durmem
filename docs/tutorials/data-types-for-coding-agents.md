# Durmem data types for coding agents

<!-- loom-doc: slug=data-types-for-coding-agents; audience=both; section=tutorials -->
This tutorial shows how Durmem uses data types and relationships to make project knowledge easier
to find and use. You will save a decision, a plan, and a finding, then create a new custom support
issue type and connect it to the Roadmap item that will fix it. These connections let a later session answer questions about related work.

## Before you start

Finish [Quickstart](../guide/quickstart.md). Continue in the same `palmerpenguins`
repository and the `[demo]` store. If you use your own project, adapt the examples to its repository
and saved knowledge.

## Memory types and relationships

Durmem uses an entity-relation data model. Entity types describe the kinds of information you save;
relation types describe how that information is connected. The two root types are `Entity` and
`Relation`, and a relation is also called an edge. These are the main entity types for coding work:

| Type | What it records |
| --- | --- |
| Goal | An outcome the project is working toward. |
| Roadmap | A piece of planned work and its status. |
| Decision | A choice and the reason for it. |
| Directive | Standing rules for future work. |
| Finding | A useful fact that was verified, with its evidence. |
| Milestone | A collection of related Roadmaps or other Milestones that contribute to a body of work. |

Relations connect facts, allowing agents to find related facts in Durmem stores. For example,
several Roadmaps can belong to a Milestone, a Decision can explain why a Roadmap item is no longer
needed, and one Milestone can depend on another. By querying
entities and following their relations, agents can build a picture of the current state of work
and quickly retrieve the information they need.

This flexible entity-relation model lets a Durmem store support many practical uses. For example,
Milestones and their dependencies can express a project plan and track issues, removing the need
for a separate project-planning or issue-tracking system for that work.

## 1. Keep a Decision separate from planned work

A Decision records a choice; a Roadmap item records work that remains to do. The following example
saves them separately, then shows how the agent uses the relevant memory in a later answer:

**Tell your coding agent:**

> For palmerpenguins, remember that we decided to read the bundled CSV with Python's built-in
> csv.DictReader.
> Also add a plan to document the bundled CSV columns. Show me how you saved the decision and the planned work.

The agent should show two records: a Decision to use `csv.DictReader` and a Roadmap to document
the columns. Now ask about work affected by that Decision:

**Tell your coding agent:**

> What should I keep in mind while changing how we read the CSV?

The answer should bring back the CSV-reading Decision, showing how a saved choice can guide later work.

## 2. Record a useful Finding

A Finding records a useful fact together with the evidence behind it. Here, the example counts
penguins by species and island in the bundled CSV. A later agent can reuse the result and see how
it was checked.

**Tell your coding agent:**

> Use code to count penguins by species and island in `palmerpenguins/data/penguins.csv`. Save a
> Finding with the grouped counts, total rows, exact source revision, and how you checked it.

Your agent should report something like this:

```text
Observation: At commit 24ab5d7ce1ed9afb54f7a304080da112f44542c8, the bundled palmerpenguins/data/penguins.csv has 344 rows.
Biscoe: Adelie 44, Chinstrap 0, Gentoo 124
Dream: Adelie 56, Chinstrap 68, Gentoo 0
Torgersen: Adelie 52, Chinstrap 0, Gentoo 0
Evidence: Read the CSV at that commit with Python csv.DictReader; counted the (species,island) pairs and checked their sum against the row count.
Method: Used csv.DictReader and collections.Counter; verified the grouped total was 344.
```

The saved Finding connects the result to its source and method, so another agent can use the
count and understand how it was checked.

## 3. Add a type, label and relation

When your project needs to record something the existing types do not capture, ask your agent to
create a new data type in the store. Here, you will create a `SupportIssue` type and use an
Importance label to rank an issue. A label attaches a value to a record; for example, an
Importance of `normal` says how this issue should rank alongside other saved issues.

**Tell your coding agent:**

> Create a `SupportIssue` type with a date, reporter and description. Save this issue, reported
> today by Mara, with normal importance: “The Adelie island-count chart is missing a clear
> comparison between the three islands.”

Check the fields in the saved issue. Your read-back should include:

```text
SupportIssue
Reference: the saved issue’s reference
date: the date you saved the issue
reporter: Mara
description: The Adelie island-count chart is missing a clear comparison between the three islands.
Importance: normal
```

Next, create a Roadmap item to fix the SupportIssue and link the two records:

**Tell your coding agent:**

> Create a Roadmap item to fix the SupportIssue we just saved, and link it to that issue.
> Show both records with their references so I can find the same records in a later session.

The agent should show the two records and the edge type it used to connect them, such as `IsAbout`:
the Roadmap is about the SupportIssue. Keep the issue and Roadmap references for step 4.

## 4. Query a custom relationship from a fresh session

Open a fresh session in the same repository and `[demo]` store. A fresh session can use another
harness or run on another computer. Set its store with the
[Quickstart session-default prompt](../guide/quickstart.md#choose-this-sessions-default-store), then ask:

**Tell your coding agent:**

> In [demo], find the SupportIssue about the Adelie island-count chart. What are its date,
> reporter, description and importance, and which Roadmap item will fix it? Show both references.

The fresh session should report something like this:

```text
SupportIssue
Reference: the saved issue’s reference
date: the date you saved the issue
reporter: Mara
description: The Adelie island-count chart is missing a clear comparison between the three islands.
Importance: normal
Related Roadmap: fix the island-count chart
Roadmap reference: the linked Roadmap’s reference
Relation: Roadmap → IsAbout → SupportIssue
```

**Check:** The issue and Roadmap references should match the ones you kept in step 3.

## Next

Continue with [Give agents real-time reminders](give-agents-real-time-reminders.md) to see how a
saved instruction can return when it is relevant.
