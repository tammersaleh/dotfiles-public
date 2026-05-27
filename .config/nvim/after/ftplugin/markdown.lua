-- Markdown configuration

-------------------------------------------------------------------------------
-- Keymaps
-------------------------------------------------------------------------------

-- Open current file in mark
vim.keymap.set('n', '<leader>o', ':!mark "%"<CR><CR>', {buffer = true, desc = "Open in mark"})
vim.keymap.set('n', '<leader>m', ':silent! !mark %<CR>:redraw!<CR>', {buffer = true, silent = true, desc = "Mark file"})

-- Visual mode list formatting
vim.keymap.set('v', '-', ':s/^/- /<CR>:noh<CR>', {buffer = true, desc = "Add bullet points"})
vim.keymap.set('v', '*', ':s/^/* /<CR>:noh<CR>', {buffer = true, desc = "Add asterisk bullets"})
vim.keymap.set('v', '#', ':s/^/1. /<CR>:noh<CR>', {buffer = true, desc = "Add numbered list"})

-- Align GitHub-Flavored Markdown tables with Space-|
-- https://www.statusok.com/align-markdown-tables-vim
vim.keymap.set('v', '<Leader>\\', ':EasyAlign*<Bar><CR>', {buffer = true, desc = "Align markdown table"})

-- Use K on top of a word to look it up in Dictionary.app
vim.keymap.set('n', 'K', ':silent !open dict://<cword><CR><CR>', {buffer = true, silent = true, desc = "Look up in dictionary"})

-------------------------------------------------------------------------------
-- Folding
-------------------------------------------------------------------------------

