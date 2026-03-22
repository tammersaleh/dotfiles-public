local h = require('helpers')

require('config.keymaps')

describe("keymaps", function()
  before_each(function()
    h.reset()
  end)

  -- Tab / S-Tab indent ---------------------------------------------------------

  describe("indent", function()
    describe("normal mode", function()
      it("Tab indents line", function()
        h.set_buf({ "hello", "world" })
        h.set_cursor(1)
        h.feed("<Tab>")
        assert.are.same({ "  hello", "world" }, h.get_buf())
      end)

      it("S-Tab dedents line", function()
        h.set_buf({ "  hello", "world" })
        h.set_cursor(1)
        h.feed("<S-Tab>")
        assert.are.same({ "hello", "world" }, h.get_buf())
      end)
    end)

    describe("visual mode", function()
      it("Tab indents selection", function()
        h.set_buf({ "hello", "world", "foo" })
        h.set_cursor(1)
        h.feed("Vj<Tab>")
        assert.are.same({ "  hello", "  world", "foo" }, h.get_buf())
      end)

      it("S-Tab dedents selection", function()
        h.set_buf({ "  hello", "  world", "foo" })
        h.set_cursor(1)
        h.feed("Vj<S-Tab>")
        assert.are.same({ "hello", "world", "foo" }, h.get_buf())
      end)

      it("keeps selection active after indent", function()
        h.set_buf({ "hello", "world" })
        h.set_cursor(1)
        h.feed("Vj<Tab>")
        assert.equals("V", h.get_mode())
        h.ensure_normal()
      end)
    end)

    describe("insert mode", function()
      it("Tab at column 0 inserts whitespace", function()
        h.set_buf({ "hello", "world" })
        h.set_cursor(1, 0)
        h.feed("i<Tab>")
        h.ensure_normal()
        assert.are.same({ "  hello", "world" }, h.get_buf())
      end)

      it("Tab after whitespace indents entire line", function()
        h.set_buf({ "- ", "world" })
        h.set_cursor(1, 2)
        h.feed("a<Tab>")
        h.ensure_normal()
        assert.are.same({ "  - ", "world" }, h.get_buf())
      end)

      it("S-Tab dedents entire line", function()
        h.set_buf({ "  hello", "world" })
        h.set_cursor(1, 0)
        h.feed("i<S-Tab>")
        h.ensure_normal()
        assert.are.same({ "hello", "world" }, h.get_buf())
      end)
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

  -- Space as nop ---------------------------------------------------------------

  describe("space", function()
    it("is disabled in normal mode", function()
      local maps = vim.api.nvim_get_keymap('n')
      local found = false
      for _, map in ipairs(maps) do
        if map.lhs == ' ' then
          found = true
          break
        end
      end
      assert.is_true(found, "space mapping not found")
    end)
  end)

  -- Go back in tag stack -------------------------------------------------------

  describe("gb", function()
    it("maps to C-t in normal mode", function()
      local maps = vim.api.nvim_get_keymap('n')
      local found = false
      for _, map in ipairs(maps) do
        if map.lhs == 'gb' then
          found = true
          assert.equals('<C-T>', map.rhs)
          break
        end
      end
      assert.is_true(found, "gb mapping not found")
    end)
  end)

  -- j/k word wrap --------------------------------------------------------------

  describe("j/k word wrap", function()
    it("maps j with expression for wrapped lines", function()
      local maps = vim.api.nvim_get_keymap('n')
      local found = false
      for _, map in ipairs(maps) do
        if map.lhs == 'j' then
          found = true
          assert.is_true(map.expr == 1 or map.expr == true)
          break
        end
      end
      assert.is_true(found, "j mapping not found")
    end)

    it("maps k with expression for wrapped lines", function()
      local maps = vim.api.nvim_get_keymap('n')
      local found = false
      for _, map in ipairs(maps) do
        if map.lhs == 'k' then
          found = true
          assert.is_true(map.expr == 1 or map.expr == true)
          break
        end
      end
      assert.is_true(found, "k mapping not found")
    end)
  end)

  -- Select last paste ----------------------------------------------------------

  describe("gp", function()
    it("selects last pasted text", function()
      h.set_buf({ "alpha", "beta", "gamma" })
      h.set_cursor(1)
      h.feed("yy")       -- yank line
      h.feed("G")        -- go to last line
      h.feed("p")        -- paste below
      h.feed("gp")       -- select pasted
      assert.equals("v", h.get_mode())
      h.ensure_normal()
    end)
  end)
end)
