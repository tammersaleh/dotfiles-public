describe("treesitter folds (foldexpr)", function()
  local function open(ext, lines)
    local tmp = vim.fn.tempname() .. '.' .. ext
    vim.fn.writefile(lines, tmp)
    vim.cmd('edit ' .. vim.fn.fnameescape(tmp))
    vim.wait(300, function()
      return vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil
    end, 20)
  end

  it("global foldexpr is treesitter foldexpr", function()
    assert.equals('v:lua.vim.treesitter.foldexpr()', vim.o.foldexpr)
    assert.equals('expr', vim.o.foldmethod)
  end)

  it("python: lines inside a function get a fold level > 0", function()
    open('py', {
      'def foo():',     -- 1
      '    a = 1',       -- 2
      '    return a',    -- 3
      '',                -- 4 (between)
      'x = 1',           -- 5 (top-level, no fold)
    })
    vim.cmd('normal! zX')  -- force fold recomputation
    local level_in_func = vim.fn.foldlevel(2)
    local level_top = vim.fn.foldlevel(5)
    assert.is_true(level_in_func > 0,
      "expected line inside function to have fold level > 0, got " .. level_in_func)
    assert.is_true(level_top == 0 or level_top < level_in_func,
      "expected top-level line to have lower fold level than function body; in_func="
        .. level_in_func .. " top=" .. level_top)
  end)

  it("typescript: nested block adds another fold level", function()
    open('ts', {
      'function foo() {',  -- 1
      '  if (x) {',         -- 2
      '    return 1;',      -- 3
      '  }',                -- 4
      '}',                  -- 5
    })
    vim.cmd('normal! zX')
    local outer = vim.fn.foldlevel(2)
    local inner = vim.fn.foldlevel(3)
    assert.is_true(outer > 0, "outer block fold level should be > 0")
    assert.is_true(inner >= outer, "nested block should have fold level >= outer")
  end)
end)