local function markdown_fold_expr()
  local line = vim.fn.getline(vim.v.lnum)
  local next_line = vim.fn.getline(vim.v.lnum + 1)

  -- ATX-style headers (# Header)
  local level = line:match('^(#+)%s')
  if level then
    return '>' .. #level
  end

  -- Setext-style headers (underlined with = or -)
  if next_line:match('^=+%s*$') then
    return '>1'
  elseif next_line:match('^%-+%s*$') then
    return '>2'
  end

  return '='
end

_G.markdown_fold_expr = markdown_fold_expr

vim.opt_local.foldexpr = 'v:lua.markdown_fold_expr()'
vim.opt_local.foldmethod = 'expr'

-------------------------------------------------------------------------------
-- Bullet cycling: paragraph ↔ bullet ↔ sub-bullet
--
-- Tab on a plain line adds a bullet (matching nearby style).
-- Tab on a bullet or indented line indents.
-- S-Tab on an indented bullet/line dedents.
-- S-Tab on a top-level bullet removes it.
-------------------------------------------------------------------------------

local function heading_level(line)
  local hashes = line:match('^(#+)%s')
  return hashes and #hashes or nil
end

local function is_bullet(line)
  return line:match('^%s*[%-*+]%s') or line:match('^%s*%d+%.%s')
end

local function is_top_level_bullet(line)
  return line:match('^[%-*+]%s') or line:match('^%d+%.%s')
end

local function has_leading_whitespace(line)
  return line:match('^%s+') ~= nil
end

-- Scans nearest above, then below for a bullet to match.
-- Falls back to the most common style in the buffer, or "- ".
local function detect_bullet_style(lnum)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for i = lnum - 1, 1, -1 do
    local num = lines[i]:match('^(%d+)%.%s')
    if num then return tostring(tonumber(num) + 1) .. '. ' end
    local char = lines[i]:match('^%s*([%-*+])%s')
    if char then return char .. ' ' end
  end

  for i = lnum + 1, #lines do
    local num = lines[i]:match('^(%d+)%.%s')
    if num then return tostring(math.max(1, tonumber(num) - 1)) .. '. ' end
    local char = lines[i]:match('^%s*([%-*+])%s')
    if char then return char .. ' ' end
  end

  local counts = { ['-'] = 0, ['*'] = 0, ['+'] = 0 }
  for _, l in ipairs(lines) do
    local char = l:match('^%s*([%-*+])%s')
    if char then counts[char] = counts[char] + 1 end
  end
  local best, best_count = '-', 0
  for char, count in pairs(counts) do
    if count > best_count then
      best, best_count = char, count
    end
  end
  return best .. ' '
end

local function indent_unit()
  return vim.bo.expandtab and string.rep(' ', vim.bo.shiftwidth) or '\t'
end

local function indent_line_text(lnum)
  vim.fn.setline(lnum, indent_unit() .. vim.fn.getline(lnum))
end

local function dedent_line_text(lnum)
  local line = vim.fn.getline(lnum)
  local stripped = (line:gsub('^' .. indent_unit(), '', 1))
  if stripped == line then stripped = (line:gsub('^%s+', '', 1)) end
  vim.fn.setline(lnum, stripped)
end

local function remove_bullet_prefix(lnum)
  local line = vim.fn.getline(lnum)
  local stripped = (line:gsub('^(%s*)[%-*+]%s', '%1', 1))
  stripped = (stripped:gsub('^(%s*)%d+%.%s', '%1', 1))
  vim.fn.setline(lnum, stripped)
end

-- When a line is rewritten (bullet added, indented, dedented, etc.) the
-- cursor stays at its old byte column, which puts it in the wrong place
-- relative to the text. Capture the cursor before the rewrite (setline
-- auto-clamps to the new line length, losing info) and shift by the delta.
local function capture_cursor(lnum)
  local cursor = vim.api.nvim_win_get_cursor(0)
  return cursor[1] == lnum and cursor[2] or nil
end

local function adjust_cursor(lnum, original_col, delta)
  if original_col == nil or delta == 0 then return end
  local line_len = #vim.fn.getline(lnum)
  local mode = vim.api.nvim_get_mode().mode
  local max_col = vim.startswith(mode, 'i') and line_len or math.max(0, line_len - 1)
  local new_col = math.max(0, math.min(original_col + delta, max_col))
  vim.api.nvim_win_set_cursor(0, { lnum, new_col })
end

local function tab_line(lnum)
  local line = vim.fn.getline(lnum)
  local old_len = #line
  local original_col = capture_cursor(lnum)
  local level = heading_level(line)
  if level then
    if level < 6 then vim.fn.setline(lnum, '#' .. line) end
  elseif is_bullet(line) or has_leading_whitespace(line) then
    indent_line_text(lnum)
  else
    local prefix = detect_bullet_style(lnum)
    vim.fn.setline(lnum, prefix .. line)
  end
  adjust_cursor(lnum, original_col, #vim.fn.getline(lnum) - old_len)
end

local function stab_line(lnum)
  local line = vim.fn.getline(lnum)
  local old_len = #line
  local original_col = capture_cursor(lnum)
  local level = heading_level(line)
  if level then
    if level > 1 then vim.fn.setline(lnum, line:sub(2)) end
  elseif is_top_level_bullet(line) then
    remove_bullet_prefix(lnum)
  elseif is_bullet(line) or has_leading_whitespace(line) then
    dedent_line_text(lnum)
  end
  adjust_cursor(lnum, original_col, #vim.fn.getline(lnum) - old_len)
end

local function md_tab()
  tab_line(vim.fn.line('.'))
end

local function md_stab()
  stab_line(vim.fn.line('.'))
end

local function for_visual_range(fn, saturated_at)
  local s, e = vim.fn.line('v'), vim.fn.line('.')
  if s > e then s, e = e, s end
  vim.cmd('normal! \27')

  local levels, has_heading, saturated = {}, false, false
  for lnum = s, e do
    local level = heading_level(vim.fn.getline(lnum))
    levels[lnum] = level
    if level then
      has_heading = true
      if level == saturated_at then saturated = true end
    end
  end

  if not (has_heading and saturated) then
    for lnum = s, e do
      if not has_heading or levels[lnum] then fn(lnum) end
    end
  end

  vim.cmd('normal! gv')
end

local function md_tab_visual() for_visual_range(tab_line, 6) end
local function md_stab_visual() for_visual_range(stab_line, 1) end

local function with_cmp(cmp_action, fallback)
  return function()
    local ok, cmp = pcall(require, 'cmp')
    if ok and cmp.visible() then
      cmp_action(cmp)
      return
    end
    fallback()
  end
end

vim.keymap.set('n', '<Tab>', md_tab, { buffer = true, silent = true, desc = "Bullet cycle forward" })
vim.keymap.set('n', '<S-Tab>', md_stab, { buffer = true, silent = true, desc = "Bullet cycle backward" })
vim.keymap.set('x', '<Tab>', md_tab_visual, { buffer = true, silent = true, desc = "Bullet cycle forward" })
vim.keymap.set('x', '<S-Tab>', md_stab_visual, { buffer = true, silent = true, desc = "Bullet cycle backward" })
vim.keymap.set('i', '<Tab>', with_cmp(function(cmp) cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert }) end, md_tab), { buffer = true, silent = true, desc = "Bullet cycle forward" })
vim.keymap.set('i', '<S-Tab>', with_cmp(function(cmp) cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert }) end, md_stab), { buffer = true, silent = true, desc = "Bullet cycle backward" })

-------------------------------------------------------------------------------
-- Options
-------------------------------------------------------------------------------

vim.opt_local.conceallevel = 0
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.linebreak = true
vim.opt_local.foldenable = true
vim.opt_local.spell = true
