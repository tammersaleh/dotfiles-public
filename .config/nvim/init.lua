--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--    https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  change_detection = { enabled = false },
})

-- Load configuration modules
require('config.filetypes')
require('config.editor')
require('config.ui')
require('config.search')
require('config.completion')
require('config.splits')
require('config.terminal')
require('config.mkdir_on_save')
require('config.keymaps')

require('lsp')

-- Test support
if #vim.api.nvim_list_uis() == 0 then
  vim.o.swapfile = false
  local config_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h')
  package.path = config_dir .. '/tests/?.lua;' .. package.path
end

-- vim: ts=2 sts=2 sw=2 et
