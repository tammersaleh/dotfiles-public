return {
  'saghen/blink.cmp',
  version = '1.*',

  dependencies = {
    { 'rafamadriz/friendly-snippets',
      dependencies = {
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        -- install jsregexp (optional!).
        build = 'make install_jsregexp',
      }
    },
  },

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
      preset = 'super-tab',
    },

    appearance = { nerd_font_variant = 'normal' },

    completion = {
      ghost_text = { enabled = true },
      trigger = { show_in_snippet = false },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    fuzzy = { implementation = 'prefer_rust_with_warning' },
  },
  opts_extend = { 'sources.default' },
}
