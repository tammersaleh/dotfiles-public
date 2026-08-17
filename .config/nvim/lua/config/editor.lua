-- Editing behavior options

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true
vim.o.showbreak = '↳  '

-- Don't add two spaces after punctuation when joining lines
vim.o.joinspaces = false

-- Save undo history
vim.o.undofile = true

-- Save all buffers when focus is lost
vim.o.autowriteall = true

-- Disable abandoned buffers instead of hiding them
vim.o.hidden = false

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Reload buffers when the underlying file changes on disk, including
-- buffers that aren't currently focused. :checktime with no args checks
-- every loaded buffer, so background buffers reload too (not just on BufEnter).
--
-- Only fire on discrete transitions (focus, buffer/terminal switches), never
-- on CursorHold/CursorHoldI: those run every updatetime (250ms) while the
-- cursor rests, so on a markdown buffer they trigger a render-markdown +
-- spell + fold recompute on every typing pause, which makes editing crawl.
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'TermClose', 'TermLeave' }, {
  group = vim.api.nvim_create_augroup('live_reload', { clear = true }),
  pattern = '*',
  callback = function()
    if vim.fn.mode() ~= 'c' and vim.fn.getcmdwintype() == '' then
      vim.cmd('checktime')
    end
  end,
})
