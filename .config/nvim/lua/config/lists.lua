-- Markdown list and blockquote continuation on <CR>, as typed keys.
--
-- newline_keys returns the keys an expr mapping should produce for Enter at
-- a given cursor position: backspaces, <CR>, the next item's marker. Typed
-- keys land in the redo buffer, so `cw<CR>` on a list item dot-repeats. A
-- buffer edit from Lua would not. The two exceptions, renumbering an ordered
-- list and removing an unused item, run from a <Cmd> at the end of the key
-- string; they happen once and are not replayed by `.`.
--
-- The key strings rely on 'autoindent': <CR> copies the current line's
-- indent to the new line and drops leading whitespace from the moved tail.
-- Inside a blockquote the indent sits after the leader, where autoindent
-- does not see it, so it is typed.

local blockquote = require('config.blockquote')

local M = {}

-- Parse a CommonMark list item body (after any quote leader). Returns
-- { indent, marker, number, delim, checkbox, prefix } or nil. prefix is
-- everything before the item text.
function M.parse(body)
  local indent, marker, pad = body:match('^(%s*)([%-*+])(%s+)')
  local number, delim
  if not marker then
    indent, number, delim, pad = body:match('^(%s*)(%d+)([%.%)])(%s+)')
    if not number then return nil end
    marker = number .. delim
    number = tonumber(number)
  end
  local prefix = indent .. marker .. pad
  local checkbox, cpad = body:match('^(%[[ xX]%])(%s+)', #prefix + 1)
  if checkbox then prefix = prefix .. checkbox .. cpad end
  return {
    indent = indent,
    marker = marker,
    number = number,
    delim = delim,
    checkbox = checkbox,
    prefix = prefix,
  }
end

-- The prefix for the item after `item`. opts.nest indents by
-- opts.indent_unit and restarts numbering.
function M.next_prefix(item, opts)
  local indent = item.indent
  local marker = item.marker
  if opts.nest then
    indent = indent .. opts.indent_unit
    if item.number then marker = '1' .. item.delim end
  elseif item.number then
    marker = tostring(item.number + 1) .. item.delim
  end
  local checkbox = item.checkbox and '[ ] ' or ''
  return indent .. marker .. ' ' .. checkbox
end

local RENUMBER = "<Cmd>lua require('config.lists').renumber()<CR>"
local CLEAR = "<Cmd>lua require('config.lists').clear_item()<CR>"

-- Whitespace as keys that insert it literally: a typed <Tab> would expand
-- under 'expandtab'.
local function typed(ws)
  return (ws:gsub('\t', '<C-v><Tab>'))
end

local function display_width(text, ws, tabstop)
  local vcol = vim.fn.strdisplaywidth(text)
  for ch in ws:gmatch('.') do
    vcol = ch == '\t' and (math.floor(vcol / tabstop) + 1) * tabstop or vcol + 1
  end
  return vcol
end

-- How many <BS> remove the whitespace run `ws` that follows `text`. With
-- 'softtabstop' set, one <BS> over whitespace deletes back to the previous
-- softtabstop column (whitespace only), so the count is simulated rather
-- than one per byte.
local function backspaces(text, ws, opts)
  local sts = opts.softtabstop or 0
  if ws == '' then return 0 end
  if sts <= 0 then return #ws end
  local count = 0
  while #ws > 0 do
    count = count + 1
    local want = math.floor((display_width(text, ws, opts.tabstop) - 1) / sts) * sts
    repeat
      ws = ws:sub(1, -2)
    until #ws == 0 or display_width(text, ws, opts.tabstop) <= want
  end
  return count
end

-- Keys for <CR> at byte offset `col` (0-based) of `line`. opts: indent_unit,
-- softtabstop (effective value, 0 for off), tabstop.
function M.newline_keys(line, col, opts)
  local leader, body = blockquote.split(line)
  local item = M.parse(body)
  if leader == '' and not item then return '<CR>' end

  local prefix = leader .. (item and item.prefix or '')
  local head, tail = line:sub(1, col), line:sub(col + 1)

  -- An unused item or leader: remove it rather than continue it.
  if col >= #prefix and tail:match('^%s*$') and head:sub(#prefix + 1):match('^%s*$') then
    return CLEAR
  end
  if col <= #prefix then return '<CR>' end

  local keys = ''
  -- Drop the whitespace at the split point, but only when text moves down:
  -- trailing spaces at the end of a line are a hard break.
  if not tail:match('^%s*$') then
    local ws = head:match('%s*$')
    keys = string.rep('<BS>', backspaces(head:sub(1, #head - #ws), ws, opts))
  end
  -- Autoindent already copied whitespace before an indented leader.
  keys = keys .. '<CR>' .. typed((leader:gsub('^%s+', '')))

  if item then
    local nest = head:match(':%s*$') ~= nil
    local next_prefix = M.next_prefix(item, { indent_unit = opts.indent_unit, nest = nest })
    -- Autoindent already copied an indent that starts the line.
    if leader == '' then next_prefix = next_prefix:sub(#item.indent + 1) end
    keys = keys .. typed(next_prefix)
    if item.number then keys = keys .. RENUMBER end
  end
  return keys
end

-- Remove one layer from the cursor line: the list prefix if there is one,
-- else the quote leader.
function M.clear_item()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local leader, body = blockquote.split(vim.fn.getline(row))
  local new_line = M.parse(body) and leader or ''
  vim.fn.setline(row, new_line)
  vim.api.nvim_win_set_cursor(0, { row, #new_line })
end

local function depth(indent)
  return vim.fn.strdisplaywidth(indent)
end

-- Ordered lists are one kind per delimiter; all unordered items are one kind.
local function kind(item)
  return item.delim or 'unordered'
end

-- Renumber the ordered list block around the cursor line. The block is the
-- run of lines sharing the cursor line's quote leader whose body is a list
-- item or is indented deeper than the cursor item (continuation text). It
-- ends at a blank line or, at the cursor item's depth or shallower, at an
-- item of another kind: that starts a different list. One counter per
-- depth; deeper counters reset when the walk returns to a shallower item.
function M.renumber()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local leader, body = blockquote.split(vim.fn.getline(row))
  local cursor_item = M.parse(body)
  if not cursor_item or not cursor_item.number then return end
  local cursor_depth = depth(cursor_item.indent)

  local function in_block(lnum)
    local l, b = blockquote.split(vim.fn.getline(lnum))
    if l ~= leader or b:match('^%s*$') then return false end
    local it = M.parse(b)
    if not it then return depth(b:match('^%s*')) > cursor_depth end
    return depth(it.indent) > cursor_depth or kind(it) == kind(cursor_item)
  end

  local first, last = row, row
  while first > 1 and in_block(first - 1) do first = first - 1 end
  local line_count = vim.api.nvim_buf_line_count(0)
  while last < line_count and in_block(last + 1) do last = last + 1 end

  local counters = {}
  for lnum = first, last do
    local line = vim.fn.getline(lnum)
    local _, b = blockquote.split(line)
    local it = M.parse(b)
    if it then
      local d_item = depth(it.indent)
      for d in pairs(counters) do
        if d > d_item then counters[d] = nil end
      end
      if it.number then
        counters[d_item] = (counters[d_item] or 0) + 1
        local marker = tostring(counters[d_item]) .. it.delim
        if marker ~= it.marker then
          local new_line = leader .. it.indent .. marker .. b:sub(#it.indent + #it.marker + 1)
          vim.fn.setline(lnum, new_line)
          if lnum == row then col = col + #new_line - #line end
        end
      end
    end
  end
  vim.api.nvim_win_set_cursor(0, { row, math.max(0, col) })
end

return M
