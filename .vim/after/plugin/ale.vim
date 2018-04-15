" let g:airline#extensions#ale#enabled = 1
" let g:ale_echo_msg_error_str = 'E'
" let g:ale_echo_msg_warning_str = 'W'
" let g:ale_linters_explicit = 1
" let g:ale_lint_on_text_changed = 'never'
" let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
" let g:ale_open_list = 1
" let g:ale_set_balloons = 1
let g:ale_sign_error = '⚠️'
let g:ale_sign_warning = '❓'
highlight clear ALEErrorSign
highlight clear ALEWarningSign
let g:ale_sign_column_always = 1
set signcolumn="yes"
augroup LanguageClient_config
  autocmd!
  autocmd User LanguageClientStarted setlocal signcolumn=yes
  autocmd User LanguageClientStopped setlocal signcolumn=yes
augroup END


