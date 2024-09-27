return {
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
