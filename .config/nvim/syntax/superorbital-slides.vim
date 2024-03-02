if exists('b:current_syntax')
  finish
endif

runtime! syntax/markdown.vim
unlet b:current_syntax

syntax match slideDelim '^===.*$' containedin=ALL
syntax match slideStructure '^%col.*$' containedin=ALL
syntax match slideStructure '^%notes' containedin=ALL
hi def link slideDelim Comment
hi def link slideStructure Comment

let b:current_syntax = 'markdownslides'

