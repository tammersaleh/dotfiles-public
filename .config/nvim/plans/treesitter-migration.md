# Treesitter migration plan

## Context

Neovim 0.13.0-dev throws `attempt to call method 'range' (a nil value)` on every markdown BufReadPost. Root cause: `nvim-treesitter` master is pinned to its archived 2025-05 commit, and its `query_predicates.lua` does `match[capture_id]` assuming a single `TSNode` - but on Neovim 0.12+ that returns a list of nodes. Snacks indent triggers this on every markdown load because it parses with injections enabled.

Whole `nvim-treesitter/nvim-treesitter` repo was archived 2026-04-03. The `main` branch is still usable as a frozen snapshot.

## Goal

Get syntax highlighting + textobjects + folds + indent working for: bash, c, cpp, go, javascript, lua, markdown, python, ruby, tsx, typescript, vim, vimdoc. Without depending on the broken master-branch API.

User does NOT use `:TSInstall`/`:TSUpdate` interactively. Parser install/update is a one-time `build` hook of the plugin spec - never interactive UI.

## Decision

Switch `nvim-treesitter` and `nvim-treesitter-textobjects` to `branch = "main"`. Drop all `nvim-treesitter.configs.setup{}` usage. Wire features through core `vim.treesitter.*` APIs.

`nvim-treesitter` main becomes a silent provider of parser binaries (via its install function) and query files (via runtimepath). User never invokes its commands.

## Why not pure built-in

0.13-dev only bundles queries for c/lua/markdown/markdown_inline/query/vim/vimdoc. For bash/cpp/go/python/js/ts/tsx/ruby you need queries from somewhere - nvim-treesitter `main` is currently the simplest source.

## Plugin audit

| Plugin | Impact | Action |
|---|---|---|
| nvim-treesitter | broken on 0.12+ | Switch to `main`, replace config entirely |
| nvim-treesitter-textobjects | hard-requires removed APIs | Switch to `main`, rewrite keymaps explicitly |
| nvim-treesitter-endwise | already migrated upstream | Move to its own spec file; remove dead `enable=true` block |
| nvim-ts-autotag | already self-contained | Move to its own spec file (cleanup) |
| snacks/render-markdown/helpview/refactoring/todo-comments | core APIs only | No change |

## Steps

### 1. Prereq: install tree-sitter CLI

- [ ] Add `tree-sitter` to `~/dotfiles/public/packages/Brewfile`
- [ ] `brew bundle --file=~/dotfiles/public/packages/Brewfile install`
- [ ] Confirm `tree-sitter --version` works

Must happen before plugin branch change. Branch flip + missing CLI = broken parsers with no rebuild path.

### 2. Replace plugin spec

Rewrite `lua/plugins/treesitter.lua`:

- `nvim-treesitter`: `branch = "main"`, `build` hook calling `require('nvim-treesitter').install({...}):wait()`
- `nvim-treesitter-textobjects`: `branch = "main"`, table-driven explicit keymaps for select/move/swap
- Keep custom `is-mise?` predicate registration
- Keep global foldmethod/foldexpr (already core APIs)
- Keep fold-aware `<Left>`/`<Right>`/`h`/`l` mappings
- Keep Ruby `indentkeys` autocmd
- FileType autocmd calling `vim.treesitter.start()` for non-auto-attaching langs (exclude lua/markdown/query/help)
- Filetype aliases: `typescriptreact→tsx`, `javascriptreact→javascript`
- `indentexpr` via FileType autocmd for: c, cpp, go, python, javascript, typescript, typescriptreact, tsx, bash, lua (experimental on main - may need per-lang tuning)
- Delete: `configs.setup{}`, `ensure_installed`, `auto_install`, `highlight={}`, `indent={}`, `incremental_selection`, `textobjects={}`, `endwise={}` blocks

### 3. Split out endwise + autotag

- [ ] `lua/plugins/endwise.lua` (or merge into existing autopairs.lua) - own spec, no nvim-treesitter dep
- [ ] `lua/plugins/autotag.lua` - own spec, no nvim-treesitter dep

These no longer logically belong under treesitter.

### 4. Parser set

To install via build hook (non-bundled in 0.13-dev):
`bash, cpp, go, javascript, python, ruby, tsx, typescript`

Drop the auto_install incidental cruft from old behavior (json/yaml/gitcommit/etc.). If any are missed, add them back later.

### 5. Incremental selection shim

3-line shim using built-in `an` text object (which already does incremental expand when pressed in visual mode):

```lua
vim.keymap.set('n', '<C-Space>', 'van', { desc = 'TS: select node' })
vim.keymap.set('x', '<C-Space>', 'an',  { desc = 'TS: expand to parent node' })
vim.keymap.set('x', '<C-s>',     'an',  { desc = 'TS: expand to parent (scope alias)' })
```

Lost vs. old plugin: no `scope_incremental` distinction (just press `<C-Space>` more times); no `node_decremental` (user never bound it anyway).

### 6. Tests + verify

- [ ] `mise run test` passes (both unit + e2e)
- [ ] Open a markdown buffer with a fenced code block - no `range` error
- [ ] Verify highlights in c/cpp/go/python/js/ts/tsx/bash/ruby files
- [ ] Verify no duplicate attach: `:lua =vim.treesitter.highlighter.active[0]`
- [ ] Textobjects: `aa, ia, af, if, ac, ic, ]m, ]M, [m, [M, ]], [[, ][, [], <leader>a, <leader>A`
- [ ] Endwise: typing `def foo` + enter in ruby adds `end`
- [ ] Autotag: typing `<div>` adds `</div>`
- [ ] Markdown still uses custom foldexpr from `after/ftplugin/markdown.lua`
- [ ] Ruby `.` no longer reindents

## Things explicitly NOT in scope

- Any `:TSInstall`/`:TSUpdate` workflow (user doesn't use)
- Recreating `auto_install` runtime behavior
- Preserving incidentally-installed parsers (yaml, gitcommit, etc.)
- `<C-Space>` incremental selection muscle memory

## Decisions locked in

- Incremental selection: 3-line `<C-Space>` shim using built-in `an` (preserves muscle memory)
- Test first: write e2e test that opens markdown with fenced code block, asserts no error; watch it fail, then migrate
- Indent: enable for c, cpp, go, python, javascript, typescript, typescriptreact, tsx, bash, lua. Skip ruby (keep `.` workaround). Skip markdown/help/query/vimdoc.

## Sequence

Steps must run in order. Step 1 before all others. Steps 2-3 before 4-6.

## Migration completed

All steps done. Final state:

- `tree-sitter-cli` added to Brewfile and installed
- `lua/plugins/treesitter.lua` rewritten for main branch
- `lua/plugins/endwise.lua` and `lua/plugins/autotag.lua` split out
- Parsers installed at `~/.local/share/nvim/site/parser/`
- All 134 tests pass (130 unit + 4 e2e)
- Markdown fence error gone (verified via regression test + smoke checks)

### Extra cleanup step required

After `:Lazy sync`, leftover `.so` files from the old master branch remained in `~/.local/share/nvim/lazy/nvim-treesitter/parser/`. These shadowed bundled and newly-installed parsers via runtimepath order, causing a different error (`operator: _ @operator)` query mismatch when injecting lua into markdown).

Fix: removed all `parser/*.so` and `parser-info/*.revision` from the plugin directory.

If switching branches again in future, repeat: `cd ~/.local/share/nvim/lazy/nvim-treesitter && rm -f parser/*.so parser-info/*.revision`.
