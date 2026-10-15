-- gx: open URLs in the browser and file paths with the system opener.
--
-- Normal mode looks at the whole line, not just the word under the cursor.
-- Cursor on a target opens that one. Otherwise a lone target opens directly
-- and several prompt via vim.ui.select. Visual mode collects targets from the
-- selection. Targets are http(s) URLs and file paths that exist on disk - no
-- commit hashes, issue refs, or web searches.
--
-- A path candidate is a token delimited by whitespace, brackets, quotes, or
-- backticks, so `[x](./foo.md)` yields `./foo.md`; the label before `](`
-- is skipped. It must look like a path
-- (contain `/`, start with `~`, or end in an extension) and exist, so prose
-- like "the docs directory" never opens Finder. Relative paths resolve
-- against the buffer's directory, then cwd. A trailing `:LINE[:COL]` is
-- dropped from the path but kept in the span the cursor can land on.

local M = {}

-- RFC 3986 characters, plus a leading scheme.
local SCHEME = "[Hh][Tt][Tt][Pp][Ss]?://"
local URL = SCHEME .. "[%w%-%._~:/%?#%[%]@!%$&'%(%)%*%+,;=%%]+"

local CLOSER = { [")"] = "(", ["]"] = "[" }

-- A greedy match runs into whatever follows the URL. Cut it back to what a
-- human would read as one URL: stop at another scheme (comma-joined URLs),
-- stop at an unbalanced closer (markdown `](...)`), then drop trailing prose
-- punctuation. Balanced brackets survive: `Foo_(bar)`, `http://[::1]`.
local function trim(url)
  local next_scheme = url:find(SCHEME, 2)
  if next_scheme then
    url = url:sub(1, next_scheme - 1)
  end

  local depth = { ["("] = 0, ["["] = 0 }
  for i = 1, #url do
    local c = url:sub(i, i)
    if depth[c] then
      depth[c] = depth[c] + 1
    elseif CLOSER[c] then
      if depth[CLOSER[c]] == 0 then
        url = url:sub(1, i - 1)
        break
      end
      depth[CLOSER[c]] = depth[CLOSER[c]] - 1
    end
  end

  return (url:gsub("[%.,;:!%?'\">]+$", ""))
end

--- All URLs in `line` as { url = string, from = col, to = col } (1-indexed, inclusive).
function M.find_urls(line)
  local found = {}
  local pos = 1
  while true do
    local from, to = line:find(URL, pos)
    if not from then
      break
    end
    local url = trim(line:sub(from, to))
    found[#found + 1] = { url = url, from = from, to = from + #url - 1 }
    pos = from + #url
  end
  return found
end

local TOKEN = "[^%s%(%)%[%]<>\"'`]+"

local function looks_like_path(token)
  return token:find("/", 1, true) ~= nil or token:sub(1, 1) == "~" or token:match("%.%w+$") ~= nil
end

local function exists(path)
  return vim.uv.fs_stat(path) ~= nil
end

local function resolve(token, dir)
  local path = vim.fs.normalize(token)
  if path:sub(1, 1) == "/" then
    return exists(path) and path or nil
  end
  local bases = { vim.uv.cwd() }
  if dir then
    table.insert(bases, 1, dir)
  end
  for _, base in ipairs(bases) do
    local full = vim.fs.normalize(base .. "/" .. path)
    if exists(full) then
      return full
    end
  end
  return nil
end

--- All existing file paths in `line` as { url = abs_path, from = col, to = col }.
--- `dir` is the directory relative paths resolve against before cwd. `skip`
--- is a list of { from, to } spans to ignore (URLs).
function M.find_paths(line, dir, skip)
  local found = {}
  local pos = 1
  while true do
    local from, to = line:find(TOKEN, pos)
    if not from then
      break
    end
    pos = to + 1
    local covered = false
    for _, span in ipairs(skip or {}) do
      if from <= span.to and to >= span.from then
        covered = true
        break
      end
    end
    -- A markdown link label (`[label](...)`) is prose, not a path.
    local label = line:sub(to + 1, to + 2) == "]("
    if not covered and not label then
      local token = line:sub(from, to):gsub("[%.,;:!%?]+$", ""):gsub(":%d+:?%d*$", "")
      if looks_like_path(token) then
        local path = resolve(token, dir)
        if path then
          found[#found + 1] = { url = path, from = from, to = to }
        end
      end
    end
  end
  return found
end

--- All targets in `line`, URLs and paths, in column order.
function M.find(line, dir)
  local found = M.find_urls(line)
  for _, m in ipairs(M.find_paths(line, dir, found)) do
    found[#found + 1] = m
  end
  table.sort(found, function(a, b)
    return a.from < b.from
  end)
  return found
end

local function buf_dir()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" or vim.bo.buftype ~= "" then
    return nil
  end
  return vim.fs.dirname(name)
end

local function open_one_of(urls)
  if #urls == 0 then
    vim.notify("No URL or path found", vim.log.levels.INFO)
  elseif #urls == 1 then
    vim.ui.open(urls[1])
  else
    vim.ui.select(urls, { prompt = "Open:" }, function(choice)
      if choice then
        vim.ui.open(choice)
      end
    end)
  end
end

local function dedupe(urls)
  local seen, out = {}, {}
  for _, u in ipairs(urls) do
    if not seen[u] then
      seen[u] = true
      out[#out + 1] = u
    end
  end
  return out
end

function M.open_line()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local urls = {}
  for _, m in ipairs(M.find(line, buf_dir())) do
    if col >= m.from and col <= m.to then
      vim.ui.open(m.url)
      return
    end
    urls[#urls + 1] = m.url
  end
  open_one_of(dedupe(urls))
end

function M.open_selection()
  local mode = vim.fn.mode()
  local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
  vim.cmd.normal({ "\27", bang = true })
  local urls = {}
  local dir = buf_dir()
  for _, line in ipairs(lines) do
    for _, m in ipairs(M.find(line, dir)) do
      urls[#urls + 1] = m.url
    end
  end
  open_one_of(dedupe(urls))
end

vim.g.netrw_nogx = 1
vim.keymap.set("n", "gx", M.open_line, { desc = "Open URL/path on line" })
vim.keymap.set("x", "gx", M.open_selection, { desc = "Open URL/path in selection" })

return M
