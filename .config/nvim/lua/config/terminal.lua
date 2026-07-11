-- Terminal configuration

-- Function to save the last mode (used by splits.lua too, but defined locally here for terminal windows)
local function save_last_mode()
  vim.b._last_mode = vim.api.nvim_get_mode().mode
end

-- Open terminal in current buffer
vim.keymap.set('n', '<Leader>t', function()
  if vim.api.nvim_get_option_value('modified', {buf = 0}) then
    print("Buffer modified.  Save before replacing with a terminal")
    return nil
  end
  if vim.api.nvim_buf_get_name(0) ~= "" then
    vim.cmd('lcd %:h')
  end

  local old_buf = vim.api.nvim_get_current_buf()
  vim.cmd('terminal')
  local term_buf = vim.api.nvim_get_current_buf()

  if old_buf ~= term_buf then
    vim.api.nvim_buf_delete(old_buf, {})
  end
end, {desc = "Open terminal in current buffer"})

-- Terminal autocommands
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

-- Close the terminal as soon as its shell exits, regardless of exit code.
-- Neovim otherwise leaves the buffer showing "[Process exited N]" until a key
-- is pressed. If the terminal is the whole editor, quit; otherwise just close
-- it (dropping a split, returning to the alternate file).
vim.api.nvim_create_autocmd('TermClose', {
  callback = function(args)
    local buf = args.buf
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      if #vim.api.nvim_list_tabpages() == 1 and #vim.api.nvim_list_wins() == 1 then
        vim.cmd.quitall()
      else
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end)
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

-- Exit insert mode via ctrl-u
vim.keymap.set('t', "<c-u>", "<c-\\><c-n>", {desc = "Exit terminal insert mode"})
