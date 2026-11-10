---
name: loom-query
description: Read discipline for Durmem - retrieve the most relevant facts from the memory store, test the question's premise against current truth, reconcile contradictions by timeline, honor retractions/disputes, and answer only from the latest consistent state. Load when answering a question, making a recommendation, or reading the user's state from memory. Pairs with loom-capture (write side).
---

# Durmem — query discipline

The Durmem tool descriptions cover the memory mechanics (`loom_query`,
`loom_read_probe_bundle`, labels, seed rules). This skill
is the judgment layer: how to retrieve and reconcile so the answer reflects
current reality.

## Fetch your active discipline (do this first)

The full read discipline is composed by the memory server per use case, not hard-coded
here. Before answering, fetch it and follow it verbatim:

```
loom_query(namespace="<resolved-store>_root", rule_name="compose_prompt",
           args=[<domain>, "OrganizationHierarchy", "prod"])
# → {"capture": ..., "read": <the discipline to follow>}; use the "read" half.
```

For an MCP call, make the selected store explicit as
`namespace="<resolved-store>_root"`; `args` contains exactly the three middle
arguments shown, while the server supplies `dbpath` and appends `when`. The bare
`"root"` namespace is the compatibility spelling for the already-selected default
store. A ZMQ-direct client instead selects the store in its connection bundle
and therefore passes the tier name `"root"` to `.query(...)` as shown below.

Pick `<domain>` to match the memory you're reading (compose domains carry the
`*Domain` suffix — they are prompt-composition axes, distinct from fact-label roots
like `Record`; an undeclared name silently composes an EMPTY discipline):

- **`PersonalDomain`** — a person's life/work state (the default for an assistant).
  Carries the premise-falsification, binding-constraint, and cross-domain-cascade
  reconciliation discipline.
- **`LogDomain`** — an append-only history/log/trajectory: look records up by exact
  key (step/turn index), enumerate full sequences for count/list questions, and
  do **not** reconcile log entries against each other.
- **`CodingDomain`** — coding sessions (see loom-coding), or a project subtype
  declared under `Domain` — inherits the universal read core.

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
database-specific adapters. Use the `"read"` half. MCP or ZMQ are the supported integration
paths. The returned text **is** your read discipline for this turn — follow it; the
points below are the irreducible core so you are never reading blind.

## Irreducible core (always true, even before the fetch)

- **Seek current truth, not confirmation.** Treat the question as search clues,
  not assumptions. If a question carries a premise ("since I still…", "given
  that…"), run a premise-falsification pass: newer concrete facts and dispute
  edges can reject an old premise without a formal retraction.
- **Retrieve bounded and meaning-driven.** Choose a small related label set
  (direct + dependency + newer-state labels); use `loom_read_probe_bundle` with
  per-label questions. Never dump `Label`/whole-store. For date-decided questions,
  gate the bundle with `since`/`until`.
- **`current_facts` is the authoritative current state** (already excludes
  retracted/disputed). Retracted, disputed and superseded facts appear only in `stale_context`
  (a retracted one has `current_status` `retracted` and `why_included` `retracted_support`); they
  are not hits. Use `stale_context` only to explain why a premise changed.
- **Reconcile by timeline:** later `known_from` wins (ties by observation order);
  a fact flagged `disputed_target` is not current — a live `Dispute`/`Negates` edge
  (adversarial: contested/false) OR a live `Supersedes` edge (non-adversarial: the
  newer fact replaces it) points at it. Follow the fact that holds the edge.
  Be decisive; don't hedge to "unknown" once a newer fact resolves the state.
- **Ground the answer** in the facts you used; abstain when memory has nothing.

For the full retrieval loop, the cross-domain cascade table, and the
refuse-the-escapes rules, **use the fetched discipline.**
