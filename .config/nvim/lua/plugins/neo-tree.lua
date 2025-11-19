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
        return vim.iter({"filesystem", "buffers", "git_status", "document_symbols"})
          :any(function(s) return renderer.window_exists(manager.get_state(s)) end)
      end

      vim.keymap.set("n", "-", function() vim.cmd.Neotree("toggle", "reveal") end)

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

      require("neo-tree").setup({
        -- log_level = "trace", -- TODO: remove these
        -- log_to_file = true,  -- TODO: remove these
        event_handlers = {
          -- Replace cursor with full line highlight
          {
            event = "neo_tree_buffer_enter",
            handler = function()
              local hl = vim.api.nvim_get_hl(0, { name = 'Cursor' })
              hl.blend = 100
              vim.api.nvim_set_hl(0, 'Cursor', hl)
              vim.opt.guicursor:append('a:Cursor/lCursor')
            end
          },
          {
            event = "neo_tree_buffer_leave",
            handler = function()
              local hl = vim.api.nvim_get_hl(0, { name = 'Cursor' })
              hl.blend = 0
              vim.api.nvim_set_hl(0, 'Cursor', hl)
              vim.opt.guicursor:remove('a:Cursor/lCursor')
            end
          },
          -- rebalance windows on open/close
          {
            event = "neo_tree_window_after_open",
            handler = function()
              vim.cmd.wincmd('=')
            end
          },
          {
            event = "neo_tree_window_after_close",
            handler = function()
              vim.cmd.wincmd('=')
            end
          },
        },
        -- use_default_mappings = false,
        sources = {
          "filesystem",
          "buffers",
          "git_status",
          "document_symbols",
        },
        close_if_last_window = true,
        source_selector = { winbar = true, },
        window = {
          position = "left",
          width = 35,
          mapping_options = {
            noremap = true,
            nowait = true,
          },
          mappings = {
            ["<cr>"] = "open_with_window_picker",

            -- https://github.com/nvim-neo-tree/neo-tree.nvim/discussions/163#discussioncomment-4747082
            -- https://github.com/nvim-neo-tree/neo-tree.nvim/discussions/163#discussioncomment-7663286
            -- Jump up to parent directory on file or closed directory, or close on open directory
            ['h'] = function(state)
              local node = state.tree:get_node()
              if (node.type == 'directory' or node:has_children()) and node:is_expanded() then
                state.commands.toggle_node(state)
              else
                renderer.focus_node(state, node:get_parent_id())
              end
            end,

            -- Open on file or closed directory, or jump down to top subdirectory on open directory
            ['l'] = function(state)
              local node = state.tree:get_node()
              if node.type == 'directory' or node:has_children() then
                if not node:is_expanded() then
                  state.commands.toggle_node(state)
                else
                  renderer.focus_node(state, node:get_child_ids()[1])
                end
              else
                -- open the file
                -- require('neo-tree.sources.filesystem.commands').open(state)
              end
            end,

            ['<S-Tab>'] = 'prev_source',
            ['<Tab>'] = 'next_source',
            ['1'] = function() vim.cmd.Neotree('filesystem') end,
            ['2'] = function() vim.cmd.Neotree('buffers') end,
            ['3'] = function() vim.cmd.Neotree('git_status') end,
            ["r"] = function() vim.cmd.Neotree('filesystem', 'show', 'reveal') end,
            ["dd"] = "delete",
            ["R"] = "rename",
            ["a"] = { "add", config = { show_path = "relative" } },
            ["s"] = "open_split",
            ["v"] = "open_vsplit",
            ["?"] = "show_help",
            ["<esc>"] = "cancel",
            ["<space>"] = {
              "toggle_preview",
              config = {
                use_float = true,
                use_snacks_image = true,
                use_image_nvim = true,
              }, nowait = true,
            },
          },
        },
        git_status = {
          window = {
            mappings = {
              ["u"] = "git_unstage_file",
              ["a"] = "git_add_file",
            },
          },
        },
        filesystem = {
          use_libuv_file_watcher = true,
          follow_current_file = {
            enabled = true,
            leave_dirs_open = true,
          },
          window = {
            mappings = {
              ["/"] = "fuzzy_finder",
              ["<esc>"] = "clear_filter",
            },
            fuzzy_finder_mappings = {
              ["<down>"] = "move_cursor_down",
              ["<up>"] = "move_cursor_up",
            },
          },
        },
        default_component_configs = {
          symlink_target = {
            enabled = true,
          },
        }
      }
      )
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
            -- buftype = { "terminal", "quickfix" },
            buftype = { "quickfix" },
          },
        },
      })
    end,
  },
}
