-- Neo-tree options and source registry. Directories outside this config can
-- add a source with add_source(), e.g. from an exrc `.nvim.lua`.

local M = {}

local renderer = require("neo-tree.ui.renderer")

local opts = {
  -- log_level = "trace", -- For debuging
  -- log_to_file = true,  -- For debuging
  event_handlers = {
    -- Replace cursor with full line highlight
    {
      event = "neo_tree_buffer_enter",
      handler = function()
        local hl = vim.api.nvim_get_hl(0, { name = 'Cursor' })
        vim.api.nvim_set_hl(0, 'Cursor', hl)
        vim.opt.guicursor:append('a:Cursor/lCursor')
      end
    },
    {
      event = "neo_tree_buffer_leave",
      handler = function()
        local hl = vim.api.nvim_get_hl(0, { name = 'Cursor' })
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
    "neotree_recent", -- lua/neotree_recent/, source name "recent"
  },
  close_if_last_window = true,
  source_selector = {
    winbar = true,
    show_scrolled_off_parent_node = true,
    sources = {
      {
        source = "filesystem",
        display_name = " 󰉓 Files "
      },
      {
        source = "recent",
        display_name = " 󰋚 Recent "
      },
      {
        source = "git_status",
        display_name = " 󰊢 Git "
      },
      {
        source = "document_symbols",
        display_name = " 󰈚 Syms "
      },
    },
  },
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
        end
      end,

      ['<S-Tab>'] = 'prev_source',
      ['<Tab>'] = 'next_source',
      ['<Left>'] = 'prev_source',
      ['<Right>'] = 'next_source',

      ["r"] = function() vim.cmd.Neotree('filesystem', 'show', 'reveal') end,
      ["dd"] = "delete",
      ["R"] = "rename",
      ["a"] = { "add", config = { show_path = "relative" } },
      ["s"] = "open_split",
      ["f"] = "open_split",
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
  document_symbols = {
    window = {
      mappings = {
        -- No clipboard, add, or delete here; silence the defaults.
        ["<C-r>"] = "noop",
        ["a"] = "noop",
        ["dd"] = "noop",
      },
    },
  },
  recent = {
    window = {
      mappings = {
        ["d"] = "remove_from_recent",
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

-- Source names ("recent"), not module names ("neotree_recent").
local names = { "filesystem", "buffers", "git_status", "document_symbols", "recent" }

-- The window's 1..N keys jump to the selector's tabs, in order.
local function set_number_keys()
  local mappings = opts.window.mappings
  for i = 1, 9 do
    mappings[tostring(i)] = nil
  end
  for i, entry in ipairs(opts.source_selector.sources) do
    if i > 9 then break end
    mappings[tostring(i)] = function() vim.cmd.Neotree(entry.source) end
  end
end

function M.setup()
  set_number_keys()
  require("neo-tree").setup(opts)
end

function M.source_names()
  return vim.list_extend({}, names)
end

---@param module string Lua module implementing a Neo-tree source
---@param spec { display_name: string }
function M.add_source(module, spec)
  if vim.tbl_contains(opts.sources, module) then return end
  local name = require(module).name
  table.insert(opts.sources, module)
  table.insert(opts.source_selector.sources, { source = name, display_name = spec.display_name })
  table.insert(names, name)
  M.setup()
end

return M
