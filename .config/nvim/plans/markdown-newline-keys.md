# Markdown `<CR>` as typed keys

Replace the bullets.vim-backed insert-mode `<CR>` in markdown with our own Lua that returns keys from an `expr` mapping, so the result dot-repeats.

## Context

### The bug

`cw<CR><Esc>` on a list item or blockquote line splits the line correctly. `.` on another word only deletes the word. Reproduced in a tmux PTY (markdown filetype):

| Line | `cw<CR>` | `.` |
|---|---|---|
| paragraph, any position | splits | splits |
| list item, cursor on first word | splits | splits |
| list item, middle word | new bullet | deletes word only |
| list item, last word | new bullet | deletes word only |
| blockquote line | new `> ` line | deletes word only |

Dot-repeat replays the characters inserted during insert mode. Our wrapper in `lua/plugins/bullets.lua` splits with `nvim_buf_set_lines`, and bullets.vim's own end-of-line path adds the bullet with `append()`. Neither is recorded. The paragraph case works because bullets.vim falls back to `feedkeys("\<CR>")`, which is recorded.

### Experiment (2026-10-12)

With `-u NONE`, an `expr` insert mapping returning `<BS>…<CR>- <Cmd>lua …<CR>`:

- `cw<CR><Esc>` then `.` on another item: both lines got the new bullet. Redo register was `<BS><NL>- `.
- The `<Cmd>` ran once and was not recorded. A renumber hung on a `<Cmd>` therefore runs on the original keystroke, not on `.`.
- Headless `nvim_feedkeys(..., 'x')` processes expr-returned keys synchronously, so the behavior becomes testable in plenary. Today it is not: bullets.vim's queued `<CR>` never flushes under `'x'`, so the existing e2e newline spec passes only because every case avoids that path or asserts after `ensure_normal`.

Facts that the key strings rely on, all verified in a markdown buffer: `autoindent` on (runtime ftplugin), `backspace=indent,eol,start`, `expandtab`, `shiftwidth=4`, `smarttab`. `<CR>` with `autoindent` copies the current line's indent to the new line and drops leading whitespace from the moved tail. It keeps trailing whitespace on the head.

### Behavior to preserve

`tests/e2e/config/markdown_newline_spec.lua` is the spec for today's `<CR>`: bullet continuation at end of line and mid-line, nested indent, `1.` and `1)` numbering with renumber of the rest of the list, colon nesting, checkbox continuation as `[ ]`, multibyte split, plain newline when the cursor is inside the marker or quote leader, empty item deletion, blockquote continuation at depth 1 and 2 with and without the trailing space, and all of it inside a quote. `tests/e2e/config/bullets_mappings_spec.lua` covers `o`, `gN`, `<leader>x`.

### Behavior dropped or changed

- Alphabetic and Roman lists (`a.`, `IV.`). Not CommonMark; our `bullet_prefix` never recognized them for mid-line splits.
- Nesting after a trailing colon keeps the parent's marker instead of switching `-` to `*`. Tab indenting already keeps the marker, so this makes the two consistent. Only the ASCII colon nests; bullets.vim also recognized the full-width `：`.
- Renumbering runs on the typed `<CR>`, not on `.`. `gN` fixes a list after a replay.
- `o` no longer goes through bullets.vim. It becomes `A<CR>`, so it inherits every `<CR>` rule and dot-repeats. Counts (`3o`) are lost.

## Design

### `lua/config/lists.lua` (pure, unit-tested)

