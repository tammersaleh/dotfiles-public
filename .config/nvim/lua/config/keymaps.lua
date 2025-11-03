-- General keymaps

-- Disable space in normal/visual mode (it's the leader key)
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Indenting
vim.keymap.set('v', '<Tab>',   '>gv', { silent = true, desc = "Indent selection" })
vim.keymap.set('v', '<S-Tab>', '<gv', { silent = true, desc = "Dedent selection" })
vim.keymap.set('n', '<Tab>',   '>>_', { silent = true, desc = "Indent line" })
vim.keymap.set('n', '<S-Tab>', '<<_', { silent = true, desc = "Dedent line" })

-- Go back in tag stack
vim.keymap.set('n', 'gb', '<C-t>', {silent = true, desc = "[G]o [b]ack in tag stack"})

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Move line up/down
vim.keymap.set('n', '<c-s-down>', ":m .+1<CR>==",        {silent = true})
vim.keymap.set('n', '<c-s-up>',   ":m .-2<CR>==",        {silent = true})
vim.keymap.set('i', '<c-s-down>', "<Esc>:m .+1<CR>==gi", {silent = true})
vim.keymap.set('i', '<c-s-up>',   "<Esc>:m .-2<CR>==gi", {silent = true})
vim.keymap.set('v', '<c-s-down>', ":m '>+1<CR>gv=gv",    {silent = true})
vim.keymap.set('v', '<c-s-up>',   ":m '<-2<CR>gv=gv",    {silent = true})

-- Use semicolon for command mode
vim.keymap.set('n', ';', ':', {silent = true, desc = "Command (replaces :)"})

-- Select last pasted text
vim.keymap.set('n', 'gp', '`[v`]', { noremap = true, silent = true, desc = 'Select last pasted text' })
