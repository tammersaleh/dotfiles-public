describe("treesitter indent (indentexpr)", function()
  local function open(ext, lines)
    local tmp = vim.fn.tempname() .. '.' .. ext
    vim.fn.writefile(lines, tmp)
    vim.cmd('edit ' .. vim.fn.fnameescape(tmp))
    vim.wait(300, function()
      return vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil
    end, 20)
  end

  it("python: indentexpr is wired to nvim-treesitter on python buffers", function()
    open('py', { 'def foo():', '    return 1' })
    assert.equals(
      "v:lua.require'nvim-treesitter'.indentexpr()",
      vim.bo.indentexpr,
      "expected treesitter indentexpr to be set for python"
    )
  end)

  it("typescript: indentexpr is wired to nvim-treesitter on ts buffers", function()
    open('ts', { 'function foo() {', '  return 1;', '}' })
    assert.equals(
      "v:lua.require'nvim-treesitter'.indentexpr()",
      vim.bo.indentexpr
    )
  end)

  it("python: 'o' on def line opens an indented new line", function()
    open('py', { 'def foo():' })
    vim.bo.expandtab = true
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    local keys = vim.api.nvim_replace_termcodes('oreturn 1<Esc>', true, false, true)
    vim.api.nvim_feedkeys(keys, 'tx', false)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    assert.equals('    return 1', lines[2],
      "expected treesitter to auto-indent body to 4 spaces, got: " .. vim.inspect(lines))
  end)

  it("markdown does NOT get treesitter indentexpr (excluded by design)", function()
    local tmp = vim.fn.tempname() .. '.md'
    vim.fn.writefile({ '# H' }, tmp)
    vim.cmd('edit ' .. vim.fn.fnameescape(tmp))
    vim.wait(200, function() return false end)
    assert.equals('markdown', vim.bo.filetype)
    assert.is_not_equal(
      "v:lua.require'nvim-treesitter'.indentexpr()",
      vim.bo.indentexpr,
      "markdown should keep its own indentexpr from after/ftplugin/markdown.lua"
    )
  end)
end)
