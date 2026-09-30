local h = require('helpers')

local config_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h:h:h')
vim.opt.rtp:prepend(config_dir .. '/tests/fixtures')

local function neotree_win(source)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == 'neo-tree' and (not source or vim.b[buf].neo_tree_source == source) then
      return win
    end
  end
  return nil
end

local function wait_for_win(source)
  vim.wait(1000, function() return neotree_win(source) ~= nil end)
  return neotree_win(source)
end

describe("Neo-tree add_source (with plugins)", function()
  local neotree = require('config.neotree')

  before_each(function()
    neotree.add_source('neotree_fixture', { display_name = ' Fixture ' })
    h.reset()
    vim.cmd.Neotree('close')
  end)

  after_each(function()
    vim.cmd.Neotree('close')
  end)

  it("registers the source by name", function()
    assert.is_true(vim.tbl_contains(neotree.source_names(), 'fixture'))
  end)

  it("opens the added source", function()
    vim.cmd.Neotree('fixture')
    local win = wait_for_win('fixture')
    assert.is_not_nil(win)
    local lines = vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(win), 0, -1, false)
    assert.is_true(vim.iter(lines):any(function(l) return l:find('fixture-item', 1, true) ~= nil end))
  end)

  it("shows the added source in the selector", function()
    vim.cmd.Neotree('fixture')
    local win = wait_for_win('fixture')
    local bar = vim.api.nvim_eval_statusline(vim.wo[win].winbar, { winid = win, use_winbar = true }).str
    assert.is_truthy(bar:find('Fix', 1, true))
  end)

  it("switches to the added source with its number key", function()
    vim.cmd.Neotree('filesystem')
    vim.api.nvim_set_current_win(wait_for_win('filesystem'))
    h.feed('5')
    assert.is_not_nil(wait_for_win('fixture'))
  end)

  it("closes the added source with the toggle", function()
    vim.cmd.Neotree('fixture')
    assert.is_not_nil(wait_for_win('fixture'))
    vim.cmd.wincmd('p')
    h.feed('-')
    assert.is_nil(neotree_win())
  end)

  it("ignores a second add of the same module", function()
    neotree.add_source('neotree_fixture', { display_name = ' Fixture ' })
    local count = #vim.tbl_filter(function(n) return n == 'fixture' end, neotree.source_names())
    assert.equals(1, count)
  end)
end)
