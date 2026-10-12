local L = require('config.lists')

local RENUMBER = "<Cmd>lua require('config.lists').renumber()<CR>"
local CLEAR = "<Cmd>lua require('config.lists').clear_item()<CR>"
local UNIT = '    '

describe("config.lists", function()
  describe("parse", function()
    local cases = {
      { "- one", { indent = '', marker = '-', checkbox = nil, prefix = '- ' } },
      { "* one", { indent = '', marker = '*', checkbox = nil, prefix = '* ' } },
      { "+ one", { indent = '', marker = '+', checkbox = nil, prefix = '+ ' } },
      { "1. one", { indent = '', marker = '1.', number = 1, delim = '.', prefix = '1. ' } },
      { "12) one", { indent = '', marker = '12)', number = 12, delim = ')', prefix = '12) ' } },
      { "    - one", { indent = '    ', marker = '-', prefix = '    - ' } },
      { "\t- one", { indent = '\t', marker = '-', prefix = '\t- ' } },
      { "-  one", { indent = '', marker = '-', prefix = '-  ' } },
      { "- [ ] one", { indent = '', marker = '-', checkbox = '[ ]', prefix = '- [ ] ' } },
      { "- [x] one", { indent = '', marker = '-', checkbox = '[x]', prefix = '- [x] ' } },
      { "- [X] one", { indent = '', marker = '-', checkbox = '[X]', prefix = '- [X] ' } },
      { "1. [ ] one", { indent = '', marker = '1.', number = 1, delim = '.', checkbox = '[ ]', prefix = '1. [ ] ' } },
      { "- ", { indent = '', marker = '-', prefix = '- ' } },
    }
    for _, c in ipairs(cases) do
      it("parses " .. vim.inspect(c[1]), function()
        local item = L.parse(c[1])
        assert.is_not_nil(item)
        for k, v in pairs(c[2]) do assert.equals(v, item[k], k) end
        assert.equals(c[2].checkbox, item.checkbox, 'checkbox')
      end)
    end

    it("treats other bracket text as item text, not a checkbox", function()
      local item = L.parse("- [a] literal")
      assert.is_nil(item.checkbox)
      assert.equals('- ', item.prefix)
    end)

    for _, line in ipairs({ "one", "-one", "1.one", "# heading", "", "   ", "--", "1.", "a. one", "IV. one" }) do
      it("rejects " .. vim.inspect(line), function()
        assert.is_nil(L.parse(line))
      end)
    end
  end)

  describe("next_prefix", function()
    local cases = {
      { "- one", '- ' },
      { "* one", '* ' },
      { "+ one", '+ ' },
      { "    - one", '    - ' },
      { "\t- one", '\t- ' },
      { "1. one", '2. ' },
      { "9. one", '10. ' },
      { "1) one", '2) ' },
      { "- [x] one", '- [ ] ' },
      { "- [X] one", '- [ ] ' },
      { "- [ ] one", '- [ ] ' },
      { "3. [x] one", '4. [ ] ' },
      { "-  one", '- ' },
    }
    for _, c in ipairs(cases) do
      it("follows " .. vim.inspect(c[1]) .. " with " .. vim.inspect(c[2]), function()
        assert.equals(c[2], L.next_prefix(L.parse(c[1]), { indent_unit = UNIT }))
      end)
    end

    it("nests by one indent unit and keeps the marker", function()
      assert.equals('    - ', L.next_prefix(L.parse("- one"), { nest = true, indent_unit = UNIT }))
      assert.equals('        * ', L.next_prefix(L.parse("    * one"), { nest = true, indent_unit = UNIT }))
      assert.equals('\t\t- ', L.next_prefix(L.parse("\t- one"), { nest = true, indent_unit = '\t' }))
    end)

    it("restarts a nested numbered list at 1", function()
      assert.equals('    1. ', L.next_prefix(L.parse("4. one"), { nest = true, indent_unit = UNIT }))
      assert.equals('    1) ', L.next_prefix(L.parse("4) one"), { nest = true, indent_unit = UNIT }))
    end)
  end)

  describe("newline_keys", function()
    local function keys(line, col, sts)
      return L.newline_keys(line, col, { indent_unit = UNIT, softtabstop = sts or 0, tabstop = 4 })
    end

    describe("plain lines", function()
      it("is a bare <CR> on a paragraph", function()
        assert.equals('<CR>', keys("one two", 3))
        assert.equals('<CR>', keys("one  two", 4))
        assert.equals('<CR>', keys("one two", 7))
      end)

      it("is a bare <CR> on a heading, fence, table row and empty line", function()
        assert.equals('<CR>', keys("# one", 5))
        assert.equals('<CR>', keys("```lua", 6))
        assert.equals('<CR>', keys("| a | b |", 9))
        assert.equals('<CR>', keys("", 0))
      end)
    end)

    describe("list items", function()
      it("continues the marker at end of line", function()
        assert.equals('<CR>- ', keys("- one", 5))
        assert.equals('<CR>* ', keys("* one", 5))
        assert.equals('<CR>+ ', keys("+ one", 5))
      end)

      it("relies on autoindent for a nested item's indent", function()
        assert.equals('<CR>- ', keys("    - one", 9))
        assert.equals('<CR>- ', keys("\t- one", 6))
      end)

      it("backspaces the whitespace before the split point", function()
        assert.equals('<BS><CR>- ', keys("- one two", 6))
        assert.equals('<BS><BS><BS><CR>- ', keys("- one   two", 8))
      end)

      it("does not backspace when the cursor sits on the space", function()
        assert.equals('<CR>- ', keys("- one two", 5))
      end)

      it("keeps trailing spaces at end of line (hard break)", function()
        assert.equals('<CR>- ', keys("- one  ", 7))
      end)

      it("numbers the next item and schedules a renumber", function()
        assert.equals('<CR>2. ' .. RENUMBER, keys("1. one", 6))
        assert.equals('<CR>10. ' .. RENUMBER, keys("9. one", 6))
        assert.equals('<CR>2) ' .. RENUMBER, keys("1) one", 6))
        assert.equals('<BS><CR>2. ' .. RENUMBER, keys("1. one two", 7))
      end)

      it("resets the checkbox", function()
        assert.equals('<CR>- [ ] ', keys("- [x] one", 9))
        assert.equals('<CR>- [ ] ', keys("- [X] one", 9))
        assert.equals('<BS><CR>- [ ] ', keys("- [x] one two", 10))
      end)

      it("nests after a trailing colon", function()
        assert.equals('<CR>    - ', keys("- head:", 7))
        assert.equals('<BS><CR>    - ', keys("- head: tail", 8))
        assert.equals('<CR>    1. ' .. RENUMBER, keys("3. head:", 8))
      end)

      it("does not nest when only the moved text ends in a colon", function()
        assert.equals('<BS><CR>- ', keys("- head tail:", 7))
      end)

      it("is a bare <CR> inside the marker or before the text", function()
        assert.equals('<CR>', keys("- one", 0))
        assert.equals('<CR>', keys("- one", 1))
        assert.equals('<CR>', keys("- one", 2))
        assert.equals('<CR>', keys("-  one", 2))
        assert.equals('<CR>', keys("- [x] one", 6))
        assert.equals('<CR>', keys("    - one", 2))
      end)

      it("is a bare <CR> before an unused item", function()
        assert.equals('<CR>', keys("- ", 0))
        assert.equals('<CR>', keys("> - ", 2))
      end)

      it("clears an unused item", function()
        assert.equals(CLEAR, keys("- ", 2))
        assert.equals(CLEAR, keys("    - ", 6))
        assert.equals(CLEAR, keys("\t- ", 3))
        assert.equals(CLEAR, keys("1. ", 3))
        assert.equals(CLEAR, keys("- [ ] ", 6))
        assert.equals(CLEAR, keys("-  ", 3))
      end)

      it("splits after a multibyte character", function()
        assert.equals('<BS><CR>- ', keys("- café résumé", 8))
      end)

      describe("with softtabstop", function()
        it("still uses one <BS> for one space", function()
          assert.equals('<BS><CR>- ', keys("- one two", 6, 4))
        end)

        it("counts the stops Vim will take across a run of spaces", function()
          -- "- one   " is 8 columns: one <BS> goes back to column 4 but stops at
          -- the "e" on column 5.
          assert.equals('<BS><CR>- ', keys("- one   two", 8, 4))
          -- "- one     " is 10 columns: back to 8, then to 5.
          assert.equals('<BS><BS><CR>- ', keys("- one     two", 10, 4))
          -- "- one  " is 7 columns: back to 4, stopped by the "e".
          assert.equals('<BS><CR>- ', keys("- one  two", 7, 4))
        end)

        it("treats a tab as one stop", function()
          assert.equals('<BS><CR>- ', keys("- one\ttwo", 6, 4))
          -- The tab ends on column 8; one <BS> wants column 4, takes the tab and
          -- the space, and stops at the "e".
          assert.equals('<BS><CR>- ', keys("- one \ttwo", 7, 4))
        end)

        it("counts multibyte text by display width", function()
          -- "- café   " is 10 bytes but 9 columns: back to 8, then to 6.
          assert.equals('<BS><BS><CR>- ', keys("- café   résumé", 10, 4))
        end)
      end)
    end)

    describe("blockquotes", function()
      it("repeats the leader", function()
        assert.equals('<CR>> ', keys("> one", 5))
        assert.equals('<CR>> > ', keys("> > one", 7))
        assert.equals('<CR>>', keys(">one", 4))
      end)

      it("backspaces the whitespace before the split point", function()
        assert.equals('<BS><CR>> ', keys("> one two", 6))
      end)

      it("keeps trailing spaces at end of line", function()
        assert.equals('<CR>> ', keys("> one  ", 7))
      end)

      it("is a bare <CR> inside the leader", function()
        assert.equals('<CR>', keys("> one", 0))
        assert.equals('<CR>', keys("> one", 1))
        assert.equals('<CR>', keys("> one", 2))
        assert.equals('<CR>', keys("> > one", 3))
      end)

      it("clears an unused leader", function()
        assert.equals(CLEAR, keys("> ", 2))
        assert.equals(CLEAR, keys(">", 1))
        assert.equals(CLEAR, keys("> > ", 4))
      end)
    end)

    describe("lists inside blockquotes", function()
      it("types the leader and the marker", function()
        assert.equals('<CR>> - ', keys("> - one", 7))
        assert.equals('<CR>> > - ', keys("> > - one", 9))
        assert.equals('<CR>> 2. ' .. RENUMBER, keys("> 1. one", 8))
        assert.equals('<CR>> - [ ] ', keys("> - [x] one", 11))
      end)

      it("leaves an indented leader's indent to autoindent", function()
        assert.equals('<CR>> - ', keys("  > - one", 9))
        assert.equals('<CR>> ', keys("  > one", 7))
      end)

      it("types the body indent since autoindent stops at the leader", function()
        assert.equals('<CR>>     - ', keys(">     - one", 11))
        assert.equals('<CR>>' .. '<C-v><Tab>' .. '- ', keys(">\t- one", 7))
      end)

      it("nests after a trailing colon", function()
        assert.equals('<CR>>     - ', keys("> - head:", 9))
      end)

      it("backspaces the whitespace before the split point", function()
        assert.equals('<BS><CR>> - ', keys("> - one two", 8))
      end)

      it("is a bare <CR> inside the leader or marker", function()
        assert.equals('<CR>', keys("> - one", 1))
        assert.equals('<CR>', keys("> - one", 2))
        assert.equals('<CR>', keys("> - one", 3))
        assert.equals('<CR>', keys("> - one", 4))
      end)

      it("clears an unused quoted item", function()
        assert.equals(CLEAR, keys("> - ", 4))
        assert.equals(CLEAR, keys("> 1. ", 5))
      end)
    end)
  end)
end)
