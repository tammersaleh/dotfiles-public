return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    input = { enabled = true },
    picker = { enabled = true }, -- people say this using the ivy layout is a good telescope replacement
    animate = { enabled = true },
    -- bigfile = { enabled = true },
    indent = {
      enabled = true,
      only_scope = true, -- only show indent guides of the scope
      only_current = true, -- only show indent guides in the current window
      scope = {
        enabled = false,
        only_current = true,
        char = "│",
      },
      chunk = {
        enabled = true,
        only_current = true,
        char = {
          horizontal = "─",
          corner_top = "╭",
          vertical = "│",
          corner_bottom = "╰",
          arrow = "─",
          -- horizontal = "═",
          -- corner_top = "╒",
          -- vertical = "│",
          -- corner_bottom = "╘",
          -- arrow = "═",
        },
      },
      animate = {
        style = "out",
        easing = "outExpo",
        duration = {
          step = 20, -- ms per step
          total = 500, -- maximum duration
        },
      },
    },
    -- notifier = { enabled = true },
    -- quickfile = { enabled = true },
    -- scope = { enabled = true },
    scroll = {
      enabled = true,
      animate = {
        duration = { step = 10, total = 200 },
        easing = "linear",
      },
      -- faster animation when repeating scroll after delay
      animate_repeat = {
        delay = 100, -- delay in ms before using the repeat animation
        duration = { step = 5, total = 50 },
        easing = "linear",
      },
      -- what buffers to animate
      -- filter = function(buf)
      --   return vim.g.snacks_scroll ~= false and vim.b[buf].snacks_scroll ~= false and vim.bo[buf].buftype ~= "terminal"
      -- end,
    },
    gitbrowse = {
      enabled = false,
      open = function(url) require("lazy.util").open(url, { system = true }) end,
      ---@type "repo" | "branch" | "file" | "commit" | "permalink"
      what = "branch",
    }
    -- statuscolumn = { enabled = true },
    -- words = { enabled = true },
  },
  config = function(_, opts)
    require('snacks').setup(opts)
    local function git_browse(cmd_opts)
      local line1, line2

      if cmd_opts.range > 0 then
        line1 = cmd_opts.line1
        line2 = cmd_opts.line2
      end

      if cmd_opts.bang then
        local url = require('snacks').gitbrowse.get_url({line1 = line1, line2 = line2})
        if url then
          vim.fn.setreg('+', url)
          print("Copied to clipboard: " .. url)
        end
      else
        require('snacks').gitbrowse({
          line1 = line1,
          line2 = line2,
        })
      end
    end

    vim.api.nvim_create_user_command('GBrowse', git_browse, {
      bang = true,
      range = true,
      desc = "Git browse (or copy URL with !)"
    })

    vim.api.nvim_create_user_command('Gbrowse', git_browse, {
      bang = true,
      range = true,
      desc = "Git browse (or copy URL with !)"
    })
  end,
}
