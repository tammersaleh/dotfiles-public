local h = require('helpers')

describe("line textobject", function()
  before_each(function()
    h.set_buf({ "  hello world  ", "next" })
    h.set_cursor(1)
  end)

  it("dil deletes the line's text, keeping indentation and trailing space", function()
    h.feed("dil")
    assert.are.same({ "    ", "next" }, h.get_buf())
  end)

  it("dal deletes the whole line's characters, keeping the empty line", function()
    h.feed("dal")
    assert.are.same({ "", "next" }, h.get_buf())
  end)

  it("vil selects the line's text", function()
    h.feed("vily")
    assert.equals("hello world", vim.fn.getreg('"'))
  end)
end)
