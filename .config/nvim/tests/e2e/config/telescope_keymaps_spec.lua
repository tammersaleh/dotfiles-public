local keys = { 'f', 'F', 'g', 'G', 'k', 'w', 'b', 'd', 'h', 'a', 'r' }
local modes = { 'n', 'i', 'x', 't' }

describe("Telescope keymaps (with plugins)", function()
  it("puts every picker under <C-f> in normal, insert, visual, and terminal mode", function()
    for _, key in ipairs(keys) do
      for _, mode in ipairs(modes) do
        assert.not_equals('', vim.fn.maparg('<C-f>' .. key, mode), '<C-f>' .. key .. ' missing in mode ' .. mode)
      end
    end
  end)

  it("drops the old <leader>f prefix", function()
    for _, key in ipairs(keys) do
      assert.equals('', vim.fn.maparg('<leader>f' .. key, 'n'), '<leader>f' .. key .. ' still mapped')
    end
  end)

  -- which-key's auto triggers skip insert and terminal mode, where the
  -- prefix would otherwise time out after 'timeoutlen'.
  it("holds <C-f> for which-key in every mode", function()
    local buf = vim.api.nvim_get_current_buf()
    -- Specs run from -c, before VimEnter, which is when which-key loads.
    if vim.v.vim_did_enter == 0 then vim.api.nvim_exec_autocmds('VimEnter', {}) end
    assert.is_true(vim.wait(2000, function() return require('which-key.config').loaded end))
    for _, mode in ipairs(modes) do
      -- which-key attaches a mode's triggers on first entry to that mode,
      -- which headless tests never do. Attach directly (internal API).
      require('which-key.buf').get({ buf = buf, mode = mode })
      local trigger = vim.wait(2000, function()
        local m = vim.fn.maparg('<C-f>', mode, false, true)
        return (m.desc or ''):find('which-key-trigger', 1, true) ~= nil
      end)
      assert.is_true(trigger, 'no which-key trigger for <C-f> in mode ' .. mode .. ' (buf ' .. buf .. ')')
    end
  end)
end)
