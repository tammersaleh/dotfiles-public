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
--
-- vim.keymap.set('i', '<Tab>',   tab_forward,  {silent = true, expr = true})
-- vim.keymap.set('i', '<S-Tab>', tab_backward, {silent = true, expr = true})

return {
  'saghen/blink.cmp',
  version = '1.*',


  config = function()
    local blink = require('blink-cmp')


    blink.setup({
      keymap = {
        preset = 'none',
        ['<Tab>'] = {
          function(cmp)
            if only_whitespace_before_cursor() then return false end
            cmp.show_and_insert()
          end,
          function(cmp) if cmp.is_visible() then cmp.select_next() end end,
          'fallback'
        },
        ['<S-Tab>'] = {
          'select_prev',
          'fallback'
        },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<Esc>'] = {
          function(cmp)
            cmp.cancel({ callback = function() vim.cmd('stopinsert') end })
          end,
          'fallback'
        },
        ['<Enter>'] = {
          function(cmp) if cmp.is_visible() then cmp.accept() end end,
          'fallback'
        },
      },
      appearance = {
        nerd_font_variant = 'normal'
      },

      completion = {
        ghost_text = {
          enabled = true
        },
        menu = {
          auto_show = false,
        },
        list = {
          selection = {
            auto_insert = true,
            preselect = true,
          }
        }
      },
      cmdline = {
        keymap = { preset = 'inherit' },
        completion = { menu = {auto_show = false} },
      },
      sources = {
        default = { 'lsp', 'path', 'buffer' },
      },

      fuzzy = { implementation = 'prefer_rust_with_warning' },

    })
  end
}
