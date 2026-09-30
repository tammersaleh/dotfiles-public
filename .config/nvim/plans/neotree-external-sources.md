# Neo-tree external sources

Let a directory outside this config add its own Neo-tree source, active only when nvim starts there. The global config gains a generic hook and knows nothing about the caller.

## Context

`exrc` (off by default) makes nvim source `.nvim.lua` from the cwd and every parent directory, if `:trust`ed. It runs at startup step 7c, after `init.lua`, so after lazy.nvim has run neo-tree's `config`.

Neo-tree takes `sources` once, in `setup()`. `require("neo-tree").setup(opts)` only stores the opts; the merge happens later in `ensure_config` (`lua/neo-tree.lua:110`). A second `setup()` before first use just replaces the stored opts. After first use, `merge_config` is re-entrant: it clears events (`events_setup`), and `manager.setup` calls `unsubscribe_all` per source (`lua/neo-tree/setup/init.lua:417`, `lua/neo-tree/sources/manager.lua:795`).

External sources load by `require(module)`, and `module.name` becomes the source name (same mechanism as `lua/neotree_recent/`).

## Design

### `lua/config/neotree.lua`

Owns the neo-tree opts table, moved out of `lua/plugins/neo-tree.lua`. Public API:

- `setup()` - call `require("neo-tree").setup(opts)`, install the number keymaps.
- `add_source(module, { display_name = "..." })` - require `module`, append it to `sources` and `source_selector.sources`, re-run `setup()`. Idempotent per module.
- `source_names()` - names of every registered source, used by the visibility check.

The window's `1`..`N` keymaps come from `source_selector.sources` order, so an added source gets the next number (`5`).

### `lua/plugins/neo-tree.lua`

Keeps the toggles and split keymaps. `neotree_is_visible()` reads `source_names()` instead of a hardcoded list. Calls `require("config.neotree").setup()`.

### `exrc`

`vim.o.exrc = true` in `lua/config/editor.lua`.

### Caller side (in the external repo)

`<repo>/.nvim.lua`:

```lua
local root = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
vim.opt.rtp:prepend(root .. "/.nvim")
local ok, neotree = pcall(require, "config.neotree")
if ok then
  neotree.add_source("my_source", { display_name = " Mine " })
end
```

The `pcall` keeps other nvim configs working. The source lives at `<repo>/.nvim/lua/my_source/init.lua`, modeled on `lua/neotree_recent/init.lua`.

## Steps

1. [x] Failing e2e test `tests/e2e/config/neotree_add_source_spec.lua`: a fixture source added via `add_source` opens with `:Neotree <name>`, shows in the selector, `5` switches to it, and `-` closes it.
   Fixture source: `tests/fixtures/lua/neotree_fixture/`. Fails today with `module 'config.neotree' not found`.
2. [x] Extract `lua/config/neotree.lua`; implement `add_source`, `source_names`, generated number keymaps. Tests green.
3. [x] Enable `exrc`.
4. [x] Update `.config/nvim/CLAUDE.md` (section on external sources).
5. [ ] Caller side: tracked in the external repo, not here.

## Discoveries

- With five tabs, the 35-column selector truncates every label (` 󰉓 F…▕▏ 󰋚 R…▕▏ 󰊢 G…▕▏ 󰈚 S…▕▏ Fix…`).
- Verified with a real headless launch from a subdirectory of a trusted `.nvim.lua`: the source registers and renders.
