# Why Durmem
<!-- loom-doc: slug=what-is-durmem; audience=both; section=guide -->

One of the most common complaints about today's coding agents is that they forget too much and
too fast.
As conversations grow or sessions change, important details can fall out of an agent's active
context. Without durable memory, project goals and earlier decisions have to be explained
again and again, and a long-running agent can lose direction and go off track.

Durmem preserves reusable project knowledge: goals, decisions, instructions and guardrails,
findings, and planned work. When a coding agent connects to Durmem, it can
bring relevant saved knowledge into the agent's context at session start and before relevant
actions, so important decisions and instructions stay fresh in the agent's context while work
continues.

Durmem helps prevent repeated explanations, rediscovery, and rework caused by missed findings,
decisions or instructions. This reduces repeated model work and can save a significant number of tokens for
long-running agents.

## How it works

A Durmem store is a database on the server that all connected agents can access. It holds the memories an
agent chooses to keep. Multiple AI agents connected to the same store can see each other's updates
through the store, enabling them to share findings and coordinate in real time.

## Durmem and the Loom engine

Durmem is the product. Loom is the memory engine behind Durmem. In your coding harness, Loom tools
are named `loom_*`, and Loom skills are named `loom-*`.

> **Hosted:** durmem.ai runs the engine for you. Your harness connects to the service, so you can
> start using Durmem without installing or managing a server. Teams that want full control over
> their data can contact [info@durmem.ai](mailto:info@durmem.ai) about a private
> installation.

> **Private install:** Your team runs and manages the Durmem server inside its own network,
> controlling how its data is stored, accessed, and protected.

## Data security

Saved memories can contain valuable project knowledge. Choose which agents and people have access
to each store, and use a private server when your team needs full control of its data. See
[Security and privacy](security-and-privacy.md) for how Durmem stores and protects data and what
changes when you host it yourself.

## Next

Start with the [Quickstart](quickstart.md) to install Durmem, connect your agent, and save project
knowledge for use in a later session.
