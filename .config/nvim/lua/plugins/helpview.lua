-- Pretty :help
-- https://github.com/OXY2DEV/helpview.nvim

return {
  "OXY2DEV/helpview.nvim",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter"
  },
  opts = {
    vimdoc = {
      arguments = {
        default = {
          enabled = false
        }
      }
    }
  }
}
