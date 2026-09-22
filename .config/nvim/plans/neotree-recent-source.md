# Neo-tree "Recent" source

Add a fourth tab to the Neo-tree source selector (Files, Git, Syms, Recent)
listing recently opened files, most recent first.

## Context

Neo-tree cannot stack two sources in one window (upstream issues 360 and
395, won't-fix). Sources are separate views switched via the selector tabs.
Neo-tree loads external sources by `require(name)` when
`neo-tree.sources.<name>` doesn't exist (`lua/neo-tree/setup/init.lua:494`).
A module at `lua/neotree_recent/init.lua` with `name = "recent"` works
as a source named `recent` without shadowing the plugin's namespace. Reference implementation: the built-in
`buffers` source.

`vim.v.oldfiles` is only read from shada at startup and refreshed on
`:rshada`, so it misses files opened in the current session. We track
BufEnter ourselves and seed from oldfiles.

## Design

### `lua/config/recent_files.lua` (pure, unit-tested)

MRU list of absolute paths. Public API:

- `setup()` - seed from `vim.v.oldfiles`, install a `BufEnter` autocmd that
  calls `touch()` for real, listed, non-neo-tree file buffers.
- `touch(path)` - move `path` to the front.
- `list(opts)` - return paths, most recent first. Drops files that no
  longer exist. Capped at `opts.limit` (default 30). No cwd filter: files
  opened from `/tmp` and elsewhere belong in the list.
- `remove(path)` - drop one entry (used by `d` in the tree).

### `lua/neotree_recent/init.lua` (source module)

- `name = "recent"`, `display_name = " 󰋚 Recent "`.
- `navigate(state, path, path_to_reveal, callback)` - `state.path` is cwd
  (like buffers). Builds a flat list: a root node labeled `Recent`,
  children are file items created with
  `file_items.create_item(context, path, "file")` so icons, git status and
  the common `open*` commands work. Item name is the basename only. The
  node id is the absolute path, so duplicates by name stay distinct.
- `setup(config, global_config)` - subscribe to `VIM_BUFFER_ENTER` to
  refresh the tree when it is visible (debounced, as buffers does).
  Neo-tree only calls this on first use of the source, so
  `recent_files.setup()` is called from `lua/plugins/neo-tree.lua`.

### `lua/neotree_recent/commands.lua`

Extends common commands. Adds `remove_from_recent` (drop the entry and
refresh). Everything else (`open`, `open_split`, `open_vsplit`,
`open_with_window_picker`, `toggle_preview`, `show_help`, `refresh`)
comes from `neo-tree.sources.common.commands`.

### `lua/plugins/neo-tree.lua` wiring

- Add `"neotree_recent"` to `sources` and to `source_selector.sources` as the
  fourth tab.
- Add `['4'] = function() vim.cmd.Neotree('recent') end`.
- Add `"recent"` to the `neotree_is_visible()` source list.
- `recent = { window = { mappings = { ["d"] = "remove_from_recent" } } }`.

## Decisions

- No cwd scope. Files opened in `/tmp` and elsewhere show up too.
- Flat list, basename only. No directory grouping or paths.
- Limit 30.
- Live tracking via BufEnter, seeded from `v:oldfiles`. Not persisted
  beyond what shada already keeps.
- Excludes the current buffer? No. Simpler, and the top entry doubles as
  "where am I".

## Steps

Red, green, refactor for each behavioral step.

1. [x] `tests/unit/config/recent_files_spec.lua`: touch ordering, dedupe,
       missing-file pruning, limit, remove.
2. [x] Implement `lua/config/recent_files.lua`.
3. [x] `tests/e2e/config/neotree_recent_spec.lua`: `:Neotree recent` opens
       a window whose buffer has `neo_tree_source == "recent"`; after
       editing two temp files, the tree lists both by basename, newest first;
       `4` from the filesystem tree switches to it.
4. [x] Implement the source module and commands.
5. [x] Wire into `lua/plugins/neo-tree.lua`.
6. [x] `mise run test`, then manual check in a PTY (see CLAUDE.md).
7. [x] Update `.config/nvim/CLAUDE.md` with a short "Recent source" section.
8. [x] Commit in small pieces, push.

## Discoveries

- `hidden` is off in this config, so a modified nameless buffer blocks `:b`
  in the target window. The e2e open test clears `modified` first.
- With four tabs at width 35 the selector truncates labels (`Fil…`, `Sym…`,
  `Rec…`).

## Open questions

- Codex review skipped: the codex MCP server failed to connect this session.
