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
        heading = {
            sign = false,
            position = 'inline',
            backgrounds = {
                'Normal',
                'Normal',
                'Normal',
                'Normal',
                'Normal',
                'Normal',
            },
            foregrounds = {
                'RenderMarkdownH1',
                'RenderMarkdownH2',
                'RenderMarkdownH3',
                'RenderMarkdownH4',
                'RenderMarkdownH5',
                'RenderMarkdownH6',
            },
        },
        -- indent = { enabled = true },
        latex = { enabled = false },
        pipe_table = { style = 'normal' },
    },
}
