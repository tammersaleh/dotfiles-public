nnoremap <buffer> <leader>o :!mark "%"<enter><enter>

vmap <buffer> - :s/^/- /<enter>:noh<enter>
vmap <buffer> * :s/^/* /<enter>:noh<enter>
vmap <buffer> # :s/^/1. /<enter>:noh<enter>

" Quick links
vmap <buffer> <leader>l    s[%a(<C-R>*)<ESC>
nmap <buffer> <leader>l viWs[%a(<C-R>*)<ESC>

" Align GitHub-Flavored Markdown tables with Space-|
" https://www.statusok.com/align-markdown-tables-vim
vmap <buffer> <Leader><Bslash> :EasyAlign*<Bar><Enter>

" Use K on top of a word to look it up in Dictionary.app
noremap <buffer> <silent> K :silent !open dict://<cword><CR><CR>
noremap <buffer> <silent> <leader>m :silent! !mark %<CR>:redraw!<CR>

" vim-markdown's folding is too agressive (happens in after)
" and breaks my markdownslides format.  We disable folding in vimrc, and
" enable it here more simply:
setlocal foldexpr=Foldexpr_markdown(v:lnum)
setlocal foldmethod=expr

let b:surround_42 = "**\r**"

setlocal conceallevel=0
setlocal tabstop=4
setlocal shiftwidth=4
setlocal linebreak
setlocal foldenable
setlocal spell

let g:vim_markdown_override_foldtext = 0
let g:vim_markdown_folding_style_pythonic = 1
let g:vim_markdown_folding_level = 6
let g:vim_markdown_yaml_frontmatter = 1
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_new_list_item_indent = 0
" let b:coc_suggest_disable = 1
let g:vim_markdown_fenced_languages = ['c++=cpp', 'viml=vim', 'bash=sh', 'ini=dosini', 'hcl=terraform', 'bash=sh', 'console=sh']

