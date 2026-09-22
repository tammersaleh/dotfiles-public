-- Neo-tree source: recently opened files, newest first, basename only.
-- Data comes from config.recent_files. Loaded by neo-tree via
-- `sources = { "neotree_recent" }`; the tab is named "recent".

local renderer = require("neo-tree.ui.renderer")
local manager = require("neo-tree.sources.manager")
local events = require("neo-tree.events")
local utils = require("neo-tree.utils")
local git = require("neo-tree.git")
local recent = require("config.recent_files")

local M = {
  name = "recent",
  display_name = " 󰋚 Recent ",
}

M.components = require("neo-tree.sources.common.components")
M.commands = require("neotree_recent.commands")

local function get_state()
  return manager.get_state(M.name)
end

local function build_items()
  local items = {}
  for _, path in ipairs(recent.list()) do
    local _, name = utils.split_path(path)
    table.insert(items, {
      id = path,
      name = name,
      path = path,
      type = "file",
      ext = name:match("%.([^.]+)$"),
      loaded = true,
      extra = {},
    })
  end
  return items
end

---@param state neotree.State
M.navigate = function(state, path, path_to_reveal, callback)
  state.dirty = false
  state.path = path or state.path or vim.fn.getcwd()
  if path_to_reveal then
    renderer.position.set(state, path_to_reveal)
  end
  renderer.show_nodes(build_items(), state)
  if type(callback) == "function" then
    vim.schedule(callback)
  end
end

local function refresh_visible()
  for _, tabid in ipairs(vim.api.nvim_list_tabpages()) do
    local state = manager.get_state(M.name, tabid)
    if renderer.window_exists(state) then
      M.navigate(state)
    end
  end
end

M.refresh = function()
  utils.debounce("neotree_recent_refresh", refresh_visible, 100, utils.debounce_strategy.CALL_LAST_ONLY)
end

-- Neo-tree calls this on first use of the source, so BufEnter tracking is
-- started by lua/plugins/neo-tree.lua instead, not here.
M.setup = function(config, global_config)
  if global_config.enable_git_status then
    manager.subscribe(M.name, {
      event = events.BEFORE_RENDER,
      handler = function(state)
        if state == get_state() then
          git.status(state.path, state.git_base_by_worktree)
        end
      end,
    })
  end

  manager.subscribe(M.name, {
    event = events.VIM_BUFFER_ENTER,
    handler = function()
      if vim.bo.filetype ~= "neo-tree" then
        M.refresh()
      end
    end,
  })
end

return M
