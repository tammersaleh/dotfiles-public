# Neovim Config

Lazy.nvim-based config. Plugin specs in `lua/plugins/`, config modules in `lua/config/`, filetype overrides in `after/ftplugin/`.

## Testing

Run tests with `mise run test` (runs both suites). `mise run test:unit` and `mise run test:e2e` run individually.

- Unit tests (`tests/unit/`) load a minimal init with no plugins. Fast. Use for testing keymaps, options, autocmds.
- E2E tests (`tests/e2e/`) load the full `init.lua` with lazy.nvim and all plugins. Use for testing behavior that involves plugin interaction (e.g. cmp + Tab).
- Shared helpers are in `tests/helpers.lua`.
- Plenary's `init` (not `minimal_init`) option is required for e2e to avoid `--noplugin` in subprocesses.

### Red, green, refactor

Never make a behavioral change without first writing a test that fails. Watch it fail. Then implement the fix. Then look for simplification. This applies even to "obvious" fixes.

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

### Before committing

Always run `mise run test` and confirm all tests pass.

## Markdown shiftwidth

Markdown uses shiftwidth=4 (set in `after/ftplugin/markdown.lua`). Unit tests that operate on markdown buffers must set this explicitly in `before_each`.

## LSP warnings

The `undefined global 'vim'` warnings in lua files are expected - the LSP doesn't know these run inside Neovim. Ignore them.
