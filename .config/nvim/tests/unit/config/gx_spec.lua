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

  it("collects URLs across a visual selection", function()
    h.set_buf({ "a https://one.com", "b https://two.com", "c https://three.com" })
    h.set_cursor(1, 0)
    h.feed("Vj")
    h.feed("gx")
    h.ensure_normal()
    assert.are.same({ "https://one.com", "https://two.com" }, select_items)
  end)
end)
