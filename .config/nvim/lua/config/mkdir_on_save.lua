-- Automatically create parent directories when saving a file

local mkdir_group = vim.api.nvim_create_augroup('mkdir_on_save', { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(event)
    -- Don't do this for URLs
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
  group = mkdir_group
})
