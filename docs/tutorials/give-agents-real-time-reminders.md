# Give agents real-time reminders

<!-- loom-doc: slug=give-agents-real-time-reminders; audience=both; section=tutorials -->
During a long task, an agent can lose track of an earlier decision or instruction as the
conversation grows and its context is compacted. Durmem brings relevant saved knowledge back
into the agent's context when it is needed, helping the agent stay on track without you
repeating the same guidance.

In this guide, you will save an instruction, have it return when a particular subject comes up,
and use the same mechanism to remind an agent of relevant information when it is needed. Finally,
you will leave a handoff so a new session knows where to resume unfinished work.

## Before you start

Finish [Quickstart](../guide/quickstart.md) and
[Durmem data types for coding agents](data-types-for-coding-agents.md). Continue in the same
`palmerpenguins` repository and `[demo]` store. You can also use your own project to follow this guide if you prefer, in which case you need to adapt the prompts accordingly.

## 1. Check the agent connection

This guide's hook-based reminders do not run automatically in OpenAI's Dot in ChatGPT; Dot
users should follow [Connect OpenAI's Dot to Durmem](../guide/connect-dot.md) for manual context
retrieval.

Durmem delivers reminders through supported harness hooks. A hook runs at a particular point in a
session: when the session starts, when you enter a prompt, or when the agent is about to use a
tool. These are opportunities to bring saved guidance back before the agent answers or acts.

To keep the agent fast, plain read-only commands, such as listing files, reading a file or
`git status`, do not bring back saved guidance on their own, because they cannot change anything.
The warnings you arm for a specific command, and the approval check before a consequential command
such as `git push` (section 5), still run.

First, check that Durmem is connected and its hooks are enabled in your harness:

- **Codex:** If asked to trust hooks from the `loom` plugin (`loom@durmem`), trust them permanently.
  Start `codex`, enter `/hooks`, and confirm `SessionStart`, `UserPromptSubmit`, `PreToolUse`,
  `PostToolUse`, `PreCompact`, and `PostCompact` are enabled.
- **Claude Code:** In Claude Code, enter `/hooks` and confirm the `loom` plugin appears under
  `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, and `PreCompact`. If Claude Code
  is launched with `--bare`, its hooks are not available.
- **OpenCode:** Restart OpenCode and run `opencode mcp list` in a terminal. Confirm `durmem` is
  listed; OpenCode supplies prompt and tool events through its plugin.

If a reminder does not appear as you follow this guide, check that the relevant hook is enabled
before changing the saved instruction.

## 2. Save an active instruction

Durmem automatically brings relevant saved knowledge into the agent's context. You can also
specify keywords to make a particular instruction surface whenever those words appear in a
prompt.

Some rows in the `palmerpenguins` dataset have a missing sex field, so a final count could include or
exclude those with missing sex. To avoid ambiguity, we ask the agent to remember to report that choice whenever a
penguin count is reported. Durmem records standing instructions like this as Directives.

**Tell your coding agent:**

> When we talk about penguin counts, please say whether rows with missing sex were dropped.
> Make sure this instruction surfaces whenever a penguin count is asked for.

The agent should show the saved Directive and its attached trigger. A trigger specifies when
to bring a memory back: here, it matches “penguin count” in a prompt. Its hook event is
`UserPromptSubmit`, which means the instruction is supplied when you enter the prompt, before
the agent answers. The trigger matches those words as literal substrings, without regard to case.

## 3. Check a reminder in a fresh session

The instruction is now saved. Try it in another session to see it surface without repeating the
rule yourself.

Open a fresh harness session in the same repository and connect it to `[demo]`. You can use
another harness or computer connected to the same store. In each fresh session in this lesson,
use the [Quickstart session-default prompt](../guide/quickstart.md#choose-this-sessions-default-store)
to select `[demo]`. Then ask:

**Tell your coding agent:**

> Can you summarize penguin counts for the report?

The reminder is supplied to the agent’s context; it is not a separate chat message in every
harness. In the harness chat, ask: “Show the Directive reference and say whether it arrived with
my prompt or you looked it up separately.” Compare it with the saved instruction. A separate
lookup shows recall, but does not confirm hook delivery. The count answer should say whether
rows with missing sex were dropped. If the reminder is missing, use the connection
checks in section 1 and confirm that the new session is using the same store and project.

## 4. Preview a reminder without doing the work

You can also inspect the instruction itself without requesting another count. This is useful
when you want to check or revise what the reminder says:

**Tell your coding agent:**

> Show me the saved reminder for a question about penguin counts.

The response should show the saved instruction about reporting whether rows with missing sex
were dropped. You can ask the agent to revise that wording if it does not capture what you mean.

## 5. Require approval before a consequential command

Reminders can also gate the agent before it runs a command. For example, you may want it to
ask for your approval before pushing changes to the main branch. Save that rule so it comes
back when the agent prepares a push, even if the earlier conversation has been compacted.

**Tell your coding agent:**

> Remember that any git push to the main branch requires my explicit approval. Remind the agent
> of this rule before it runs a git push.

The agent should show the saved Directive and a `PreToolUse` trigger matching `git push`.
This hook brings the rule back before the command runs, so the agent can stop and ask for approval.

To check the rule, open a fresh harness session in the same repository and connect it to `[demo]`:

**Tell your coding agent:**

> Push the current version to main.

The agent should bring back the rule and explain that it needs your explicit approval before it
makes the tool call to push.

## 6. Continue from a saved handoff

A session may end before the work is finished. You might switch computers, change harnesses, or
return the next day. The project goal tells the next agent what you want to achieve, but not how
far the previous agent got or where it should pick up. Without that information, it may repeat
work or ask you to reconstruct the previous session.

A handoff saves the current state of the work and a concrete next step in Durmem. In Codex and
Claude Code, the session-start hook can bring that handoff into the agent's context. Durmem's
OpenCode integration does not load handoffs at session start, so use the prompt below to ask the
agent to read the handoff. The next agent can resume from the saved progress instead of starting over.

For the chart goal from Quickstart, suppose you are stopping before choosing the chart layout:

**Tell your coding agent:**

> In [demo], write a handoff record of this current session in Durmem so another agent can pick up the work.

The agent should show the saved handoff. Check that it includes the chart goal, progress so far,
and choosing the chart layout as the next step; correct it before ending the session if needed.

Open a fresh harness session in the same repository and connect it to `[demo]`.

**Tell your coding agent:**

> Let's continue from the previous session's handoff in [demo].

The agent should read back the same chart goal and progress, then resume at choosing the chart
layout instead of repeating completed work.

## Next

Continue with [Manage a project](manage-a-project.md) to group Roadmaps into a Milestone and report
the work an agent completes.