- `parse(body)` - `{ indent, marker, number, delim, checkbox, prefix }` for a CommonMark list item body (after any quote leader), or nil. Markers `-`, `*`, `+`, `N.`, `N)`. Checkbox `[ ]`/`[x]` optional.
- `next_prefix(item, opts)` - the prefix for the item that follows: same indent and marker, number plus one with the same delimiter, checkbox reset to `[ ]`. `opts.nest` adds one `indent_unit` and, for a numbered list, restarts at 1.
- `newline_keys(line, col)` - the key string for `<CR>` at byte `col` of `line`. Cases, in order:
  1. Cursor inside the quote leader or list prefix (`col <= #leader + #prefix`): `<CR>`.
  2. Item or quote with no text (body after the prefix is blank, nothing after the cursor): `<Cmd>lua require('config.lists').clear_item()<CR>`. `clear_item` strips one layer: the list prefix if there is one (`> - ` becomes `> `, `    - ` becomes ``), else the quote leader (`> ` becomes ``). A buffer edit, not keys: `<BS>` over indentation deletes a `softtabstop` worth at a time and `backspace=eol` would join lines, so the count is not predictable. Matches bullets.vim, which also edited the line directly here, so nothing is lost for `.`.
  3. Otherwise: if the tail after the cursor is nonblank, `<BS>` per trailing whitespace byte between the prefix and the cursor (at end of line the whitespace stays: two trailing spaces are a hard break). Then `<CR>`. Then the typed continuation: for a quoted line, the leader plus the body indent plus the marker part; for an unquoted line, only the marker part, since autoindent already copied the indent. `nest` is set when the head ends in `:`. For numbered lists append `<Cmd>lua require('config.lists').renumber()<CR>`.
- `renumber(lnum)` - renumber the ordered list block around `lnum`: contiguous lines sharing the quote leader, stopping at a blank line, a leader change, or a non-list line shallower than or equal to the item's indent. One counter per indent level, as bullets.vim does, so a nested ordered sublist is renumbered too and its counter resets when the walk returns to the parent level. Numbering starts at 1 (the existing spec expects `5. 8.` to become `1. 2. 3.`). The cursor line's cursor column shifts by the width change of its prefix so the insert point stays before the moved tail (`99.` to `100.` to `2.`). Edits from `<Cmd>` inside insert mode should join the insert's undo entry; a test asserts one `u` reverts the whole `<CR>`, and `undojoin` is the fallback if it does not.
- `clear_item()` - see case 2.
- Checkbox accepts any single character inside the brackets (`[x]`, `[X]`, `[ ]`), like today's `bullet_prefix`.

### Mappings (`after/ftplugin/markdown.lua`)

- `imap <buffer> <CR> <C-]><Plug>(config-lists-newline)`; the `<Plug>` is a global `expr` mapping returning `newline_keys(getline('.'), col)`. `<C-]>` expands a pending abbreviation first, as today.
- `inoremap <buffer> <C-CR> <CR>` - newline without a bullet.
- `nmap <buffer> o A<Plug>(config-lists-newline)`. Not `A<CR>`: that would pass through `<C-]>` and expand an abbreviation at the end of the line, which native `o` does not.
- Explicitly `setlocal autoindent`, since the key strings depend on it.

### `lua/plugins/bullets.lua`

Drop `<cr>` and `o` from `g:bullets_custom_mappings`, delete `insert_new_bullet`, `split_quote`, `newline`, `open_below`, and `bullet_prefix`. Keep `with_quote_stripped` for `gN` and `<leader>x`, which still run bullets.vim. Update the header comment and `CLAUDE.md`.

## Tests

Red first for every case: write it, watch it fail against the current code, then implement.

### `tests/unit/config/lists_spec.lua` - pure functions

Table-driven over `parse`, `next_prefix`, `newline_keys`: every marker, `9.` to `10.`, `1)`, checkbox checked and unchecked, nested by 2 and 4 spaces and by tab, quote depth 1 and 2, `>` without space, colon nesting, empty items plain, nested, quoted, quoted-list, cursor inside the marker and the leader, trailing whitespace of 0, 1, and 3 bytes, multibyte before the cursor.

### `tests/unit/ftplugin/markdown_newline_spec.lua` - behavior, no plugins

The existing e2e spec moves here unchanged except the colon-nesting marker if Tammer agrees, plus:

- Cursor row and column after each kind of split.
- Renumber: after a split, out-of-order list, stops at a blank line, skips a nested sublist, only the quoted list, not triggered for `-` lists, `1)` lists.
- Dot-repeat with `.`: `cw<CR>` on a middle word, last word, quoted paragraph, quoted item, nested item, numbered item (numbers replay literally), and `A<CR>text<Esc>` then `j.`.
- Hard break: `- one  ` with `<CR>` at end of line keeps both spaces.
- Empty items: plain, nested by spaces, nested by tab, quoted, quoted list; the previous line is untouched.
- Undo: one `u` after a numbered split restores the original buffer.
- Cursor after renumber: `99. one two` split before `two`, then type `X`, gives `2. Xtwo`.
- `o`: on an item, an empty item, a quoted paragraph, a plain paragraph, a numbered item.
- `<C-CR>` gives a plain newline on an item.
- An abbreviation before `<CR>` expands.
- Lines that are not lists are untouched: heading, paragraph, fence line, table row.

