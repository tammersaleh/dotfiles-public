-- Minimal Neo-tree source for tests of config.neotree.add_source.

local renderer = require("neo-tree.ui.renderer")

local M = { name = "fixture", display_name = " Fixture " }

M.components = require("neo-tree.sources.common.components")
M.commands = require("neo-tree.sources.common.commands")

M.navigate = function(state, path, _, callback)
  state.path = path or state.path or vim.fn.getcwd()
  renderer.show_nodes({
    { id = "fixture-item", name = "fixture-item", type = "file", path = "/fixture-item", extra = {} },
  }, state)
  if type(callback) == "function" then
    vim.schedule(callback)
  end
end

M.setup = function() end

return M
