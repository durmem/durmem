# Five-minute quick start
<!-- loom-onboarding-surface: post-setup -->

Complete the two actions in [INSTALL.md](INSTALL.md), follow setup's
restart summary, and open a new or reloaded coding-agent session.

## Inspect your stores

Ask your agent:

```text
List my durmem stores and describe which store is the default.
```

Store names are local configuration names. Setup
preserves existing named bindings and does not silently change the default
store.

## Use durmem in a repository

Open a project and ask:

```text
Use durmem coding memory for this repository. Check existing project decisions
before making a plan.
```

After recording one real project decision, start another session in the same
repository and retrieve it before planning. Do not test with credentials or
other secrets. If anything fails, see [Troubleshooting](TROUBLESHOOTING.md).
