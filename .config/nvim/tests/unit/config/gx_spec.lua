local h = require('helpers')

require('config.gx')

describe("gx", function()
  local opened, select_items, select_cb
  local real_open, real_select, real_notify

  before_each(function()
    h.reset()
    opened, select_items, select_cb = {}, nil, nil
    real_open, real_select, real_notify = vim.ui.open, vim.ui.select, vim.notify
    vim.ui.open = function(url) table.insert(opened, url) end
    vim.ui.select = function(items, _, cb) select_items, select_cb = items, cb end
    vim.notify = function() end
  end)

  after_each(function()
    vim.ui.open, vim.ui.select, vim.notify = real_open, real_select, real_notify
  end)

  it("opens the only URL on the line even when the cursor is elsewhere", function()
    h.set_buf({ "see https://example.com/a for details" })
    h.set_cursor(1, 0)
    h.feed("gx")
    assert.are.same({ "https://example.com/a" }, opened)
    assert.is_nil(select_items)
  end)

  it("opens the URL under the cursor when there are several", function()
    h.set_buf({ "https://one.com and https://two.com" })
    h.set_cursor(1, 25)
    h.feed("gx")
    assert.are.same({ "https://two.com" }, opened)
    assert.is_nil(select_items)
  end)

  it("prompts when there are several URLs and the cursor is on none", function()
    h.set_buf({ "x https://one.com and https://two.com" })
    h.set_cursor(1, 0)
    h.feed("gx")
    assert.are.same({}, opened)
    assert.are.same({ "https://one.com", "https://two.com" }, select_items)
    select_cb("https://two.com")
    assert.are.same({ "https://two.com" }, opened)
  end)

  it("does nothing when the line has no URL", function()
    h.set_buf({ "abc1234 fixes owner/repo#12" })
    h.set_cursor(1, 0)
    h.feed("gx")
    assert.are.same({}, opened)
    assert.is_nil(select_items)
  end)

  it("strips trailing prose punctuation", function()
    h.set_buf({ "Read https://example.com/a/b." })
    h.feed("gx")
    assert.are.same({ "https://example.com/a/b" }, opened)
  end)

  it("handles markdown links", function()
    h.set_buf({ "[docs](https://example.com/a?x=1&y=2)." })
    h.feed("gx")
    assert.are.same({ "https://example.com/a?x=1&y=2" }, opened)
  end)

  it("keeps balanced parentheses", function()
    h.set_buf({ "https://en.wikipedia.org/wiki/Foo_(bar)" })
    h.feed("gx")
    assert.are.same({ "https://en.wikipedia.org/wiki/Foo_(bar)" }, opened)
  end)

  it("splits adjacent markdown links", function()
    h.set_buf({ "[one](https://one.com)[two](https://two.com)" })
    h.feed("gx")
    assert.are.same({ "https://one.com", "https://two.com" }, select_items)
  end)

  it("splits comma-separated URLs", function()
    h.set_buf({ "x https://one.com,https://two.com" })
    h.feed("gx")
    assert.are.same({ "https://one.com", "https://two.com" }, select_items)
  end)

  it("keeps IPv6 brackets", function()
    h.set_buf({ "see http://[::1]" })
    h.feed("gx")
    assert.are.same({ "http://[::1]" }, opened)
  end)

  it("matches uppercase schemes", function()
    h.set_buf({ "HTTPS://example.com" })
    h.feed("gx")
    assert.are.same({ "HTTPS://example.com" }, opened)
  end)

  it("leaves visual mode before queued keys run", function()
    h.set_buf({ "a https://one.com", "b https://two.com" })
    h.set_cursor(1, 0)
    h.feed("Vjgxd")
    h.ensure_normal()
    assert.are.same({ "a https://one.com", "b https://two.com" }, h.get_buf())
    assert.are.same({ "https://one.com", "https://two.com" }, select_items)
  end)

  describe("file paths", function()
    local dir, real_home, real_cwd

    before_each(function()
      real_cwd = vim.uv.cwd()
      dir = vim.fn.tempname()
      vim.fn.mkdir(dir, "p")
      dir = vim.uv.fs_realpath(dir)
      vim.fn.mkdir(dir .. "/docs", "p")
      vim.fn.mkdir(dir .. "/lua/config", "p")
      vim.fn.writefile({}, dir .. "/README.md")
      vim.fn.writefile({}, dir .. "/notes.md")
      vim.fn.writefile({}, dir .. "/docs/notes.md")
      vim.fn.writefile({}, dir .. "/lua/config/gx.lua")
      vim.cmd.cd(dir)
      real_home = vim.env.HOME
      vim.env.HOME = dir
    end)

    after_each(function()
      vim.env.HOME = real_home
      vim.cmd.cd(real_cwd)
      vim.fn.delete(dir, "rf")
    end)

    it("opens a relative path that exists in cwd", function()
      h.set_buf({ "see lua/config/gx.lua for details" })
      h.feed("gx")
      assert.are.same({ dir .. "/lua/config/gx.lua" }, opened)
    end)

    it("ignores a path-shaped token that does not exist", function()
      h.set_buf({ "see lua/config/missing.lua" })
      h.feed("gx")
      assert.are.same({}, opened)
      assert.is_nil(select_items)
    end)

    it("ignores bare words even when a directory of that name exists", function()
      h.set_buf({ "the docs directory" })
      h.feed("gx")
      assert.are.same({}, opened)
    end)

    it("opens a bare filename with an extension", function()
      h.set_buf({ "read README.md first" })
      h.feed("gx")
      assert.are.same({ dir .. "/README.md" }, opened)
    end)

    it("opens a markdown link destination", function()
      h.set_buf({ "[notes](./notes.md)." })
      h.feed("gx")
      assert.are.same({ dir .. "/notes.md" }, opened)
    end)

    it("ignores a markdown link label that names a file", function()
      h.set_buf({ "[README.md](https://example.com)" })
      h.feed("gx")
      assert.are.same({ "https://example.com" }, opened)
      assert.is_nil(select_items)
    end)

    it("opens a path in backticks", function()
      h.set_buf({ "edit `lua/config/gx.lua`, then test" })
      h.feed("gx")
      assert.are.same({ dir .. "/lua/config/gx.lua" }, opened)
    end)

    it("strips a trailing line and column", function()
      h.set_buf({ "lua/config/gx.lua:42:7: error" })
      h.feed("gx")
      assert.are.same({ dir .. "/lua/config/gx.lua" }, opened)
    end)

    it("expands ~", function()
      h.set_buf({ "see ~/README.md" })
      h.feed("gx")
      assert.are.same({ dir .. "/README.md" }, opened)
    end)

    it("resolves against the buffer directory before cwd", function()
      vim.api.nvim_buf_set_name(0, dir .. "/docs/index.md")
      h.set_buf({ "see notes.md" })
      h.feed("gx")
      assert.are.same({ dir .. "/docs/notes.md" }, opened)
    end)

    it("falls back to cwd when the buffer directory has no match", function()
      vim.api.nvim_buf_set_name(0, dir .. "/docs/index.md")
      h.set_buf({ "see README.md" })
      h.feed("gx")
      assert.are.same({ dir .. "/README.md" }, opened)
    end)

    it("prompts with URLs and paths in line order", function()
      h.set_buf({ "x README.md and https://one.com" })
      h.set_cursor(1, 0)
      h.feed("gx")
      assert.are.same({ dir .. "/README.md", "https://one.com" }, select_items)
    end)

    it("opens the path under the cursor when a URL is also present", function()
      h.set_buf({ "https://one.com and README.md" })
      h.set_cursor(1, 22)
      h.feed("gx")
      assert.are.same({ dir .. "/README.md" }, opened)
    end)

    it("does not treat a URL's path segment as a file", function()
      h.set_buf({ "https://one.com/README.md" })
      h.feed("gx")
      assert.are.same({ "https://one.com/README.md" }, opened)
    end)
  end)

  it("collects URLs across a visual selection", function()
    h.set_buf({ "a https://one.com", "b https://two.com", "c https://three.com" })
    h.set_cursor(1, 0)
    h.feed("Vj")
    h.feed("gx")
    h.ensure_normal()
    assert.are.same({ "https://one.com", "https://two.com" }, select_items)
  end)
end)
