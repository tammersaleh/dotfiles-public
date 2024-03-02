--[[
  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/

  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html
--]]

-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
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

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
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

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

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
-- Better tab-completion

local function is_after_whitespace()
  local prev_col = vim.fn.col(".") - 1
  local prev_char = vim.fn.getline("."):sub(prev_col, prev_col)
  if prev_col == 0 then
    return true
  elseif prev_char:match("%s") == nil then
    return false
  else
    return true
  end
end

local function possible_autocomplete_forward()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  elseif is_after_whitespace() then
    return "<Tab>"
  else
    return "<C-n>"
  end
end

local function possible_autocomplete_backward()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  elseif is_after_whitespace() then
    return "<S-Tab>"
  else
    return "<C-n>"
  end
end

vim.keymap.set('i', '<Tab>',   possible_autocomplete_forward,  {silent = true, expr = true})
vim.keymap.set('i', '<S-Tab>', possible_autocomplete_backward, {silent = true, expr = true})

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,         { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next,         { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

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

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end
vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sgf', require('telescope.builtin').git_files, { desc = '[S]earch [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

-- vim: ts=2 sts=2 sw=2 et
