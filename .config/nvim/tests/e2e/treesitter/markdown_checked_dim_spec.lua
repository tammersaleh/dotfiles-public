-- Checked list items dim: the whole item, nested children included, at a
-- priority above the inline highlights (after/queries/markdown/highlights.scm).
describe("markdown checked item dimming", function()
  local buf
  local lines = {
    '- [x] done **bold** [link](http://x) `code`', -- row 0
    '    - child text',                            -- row 1
    '    - [ ] child box',                         -- row 2
    '- [ ] open **bold**',                         -- row 3
    '    - [x] checked child',                     -- row 4
    '- plain',                                     -- row 5
  }

  local function dim_priority(row, col)
    for _, c in ipairs(vim.treesitter.get_captures_at_pos(buf, row, col)) do
      if c.capture == 'markup.list.checked.item' then
        return tonumber(c.metadata.priority)
      end
    end
  end

  before_each(function()
    local path = vim.fn.tempname() .. '.md'
    vim.fn.writefile(lines, path)
    vim.cmd('edit ' .. vim.fn.fnameescape(path))
    buf = vim.api.nvim_get_current_buf()
    vim.treesitter.get_parser(buf):parse(true)
  end)

  it("dims the checked item's text above inline highlights", function()
    for _, col in ipairs({ 0, 6, 13, 20, 38 }) do
      assert.equals(200, dim_priority(0, col), "col " .. col)
    end
  end)

  it("dims nested children of a checked item", function()
    assert.equals(200, dim_priority(1, 8))
    assert.equals(200, dim_priority(2, 12))
  end)

  it("dims a checked child but not its unchecked parent", function()
    assert.is_nil(dim_priority(3, 8))
    assert.equals(200, dim_priority(4, 12))
  end)

  it("leaves plain items alone", function()
    assert.is_nil(dim_priority(5, 3))
  end)

  it("uses a dim foreground for the item and the checked icon", function()
    local grey = vim.api.nvim_get_hl(0, { name = 'Grey', link = false }).fg
    assert.is_not_nil(grey)
    assert.equals(grey, vim.api.nvim_get_hl(0, { name = '@markup.list.checked.item', link = false }).fg)
    assert.equals(grey, vim.api.nvim_get_hl(0, { name = 'RenderMarkdownChecked', link = false }).fg)
  end)
end)
