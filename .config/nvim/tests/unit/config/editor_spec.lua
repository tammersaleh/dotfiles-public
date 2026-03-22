local h = require('helpers')

require('config.editor')

describe("editor", function()
  it("enables mouse", function()
    assert.equals('a', vim.o.mouse)
  end)

  it("syncs clipboard with OS", function()
    assert.equals('unnamedplus', vim.o.clipboard)
  end)

  it("enables break indent", function()
    assert.is_true(vim.o.breakindent)
  end)

  it("sets showbreak character", function()
    assert.equals('↳  ', vim.o.showbreak)
  end)

  it("disables double space after punctuation on join", function()
    assert.is_false(vim.o.joinspaces)
  end)

  it("enables persistent undo", function()
    assert.is_true(vim.o.undofile)
  end)

  it("auto-writes all buffers on focus loss", function()
    assert.is_true(vim.o.autowriteall)
  end)

  it("does not hide abandoned buffers", function()
    assert.is_false(vim.o.hidden)
  end)

  it("disables netrw", function()
    assert.equals(1, vim.g.loaded_netrw)
    assert.equals(1, vim.g.loaded_netrwPlugin)
  end)
end)
