-- Help buffer keymaps
-- Map 'K' or Enter to jump to tag under cursor
-- 'gb' already replaces Ctrl-O for going back up the stack

vim.keymap.set('n', 'K', '<C-]>', {buffer = true, noremap = true, silent = true, desc = "Jump to tag"})
vim.keymap.set('n', '<Enter>', '<C-]>', {buffer = true, noremap = true, silent = true, desc = "Jump to tag"})
