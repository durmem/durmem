---
name: loom-exit
description: Session-exit discipline for Durmem - before wrapping up, sweep the session for durable facts not yet captured, and if real work is left unfinished, save a repo-scoped HandoffTask note (with agent id and a concrete next step) so the next session picks up cleanly. Load when the user asks to wrap up, hand over, or end the session, or when you judge a session is ending with meaningful work still in flight.
---

# Durmem — session-exit discipline

Two jobs, run together when a session is wrapping up. Load **loom-coding** first if you
haven't already this session (identity/scope resolution, capture discipline) — this skill
assumes that groundwork is done.

## 1. Capture sweep (reuse loom-coding's on-demand capture)

Same as loom-coding's "on-demand capture": sweep the conversation for durable facts not
already in memory — decisions made (including ones rejected), root causes found, non-obvious
gotchas, standing directives given. Skip status chatter and anything the code/git history
already shows. Check what memory already holds before saving (don't duplicate). This is the
"reflect and capture what we learned" half — see loom-coding §3.

## 2. Session handover — `HandoffTask`

If real work is left unfinished — mid-implementation, blocked on a decision, a half-done
investigation — save a `HandoffTask` so the next session (yours or another agent's) picks up
cleanly instead of re-discovering context from scratch. Skip this if the session reached a
clean stopping point; not every session needs one.

This is a **pull** mechanism: it resurfaces automatically at the next `SessionStart` prime for
THIS repo (wired into the `SessionStart` handler). It complements,
doesn't replace, a direct message when the handoff is time-sensitive or needs a specific
other agent to act.

**Three things this requires, beyond the normal capture rules (loom-coding §1a/§3):**

1. **Scope narrowly to the repo, not the project/workspace.** `['InScope()', 'Repo("<repo>")']`
   ONLY — same repo-name derivation as loom-coding §1b (git remote name, not folder basename).
   A project/workspace-scoped `HandoffTask` would resurface in every repo under that workspace
   at their next session start; a resume note is repo-specific by nature.
2. **Include your agent id in content** — `{"agent": "<harness>@<native-session-id>", ...}`,
   the same conversation identity used by Durmem Kanban. `HandoffTask` has no dedicated `agent`
   field — this is informational content, not a schema field.
3. **Say what to do next, concretely** — not "continue the work" but the actual next step:
   what's half-done, what's blocked and on what, what command to re-run, what decision is
   pending and from whom. Write it for a reader with zero memory of this conversation.

Still attach `Author()` per loom-coding §1a as normal.

```
loom_save(store='<resolved-store>', entity='HandoffTask("<short title>")',
          edges=[['InScope()', 'Repo("<repo>")'], ['Author()', 'GitUser("<git-email>")']],
          content='{"agent": "<harness>@<native-session-id>", "next_step": "..."}')
```

## 3. Picking up a prior `HandoffTask`

If `SessionStart` surfaced a current `HandoffTask` for this repo and you take up that thread,
**Supersede it once addressed** — fully resolved, or you're leaving a fresh handover in its
place. Don't leave it dangling as `current` forever, or it keeps resurfacing at every future
session start for this repo:

```
loom_save(store='<resolved-store>', entity='Finding("<what happened>")',   # or a fresh HandoffTask
          edges=[['Supersedes()', '<old-resume-task-fact-id>'], ...],
          content='{"status":"resolved"}')
```

`Supersedes()` is a fact-to-fact relation, so its target is the OLD `HandoffTask` row's live
`fact_id`, **not** `HandoffTask("<title>")` or any other entity canonical. Using the canonical
fails target resolution because content-bearing fact references never create/resolve placeholder
value nodes. Retain the surfaced `fact_id` from the SessionStart/read result and pass that exact
string in the edge target.

## Reminder to the user

There's no automatic gate forcing this (a Claude Code `SessionEnd` hook cannot block or force
further action — it's cleanup-only, and a `Stop`-hook gate was evaluated and rejected as too
disruptive: it fires on every turn, not just true session exit). Invoking this skill is
opt-in — ask for it explicitly (`loom, wrap up` / `loom-exit`) when you're ending a session
with work still in flight.
