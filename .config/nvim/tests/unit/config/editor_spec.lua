local h = require('helpers')

require('config.editor')

describe("editor", function()
  it("enables mouse", function()
    assert.equals('a', vim.o.mouse)
  end)

  it("syncs clipboard with OS", function()
    assert.equals('unnamedplus', vim.o.clipboard)
  end)

  it("enables break indent", function()
    assert.is_true(vim.o.breakindent)
  end)

  it("sets showbreak character", function()
    assert.equals('↳  ', vim.o.showbreak)
  end)

  it("disables double space after punctuation on join", function()
    assert.is_false(vim.o.joinspaces)
  end)

  it("enables persistent undo", function()
    assert.is_true(vim.o.undofile)
  end)

  it("auto-writes all buffers on focus loss", function()
    assert.is_true(vim.o.autowriteall)
  end)

  it("does not hide abandoned buffers", function()
    assert.is_false(vim.o.hidden)
  end)

  it("disables netrw", function()
    assert.equals(1, vim.g.loaded_netrw)
    assert.equals(1, vim.g.loaded_netrwPlugin)
  end)

  describe("live-reload autocmd", function()
    local function events()
      local set = {}
      for _, ac in ipairs(vim.api.nvim_get_autocmds({ group = 'live_reload' })) do
        set[ac.event] = true
      end
      return set
    end

    it("reloads on focus gain and buffer entry", function()
      local e = events()
      assert.is_true(e.FocusGained)
      assert.is_true(e.BufEnter)
    end)

    it("does not run checktime on cursor idle", function()
      local e = events()
      assert.is_nil(e.CursorHold)
      assert.is_nil(e.CursorHoldI)
    end)
  end)
end)
