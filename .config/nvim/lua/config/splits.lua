-- Window and split behavior

-- Split behavior options
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.equalalways = true

-- resize splits when terminal resized
local vim_resized = vim.api.nvim_create_augroup('vim_resized', { clear = true })
vim.api.nvim_create_autocmd("VimResized", {
  pattern = "*",
  command = "wincmd =",
  group = vim_resized,
})

-- Window navigation with mode preservation
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

-- Split to a file, or focus its window if one already shows it. Used by ~/bin/v.
vim.api.nvim_create_user_command('SplitOrFocus', function(opts)
  local path = vim.fn.fnamemodify(opts.args, ':p')
  local win = vim.fn.bufwinid(vim.fn.bufnr(path))
  if win ~= -1 then
    vim.api.nvim_set_current_win(win)
  else
    vim.cmd.split(vim.fn.fnameescape(path))
  end
end, { nargs = 1, desc = "Split to a file, or focus its existing window." })
