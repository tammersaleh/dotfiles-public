" Close Toc after enter
" https://github.com/plasticboy/vim-markdown/issues/145
nnoremap <buffer> <expr><enter> &ft=="qf" ? "<cr>:lcl<cr>" : (getpos(".")[2]==1 ? "i<cr><esc>": "i<cr><esc>l")

nnoremap <buffer> <leader>t :Toc<enter>

nnoremap <buffer> <leader>o :!mark %<enter><enter>

vmap <buffer> * :s/^/* /<enter>:noh<enter>
vmap <buffer> # :s/^/1. /<enter>:noh<enter>

" Quick links
vmap <buffer> <leader>l    s[%a(<C-R>*)<ESC>
nmap <buffer> <leader>l viWs[%a(<C-R>*)<ESC>

" Align GitHub-Flavored Markdown tables with Space-|
" https://www.statusok.com/align-markdown-tables-vim
vmap <Leader><Bslash> :EasyAlign*<Bar><Enter>

