local h = require('helpers')

local function neotree_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'neo-tree' then
      return true
    end
  end
  return false
end

describe("Neo-tree toggle (with plugins)", function()
  before_each(function()
    h.reset()
    vim.cmd.Neotree('close')
  end)

  after_each(function()
    vim.cmd.Neotree('close')
  end)

  it("maps ctrl-dash in normal, insert, and terminal mode", function()
    for _, mode in ipairs({ 'n', 'i', 't' }) do
      assert.not_equals('', vim.fn.maparg('<C-->', mode), '<C--> missing in mode ' .. mode)
      assert.not_equals('', vim.fn.maparg('<C-_>', mode), '<C-_> missing in mode ' .. mode)
    end
  end)

  it("opens Neo-tree from insert mode", function()
    -- feed() leaves insert mode once typeahead is empty, so send both keys at once.
    h.feed("i<C-->")
    assert.is_true(neotree_open())
    h.ensure_normal()
  end)
end)
