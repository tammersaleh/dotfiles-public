local h = require('helpers')

require('config.completion')

describe("completion", function()
  it("sets completeopt", function()
    assert.equals('menuone,noselect', vim.o.completeopt)
  end)
end)
