return {
  -- Autocompletion
  'hrsh7th/nvim-cmp',

  dependencies = {
    'L3MON4D3/LuaSnip',
    'onsails/lspkind.nvim',
    -- 'SergioRibera/cmp-dotenv',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-nvim-lsp', -- Adds LSP completion capabilities
    'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-path',
    'saadparwaiz1/cmp_luasnip',
    { 'windwp/nvim-autopairs', opts = {} },
    {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
    {'neovim/nvim-lspconfig'},
    {'hrsh7th/cmp-nvim-lsp'},
  },
  config = function ()
    local cmp = require 'cmp'
    cmp.setup {
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
        end,
      },
      window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
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
          { name = "buffer" },
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
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { 'i', 's' }),
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

    -- Insert `(` after select function or method item
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    cmp.event:on(
      'confirm_done',
      cmp_autopairs.on_confirm_done()
    )

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
