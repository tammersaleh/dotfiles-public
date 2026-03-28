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

local function md_tab()
  local lnum = vim.fn.line('.')
  local line = vim.fn.getline(lnum)
  if is_bullet(line) or has_leading_whitespace(line) then
    vim.cmd('normal! >>')
  else
    local prefix = detect_bullet_style(lnum)
    vim.fn.setline(lnum, prefix .. line)
  end
end

local function md_stab()
  local line = vim.fn.getline('.')
  if is_top_level_bullet(line) then
    vim.cmd([[silent! s/^\s*\zs[-*+] //]])
    vim.cmd([[silent! s/^\s*\zs\d\+\. //]])
  elseif is_bullet(line) or has_leading_whitespace(line) then
    vim.cmd('normal! <<')
  end
end

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
