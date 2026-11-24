-- Inline code uses the colorscheme's blue, not the white that String
-- (and so @markup.raw) is set to. Fenced blocks keep @markup.raw.block.
describe("markdown inline code colour", function()
  local function fg(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false }).fg
  end

  it("is blue for markdown_inline only", function()
    assert.is_not_nil(fg('Blue'))
    assert.equals(fg('Blue'), fg('@markup.raw.markdown_inline'))
    assert.are_not.equal(fg('Blue'), fg('@markup.raw'))
  end)
end)
