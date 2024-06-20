return {
  -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      -- NOTE: If you are having trouble with this installation,
      --       refer to the README for telescope-fzf-native for more instructions.
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
  },
  keys = {
    {
      "<leader>f",
      function() require('telescope.builtin').live_grep() end,
      mode = {'n'},
      desc = "[F]ind Text in File Contents"
    },
    {
      "<leader>o",
      function() require('telescope.builtin').find_files() end,
      mode = {'n'},
      desc = "Fuzzy [O]pen File"
    },
    {
      "<leader>h",
      function() require('telescope.builtin').help_tags() end,
      mode = {'n'},
      desc = "Fuzzy Find [H]elp"
    },
  },
  opts = {
    defaults = {
      layout_strategy = "horizontal",
      layout_config = { prompt_position = "top" },
      sorting_strategy = "ascending",
      winblend = 0,

      mappings = {
        i = {
          ["<esc>"] = require('telescope.actions').close,
        },
      },
    },

  }
}
