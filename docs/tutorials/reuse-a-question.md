# Turn repeated work into a server-side function

<!-- loom-doc: slug=reuse-a-question; audience=both; section=tutorials -->
When your agent keeps doing the same calculation, it can save the method as a reusable server-side
function and call it with new inputs instead of reconstructing it each time. A server-side function
completes the calculation on the Durmem server and returns only the results to the agent, which can
be a lot more efficient in token consumption. This tutorial turns a penguin count into a server-side function,
checks it against the data and uses it from a fresh harness session.

## Before you start

Finish [Quickstart](../guide/quickstart.md) and continue with `palmerpenguins` and `[demo]`.

You can use your own project instead: choose a calculation you repeat often.

## 1. Establish a reproducible baseline

Use one exact data snapshot so the function and independent calculation can be compared. A moving
branch name by itself is not a fixed snapshot.

**Tell your coding agent:**

> Can you count the Adelie penguins on Torgersen from the public dataset? First make sure we’re
> using a fixed copy of the data, then tell me how you counted and what you got.

Keep the source commit, the filter and the count the agent reports. You will compare the saved
function with a separate calculation from that same data, so both need to use the same revision.

## 2. Propose a function for the method

The useful part to save is the method, not the answer to one count. A function such as
`count_penguins(species, island)` takes the species and island as inputs and calculates from the
chosen dataset. Ask the agent to check for an existing function before proposing a new one.

**Tell your coding agent:**

> We keep doing this count. Could you turn it into a reusable server-side function that works for any species and
> island, not just this one result? Show me how it would work and where it would run before you
> make the change.

Review the inputs, calculation and data source together. Once you are happy
with the proposal, approve it and ask the agent to install the function.

## 3. Check the function against independent calculations

After approval and installation, use at least two pairs from the same snapshot. Calculate each
pair independently from the source to validate the calculation:

**Tell your coding agent:**

> Can you try the function for Adelie on Torgersen and Gentoo on Biscoe? Please check both answers
> against the same data we used before and show me how they compare.

The two function results should match the independent counts. If they differ, ask the agent to
trace the input data and filters before using the function for other questions.

## 4. Find and use it in a fresh session

Open a fresh harness session in the same repository and select `[demo]`. You can use another
harness or computer connected to the same account and server. Ask the new agent to find and call
the saved function:

**Tell your coding agent:**

> In this fresh session, can you use the penguin-count function for Chinstrap on Dream and tell me
> what you find? Please use [demo] again for this session.

The new agent should find and call the saved function. Its response should show the call and result,
demonstrating that the method is available beyond the session where you created it.

## 5. Decide whether to keep it and consolidate a repeated memory question

After trying the function, decide whether it is useful enough to maintain. Keep its data source and
execution needs in mind as well as the calculation itself. If you retire it later, ask the agent
to check its callers and use the supported function lifecycle.

The same idea applies to repeated questions about saved memories: an agent can give a recurring
query a name and reuse it. If you have a project-memory question you keep asking, try this:

**Tell your coding agent:**

> I keep asking this question about the project: [replace this with a question you have actually
> asked more than once]. Is there a simpler way to get the same saved information? Show me your
> idea before changing anything.

The agent should show an existing query or propose one that returns the records you need.
After approving a new query, compare its result with a direct read of those project memories.
That checks that the reusable query answers the same question.

For the surrounding project workflow, see [Manage a project](manage-a-project.md). For memory
terms, see the [Glossary](../reference/glossary.md).
