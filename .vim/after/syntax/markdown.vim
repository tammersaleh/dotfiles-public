" https://kramdown.gettalong.org/syntax.html#inline-attribute-lists
syn match kramdownIAL /{:.*}/ containedin=ALL

function! s:OpenToc()
  if &filetype ==# 'markdown'
    :silent Toc 
    if &filetype ==# 'qf'
      " If the Toc successfully opened, switch back to the markdown window
      :wincmd p
    endif
  endif
endfunction

call s:OpenToc()

