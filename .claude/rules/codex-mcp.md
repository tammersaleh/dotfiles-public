# Codex MCP for Collaborative Planning

Codex MCP provides a collaborative AI planning partner via threaded conversations. Use it for thinking through problems before committing to an approach.

## When to Use Codex

- Planning complex implementations before writing code
- Exploring tradeoffs between approaches
- Rubber-ducking problems to find gaps in thinking
- Getting a second opinion on architectural decisions

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

- Start threads for planning before diving into implementation
- Keep threads focused - one topic per thread
- Share relevant code snippets or requirements as context
- Use multiple exchanges to refine ideas before committing to an approach
