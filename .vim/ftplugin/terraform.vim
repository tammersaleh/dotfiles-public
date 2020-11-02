setlocal foldmethod=marker
setlocal foldmarker={,}
setlocal commentstring=#%s

let b:ale_fix_on_save = 1
let b:ale_fixers = [
      \ 'remove_trailing_lines',
      \ 'trim_whitespace',
      \ ]

