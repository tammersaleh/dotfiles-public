-- bullets.vim continues a list on <cr> only when the cursor is at the end of
-- the line. Breaking a long item into two (Enter mid-sentence) left the tail
-- of the item without a bullet. This wraps its <cr> mapping so a mid-item
-- split continues the list too.
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
      { 'nmap', 'o', '<Plug>(bullets-newline)' },
      { 'nmap', 'gN', '<Plug>(bullets-renumber)' },
      { 'vmap', 'gN', '<Plug>(bullets-renumber)' },
      { 'nmap', '<leader>x', '<Plug>(bullets-toggle-checkbox)' },
    }
  end,
  config = function()
    vim.keymap.set('i', '<Plug>(config-bullets-split-newline)', insert_new_bullet,
      { silent = true, desc = "New bullet, splitting the item at the cursor" })
  end,
}
