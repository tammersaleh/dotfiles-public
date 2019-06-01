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

let b:AutoPairs = {'(':')', '{':'}',"'":"'",'"':'"', '`':'`'} " [] screws with GFM checkboxes
let b:AutoPairs = AutoPairsDefine({'```' : '```'}) " Add triple backticks

ALEDisableBuffer
let b:ale_fix_on_save = 1
let b:ale_fixers = ['remove_trailing_lines', 'trim_whitespace']

function s:Toc()
  :Toc
  :wincmd p
endfunction

augroup markdown
  autocmd!
  autocmd BufWritePost *.md :call s:Toc()
augroup END
