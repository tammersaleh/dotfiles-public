return {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  config = function(_, opts)
    local surround = require("nvim-surround")
    surround.setup(opts)

    -- Upstream leaves the '< and '> marks where they were before the
    -- delimiters went in, so gv reselects the wrong columns. Track the
    -- selection through the edit with extmarks and move the marks after.
    local ns = vim.api.nvim_create_namespace("config.surround.visual_marks")
    local visual_surround = surround.visual_surround
    surround.visual_surround = function(args)
      local first = vim.api.nvim_buf_get_mark(0, "<")
      local last = vim.api.nvim_buf_get_mark(0, ">")
      local ids = {}
      for _, pos in ipairs({ first, last }) do
        local line = vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], false)[1] or ""
        local col = math.min(pos[2], math.max(#line - 1, 0))
        ids[#ids + 1] = vim.api.nvim_buf_set_extmark(0, ns, pos[1] - 1, col, { right_gravity = true })
      end
      visual_surround(args)
      for i, mark in ipairs({ "<", ">" }) do
        local pos = vim.api.nvim_buf_get_extmark_by_id(0, ns, ids[i], {})
        if pos[1] then
          vim.api.nvim_buf_set_mark(0, mark, pos[1] + 1, pos[2], {})
        end
        vim.api.nvim_buf_del_extmark(0, ns, ids[i])
      end
    end
  end,
  opts = {
    move_cursor = false,
    surrounds = {
      -- Openers pad by default ("( bar )"). Make them match their closers.
      ["("] = { add = { "(", ")" } },
      ["["] = { add = { "[", "]" } },
      ["{"] = { add = { "{", "}" } },
      ["<"] = { add = { "<", ">" } },
      ["~"] = { -- Markdown fenced code blocks
        add = function()
          local config = require("nvim-surround.config")
          local result = config.get_input("Markdown code block language: ")
          return { { "```" .. result }, { "```" } }
        end,
      },
      ["l"] = { -- Markdown links
        add = function()
          local clipboard = vim.fn.getreg("+"):gsub("\n", "")
          local p="^(.*)://"
          local l = string.match(clipboard,p) and clipboard or "URL"
          return {
            { "[" },
            { "](" .. l .. ")" },
          }
        end,
        find = "%b[]%b()",
        delete = "^(%[)().-(%]%b())()$",
        change = {
          target = "^()()%b[]%((.-)()%)$",
          replacement = function()
            local clipboard = vim.fn.getreg("+"):gsub("\n", "")
            local p="^(.*)://"
            local l = string.match(clipboard,p) and clipboard or "URL"
            return {
              { "" },
              { l },
            }
          end,
        },
      },
    },
  },
}
