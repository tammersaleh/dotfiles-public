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

--- Assert a global keymap exists with the expected rhs.
function M.assert_keymap(mode, lhs, expected_rhs)
  for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
    if map.lhs == lhs then
      if expected_rhs then
        assert.equals(expected_rhs, map.rhs)
      end
      return map
    end
  end
  error("mapping " .. lhs .. " not found in mode " .. mode)
end

--- Assert a buffer-local keymap exists with the expected rhs.
function M.assert_buf_keymap(mode, lhs, expected_rhs)
  for _, map in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
    if map.lhs == lhs then
      if expected_rhs then
        assert.equals(expected_rhs, map.rhs)
      end
      return map
    end
  end
  error("buffer-local mapping " .. lhs .. " not found in mode " .. mode)
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
