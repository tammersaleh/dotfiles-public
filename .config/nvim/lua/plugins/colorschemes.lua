local config = function()
  vim.cmd.colorscheme("everforest")
  -- vim.cmd.colorscheme("default")

  vim.api.nvim_set_hl(0, 'Comment', { fg = 'white', bold = true })
  vim.api.nvim_set_hl(0, 'String', { fg = 'white' })
  vim.api.nvim_set_hl(0, 'CursorLine', { bg = 'black' })
  vim.api.nvim_set_hl(0, 'Visual', { bg = '#3a3a0a' })

  -- Set terminal background to black
  vim.api.nvim_set_hl(0, 'Terminal', { bg = '#000000', fg = '#d3c6aa' })

  -- Override terminal background when opening :terminal
  vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
      vim.wo.winhighlight = 'Normal:Terminal'
    end,
  })
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
    config = function(_, opts)
      require("everforest").setup(opts)

      -- Override terminal ANSI colors after everforest loads
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "everforest",
        callback = function()
          -- Set standard ANSI terminal colors
          vim.g.terminal_color_0  = '#000000'  -- Black
          vim.g.terminal_color_1  = '#cd0000'  -- Red
          vim.g.terminal_color_2  = '#00cd00'  -- Green
          vim.g.terminal_color_3  = '#cdcd00'  -- Yellow
          vim.g.terminal_color_4  = '#0000ee'  -- Blue
          vim.g.terminal_color_5  = '#cd00cd'  -- Magenta
          vim.g.terminal_color_6  = '#00cdcd'  -- Cyan
          vim.g.terminal_color_7  = '#e5e5e5'  -- White
          vim.g.terminal_color_8  = '#7f7f7f'  -- Bright Black (Gray)
          vim.g.terminal_color_9  = '#ff0000'  -- Bright Red
          vim.g.terminal_color_10 = '#00ff00'  -- Bright Green
          vim.g.terminal_color_11 = '#ffff00'  -- Bright Yellow
          vim.g.terminal_color_12 = '#5c5cff'  -- Bright Blue
          vim.g.terminal_color_13 = '#ff00ff'  -- Bright Magenta
          vim.g.terminal_color_14 = '#00ffff'  -- Bright Cyan
          vim.g.terminal_color_15 = '#ffffff'  -- Bright White
        end,
      })
    end,
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
