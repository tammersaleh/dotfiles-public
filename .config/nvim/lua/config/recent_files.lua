-- Most-recently-used file list. Seeded from v:oldfiles, kept current via
-- BufEnter. Backs the Neo-tree "recent" source.

local M = {}

local DEFAULT_LIMIT = 30

local entries = {}
local augroup

local function normalize(path)
  if type(path) ~= 'string' or path == '' then
    return nil
  end
  if path:find('^%w+://') then
    return nil
  end
  local abs = vim.fn.fnamemodify(path, ':p')
  if vim.fn.filereadable(abs) ~= 1 then
    return nil
  end
  -- Canonical form so /var/x and /private/var/x dedupe.
  return vim.uv.fs_realpath(abs) or abs
end

function M.clear()
  entries = {}
end

--- Move `path` to the front of the list. Ignores paths that are not
--- readable files.
function M.touch(path)
  local abs = normalize(path)
  if not abs then
    return
  end
  M.remove(abs)
  table.insert(entries, 1, abs)
end

function M.remove(path)
  for i, p in ipairs(entries) do
    if p == path then
      table.remove(entries, i)
      return
    end
  end
end

--- Return paths most recent first, dropping files that no longer exist.
function M.list(opts)
  local limit = opts and opts.limit or DEFAULT_LIMIT
  local out = {}
  local kept = {}
  for _, p in ipairs(entries) do
    if vim.fn.filereadable(p) == 1 then
      table.insert(kept, p)
      if #out < limit then
        table.insert(out, p)
      end
    end
  end
  entries = kept
  return out
end

local function track_current_buffer()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype ~= '' or not vim.bo[buf].buflisted then
    return
  end
  M.touch(vim.api.nvim_buf_get_name(buf))
end

--- Seed from v:oldfiles (behind anything already touched) and start
--- tracking BufEnter.
function M.setup()
  for _, p in ipairs(vim.v.oldfiles or {}) do
    local abs = normalize(p)
    if abs and not vim.tbl_contains(entries, abs) then
      table.insert(entries, abs)
    end
  end

  augroup = vim.api.nvim_create_augroup('RecentFiles', { clear = true })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = augroup,
    callback = track_current_buffer,
  })
end

return M
