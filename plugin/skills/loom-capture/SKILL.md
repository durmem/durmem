---
name: loom-capture
description: Write discipline for Durmem - extract state claims from user utterances, save attribute-rich facts (one entity sortal + [relation,target] edges), retrieve related facts before saving, and maintain consistency by retracting or disputing contradictions. Load when ingesting, saving, recording, or remembering observations into the user's memory. Pairs with loom-query (read side).
---

# Durmem — capture discipline

The Durmem tool descriptions cover mechanics (entity/relation types, `loom_save`, `loom_forget`,
`loom_query`, `loom_read_probe_bundle`, rule loading). This skill is the judgment
layer: what to save and how to keep the fact store consistent.

## Fetch your active discipline (do this first)

The full, **use-case-specialized** capture discipline lives in the memory server as a
composable rule, not hard-coded here — so a personal-assistant memory and an
append-only agent/record memory each get the right instructions instead of one
bloated prompt. Before capturing, fetch it and follow it verbatim:

```
loom_query(namespace="<resolved-store>_root", rule_name="compose_prompt",
           args=[<domain>, "OrganizationHierarchy", "prod"])
# → {"capture": <the discipline to follow>, "read": ...}; use the "capture" half.
```

For an MCP call, make the selected store explicit as
`namespace="<resolved-store>_root"`; `args` contains exactly the three middle
arguments shown, while the server supplies `dbpath` and appends `when`. The bare
`"root"` namespace is the compatibility spelling for the already-selected default
store. A ZMQ-direct client instead selects the store in its connection bundle
and therefore passes the tier name `"root"` to `.query(...)` as shown below.

Pick `<domain>` by what you are storing (compose domains carry the `*Domain`
suffix — they are prompt-composition axes, distinct from fact-label roots like
`Record`; an undeclared name silently composes an EMPTY discipline):

- **`PersonalDomain`** — a person's life/work state from conversation (decisions,
  residence, health, preferences, relationships, schedule). The default for an
  assistant. Carries the binding-constraint + reconciliation discipline.
- **`LogDomain`** — an append-only history/log/trajectory (agent tool-call steps,
  transaction logs, move lists). Captures every entry losslessly and in order;
  log entries do not conflict, so the personal reconciliation pass is dropped.
- A project-specific subtype the user declared under `Domain` (e.g. `Chemistry`)
  — you inherit `Domain` (universal) + the subtree above it.

Non-MCP callers (a ZMQ-direct harness) call the SAME rule via the endpoint-only client:

```python
ZmqLoomClient(
    config_path=None,
    store_name=None,
    call_timeout_s=60.0,
    startup_timeout_s=120.0,
    conn={"LOOM_ZMQ_ENDPOINT": "tcp://host:port", "LOOM_STORE": "store"},
).query("root", "compose_prompt", [<domain>, "OrganizationHierarchy", "prod"])
```

`conn` is a resolved `LOOM_*` connection bundle; omit it to resolve `config_path` (or the
user-wide config). Use the current connection object rather than legacy positional or
database-specific adapters. Use the `"capture"` half (pass a `version` tag in place of
`"prod"` for an A/B prompt). MCP or ZMQ are the supported integration paths. The returned
text **is** your capture discipline for this turn — follow it; the points below are only
the irreducible core so you are never operating blind.

## Irreducible core (always true, even before the fetch)

- **Capture current state, then preserve consistency.** `save` is append-only and
  notices nothing; truth-maintenance is your job. Every save should make the
  active store more internally consistent, not just append a possibly-conflicting
  claim.
- **Save durable state** a future reader could ask about — from either speaker —
  losslessly: keep concrete specifics (when/who/where/how much/how long/why) and
  any verbatim record/log values; never summarize away a value.
- **Proposed or future work** (a plan, change request or follow-up not done yet) is a
  `Roadmap` item with `Status` and `Importance`, one per item, never a `Project` (a scope
  node); see **loom-coding**, "Roadmap and Milestone lifecycle", for the exact save.
- **Reconcile before/after saving** against *retrieved* prior facts (not your
  in-context recollection): retrieve related facts, then resolve each conflict by
  a `["Negates()", <old_fact_id>]` edge on the superseding save (hard semantic
  retraction — moved/sold/quit/ended; old fact kept as history, flagged not
  current), a `["Dispute()", <old_fact_id>]` edge (soft, adversarial — the old fact
  is probably stale/contested), or a `["Supersedes()", <old_fact_id>]` edge
  (NON-adversarial — the new fact replaces/enriches the old, which stays as valid
  history, not contested). All three flag the old fact not-current on reads. Reserve
  `forget` for data-entry errors only. Don't leave a known contradiction active.
- **A concrete, domain-specific entity sortal per fact** (never a bare
  root/abstract type). Reuse an existing type before minting a near-synonym.
  Call `loom_nearest_types(store, text)` before minting, but treat its output as
  a candidate list to judge, not an oracle. Ranking is by `neighbors` count
  first and `max_similarity` only as the tie-breaker, so a numerous weak cluster
  can outrank a sharper match. Cross-read BOTH fields for each candidate; when
  the count-ranked leader does not have the best similarity, cross-check
  `loom_query(..., rule_name="list_types")` for the full catalog and type
  descriptions before choosing reuse versus a genuinely new sortal.

## Minimal storage shape

```
loom_save(
  store='default', content='{}', entity='SpanishStudy()'  # create edge target first
)
loom_save(
  store='default',                              # REQUIRED first arg — the target store (loom_list_stores)
  content='{"claim":"...","attributes":{...}}',
  known_from='YYYY-MM-DD',
  entity='RelevantType("...")',                 # the ONE sortal — drives the embedding
  edges=[['IsAbout()', 'SpanishStudy()']],      # [relation,target] edges (0+); subject → a DECLARED concrete type (e.g. SpanishStudy <: Interest) — no freeform catch-all
  source_text='<verbatim user utterance>'
)
```

Declaring a type does not create any node instance. Every canonical edge target must
already be live, so explicitly save subject, scope, author, and other value nodes before
the facts that reference them. In `loom_save_many`, put those node saves earlier in the
batch. The only schema-seeded canonical targets are the three `Importance` levels; public
A `Label` is normally an edge TARGET, not a fact's entity — but saving one as the entity is allowed,
and is the ONLY way to create an open-vocabulary handle such as `KanbanTaskRef` before an edge can
point at it. Fact-reference relations still target a live `fact_id`.

For declaring entity/relation types, the full data-type/edge/reconciliation rules, and
the structured-output `conflict_checks` contract, **use the fetched discipline.**
