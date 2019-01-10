if exists('b:current_syntax')
  finish
endif

runtime! syntax/markdown.vim
unlet b:current_syntax

syntax match slideDelim '^===.*$' containedin=ALL
hi def link slideDelim Comment

let b:current_syntax = 'markdownslides'

