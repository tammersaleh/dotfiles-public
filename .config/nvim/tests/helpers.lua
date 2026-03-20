-- Test helpers for nvim config tests.
-- Provides buffer manipulation and keystroke simulation for
-- testing keymap behavior in a real nvim instance.

local M = {}

--- Replace buffer contents with the given lines.
function M.set_buf(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

--- Return buffer contents as a table of lines.
function M.get_buf()
  return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

--- Set cursor position. Row is 1-indexed, col is 0-indexed (defaults to 0).
function M.set_cursor(row, col)
  vim.api.nvim_win_set_cursor(0, { row, col or 0 })
end

--- Return cursor position as {row, col}.
function M.get_cursor()
  return vim.api.nvim_win_get_cursor(0)
end

--- Feed keystrokes as if typed, processing mappings.
--- Keys are executed synchronously before returning.
function M.feed(keys)
  local termcodes = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(termcodes, 'x', false)
end

--- Return the current mode string (e.g. "n", "i", "v", "V").
function M.get_mode()
  return vim.api.nvim_get_mode().mode
end

--- Escape to normal mode.
function M.ensure_normal()
  M.feed('<Esc>')
end

--- Open a fresh empty buffer with predictable settings.
function M.reset()
  vim.cmd('enew!')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { '' })
  M.ensure_normal()
  vim.bo.shiftwidth = 2
  vim.bo.tabstop = 2
  vim.bo.expandtab = true
  vim.bo.softtabstop = 2
end

return M
