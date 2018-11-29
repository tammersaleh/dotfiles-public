" Close Toc after enter
" https://github.com/plasticboy/vim-markdown/issues/145
nnoremap <buffer> <expr><enter> &ft=="qf" ? "<cr>:lcl<cr>" : (getpos(".")[2]==1 ? "i<cr><esc>": "i<cr><esc>l")
nnoremap <buffer> <leader>t :Toc<enter>
nnoremap <buffer> <leader>o :!mark "%"<enter><enter>

vmap <buffer> * :s/^/* /<enter>:noh<enter>
vmap <buffer> # :s/^/1. /<enter>:noh<enter>

" Quick links
vmap <buffer> <leader>l    s[%a(<C-R>*)<ESC>
nmap <buffer> <leader>l viWs[%a(<C-R>*)<ESC>

" Align GitHub-Flavored Markdown tables with Space-|
" https://www.statusok.com/align-markdown-tables-vim
vmap <Leader><Bslash> :EasyAlign*<Bar><Enter>

" Use K on top of a word to look it up in Dictionary.app
noremap <buffer> <silent> K :silent !open dict://<cword><CR><CR>
noremap <buffer> <silent> <leader>m :silent !mark %<CR><CR>

let g:vim_markdown_override_foldtext = 0
let g:vim_markdown_yaml_frontmatter = 1
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_fenced_languages = ['bash=sh', 'console=sh']

let b:surround_42 = "**\r**"

setlocal conceallevel=0
setlocal tabstop=4
setlocal shiftwidth=4
setlocal linebreak
setlocal foldenable
setlocal spell
let b:AutoPairs = {'(':')', '{':'}',"'":"'",'"':'"', '`':'`'} " [] screws with GFM checkboxes
ALEDisableBuffer

let b:ale_fix_on_save = 1
let b:ale_fixers = ['remove_trailing_lines', 'trim_whitespace']

