local ts_filetypes = {
  'bash',
  'c',
  'cpp',
  'css',
  'go',
  'html',
  'javascript',
  'javascriptreact',
  'json',
  'python',
  'ruby',
  'sh',
  'toml',
  'tsx',
  'typescript',
  'typescriptreact',
  'yaml',
}

local indent_filetypes = {
  'bash',
  'c',
  'cpp',
  'go',
  'javascript',
  'javascriptreact',
  'lua',
  'python',
  'sh',
  'tsx',
  'typescript',
  'typescriptreact',
}

local parsers = {
  'bash',
  'cpp',
  'css',
  'go',
  'html',
  'javascript',
  'json',
  'python',
  'ruby',
  'toml',
  'tsx',
  'typescript',
  'yaml',
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = function()
      require('nvim-treesitter').install(parsers):wait(300000)
    end,
    config = function()
      vim.treesitter.language.register('tsx', 'typescriptreact')
      vim.treesitter.language.register('javascript', 'javascriptreact')

      vim.treesitter.query.add_predicate('is-mise?', function(_, _, bufnr, _)
        local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
        local filename = vim.fn.fnamemodify(filepath, ':t')
        return string.match(filename, '.*mise.*%.toml$') ~= nil
      end, { force = true, all = false })

      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.opt.foldnestmax = 2

      local function MoveAndFoldLeft()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))

        if col == 0 and vim.fn.foldlevel(line) ~= 0 then
          vim.cmd.foldclose()
        else
          vim.cmd.normal { 'h', bang = true }
        end
      end

      local function MoveAndFoldRight()
        local line = vim.api.nvim_win_get_cursor(0)[1]

        if vim.fn.foldlevel(line) ~= 0 and vim.fn.foldclosed(line) ~= -1 then
          vim.cmd.foldopen()
        else
          vim.cmd.normal { 'l', bang = true }
        end
      end

      vim.keymap.set('n', '<Left>', MoveAndFoldLeft, { desc = 'Move left, possibly closing folds.' })
      vim.keymap.set('n', 'h', MoveAndFoldLeft, { desc = 'Move left, possibly closing folds.' })
      vim.keymap.set('n', '<Right>', MoveAndFoldRight, { desc = 'Move right, possibly opening folds.' })
      vim.keymap.set('n', 'l', MoveAndFoldRight, { desc = 'Move right, possibly opening folds.' })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = ts_filetypes,
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
        desc = 'Enable treesitter highlighting',
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = indent_filetypes,
        callback = function(ev)
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
        desc = 'Enable treesitter indent',
      })

      -- Treesitter Ruby re-indents incorrectly every time you type '.'
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'ruby',
        callback = function()
          vim.opt_local.indentkeys:remove '.'
        end,
      })

      vim.keymap.set('n', '<C-Space>', 'van', { remap = true, desc = 'TS: select node' })
      vim.keymap.set('x', '<C-Space>', 'an', { remap = true, desc = 'TS: expand to parent node' })
      vim.keymap.set('x', '<C-s>', 'an', { remap = true, desc = 'TS: expand to parent (scope alias)' })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = { lookahead = true },
        move = { set_jumps = true },
      }

      local select = require('nvim-treesitter-textobjects.select')
      local select_keymaps = {
        aa = '@parameter.outer',
        ia = '@parameter.inner',
        af = '@function.outer',
        ['if'] = '@function.inner',
        ac = '@class.outer',
        ic = '@class.inner',
      }
      for lhs, query in pairs(select_keymaps) do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(query, 'textobjects')
        end, { desc = 'TS select ' .. query })
      end

      local move = require('nvim-treesitter-textobjects.move')
      local move_groups = {
        { fn = move.goto_next_start,     maps = { [']m'] = '@function.outer', [']]'] = '@class.outer' } },
        { fn = move.goto_next_end,       maps = { [']M'] = '@function.outer', [']['] = '@class.outer' } },
        { fn = move.goto_previous_start, maps = { ['[m'] = '@function.outer', ['[['] = '@class.outer' } },
        { fn = move.goto_previous_end,   maps = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' } },
      }
      for _, group in ipairs(move_groups) do
        for lhs, query in pairs(group.maps) do
          vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
            group.fn(query, 'textobjects')
          end, { desc = 'TS move ' .. query })
        end
      end

      local swap = require('nvim-treesitter-textobjects.swap')
      vim.keymap.set('n', '<leader>a', function() swap.swap_next('@parameter.inner') end, { desc = 'TS swap parameter next' })
      vim.keymap.set('n', '<leader>A', function() swap.swap_previous('@parameter.inner') end, { desc = 'TS swap parameter previous' })
    end,
  },
}
