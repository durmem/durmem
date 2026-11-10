---
name: loom-coding
description: Coding-agent memory discipline for Durmem — prime a repo at session start, capture the developer's standing directives / design decisions / goals / findings as scoped, AUTHOR-ATTRIBUTED facts, reinforce repeated instructions so they stop being forgotten, and bootstrap a fresh repo. On a shared multi-user server, resolve the author from git email and tag every fact with Author() → GitUser(email), and resolve the Project against existing nodes (never invent one). Load when working in a code repository with Durmem available, especially at the start of a coding session or when the user states a rule, decision, goal, or "remember this". Pairs with loom-capture (general write discipline), loom-query (read side).
---

# Durmem — coding specialization

Durmem turns memory from something you must *remember to read* into something that
**re-asserts itself at the moment of action**. This skill is the judgment layer for
coding sessions: what to capture, how to scope it, how to prime, and how repeated
instructions raise their own priority.

The Durmem tool descriptions cover mechanics (`loom_save`, `loom_query`, entity/relation
types); load **loom-capture** for the general reconcile-on-save discipline. The Coding
overlay is a **scaffold over the full self-organizing memory, not a schema** — you
may still mint ANY entity/relation type and store ANY useful fact (experiments, tips,
failure analyses, where env vars / API keys live — the *location*, never the secret,
file maps, …).

**Credential-file safety:** Never print, `cat`, `grep`, quote, or summarize `~/.loom/stores.toml`
or any credential/key file. Treat `store_key` and private keys as secrets. To check configured
stores or connectivity, use only `loom_list_stores()` and `loom_load_store(...)`; never copy or
expose file values.

## The fact model in one line

