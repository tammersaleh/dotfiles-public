return {
  'andythigpen/nvim-coverage',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('coverage').setup {
      lang = {
        go = {
          coverage_file = vim.fn.getcwd() .. '/coverage.out',
        },
      },
    }
  end,
}
