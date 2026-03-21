local h = require('helpers')

require('config.keymaps')

describe("markdown bullet indent", function()
  before_each(function()
    h.reset()
    vim.bo.filetype = 'markdown'
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.expandtab = true
  end)

  describe("normal mode", function()
    it("Tab indents a bullet", function()
      h.set_buf({ "- item one", "- item two" })
      h.set_cursor(1)
      h.feed("<Tab>")
      assert.are.same({ "    - item one", "- item two" }, h.get_buf())
    end)

    it("S-Tab dedents a bullet", function()
      h.set_buf({ "    - item one", "- item two" })
      h.set_cursor(1)
      h.feed("<S-Tab>")
      assert.are.same({ "- item one", "- item two" }, h.get_buf())
    end)

    it("Tab adds another indent level to a sub-bullet", function()
      h.set_buf({ "- parent", "    - child" })
      h.set_cursor(2)
      h.feed("<Tab>")
      assert.are.same({ "- parent", "        - child" }, h.get_buf())
    end)
  end)
end)
