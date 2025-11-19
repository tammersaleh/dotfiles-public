local config = function()
  vim.cmd.colorscheme("everforest")
  -- vim.cmd.colorscheme("default")
  -- vim.api.nvim_set_hl(0, 'Terminal',    { bg = 'black' }) -- Example dark background
  -- vim.api.nvim_set_hl(0, 'TerminalWin', { bg = 'black' }) -- Also for the terminal window itself
  vim.api.nvim_set_hl(0, 'Comment', { fg = 'white', bold = true })
  -- vim.api.nvim_set_hl(0, 'TSString', { fg = 'white' })
  vim.api.nvim_set_hl(0, 'String', { fg = 'white' })
end

return {
  {
    "neanias/everforest-nvim",
    main = "everforest",
    version = false,
    lazy = false,
    priority = 1000,
    opts = {
      background = "hard", -- "soft", "medium", "hard"
      italics = true,
      dim_inactive_windows = true,
      show_eob = false,
      -- on_highlights = function(hl, palette)
      --   hl.Comment = { fg = palette.yellow, bg = palette.none, italic = true }
      --   hl.String = { fg = palette.white, bg = palette.none, italic = true }
      -- end,
      -- colours_override = function (palette)
      --   palette.white = "#000000"
      -- end
    },
  },
  -- Add a dummy plugin to set the colorscheme after all are loaded
  {
    "set-colorscheme",
    lazy = false,
    priority = 999, -- Lower priority than colorscheme plugins
    dir = vim.fn.stdpath("config"), -- Point to a valid directory
    config = config,
  },
}
