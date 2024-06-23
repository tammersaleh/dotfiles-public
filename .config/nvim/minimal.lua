vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  opts = {
    move_cursor = false,
    surrounds = {
      ["~"] = { -- Markdown fenced code blocks
        add = function()
          local config = require("nvim-surround.config")
          local result = config.get_input("Markdown code block language: ")
          return {
            { "```" .. result, '' },
            { "", "```" },
          }
        end,
      },
    },
  },
})


