local h = require('helpers')

describe("markdown bullet indent (with plugins)", function()
  before_each(function()
    h.reset()
    vim.bo.filetype = 'markdown'
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.expandtab = true
  end)

  describe("insert mode", function()
    it("Tab after bullet marker indents the line", function()
      h.set_buf({ "- ", "- item two" })
      h.set_cursor(1, 2)
      h.feed("a<Tab>")
      h.ensure_normal()
      assert.are.same({ "    - ", "- item two" }, h.get_buf())
    end)

    it("S-Tab after bullet marker dedents the line", function()
      h.set_buf({ "    - ", "- item two" })
      h.set_cursor(1, 6)
      h.feed("a<S-Tab>")
      h.ensure_normal()
      assert.are.same({ "- ", "- item two" }, h.get_buf())
    end)
  end)
end)
