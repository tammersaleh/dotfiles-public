local keys = { 'f', 'F', 'g', 'G', 'k', 'w', 'b', 'd', 'h', 'a', 'r' }
local modes = { 'n', 'i', 'x', 't' }

describe("Telescope keymaps (with plugins)", function()
  it("puts every picker under <C-f> in normal, insert, visual, and terminal mode", function()
    for _, key in ipairs(keys) do
      for _, mode in ipairs(modes) do
        assert.not_equals('', vim.fn.maparg('<C-f>' .. key, mode), '<C-f>' .. key .. ' missing in mode ' .. mode)
      end
    end
  end)

  it("drops the old <leader>f prefix", function()
    for _, key in ipairs(keys) do
      assert.equals('', vim.fn.maparg('<leader>f' .. key, 'n'), '<leader>f' .. key .. ' still mapped')
    end
  end)
end)
