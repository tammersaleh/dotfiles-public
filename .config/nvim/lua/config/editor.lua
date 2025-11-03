-- Editing behavior options

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true
vim.o.showbreak = '↳  '

-- Don't add two spaces after punctuation when joining lines
vim.o.joinspaces = false

-- Save undo history
vim.o.undofile = true

-- Save all buffers when focus is lost
vim.o.autowriteall = true

-- Disable abandoned buffers instead of hiding them
vim.o.hidden = false

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
