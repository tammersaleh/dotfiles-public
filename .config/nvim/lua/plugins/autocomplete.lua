return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",  -- LSP completions
    "hrsh7th/cmp-buffer",    -- buffer words
    "hrsh7th/cmp-path",      -- filesystem paths
    "hrsh7th/cmp-cmdline",   -- command-line completions
    -- "L3MON4D3/LuaSnip",      -- snippet engine
    -- "saadparwaiz1/cmp_luasnip", -- snippet completions
  },
  config = function()

    local function only_whitespace_before_cursor()
      local cursor_pos = vim.api.nvim_win_get_cursor(0)[2]
      local text_before_cursor = vim.api.nvim_get_current_line():sub(1, cursor_pos)
      return text_before_cursor:match("^%s*$") ~= nil
    end

    vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
    local cmp = require('cmp')

    cmp.setup({
      mapping = cmp.mapping.preset.insert({
        -- Tab: Open menu and select first item, or cycle through items if already open
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif only_whitespace_before_cursor() then
            fallback()
          else
            cmp.complete()
            cmp.select_next_item()
          end
        end, { 'i', 's' }),

        -- Shift-Tab: Cycle backwards through completion items
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { 'i', 's' }),

        -- Escape: Close the completion menu
        ['<Esc>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.abort()
            vim.cmd('stopinsert')
          else
            fallback()
          end
        end, { 'i' }),

        -- Enter: Confirm the selected item
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
      }),

      -- Enable ghost text to show the top completion while typing
      experimental = {
        ghost_text = {
          hl_group = "CmpGhostText",
        },
      },

      -- Your sources configuration
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'buffer' },
        -- Add other sources as needed
      }),
    })
  end,
}
