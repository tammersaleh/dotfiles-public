return {
  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  'justinmk/vim-dirvish',
  'kristijanhusak/vim-dirvish-git',
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
  { "kylechui/nvim-surround", event = "VeryLazy", },

  'zhimsel/vim-stay',
  'RRethy/vim-illuminate',
  'Matt-Deacalion/vim-systemd-syntax',
  'cakebaker/scss-syntax.vim',
  'cespare/vim-toml',
  'ekalinin/Dockerfile.vim',
  'elzr/vim-json',
  'fatih/vim-go',
  'hail2u/vim-css3-syntax',
  'hashivim/vim-terraform',
  'pangloss/vim-javascript',
  'plasticboy/vim-markdown',
  'dkarter/bullets.vim',
  'tmhedberg/SimpylFold',
  'davidhalter/jedi-vim',
  'raimon49/requirements.txt.vim',
  'vim-ruby/vim-ruby',
  'vim-scripts/jQuery',
  'tpope/vim-rails',
  'tpope/vim-git',
  'aliou/bats.vim',
  'kevinoid/vim-jsonc',
  'rust-lang/rust.vim',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },

  { 'sainnhe/gruvbox-material',
    init = function()
      vim.g.gruvbox_material_dim_inactive_windows = true
      vim.g.gruvbox_material_background = 'hard'
      vim.cmd.colorscheme("gruvbox-material")
    end,
    priority = 1000
  },

  { 'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = true,
        theme = 'gruvbox',
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = {
          {
            'filename',
            file_status = true,      -- Displays file status (readonly status, modified status)
            newfile_status = false,  -- Display new file status (new file means no write after created)
            path = 1,                -- 0: Just the filename
                                     -- 1: Relative path
                                     -- 2: Absolute path
                                     -- 3: Absolute path, with tilde as the home directory
                                     -- 4: Filename and parent dir, with tilde as the home directory
            shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                                     -- for other components. (terrible name, any suggestions?)
            symbols = {
              modified = '[+]',      -- Text to show when the file is modified.
              readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
              unnamed = '[🤷]', -- Text to show for unnamed buffers.
              newfile = '[New]',     -- Text to show for newly created file before first write
            }
          }
        },
        lualine_b = {'progress'},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {'mode'},
      }
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {'filename'},
      lualine_x = {'progress'},
      lualine_y = {},
      lualine_z = {}
    },
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
  { 'numToStr/Comment.nvim', opts = {}, lazy = false, },

  -- Fuzzy Finder (files, lsp, etc)
  {
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
  },

}