let g:pymode_python = 'python3'
let g:pymode_syntax_all = 1
" let g:pymode_folding = 0 " I guess zero /enables/ folding??
let g:pymode_rope = 0 " Too much

let g:pymode_options = 0
setlocal formatoptions-=ta
setlocal commentstring=#%s
setlocal define=^\s*\\(def\\\\|class\\)

let g:pymode_lint = 0 " We use ALE
let b:ale_fix_on_save = 1
let g:ale_fixers.python = [
      \ 'isort', 
      \ 'autopep8', 
      \ 'yapf', 
      \ 'remove_trailing_lines', 
      \ 'trim_whitespace',
      \ ]

