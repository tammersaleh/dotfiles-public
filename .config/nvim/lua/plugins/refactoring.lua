return {
  'ThePrimeagen/refactoring.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  cmd = 'Refactor',
  keys = {
    {
      "<leader>rr",
      function() require('telescope').extensions.refactoring.refactors() end,
      mode = {'n', 'x'},
      desc = "[R]efactor"
    },
  },
  config = function()
    require('refactoring').setup({})
    require('telescope').load_extension('refactoring')
  end,
}
