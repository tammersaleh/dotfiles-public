" Bash, not sh
let g:is_bash=1

let b:ale_fix_on_save = 1

" Try the following fixers appropriate for the filetype:
"
" 'shfmt' - Fix sh files with shfmt.
"
" Try the following generic fixers:
"
" 'remove_trailing_lines' - Remove all blank lines at the end of a file.
" 'trim_whitespace' - Remove all trailing whitespace characters at the end of every line.
"
" See :help ale-fix-configuration

let g:ale_fixers.sh = [
      \ 'shfmt', 
      \ 'remove_trailing_lines', 
      \ 'trim_whitespace',
      \ ]

" -i uint   indent: 0 for tabs (default), >0 for number of spaces
" -bn       binary ops like && and | may start a line
" -ci       switch cases will be indented
" -kp       keep column alignment paddings

let g:ale_sh_shfmt_options = '-i 2 -bn'
