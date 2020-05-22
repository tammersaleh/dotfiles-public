setlocal formatoptions-=ta
setlocal commentstring=#%s
setlocal define=^\s*\\(def\\\\|class\\)

" In addition to being dumb, these override my foldtext.
let b:SimpylFold_fold_docstring = 0
let b:SimpylFold_fold_import = 0
let g:SimpylFold_docstring_preview = 0
