-- gx: open URLs in the browser.
--
-- Normal mode looks at the whole line, not just the word under the cursor.
-- Cursor on a URL opens that one. Otherwise a lone URL opens directly and
-- several prompt via vim.ui.select. Visual mode collects URLs from the
-- selection. Only http(s) URLs count - no commit hashes, issue refs, or
-- web searches.

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
function M.find(line)
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

local function open_one_of(urls)
  if #urls == 0 then
    vim.notify("No URL found", vim.log.levels.INFO)
  elseif #urls == 1 then
    vim.ui.open(urls[1])
  else
    vim.ui.select(urls, { prompt = "Open URL:" }, function(choice)
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
  for _, m in ipairs(M.find(line)) do
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
  for _, line in ipairs(lines) do
    for _, m in ipairs(M.find(line)) do
      urls[#urls + 1] = m.url
    end
  end
  open_one_of(dedupe(urls))
end

vim.g.netrw_nogx = 1
vim.keymap.set("n", "gx", M.open_line, { desc = "Open URL(s) on line" })
vim.keymap.set("x", "gx", M.open_selection, { desc = "Open URL(s) in selection" })

return M
