setlocal foldmethod=marker
setlocal foldmarker={,}
setlocal commentstring=#%s

let b:ale_fix_on_save = 1
let b:ale_fixers = [
      \ 'remove_trailing_lines', 
      \ 'trim_whitespace',
      \ ]

" Using devdocs.io instead.  Remove eventually.
"" Open the terraform resource under the current line in the online
"" documenation at https://https://www.terraform.io/docs
"function! OpenTerraformDocs()
"  let l:words = filter(split(getline("."), '[" {]'), 'v:val != ""')
"
"  let l:type = words[0]
"  if (index(['resource', 'data'], l:type) < 0)
"    echom "K only works on a resource or data definition line."
"    return
"  endif
"  let l:type_first_letter = split(l:type, '\zs')[0]
"
"  let l:provider_and_resource = words[1]
"  let l:provider_and_resource_pieces = split(l:provider_and_resource, '_')
"
"  let l:provider = l:provider_and_resource_pieces[0]
"  let l:resource = join(l:provider_and_resource_pieces[1:-1], '_')
"
"  if (l:provider == 'google')
"    let l:resource = 'google_' . l:resource
"  endif
"
"  let l:url_pieces = ['https://www.terraform.io/docs/providers', l:provider, l:type_first_letter, l:resource]
"  let l:url = join(l:url_pieces, "/") . '.html'
"
"  " echom l:url
"  silent execute "!open " . l:url
"endfunction
"
"nnoremap <buffer> <silent> K :call OpenTerraformDocs()<CR>