### `tests/e2e/config/bullets_mappings_spec.lua` - with plugins

Keep the `gN` and `<leader>x` cases. Add: our `<CR>` map is still the buffer's map after bullets.vim's FileType autocmd; `<CR>` with the cmp menu closed splits an item (cmp's fallback must evaluate the expr map); `<CR>` with the menu open confirms the item and does not split.

### PTY smoke (`tests/pty/newline-dot-repeat.sh`, `mise run test:pty`)

tmux-driven, two cases: `cw<CR>` then `.` on a list item's last word and on a quoted line. Reads the saved file. Not part of `mise run test`; run by hand before commit because it costs ten seconds and needs tmux.

## Steps

1. [x] Codex review of this plan. Taken: `<Cmd>` edit for empty items, keep hard-break spaces, nested renumber with cursor fix, `[X]`, `o` via the `<Plug>` not `<CR>`, PTY smoke down to two cases. Rejected: keeping bullets.vim's `o` (it would drift from `<CR>`), full-width colon.
2. [x] Colon-nesting keeps the parent marker (decided by Claude, flagged to Tammer).
3. [x] `lists_spec.lua` red, then `lua/config/lists.lua`.
4. [x] Move newline spec to unit, add new cases, red.
5. [x] Mappings in the ftplugin, strip `lua/plugins/bullets.lua`. Green (337 unit, 104 e2e).
6. [x] e2e cases for bullets.vim and cmp interplay. The menu-open case was dropped: cmp's menu does not open under headless `startinsert`, and that mapping is cmp's own, unchanged.
7. [x] PTY smoke script (`tests/pty/newline-dot-repeat`, `mise run test:pty`): list last word, list middle word, blockquote, abbreviation before Enter.
8. [x] `CLAUDE.md` section rewrite.
9. [x] Codex code review. Taken: indented quote leader doubled the indent (autoindent supplies it, so the typed leader drops its leading whitespace); checkbox limited to `[ ]`, `[x]`, `[X]`; renumber depth by display width; the renumber block stops at an item of another kind at the cursor's depth or shallower, so a `-` item or a `)` list ends it. Rejected: full-width colon (documented as dropped); `clear_item` at column 0 was already fixed by requiring `col >= #prefix`.
10. [x] `mise run test` (345 unit, 106 e2e), `mise run test:pty`, commits, push.

## Discoveries during implementation

- `<BS>` over pre-existing spaces with `softtabstop=4` deletes back to the previous stop, whitespace only. One `<BS>` per byte over-deleted into the text (`- one   two` became `- o`). `backspaces()` simulates Vim's `ins_bs` rule: `want = floor((vcol - 1) / sts) * sts`, delete whitespace until `vcol <= want`. Not modeled: with `sts < ts`, deleting a tab can overshoot and Vim re-inserts spaces. Markdown here has `sts = ts = 4`.
- `cw` on the last word leaves `- aaa ` with the cursor at end of line. The hard-break rule keeps that space. The old wrapper trimmed it. Accepted.
- Abbreviations only expand text typed in the current insert; an existing word before `A<CR>` never expands, so Codex's `o` concern could not happen either way. `o` still uses the `<Plug>` directly.
- Headless harness: `nvim_feedkeys` with `x` ends insert mode after each call, so a cursor check mid-insert needs typed text instead; `x!` hangs plenary; `set_buf` and the following insert share one undo block unless `let &undolevels = &undolevels` runs between them; an abbreviation plus `<CR>` in one batch makes insert mode read ahead so the expr mapping sees a stale line. Real typing and macros are unaffected (verified in tmux).

## Decisions

- 2026-10-12: option three over calling bullets.vim's script-local `s:next_bullet_str`. Own the list logic rather than depend on a private API.
