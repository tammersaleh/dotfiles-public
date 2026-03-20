-- Minimal init for running plenary tests in headless mode.
-- Loads plenary from lazy's install path and puts this config on the rtp
-- so require('config.*') works in spec files.

local this_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h')
local root_dir = vim.fn.fnamemodify(this_dir, ':h')

vim.opt.rtp:prepend(root_dir)
vim.opt.rtp:prepend(vim.fn.stdpath('data') .. '/lazy/plenary.nvim')

-- Allow spec files to require('helpers')
package.path = this_dir .. '/?.lua;' .. package.path

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Predictable indent settings (vim-sleuth won't be loaded)
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.expandtab = true
vim.o.softtabstop = 2
