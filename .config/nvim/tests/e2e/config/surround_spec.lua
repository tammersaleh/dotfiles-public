local h = require('helpers')

describe("surround", function()
  before_each(function()
    vim.cmd("doautocmd User VeryLazy")
    h.set_buf({ "foo bar baz" })
    h.set_cursor(1, 5)
  end)

  for open, close in pairs({ ["("] = ")", ["["] = "]", ["{"] = "}", ["<"] = ">" }) do
    it("ysiw" .. open .. " adds no padding", function()
      h.feed("ysiw" .. open)
      assert.are.same({ "foo " .. open .. "bar" .. close .. " baz" }, h.get_buf())
    end)
  end
end)
