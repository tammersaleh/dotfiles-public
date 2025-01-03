return {
  -- Autocompletion
  'hrsh7th/nvim-cmp',

  dependencies = {
    'L3MON4D3/LuaSnip',
    'onsails/lspkind.nvim',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-nvim-lsp', -- Adds LSP completion capabilities
    'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-path',
    'saadparwaiz1/cmp_luasnip',
    {'neovim/nvim-lspconfig'},
    {'hrsh7th/cmp-nvim-lsp'},
  },
  config = function ()
    local function character_just_before_cursor()
      local cursor_pos = vim.api.nvim_win_get_cursor(0)[2]
      local line = vim.api.nvim_get_current_line()

      if cursor_pos == 0 then
        return false -- If the cursor is at the first position, return false
      end

      local char_before_cursor = line:sub(cursor_pos, cursor_pos)
      return not char_before_cursor:match("%s")
    end

    local cmp = require('cmp')
    local luasnip = require("luasnip")
    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      matching = {
        disallow_fuzzy_matching = true,
        disallow_fullfuzzy_matching = true,
        disallow_partial_fuzzy_matching = true,
        disallow_partial_matching = true,
        disallow_prefix_unmatching = false,
      },
      sources = cmp.config.sources({
          -- { name = "dotenv" },
          { name = "luasnip" }, -- For luasnip users.
          { name = "nvim_lsp" },
          { name = "nvim_lua" },
        }, {
          { name = "buffer",
            option = {
              get_bufnrs = function()
                return vim.api.nvim_list_bufs()
              end
            }
          },
          { name = "path" },
        }),
      completion = { completeopt = 'menu,menuone,longest,noselect' },
      preselect = cmp.PreselectMode.None,
      mapping = cmp.mapping.preset.insert {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif character_just_before_cursor() then
            cmp.complete()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif character_just_before_cursor() then
            cmp.complete()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<CR>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            if luasnip.expandable() then
              luasnip.expand()
            else
              cmp.confirm({ select = true })
            end
          else
            fallback()
          end
        end),
      },
      formatting = {
        format = require('lspkind').cmp_format({
          preset = 'codicons', -- uses vscode icons installed via homebrew
          menu = ({
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            luasnip = "[LuaSnip]",
            nvim_lua = "[Lua]",
            path = "[Path]",
          })
        })
      }
    }

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
    })

    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = 'buffer' } }
    })
  end
}