A fact is **one `Entity`** (its sortal — *what the fact IS*; drives the embedding) plus
**zero or more `[relation, target]` edges** (*how it's filed / what it points at*). Save
takes `entity` + `edges`; reads are an AND-of-OR of `[relation, target]` pairs. See
the Durmem tool descriptions for the full mechanics.

## Shared across harnesses

Durmem rules, prompts, and skills are **shared across all harnesses**. Do not fork
the instruction layer into `loom-codex`, `loom-claude`, or any other harness-specific
variant. Harness-specific behavior belongs in plugin wiring, hook adapters, installer
metadata, transport config, or integration code. Keep the shared discipline consistent
in every harness package.

The only skill exception is `loom-install`: install/bootstrap steps are genuinely
harness-specific, but the skill must be identically named `loom-install` in every harness
that ships one. Do not create names like `loom-codex-install` or `loom-claude-install`.

The user's `~/.loom/stores.toml` is the connection and credential registry. It contains named store
sections, their endpoints and keys, workspace-to-store mappings, and an optional saved default.
Never read or print this file yourself. Repository identity lives in a nonsecret `loom.toml` at the
Git root; its `active_workspace` selects the confirmed workspace. The coding store comes only from
the registry's `[workspace]` mapping for that workspace, or the registry's default; a mapping in the
repository file never selects it. The shared resolver combines these sources and returns the selected store through
`loom_list_stores(repo_path=...)`. Never copy endpoint or credential values into a repository,
plugin config, or hook environment. The only allowed credential-manager environment fallback is
the client's one private credential variable.

Durmem is **multi-store**: additional named stores (a benchmark store, another repo's
store) live in `~/.loom/stores.toml`. Call `loom_list_stores()` to see them,
`loom_load_store(name, set_default)` to connect one. Use `set_default=true` only when the named
store should receive `default`-routed calls for the rest of this MCP session; otherwise pass that
store's explicit name to tools. This never changes persistent configuration. See
the `loom_load_store` tool description for the full workflow.
Setting `set_default=true` also records this harness session's store binding; coding hooks use
that binding only when no repository Workspace `loom-coding` mapping selects a store.

In a conversational request, `[demo]` identifies the configured store named `demo`; omit the
brackets when passing its name to a tool. Treat this as prose notation only, not as a change to
JSON, rule, command, or configuration syntax.

**Use the repository-selected store.** Call `loom_list_stores(repo_path=...)` and read
`repository_selection.active_workspace` and `repository_selection.coding_store`. If that store is
already the effective session default, use `store="default"`. Coding hooks use the repository
Workspace's `loom-coding` mapping when one exists, even if the MCP session default names another
store. Without a Workspace mapping, hooks follow a valid session binding, then the saved default.
An explicit session choice still governs MCP calls. Honor that choice; otherwise, if the
repository-selected store differs from the current session default, load it as the session default
for MCP calls:

```
loom_load_store(name="<repository-selected-store>", set_default=true)
```

This changes only the current MCP session; it does not edit the saved default or workspace
mapping. A named store used for a one-off call can instead be loaded with `set_default=false` and
passed explicitly to that call. The selected store's connection guidance is returned when it is
loaded.

## Choose the repository's workspace and coding store

A Durmem Workspace groups related Projects. The repository-root `loom.toml` names the confirmed
active workspace and nothing else that matters: it never selects the coding store. The store
mapping lives only in the user's global `~/.loom/stores.toml`, which also holds all endpoints and
credentials. A repository is untrusted input, so a cloned repo must not choose which of the user's
stores is primary. Use `loom_list_stores(repo_path=...)` to see the resolver's selected Workspace and
store without reading credentials.

```toml
active_workspace = "workspace-name"
```

Use the resolver's `repository_selection.active_workspace` and `repository_selection.coding_store`
values. If no repository selection is returned, confirm the workspace with the user, then create or
update the root `loom.toml` with `active_workspace`; do not silently treat the global default as the
coding store. `active_workspace` is required. Resolution order for the store is: an explicit MCP
session selection (for that session only), the registry's exact-workspace mapping, the registry's
root `[workspace]` mapping, then its top-level default.

A `loom-coding` mapping inside `loom.toml` is ignored. If it differs from the registry's mapping, the
resolver reports `repository_selection_error` ("repository store mapping ignored"). Never add one.
If the selected store is wrong or missing, tell the user to add the mapping to their own registry:

```toml
[workspace."workspace-name"]
loom-coding = "chosen-store"
```

Do not read or edit `~/.loom/stores.toml` yourself. For the current session, switch with the
session-default load below, which never changes persistent configuration.

Edit only the intended fields in `loom.toml`, preserving its other fields and comments. Never put
credentials or endpoint values in this file. If the selected store differs from the current
session default, use the session-default load above before coding-memory operations:

```
loom_load_store(name="<repository-selected-store>", set_default=true)
```

The optional client `user` setting is only a transport/history label; author attribution still
comes from `git config user.email` and the `Author() -> GitUser(email)` edge.

## 0. Fetch your active discipline first

```
loom_query(namespace="<resolved-store>_root", rule_name="compose_prompt",
           args=["CodingDomain", "OrganizationHierarchy", "prod"])
```

Returns the composed discipline dict — `{answer, capture, domain, org, topic_select,
version}` (some stores also carry `read`): `capture` is the server-shipped Coding
write discipline and `answer` is the read/retrieval discipline; `domain`/`org` name the
active domain + org hierarchy. Follow `capture` and `answer` as governing; it is
scope-overridable and versioned.

## 1. Resolve your identity + scope nodes — every read/write keys on these

The Durmem server may be **shared by multiple developers** (one server, many clients —
see the multi-user design). So two things must be resolved before any write:
**who you are** (author attribution) and **where the fact is filed** (scope).

### 1a. Author identity — attach `Author()` to EVERY fact

Resolve the developer from **git**, once per session:

```
git config user.email     # → the author identity, e.g. "dev@example.test"
git config user.name      # → human label, only if you need to show it
```

The author value-node is `GitUser("<email>")` — `GitUser <: Person`, keyed by **email**
(stable across machines; the name is not). Add an author edge to **every** `loom_save`:

```
['Author()', 'GitUser("dev@example.test")']
```

This is **non-optional on a shared server**: a `Decision`/`Directive`/`Finding` with no
author is unattributable once several people write to the same store. ⚠ Use a **real**
git email — `git config user.email` is often left at a placeholder like `you@local` or a
stale CI value; if it doesn't look like the developer's real address, **ASK** before
writing (a wrong email forks the author node) and suggest they fix `git config
user.email`. Same if it's empty. Declare the types once at
bootstrap if a fresh store lacks them:

```
loom_declare_types(store='<resolved-store>', type_specs=[
  {name:"GitUser", parent:"Person",   kind:"concrete", fields:["email"],
   why_new:"author attribution on a shared multi-user server"},
  {name:"Author",  parent:"Relation", kind:"concrete", fields:[],
   why_new:"fact Author()->GitUser(email); who entered this fact"}])
loom_save(store='<resolved-store>', content='{}', entity='GitUser("dev@example.test")')
```

The `GitUser` node save is mandatory before any fact carries the `Author()` edge.
Declaration creates the type, not an instance. Edge targets are resolve-or-reject and
are never created implicitly.

To read **one developer's** facts later, AND in an `[["Author()", 'GitUser("…")']]` group;
to see all authors on a node, `edge_targets(fact_id, "Author")`.

### 1b. Scope nodes

Scope coords are plain **entity nodes** (`Project("coding")`, `Workspace("development")`,
`Organization("example-org")`, `Repo("my-app")`); the hierarchy is **`PartOf` edges**
between them (NOT parametric type parameters). A fact is filed with `InScope()` edges to
the node(s) it applies to.

- **repo** — the **git repository name**, NOT the working-folder basename (they often
  differ). Derive it from the remote: `basename -s .git "$(git remote get-url origin)"`
  — e.g. a folder `my-app-experiments` cloned from `…/my-app.git` has repo
  name **`my-app`** → `Repo("my-app")`. Fall back to the directory basename
  only when there is no remote (a never-pushed local repo).
- **project** — never invent a Project name. Query existing Project nodes, choose only an
  unambiguous match, or ask the user to confirm/create one.
- **workspace** — use the confirmed `active_workspace` from root `loom.toml`; if absent, ask the
  user to confirm the Workspace name and add it to `loom.toml` before resolving the store. Then
  verify that Workspace and the complete scope path in the selected store.
  - **org** — resolve against existing Organization nodes; if absent or ambiguous, ask rather than
  guessing. Explain the three plainly when you ask:
  - **org** — the company / GitHub org / account (e.g. `example-org`) → `Organization("example-org")`.
  - **workspace** — a product or team that **groups related repos/projects** under the org
    (e.g. `loom`) → `Workspace("loom")`. If the user has no such grouping (a single standalone
    project), **default workspace to the project name** — a degenerate one-project workspace —
    and confirm it; never invent a value silently.
- **project** — the specific initiative / repo-set you work in (e.g. `coding`) →
  `Project("coding")`.

- **store** — the configured store section selected by the shared resolver for this Workspace;
  it is a connection choice, not a graph scope node. Do not infer it from the folder or read the
  credentials registry yourself.

Scope-node identity is the **string arg** (value-node dedup is on the exact canonical), so
`Project("coding")` and `Project("coding-assistant")` are different nodes. Use the exact names
confirmed in the selected store.

**Bootstrap the `PartOf` chain in each store that will be used for coding memory.** A chain in
one store does not create scope records in another. Use `scope_chain` in the repository-selected
store to verify the exact Repo→Project→active Workspace→Organization path; when absent or
ambiguous, ask the user to confirm the identities before creating missing nodes and links. Save
parents before children because every edge target must already exist:

```
loom_save(store='<resolved-store>', content='{}', known_from="<today>", entity='Organization("example-org")')
loom_save(store='<resolved-store>', content='{}', known_from="<today>", entity='Workspace("loom")',
          edges=[['PartOf()', 'Organization("example-org")']])
loom_save(store='<resolved-store>', content='{}', known_from="<today>", entity='Project("coding")',
          edges=[['PartOf()', 'Workspace("loom")']])
# Repo lives under the project: Repo("my-app") PartOf Project("coding")
loom_save(store='<resolved-store>', content='{}', known_from="<today>", entity='Repo("my-app")',
          edges=[['PartOf()', 'Project("coding")']])
```

Create only missing nodes. When an existing node lacks a confirmed parent link, add that link with
`loom_add_edges` to the existing node's fact; re-saving the node does not merge new edges. You do
NOT need a goal (optional) or a path/area (stored on facts, never a scope). For `loom_save_many`,
preserve the same order: node-creation saves first, facts whose edges reference those nodes
afterward. A batch does not waive target liveness.

## 1b-verify. Before opening, declaring incomplete, or closing ANY roadmap item, verify current truth

**A roadmap item is a claim about the past, not a description of the present.** Before you
open one for development, report that it remains incomplete, or give it a terminal
disposition, verify it against the CURRENT state of the code, the store and the running
system. Repeat this audit whenever the target branch or deploying release advances during
a long-running effort; a correct claim-time audit can become stale too.

Check, in this order, and stop at the first that resolves it:
1. **Already decided?** Query for a `Decision` naming this defect. A prior
   *decided-against* is binding.
2. **Already fixed?** Read the code and the live system, not the row. A fix may be merged
   but unreleased, so ALSO check whether the fixing commit has actually shipped — an
   unreleased fix looks exactly like an open defect from the outside. A release contains
   its full source snapshot, not only its tip commit's diff: prove the fixing commit is an
   ancestor of the deployed release source before classifying it as shipped.
3. **Does the subject still exist?** Verify the store, route, file, host or component the
   item is about is still real. Retired subsystems leave live-looking rows behind.
4. **Is the evidence still reproducible?** Re-measure the symptom with your own instrument
   before treating the row's description as current.

Only if it survives all four is there work to do. If it does not, close it with the
evidence (`Has()->Status("done"|"canceled")`) — do not silently skip it, or the next agent
re-opens it.

## 1c. Three rules that override your sense of already knowing

Check authoritative evidence even when the answer feels familiar.

**A. Check for a prior disposition before implementing.** Before writing code that fixes a
named defect, query the store for an existing `Decision` on that defect. A prior
*decided-against* is BINDING; reopening it requires approval from the operator or
the store's authorized owner.

**B. When a passage confirms your intended action, read to the end of the subsection.**
The exception or escape hatch is typically the NEXT SENTENCE. Confirmation is where
reading stops, so it is exactly where reading must continue.

**C. Attempt the call before reporting impossibility.** A gate's rejection message IS
documentation. Never tell the user "X is impossible", propose a workaround, or ask
permission for one, without having actually tried X. Read the full rejection message
for supported alternatives.

The general form of all three: **do not compose an explanation for a silence or a gap
when an instrument exists.** Absence of evidence is not evidence. If you are about to
write "X, because Y" and Y is checkable, check Y before writing the sentence.

## 2. Prime at session start

Resolve the exact Repo→Project→active Workspace→Organization path with `scope_chain` in the
selected store. Prime with those exact nodes; do not use `facts_in_scope(Project(...))`, whose
recursive parent walk may include sibling Workspace branches when a Project has multiple parents.
Use `facts_by_groups` with one `InScope()` OR group containing only the verified chain nodes:

```
loom_query(namespace="<resolved-store>_root", rule_name="scope_chain",
           args=['Repo("my-app")', '<active-workspace>'])
```

Continue only when the result contains exactly one path and `truncated` is false. Use the four
returned nodes in the scope group; do not fill missing nodes from guidance text or another store.

```text
loom_query(namespace="<resolved-store>_root", rule_name="facts_by_groups",
           args=[[ [["SubTypeOf()", "Directive"]],
                   [["InScope()", 'Repo("my-app")'],
                    ["InScope()", 'Project("coding")'],
                    ["InScope()", 'Workspace("loom")'],
                    ["InScope()", 'Organization("example-org")']] ]])
```

Repeat with the desired family (`Decision`, `Goal`, `CodeDoc`, and other relevant types). The
explicit chain includes workspace- and organization-level memory without including sibling
workspace branches.

Read this BEFORE exploring the repo — it surfaces the architecture knowledge, standing
orders, design decisions (incl. what was decided *against*), open goals, and recipes prior
sessions banked. **You rank the result yourself**: by `Importance` (each fact's
`typed_labels` carries its edge targets — `Importance("critical")` > `"important"` >
normal/untagged), then recency (`known_from`). Don't re-discover what memory already holds.

## 3. Capture what matters — and reconcile

**Keep only relevant, load-bearing facts** — durable intent, decisions, environment, and
findings a future action would actually use. **Drop noise**: historical "when it shipped"
status, chatter, and anything derivable from code or git. Then **shape every fact for
indexing** — pick the right entity sortal, and add the edges that let it surface *only*
when relevant. A read is assembled from these dimensions:

- **entity (family)** — the sortal IS the family: `Directive` / `Decision` / `Goal` / a
  `CodeDoc` subtype (table below). One per fact; it drives the embedding.
- **author (mandatory on a shared server)** — `['Author()', 'GitUser("<git-email>")']` on
  EVERY fact (§1a). It's who entered the fact; without it a shared store is unattributable.
- **scope** — file the fact at the level it applies to with **`InScope()` edges to scope
  nodes**. A **specific** fact points at the narrowest node: `['InScope()', 'Project("coding")']`
  (project-wide) or `['InScope()', 'Repo("my-app")']` (repo-specific). A **group-wide**
  fact points higher: `['InScope()', 'Workspace("loom")']` (whole workspace) or
  `['InScope()', 'Organization("example-org")']` (org-wide). A fact may carry **multiple** `InScope`
  edges across the independent dimensions (a `Repo` AND a `Project`). Coding-memory reads use the
  verified Repo→Project→active Workspace→Organization path from §2; do not rely on an unrestricted
  recursive parent walk when the graph has multiple Workspace memberships.
  ⚠ **A `Directive`/`Decision` whose entire reason to exist is ONE Roadmap or Milestone
  does not get a bare project/repo `InScope` and nothing else.** "The user approves release
  builds for this milestone" or "billed CI pre-approved for this one milestone" is
  not standing project-wide policy — it's an authorization whose lifetime is that item's
  lifetime. Give it BOTH the normal `InScope` (so it's still found by ordinary scope reads
  while active) AND `['IsAbout()', '<the Roadmap/Milestone's fact_id>']` — **the fact_id,
  never the entity canonical.** A live Roadmap/Milestone is a content-bearing fact, not a
  pure Label/value-node, so the fact_id is the unambiguous handle to that existing
  content-bearing item. Save rejects a missing edge target with `edge_target_missing_node`, so
  an unresolved canonical target now fails loudly, but a wrong-yet-existing canonical still resolves
  quietly; use the fact_id. The item's
  own `Roadmap("<title>")`/`Milestone("<title>")` canonical is not a substitute. Look the
  item up first (`facts_by_groups`) and use its returned `fact_id`. This
  lets a later maintenance pass find every directive/decision an item owns by its `IsAbout`
  target instead of guessing from prose, and retire them together the moment that item's
  `Status` goes `done`/`canceled` (§ Roadmap and Milestone lifecycle, below). A durable,
  general rule ("use the project-approved build service") still gets only the broad scope — this
  is for the narrow, one-shot, tied-to-this-item kind.
- **`IsAbout() → <SubjectType>()`** — the subject, via a **concrete type** (not a freeform
  string) — the ordinary subject-type form. (The one exception is the item-specific
  `IsAbout() → <fact_id>` edge for a directive/decision owned by ONE Roadmap/Milestone,
  described in the scope bullet above; it names that item's fact_id, not a subject type.)
  There is NO `Topic` catch-all. **Reuse a shipped subject type** where one fits —
  e.g. release/deploy ops use the shipped `Release()` / `Deploy()` (under `DevOps <: Procedure`):
  `["IsAbout()", "Release()"]`. Otherwise declare one first (e.g. `Benchmarking <: Interest`) in
  `new_types`. A read then narrows by subject — `Directive ∧ IsAbout Release()` surfaces only
  release directives; a bare **family** matches its subtree, so `Directive ∧ IsAbout DevOps`
  surfaces both release and deploy. **Search `list_types` and reuse an existing subject
  type before minting a near-duplicate.** Omit the `IsAbout` edge when the subject is already
  captured in the entity sortal itself.
- **`Has() → Importance("normal"|"important"|"critical"|"roadblocker")`** — priority (a `Label`), only when it matters (§4); default none. `roadblocker` is the highest level (above critical) and is assigned only to a Roadmap that is blocking work; it is never reached by repetition.
- **`source_doc`** in content — for any doc-derived fact, a repo-relative path (+ section)
  so a later agent can open the original for detail. **Must be in content** — reads return
  content, not `source_text`.
- **`commits`/`fix_commit`** in content — for a fact ABOUT a code change (a bug + its fix, a
  gotcha, a migration), record the commit SHA(s) (short hash + one-line what), so a later
  agent can `git show <sha>` for the exact diff and rationale. Same anchor idea as `source_doc`,
  pointed at the change instead of a doc.

**Edge vs content field — which goes where?** An **edge** (or the entity itself) is a
*retrieval axis*: make it an edge only if you'd ever find / group / rank facts BY it (scope,
a declared subject/domain type, `Importance`, or another fact/entity the fact is *about* or
*disputes*). A **content
field** is *payload* you read only AFTER retrieving the fact (`source_doc`, `commits`,
`status`, measurements, free text). Litmus test: *would you pass it to `facts_by_groups` as a
`[relation, target]` filter?* — yes → edge, no → content. Don't mint a value-node for a unique
/ high-cardinality value (a SHA, a timestamp, a one-off detail): it bloats the ontology without
grouping anything. Start such values in content and add an edge only when a real "find-by-it"
access pattern emerges.

Pick the entity sortal + add the dimension edges:

| What | Entity (sortal) | Edges |
|---|---|---|
| Standing operational order | `Directive("run the server elevated, not sandboxed")` | `['InScope()', 'Project("coding")']` (or `'Workspace("development")'` if workspace-wide) + `['IsAbout()', 'Deploy()']` (shipped subject under `DevOps <: Procedure`) |
| Settled design choice / prohibition | `Decision("no cache layer; correctness over speed")` + content `{"decided_against": true}` | `['InScope()', ...]` + `['IsAbout()', ...]` |
| What an effort drives toward | a concrete subtype of the abstract `Goal` family, e.g. `ProjectGoal("ship the endpoint and verify") <: Goal` | `['InScope()', ...]` + `['IsAbout()', ...]` |
| Findings / dead-ends / env / recipes / shipped artifacts | a `CodeDoc` subtype: `Finding("endpoint integration: retry-once fixed the race")`, `Deliverable("v1 core landed")` | `['InScope()', ...]` + `['IsAbout()', ...]` |

For knowledge, always pick a **`CodeDoc` subtype** entity (`Architecture`, `Environment`,
`Finding`, `BusinessContext`, `Recipe`, `AreaMap`, `Mechanism`, …) — never the bare `CodeDoc`
parent. Capture not just code mechanics (`Architecture` = *how* it's built) but the
**business/domain logic** (`BusinessContext` = *why* it exists, the domain model + vocabulary,
the big picture, how code maps to business value) — an agent that grasps the *why* makes better
decisions, not just correct edits. Gather `BusinessContext` at `/loom init` and whenever the
purpose/domain becomes clearer. A `facts_by_groups` read with `[["SubTypeOf()", "CodeDoc"]]` as
the family group scans the whole `CodeDoc` subtree, so any subtype shows up.

```
loom_save(store='<resolved-store>', content='{"status":"active"}', known_from="2024-06-14",
          entity='Directive("run the server elevated, not sandboxed")',
          edges=[['Author()', 'GitUser("dev@example.test")'],
                 ['InScope()', 'Project("coding")'],
                 ['IsAbout()', 'Deploy()']])
# Author() → GitUser("<git config user.email>") is REQUIRED on every save (§1a, shared server).
# + IsAbout() → <SubjectType>() edge(s) for indexing (reuse a shipped type like Release/Deploy, or declare one in new_types);
#   add ['Has()', 'Importance("important"|"critical")']
#   only if it matters (§4); put "source_doc":"<path>" in content if the fact came from a doc.
# ⚠ Each expression is parsed as a Julia constructor head + LITERAL args (no eval). A literal
#   `$` is auto-escaped server-side; an unescaped `"` or `\` inside the text still breaks the
#   parse — escape them (`\"`, `\\`) or keep such text in `content` (content is never parsed).
#   On SAVE every relation must be a concrete INSTANCE with parens, even zero-field: `Has()`,
#   `IsAbout()`, `InScope()` — a bare `Has` or abstract family is rejected.
```

**Reconcile on save** (loom-capture discipline): before saving, pull related facts;
if the new fact contradicts a standing one, resolve it explicitly — a `['Dispute()', '<fact_id>']`
or `['Negates()', '<fact_id>']` edge (contested/false), or a `['Supersedes()', '<fact_id>']` edge
(non-adversarial: the new fact replaces it, old kept as history) — rather than letting two
contradictory orders coexist. All three are edges pointing at the stale fact's id; the old fact
stays live but is flagged not-current. See loom-capture.

**On-demand capture:** when the user says *"Durmem, capture / summarize what we learnt"*,
sweep the session — extract each durable fact as its specific `CodeDoc` subtype entity
(`Finding`, `Decision`, `BusinessContext`, …) with its scope/subject edges, and reconcile
conflicts in one pass.

### Session handover — leave a `HandoffTask`

When a session ends with real work still in flight, load **loom-exit** — it covers the
capture sweep plus the `HandoffTask` handover-note discipline (repo-scoped, agent-id-tagged,
concrete next step) so the next session picks up cleanly instead of re-discovering context
from scratch.

At the next `SessionStart`, current `HandoffTask` facts scoped to this exact repo surface
automatically appear in the session-start prime — see loom-exit §3 for picking one up (Supersede it once
addressed, don't leave it dangling as `current` forever).

## 4. Importance — mark what matters; escalate on repetition

Importance is a **declared 4-level value node** reached by a `Has()` edge —
`Has() → Importance("normal"|"important"|"critical"|"roadblocker")` (default = no edge = normal), **not**
an emergent count. It gets set two ways:

- **Explicit (primary).** When the user signals a rule matters — "important", "critical",
  "always", "never", "don't forget" — add `['Has()', 'Importance("important")']` (or
  `"critical"`) directly at save.
- **Escalation (fallback).** When the user *repeats* a standing rule **without** flagging
  it, raise its level one step via **relabel** (normal → important → critical, capping at
  critical), around the ~3rd mention. The repetition is the signal; you keep no count.
  Changing an Importance level is an EDGE swap on the existing fact, NOT a re-save (re-saving
  the same entity canonical is a dedup no-op). For a **Roadmap** — whose Importance is a
  unique label with exactly one value — relabel is one compare-and-swap:
  `loom_replace_edge(store='<resolved-store>', fact_id='<fact-id>', relation='Has()',
  old_target='Importance("important")', new_target='Importance("critical")')`.
  Adding a different level with `loom_add_edges` is rejected, and the error names the current
  value and this call. For a fact whose Importance is not a declared unique label, use the
  explicit remove-old then add-new sequence:
  `loom_remove_edges(store='<resolved-store>', fact_id='<fact-id>', edges=[['Has()',
  'Importance("important")']])` then
  `loom_add_edges(store='<resolved-store>', fact_id='<fact-id>', edges=[['Has()',
  'Importance("critical")']])`.
  This touches only the edge table — the entity row and its embedding are unchanged.

Reads sort/filter by `Importance` (the target canonical comes back in the fact's
`typed_labels`), so a high-priority directive ranks up and surfaces first. You can also
filter directly: `[["Has()", 'Importance("roadblocker")'], ["Has()", 'Importance("critical")'], ["Has()", 'Importance("important")']]`
as an OR-group. `roadblocker` outranks `critical` and is reserved for a Roadmap that is
blocking work; it is never reached by repetition (escalation caps at `critical`).

⚠ **Roadmap priority invariant:** the `roadblocker` level node is root-seeded and writable.
Every Roadmap has exactly one `Has() → Importance(...)` edge; a Roadmap's priority is written by
setting that single Importance (default = `normal`), and the exact-one invariant is enforced by
Durmem (a Roadmap may never end with zero or multiple Importance targets). `roadblocker`
is reserved for a Roadmap that is blocking work. Confirm a live `Importance("roadblocker")` node
before writing it via `loom_query(namespace="<store>_root", rule_name="list_nodes", args=["Importance"])`.

⚠ Do **not** re-save duplicate copies of a directive to "raise a count" — **there is no
count** (and a re-save of the same canonical is a dedup no-op anyway). A restatement either
sets/raises the `Importance` edge (via relabel — `loom_replace_edge` on a Roadmap) or is a
no-op. (Emergent count-based reinforcement and `Reaffirm` edges were evaluated and rejected
as too much machinery for a simple priority metric — see `loom-coding-design.md` §12.)

### Roadmap and Milestone lifecycle — progress by relabel, close by Status

A `Roadmap` is one planned work item. File every proposed change, plan or follow-up that is
not done yet as a `Roadmap`, one per item, never as a `Project`: a `Project` is only the scope
a fact is about, and a Roadmap query will not find work saved as one. For example:

```text
loom_save(store="<store>", entity='Roadmap("<short title of the change>")',
  content="<what to change, why, and how to tell it is done>",
  edges=[["Has()", 'Importance("normal")'], ["Has()", 'Status("not_started")'],
         ["InScope()", 'Project("<project name>")']])
```

Save the `Project` node first if it does not exist yet. A multi-step plan is one `Milestone` with
each step a Roadmap attached through `PartOf()`, not one entity with a long description.

A work `Milestone` groups related Roadmap items:
save the Milestone first, then attach each member through `PartOf()`. A release
`Milestone` groups work milestones; only an emergency-fix Roadmap belongs directly
to it.

Name new work milestones `m<index>-<scope>` (`m1-setup`, `m2-memory`, `m3-search`); name a
release milestone exactly by its release tag. The work
milestone index orders the program; the scope names the area. A Milestone's entity
canonical is its identity: renaming mints a different node and leaves existing `PartOf` edges pointing
at the old one. Keep pre-convention descriptive names; reference them by `fact_id`,
never retro-rename them.

Rank either kind with `Importance` and track its lifecycle through the root-declared value node
`Has() → Status("not_started"|"in_flight"|"deferred"|"done"|"canceled")`. No `Status`
edge means `not_started`. `deferred` means still intended but not now — it is NOT
terminal and remains open work, merely held out of the standing open-roadmap list so it
cannot crowd out actionable items.

Advance a Roadmap or Milestone by **relabeling**. `Status` on these types is a unique label:
at most one value, and adding a different one is rejected. Change it with one compare-and-swap,
`loom_replace_edge(store, fact_id, 'Has()', 'Status("not_started")', 'Status("in_flight")')`;
it fails with no change if the current value is not the one you named, so read the edges first.
A row with no Status yet takes a plain `loom_add_edges`. This is a pure edge swap; the work item
keeps the same `fact_id` and is not re-embedded. The root rule `unique_label_audit` lists rows
that still hold several Status values (written before enforcement) or none.

**A terminal `Status` edge IS closure, and it is the representation to WRITE.** That is the
standing directive — a work item is closed by a Status edge, never by title prose — and
relabeling a Roadmap or Milestone `done` or `canceled` is what removes it from the standing
list.

⚠ When READING, know that the shipped reader honours a second representation. It also treats a
`"status"` field in fact **content** as authoritative,
accepting the looser spellings `done|closed|resolved|canceled|cancelled` that the seeded
`Status` enum would reject. That path exists for older rows whose lifecycle was written into
content before the edge existed, and a regression test pins it — dropping it silently
reopens every such row. So a row can read as closed with no `Status` edge at all. Write the
edge; expect either when auditing.

Supersession still has an effect, and it is worth knowing the difference. A fact that a
`Supersedes()` edge points at stops being `current`, and every current-only read — including
this one — drops it. So a `Deliverable` receipt does remove its Roadmap from the list as a
side effect. That is not what makes the item closed; the `Status` edge is. Close with
`Status`, and write the receipt because the evidence is worth keeping.

A `Deliverable` is the **evidence receipt**, not the closing act. Write one whenever
delivered work leaves something a later reader would need: what shipped, where it landed,
and how it was verified.

- **Done:** relabel the item to `Status("done")`, then save a distinct,
  evidence-bearing `Deliverable` with
  `['Supersedes()', '<work-item-fact-id>']` plus the normal author and scope edges.
- **Canceled:** relabel the item to `Status("canceled")`. Add
  `['Supersedes()', '<same-work-item-fact-id>']` to that item itself — a
  self-supersession — only when the reason for abandoning it is worth preserving; do not
  fabricate a Deliverable for work that did not ship.

The Roadmap or Milestone carries `Status`/`Importance`; a `Deliverable` needs no `Status`.

**Closing an item also retires what was only `IsAbout` it.** A `Directive`/`Decision`
saved per §4 above with `['IsAbout()', '<that-item's-fact_id>']` exists only because that
item was open — when you relabel the item `done`/`canceled`, find its `IsAbout`-tagged
directives/decisions (`facts_by_groups` on `[["IsAbout()", "<item-fact_id>"]]` — the
**fact_id**, matching how it was written, not the item's canonical) and add `['Supersedes()',
'<that-directive/decision-fact-id>']` on a new fact for each, marking it non-current. Don't
`loom_forget` it — a normal change of state, not a data-entry error — and don't leave it standing: an authorization for finished work read as
if it still governs can extend permission beyond the work it authorized. A directive/decision
with no `IsAbout` edge at all can't be found
this way — that's the gap the write-time rule above closes going forward; anything already
stranded needs a one-time text-matching audit instead.

**Four rules the mechanics do not enforce.**

1. **Change `Status` with `loom_replace_edge`, not an add.** On a Roadmap or Milestone,
   Status is a unique label: adding `Status("done")` to a row carrying `Status("not_started")`
   is rejected with `unique_label_conflict` and changes nothing. Rows written before that rule
   can still read open *and* closed, which is worse than unlabeled: unlabeled is merely
   invisible, contradictory is actively wrong. Run `unique_label_audit` and repair any
   `multiple` row by removing the stale values with `loom_remove_edges`.

2. **Legacy rows with no `Importance` stay writable, but fix them when you touch them.** A
   write that names no Importance never checks it, so adding a `Status` to such a row works.
   `unique_label_audit` lists these rows as kind `zero` for `Has()→Importance`; give each one
   level with `loom_add_edges` (there is nothing to swap from yet).

3. **Choose the terminal state by WHAT HAPPENED, not by whether work stopped.** Three
   situations collapse into two labels — the proposed *approach* was rejected → `canceled`;
   the row's claim was later *disproven* → `canceled`; the work was *delivered* and the record
   lives in a superseding row → `done`. Marking a delivered request `canceled` actively
   misinforms: it reads as "we decided not to do this" when the truth is "we did it, recorded
   elsewhere."

4. **A row whose deliverable was an ANSWER is `done` with no commit.** Some items ask someone
   to find out whether a claimed gap is real, and the output is a note concluding it was
   already handled. Do not reject these for lacking a fixing commit; the "prove the fixing
   commit is an ancestor of the deployed release" check does not apply to them.

## 5. Search before you decide

You can see the entire ontology (both `Entity` and `Relation` roots):

```
loom_query(namespace="<resolved-store>_root", rule_name="list_types", args=[])
```

**Proactively consult Durmem whenever a request plausibly relates to something it already knows.**
You have the full entity/relation type list above — so before forming a plan, designing an approach,
or taking a consequential action, ask: does this touch an existing `Decision`, `Directive`,
`Mechanism`, `Roadmap` item, `Glossary` term, `AreaMap`, …? If plausibly yes, query Durmem FIRST and
build on what's there — don't re-derive or re-propose something already decided against.
**Planning/design is the canonical, highest-value case** (pull `Decision`s incl. decided-against,
open `Roadmap`, `Directive`s, and the subject-relevant facts before you plan). The `UserPromptSubmit` hook
*nudges* you toward this on plan/design intent, but the judgment — and the retrieval — is yours;
don't wait for the nudge.

Before a consequential action, pull the relevant standing facts with **`facts_by_groups`**
and reason over them. Compose `[relation, target]` GROUPS — AND across groups, OR within each —
to narrow by **family** (`SubTypeOf()`), **scope union-up** (the `InScope` chain, §2), and
**subject** (`IsAbout() → <DeclaredSubjectType>()`), so you surface *only* what's relevant:

```
# directives relevant to setting up a benchmark run, in this scope:
# (assumes Benchmarking <: Interest is already declared)
loom_query(namespace="<resolved-store>_root", rule_name="facts_by_groups",
           args=[[ [["SubTypeOf()", "Directive"]],
                   [["InScope()", 'Project("coding")'],
                    ["InScope()", 'Workspace("development")'],
                    ["InScope()", 'Organization("example-org")']],
                   [["IsAbout()", 'Benchmarking()']] ]])
```

This returns just the benchmark-relevant directives, not
*every* standing directive — the subject group does the narrowing. Drop the subject group for
all in-scope directives; swap the family group for `["SubTypeOf()","Decision"]` / `"Goal"` /
`"CodeDoc"`. For fuzzy/subject relevance without an exact subject type, use the `loom_read_probe_bundle`
tool (it embeds your query text for you). Rank the returned set yourself (Importance + recency).

e.g. before running a process, pull `[["SubTypeOf()","Directive"]]` for your scope and check
for an "elevated/sandbox" order; before adding a feature, pull `[["SubTypeOf()","Decision"]]`
and check for a `decided_against`.

### 5b. Locate code fast — the **area map** (`AreaMap`)

Don't grep blind. Before searching the tree for *where* something lives, query the area map —
durable facts recording which subsystem / business-function lives in which file or dir:

```
loom_query(namespace="<resolved-store>_root", rule_name="facts_by_groups",
           args=[[ [["SubTypeOf()", "AreaMap"]],
                   [["InScope()", 'Repo("my-app")'],
                    ["InScope()", 'Project("coding")'],
                    ["InScope()", 'Workspace("development")'],
                    ["InScope()", 'Organization("example-org")']] ]])
```

Each `AreaMap` fact's content is `{area, where, note, sha}` — `where` is the file/dir, `note` the
non-obvious bit, `sha` the commit it was last verified at. **You** pull this before searching — the
hook does not pick a subject for you (it owns enforcement only; you own edge selection).

**Capture the area map as you learn the layout** — one `AreaMap` fact per subsystem, NOT a file listing:
- Record the NON-OBVIOUS mapping — where a name misleads ("the read engine lives in `reader.py`,
  not `rules.py`"), a responsibility split, "config X lives in dir Y". A mechanical `ls` is derivable
  from the tree — don't store it (the standing "no trivia derivable from code/git" rule applies).
- Keep it COARSE (area → file/dir + key entry points). Entity = `AreaMap("<area>")`; add your
  `['InScope()', 'Repo("my-app")']` (+ `Project`) scope edge and an `['IsAbout()', '<DeclaredSubjectType>()']`;
  put `{"area","where","note"}` in content, and carry the commit `sha` as an IDENTITY field of the
  `AreaMap` entity (so a refresh at a new commit is a DISTINCT canonical, not a dedup no-op).
- **Anchor to the commit `sha`** so staleness is detectable — a *wrong* map is worse than none. When you
  touch a file and find the map stale, save the new `AreaMap` (new `sha` → new fact) with a
  `['Supersedes()', '<old_fact_id>']` edge; the old stays as history, flagged not-current.

### 5c. Capture what code DOES — `Mechanism`

One step deeper than the area map: a `Mechanism` fact records **what a code unit does / the operating
principle (invariant, contract, ordering) it enforces** — anchored to file + commit `sha`. Content
`{principle, where, sha}`. It is distinct from the others: `AreaMap` = *where*, `Decision` = *why a choice*,
`BusinessContext` = *why it exists (domain)*, `Architecture` = *how it's built*, **`Mechanism` = *what it does***.

- Capture the **non-obvious principle/invariant**, NOT a code restatement — the code is the truth for the
  mechanics; the "no trivia derivable from code/git" rule applies hard. (Good: "the gate verifies *process*,
  never adjudicates applicability — because applicability is semantic." Bad: paraphrasing the function body.)
- Coarse grain (per mechanism/subsystem, load-bearing only); **SHA-anchored**; reviewed before save.
- **Staleness is the make-or-break** — behavior changes on every edit. Carry the `sha` as an IDENTITY
  field so a refresh is a distinct fact. When you change code a `Mechanism` fact describes and the
  behavior/invariant changed, save the new one (new `sha`) with a `['Supersedes()', '<old_fact_id>']`
  edge; the old stays as history, flagged not-current. A confidently-wrong `Mechanism` is worse than none.
  (An edit-time hook to flag/refresh stale `Mechanism` facts is on the roadmap.)

## 6. First run — bootstrap the store

On a fresh repo (an empty prime — `facts_by_groups` returns nothing in scope), seed it
from what already exists so the prime is useful immediately. Scan README / CLAUDE.md / docs / CI config;
propose the `Repo("<repo>")` + `Project("<project>")` identity and their `PartOf` chain (§1), an `AreaMap`
of the major subsystems (§5b), existing conventions as `Directive`/`Decision` candidates, and run recipes.
**Show the user the proposed facts and let them confirm/edit BEFORE any `loom_save`** — never seed garbage.

## Appendix — hooks: re-assert memory at the moment it helps

The skill above is pull-based (you call `facts_by_groups` proactively). To make memory
*re-assert itself* — defeating intra-session forgetting without relying on you to re-read —
configure the coding hook adapter. It dispatches on hook events and runs the same
`facts_by_groups` core for three jobs:

- **SessionStart** → prime: goals + top directives + open roadmaps for the
  scope (no subject narrowing; injects only).
- **UserPromptSubmit** → directives/decisions relevant to the stated intent (subject type inferred
  from the prompt); **plus**, on plan/design intent, a non-blocking nudge to consult Durmem for
  planning-relevant standing context before you act (you do the retrieval — see §5). Injects only.
- **PreToolUse** (`Bash`) → infers the subject type from the command and SURFACES the on-subject
  directives/decisions/recipes as **non-blocking** context (a standing prohibition is flagged
  `⚠ verify this applies` — you judge applicability; it does **not** auto-deny, because the hook
  can't tell whether a surfaced directive applies to *this* command). The single **deny** path
  is the **attestation gate** (ON by default; disable via `~/.loom/hooks.toml` `[injection] require_attestation = false`): a coarse must-check command
  (build/release/`git push`/`--paid`/…) must carry `# loom-checked: [[relation,target groups you
  queried]]` (or `# loom-unchecked: <reason>`).
- **PreToolUse** (every other tool) + **PostToolUse** (all tools) → advisory-only interception:
  `hook_action` is queried with `"<tool name> <command-or-capped-input-JSON>"`, so a trigger
  needle can match a tool name (`Edit`, `mcp__durmem__loom_write_user_files`), a file path, or any
  argument substring. Matches inject; nothing else runs (no topic ranking, no gate).
- **PreCompact** → **capture before compaction**: compaction is where session knowledge is silently
  lost, so preserve the full pre-compaction source and make its durable-knowledge sweep the first
  post-compaction action. Claude carries the instruction through its compaction summarizer. Codex
  ignores PreCompact stdout, so its adapter snapshots the documented `transcript_path` privately
  before history replacement; the following `SessionStart(source="compact")` injects the
  model-visible instruction to sweep that snapshot. Mode: `[capture] precompact` in
  `~/.loom/hooks.toml` — `off` (DEFAULT: skip capture) / `auto` (save silently) / `confirm`
  (numbered proposals, the user confirms before any save). In every harness, reconcile against existing facts and use
  the workspace-resolved store rather than assuming `default`.

  The generic advisory extension is `hook_action(event_kind, action_text, scope_json)`. The shipped root rule
  follows live `Has() -> HookTrigger(hook_type, needle)` edges from ordinary facts. `hook_type` is
  an exact hook event: `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `SessionStart`, or
  `PreToolUse:code-review`; `needle` is a case-insensitive literal substring or
  `|`-separated alternatives. Create the `HookTrigger` target first, then attach it with `Has()` to
  the fact whose type and content should be surfaced. For computed behavior, define the identical
  `hook_action` signature in the store's `user_rules.jl`; the user namespace shadows root, and the
  override may call `root.hook_action(d, event_kind, action_text, scope_json, when)` to compose with
  the defaults. `scope_json` is the JSON array of exact active scope-node expressions and must be
  forwarded unchanged so scoped triggers cannot leak into sibling repositories. Its output is only
  `{"inject":[String...]}`. It never feeds or weakens the attestation deny path. The superseded
  `HookPattern` entity is removed; do not create it or add a compatibility shim.

  **Auto-arm a trigger at capture time — YOU determine the surface and the keyword.** When you
  capture a fact that is *action-conditioned* — it matters at a specific future moment, not all
  the time — don't stop at scope/subject edges: decide the best surface and needle and attach the
  `HookTrigger` in the same capture, without being asked. Two questions determine both:

  1. **Surface (`hook_type`) — WHEN is the reminder actionable?** Pick the *earliest* moment it
     can still change behavior:

     | The fact matters when… | `hook_type` |
     |---|---|
     | the user *asks* about the subject (intent-level) | `UserPromptSubmit` |
     | the agent is *about to run* a matching tool/command (action-level) | `PreToolUse` |
     | a matching action *just ran* and a follow-up is owed (capture/verify-level) | `PostToolUse` |
     | a diff is being reviewed | `PreToolUse:code-review` |
     | always, for orientation | none — Importance + scope ranking already surface it at `SessionStart`; do NOT arm a trigger |

  2. **Keyword (`needle`) — what literal text will the action contain?** The needle is matched
     case-insensitively against `"<tool name> <command-or-args>"` for tool events and the raw
     prompt for `UserPromptSubmit`. Pick the most *discriminative* short substrings that will
     actually appear — command tokens, file paths, tool names — and OR alternatives with `|`.
     Too broad (`git`) fires on everything; too narrow (`docker build --platform=linux/amd64`)
     misses variants. 2–4 alternatives is the sweet spot.

     **Match the SUBJECT, never your NAME for the mistake.** A needle built from the words you
     would use to *describe* the error is dead on arrival: those words appear only in the verdict,
     which is available only *after* the judgment the trigger exists to prompt. Nobody types
     "please over-engineer this" or "here is some scope creep" — they type `add auth`, or
     `make the store tamper-proof`. So for a fact that says *don't build tamper resistance*, the
     needle is `auth|tamper` (what the request will literally say), NOT
     `over-engineer|scope creep|hardening` (what you would call it afterward). This is the failure
     that survives the too-broad/too-narrow check above, because a verdict-word IS short and IS
     discriminative — it just never occurs. Test it by writing the sentence that should fire the
     trigger, in the requester's voice, and grepping your own needle against it: if it does not
     match, the needle names your conclusion instead of their subject.

  Worked examples (two saves each — the trigger value-node first, edges are resolve-or-reject).
  They assume referenced scope nodes such as `Repo("my-app")` and the author's
  `GitUser` node already exist from repository bootstrap (§1); create any missing node first or
  omit that edge, because saves never create edge targets implicitly. These are ordinary facts,
  so §1a's author-attribution contract applies — every one carries `Author() -> GitUser(email)`:

  ```
  # Action-level: binary builds need the release checklist → command tokens
  loom_save(store='<store>', entity='HookTrigger("PreToolUse", "packagecompiler|juliac|--app-out")', content='{}',
            edges=[['Author()', 'GitUser("dev@example.test")']])
  loom_save(store='<store>', entity='Recipe("release checklist before binary builds")',
            content='Run the release checklist before any binary build.',
            edges=[['Has()', 'HookTrigger("PreToolUse", "packagecompiler|juliac|--app-out")'],
                   ['InScope()', 'Repo("my-app")'],
                   ['Author()', 'GitUser("dev@example.test")']])

  # Follow-up level: editing user rules requires a catalog re-read after → tool name + file path
  loom_save(store='<store>', entity='HookTrigger("PostToolUse", "user_rules.jl|loom_write_user_files")', content='{}',
            edges=[['Author()', 'GitUser("dev@example.test")']])
  loom_save(store='<store>', entity='Recipe("rule catalog refresh after rule edits")',
            content='After editing user rules, re-read user_rules.jl before the next loom_query.',
            edges=[['Has()', 'HookTrigger("PostToolUse", "user_rules.jl|loom_write_user_files")'],
                   ['Author()', 'GitUser("dev@example.test")']])

  # Intent-level: deploy questions must consult the runbook → words the user's prompt will contain
  loom_save(store='<store>', entity='HookTrigger("UserPromptSubmit", "deploy|rollout|rollback")', content='{}',
            edges=[['Author()', 'GitUser("dev@example.test")']])
  loom_save(store='<store>', entity='Directive("consult the deploy runbook before deploy work")',
            content='Read the current deployment runbook before any deploy/rollback work.',
            edges=[['Has()', 'HookTrigger("UserPromptSubmit", "deploy|rollout|rollback")'],
                   ['Has()', 'Importance("important")'],
                   ['Author()', 'GitUser("dev@example.test")']])
  ```

  One fact may carry several triggers (one per surface). Signals you chose WRONG: a needle that
  would fire on most actions means the fact is always-relevant — give it `Importance` + scope and
  let SessionStart ranking carry it; a reminder that keeps arriving after the moment it could help
  means the surface is too late — move it one row up the table (PostToolUse → PreToolUse →
  UserPromptSubmit).

  Scope is enforced at fire time: `hook_action` receives the session's active scope chain, and a
  trigger-tagged fact **with `InScope` edges fires only inside its own scope** (an unscoped fact
  is global). So the release-checklist example above cannot leak into a sibling repo sharing the
  same workspace store — scope your trigger facts exactly like any other fact. Also note the
  advisory-only paths (non-Bash PreToolUse, PostToolUse) run behind a small trigger-presence
  cache (~2 min TTL), so a freshly armed trigger can take up to that long to start firing there.

  ### Inspecting triggers: which fact is firing at me, and how do I find it?

  Sooner or later a directive keeps arriving that you want to audit, amend or retract, and you
  need its `fact_id`. There are two questions and they need **different** tools.

  **"What actually fires for this action?" — `hook_action` is the ONLY ground truth.**

  ```
  loom_query(namespace="root", rule_name="hook_action",
             args=["PreToolUse",
                   "make release",
                   '["Repo(\\"my-app\\")","Workspace(\\"loom\\")"]'])
  # -> {"inject": ["Directive: ...", ...], "queries": [...], "source": "root"}
  ```

  Pass the same `action_text` the hook would (`"<tool name> <command-or-capped-input-JSON>"`) and
  the real scope chain. Diff two calls — one with the needle text, one without — to prove which
  needle is responsible: an unrelated command returns `"inject": []`.

  Note `inject` returns **rendered strings, not fact_ids**, and `diagnostics` is usually empty. It
  tells you WHAT fires, never WHICH fact.

  **"Which facts carry triggers, so I can edit them?" — enumerate the edge.**

  ```
  loom_query(namespace="<store>_root", rule_name="facts_by_groups",
             args=[[[["Has()", "HookTrigger"]]]])
  ```

  Rows come back with `fact_id` plus `typed_labels` containing the full
  `HookTrigger({"hook_type":...,"needle":...})` canonicals, which is what you need to retract with
  `loom_forget` or re-point with `loom_add_edges`/`loom_remove_edges`.

  **⚠ These two do NOT always agree.** A fact can fire while structured queries omit it,
  for example when its edges are malformed. When they disagree, believe `hook_action`
  about what fires.

  Three retrieval paths that will ALSO fail to find such a fact, so don't conclude "it must live
  in another store" without checking:
  - `text_search` — matches `facts.content` only; misses anything whose searchable text is
    malformed or whose distinctive phrase sits outside the match.
  - `facts_by_groups` filtered by `IsAbout()`/`InScope()` — a fact saved with broken edges has
    none of those edges, so every scoped query silently excludes it.
  - the semantic bundle / `loom_read_probe_bundle` — a fact whose content is polluted (see below)
    embeds badly and scores under the 0.7 default-lane threshold even against near-verbatim query
    text.

  Also beware `content_truncated: true` on enumeration rows: grepping
  the returned `content` for a phrase buried deep in a long fact finds nothing even when the fact
  is right there in the result set. Match on `typed_labels` / the `Directive({"statement":...})`
  canonical instead, which is never truncated.

  **The failure mode that makes a fact unfindable-but-live.** If a `loom_save` is malformed such
  that the tool-call XML leaks into the content string, the fact is created with its *text* intact
  but its *edges never parsed* — content ending in a literal
  `</content><parameter name="edges">[["Has()", "Importance(\"critical\")"], ...]` is the
  signature. Such a fact keeps whatever edge did register (often the `HookTrigger`) and loses the
  rest, so it fires forever while being invisible to scope-, type- and similarity-based reads, and
  cannot be superseded by an ordinary newer fact because nothing links them. If you spot that
  signature in injected text, go straight to `hook_action` + the `Has()→HookTrigger` enumeration,
  and if the fact still cannot be reached, say so plainly rather than retracting something else by
  guesswork — `loom_forget` is destructive and a wrong retraction loses real memory.

  **A correct rule with no trigger loses to a stale rule that has one.** Recency and correctness do
  not win attention; only a trigger does. When you supersede a triggered directive, put the trigger
  on the replacement in the same save — otherwise the old one keeps arriving beside it and gets
  followed.

  **Exact placement (this is where the mistake keeps happening — read carefully):** the annotation
  must be a comment on the **LAST non-empty line of the whole command string** — i.e. the very
  last thing you type, trailing the actual command it covers, in the SAME Bash call. Putting it on
  a line *before* the command (a habit that looks natural — "note, then act") does **not** satisfy
  the gate and will be denied, even though it reads fine to a human. This is deliberate, not a bug:
  a leading annotation could "cover" a chain of commands typed after it, some of which were never
  actually checked (see the attestation gate). Right:
  ```bash
  git push origin main  # loom-checked: [[["SubTypeOf()","Directive"]],[["IsAbout()","Release()"]]]
  ```
  Wrong (silently rejected, NOT what you want):
  ```bash
  # loom-checked: [[["SubTypeOf()","Directive"]]]
  git push origin main
  ```
  Also wrong: the annotation sitting inside a heredoc body, or on an earlier line of a `&&`-chained
  multi-line command — only the literal last line is read. The gate verifies *process* (the
  `[relation, target]` pairs parse + their types exist, reason non-blank) and trusts your
  compliance decision — it never judges applicability.

See the installed hook configuration guide for `settings.json` wiring and environment variables. Keep injection hard-capped;
topic narrowing is mandatory for the PreToolUse
surfacing path (no subject match → no-op), and enforcement is the attestation gate, not keyword inference.
