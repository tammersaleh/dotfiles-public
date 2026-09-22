local cc = require("neo-tree.sources.common.commands")
local recent = require("config.recent_files")

local M = {}

M.remove_from_recent = function(state)
  local node = state.tree:get_node()
  if node and node.path then
    recent.remove(node.path)
    require("neotree_recent").navigate(state)
  end
end

return vim.tbl_deep_extend("force", cc, M)
