let g:vim_markdown_folding_disabled = 0
let g:vim_markdown_folding_style_pythonic = 1
let g:vim_markdown_yaml_frontmatter = 1
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_fenced_languages = ['yaml=yaml', 'bash=sh']

let g:surround_42 = "**\r**"

" I can't figure out how to get mmark includes to not render as HTML
" syntax clear htmlTag

setlocal conceallevel=2
setlocal tabstop=4
setlocal shiftwidth=4
setlocal linebreak
setlocal nofoldenable

source ~/.vim/autocorrect.vim

setlocal spell

let b:ale_fix_on_save = 1
let g:ale_fixers.markdown = [
      \ 'remove_trailing_lines', 
      \ 'trim_whitespace',
      \ ]
