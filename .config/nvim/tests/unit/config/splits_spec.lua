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

  describe(":SplitOrFocus", function()
    local file = vim.fn.resolve(vim.fn.tempname()) .. ' with space.txt'

    before_each(function()
      vim.cmd('enew | silent! only')
    end)

    it("splits when the file isn't in a window", function()
      local start = vim.api.nvim_get_current_win()
      vim.cmd.SplitOrFocus(file)
      assert.equals(2, #vim.api.nvim_list_wins())
      assert.are_not.equal(start, vim.api.nvim_get_current_win())
      assert.equals(file, vim.api.nvim_buf_get_name(0))
    end)

    it("focuses the existing window instead of splitting again", function()
      vim.cmd.SplitOrFocus(file)
      local target = vim.api.nvim_get_current_win()
      vim.cmd.wincmd('p')
      vim.cmd.SplitOrFocus(file)
      assert.equals(2, #vim.api.nvim_list_wins())
      assert.equals(target, vim.api.nvim_get_current_win())
    end)
  end)

  describe("VimResized autocmd", function()
    it("registers the autocmd", function()
      local autocmds = vim.api.nvim_get_autocmds({ group = 'vim_resized' })
      assert.equals(1, #autocmds)
      assert.equals('VimResized', autocmds[1].event)
    end)
  end)
end)
