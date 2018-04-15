setlocal spell

setlocal foldmethod=indent

let b:ale_fix_on_save = 1
let g:ale_fixers.haml = [
      \ 'remove_trailing_lines', 
      \ 'trim_whitespace',
      \ ]
