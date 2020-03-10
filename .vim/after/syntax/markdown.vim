" https://kramdown.gettalong.org/syntax.html#inline-attribute-lists
syn match kramdownIAL /{:.*}/ containedin=ALL
set sw=2 ts=2

" function! s:OpenToc()
"   if &filetype ==# 'markdown'
"     :silent Toc 
"     if &filetype ==# 'qf'
"       " If the Toc successfully opened, switch back to the markdown window
"       :wincmd p
"     endif
"   endif
" endfunction
"
" call s:OpenToc()

