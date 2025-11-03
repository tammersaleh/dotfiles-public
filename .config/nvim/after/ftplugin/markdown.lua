-- Markdown configuration

-- Open current file in mark
vim.keymap.set('n', '<leader>o', ':!mark "%"<CR><CR>', {buffer = true, desc = "Open in mark"})
vim.keymap.set('n', '<leader>m', ':silent! !mark %<CR>:redraw!<CR>', {buffer = true, silent = true, desc = "Mark file"})

-- Visual mode list formatting
vim.keymap.set('v', '-', ':s/^/- /<CR>:noh<CR>', {buffer = true, desc = "Add bullet points"})
vim.keymap.set('v', '*', ':s/^/* /<CR>:noh<CR>', {buffer = true, desc = "Add asterisk bullets"})
vim.keymap.set('v', '#', ':s/^/1. /<CR>:noh<CR>', {buffer = true, desc = "Add numbered list"})

-- Align GitHub-Flavored Markdown tables with Space-|
-- https://www.statusok.com/align-markdown-tables-vim
vim.keymap.set('v', '<Leader>\\', ':EasyAlign*<Bar><CR>', {buffer = true, desc = "Align markdown table"})

-- Use K on top of a word to look it up in Dictionary.app
vim.keymap.set('n', 'K', ':silent !open dict://<cword><CR><CR>', {buffer = true, silent = true, desc = "Look up in dictionary"})

-- Simple markdown folding based on headers
local function markdown_fold_expr()
  local line = vim.fn.getline(vim.v.lnum)
  local next_line = vim.fn.getline(vim.v.lnum + 1)

  -- ATX-style headers (# Header)
  local level = line:match('^(#+)%s')
  if level then
    return '>' .. #level
  end

  -- Setext-style headers (underlined with = or -)
  if next_line:match('^=+%s*$') then
    return '>1'
  elseif next_line:match('^%-+%s*$') then
    return '>2'
  end

  return '='
end

vim.opt_local.foldexpr = 'v:lua.markdown_fold_expr()'
vim.opt_local.foldmethod = 'expr'

-- Other markdown settings
vim.opt_local.conceallevel = 0
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.linebreak = true
vim.opt_local.foldenable = true
vim.opt_local.spell = true

-- Make the fold function globally accessible
_G.markdown_fold_expr = markdown_fold_expr
