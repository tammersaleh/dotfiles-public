-- bullets.vim provides gN (renumber) and <leader>x (toggle checkbox). On a
-- line without a checkbox, <leader>x toggles the nearest ancestor item that
-- has one (config.lists.checkbox_row).
-- Insert-mode <cr> and normal-mode o are ours, in after/ftplugin/markdown.lua
-- via lua/config/lists.lua, so that a split dot-repeats; bullets.vim adds its
-- new bullet with append(), which `.` cannot replay.
--
-- bullets.vim knows nothing about blockquotes: every regex it has starts at
-- `^\s*`. Rather than teach it, each of its commands runs with the quote
-- leader stripped from the surrounding block of same-depth quote lines, then
-- the leader goes back on (see with_quote_stripped). That keeps its own
-- numbering and checkbox handling intact inside a quote.
--
-- The mappings go through g:bullets_custom_mappings because bullets.vim
-- installs its buffer-local maps from a FileType autocmd that runs after
-- after/ftplugin/markdown.lua. A mapping set in the ftplugin is overwritten.

local quote_prefix = require('config.blockquote').prefix
local quote_split = require('config.blockquote').split

-- Run fn with the quote leader removed from the block of lines around the
-- cursor that share the cursor line's exact leader (or from first..last when
-- given), then put the leader back. Lines fn adds take the cursor line's
-- leader; a depth change ends the block. Without a leader, fn runs as is.
local function with_quote_stripped(fn, first, last)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local prefix = quote_prefix(vim.fn.getline(row))
  if not prefix then return fn() end

  local line_count = vim.api.nvim_buf_line_count(0)
  local s, e = first or row, last or row
  if not first then
    while s > 1 and quote_prefix(vim.fn.getline(s - 1)) == prefix do s = s - 1 end
    while e < line_count and quote_prefix(vim.fn.getline(e + 1)) == prefix do e = e + 1 end
  end

  -- setline, not nvim_buf_set_lines: replacing a range moves the '< and '>
  -- marks that RenumberSelection reads.
  for lnum = s, e do
    vim.fn.setline(lnum, vim.fn.getline(lnum):sub(#prefix + 1))
  end
  vim.api.nvim_win_set_cursor(0, { row, math.max(0, col - #prefix) })

  fn()

  e = e + vim.api.nvim_buf_line_count(0) - line_count
  for lnum = s, e do
    vim.fn.setline(lnum, prefix .. vim.fn.getline(lnum))
  end
  local new_row, new_col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_win_set_cursor(0, { new_row, new_col + #prefix })
end

-- Visual variant: the block is the selection itself.
local function with_quote_stripped_visual(fn)
  local s, e = vim.fn.line('v'), vim.fn.line('.')
  if s > e then s, e = e, s end
  vim.cmd('normal! \27')
  with_quote_stripped(fn, s, e)
end

return {
  'dkarter/bullets.vim',
  init = function()
    -- Declare the mappings by hand. The defaults also take >>, <<, > and <
    -- for promote/demote, which shadows the indent operators and duplicates
    -- the Tab/S-Tab cycling in after/ftplugin/markdown.lua.
    vim.g.bullets_set_mappings = 0
    -- On and off only. The default ' .oOX' adds partial-completion states.
    vim.g.bullets_checkbox_markers = ' x'
    vim.g.bullets_custom_mappings = {
      { 'nmap', 'gN', '<Plug>(config-bullets-renumber)' },
      { 'xmap', 'gN', '<Plug>(config-bullets-renumber)' },
      { 'nmap', '<leader>x', '<Plug>(config-bullets-toggle-checkbox)' },
    }
  end,
  config = function()
    local function plug(mode, name, fn, desc)
      vim.keymap.set(mode, '<Plug>(config-bullets-' .. name .. ')', fn, { silent = true, desc = desc })
    end
    plug('n', 'renumber', function() with_quote_stripped(function() vim.cmd('RenumberList') end) end,
      "Renumber list")
    plug('x', 'renumber', function() with_quote_stripped_visual(function() vim.cmd('RenumberSelection') end) end,
      "Renumber selected lines")
    -- On a line without a checkbox, toggle the nearest ancestor's instead.
    -- The cursor moves there first so with_quote_stripped strips the right
    -- block, then comes back.
    --
    -- bullets.vim's nested toggle sets every child item by replacing the
    -- character after "- [", whether or not the child is a checkbox, so
    -- "- [Link](url)" becomes "- [xink](url)". Lines that were not checkbox
    -- items before the toggle are restored afterwards.
    plug('n', 'toggle-checkbox', function()
      local lists = require('config.lists')
      local cursor = vim.api.nvim_win_get_cursor(0)
      local row = lists.checkbox_row(cursor[1])
      if not row then return end
      local before = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      vim.api.nvim_win_set_cursor(0, { row, 0 })
      with_quote_stripped(function() vim.cmd('ToggleCheckbox') end)
      for lnum, old in ipairs(before) do
        if vim.fn.getline(lnum) ~= old then
          local _, body = quote_split(old)
          local item = lists.parse(body)
          if not (item and item.checkbox) then vim.fn.setline(lnum, old) end
        end
      end
      vim.api.nvim_win_set_cursor(0, cursor)
    end, "Toggle checkbox")
  end,
}
