return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function() return vim.fn.executable 'make' == 1 end,
    },
  },
  lazy = false,
  config = function ()
    local telescope = require('telescope')
    local actions = require("telescope.actions")
    local builtin = require('telescope.builtin')

    telescope.setup({
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          n = {
            ["<C-u>"] = actions.cycle_history_prev,
            ["<C-d>"] = actions.cycle_history_next,
          },
          i = {
            ["<C-u>"] = actions.cycle_history_prev,
            ["<C-d>"] = actions.cycle_history_next,
          },
        },
      },

    })
    telescope.load_extension('fzf')

    local function gcwd()
      return vim.fn.getcwd(-1)
    end

    local function git()
      local git_root = vim.fn.systemlist('git -C ' .. gcwd() .. ' rev-parse --show-toplevel')[1]
      if vim.v.shell_error ~= 0 then
        return gcwd()
      end
      return git_root
    end

    -- All of the telescope bindings start with space-f
    local function map(key, func, desc)
      vim.keymap.set('n', '<leader>f' .. key, func, { desc = '[F]ind ' .. desc })
    end

    local function find_in_current_buffer_fn()
      return function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false, })
      end
    end

    map('f', function() builtin.find_files({cwd = gcwd()}) end, '[f]iles')
    map('F', function() builtin.find_files({cwd = git()})  end, '[F]iles from Git root')

    map('g', function() builtin.live_grep({cwd = gcwd()}) end, '[g]rep')
    map('G', function() builtin.live_grep({cwd = git()})  end, '[G]rep from Git root')

    map('w', function() builtin.live_grep({cwd = gcwd(), default_text = vim.fn.expand('<cword>')}) end, 'current [W]ord')

    map('b', find_in_current_buffer_fn(), 'in current [b]uffer')

    map('d', builtin.diagnostics, '[D]iagnostics')
    map('h', builtin.help_tags,   '[H]elp')
    map('a', builtin.builtin,     '[A]ll Telescope')
    map('r', builtin.resume,      '[R]esume')
  end
}
