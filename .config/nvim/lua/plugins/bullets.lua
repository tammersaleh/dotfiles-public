-- bullets.vim continues a list on <cr> only when the cursor is at the end of
-- the line. Breaking a long item into two (Enter mid-sentence) left the tail
-- of the item without a bullet. This wraps its <cr> mapping so a mid-item
-- split continues the list too, and so Enter inside a blockquote repeats the
-- `> ` leader.
--
-- bullets.vim knows nothing about blockquotes: every regex it has starts at
-- `^\s*`. Rather than teach it, each of its commands runs with the quote
-- leader stripped from the surrounding block of same-depth quote lines, then
-- the leader goes back on (see with_quote_stripped). That keeps its own
-- numbering, renumbering, and checkbox nesting intact inside a quote.
--
-- The wrapper goes through g:bullets_custom_mappings because bullets.vim
-- installs its buffer-local <cr> map from a FileType autocmd that runs after
-- after/ftplugin/markdown.lua. A mapping set in the ftplugin is overwritten.

-- Everything before the item text: indent, marker, checkbox, and the padding
-- after each. Covers the CommonMark markers only, not bullets.vim's alphabetic
-- and Roman lists.
local function bullet_prefix(line)
  local prefix = line:match('^%s*[%-*+]%s+') or line:match('^%s*%d+[%.%)]%s+')
  if not prefix then return nil end
  local checkbox = line:sub(#prefix + 1):match('^%[.%]%s+')
  return checkbox and prefix .. checkbox or prefix
end

local quote_prefix = require('config.blockquote').prefix

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

-- Repeat the quote leader on a new line, moving the text after the cursor
-- onto it. An empty quote line loses its leader instead, the same way
-- bullets.vim drops an unused bullet. Vim's own 'formatoptions' `r` flag
-- would do the repeat, but its `fb:-` entry then indents plain splits after
-- a list marker, and bullets.vim queues its fallback <cr> through feedkeys,
-- which lands after any keys typed behind it.
local function split_quote(prefix, line, row, col)
  local head = (line:sub(1, col):gsub('%s+$', ''))
  local tail = (line:sub(col + 1):gsub('^%s+', ''))
  if head == prefix:gsub('%s+$', '') and tail == '' then
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { '' })
    vim.api.nvim_win_set_cursor(0, { row, 0 })
    return
  end
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, { head, prefix .. tail })
  vim.api.nvim_win_set_cursor(0, { row + 1, #prefix })
end

-- bullets.vim decides what the next bullet looks like: numbering, checkbox
-- state, and whether a trailing colon nests it. It reads the current line to
-- do that, so split the line first, then move the text after the cursor down
-- onto the bullet it generates.
local function insert_new_bullet()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local prefix = bullet_prefix(line)
  -- Drop the whitespace around the split point. It was word spacing inside a
  -- sentence, not indentation.
  local head = (line:sub(1, col):gsub('%s+$', ''))
  local tail = prefix and (line:sub(col + 1):gsub('^%s+', '')) or ''

  -- Split only between two pieces of item text. The end of the line, a plain
  -- paragraph, and a cursor inside the marker are all bullets.vim's job.
  if not prefix or col <= #prefix or tail == '' then
    vim.cmd('InsertNewBullet')
    return
  end

  vim.api.nvim_buf_set_lines(0, row - 1, row, false, { head })
  vim.api.nvim_win_set_cursor(0, { row, #head })
  vim.cmd('InsertNewBullet')

  -- bullets.vim added no line: it does not recognize this marker and has
  -- queued a plain <cr> instead. Restore the line so that splits it.
  local new_row = vim.api.nvim_win_get_cursor(0)[1]
  if new_row == row then
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { line })
    vim.api.nvim_win_set_cursor(0, { row, col })
    return
  end

  local new_line = vim.api.nvim_buf_get_lines(0, new_row - 1, new_row, false)[1]
  vim.api.nvim_buf_set_lines(0, new_row - 1, new_row, false, { new_line .. tail })
  vim.api.nvim_win_set_cursor(0, { new_row, #new_line })
end

-- o: a quoted paragraph gets a new quoted line below; anything else goes
-- through bullets.vim (with the leader stripped for a quoted list item).
local function open_below()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.fn.getline(row)
  local quote = quote_prefix(line)
  if quote and not bullet_prefix(line:sub(#quote + 1)) then
    vim.fn.append(row, quote)
    vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
    vim.cmd('startinsert!')
    return
  end
  with_quote_stripped(function() vim.cmd('InsertNewBullet') end)
end

-- <cr>: a quoted list item goes through bullets.vim with the leader stripped;
-- a quoted paragraph repeats the leader; anything else is bullets.vim's job.
local function newline()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local quote = quote_prefix(line)
  if not quote or col < #quote then
    insert_new_bullet()
  elseif bullet_prefix(line:sub(#quote + 1)) then
    with_quote_stripped(insert_new_bullet)
  else
    split_quote(quote, line, row, col)
  end
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
      -- <C-]> expands a pending abbreviation first, as the default <cr>
      -- mapping does.
      { 'imap', '<cr>', '<C-]><Plug>(config-bullets-split-newline)' },
      { 'inoremap', '<C-cr>', '<cr>' }, -- newline without a bullet
      { 'nmap', 'o', '<Plug>(config-bullets-newline)' },
      { 'nmap', 'gN', '<Plug>(config-bullets-renumber)' },
      { 'xmap', 'gN', '<Plug>(config-bullets-renumber)' },
      { 'nmap', '<leader>x', '<Plug>(config-bullets-toggle-checkbox)' },
    }
  end,
  config = function()
    local function plug(mode, name, fn, desc)
      vim.keymap.set(mode, '<Plug>(config-bullets-' .. name .. ')', fn, { silent = true, desc = desc })
    end
    plug('i', 'split-newline', newline, "New bullet, splitting the item at the cursor")
    plug('n', 'newline', open_below, "New bullet or quote line below")
    plug('n', 'renumber', function() with_quote_stripped(function() vim.cmd('RenumberList') end) end,
      "Renumber list")
    plug('x', 'renumber', function() with_quote_stripped_visual(function() vim.cmd('RenumberSelection') end) end,
      "Renumber selected lines")
    plug('n', 'toggle-checkbox', function() with_quote_stripped(function() vim.cmd('ToggleCheckbox') end) end,
      "Toggle checkbox")
  end,
}
