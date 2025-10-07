return {
  -- LSP Configuration Files
  'neovim/nvim-lspconfig',
  lazy = false,
  dependencies = {
    -- Useful status updates for LSP
    { 'j-hui/fidget.nvim', opts = {} },
    -- Additional lua configuration, makes nvim stuff amazing!
    { "folke/lazydev.nvim", ft = "lua", opts = {} },
    {
      'nvimtools/none-ls.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
        local null_ls = require 'null-ls'
        null_ls.setup {
          sources = {
            null_ls.builtins.formatting.stylua,
            null_ls.builtins.formatting.prettier,
            null_ls.builtins.formatting.black,
            null_ls.builtins.diagnostics.erb_lint,
            null_ls.builtins.diagnostics.rubocop,
            null_ls.builtins.formatting.rubocop,
          },
        }
      end,
    },
  }
}
