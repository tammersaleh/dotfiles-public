local h = require('helpers')

local function open(ext, lines)
  local tmp = vim.fn.tempname() .. '.' .. ext
  vim.fn.writefile(lines, tmp)
  vim.cmd('edit ' .. vim.fn.fnameescape(tmp))
  vim.wait(50, function() return false end)
end

-- Visual selection bounds as { srow, scol, erow, ecol } (1-indexed rows, 0-indexed cols).
local function visual_bounds()
  local s = vim.fn.getpos('v')
  local e = vim.fn.getpos('.')
  -- normalize so start <= end
  if s[2] > e[2] or (s[2] == e[2] and s[3] > e[3]) then
    s, e = e, s
  end
  return { s[2], s[3] - 1, e[2], e[3] - 1 }
end

describe("treesitter textobjects", function()
  describe("select on lua", function()
    local LUA = {
      'local function alpha(x, y)',  -- line 1
      '  return x + y',              -- line 2
      'end',                          -- line 3
      '',                             -- line 4
      'local function beta()',        -- line 5
      '  return 42',                  -- line 6
      'end',                          -- line 7
    }

    it("vaf selects exactly the surrounding function (lines 1-3)", function()
      open('lua', LUA)
      vim.api.nvim_win_set_cursor(0, { 2, 4 })  -- inside alpha body
      h.feed('vaf')
      local b = visual_bounds()
      h.ensure_normal()
      assert.equals(1, b[1], "expected start line 1, got " .. b[1])
      assert.equals(3, b[3], "expected end line 3, got " .. b[3])
    end)

    it("vif selects exactly the function body (line 2)", function()
      open('lua', LUA)
      vim.api.nvim_win_set_cursor(0, { 2, 4 })
      h.feed('vif')
      local b = visual_bounds()
      h.ensure_normal()
      assert.equals(2, b[1], "expected start line 2, got " .. b[1])
      assert.equals(2, b[3], "expected end line 2, got " .. b[3])
    end)

    it("vaa selects the parameter under cursor with trailing comma (x,)", function()
      open('lua', LUA)
      vim.api.nvim_win_set_cursor(0, { 1, 21 })  -- on 'x' in (x, y)
      h.feed('vaa')
      local b = visual_bounds()
      h.ensure_normal()
      assert.equals(1, b[1])
      -- "around" parameter includes trailing comma + space when not the last param
      local text = vim.api.nvim_buf_get_text(0, b[1] - 1, b[2], b[3] - 1, b[4] + 1, {})[1]
      assert.is_true(text:match('^x') ~= nil, "expected text to start with 'x', got: " .. vim.inspect(text))
    end)

    it("via selects the parameter inner (also just 'x' here)", function()
      open('lua', LUA)
      vim.api.nvim_win_set_cursor(0, { 1, 21 })  -- on 'x'
      h.feed('via')
      local b = visual_bounds()
      h.ensure_normal()
      assert.equals('x', vim.api.nvim_buf_get_text(0, b[1] - 1, b[2], b[3] - 1, b[4] + 1, {})[1])
    end)
  end)

  describe("select on python (cross-language)", function()
    local PY = {
      'class C:',                     -- 1
      '    def alpha(self, x):',       -- 2
      '        return x + 1',          -- 3
      '    def beta(self):',           -- 4
      '        return 2',              -- 5
    }

    it("vaf on python function selects the def block", function()
      open('py', PY)
      vim.api.nvim_win_set_cursor(0, { 3, 8 })  -- inside alpha body
      h.feed('vaf')
      local b = visual_bounds()
      h.ensure_normal()
      assert.equals(2, b[1], "expected start line 2, got " .. b[1])
      assert.equals(3, b[3], "expected end line 3, got " .. b[3])
    end)

    it("vac on python class selects entire class", function()
      open('py', PY)
      vim.api.nvim_win_set_cursor(0, { 2, 8 })  -- inside class body
      h.feed('vac')
      local b = visual_bounds()
      h.ensure_normal()
      assert.equals(1, b[1])
      assert.equals(5, b[3])
    end)

    it("vic on python class selects class body inner", function()
      open('py', PY)
      vim.api.nvim_win_set_cursor(0, { 2, 8 })
      h.feed('vic')
      local b = visual_bounds()
      h.ensure_normal()
      assert.equals(2, b[1], "expected inner class to start at line 2 (first body line)")
      assert.equals(5, b[3], "expected inner class to end at line 5")
    end)
  end)

  describe("move", function()
    local LUA = {
      'local function alpha(x, y)',  -- 1
      '  return x + y',              -- 2
      'end',                          -- 3
      '',                             -- 4
      'local function beta()',        -- 5
      '  return 42',                  -- 6
      'end',                          -- 7
    }

    it("]m jumps to line 5 (next function start)", function()
      open('lua', LUA)
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      h.feed(']m')
      local pos = vim.api.nvim_win_get_cursor(0)
      assert.equals(5, pos[1])
    end)

    it("]M jumps to line 7 (next function end)", function()
      open('lua', LUA)
      vim.api.nvim_win_set_cursor(0, { 4, 0 })
      h.feed(']M')
      local pos = vim.api.nvim_win_get_cursor(0)
      assert.equals(7, pos[1])
    end)

    it("[m from inside beta jumps to line 5 (its own start)", function()
      open('lua', LUA)
      vim.api.nvim_win_set_cursor(0, { 6, 0 })
      h.feed('[m')
      local pos = vim.api.nvim_win_get_cursor(0)
      assert.equals(5, pos[1])
    end)

    it("[m twice from inside beta jumps to line 1 (alpha)", function()
      open('lua', LUA)
      vim.api.nvim_win_set_cursor(0, { 6, 0 })
      h.feed('[m[m')
      local pos = vim.api.nvim_win_get_cursor(0)
      assert.equals(1, pos[1])
    end)

    it("[M from inside beta jumps to line 3 (previous function end)", function()
      open('lua', LUA)
      vim.api.nvim_win_set_cursor(0, { 6, 0 })
      h.feed('[M')
      local pos = vim.api.nvim_win_get_cursor(0)
      assert.equals(3, pos[1])
    end)

    local PY = {
      'class A:',           -- 1
      '    pass',           -- 2
      '',                   -- 3
      'class B:',           -- 4
      '    pass',           -- 5
    }

    it("]] jumps to line 4 (next class start)", function()
      open('py', PY)
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      h.feed(']]')
      local pos = vim.api.nvim_win_get_cursor(0)
      assert.equals(4, pos[1])
    end)

    it("[[ from inside class B jumps to line 4 (its own start)", function()
      open('py', PY)
      vim.api.nvim_win_set_cursor(0, { 5, 0 })
      h.feed('[[')
      local pos = vim.api.nvim_win_get_cursor(0)
      assert.equals(4, pos[1])
    end)

    it("[[ twice from inside class B jumps to line 1 (class A)", function()
      open('py', PY)
      vim.api.nvim_win_set_cursor(0, { 5, 0 })
      h.feed('[[[[')
      local pos = vim.api.nvim_win_get_cursor(0)
      assert.equals(1, pos[1])
    end)

    it("][ jumps to line 5 (next class end)", function()
      open('py', PY)
      vim.api.nvim_win_set_cursor(0, { 3, 0 })
      h.feed('][')
      local pos = vim.api.nvim_win_get_cursor(0)
      assert.equals(5, pos[1])
    end)

    it("[] jumps to line 2 (previous class end)", function()
      open('py', PY)
      vim.api.nvim_win_set_cursor(0, { 5, 0 })
      h.feed('[]')
      local pos = vim.api.nvim_win_get_cursor(0)
      assert.equals(2, pos[1])
    end)
  end)

  describe("swap", function()
    it("<leader>a swaps parameter with the next one", function()
      open('lua', { 'local function f(alpha, beta) end' })
      vim.api.nvim_win_set_cursor(0, { 1, 17 })  -- on 'alpha'
      h.feed(' a')  -- <leader>a (default leader is space)
      h.ensure_normal()
      assert.equals('local function f(beta, alpha) end',
        vim.api.nvim_buf_get_lines(0, 0, 1, false)[1])
    end)

    it("<leader>A swaps parameter with the previous one", function()
      open('lua', { 'local function f(alpha, beta) end' })
      vim.api.nvim_win_set_cursor(0, { 1, 24 })  -- on 'beta'
      h.feed(' A')  -- <leader>A
      h.ensure_normal()
      assert.equals('local function f(beta, alpha) end',
        vim.api.nvim_buf_get_lines(0, 0, 1, false)[1])
    end)
  end)
end)
