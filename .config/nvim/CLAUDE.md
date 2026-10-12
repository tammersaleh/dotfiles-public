# Neovim Config

Lazy.nvim-based config. Plugin specs in `lua/plugins/`, config modules in `lua/config/`, filetype overrides in `after/ftplugin/`.

## Directory structure

This directory lives in the dotfiles repo at `~/dotfiles/public/.config/nvim/` and is symlinked to `~/.config/nvim/`. Your logical cwd (`pwd -L`) will show the symlink path, but the git repo is at the physical path. Run git commands from `~/dotfiles/public/`.

## Testing

Run tests with `mise run test` (runs both suites). `mise run test:unit` and `mise run test:e2e` run individually. Never launch nvim directly for testing - always use `mise run test`.

- Unit tests (`tests/unit/`) load a minimal init with no plugins. Fast. Use for testing keymaps, options, autocmds.
- E2E tests (`tests/e2e/`) load the full `init.lua` with lazy.nvim and all plugins. Use for testing behavior that involves plugin interaction (e.g. cmp + Tab).
- Shared helpers are in `tests/helpers.lua`.
- Plenary's `init` (not `minimal_init`) option is required for e2e to avoid `--noplugin` in subprocesses.

### Red, green, refactor

Never make a behavioral change without first writing a test that fails. Watch it fail. Then implement the fix. Then look for simplification. This applies even to "obvious" fixes.

### Verifying interactive behavior

Headless nvim (and `h.feed`, which feeds keys synchronously) is the right tool
for deterministic keymap logic - the unit/e2e suites cover it, including blockwise
insert. What it can't reproduce is timing-dependent interactive behavior: async
autocmds (render-markdown, cmp) never interleave between keystrokes, and feeding
keys asynchronously to mimic real typing is unreliable (`<C-v>` may not even enter
blockwise-visual). To confirm the real-terminal experience, drive nvim in a PTY:
`tmux new-session -d -s x -x 120 -y 40`, `tmux send-keys`, `sleep` between keys,
then read the saved buffer.

`mise run test:pty` runs `tests/pty/newline-dot-repeat`, which does this for the markdown `<CR>` dot-repeat and abbreviation cases. It needs tmux and is not part of `mise run test`; run it by hand before committing a change to `lua/config/lists.lua` or the markdown `<CR>` mappings.

Two harness limits found while writing those tests: `nvim_feedkeys` with `x!` (stay in insert mode) hangs the plenary subprocess, and an abbreviation typed right before `<CR>` in one feedkeys batch makes insert mode read ahead, so an `expr` mapping sees the line before the word is inserted. Neither happens with real typing.

### Test pattern

```lua
it("does the thing", function()
  h.set_buf({ "line one", "line two" })
  h.set_cursor(1)
  h.feed("<Tab>")
  assert.are.same({ "  line one", "line two" }, h.get_buf())
end)
```

`h.feed()` processes mappings synchronously. Use `h.ensure_normal()` after insert-mode sequences.

In visual-mode tests where the buffer triggers `foldexpr` (e.g., `## Heading` lines for markdown), feed the visual-entry motion and the trigger key in separate `h.feed()` calls. Combined typeahead like `Vj<S-Tab>` can drop the trigger key when `foldmethod=expr` recomputes folds mid-sequence. Splitting into `h.feed("Vj")` then `h.feed("<S-Tab>")` avoids it. Doesn't affect interactive use.

### Before committing

Always run `mise run test` and confirm all tests pass.

## Markdown shiftwidth

Markdown uses shiftwidth=4 (set in `after/ftplugin/markdown.lua`). Unit tests that operate on markdown buffers must set this explicitly in `before_each`.

## LSP warnings

The `undefined global 'vim'` warnings in lua files are expected - the LSP doesn't know these run inside Neovim. Ignore them.

## Markdown Enter and bullets.vim

Insert-mode `<CR>` and normal-mode `o` in markdown are ours: `after/ftplugin/markdown.lua` maps them to `<Plug>(config-lists-newline)`, an `expr` mapping whose keys come from `lua/config/lists.lua`. It returns typed keys (`<BS>`, `<CR>`, the leader, the next marker) instead of editing the buffer, so `cw<CR>` on a list item or quote line dot-repeats. bullets.vim added its bullet with `append()`, which `.` cannot replay. Two things still run as buffer edits from a `<Cmd>` at the end of the key string, so they happen once and are not replayed: renumbering an ordered list and clearing an unused item.

The key strings assume `autoindent` (the ftplugin sets it): `<CR>` copies a line-leading indent and drops leading whitespace from the moved tail. Inside a blockquote the indent follows the leader, so it is typed. `<BS>` counts simulate Vim's `softtabstop` rule, since one `<BS>` over pre-existing spaces deletes back to the previous stop. Whitespace at the split point is removed only when text moves down; trailing spaces at end of line are a hard break and stay. Nesting after a trailing colon keeps the parent's marker, the same as Tab indenting. Alphabetic and Roman lists are not recognized.

