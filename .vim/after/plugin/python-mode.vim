let g:pymode_python = 'python3'
let g:pymode_syntax_all = 1
let g:pymode_folding = 0
let g:pymode_lint_on_write = 0
let g:pymode_rope_regenerate_on_write = 0

let b:ale_fix_on_save = 1

" Try the following fixers appropriate for the filetype:
"
" 'add_blank_lines_for_python_control_statements' - Add blank lines before control statements.
" 'autopep8' - Fix PEP8 issues with autopep8.
" 'isort' - Sort Python imports with isort.
" 'yapf' - Fix Python files with yapf.
"
" Try the following generic fixers:
"
" 'remove_trailing_lines' - Remove all blank lines at the end of a file.
" 'trim_whitespace' - Remove all trailing whitespace characters at the end of every line.
"
" See :help ale-fix-configuration

let g:ale_fixers.python = [
      \ 'isort', 
      \ 'autopep8', 
      \ 'yapf', 
      \ 'remove_trailing_lines', 
      \ 'trim_whitespace',
      \ ]

