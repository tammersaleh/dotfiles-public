-- Search behavior

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Highlight all search results only while searching
local search_group = vim.api.nvim_create_augroup('vim_search', { clear = true })
vim.api.nvim_create_autocmd('CmdlineEnter', {
  command = 'setlocal hlsearch',
  pattern = '/,?',
  group = search_group
})
vim.api.nvim_create_autocmd('CmdlineLeave', {
  command = 'setlocal nohlsearch',
  pattern = '/,?',
  group = search_group
})
