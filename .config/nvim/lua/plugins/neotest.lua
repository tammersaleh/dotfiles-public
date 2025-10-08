return {
  'nvim-neotest/neotest',
  tag = 'v5.6.1',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/neotest-go',
  },
  config = function()
    local neotest = require('neotest')
    neotest.setup {
      adapters = {
        require 'neotest-go' {
          args = { '-coverprofile=coverage.out' },
        },
      },
    }
    vim.keymap.set('n', '<Leader>rt', function() neotest.run.run() end, { desc = 'Run test' })
  end,
}
