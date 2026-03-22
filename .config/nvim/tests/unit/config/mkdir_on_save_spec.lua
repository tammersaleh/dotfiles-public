local h = require('helpers')

require('config.mkdir_on_save')

describe("mkdir_on_save", function()
  it("registers BufWritePre autocmd", function()
    local autocmds = vim.api.nvim_get_autocmds({ group = 'mkdir_on_save' })
    assert.equals(1, #autocmds)
    assert.equals('BufWritePre', autocmds[1].event)
  end)

  it("creates parent directories on save", function()
    local tmpdir = vim.fn.tempname()
    local filepath = tmpdir .. '/deeply/nested/dir/file.txt'

    h.reset()
    vim.api.nvim_buf_set_name(0, filepath)
    h.set_buf({ "test content" })

    -- Trigger the autocmd manually
    vim.api.nvim_exec_autocmds('BufWritePre', { pattern = filepath })

    local parent = vim.fn.fnamemodify(filepath, ':h')
    assert.equals(1, vim.fn.isdirectory(parent))

    -- Cleanup
    vim.fn.delete(tmpdir, 'rf')
  end)

  it("skips URLs", function()
    local autocmds = vim.api.nvim_get_autocmds({ group = 'mkdir_on_save' })
    local callback = autocmds[1].callback

    -- Should not error on URL patterns
    local ok = pcall(callback, { match = 'https://example.com/file.txt' })
    assert.is_true(ok)
  end)
end)
