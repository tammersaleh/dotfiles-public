# Neovim Config

Lazy.nvim-based Neovim configuration. Lives in the dotfiles repo at `~/dotfiles/public/.config/nvim/` and is symlinked to `~/.config/nvim/`.

## Directory structure

```
init.lua                    # Entry point: leader key, lazy.nvim bootstrap, module loading
lua/
  config/                   # Editor behavior (no plugin dependencies)
    editor.lua              # Mouse, clipboard, undo, breakindent
    filetypes.lua           # Custom filetype detection
    ui.lua                  # Line numbers, signcolumn, foldlevel, cursorline
    search.lua              # Case sensitivity, hlsearch autocmds
    completion.lua          # completeopt
    splits.lua              # Split behavior, window navigation (C-h/j/k/l)
    terminal.lua            # Terminal keymaps and autocmds
    mkdir_on_save.lua       # Auto-create parent directories on save
    keymaps.lua             # General keymaps (Tab indent, move line, etc.)
  plugins/                  # Lazy.nvim plugin specs
    init.lua                # Miscellaneous plugins (sleuth, fugitive, which-key, etc.)
    autocomplete.lua        # nvim-cmp setup and Tab/S-Tab behavior
    lsp.lua                 # LSP plugin config (mason, lspconfig)
    telescope.lua           # Fuzzy finder
    treesitter.lua          # Syntax highlighting
    ...                     # One file per plugin or plugin group
  lsp.lua                   # LSP keymaps and server configuration
after/ftplugin/             # Filetype-specific overrides (loaded after plugins)
  markdown.lua              # shiftwidth=4, folding, bullet formatting, spell
  help.lua                  # K and Enter jump to tag
  rust.lua                  # rustaceanvim keymaps
tests/
  helpers.lua               # Shared test utilities (set_buf, feed, get_buf, etc.)
  unit/                     # Fast tests, no plugins loaded
    minimal_init.lua        # Minimal nvim init for unit tests
    config/                 # Tests for lua/config/ modules
    ftplugin/               # Tests for after/ftplugin/ files
  e2e/                      # Full config tests with all plugins loaded
    config/                 # Tests requiring plugin interaction (e.g. cmp + Tab)
```

## Testing

Tests use [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)'s busted-style test runner.

```sh
mise run test          # run both suites
mise run test:unit     # fast, no plugins
mise run test:e2e      # full config with lazy.nvim and all plugins
```

Unit tests load a minimal init with just the config modules under test. E2E tests load the real `init.lua` using plenary's `init` option (not `minimal_init`) to avoid `--noplugin` in subprocesses, which would prevent lazy.nvim's event-based plugin loading from working.

### Writing tests

```lua
local h = require('helpers')

require('config.keymaps')

describe("keymaps", function()
  before_each(function()
    h.reset()
  end)

  it("Tab indents line in normal mode", function()
    h.set_buf({ "hello", "world" })
    h.set_cursor(1)
    h.feed("<Tab>")
    assert.are.same({ "  hello", "world" }, h.get_buf())
  end)
end)
```

`h.feed()` processes mappings synchronously. Use `h.ensure_normal()` after insert-mode sequences. Markdown tests must set `vim.bo.shiftwidth = 4` explicitly in `before_each`.
