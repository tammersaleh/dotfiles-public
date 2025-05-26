return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-tree/nvim-web-devicons',
        'tree-sitter-grammars/tree-sitter-markdown',
        'tree-sitter/tree-sitter-html'
    },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
         code = {
            border = 'thin',
            style = 'normal',
            sign = false,
            width = 'block',
            right_pad = 4,
        },
         latex = { enabled = false },
         pipe_table = { style = 'normal' },
    },
}
