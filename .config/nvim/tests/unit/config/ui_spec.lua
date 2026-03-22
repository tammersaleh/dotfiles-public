local h = require('helpers')

require('config.ui')

describe("ui", function()
  it("enables line numbers", function()
    assert.is_true(vim.wo.number)
  end)

  it("always shows sign column", function()
    assert.equals('yes', vim.wo.signcolumn)
  end)

  it("sets command line height to 2", function()
    assert.equals(2, vim.o.cmdheight)
  end)

  it("starts with folds open", function()
    assert.equals(99, vim.o.foldlevel)
  end)

  it("sets update time to 250ms", function()
    assert.equals(250, vim.o.updatetime)
  end)

  it("sets timeout length to 300ms", function()
    assert.equals(300, vim.o.timeoutlen)
  end)
end)
