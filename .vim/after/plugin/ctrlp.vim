let g:ctrlp_open_new_file = 'e'
let g:ctrlp_open_multiple_files = 'e'
let g:ctrlp_map = '<Leader>f'
let g:ctrlp_working_path_mode = 'a'
if executable('ag')
  let g:ctrlp_user_command = 'gtimeout 2s ag %s -l --nocolor -g ""'
  let g:ctrlp_use_caching = 0
endif
