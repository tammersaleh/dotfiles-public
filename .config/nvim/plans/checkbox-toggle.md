# Own `<leader>x` and remove bullets.vim

## Context

bullets.vim is left with two jobs: `gN` (renumber, unused) and `<leader>x` (toggle checkbox). Its nested toggle rewrites the character after `- [` on every child item, checkbox or not, so `- [Link](url)` became `- [xink](url)`. The current workaround in `lua/plugins/bullets.lua` snapshots the buffer and restores non-checkbox lines. `<CR>` and `o` are already ours (`lua/config/lists.lua`), with `parse` and `checkbox_row` doing the list parsing and the ancestor walk.

## Semantics

- Scope is a contiguous block of list items sharing the cursor line's quote leader. A blank line, non-list text (including indented continuation text), or a leader change is a boundary in both directions.
- Target row: the cursor row when its body is a checkbox item, else its parent item when that has a checkbox. The parent is the first shallower item, reached only through sibling items and their descendants. No target means `<leader>x` does nothing and does not replace the `.` command.
- Toggle `[ ]` to `[x]`, `[x]` or `[X]` to `[ ]`. Markers `-`, `*`, `+`, `N.`, `N)` all count (bullets.vim only handled unordered).
- Children: every descendant of the target that is a checkbox item takes the new state. Non-checkbox descendants are untouched, so `- [Link](url)` is safe.
- Parents: consecutive checkbox parents are recomputed, stopping at the first plain parent. A checkbox parent is checked when all of its direct checkbox children are checked. Plain child items and their subtrees do not count.
- bullets.vim with two markers checked the parent when any child was checked (`ceil(checked / n)`). That changes on purpose.
- Cursor stays. The whole change is one undo step.
- Dot-repeat: the `<Plug>` is an `expr` map that sets `operatorfunc` and returns `g@l`. `.` reuses the global `operatorfunc`, so another custom operator used in between takes over `.`; accepted.
- Markdown only. The slack ftplugin reuses markdown's and deletes the map (Slack has no checkboxes, Trouble keeps `<leader>x` there). `text` and `gitcommit` lose `<leader>x` and `gN`, which bullets.vim had enabled there.

## Codex review

Taken: no-target preflight so `.` is not replaced, slack keeps Trouble's `<leader>x`, undo and end-of-line tests, wording for plain parents and plain subtrees. Rejected: dropping the `toggle_checkbox_operator` wrapper (`operatorfunc` passes the motion type, the wrapper keeps `toggle_checkbox(row)` testable), filetype guard in markdown.lua (slack.lua already deletes markdown-only maps, so follow that).

## Steps

1. [x] Unit tests for `lists.toggle_checkbox` (red).
2. [x] E2E tests: `<leader>x` in markdown, quotes, link children, dot-repeat; drop `tests/e2e/config/bullets_mappings_spec.lua` cases that pin bullets.vim (`gN`, indent operators).
3. [x] Implement `toggle_checkbox` in `lua/config/lists.lua`, map in `after/ftplugin/markdown.lua`.
4. [x] Delete `lua/plugins/bullets.lua`, remove from `lazy-lock.json`, update `CLAUDE.md` and the blockquote.lua comment.
5. [x] Codex review, `mise run test`, `mise run test:pty`, commit, push.
