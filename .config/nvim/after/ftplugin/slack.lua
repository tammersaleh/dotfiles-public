-- Slack mrkdwn configuration
-- Reuse markdown ftplugin for shared behavior (bullets, spell, wrap)

dofile(vim.fn.stdpath('config') .. '/after/ftplugin/markdown.lua')

-- Override markdown-specific settings
vim.keymap.del('n', '<leader>o', { buffer = true })
vim.keymap.del('n', '<leader>m', { buffer = true })
vim.keymap.del('v', '<Leader>\\', { buffer = true })

-- No folding (mrkdwn has no headers)
vim.opt_local.foldmethod = 'manual'
vim.opt_local.foldenable = false

-- Standard indent (not markdown's 4-space)
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
