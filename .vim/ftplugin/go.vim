nmap <buffer> <Leader>i <Plug>(go-info)
nmap <buffer> <Leader>r <Plug>(go-rename)
setlocal noexpandtab
setlocal nolist
setlocal tabstop=4 shiftwidth=4

let g:go_fmt_fail_silently = 1
let g:go_fmt_command = 'goimports'
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

