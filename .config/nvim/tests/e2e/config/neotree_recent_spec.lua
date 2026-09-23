local h = require('helpers')
local recent = require('config.recent_files')

local function neotree_win(source)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == 'neo-tree' and vim.b[buf].neo_tree_source == source then
      return win
    end
  end
  return nil
end

-- The filesystem source renders after an async directory scan.
local function wait_for_win(source)
  vim.wait(1000, function() return neotree_win(source) ~= nil end)
  return neotree_win(source)
end

local function tree_lines(source)
  local win = neotree_win(source)
  assert.is_not_nil(win, 'no neo-tree window for source ' .. source)
  local lines = vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(win), 0, -1, false)
  return vim.tbl_map(vim.trim, lines)
end

describe("Neo-tree recent source (with plugins)", function()
  local dir

  before_each(function()
    h.reset()
    vim.cmd.Neotree('close')
    dir = vim.uv.fs_realpath(vim.fn.tempname() .. '_x') or vim.fn.tempname()
    vim.fn.mkdir(dir, 'p')
    dir = vim.uv.fs_realpath(dir)
    recent.clear()
  end)

  after_each(function()
    vim.cmd.Neotree('close')
    vim.cmd('silent! %bwipeout!')
    vim.fn.delete(dir, 'rf')
  end)

  it("opens as its own source", function()
    vim.cmd.Neotree('recent')
    assert.is_not_nil(neotree_win('recent'))
  end)

  it("lists recently edited files by basename, newest first", function()
    vim.fn.writefile({ '' }, dir .. '/alpha.txt')
    vim.fn.writefile({ '' }, dir .. '/beta.lua')
    vim.cmd('edit! ' .. dir .. '/alpha.txt')
    vim.cmd('edit! ' .. dir .. '/beta.lua')
    vim.cmd.Neotree('recent')
    local lines = tree_lines('recent')
    local beta, alpha
    for i, l in ipairs(lines) do
      if l:find('beta.lua', 1, true) then beta = i end
      if l:find('alpha.txt', 1, true) then alpha = i end
    end
    assert.is_not_nil(beta, 'beta.lua missing from ' .. vim.inspect(lines))
    assert.is_not_nil(alpha, 'alpha.txt missing from ' .. vim.inspect(lines))
    assert.is_true(beta < alpha, 'expected beta.lua above alpha.txt in ' .. vim.inspect(lines))
    for _, l in ipairs(lines) do
      assert.is_nil(l:find(dir, 1, true), 'full path leaked into tree: ' .. l)
    end
  end)

  it("moves between source tabs with the arrow keys", function()
    vim.cmd.Neotree('filesystem')
    vim.api.nvim_set_current_win(wait_for_win('filesystem'))
    h.feed('<Left>') -- wraps from the first tab to the last
    assert.is_not_nil(neotree_win('recent'))
    vim.api.nvim_set_current_win(neotree_win('recent'))
    h.feed('<Right>')
    assert.is_not_nil(wait_for_win('filesystem'))
  end)

  it("switches to the recent tab with 4", function()
    vim.cmd.Neotree('filesystem')
    vim.api.nvim_set_current_win(wait_for_win('filesystem'))
    h.feed('4')
    assert.is_not_nil(neotree_win('recent'))
  end)

  it("opens the file under the cursor with <cr>", function()
    vim.fn.writefile({ 'hello' }, dir .. '/alpha.txt')
    vim.cmd('edit! ' .. dir .. '/alpha.txt')
    h.reset()
    vim.bo.modified = false -- a modified scratch buffer blocks :b in the target window
    vim.cmd.Neotree('recent')
    local win = neotree_win('recent')
    vim.api.nvim_set_current_win(win)
    local lines = tree_lines('recent')
    for i, l in ipairs(lines) do
      if l:find('alpha.txt', 1, true) then
        vim.api.nvim_win_set_cursor(win, { i, 0 })
      end
    end
    -- Bypass window-picker (which prompts) and call the plain open command.
    local state = require('neo-tree.sources.manager').get_state('recent')
    require('neo-tree.sources.common.commands').open(state)
    assert.equals(dir .. '/alpha.txt', vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0)))
  end)
end)
