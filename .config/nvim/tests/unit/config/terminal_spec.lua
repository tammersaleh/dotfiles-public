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

  describe("tab title follows the terminal", function()
    -- Start a terminal (in a split so nvim survives its exit) whose shell emits
    -- an OSC title sequence, then keep the shell alive so the terminal buffer
    -- persists while we assert. \033/\007 are the OSC introducer/terminator;
    -- \045 is octal for '%' (kept off the Ex command line, where '%' would
    -- expand to the current filename).
    local function run_titled_term(osc_body_octal)
      vim.cmd('enew')
      vim.cmd('split')
      vim.cmd("terminal sh -c 'printf \"\\033]2;" .. osc_body_octal .. "\\007\"; sleep 10'")
      return vim.api.nvim_get_current_buf()
    end

    before_each(function()
      vim.cmd('silent! only')
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buftype == 'terminal' then
          vim.api.nvim_buf_delete(b, { force = true })
        end
      end
      vim.o.titlestring = ''
    end)

    after_each(function()
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buftype == 'terminal' then
          vim.api.nvim_buf_delete(b, { force = true })
        end
      end
    end)

    it("pins titlestring to the OSC title the terminal sets", function()
      run_titled_term('CLAUDE SESSION')
      vim.wait(4000, function() return vim.o.titlestring == 'CLAUDE SESSION' end)
      assert.equals('CLAUDE SESSION', vim.o.titlestring)
    end)

    it("keeps the pinned title when focus moves to a normal buffer", function()
      run_titled_term('CLAUDE SESSION')
      vim.wait(4000, function() return vim.o.titlestring == 'CLAUDE SESSION' end)
      vim.cmd('wincmd w')
      assert.not_equals('terminal', vim.bo.buftype)
      assert.equals('CLAUDE SESSION', vim.o.titlestring)
    end)

    it("escapes '%' so it is not read as a statusline item", function()
      run_titled_term('50\\045 done')
      vim.wait(4000, function() return vim.o.titlestring ~= '' end)
      assert.equals('50%% done', vim.o.titlestring)
    end)

    it("resets titlestring to default when the last terminal closes", function()
      vim.cmd('enew')
      vim.cmd('split')
      vim.cmd("terminal sh -c 'sleep 10'")
      local buf = vim.api.nvim_get_current_buf()
      vim.o.titlestring = 'STALE SESSION'          -- as if a session had pinned it
      vim.api.nvim_buf_delete(buf, { force = true }) -- close the terminal -> TermClose
      vim.wait(4000, function() return not vim.api.nvim_buf_is_valid(buf) end)
      assert.is_false(vim.api.nvim_buf_is_valid(buf))
      assert.equals('', vim.o.titlestring)
    end)
  end)
end)
