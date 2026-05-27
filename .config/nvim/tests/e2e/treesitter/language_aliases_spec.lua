describe("treesitter filetype -> parser aliases", function()
  it("typescriptreact filetype maps to the 'tsx' parser", function()
    assert.equals('tsx', vim.treesitter.language.get_lang('typescriptreact'))
  end)

  it("javascriptreact filetype maps to the 'javascript' parser", function()
    assert.equals('javascript', vim.treesitter.language.get_lang('javascriptreact'))
  end)

  it("opening a .tsx file uses the tsx parser", function()
    local tmp = vim.fn.tempname() .. '.tsx'
    vim.fn.writefile({ 'export const C = () => <div />;' }, tmp)
    vim.cmd('edit ' .. vim.fn.fnameescape(tmp))
    vim.wait(300, function()
      return vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil
    end, 20)
    assert.equals('typescriptreact', vim.bo.filetype)

    local parser = vim.treesitter.get_parser(0)
    assert.is_not_nil(parser, "expected a parser for .tsx buffer")
    assert.equals('tsx', parser:lang())
  end)
end)
