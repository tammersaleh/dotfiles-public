-- Regression test for the broken `set-lang-from-info-string!` predicate that
-- was triggered on every markdown buffer read by snacks.nvim's scope/indent.
-- See plans/treesitter-migration.md.

describe("markdown buffer with fenced code block", function()
  local tmpfile

  before_each(function()
    tmpfile = vim.fn.tempname() .. '.md'
    vim.fn.writefile({
      '# Heading',
      '',
      '```lua',
      'local x = 1',
      '```',
      '',
      'End.',
    }, tmpfile)
    pcall(vim.cmd, 'messages clear')
  end)

  after_each(function()
    if tmpfile then vim.fn.delete(tmpfile) end
  end)

  it("opens without a treesitter 'range' nil error", function()
    vim.cmd('edit ' .. vim.fn.fnameescape(tmpfile))
    vim.api.nvim_win_set_cursor(0, { 4, 2 })
    vim.wait(200, function() return false end)

    local msgs = vim.api.nvim_exec2('messages', { output = true }).output
    assert.is_nil(
      msgs:match("attempt to call method 'range'"),
      "treesitter 'range' nil error in messages:\n" .. msgs
    )
  end)

  it("can parse markdown with injections directly", function()
    vim.cmd('edit ' .. vim.fn.fnameescape(tmpfile))
    local ok_get, parser = pcall(vim.treesitter.get_parser, 0, 'markdown')
    assert.is_true(ok_get, "get_parser failed: " .. tostring(parser))

    local ok_parse, err = pcall(function() parser:parse(true) end)
    assert.is_true(
      ok_parse,
      "markdown parse with injections errored: " .. tostring(err)
    )
  end)
end)
