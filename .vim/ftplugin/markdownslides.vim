if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpoptions
set cpoptions&vim

runtime! ftplugin/markdown.vim

setlocal foldmethod=expr 
setlocal foldexpr=getline(v:lnum)=~#'^===\\ssubsection'?'>1':'='

" restore Vi compatibility settings
let &cpoptions = s:cpo_save
unlet s:cpo_save


