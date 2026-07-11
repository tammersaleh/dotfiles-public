local h = require('helpers')

-- nvim-ts-autotag aliases markdown to html and maps `>` in insert mode to a
-- callback that inserts the `>` via nvim_buf_set_text (a programmatic edit, not
-- typed input). That breaks dot-repeat: `.` never records the `>`. Autotag must
-- stay disabled for markdown so `>` is typed normally.
describe("markdown dot-repeat with > (with plugins)", function()
  before_each(function()
    h.reset()
    vim.bo.filetype = 'markdown'
    vim.wait(200)
  end)

  it("has no autotag > mapping in markdown buffers", function()
    assert.equals('', vim.fn.maparg('>', 'i'))
  end)

  it("repeats I> across lines with .", function()
    h.set_buf({ "alpha", "beta" })
    h.set_cursor(1)
    h.feed("I>")
    h.ensure_normal()
    h.feed("j.")
    assert.are.same({ ">alpha", ">beta" }, h.get_buf())
  end)
end)
