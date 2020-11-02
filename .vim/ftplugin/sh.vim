" Bash, not sh
let b:is_bash=1
let g:sh_fold_enabled = 1 " Just functions

let b:ale_fix_on_save = 1
let b:ale_fixers = [
      \ 'shfmt',
      \ 'remove_trailing_lines',
      \ 'trim_whitespace',
      \ ]

" -i uint   indent: 0 for tabs (default), >0 for number of spaces
" -bn       binary ops like && and | may start a line
" -ci       switch cases will be indented
" -kp       keep column alignment paddings
let g:ale_sh_shfmt_options = '-i 2 -bn'
