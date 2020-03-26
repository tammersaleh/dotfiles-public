setlocal keywordprg=:help
setlocal foldmethod=marker

if has_key(g:AutoPairs, '"')
  let b:AutoPairs = copy(g:AutoPairs)
  call remove(b:AutoPairs, '"')
endif
