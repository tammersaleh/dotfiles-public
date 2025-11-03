-- UI and display settings

-- Show line numbers
vim.wo.number = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Command line height
vim.o.cmdheight = 2

-- Start with all folds open
vim.o.foldlevel = 99

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({timeout = 600})
  end,
  group = highlight_group,
  pattern = '*',
})

-- Show the cursorline in the active buffer only
local vim_group = vim.api.nvim_create_augroup('vim_ui', { clear = true })
vim.api.nvim_create_autocmd({'VimEnter', 'WinEnter', 'BufWinEnter'}, {
  command = 'setlocal cursorline',
  group = vim_group
})
vim.api.nvim_create_autocmd('WinLeave', {
  callback = function()
    -- Don't hide cursorline when leaving neo-tree
    if vim.bo.filetype ~= 'neo-tree' then
      vim.wo.cursorline = false
    end
  end,
  group = vim_group
})
