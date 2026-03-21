-- Minimal init for unit tests.
-- Loads plenary and this config on the rtp, but no plugins.

local this_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h')
local tests_dir = vim.fn.fnamemodify(this_dir, ':h')
local root_dir = vim.fn.fnamemodify(tests_dir, ':h')

vim.opt.rtp:prepend(root_dir)
vim.opt.rtp:prepend(vim.fn.stdpath('data') .. '/lazy/plenary.nvim')

-- Allow spec files to require('helpers')
package.path = tests_dir .. '/?.lua;' .. package.path

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.swapfile = false

vim.cmd('filetype plugin indent on')

-- Predictable indent settings (vim-sleuth won't be loaded)
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.expandtab = true
vim.o.softtabstop = 2
