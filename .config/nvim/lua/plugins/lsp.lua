return {
  -- LSP Configuration Files
  'neovim/nvim-lspconfig',
  lazy = false,
  dependencies = {
    -- Useful status updates for LSP
    { 'j-hui/fidget.nvim',  opts = {} },
    -- Additional lua configuration, makes nvim stuff amazing!
    { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
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
            null_ls.builtins.diagnostics.golangci_lint,
            null_ls.builtins.diagnostics.hadolint,
          },
          on_attach = function(client, bufnr)
            if client.supports_method 'textDocument/formatting' then
              local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
              vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
              vim.api.nvim_create_autocmd('BufWritePre', {
                group = augroup,
                buffer = bufnr,
                callback = function()
                  vim.lsp.buf.format()
                end,
              })
            end
          end,
        }
      end,
    },
  },
}
