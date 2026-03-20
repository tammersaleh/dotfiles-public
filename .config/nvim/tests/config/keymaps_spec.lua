local h = require('helpers')

-- Load the keymaps module under test
require('config.keymaps')

describe("keymaps", function()
  before_each(function()
    h.reset()
  end)

  -- Tab / S-Tab indent ---------------------------------------------------------

  describe("indent", function()
    it("Tab indents line in normal mode", function()
      h.set_buf({ "hello", "world" })
      h.set_cursor(1)
      h.feed("<Tab>")
      assert.are.same({ "  hello", "world" }, h.get_buf())
    end)

    it("S-Tab dedents line in normal mode", function()
      h.set_buf({ "  hello", "world" })
      h.set_cursor(1)
      h.feed("<S-Tab>")
      assert.are.same({ "hello", "world" }, h.get_buf())
    end)

    it("Tab indents visual selection", function()
      h.set_buf({ "hello", "world", "foo" })
      h.set_cursor(1)
      h.feed("Vj<Tab>")
      assert.are.same({ "  hello", "  world", "foo" }, h.get_buf())
    end)

    it("S-Tab dedents visual selection", function()
      h.set_buf({ "  hello", "  world", "foo" })
      h.set_cursor(1)
      h.feed("Vj<S-Tab>")
      assert.are.same({ "hello", "world", "foo" }, h.get_buf())
    end)

    it("visual indent keeps selection active", function()
      h.set_buf({ "hello", "world" })
      h.set_cursor(1)
      h.feed("Vj<Tab>")
      assert.equals("V", h.get_mode())
      h.ensure_normal()
    end)
  end)

  -- Move line up / down -------------------------------------------------------

  describe("move line", function()
    it("C-S-Down moves line down in normal mode", function()
      h.set_buf({ "alpha", "beta", "gamma" })
      h.set_cursor(1)
      h.feed("<C-S-Down>")
      assert.are.same({ "beta", "alpha", "gamma" }, h.get_buf())
    end)

    it("C-S-Up moves line up in normal mode", function()
      h.set_buf({ "alpha", "beta", "gamma" })
      h.set_cursor(2)
      h.feed("<C-S-Up>")
      assert.are.same({ "beta", "alpha", "gamma" }, h.get_buf())
    end)

    it("cursor follows the moved line", function()
      h.set_buf({ "alpha", "beta", "gamma" })
      h.set_cursor(1)
      h.feed("<C-S-Down>")
      assert.are.same({ 2, 0 }, h.get_cursor())
    end)
  end)

  -- Semicolon -> colon --------------------------------------------------------

  describe("semicolon", function()
    it("maps ; to : in normal mode", function()
      local maps = vim.api.nvim_get_keymap('n')
      local found = false
      for _, map in ipairs(maps) do
        if map.lhs == ";" then
          found = true
          assert.equals(":", map.rhs)
          break
        end
      end
      assert.is_true(found, "semicolon mapping not found")
    end)
  end)
end)
