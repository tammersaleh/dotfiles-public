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
    it("maps C-h to move left", function()
      local maps = vim.api.nvim_get_keymap('n')
      local found = false
      for _, map in ipairs(maps) do
        if map.lhs == '<C-H>' then
          found = true
          break
        end
      end
      assert.is_true(found, "C-h mapping not found")
    end)

    it("maps C-j to move down", function()
      local maps = vim.api.nvim_get_keymap('n')
      local found = false
      for _, map in ipairs(maps) do
        if map.lhs == '<C-J>' then
          found = true
          break
        end
      end
      assert.is_true(found, "C-j mapping not found")
    end)

    it("maps C-k to move up", function()
      local maps = vim.api.nvim_get_keymap('n')
      local found = false
      for _, map in ipairs(maps) do
        if map.lhs == '<C-K>' then
          found = true
          break
        end
      end
      assert.is_true(found, "C-k mapping not found")
    end)

    it("maps C-l to move right", function()
      local maps = vim.api.nvim_get_keymap('n')
      local found = false
      for _, map in ipairs(maps) do
        if map.lhs == '<C-L>' then
          found = true
          break
        end
      end
      assert.is_true(found, "C-l mapping not found")
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
