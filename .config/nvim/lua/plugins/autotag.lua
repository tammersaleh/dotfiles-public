return {
  'windwp/nvim-ts-autotag',
  lazy = false,
  config = function()
    -- autotag aliases markdown to html and maps `>` in insert mode, inserting
    -- it via nvim_buf_set_text. That breaks dot-repeat for `>` (used constantly
    -- for blockquotes), so disable autotag entirely in markdown. Tradeoff: no
    -- HTML tag auto-close/rename inside markdown files.
    require('nvim-ts-autotag').setup({
      per_filetype = {
        markdown = {
          enable_close = false,
          enable_close_on_slash = false,
          enable_rename = false,
        },
      },
    })
  end,
}
