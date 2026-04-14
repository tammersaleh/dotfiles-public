local h = require('helpers')

describe("ftplugin/slack", function()
  before_each(function()
    h.reset()
    vim.bo.filetype = 'slack'
  end)

  describe("options", function()
    it("sets shiftwidth to 2", function()
      assert.equals(2, vim.bo.shiftwidth)
    end)

    it("sets tabstop to 2", function()
      assert.equals(2, vim.bo.tabstop)
    end)

    it("enables spell check", function()
      assert.is_true(vim.wo.spell)
    end)

    it("enables line break", function()
      assert.is_true(vim.wo.linebreak)
    end)

    it("disables folding", function()
      assert.is_false(vim.wo.foldenable)
    end)

    it("uses manual foldmethod", function()
      assert.equals('manual', vim.wo.foldmethod)
    end)
  end)

  describe("keymaps", function()
    it("has bullet formatting keymaps from markdown", function()
      h.set_buf({ "item one", "item two" })
      h.set_cursor(1)
      h.feed("Vj-")
      assert.are.same({ "- item one", "- item two" }, h.get_buf())
    end)

    it("does not have mark preview keymap", function()
      local maps = vim.api.nvim_buf_get_keymap(0, 'n')
      for _, map in ipairs(maps) do
        if map.lhs == ' o' or map.lhs == ' m' then
          error("mark preview keymap should not be set for slack filetype: " .. map.lhs)
        end
      end
    end)
  end)

  describe("bullet cycling", function()
    it("Tab on a paragraph turns it into a bullet", function()
      h.set_buf({ "some text", "other" })
      h.set_cursor(1)
      h.feed("<Tab>")
      assert.are.same({ "- some text", "other" }, h.get_buf())
    end)

    it("S-Tab on a top-level bullet removes it", function()
      h.set_buf({ "- some text", "other" })
      h.set_cursor(1)
      h.feed("<S-Tab>")
      assert.are.same({ "some text", "other" }, h.get_buf())
    end)
  end)
end)
