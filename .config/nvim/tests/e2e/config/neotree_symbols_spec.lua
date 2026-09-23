local h = require('helpers')

-- document_symbols has no clipboard, add, or delete commands. Mappings that
-- name them must be noop'd there or neo-tree warns on every open.
describe("Neo-tree document_symbols tab (with plugins)", function()
  before_each(function()
    h.reset()
    vim.cmd.Neotree('close')
    vim.cmd('messages clear')
  end)

  after_each(function()
    vim.cmd.Neotree('close')
  end)

  it("opens without invalid-mapping warnings", function()
    vim.cmd.Neotree('document_symbols')
    vim.wait(300)
    local msgs = vim.fn.execute('messages')
    assert.is_nil(msgs:find('Invalid mapping', 1, true), msgs)
  end)
end)
