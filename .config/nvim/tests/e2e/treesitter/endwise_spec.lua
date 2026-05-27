local h = require('helpers')

-- Endwise hooks vim.on_key + vim.schedule_wrap, which only fires for real
-- input through nvim_feedkeys' 'x' flag, AND requires the buffer to already
-- contain the trigger text (so the parser sees it). So tests pre-populate
-- the buffer, then send only the Enter.

local function press_enter_at_end(buf_line)
  vim.api.nvim_win_set_cursor(0, { 1, #buf_line })
  local keys = vim.api.nvim_replace_termcodes('a<CR>', true, false, true)
  vim.api.nvim_feedkeys(keys, 'tx', false)
  return vim.wait(2000, function()
    return vim.tbl_contains(vim.api.nvim_buf_get_lines(0, 0, -1, false), 'end')
  end, 20)
end

local function ruby_case(name, line)
  it("ruby: " .. name .. " adds 'end'", function()
    local tmp = vim.fn.tempname() .. '.rb'
    vim.fn.writefile({ line }, tmp)
    vim.cmd('edit ' .. vim.fn.fnameescape(tmp))
    vim.wait(100, function() return false end)
    assert.equals('ruby', vim.bo.filetype)

    local got = press_enter_at_end(line)
    h.ensure_normal()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    assert.is_true(got, name .. ": expected 'end' inserted; got:\n" .. table.concat(lines, '\n'))
  end)
end

describe("nvim-treesitter-endwise ruby contexts", function()
  ruby_case('def',    'def foo')
  ruby_case('class',  'class Foo')
  ruby_case('module', 'module Foo')
  ruby_case('if',     'if x')
  ruby_case('unless', 'unless x')
  ruby_case('while',  'while x')
  ruby_case('until',  'until x')
  ruby_case('case',   'case x')
  ruby_case('begin',  'begin')
  ruby_case('do',     'x.each do |y|')
end)

describe("nvim-treesitter-endwise other languages", function()
  it("lua: 'function foo()' adds 'end'", function()
    local tmp = vim.fn.tempname() .. '.lua'
    vim.fn.writefile({ 'function foo()' }, tmp)
    vim.cmd('edit ' .. vim.fn.fnameescape(tmp))
    vim.wait(300, function()
      return vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil
    end, 20)
    assert.equals('lua', vim.bo.filetype)

    local got = press_enter_at_end('function foo()')
    h.ensure_normal()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    assert.is_true(got, "lua function: expected 'end'; got:\n" .. table.concat(lines, '\n'))
  end)

  it("bash: 'if [[ x ]]; then' adds 'fi'", function()
    local tmp = vim.fn.tempname() .. '.sh'
    vim.fn.writefile({ '#!/usr/bin/env bash', 'if [[ x ]]; then' }, tmp)
    vim.cmd('edit ' .. vim.fn.fnameescape(tmp))
    vim.wait(200, function() return false end)
    vim.bo.filetype = 'bash'
    vim.wait(200, function() return false end)
    assert.equals('bash', vim.bo.filetype)

    vim.api.nvim_win_set_cursor(0, { 2, #'if [[ x ]]; then' })
    local keys = vim.api.nvim_replace_termcodes('a<CR>', true, false, true)
    vim.api.nvim_feedkeys(keys, 'tx', false)
    local got = vim.wait(2000, function()
      return vim.tbl_contains(vim.api.nvim_buf_get_lines(0, 0, -1, false), 'fi')
    end, 20)
    h.ensure_normal()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    assert.is_true(got, "bash if: expected 'fi'; got:\n" .. table.concat(lines, '\n'))
  end)
end)
