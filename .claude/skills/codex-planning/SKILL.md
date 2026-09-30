---
name: codex-planning
description: "MANDATORY collaborative AI partner via the Codex CLI (`codex exec`, continued with `codex exec resume`). ALWAYS load this skill and engage Codex for any significant planning (not just complex - any non-trivial decision with tradeoffs), architectural choices, tradeoff analysis, code reviews, second opinions, and rubber-ducking. Engage Codex BEFORE finalizing a plan or review, not after."
---

# Codex CLI for Planning and Reviews

Codex is the collaborative AI planning partner via threaded conversations. Use it aggressively - not as a fallback, but as the default for any significant work.

Codex runs through `codex exec` in Bash. The Codex MCP server (`codex mcp-server`, `mcp__codex__*`) was removed in Codex CLI 0.154.0; do not try to use it.

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

Pick a thread directory under the scratchpad (one per thread), then start the thread. The prompt goes on stdin (`-`), so it can be long and needs no quoting.

```bash
T=<scratchpad>/codex/<topic>; mkdir -p "$T"
codex exec --json -s read-only --skip-git-repo-check -C "$PWD" \
  -o "$T/reply.md" - > "$T/events.jsonl" <<'EOF'
Help me plan...
EOF
jq -r 'select(.type=="thread.started").thread_id' "$T/events.jsonl" > "$T/thread_id"
cat "$T/reply.md"
```

`-s read-only` lets Codex read the repo at `-C` but not change it. Codex is a co-planner, not an implementer.

## Continuing a Thread

```bash
codex exec resume --json --skip-git-repo-check -o "$T/reply.md" \
  "$(cat "$T/thread_id")" - > "$T/events.jsonl" <<'EOF'
What about X vs Y?
EOF
cat "$T/reply.md"
```

The resumed thread keeps its original sandbox and working directory.

## Blocking vs Background

A Codex turn takes seconds to several minutes.

- Block (foreground Bash, `timeout: 600000`) when the next step depends on the answer - choosing an approach, validating a plan before implementing it.
- Run in the background (`run_in_background: true`) when there is independent work to do meanwhile - e.g. start Codex on a diff, do your own review pass, then read `reply.md` when the harness reports completion and compare findings.

## Best Practices

- Start threads before diving into implementation, not after.
- Keep threads focused - one topic per thread.
- Point Codex at files by path instead of pasting them; it can read the repo.
- Use multiple exchanges to refine ideas before committing to an approach.
- For code reviews, share the diff (or the base branch) and initial findings, then ask Codex to challenge them.
