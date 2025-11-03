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
  if not vim.api.nvim_buf_get_name(0) == "" then
    vim.cmd('lcd %:h')
  end

  local old_buf = vim.api.nvim_get_current_buf()
  vim.cmd('terminal')
  local term_buf = vim.api.nvim_get_current_buf()

  if not ( old_buf == term_buf ) then
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

-- Exit insert mode via ctrl-u
vim.keymap.set('t', "<c-u>", "<c-\\><c-n>", {desc = "Exit terminal insert mode"})
