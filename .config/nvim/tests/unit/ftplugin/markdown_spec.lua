local h = require('helpers')

describe("ftplugin/markdown", function()
  before_each(function()
    h.reset()
    vim.bo.filetype = 'markdown'
  end)

  describe("options", function()
    it("sets shiftwidth to 4", function()
      assert.equals(4, vim.bo.shiftwidth)
    end)

    it("sets tabstop to 4", function()
      assert.equals(4, vim.bo.tabstop)
    end)

    it("disables conceal", function()
      assert.equals(0, vim.wo.conceallevel)
    end)

    it("enables line break", function()
      assert.is_true(vim.wo.linebreak)
    end)

    it("enables folding", function()
      assert.is_true(vim.wo.foldenable)
    end)

    it("enables spell check", function()
      assert.is_true(vim.wo.spell)
    end)

    it("uses expression folding", function()
      assert.equals('expr', vim.wo.foldmethod)
    end)
  end)

  describe("visual mode bullet formatting", function()
    it("adds dash bullets with -", function()
      h.set_buf({ "item one", "item two", "item three" })
      h.set_cursor(1)
      h.feed("Vj-")
      assert.are.same({ "- item one", "- item two", "item three" }, h.get_buf())
    end)

    it("adds asterisk bullets with *", function()
      h.set_buf({ "item one", "item two", "item three" })
      h.set_cursor(1)
      h.feed("Vj*")
      assert.are.same({ "* item one", "* item two", "item three" }, h.get_buf())
    end)

    it("adds numbered list with #", function()
      h.set_buf({ "item one", "item two", "item three" })
      h.set_cursor(1)
      h.feed("Vj#")
      assert.are.same({ "1. item one", "1. item two", "item three" }, h.get_buf())
    end)
  end)

  describe("fold expression", function()
    it("folds on ATX-style headers", function()
      h.set_buf({ "# Heading 1", "content", "## Heading 2", "more content" })
      -- The fold expression is set, verify foldmethod
      assert.equals('expr', vim.wo.foldmethod)
      -- Verify the fold level of line 1 (# = level 1)
      vim.cmd('normal! zx') -- recompute folds
      assert.equals(1, vim.fn.foldlevel(1))
    end)

    it("assigns deeper fold levels to deeper headers", function()
      h.set_buf({ "# H1", "text", "## H2", "text", "### H3", "text" })
      vim.cmd('normal! zx')
      assert.equals(1, vim.fn.foldlevel(1))
      assert.equals(2, vim.fn.foldlevel(3))
      assert.equals(3, vim.fn.foldlevel(5))
    end)
  end)
end)
