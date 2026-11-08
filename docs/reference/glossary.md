# Glossary

<!-- loom-doc: slug=glossary; audience=both; section=reference -->
A quick guide to the words used in Durmem, its coding harnesses, and multi-agent coordination.

**Account** — Your sign-in and access to Durmem.

**Bitemporal history** — A history that distinguishes when information applied from when it became
known. In the [Track values that change](../tutorials/changing-prices.md) tutorial, `asof` records when a price
applied and `known_from` records when it became known. Keeping both lets you distinguish what you
believed at a past date from what later information reveals about that date.

**Capability** — A KanbanTask requirement the worker checks against its own environment before claiming.

**Checkout** — A local working copy of a repository.

**Checkpoint** — A worker's saved progress on a task run before it submits the result.

**Claim** — A worker taking responsibility for one KanbanTask run in the Kanban store.

**Closure** — The owner's confirmation that a KanbanTask's work is complete and no run remains active.

**Compaction** — A harness shortening an older conversation into a summary to make room for more work.

**Coordinator** — The agent in a harness session that turns the operator's outcome into tracked work. You
coordinate by chatting in that session with its coordinator skill and Kanban store connected.

**Decision** — A saved choice or conclusion that can guide later work.

**Dependency** — A link showing that one work item needs another's result before it can start.
Roadmaps and KanbanTasks can each have dependencies within their respective plans.

**Directive** — A saved instruction for an agent to follow during relevant work.

**Domain** — A category that shapes how memory is captured and retrieved, such as coding or personal context.

**Entity** — A named typed value in Durmem; it can identify a memory record or a label such as a project scope.

**Fact** — One saved memory, with a type and links to related memories.

**Finding** — An observation or conclusion supported by evidence from the work.

**Fleet** — A way for an operator to manage workers across trusted computers. See the [Kanban manual](../kanban/what-is-kanban.md#coordinate-several-computers-with-fleet).

**Goal** — A desired project outcome that guides planned work.

**Handoff** — A saved note describing unfinished work and the next step for a later session.

**Harness** — The application where you interact with a coding agent, such as Claude Code, Codex or OpenCode. Workers also run in harnesses.

**Heartbeat** — A worker's periodic check-in that shows it is available to the Kanban store.

**Hook** — An event in a harness where Durmem can add relevant memory to the agent's context.

**Importance** — A shared label for the significance of any memory: normal, important or critical. `roadblocker` is reserved for a Roadmap item that is blocking other work.

**Kanban store** — A dedicated store used to coordinate KanbanTasks among agents. See the [Kanban manual](../kanban/what-is-kanban.md).

**KanbanTask** — One outcome with a brief, acceptance checks, capabilities and an owner. The
[Kanban overview](../kanban/what-is-kanban.md) defines its lifecycle.

**Lease** — A time-limited assignment of a task run to one worker.

**Loom engine** — The memory engine inside Durmem. Hosted users do not install it separately; agent setup connects their agents. Private-server operators install server components separately.

**MCP** — The tool protocol Durmem uses to connect a coding-agent app to memory tools.

**Milestone** — A collection of related Roadmaps or other Milestones that contribute to a body of work.

**Organization** — A top-level scope that can group related workspaces.

**Owner** — The agent responsible for a KanbanTask's questions, result and closure. With an
ownerless KanbanTask, its first claimant becomes the owner. See the [Kanban manual](../kanban/what-is-kanban.md).

**Priority** — How much a piece of planned work matters. Durmem records it with the Importance label; it does not show whether the work is complete.

**Project** — A named area of work used to organize related memories.

**Record** — One saved memory with a type and links to other records. A Roadmap item, Goal and Decision are different record types.

**Relation** — A typed link between a memory and another memory or label.

**Repository identity file** — The root `loom.toml` file that names a checkout's active Workspace.
It contains names, not connection credentials; a store mapping written in it is ignored. Store
mappings are in `~/.loom/stores.toml`; see the
[`stores.toml` reference](stores-toml.md#pick-a-store-for-a-checkout-by-hand).

**Residual** — The non-LLM process on a trusted computer that applies Fleet configuration and
reports the computer's state.

**Roadmap item** — A planned unit of work with a status, such as open or done. Items can be linked to milestones and other items.

**Rule** — Saved logic that the memory engine uses to answer a query or perform an operation.

**Run** — One worker's attempt to complete a KanbanTask.

**Saved default** — The global store section selected in `~/.loom/stores.toml` for ordinary
connections. A Workspace mapping in that file or an explicit session choice may select another store;
changing a session default does not edit the saved setting.

**Scope** — A repository, Project, Workspace or Organization that a memory applies to.

**Session default** — The store used when an agent request does not name a store during the current
session. The Workspace named in the checkout's `loom.toml` selects a matching mapping in
`~/.loom/stores.toml`; otherwise the saved default initializes the session. An explicit session-only
choice then overrides it without editing either saved setting.

**Skill** — Reusable instructions that help an agent perform a kind of work.

**Standing KanbanTask** — A KanbanTask with no total run limit. Each suitable worker runs it once,
including workers that join later, until its owner ends it.

**Store** — A database on the server where connected agents can save and share memories, such as
the practice store `[demo]`.

**Submission** — A worker's report of its result and evidence for a task run; it is not the owner's closure of the task.

**Task** — See KanbanTask: one outcome in a Kanban store, with a clear description of what counts as done.

**Type** — A category that defines what information a kind of memory contains.

**Vault profile** — An encrypted credential profile that Fleet can deliver to trusted computers.

**Worker** — An agent process that claims and completes KanbanTasks in a Kanban store. See the [Kanban manual](../kanban/what-is-kanban.md).

**Workspace** — A scope that can group related projects.

**Workspace mapping** — A setting in `~/.loom/stores.toml` that associates a Workspace with a
coding store. It applies to every checkout whose root `loom.toml` names that Workspace. See the
[`stores.toml` reference](stores-toml.md#pick-a-store-for-a-checkout-by-hand) for its syntax and
selection order.
