let g:pymode_python = 'python3'
let g:pymode_syntax_all = 1
let g:pymode_rope = 0 " Too much
let g:pymode_options = 0
let g:pymode_folding = 0
let g:pymode_lint = 0 " We use ALE

let g:jedi#use_splits_not_buffers = "right"

setlocal formatoptions-=ta
setlocal commentstring=#%s
setlocal define=^\s*\\(def\\\\|class\\)

" let g:ale_python_auto_pipenv = 1
let g:ale_python_flake8_change_directory = 0  " Use the project config files.
let b:ale_fix_on_save = 1
let b:ale_fixers = ['black', 'add_blank_lines_for_python_control_statements']

nnoremap <buffer> gd :call jedi#goto()<CR>
