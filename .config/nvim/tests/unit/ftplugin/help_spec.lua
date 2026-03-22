local h = require('helpers')

describe("ftplugin/help", function()
  before_each(function()
    h.reset()
    vim.bo.filetype = 'help'
  end)

  it("maps K to jump to tag", function()
    local maps = vim.api.nvim_buf_get_keymap(0, 'n')
    local found = false
    for _, map in ipairs(maps) do
      if map.lhs == 'K' then
        found = true
        assert.equals('<C-]>', map.rhs)
        break
      end
    end
    assert.is_true(found, "K mapping not found in help buffer")
  end)

  it("maps Enter to jump to tag", function()
    local maps = vim.api.nvim_buf_get_keymap(0, 'n')
    local found = false
    for _, map in ipairs(maps) do
      if map.lhs == '<CR>' then
        found = true
        assert.equals('<C-]>', map.rhs)
        break
      end
    end
    assert.is_true(found, "Enter mapping not found in help buffer")
  end)
end)
