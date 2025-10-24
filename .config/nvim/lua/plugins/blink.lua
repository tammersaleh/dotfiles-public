local function only_whitespace_before_cursor()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)[2]
  local text_before_cursor = vim.api.nvim_get_current_line():sub(1, cursor_pos)
  return text_before_cursor:match("^%s*$") ~= nil
end

local function tab(forward)
  -- Hit <tab> after a word in a line like such:
  -- Hello darling! <tab>
  -- ...and the entire line indents.
  local tab_key = forward and "<Tab>" or "<S-Tab>"
  local indent_key = forward and "<C-t>" or "<C-d>"
  return only_whitespace_before_cursor() and tab_key or indent_key
end

local function tab_forward()
  return tab(true)
end

local function tab_backward()
  return tab(false)
end

vim.keymap.set('i', '<Tab>',   tab_forward,  {silent = true, expr = true})
vim.keymap.set('i', '<S-Tab>', tab_backward, {silent = true, expr = true})

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

  config = function()
    local cmp = require('blink-cmp')

    -- local function select_and_accent_and_insert(char)
    --   return cmp.select_and_accept({
    --     callback = function()
    --       vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(char, true, false, true), 'n', false)
    --     end,
    --   })
    -- end

    cmp.setup({
      keymap = {
        -- preset = 'super-tab',
        ['<Tab>'] = {
          'show',
          'select_next',
          'snippet_forward',
          'fallback'
        },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<Esc>'] = { 'cancel', 'fallback' },
        ['<Enter>'] = { 'select_and_accept', 'fallback' },
        -- ['.'] = { function(_) return select_and_accent_and_insert('.') end, 'fallback' },
        -- [','] = { function(_) return select_and_accent_and_insert(',') end, 'fallback' },
        -- [' '] = { function(_) return select_and_accent_and_insert(' ') end, 'fallback' },
        -- [':'] = { function(_) return select_and_accent_and_insert(':') end, 'fallback' },
        -- [';'] = { function(_) return select_and_accent_and_insert(';') end, 'fallback' },
        -- ['('] = { function(_) return select_and_accent_and_insert('(') end, 'fallback' },
        -- [')'] = { function(_) return select_and_accent_and_insert(')') end, 'fallback' },
        -- ['}'] = { function(_) return select_and_accent_and_insert('}') end, 'fallback' },
        -- ['{'] = { function(_) return select_and_accent_and_insert('{') end, 'fallback' },
        -- ['|'] = { function(_) return select_and_accent_and_insert('|') end, 'fallback' },
      },

      appearance = { nerd_font_variant = 'normal' },

      completion = {
        ghost_text = { enabled = true },
        trigger = { show_in_snippet = false },
        list = {
          selection = {
            auto_insert = false,
            preselect = true,
          }
        }
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      fuzzy = { implementation = 'prefer_rust_with_warning' },

    })
  end
}
