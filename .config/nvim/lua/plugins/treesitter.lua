local function MoveAndFoldLeft()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))

    if col == 0 and vim.fn.foldlevel(line) ~= 0 then
        vim.cmd.foldclose()
    else
        vim.cmd.normal({ 'h', bang = true })
    end
end

local function MoveAndFoldRight()
    local line = vim.api.nvim_win_get_cursor(0)[1]

    if vim.fn.foldlevel(line) ~= 0 and vim.fn.foldclosed(line) ~= -1 then
        vim.cmd.foldopen()
    else
        vim.cmd.normal({'l', bang = true})
    end
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'folke/which-key.nvim',
    },
    build = ':TSUpdate',
    config = function ()
      require('nvim-treesitter.configs').setup {
        -- Add languages to be installed here that you want installed for treesitter
        ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

        -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
        auto_install = true,

        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<M-space>',
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>A'] = '@parameter.inner',
            },
          },
        },
      }
      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      -- This doesn't work.  Prints:
      -- 0................
      -- vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"
      vim.opt.foldnestmax = 2

      require('which-key').register {
        ['<leader>c'] = { name = '[C]ode',      _ = 'which_key_ignore' },
        ['<leader>d'] = { name = '[D]ocument',  _ = 'which_key_ignore' },
        ['<leader>g'] = { name = '[G]it',       _ = 'which_key_ignore' },
        ['<leader>s'] = { name = '[S]earch',    _ = 'which_key_ignore' },
        ['<leader>t'] = { name = '[T]oggle',    _ = 'which_key_ignore' },
        ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
      }
      -- register which-key VISUAL mode
      -- required for visual <leader>hs (hunk stage) to work
      require('which-key').register({
        ['<leader>'] = { name = 'VISUAL <leader>' },
      }, { mode = 'v' })

      vim.keymap.set('n', '<Left>', MoveAndFoldLeft, {desc = "Move left, possibly closing folds."})
      vim.keymap.set('n', 'h',      MoveAndFoldLeft, {desc = "Move left, possibly closing folds."})
      vim.keymap.set('n', '<Right>', MoveAndFoldRight, {desc = "Move right, possibly opening folds."})
      vim.keymap.set('n', 'l',      MoveAndFoldRight, {desc = "Move right, possibly opening folds."})

      -- Treesitter for Ruby for some reason re-indents incorrectly every time you type '.'
      vim.api.nvim_create_autocmd("FileType", { pattern = "ruby", callback = function() vim.opt_local.indentkeys:remove('.') end })

    end
  }
}

