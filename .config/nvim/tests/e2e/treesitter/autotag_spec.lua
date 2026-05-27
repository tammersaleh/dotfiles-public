local h = require('helpers')

local function open(ext, lines)
  local tmp = vim.fn.tempname() .. '.' .. ext
  vim.fn.writefile(lines or { '' }, tmp)
  vim.cmd('edit ' .. vim.fn.fnameescape(tmp))
  vim.wait(200, function() return false end)
end

describe("nvim-ts-autotag", function()
  it("html: typing <div> closes to <div></div>", function()
    open('html')
    assert.equals('html', vim.bo.filetype)
    h.feed('i<div>')
    h.ensure_normal()
    assert.equals('<div></div>', vim.api.nvim_buf_get_lines(0, 0, 1, false)[1])
  end)

  it("html: typing self-closing <br /> doesn't add close tag", function()
    open('html')
    h.feed('i<br />')
    h.ensure_normal()
    -- Should be a single line <br /> with nothing appended after
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    assert.equals('<br />', lines[1])
    assert.is_true(#lines == 1 or lines[2] == '' or lines[2] == nil,
      "expected no extra content after self-closing tag, got:\n" .. table.concat(lines, '\n'))
  end)

  it("tsx: typing <div> closes to <div></div>", function()
    open('tsx', { 'export const C = () => ', '' })
    assert.equals('typescriptreact', vim.bo.filetype)
    vim.api.nvim_win_set_cursor(0, { 1, #'export const C = () => ' })
    h.feed('a<div>')
    h.ensure_normal()
    local line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    assert.equals('export const C = () => <div></div>', line)
  end)

  it("html: renames closing tag on InsertLeave when opening tag changes", function()
    open('html', { '<div></div>' })
    -- Edit the opening tag to <span>
    vim.api.nvim_win_set_cursor(0, { 1, 1 })  -- on 'd' of opening <div>
    h.feed('cw' .. 'span')
    h.ensure_normal()
    -- The InsertLeave autocmd renames the matching closing tag
    vim.wait(200, function()
      return vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == '<span></span>'
    end, 20)
    local line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    assert.equals('<span></span>', line)
  end)
end)
