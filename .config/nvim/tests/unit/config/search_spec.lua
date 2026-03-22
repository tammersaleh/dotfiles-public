local h = require('helpers')

require('config.search')

describe("search", function()
  it("enables case-insensitive search", function()
    assert.is_true(vim.o.ignorecase)
  end)

  it("enables smart case", function()
    assert.is_true(vim.o.smartcase)
  end)

  it("registers hlsearch autocmds for search commands", function()
    local autocmds = vim.api.nvim_get_autocmds({ group = 'vim_search' })
    -- 4 autocmds: CmdlineEnter/CmdlineLeave x 2 patterns (/ and ?)
    local events = {}
    for _, ac in ipairs(autocmds) do
      events[ac.event] = true
    end
    assert.is_true(events['CmdlineEnter'])
    assert.is_true(events['CmdlineLeave'])
  end)
end)
