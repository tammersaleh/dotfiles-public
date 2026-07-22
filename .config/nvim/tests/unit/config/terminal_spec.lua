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

  describe("tab title follows Claude", function()
    local T = require('config.terminal')

    -- Start a terminal in a split (so nvim survives its exit). The shell emits
    -- an OSC title sequence, then sleeps so the buffer persists during asserts.
    -- \033/\007 are the OSC introducer/terminator; \045 is octal for '%' (kept
    -- off the Ex command line, where '%' expands to the current filename).
    local function run_term(cmd)
      vim.cmd('enew')
      vim.cmd('split')
      vim.cmd("terminal " .. cmd)
      return vim.api.nvim_get_current_buf()
    end
    local function emit(title)
      return 'printf \"\\033]2;' .. title .. '\\007\"'
    end
    -- A Claude terminal has "claude" in its command. ': claude' is a shell
    -- no-op (the ':' builtin ignores its args), so the real claude never runs.
    local function claude_cmd(title)
      return "sh -c ': claude; " .. emit(title) .. "; sleep 10'"
    end
    local function plain_cmd(title)
      return "sh -c '" .. emit(title) .. "; sleep 10'"
    end

    local function kill_terminals()
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buftype == 'terminal' then
          vim.api.nvim_buf_delete(b, { force = true })
        end
      end
    end

    before_each(function()
      vim.cmd('silent! only')
      kill_terminals()
      vim.o.titlestring = ''
    end)
    after_each(kill_terminals)

    describe("is_claude_terminal", function()
      it("matches a claude command", function()
        assert.is_true(T.is_claude_terminal("term://~/.claude//123:claude"))
        assert.is_true(T.is_claude_terminal("term:///Users/x//9:claude --resume"))
      end)

      it("does not match a plain shell even when the cwd contains 'claude'", function()
        assert.is_false(T.is_claude_terminal("term://~/.claude//123:/bin/zsh"))
        assert.is_false(T.is_claude_terminal("term:///Users/x/.claude//9:sh -c 'printf x'"))
      end)
    end)

    it("pins titlestring to a Claude terminal's OSC title", function()
      run_term(claude_cmd('CLAUDE SESSION'))
      vim.wait(4000, function() return vim.o.titlestring == 'CLAUDE SESSION' end)
      assert.equals('CLAUDE SESSION', vim.o.titlestring)
    end)

    it("ignores OSC titles from non-Claude terminals", function()
      vim.o.titlestring = 'CLAUDE SESSION'   -- as if Claude had already pinned it
      run_term(plain_cmd('cwd-basename'))
      vim.wait(1500, function() return vim.o.titlestring ~= 'CLAUDE SESSION' end)
      assert.equals('CLAUDE SESSION', vim.o.titlestring)
    end)

    it("keeps the pinned Claude title when focus moves to a normal buffer", function()
      run_term(claude_cmd('CLAUDE SESSION'))
      vim.wait(4000, function() return vim.o.titlestring == 'CLAUDE SESSION' end)
      vim.cmd('wincmd w')
      assert.not_equals('terminal', vim.bo.buftype)
      assert.equals('CLAUDE SESSION', vim.o.titlestring)
    end)

    it("escapes '%' so it is not read as a statusline item", function()
      run_term(claude_cmd('50\\045 done'))
      vim.wait(4000, function() return vim.o.titlestring ~= '' end)
      assert.equals('50%% done', vim.o.titlestring)
    end)

    it("resets when the Claude terminal closes even if a plain shell remains", function()
      run_term(plain_cmd('shell'))                     -- plain shell stays open
      local claude = run_term(claude_cmd('CLAUDE SESSION'))
      vim.wait(4000, function() return vim.o.titlestring == 'CLAUDE SESSION' end)
      vim.api.nvim_buf_delete(claude, { force = true })
      vim.wait(4000, function() return not vim.api.nvim_buf_is_valid(claude) end)
      assert.equals('', vim.o.titlestring)
    end)
  end)
end)
