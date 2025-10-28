-- See `:help mapleader`
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

require("lazy").setup("plugins")

-- [[ Setting options ]]

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- mine
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.joinspaces = false
vim.o.breakindent = true
vim.o.showbreak = '↳  '
vim.o.autowriteall = true
vim.o.undofile = true
vim.o.hidden = false
vim.o.equalalways = false
vim.o.cmdheight = 2
vim.o.foldlevel = 99

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Disable markdown folding.  We manage manually in after/ftplugin.
vim.g.vim_markdown_folding_disabled = 1

-- Splits

local function save_last_mode()
  vim.b._last_mode = vim.api.nvim_get_mode().mode
end

local function fn_to_save_mode_and_move(direction_key)
  local fn = function()
    save_last_mode()
    vim.cmd.wincmd(direction_key)
  end
  return fn
end

vim.keymap.set({'n', 't'}, '<C-h>', fn_to_save_mode_and_move("h"), {desc = "Move to window to the left."})
vim.keymap.set({'n', 't'}, '<C-j>', fn_to_save_mode_and_move("j"), {desc = "Move to window below."})
vim.keymap.set({'n', 't'}, '<C-k>', fn_to_save_mode_and_move("k"), {desc = "Move to window above."})
vim.keymap.set({'n', 't'}, '<C-l>', fn_to_save_mode_and_move("l"), {desc = "Move to window to the right."})

local function dirvish_vsplit()
  vim.cmd('vsplit')
  vim.cmd('Dirvish %')
end

local function dirvish_split()
  vim.cmd('split')
  vim.cmd('Dirvish %')
end

vim.keymap.set({'n', 't'}, '<C-Right>', dirvish_vsplit, {desc = "Open dirvish in a split to the right"})
vim.keymap.set({'n', 't'}, '<C-Down>',  dirvish_split, {desc = "Open dirvish in a split below"})

-- Terminal

vim.keymap.set('n', '<Leader>t', function()
  if vim.api.nvim_get_option_value('modified', {buf = 0}) then
    print("Buffer modified.  Save before replacing with a terminal")
    return nil
  end
  if not vim.api.nvim_buf_get_name(0) == "" then
    vim.cmd('lcd %:h')
  end

  local old_buf = vim.api.nvim_get_current_buf()
  vim.cmd('terminal')
  local term_buf = vim.api.nvim_get_current_buf()

  if not ( old_buf == term_buf ) then
    vim.api.nvim_buf_delete(old_buf, {})
  end
end)

local vim_term = vim.api.nvim_create_augroup('vim_term', { clear = true })
vim.api.nvim_create_autocmd('TermOpen', {
  callback = function()
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
    vim.cmd "startinsert!"
    save_last_mode()
  end,
  group = vim_term
})

vim.api.nvim_create_autocmd('TermClose', {
  callback = function()
    local buffers = vim.fn.getbufinfo({buflisted = 1, bufloaded = 1})
    if buffers and #buffers == 1 then
      local buffer = buffers[1]
      if buffer.name == "" and buffer.linecount == 1 and buffer.changed == 0 then
        vim.cmd.qall()
      end
    end
  end,
  group = vim_term
})

vim.api.nvim_create_autocmd('WinEnter', {
  pattern = "term://*",
  callback = function()
    if vim.b._last_mode == 't' then
      vim.cmd.startinsert()
    end
  end,
  group = vim_term
})

vim.keymap.set('t', "<c-u>", "<c-\\><c-n>")

-- Autocommands

local vim_group = vim.api.nvim_create_augroup('vim_group', { clear = true })

-- Show the cursorline in the active buffer
vim.api.nvim_create_autocmd({'VimEnter', 'WinEnter', 'BufWinEnter'}, { command = 'setlocal cursorline',   group = vim_group })
vim.api.nvim_create_autocmd('WinLeave',                              { command = 'setlocal nocursorline', group = vim_group })

-- highlight all search results only while searching
vim.api.nvim_create_autocmd('CmdlineEnter', { command = 'setlocal hlsearch',   pattern = '/,?', group = vim_group })
vim.api.nvim_create_autocmd('CmdlineLeave', { command = 'setlocal nohlsearch', pattern = '/,?', group = vim_group })

-- create parent directories on saved
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(event)
    -- Don't even for URLs
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
  group = vim_group
})

-- [[ Basic Keymaps ]]

-- Indenting
vim.keymap.set('v', '<Tab>',   '>gv', { silent = true, desc = "Indent selection" })
vim.keymap.set('v', '<S-Tab>', '<gv', { silent = true, desc = "Dendent selection" })
vim.keymap.set('n', '<Tab>',   '>>_', { silent = true, desc = "Indent line" })
vim.keymap.set('n', '<S-Tab>', '<<_', { silent = true, desc = "Dendent line" })

vim.keymap.set('n', 'gb', '<C-t>', {silent = true, desc = "[G]o [b]ack in tag stack"})

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Move line up/down
vim.keymap.set('n', '<c-s-down>', ":m .+1<CR>==",        {silent = true})
vim.keymap.set('n', '<c-s-up>',   ":m .-2<CR>==",        {silent = true})
vim.keymap.set('i', '<c-s-down>', "<Esc>:m .+1<CR>==gi", {silent = true})
vim.keymap.set('i', '<c-s-up>',   "<Esc>:m .-2<CR>==gi", {silent = true})
vim.keymap.set('v', '<c-s-down>', ":m '>+1<CR>gv=gv",    {silent = true})
vim.keymap.set('v', '<c-s-up>',   ":m '<-2<CR>gv=gv",    {silent = true})

vim.keymap.set('n', ';', ':', {silent = true, desc = "Command (replaces :)"})

vim.keymap.set('n', 'gp', '`[v`]', { noremap = true, silent = true, desc = 'Select last pasted text' })

-- Only in :help buffers:
vim.api.nvim_create_autocmd("FileType", {
  pattern = "help",
  callback = function()
    -- Map 'K' or Enter to jump to tag under cursor.  `gb` already replaces Ctrl-O for going back up the stack.
    vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<C-]>', {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(0, 'n', '<Enter>', '<C-]>', {noremap = true, silent = true})
  end
})

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({timeout = 600})
  end,
  group = highlight_group,
  pattern = '*',
})

require('lsp')

-- vim: ts=2 sts=2 sw=2 et
