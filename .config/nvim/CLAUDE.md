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

## bullets.vim

`<cr>` in markdown belongs to bullets.vim, wrapped in `lua/plugins/bullets.lua` so a mid-item Enter also continues the list (the plugin only continues at end of line).

Do not map `<CR>` for markdown in `after/ftplugin/`. bullets.vim installs its buffer-local maps from a FileType autocmd that runs after the ftplugin and overwrites them. Declare them in `g:bullets_custom_mappings` instead, which the plugin applies last.

Its default mappings are off (`g:bullets_set_mappings = 0`) because they also claim `>>`, `<<`, `>`, `<`, `<C-t>`, and `<C-d>` for promote/demote, shadowing the indent operators and duplicating the Tab/S-Tab cycling. We declare `<cr>`, `<C-cr>`, `o`, `gN`, and `<leader>x`.

The wrapper splits the line before calling `InsertNewBullet`. bullets.vim reads the current line to pick the next number, the checkbox state, and whether a trailing colon nests the item, so it has to see the post-split text.

## Treesitter

`nvim-treesitter/nvim-treesitter` and `nvim-treesitter/nvim-treesitter-textobjects` are pinned to `branch = "main"` (the master branch is archived and broken on Neovim 0.12+). The plugin is just a parser/query installer - feature wiring (highlight, indent, incremental selection, folds) goes through core `vim.treesitter.*` APIs in `lua/plugins/treesitter.lua`.

Parsers install via the `build` hook to `~/.local/share/nvim/site/parser/`. To add a language, edit the `parsers` table in `lua/plugins/treesitter.lua` and run `:Lazy build nvim-treesitter`.

If you ever switch branches on the plugin again, clean stale parser artifacts: `rm -f ~/.local/share/nvim/lazy/nvim-treesitter/parser/*.so ~/.local/share/nvim/lazy/nvim-treesitter/parser-info/*.revision`. They shadow bundled parsers via runtimepath order.
