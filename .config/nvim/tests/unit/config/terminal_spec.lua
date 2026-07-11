require('config.terminal')

describe("terminal", function()
  describe("TermClose auto-close", function()
    -- Run a terminal in a split (so a second window survives the close and the
    -- test process doesn't quit), then wait for the terminal buffer to vanish.
    local function close_on_exit(shell_cmd)
      vim.cmd('enew')
      vim.cmd('split')
      vim.cmd("terminal sh -c '" .. shell_cmd .. "'")
      local buf = vim.api.nvim_get_current_buf()
      vim.wait(4000, function() return not vim.api.nvim_buf_is_valid(buf) end)
      return buf
    end

    it("closes when the shell exits 0", function()
      local buf = close_on_exit('exit 0')
      assert.is_false(vim.api.nvim_buf_is_valid(buf))
    end)

    it("closes when the shell exits 1", function()
      local buf = close_on_exit('exit 1')
      assert.is_false(vim.api.nvim_buf_is_valid(buf))
    end)

    it("closes when the shell exits 127", function()
      local buf = close_on_exit('exit 127')
      assert.is_false(vim.api.nvim_buf_is_valid(buf))
    end)
  end)
end)
