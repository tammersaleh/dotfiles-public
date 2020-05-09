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

" In addition to being dumb, these override my foldtext.
let b:SimpylFold_fold_docstring = 0
let b:SimpylFold_fold_import = 0
let g:SimpylFold_docstring_preview = 0

" let g:ale_python_auto_pipenv = 1
let b:ale_fix_on_save = 1
let b:ale_fixers = ['isort', 'autopep8', 'black', 'remove_trailing_lines', 'trim_whitespace'] 
" let b:ale_fixers = ['isort', 'black', 'remove_trailing_lines', 'trim_whitespace'] 

nnoremap <buffer> gd :call jedi#goto()<CR>
