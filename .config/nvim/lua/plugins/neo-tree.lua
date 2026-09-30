-- https://www.reddit.com/r/neovim/comments/1cv1sc5/netrw_hijack_behavior_for_neotree/
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local manager = require("neo-tree.sources.manager")
      local renderer = require("neo-tree.ui.renderer")

      local function neotree_is_visible()
        return vim.iter(require("config.neotree").source_names())
          :any(function(s) return renderer.window_exists(manager.get_state(s)) end)
      end

      -- Toggle remembers the mode and buffer it was opened from so closing it
      -- from insert or terminal mode drops you back into that mode.
      local opened_from = nil
      local function toggle_neotree()
        if neotree_is_visible() then
          vim.cmd.Neotree("close")
          if opened_from
            and opened_from.buf == vim.api.nvim_get_current_buf()
            and (opened_from.mode == "i" or opened_from.mode == "t") then
            vim.cmd.startinsert()
          end
          opened_from = nil
        else
          opened_from = {
            buf = vim.api.nvim_get_current_buf(),
            mode = vim.api.nvim_get_mode().mode:sub(1, 1),
          }
          vim.cmd.Neotree("reveal")
        end
      end
      vim.keymap.set("n", "-", toggle_neotree, { desc = "Toggle Neo-tree" })
      -- ctrl-dash from insert or terminal mode. Kitty-protocol terminals
      -- (Ghostty) send <C-->; legacy terminals send 0x1F, which nvim calls <C-_>.
      for _, key in ipairs({ "<C-->", "<C-_>" }) do
        vim.keymap.set({ "n", "i", "t" }, key, toggle_neotree, { desc = "Toggle Neo-tree" })
      end

      -- Replace CTRL-W K, etc, with mappings that hide and restore Neotree
      for _, direction in ipairs({
        { key = 'K', desc = 'top' },
        { key = 'J', desc = 'bottom' },
        { key = 'H', desc = 'left' },
        { key = 'L', desc = 'right' },
      }) do
        vim.keymap.set('n', '<C-w>' .. direction.key, function()
          local was_visible = neotree_is_visible()
          if was_visible then
            vim.cmd.Neotree('close')
          end

          vim.cmd.wincmd(direction.key)

          if was_visible then
            vim.cmd.Neotree('show', 'last')
          end
        end, { remap = false, silent = true, desc = "Move window to the " .. direction.desc })
      end

      local function open_terminal_split(vertical)
        return function()
          if vertical then
            vim.cmd('vsplit | terminal')
          else
            local was_visible = neotree_is_visible()
            if was_visible then
              vim.cmd.Neotree('close')
            end
            vim.cmd('split | terminal')
            if was_visible then
              vim.cmd.Neotree('show', 'last')
              vim.cmd.wincmd("=")
            end
          end
        end
      end
      vim.keymap.set({'n', 't'}, '<C-Right>', open_terminal_split(true),  {silent = true, desc = "Open terminal in a split to the right"})
      vim.keymap.set({'n', 't'}, '<C-Down>',  open_terminal_split(false), {silent = true, desc = "Open terminal in a split below"})

      -- Start MRU tracking now; neo-tree only sets up a source on first use.
      require("config.recent_files").setup()

      require("config.neotree").setup()
    end
  },
  { "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neo-tree/neo-tree.nvim", -- makes sure that this loads after Neo-tree.
    },
    config = function()
      require("lsp-file-operations").setup()
    end,
  },
  { "s1n7ax/nvim-window-picker",
    version = "2.*",
    config = function()
      require("window-picker").setup({
        hint = 'floating-big-letter',
        filter_rules = {
          include_current_win = false,
          autoselect_one = false,
          -- filter using buffer options
          bo = {
            -- if the file type is one of following, the window will be ignored
            filetype = { "neo-tree", "neo-tree-popup", "notify" },
            -- if the buffer type is one of following, the window will be ignored
            buftype = { "quickfix" },
          },
        },
      })
    end,
  },
}
