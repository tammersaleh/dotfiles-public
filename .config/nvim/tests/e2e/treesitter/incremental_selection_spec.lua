local h = require('helpers')

local function open_lua()
  local tmp = vim.fn.tempname() .. '.lua'
  vim.fn.writefile({
    'local function greet(name)',  -- 1
    '  return "hi " .. name',       -- 2
    'end',                           -- 3
  }, tmp)
  vim.cmd('edit ' .. vim.fn.fnameescape(tmp))
  vim.wait(500, function()
    return vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil
  end, 20)
end

local function visual_bounds()
  local s = vim.fn.getpos('v')
  local e = vim.fn.getpos('.')
  if s[2] > e[2] or (s[2] == e[2] and s[3] > e[3]) then
    s, e = e, s
  end
  return { s[2], s[3] - 1, e[2], e[3] - 1 }
end

-- Total chars covered (across lines).
local function bounds_size(b)
  if b[1] == b[3] then return (b[4] - b[2]) + 1 end
  return (b[3] - b[1]) * 10000 + (b[4] - b[2])
end

describe("treesitter incremental selection", function()
  it("<C-Space> in normal mode enters visual mode", function()
    open_lua()
    vim.api.nvim_win_set_cursor(0, { 2, 10 })
    h.feed('<C-Space>')
    assert.equals('v', h.get_mode())
    h.ensure_normal()
  end)

  it("<C-Space> in normal mode selects more than a single character (a real node)", function()
    open_lua()
    vim.api.nvim_win_set_cursor(0, { 2, 10 })  -- inside "hi "
    h.feed('<C-Space>')
    local b = visual_bounds()
    h.ensure_normal()
    assert.is_true(bounds_size(b) > 1,
      "expected <C-Space> to select more than 1 char, got bounds=" .. vim.inspect(b))
  end)

  it("repeated <C-Space> in visual mode expands the selection", function()
    open_lua()
    vim.api.nvim_win_set_cursor(0, { 2, 10 })
    h.feed('<C-Space>')
    local after_one = visual_bounds()
    h.feed('<C-Space>')
    local after_two = visual_bounds()
    h.feed('<C-Space>')
    local after_three = visual_bounds()
    h.ensure_normal()
    assert.is_true(bounds_size(after_two) > bounds_size(after_one),
      "expected expansion after 2 presses; after_one=" .. vim.inspect(after_one)
        .. " after_two=" .. vim.inspect(after_two))
    assert.is_true(bounds_size(after_three) > bounds_size(after_two),
      "expected continued expansion after 3 presses; after_two=" .. vim.inspect(after_two)
        .. " after_three=" .. vim.inspect(after_three))
  end)

  it("expansion eventually covers the entire function", function()
    open_lua()
    vim.api.nvim_win_set_cursor(0, { 2, 10 })
    h.feed('<C-Space>')
    for _ = 1, 10 do
      h.feed('<C-Space>')
    end
    local b = visual_bounds()
    h.ensure_normal()
    assert.equals(1, b[1], "expected selection to cover full function (start line 1)")
    assert.equals(3, b[3], "expected selection to cover full function (end line 3)")
  end)

  it("<C-s> in visual mode is an alias for expand-to-parent", function()
    open_lua()
    vim.api.nvim_win_set_cursor(0, { 2, 10 })
    h.feed('<C-Space>')
    local after_csp = visual_bounds()
    h.feed('<C-s>')
    local after_cs = visual_bounds()
    h.ensure_normal()
    assert.is_true(bounds_size(after_cs) > bounds_size(after_csp),
      "expected <C-s> to expand; before=" .. vim.inspect(after_csp)
        .. " after=" .. vim.inspect(after_cs))
  end)
end)
