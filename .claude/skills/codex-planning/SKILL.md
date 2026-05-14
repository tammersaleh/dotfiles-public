---
name: codex-planning
description: "MANDATORY collaborative AI partner via Codex MCP. Use mcp__codex__codex to start a thread and mcp__codex__codex-reply to continue. ALWAYS load this skill and engage Codex for any significant planning (not just complex - any non-trivial decision with tradeoffs), architectural choices, tradeoff analysis, code reviews, second opinions, and rubber-ducking. Engage Codex BEFORE finalizing a plan or review, not after."
---

# Codex MCP for Planning and Reviews

Codex is the collaborative AI planning partner via threaded conversations. Use it aggressively - not as a fallback, but as the default for any significant work.

## When to Use Codex

Engage Codex for:

- Any significant planning - not just complex implementations. Any non-trivial decision with tradeoffs counts.
- Architectural decisions and design choices.
- Code reviews - get a second opinion on issues identified, and let Codex challenge findings.
- Exploring tradeoffs between approaches.
- Rubber-ducking problems to find gaps in thinking.
- Second opinions on anything before delivery.

Before committing to an approach, writing a non-trivial chunk of code, or delivering a review, ask: did I engage Codex? If not, do it now.

## Starting a Thread

Use `mcp__codex__codex` to start a new conversation:

```
mcp__codex__codex(prompt: "Help me plan...")
```

Returns a `threadId` and initial response.

## Continuing a Thread

Use `mcp__codex__codex-reply` with the `threadId` to continue:

```
mcp__codex__codex-reply(threadId: "...", prompt: "What about X vs Y?")
```

## Best Practices

- Start threads before diving into implementation, not after.
- Keep threads focused - one topic per thread.
- Share relevant code snippets or requirements as context.
- Use multiple exchanges to refine ideas before committing to an approach.
- For code reviews, share the diff and initial findings, then ask Codex to challenge them.
