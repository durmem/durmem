# Durmem: one memory for all your agents

<!-- loom-onboarding-surface: first-time -->

## What is Durmem?

Durmem combines durable shared memory with a simple, robust built-in Kanban, so agents across
computers and harnesses can work together to deliver complex, long-running tasks reliably. Save
project goals, decisions, instructions and findings once, so connected agents can recall them in
later sessions. Relevant reminders help long-running agents stay on course. Shared knowledge
reduces repeated explanations, rediscovery and rework, saving time and tokens.

Start with the free hosted tier (five stores, 200 MB): [Install](INSTALL.md). Need help?
[Ask in the Issues tab](https://github.com/durmem/durmem/issues).

## Fully automated multi-agent pipeline

Connect specialist agents across computers, operating systems and harnesses. Agents pass work,
decisions and evidence through a shared Kanban board. You set the goals, permissions and approval
checkpoints; the agents carry work through the pipeline.

## Shared knowledge. Clear boundaries.

Each team's store holds its own knowledge and instructions. Agents connect only to stores they
are authorized to use, sharing the context they need while keeping private knowledge separate.

## See how Durmem changes agent work

Durmem organizes reusable knowledge, brings reminders into context when needed, and keeps
important guardrails available before an agent acts. Agents can reuse computations for repeated
questions, build on another agent's findings, recognize updated decisions and resume unfinished
work in a new session. See the [worked examples](https://durmem.ai/#action) on the website. Durmem is built
with Durmem; read the [case study](https://durmem.ai/case-study) for the real project.

## Validate Durmem on real memory benchmarks

Published evaluations cover consistency when facts change (STALE), recall across long histories
(LongMemEval), and memory over real agent activity (AMA-Bench). The
[benchmark details](https://durmem.ai/benchmarks) explain the cohorts, methods and comparisons.

## Flexible plans

The free hosted tier includes five managed stores and 200 MB of total storage, with no per-agent
limits and encryption at rest. Teams that
want full control of their data and access can [contact Durmem](mailto:info@durmem.ai) about
self-hosting Durmem on their own network. For help with bugs or setup, use the Issues link below.
See [current plans](https://durmem.ai/#pricing).

## Start in minutes

<!-- loom-first-time-onboarding:start -->
1. **Install the shared Durmem CLI.** Use the secure installer for your operating system to
   install the user-level command. See [Install](INSTALL.md) for the terminal commands.
2. **Run durmem setup once.** Claude Code, Codex and OpenCode are detected, with all selected by
   default; opt out before setup begins to configure them. Setup completes authentication,
   asks for Terms and Privacy consent, finishes provisioning and will verify each harness.
   A partial failure stays visible in the result summary. Follow the restart instructions.
   Setup is idempotent; a conflict is preserved for explicit disposition. If it reports
   **no supported harness detected**, install or start a supported harness and rerun setup.
<!-- loom-first-time-onboarding:end -->

Using Meta's Muse or OpenAI's Dot? Ask the assistant to read its setup page:
[Meta's Muse](docs/guide/connect-muse.md) or [OpenAI's Dot](docs/guide/connect-dot.md). It runs the setup and asks you for the emailed sign-in code.

## Documentation

- [Install](INSTALL.md)
- [Documentation home](docs/README.md)
- [Get started: Quickstart](docs/guide/quickstart.md)
- [Tutorials](docs/tutorials/index.md)
- [Reference](docs/README.md#reference)
- [Kanban](docs/kanban/what-is-kanban.md)

## Issues and feedback

Please report bugs and share feedback in this repository's
[Issues tab](https://github.com/durmem/durmem/issues). If Durmem helps you, star the repository
so others can find it.
