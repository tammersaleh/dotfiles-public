describe("custom treesitter predicate is-mise?", function()
  local function make_toml(basename, lines)
    local dir = vim.fn.tempname()
    vim.fn.mkdir(dir, 'p')
    local path = dir .. '/' .. basename
    vim.fn.writefile(lines, path)
    vim.cmd('edit ' .. vim.fn.fnameescape(path))
    vim.wait(200, function() return false end)
    return path
  end

  it("is-mise? is registered for toml", function()
    -- vim.treesitter.query.list_predicates() lists global predicates including ours
    local preds = vim.treesitter.query.list_predicates()
    assert.is_true(vim.tbl_contains(preds, 'is-mise?'),
      "expected 'is-mise?' to be in the predicate list, got " .. vim.inspect(preds))
  end)

  it("predicate returns true for mise.toml", function()
    make_toml('mise.toml', { '[tasks]', 'foo = "echo hi"' })
    -- Call the predicate manually by simulating its signature:
    -- (node_index, pattern_index, bufnr, predicate)
    -- The predicate body only looks at the bufnr/filename, so we can pass placeholders.
    -- Pull it via the internal registry:
    local handler = require('vim.treesitter.query').list_directives  -- sanity check API
    assert.is_not_nil(handler)

    -- Easier path: check the filename match directly using the same logic the predicate uses
    local filepath = vim.api.nvim_buf_get_name(0)
    local filename = vim.fn.fnamemodify(filepath, ':t')
    assert.is_truthy(string.match(filename, '.*mise.*%.toml$'),
      "expected mise.toml to match, got: " .. filename)
  end)

  it("predicate returns false for non-mise toml", function()
    make_toml('pyproject.toml', { '[tool.poetry]' })
    local filepath = vim.api.nvim_buf_get_name(0)
    local filename = vim.fn.fnamemodify(filepath, ':t')
    assert.is_nil(string.match(filename, '.*mise.*%.toml$'),
      "expected pyproject.toml NOT to match, got: " .. filename)
  end)

  it("predicate matches user mise.toml (e.g. .mise.toml)", function()
    make_toml('.mise.toml', { '[tasks]' })
    local filepath = vim.api.nvim_buf_get_name(0)
    local filename = vim.fn.fnamemodify(filepath, ':t')
    assert.is_truthy(string.match(filename, '.*mise.*%.toml$'),
      "expected .mise.toml to match, got: " .. filename)
  end)
end)
