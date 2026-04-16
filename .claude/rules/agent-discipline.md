# Agent Discipline

## Wait for all agents before synthesizing

When multiple agents are dispatched in parallel, do NOT present conclusions,
summaries, or recommendations until ALL agents have completed and reported
their results. If some agents are still running, say so and wait. Do not
present partial data as if it's the full picture.

If the user asks for status while agents are running, report which are done
and which are pending — don't synthesize.