bullets.vim remains for `gN` (renumber) and `<leader>x` (toggle checkbox), declared in `g:bullets_custom_mappings` in `lua/plugins/bullets.lua`. Its default mappings are off (`g:bullets_set_mappings = 0`) because they also claim `>>`, `<<`, `>`, `<`, `<C-t>`, and `<C-d>` for promote/demote. bullets.vim installs its buffer-local maps from a FileType autocmd that runs after the ftplugin, so any key it maps overwrites the ftplugin's map; it must not map `<cr>` or `o`.

Every list behavior works inside a blockquote (`> - item`, `> > 1. item`). bullets.vim anchors its regexes at `^\s*`, so instead of teaching it, `with_quote_stripped` in `lua/plugins/bullets.lua` strips the leader from the surrounding block of same-leader lines, runs the bullets.vim command, and puts the leader back. It uses `setline` per line because `nvim_buf_set_lines` over a range moves the `'<`/`'>` marks that `RenumberSelection` reads. Our own Tab/S-Tab and visual `-` `*` `#` in the ftplugin work on the body after the leader. The leader pattern lives in `lua/config/blockquote.lua`: whitespace, one or more `>`, at most one trailing space, so list indentation after `>` stays in the body.

## gx

`gx` is our own (`lua/config/gx.lua`), not gx.nvim or the builtin. It scans the whole line for http(s) URLs: cursor on one opens it, a lone URL opens directly, several prompt via `vim.ui.select`. Visual mode collects URLs from the selection. No commit-hash, issue-ref, or web-search handlers - URLs only.

## Treesitter

`nvim-treesitter/nvim-treesitter` and `nvim-treesitter/nvim-treesitter-textobjects` are pinned to `branch = "main"` (the master branch is archived and broken on Neovim 0.12+). The plugin is just a parser/query installer - feature wiring (highlight, indent, incremental selection, folds) goes through core `vim.treesitter.*` APIs in `lua/plugins/treesitter.lua`.

Parsers install via the `build` hook to `~/.local/share/nvim/site/parser/`. To add a language, edit the `parsers` table in `lua/plugins/treesitter.lua` and run `:Lazy build nvim-treesitter`.

If you ever switch branches on the plugin again, clean stale parser artifacts: `rm -f ~/.local/share/nvim/lazy/nvim-treesitter/parser/*.so ~/.local/share/nvim/lazy/nvim-treesitter/parser-info/*.revision`. They shadow bundled parsers via runtimepath order.

## Neo-tree Recent tab

`lua/neotree_recent/` is a custom Neo-tree source named `recent` (loaded via
`sources = { "neotree_recent" }`). It renders `config.recent_files`, an MRU
list seeded from `v:oldfiles` and updated on `BufEnter`, as a flat list of
basenames, newest first, not scoped to cwd. Neo-tree only calls a source's
`setup` on first use, so `lua/plugins/neo-tree.lua` starts the tracker
itself. Items are plain tables, not `file_items.create_item`, which would
build parent directories into a tree. It is the second tab; `2` jumps to it,
`d` drops an entry. Neo-tree cannot stack two sources in one window (upstream 360, 395).

## External Neo-tree sources

Neo-tree options live in `lua/config/neotree.lua`, not the plugin spec. A directory outside this config adds its own source from an exrc `.nvim.lua` (`exrc` is on; nvim sources trusted `.nvim.lua` files from the cwd and its parents after `init.lua`):

```lua
vim.opt.rtp:prepend(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/.nvim")
local ok, neotree = pcall(require, "config.neotree")
if ok then neotree.add_source("my_source", { display_name = " Mine " }) end
```

`add_source` takes an optional `config`, stored as the source's own opts (e.g. `{ window = { mappings = { l = "noop" } } }`); per-source mappings are the only way to override the global `window.mappings`. It appends to `sources` and the selector, then re-runs `require("neo-tree").setup()`, which is safe to call again. The window's `1`-`9` keys follow selector order, so added sources get the next number. `source_names()` feeds the visibility check behind `-` and the `<C-w>` moves; never hardcode source names. The 35-column window truncates labels once there are five tabs.

## Telescope

Every picker lives under `<C-f>` (`<C-f>f` files, `<C-f>g` grep, and so on) in normal, insert, visual, and terminal mode, so a picker opens while typing into a terminal program. The cost is Vim's page-down and the program's own `<C-f>`. Command-line and operator-pending modes are left alone. which-key auto-triggers only `nxso`, so `lua/plugins/init.lua` adds a manual `<C-f>` trigger for `i` and `t`; without it the prefix times out after `timeoutlen` (300ms) and `<C-f>` leaks to the buffer or program. Headless specs run before `VimEnter`, when which-key loads, so `telescope_keymaps_spec` fires `VimEnter` itself. Project-local pickers join the prefix from their `.nvim.lua`.
