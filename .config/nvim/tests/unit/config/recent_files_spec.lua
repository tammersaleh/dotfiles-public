local recent = require('config.recent_files')

describe("recent_files", function()
  local dir

  local function touch_file(name)
    local path = dir .. '/' .. name
    vim.fn.writefile({ '' }, path)
    return path
  end

  before_each(function()
    dir = vim.fn.tempname()
    vim.fn.mkdir(dir, 'p')
    dir = vim.uv.fs_realpath(dir)
    recent.clear()
  end)

  after_each(function()
    vim.fn.delete(dir, 'rf')
  end)

  it("lists touched files most recent first", function()
    local a, b, c = touch_file('a'), touch_file('b'), touch_file('c')
    recent.touch(a)
    recent.touch(b)
    recent.touch(c)
    assert.are.same({ c, b, a }, recent.list())
  end)

  it("moves a re-touched file to the front without duplicating it", function()
    local a, b = touch_file('a'), touch_file('b')
    recent.touch(a)
    recent.touch(b)
    recent.touch(a)
    assert.are.same({ a, b }, recent.list())
  end)

  it("drops files that no longer exist", function()
    local a, b = touch_file('a'), touch_file('b')
    recent.touch(a)
    recent.touch(b)
    vim.fn.delete(a)
    assert.are.same({ b }, recent.list())
  end)

  it("caps the list at the limit", function()
    local paths = {}
    for i = 1, 5 do
      paths[i] = touch_file('f' .. i)
      recent.touch(paths[i])
    end
    assert.are.same({ paths[5], paths[4], paths[3] }, recent.list({ limit = 3 }))
  end)

  it("removes an entry", function()
    local a, b = touch_file('a'), touch_file('b')
    recent.touch(a)
    recent.touch(b)
    recent.remove(b)
    assert.are.same({ a }, recent.list())
  end)

  it("normalizes paths to absolute", function()
    local a = touch_file('a')
    vim.cmd.cd(dir)
    recent.touch('a')
    assert.are.same({ a }, recent.list())
    vim.cmd.cd('-')
  end)

  it("ignores empty and non-file paths", function()
    recent.touch('')
    recent.touch('term://foo//1:zsh')
    recent.touch(dir)
    assert.are.same({}, recent.list())
  end)

  it("seeds from v:oldfiles on setup, after live entries", function()
    local a, b = touch_file('a'), touch_file('b')
    local saved = vim.v.oldfiles
    vim.v.oldfiles = { a }
    recent.setup()
    recent.touch(b)
    assert.are.same({ b, a }, recent.list())
    vim.v.oldfiles = saved
  end)

  it("tracks BufEnter for real files after setup", function()
    local a = touch_file('a')
    recent.setup()
    vim.cmd.edit(a)
    assert.are.same({ a }, recent.list())
    vim.cmd('bwipeout!')
  end)
end)
