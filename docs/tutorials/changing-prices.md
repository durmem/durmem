# Track values that change

<!-- loom-doc: slug=changing-prices; audience=both; section=tutorials -->

Keeping a precise history is a major advantage of Durmem over a typical agent memory system
that uses unstructured text.
When changes are scattered across prose notes, reconstructing what changed, when it changed, and
which earlier statement it replaced takes work. Durmem's typed records and relationships connect
those updates explicitly, so agents can follow the history and query it reliably.

Durmem supports **bitemporal history**: it distinguishes when something applied from when it became
known. A price might rise in May, but you might not learn about it until July. Both dates matter:
one tells you the actual cost in June; the other explains the estimate you made at the time.
This distinction is essential in financial time-series modeling when an analysis must use only
information available at a past date. See [Bitemporal history in the glossary](../reference/glossary.md).

This tutorial shows how Durmem keeps the history of changing information. You will record monthly
costs, update a price that changed, correct an earlier mistake, and ask what was known at different
times.

## Before you start

Finish [Quickstart](../guide/quickstart.md), open the `palmerpenguins` repository, and confirm that
`[demo]` is the session default store.

## 1. Check for a reusable type

Suppose your project uses several paid services and you want to track its monthly spending.
You need to keep each service's cost up to date, calculate the total, and explain how that total
has changed. We will use AWS, OpenAI, Cursor and Vercel as fictional expenses for this exercise.

To compare service costs, give each record the same fields: the service name, monthly cost and
date the price applies. A type defines that common shape. In this example, `PaidService` belongs
under the general `Resource` type and has `name`, `monthly_cost` and `asof` fields. Ask the agent
to reuse a suitable type if one exists, or create a new type.

**Tell your coding agent:**

> I want to keep track of paid services and what they cost each month. Do we already have a type
> for that? Show me what it records, and suggest one if we need it.

Review the proposed type and its fields before saving the example records. If that name already
describes something different in your store, ask the agent to resolve the conflict with you.

## 2. Save and check the synthetic baseline

You can learn about a price change after it has already taken effect. Durmem can keep both dates:
the example's `asof` field says when the price applied, and `known_from` says when you learned
about it. Those dates will let you ask different historical questions later.

Start with four costs that were both known and effective on April 1, 2026.

**Tell your coding agent:**

> These are our monthly costs, all effective and known from April 1, 2026. Can you check which
> ones we already have, add any that are missing, and tell me the monthly total?
>
> | name | monthly_cost | asof |
> | --- | ---: | --- |
> | AWS | 340 | 2026-04-01 |
> | OpenAI | 120 | 2026-04-01 |
> | Cursor | 60 | 2026-04-01 |
> | Vercel | 20 | 2026-04-01 |

## 3. Record a value that changed

Suppose that Cursor's cost was once 60 and later changed to 96. A replacement keeps
the earlier value as history because it was once true.

**Tell your coding agent:**

> Cursor’s monthly cost changed from 60 to 96, effective May 20, 2026. We learned
> about it on July 1. Can you record the price change with both dates?

The new total is **576 per month**, using Cursor's new cost of 96. Ask the agent to show the earlier record
too: its value of 60 should remain in the history, linked to the replacement rather than counted
as another current expense.

## 4. Correct a claim that was never true

In the same invented scenario, Vercel was never 20; the correct value was 25 from April 1. That
is a correction, not a normal price change. Preserve the false claim and mark it as false rather
than deleting it.

**Tell your coding agent:**

> I got the Vercel cost wrong in our example: it was 25 per month from April 1, 2026, not 20. We
> found the mistake on July 2, 2026. Can you correct the record while keeping a note of what was
> wrong, and update the total?

The current total becomes **581 per month**. The correction should point to the earlier Vercel
record and identify its value of 20 as a mistake. This preserves why an older answer might have
used that value without continuing to treat it as true.

## 5. Ask two historical questions

“What did we know by June 1?” and “What do we now believe applied on June 1?” are different
questions. Durmem's bitemporal storage allows correct answers to both, while prose-based agent
memory often struggles:

**Tell your coding agent:**

> What did we know about these costs by June 1, and what do we now think the costs actually were
> on June 1? Show me how you worked out each total.

With the dates above, the first answer is **540 per month**: neither the Cursor increase nor the
Vercel correction was known by June 1. The second is **581 per month**: later information tells
us what applied on that date. Ask the agent to show the records behind both totals so you can
follow how the dates change the answer.

Continue with [Turn repeated work into a server-side function](reuse-a-question.md). The
[Glossary](../reference/glossary.md) defines the memory terms used here.
