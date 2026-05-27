describe("treesitter highlighter attachment", function()
  local function open(ft, lines)
    local tmpdir = vim.fn.tempname()
    vim.fn.mkdir(tmpdir, 'p')
    local path = tmpdir .. '/file.' .. ft
    vim.fn.writefile(lines, path)
    vim.cmd('edit ' .. vim.fn.fnameescape(path))
    vim.wait(50, function() return false end)
    return vim.api.nvim_get_current_buf()
  end

  local cases = {
    { ext = 'md', ft = 'markdown', lines = { '# H', '', '```lua', 'local x = 1', '```' } },
    { ext = 'go', ft = 'go', lines = { 'package main', 'func main() {}' } },
    { ext = 'py', ft = 'python', lines = { 'def foo():', '    return 1' } },
    { ext = 'rb', ft = 'ruby', lines = { 'def foo', '  1', 'end' } },
    { ext = 'ts', ft = 'typescript', lines = { 'function foo(): number { return 1; }' } },
    { ext = 'tsx', ft = 'typescriptreact', lines = { 'export const C = () => <div />;' } },
    { ext = 'lua', ft = 'lua', lines = { 'local x = 1' } },
  }

  for _, c in ipairs(cases) do
    it("attaches treesitter highlighter for " .. c.ft, function()
      local buf = open(c.ext, c.lines)
      assert.equals(c.ft, vim.bo[buf].filetype)
      assert.is_not_nil(
        vim.treesitter.highlighter.active[buf],
        "no treesitter highlighter active for ft=" .. c.ft
      )
    end)
  end
end)
