local h = require('helpers')

require('config.splits')

describe("splits", function()
  describe("options", function()
    it("splits below", function()
      assert.is_true(vim.o.splitbelow)
    end)

    it("splits right", function()
      assert.is_true(vim.o.splitright)
    end)

    it("equalizes splits", function()
      assert.is_true(vim.o.equalalways)
    end)
  end)

  describe("window navigation keymaps", function()
    it("maps C-h to move left", function() h.assert_keymap('n', '<C-H>') end)
    it("maps C-j to move down", function() h.assert_keymap('n', '<C-J>') end)
    it("maps C-k to move up", function() h.assert_keymap('n', '<C-K>') end)
    it("maps C-l to move right", function() h.assert_keymap('n', '<C-L>') end)
  end)

  describe("VimResized autocmd", function()
    it("registers the autocmd", function()
      local autocmds = vim.api.nvim_get_autocmds({ group = 'vim_resized' })
      assert.equals(1, #autocmds)
      assert.equals('VimResized', autocmds[1].event)
    end)
  end)
end)
