return {
  -- Git related plugins
  { 'tpope/vim-fugitive',
    config = function()
      vim.api.nvim_create_user_command(
        'Browse',
        function (opts) vim.fn.system { 'open', opts.fargs[1] } end,
        { nargs = 1 }
      )
    end
  },
  { 'tpope/vim-rhubarb' },

  -- Detect tabstop and shiftwidth automatically
  { 'tpope/vim-sleuth' },

  -- { 'justinmk/vim-dirvish' },
  { 'kristijanhusak/vim-dirvish-git' },
  { 'kana/vim-smartword',
    keys = {
      {'cw', 'c<Plug>(smartword-basic-w)', desc = '[C]hange [w]ord (using smartword)'},
      {'dw', 'd<Plug>(smartword-basic-w)', desc = '[d]elete [w]ord (using smartword)'},
      {'w', '<Plug>(smartword-w)',   mode = {'n', 'o', 'v'}},
      {'b', '<Plug>(smartword-b)',   mode = {'n', 'o', 'v'}},
      {'e', '<Plug>(smartword-e)',   mode = {'n', 'o', 'v'}},
      {'ge', '<Plug>(smartword-ge)', mode = {'n', 'o', 'v'}},
    },
  },
  { "stevearc/dressing.nvim", event = "VeryLazy" },

  { 'zhimsel/vim-stay' },
  { 'RRethy/vim-illuminate' },
  { 'Matt-Deacalion/vim-systemd-syntax' },
  { 'cakebaker/scss-syntax.vim' },
  { 'cespare/vim-toml' },
  { 'elzr/vim-json' },
  { 'hail2u/vim-css3-syntax' },
  { 'hashivim/vim-terraform' },
  { 'pangloss/vim-javascript' },
  { 'dkarter/bullets.vim' },
  { 'raimon49/requirements.txt.vim' },
  { 'vim-ruby/vim-ruby' },
  { 'tpope/vim-rails' },
  { 'tpope/vim-git' },
  { 'aliou/bats.vim' },
  { 'kevinoid/vim-jsonc' },
  { 'echasnovski/mini.splitjoin', version = '*', opts = {} },
  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {
    plugins = {
      presets = {
        operators = true, -- adds help for operators like d, y, ...
        motions = true, -- adds help for motions
        text_objects = true, -- help for text objects triggered after entering an operator
        windows = true, -- default bindings on <c-w>
        nav = true, -- misc bindings to work with windows
        z = true, -- bindings for folds, spelling and others prefixed with z
        g = true, -- bindings for prefixed with g
      },
    },
  } },

  { 'sainnhe/gruvbox-material',
    init = function()
      vim.g.gruvbox_material_dim_inactive_windows = true
      vim.g.gruvbox_material_background = 'hard'
      vim.g.gruvbox_material_foreground = 'hard'
      vim.g.gruvbox_material_visual = 'reverse'
      vim.cmd.colorscheme("gruvbox-material")
    end,
    priority = 1000
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  -- Neovim 0.10 has this builtin, but Comment.nvim is better
  -- https://github.com/numToStr/Comment.nvim/issues/453
  { 'numToStr/Comment.nvim', opts = {}, lazy = false, },

}
