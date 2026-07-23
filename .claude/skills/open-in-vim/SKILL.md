---
name: open-in-vim
description: >-
  Open a file for Tammer to edit in his wrapping nvim, as a split. Triggers when
  Tammer says "let me edit that", "v that for me", "open that in vim", "open in
  nvim", "open it as a split", or otherwise wants a file put in front of him to
  edit by hand rather than having Claude edit it. Only works inside an nvim
  :terminal.
---

# Open a file in Tammer's wrapping nvim

When Tammer wants to edit a file himself, open it as a split in the nvim that
wraps this terminal session. Do not edit the file yourself; hand it to him.

## Run

```bash
~/.claude/skills/open-in-vim/v-open <path> [path...]
```

`v-open` is a guarded wrapper around `v`. It checks `$NVIM` first:

- `$NVIM` set (running inside an nvim `:terminal`): it calls `v`, which uses
  `nvr -o` to open the files as splits in the parent nvim. Exits cleanly, no
  output.
- `$NVIM` unset: it refuses and exits non-zero. Never call plain `v` in that
  case - outside nvim `v` launches a new blocking `nvim` that hangs the agent
  shell.

## When it refuses

If `v-open` exits non-zero saying `$NVIM` is unset, you are not in Tammer's
wrapping nvim. Tell him, and edit the file with the normal Edit/Write tools
instead.

## After opening

Pass absolute paths. The command produces no output on success - the split just
appears in Tammer's nvim. State that the file is open and stop; do not also edit
it unless he asks.
