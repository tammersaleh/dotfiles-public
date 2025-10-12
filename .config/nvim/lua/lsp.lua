vim.lsp.config('*', {
  on_attach = function(_, bufnr)
    local nmap = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
    end

    local telescope = require 'telescope.builtin'
    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    nmap('gd', telescope.lsp_definitions, '[G]oto [D]efinition')
    nmap('gr', telescope.lsp_references, '[G]oto [R]eferences')
    nmap('gI', telescope.lsp_implementations, '[G]oto [I]mplementation')
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>gf', vim.lsp.buf.format, '[F]ormat current file')
  end,
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      telemetry = { enable = false },
      diagnostics = { disable = { 'missing-fields' } },
    },
  },
})

vim.lsp.config('pyright', {
  settings = {
    pyright = {
      disableOrganizeImports = true, -- Using Ruff's import organizer
    },
    python = {
      analysis = {
        ignore = { '*' }, -- Ignore all files for analysis to exclusively use Ruff for linting
      },
    },
  },
})

vim.lsp.enable {
  'bashls',
  'cmake',
  'cssls',
  'docker_compose_language_service',
  'dockerls',
  'gopls',
  'html',
  'lua_ls',
  'marksman',
  'pyright',
  'ruff',
  'tflint',
  'yamlls',
}
