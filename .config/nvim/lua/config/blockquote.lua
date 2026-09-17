-- Markdown blockquote leaders: "> ", "> > ", ">". Shared by the markdown
-- ftplugin and the bullets.vim wrapper so both agree on where a quote ends
-- and the list body begins.
local M = {}

-- The leader: leading whitespace, one or more ">" (each optionally preceded
-- by whitespace), and at most one space after the last ">". Any further
-- indentation belongs to the body, since that is list nesting.
function M.prefix(line)
  local pos = line:match('^%s*>()')
  if not pos then return nil end
  while true do
    local next_pos = line:match('^%s*>()', pos)
    if not next_pos then break end
    pos = next_pos
  end
  if line:sub(pos, pos) == ' ' then pos = pos + 1 end
  return line:sub(1, pos - 1)
end

-- Leader (or "") and the body after it.
function M.split(line)
  local prefix = M.prefix(line) or ''
  return prefix, line:sub(#prefix + 1)
end

return M
