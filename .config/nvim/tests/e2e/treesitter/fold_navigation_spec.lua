local h = require('helpers')

describe("fold-aware h/l navigation", function()
  local function open_py_with_function()
    local tmp = vim.fn.tempname() .. '.py'
    vim.fn.writefile({
      'def foo():',     -- 1
      '    a = 1',       -- 2
      '    b = 2',       -- 3
      '    return a+b',  -- 4
      '',                -- 5
    }, tmp)
    vim.cmd('edit ' .. vim.fn.fnameescape(tmp))
    vim.wait(500, function()
      return vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil
    end, 20)
    vim.cmd('normal! zX')  -- recompute folds
  end

  it("h on a foldable line at col 0 closes the fold", function()
    open_py_with_function()
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
    -- ensure the fold around line 2 is open
    vim.cmd('normal! zo')
    assert.equals(-1, vim.fn.foldclosed(2),
      "fold should be open before pressing h")

    h.feed('h')

    -- after pressing h at col 0 of a foldable line, the fold should be closed
    assert.is_true(vim.fn.foldclosed(2) ~= -1,
      "expected fold to be closed after pressing h at col 0")
  end)

  it("l on a closed fold opens it", function()
    open_py_with_function()
    -- Close the fold containing line 2
    vim.api.nvim_win_set_cursor(0, { 2, 0 })
    vim.cmd('normal! zc')
    assert.is_true(vim.fn.foldclosed(2) ~= -1,
      "fold should be closed before pressing l")

    h.feed('l')

    -- after pressing l on a closed fold, it should be open
    assert.equals(-1, vim.fn.foldclosed(2),
      "expected fold to be open after pressing l on closed fold")
  end)

  it("h on a non-foldable line moves cursor left normally", function()
    open_py_with_function()
    vim.api.nvim_win_set_cursor(0, { 1, 5 })  -- mid-line, not at col 0
    h.feed('h')
    local pos = vim.api.nvim_win_get_cursor(0)
    assert.equals(4, pos[2], "expected cursor to move one column left")
  end)
end)
