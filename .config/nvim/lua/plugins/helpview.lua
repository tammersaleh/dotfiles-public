-- Pretty :help
-- https://github.com/OXY2DEV/helpview.nvim

return {
  "OXY2DEV/helpview.nvim",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    'nvim-tree/nvim-web-devicons',
  },
  opts = {
    preview = {
        icon_provider = "devicons", -- Uses nvim-web-devicons
    },
  }
}
