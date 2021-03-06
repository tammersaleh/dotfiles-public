" Plugins {{{
call plug#begin('~/.vim/plugged')

if has('python3')
  " Force python3 support before loading other plugins
  " https://robertbasic.com/blog/force-python-version-in-vim/
  "
  " Then, silently load python3 to get around imp deprecation warning:
  " https://github.com/vim/vim/issues/3117
  silent! python3 1
endif

" Languages & syntax {{{
Plug 'https://github.com/hashicorp/sentinel.vim'
Plug 'https://github.com/wannesm/wmgraphviz.vim'
Plug 'https://github.com/Matt-Deacalion/vim-systemd-syntax'
Plug 'https://github.com/cakebaker/scss-syntax.vim'
Plug 'https://github.com/cespare/vim-toml'
Plug 'https://github.com/digitaltoad/vim-pug'   " Jade
Plug 'https://github.com/ekalinin/Dockerfile.vim'
Plug 'https://github.com/elzr/vim-json'
Plug 'https://github.com/fatih/vim-go'
Plug 'https://github.com/hail2u/vim-css3-syntax'
Plug 'https://github.com/hashivim/vim-terraform'
Plug 'https://github.com/pangloss/vim-javascript'
Plug 'https://github.com/plasticboy/vim-markdown'
Plug 'https://github.com/python-mode/python-mode', { 'branch': 'develop' }
Plug 'https://github.com/vim-ruby/vim-ruby'
Plug 'https://github.com/vim-scripts/jQuery'
Plug 'https://github.com/tpope/vim-rails'
Plug 'https://github.com/yosssi/vim-ace'
Plug 'https://github.com/tmhedberg/SimpylFold'  " Better python folding
Plug 'https://github.com/szymonmaszke/vimpyter' " edit jupyter notebooks.  cray.
Plug 'https://github.com/tpope/vim-git'
" }}}

" General {{{
Plug 'https://github.com/justinmk/vim-dirvish'          " Betterer netrw
Plug 'https://github.com/kana/vim-smartword'            " make `w` better.
Plug 'https://github.com/airblade/vim-gitgutter'        " Show git signs in gutter
Plug 'https://github.com/jiangmiao/auto-pairs'          " Auto-close parens, etc
Plug 'https://github.com/tpope/vim-endwise'             " Auto-close do/end in ruby
Plug 'https://github.com/RRethy/vim-illuminate'         " Highlight word under cursor after delay
Plug 'https://github.com/junegunn/vim-easy-align'       " <leader>a=
Plug 'https://github.com/machakann/vim-highlightedyank' " briefly highlights the copied text
Plug 'https://github.com/sickill/vim-pasta'             " Pasting in Vim with indentation adjusted to destination context
Plug 'https://github.com/tomtom/tcomment_vim'           " comment/uncomment lines (mapped to # in visual)
Plug 'https://github.com/tpope/vim-eunuch'              " Unix commands :Rename :Delete, etc
Plug 'https://github.com/tpope/vim-fugitive'            " :Gblame is amazingballz
Plug 'https://github.com/tpope/vim-rhubarb'             " github for fugative
Plug 'https://github.com/tpope/vim-repeat'              " enable repeating supported plugin maps with .
Plug 'https://github.com/tpope/vim-surround'            " Should be part of vim core
Plug 'https://github.com/zhimsel/vim-stay'              " Keep cursor pos, etc between sessions
Plug 'https://github.com/embear/vim-localvimrc'         " Open .lvimrc files securely
Plug 'https://github.com/romainl/vim-devdocs'           " Add :DD for devdocs.io
Plug 'https://github.com/itchyny/lightline.vim'         " Simple status line
Plug 'https://github.com/itchyny/vim-gitbranch'         " Used for lightline
Plug 'https://github.com/dbakker/vim-projectroot'       " Used for lightline
Plug 'https://github.com/ervandew/supertab'             " Tab does autocomplete
Plug 'https://github.com/w0rp/ale'                      " Linting and fixing
Plug 'https://github.com/terryma/vim-expand-region'     " +/_ expand/shrink visual selection
Plug 'https://github.com/gfontenot/vim-url-opener'      " Open arbitrary strings as urls
" TODO: nvim
Plug 'https://github.com/TaDaa/vimade'                  " Fade the inactive windows
Plug 'https://github.com/romainl/vim-qf'                " Better quickfix/location windows
" }}}

" Color theme {{{
Plug 'https://github.com/morhetz/gruvbox'
Plug 'https://github.com/rafi/awesome-vim-colorschemes'
" }}}

call plug#end()

command! PU source $MYVIMRC | PlugClean! | PlugUpdate | PlugUpgrade | source $MYVIMRC

" }}}
" Options {{{

set titlestring=%{substitute(getcwd(),\ $HOME,\ '~',\ '')}
set fillchars=vert:\│
set listchars=tab:».,nbsp:_,conceal:×
set list
" set timeoutlen=1000 ttimeoutlen=10 " Fix esc delay
set iskeyword+=-      " This makes foo-bar a single "word" - affects "*" and others
set mouse=a           " Allow mouse positioning and scrolling in terminal.
set clipboard=unnamed " Use the system clipboard
set backup            " keep a backup file
set backupdir=~/.local/share/nvim/backup
set expandtab
set shiftwidth=2
set tabstop=2
set helpheight=1000
" Regenerate the .spl list
silent exec 'mkspell! ~/.vim/en.utf-8.add'
set spellfile=~/.vim/en.utf-8.add

set nospell " Disable by default
set completeopt=menu,menuone,preview
" Hit tab once in : mode, get list.  Hit again to go through list.
set wildmode=longest:full,full
set signcolumn=yes
set virtualedit=block
set switchbuf="useopen"
setlocal numberwidth=3

set scrolloff=1
set sidescrolloff=5

" Nicer splitting
set splitbelow
set splitright

set number

set display=lastline
set nojoinspaces

set breakindent
set breakindentopt=shift:0
let &showbreak='↳  '

" https://stackoverflow.com/questions/16902317/vim-slow-with-ruby-syntax-highlighting
set regexpengine=1

" Make vim save/restore when leaving buffer, etc
set autowriteall
if !isdirectory(expand(&undodir))
  call mkdir(expand(&undodir), 'p')
endif
set undofile
set nohidden

" tmux will send xterm-style keys when its xterm-keys option is on
" https://superuser.com/questions
if &term =~# '^tmux'
  execute "set <xUp>=\e[1;*A"
  execute "set <xDown>=\e[1;*B"
  execute "set <xRight>=\e[1;*C"
  execute "set <xLeft>=\e[1;*D"
endif

" http://vim.wikia.com/wiki/Change_cursor_shape_in_different_modes 
" TODO: nvim
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"
" }}}
" Maps {{{
" Space leader
let mapleader = ' '

" Do not show stupid q: window
nnoremap q: :q

" ; instead of :
nnoremap ; :
" tnoremap <C-W>; <C-W>:

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

xnoremap gs y:%s/<C-r>"//g<Left><Left>

if has('gui_macvim')
  set macmeta
endif

" }}
" Splits
" Ctrl-n/ creates splits
" Ctrl-hjkl changes splits
 noremap <C-Right> :vsplit +Dirvish<CR>
tnoremap <C-Right> <C-w>:vsplit +Dirvish<CR>
 noremap <C-Down> :split +Dirvish<CR>
tnoremap <C-Down> <C-w>:split +Dirvish<CR>

tnoremap <C-h> <C-\><C-N><C-w>h
tnoremap <C-j> <C-\><C-N><C-w>j
tnoremap <C-k> <C-\><C-N><C-w>k
tnoremap <C-l> <C-\><C-N><C-w>l

inoremap <C-h> <C-\><C-N><C-w>h
inoremap <C-j> <C-\><C-N><C-w>j
inoremap <C-k> <C-\><C-N><C-w>k
inoremap <C-l> <C-\><C-N><C-w>l

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Space-t spawns a terminal
nnoremap <Leader>t :terminal<CR>

" Indent/deindent
nnoremap <Leader>] >>_
nnoremap <Leader>[ <<_

" Term scrolling
" function! TSExitNormalMode()
"   unmap <buffer> <silent> <LeftMouse>
"   unmap <buffer> <silent> <ESC>
"   call feedkeys('a')
" endfunction
"
" function! TSEnterNormalMode()
"   if &buftype ==? 'terminal' && mode('') ==? 't'
"     call feedkeys("\<c-w>N")
"     call feedkeys("\<c-y>")
"     map <buffer> <silent> <LeftMouse> :call TSExitNormalMode()<CR>
"     map <buffer> <silent> <ESC> :call TSExitNormalMode()<CR>
"     setlocal nonumber
"   endif
" endfunction
"
" tnoremap <silent> <ScrollWheelUp> <c-w>:call TSEnterNormalMode()<CR>
" tnoremap <silent> <C-u> <c-w>:call TSEnterNormalMode()<CR>
tnoremap <C-v> <C-w>"*

map gb <C-^>

" Make j/k move to next visual line instead of physical line
" http://yubinkim.com/?p=6
nnoremap k gk
nnoremap j gj
nnoremap gk k
nnoremap gj j

" quick fix for misspelled word
nnoremap zf 1z=

" No idea why I need this, honestly.
noremap <nowait> dd dd

""" Text objects
" 'in line' (entire line sans white-space; cursor at beginning--ie, ^)
" https://vimways.org/2018/transactions-pending/
xnoremap <silent> il :<c-u>normal! g_v^<cr>
onoremap <silent> il :<c-u>normal! g_v^<cr>

" 'around line' (entire line sans trailing newline; cursor at beginning--ie, 0)
xnoremap <silent> al :<c-u>normal! $v0<cr>
onoremap <silent> al :<c-u>normal! $v0<cr>

" 'in document' (from first line to last; cursor at top--ie, gg)
xnoremap <silent> id :<c-u>normal! G$Vgg0<cr>
onoremap <silent> id :<c-u>normal! GVgg<cr>

" 'in fold' https://github.com/Konfekt/FastFold#fold-text-object
xnoremap iz :<c-u>normal! ]zv[z<cr>
xnoremap az :<c-u>normal! ]zV[z<cr>

" 'in indentation' (indentation level sans any surrounding empty lines)
function! s:inIndentation()
  let l:magic = &magic
  set magic
  normal! ^
  let l:vCol = virtcol(getline('.') =~# '^\s*$' ? '$' : '.')
  let l:pat = '^\(\s*\%'.l:vCol.'v\|^$\)\@!'
  let l:start = search(l:pat, 'bWn') + 1
  let l:end = search(l:pat, 'Wn')
  if (l:end !=# 0)
    let l:end -= 1
  endif
  execute 'normal! '.l:start.'G0'
  call search('^[^\n\r]', 'Wc')
  execute 'normal! Vo'.l:end.'G'
  call search('^[^\n\r]', 'bWc')
  normal! $o
  let &magic = l:magic
endfunction
xnoremap <silent> ii :<c-u>call <sid>inIndentation()<cr>
onoremap <silent> ii :<c-u>call <sid>inIndentation()<cr>

" "around indentation" (indentation level and any surrounding empty lines)
function! s:aroundIndentation()
  let l:magic = &magic
  set magic
  normal! ^
  let l:vCol = virtcol(getline('.') =~# '^\s*$' ? '$' : '.')
  let l:pat = '^\(\s*\%'.l:vCol.'v\|^$\)\@!'
  let l:start = search(l:pat, 'bWn') + 1
  let l:end = search(l:pat, 'Wn')
  if (l:end !=# 0)
    let l:end -= 1
  endif
  execute 'normal! '.l:start.'G0V'.l:end.'G$o'
  let &magic = l:magic
endfunction
xnoremap <silent> ai :<c-u>call <sid>aroundIndentation()<cr>
onoremap <silent> ai :<c-u>call <sid>aroundIndentation()<cr>

noremap gs :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

function! OSC52Copy(text) abort
  let escape = system('osc-52-copy', a:text)
  if v:shell_error
    echoerr escape
  else
    call writefile([escape], '/dev/tty', 'b')
  endif
endfunction
xnoremap <silent> <Leader>y y:call OSC52Copy(getreg('"'))<CR>

" }}}
" Autocommands {{{

" Make required directories when writing a file..
" http://stackoverflow.com/questions/4292733/vim-creating-parent-directories-on-save
function! TSMkNonExDir(file, buf)
  if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
    let dir=fnamemodify(a:file, ':h')
    if !isdirectory(dir)
      call mkdir(dir, 'p')
    endif
  endif
endfunction
augroup vimrc
  autocmd!
  autocmd TermOpen * startinsert
  autocmd TermOpen * set nonumber
  autocmd BufEnter term://* startinsert

  " Open quickfix window after any :*grep* command
  " https://github.com/tpope/vim-fugitive
  autocmd QuickFixCmdPost *grep* cwindow
  " Resize splits when the window is resized
  autocmd VimResized * wincmd =                       
  " Open fold under cursor on read/write
  autocmd BufWrite,BufEnter  * :silent! normal zO     
  " Auto-read vimrc on write
  autocmd BufWritePost {.vimrc,vimrc} nested source % 

  autocmd BufWritePre * :call TSMkNonExDir(expand('<afile>'), +expand('<abuf>'))

  " Only highlight searches while searching
  autocmd CmdlineEnter /,\? :set hlsearch   
  autocmd CmdlineLeave /,\? :set nohlsearch

  " Sync syntax highlighting when entering a buffer
  autocmd BufEnter * :syntax sync fromstart
  " Fixed QF / Location window size
  autocmd FileType qf setlocal winfixwidth
  " https://github.com/justinmk/vim-dirvish/issues/142
  autocmd FileType qf noremap <buffer> <C-Right> :lclose \| vsplit +Dirvish<CR>
  autocmd FileType qf noremap <buffer> <C-Down> :lclose \| split +Dirvish<CR>
augroup END
"}}}
" Colors {{{
function! MyHighlights() abort
  highlight Normal                      guibg=NONE
  highlight Comment                                    cterm=italic
  highlight Pmenu       guifg=#c6c6c6   guibg=Blue
  highlight PmenuSel    guifg=Yellow    guibg=Blue     cterm=bold
  highlight PmenuSbar                   guibg=Grey
  highlight PmenuThumb                  guibg=White
  highlight MatchParen  guifg=NONE      guibg=NONE     cterm=underline,bold ctermbg=NONE
  highlight Folded      guifg=lightblue guibg=NONE     cterm=bold   
  highlight Cursor      guifg=yellow    guibg=blue     " Only works in GUI.  See kitty.conf for terminal
  highlight WildMenu    guifg=yellow
  " highlight ColorColumn guifg=yellow    guibg=#444444
  highlight slideDelim  guifg=#555555
  highlight kramdownIAL guifg=Grey                     cterm=italic
  highlight htmlH1      guifg=#b8bb26                  cterm=bold
  highlight htmlH2      guifg=#a5a822                  cterm=bold
  highlight htmlH3      guifg=#93951e                  cterm=bold
  highlight htmlH4      guifg=#80821a                  cterm=bold
  highlight htmlH5      guifg=#6e7016                  cterm=bold
  highlight htmlH6      guifg=#5c5d13                  cterm=bold
  highlight String      guifg=#999999
  " call matchadd('ColorColumn', '\%81v', 100)
endfunction

augroup MyColors
    autocmd!
    autocmd ColorScheme * call MyHighlights()
augroup END

" https://medium.com/@dubistkomisch/how-to-actually-get-italics-and-true-colour-to-work-in-iterm-tmux-vim-9ebe55ebc2be
" TODO: nvim
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"

" https://vi.stackexchange.com/questions/15722/vim-tmux-and-xterm-bracketed-paste
" TODO: nvim
if &term =~# '^tmux'
  let &t_BE="\<Esc>[?2004h"
  let &t_BD="\<Esc>[?2004l"
  let &t_PS="\<Esc>[200~"
  let &t_PE="\<Esc>[201~"
endif

" TODO: nvim:  if this is set, italics doesn't work :shrug:.
set termguicolors
let g:gruvbox_contrast_dark = 'hard'
colorscheme gruvbox
"}}}
" TODO: nvim
" packadd! matchit " % now works with if/else/fi
" Folding {{{
" set foldopen=all " Too aggressive.  Can't move through file.
" Toggle folds under cursor recursively
nnoremap zz zA

" http://gregsexton.org/2011/03/27/improving-the-text-displayed-in-a-vim-Fold.html
fu! CustomFoldText()
  "get first non-blank line
  let fs = v:foldstart
  while getline(fs) =~? '^\s*$' | let fs = nextnonblank(fs + 1)
  endwhile
  if fs > v:foldend
    let line = getline(v:foldstart)
  else
    let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
  endif

  let w = winwidth(0) - &foldcolumn - (&number ? 8 : 0)
  let foldSize = 1 + v:foldend - v:foldstart
  let foldSizeStr = ' ' . foldSize . ' lines '
  let lineCount = line('$')
  let foldPercentage = printf('(%.1f', (foldSize*1.0)/lineCount*100) . '%) '
  let expansionString = repeat('─', w - strwidth(foldSizeStr.line.foldPercentage))
  return line . expansionString . foldSizeStr . foldPercentage
endf
set foldtext=CustomFoldText()
" }}}
" Plugin Config {{{

let g:Illuminate_highlightUnderCursor = 0

" vim-dirvish {{{
let g:dirvish_mode = ':sort ,^.*[\/],'
augroup dirvish
  autocmd!
  autocmd FileType dirvish silent keeppatterns g@\v/\.[^\/]+/?$@d _
  autocmd FileType dirvish nnoremap <buffer> <silent> <Leader>t :exec 'lcd ' . expand('%')<CR>:terminal<CR>
  autocmd FileType dirvish nnoremap <buffer> <silent> t :exec 'lcd ' . expand('%')<CR>:terminal<CR>
augroup END
" }}}

" vim-markdown {{{
let g:vim_markdown_override_foldtext = 0
let g:vim_markdown_folding_style_pythonic = 1
let g:vim_markdown_folding_level = 6
let g:vim_markdown_yaml_frontmatter = 1
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_fenced_languages = ['bash=sh', 'console=sh']
let g:vim_markdown_folding_disabled = 1 " We manage our own folding
" }}}

" vim-qf {{{
let g:qf_auto_resize = 0
let g:qf_loclist_window_bottom = 0
" }}}

" https://github.com/romainl/vim-devdocs
set keywordprg=:DD

" https://github.com/zhimsel/vim-stay
set viewoptions=cursor,folds,slash,unix

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  set grepprg=ag\ --vimgrep\ $*
  set grepformat=%f:%l:%c:%m
endif

" localvimrc {{{
let g:localvimrc_persistent = 2
let g:localvimrc_persistence_file = expand('$HOME') . '/.vim/localvimrc_persistent'
" }}}

" Surround {{{
xmap s <Plug>VSurround
let g:surround_{char2nr("(")} = "(\r)"
let g:surround_{char2nr("[")} = "[\r]"
let g:surround_{char2nr("<")} = "<\r>"
let g:surround_{char2nr("%")} = "%{\r}"
let g:surround_{char2nr("#")} = "#{\r}"
let g:surround_{char2nr("$")} = "$(\r)"
" }}}

" ALE {{{
let g:ale_sign_error           = '🔥'
let g:ale_echo_msg_error_str   = '🔥'
let g:ale_sign_warning         = '🤔'
let g:ale_echo_msg_warning_str = '🤔'
let g:ale_sign_info            = '👋'
let g:ale_echo_msg_info_str    = '👋'
let g:ale_echo_msg_format = '%severity% %s [%code %%linter%]'
let g:ale_open_list = 0
let g:ale_loclist = 0
let g:ale_sign_column_always = 1
set signcolumn="yes"

highlight clear ALEErrorSign
highlight clear ALEWarningSign
highlight clear ALEInfoSign
augroup LanguageClient_config
  autocmd!
  autocmd User LanguageClientStarted setlocal signcolumn=yes
  autocmd User LanguageClientStopped setlocal signcolumn=yes
augroup END
" }}}

" EasyAlign {{{
" Start interactive EasyAlign in visual mode (e.g. vip<leader>a)
xmap <Leader>a <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip<leader>a)
nmap <Leader>a <Plug>(EasyAlign)
" }}}

" SuperTab {{{
let g:SuperTabDefaultCompletionType = '<C-n>'
let g:SuperTabCrMapping             = 0
" }}}

" TComment {{{
vmap # :TComment<CR>
" }}}

" ctrlp {{{
let g:ctrlp_map = '<Leader>f'
let g:ctrlp_cmd = 'CtrlPMixed'
let g:ctrlp_use_caching = 0 " ag is fast.
let g:ctrlp_open_new_file = 'e'
let g:ctrlp_open_multiple_files = 'e'
let g:ctrlp_working_path_mode = 'a'
if executable('ag')
  let g:ctrlp_user_command = 'gtimeout 2s ag %s -l --nocolor -g ""'
  let g:ctrlp_use_caching = 0
endif
" }}}

" Smartword {{{
" Warning: This overrides w/b/e/ge defaults
nmap cw c<Plug>(smartword-basic-w)
nmap dw d<Plug>(smartword-basic-w)
map w  <Plug>(smartword-w)
map b  <Plug>(smartword-b)
map e  <Plug>(smartword-e)
map ge <Plug>(smartword-ge)
" }}}

" vimade {{{
let g:vimade = {}
let g:vimade.enablesigns = 1
" }}}

" Terraform {{{
let g:terraform_align=1
let g:terraform_fmt_on_save = 1
" }}}

" Gitgutter {{{
let g:gitgutter_max_signs = 1000
let g:gitgutter_highlight_lines = 0
let g:gitgutter_sign_added              = '+'
let g:gitgutter_sign_modified           = '~'
let g:gitgutter_sign_removed            = '_'
let g:gitgutter_sign_removed_first_line = '‾'
let g:gitgutter_sign_modified_removed   = '~_'
" }}}

" Expand Region {{{
call expand_region#custom_text_objects({
      \ 'a]' :1,
      \ 'ab' :1,
      \ 'aB' :1,
      \ 'ii' :0,
      \ 'ai' :0,
      \ 'id' :0,
      \ 'ad' :0,
      \ })

call expand_region#custom_text_objects('ruby', {
      \ 'im' :0,
      \ 'am' :0,
      \ })
" }}}

" Status Line {{{
function! TSprojname() abort
  return fnamemodify(projectroot#get(), ':t')
endfunction

set noshowmode
let g:lightline = {
\   'active': {
\     'left':  [ [ 'mode', 'paste' ],
\                [ 'gitbranch', 'projectroot', 'relativepath'], 
\                ['readonly', 'modified' ] ],
\     'right': [ [ 'lineinfo' ],
\                [ 'percent' ],
\                [ 'filetype'] ]
\   },
\   'inactive': {
\     'left':  [ [ 'relativepath' ] ],
\     'right': [ [ 'lineinfo' ],
\                [ 'percent' ] ]
\   },
\   'component_function': {
\     'gitbranch': 'gitbranch#name',
\     'projectroot': 'TSprojname'
\   },
\   'mode_map': {
\     'n': 'N', 'i': 'I', 'R': 'R', 'v': 'V', 'V': 'VL', "\<C-v>": 'VB',
\     'c': 'C', 's': 'S', 'S': 'SL', "\<C-s>": 'SB', 't': 'T'
\   },
\   'separator': { 'left': '', 'right': '' },
\   'subseparator': { 'left': '', 'right': '' },
\   'colorscheme': 'PaperColor',
\ }
" }}}

" URL Opener {{{
" This isn't working.  #abc123
function! TScolor_code(word)
  if a:word =~? '^#[abcd0-9]\{6\}$'
    return 'https://www.color-hex.com/color/' . a:word[1:]
  endif
endfunction
let g:url_transformers = [ 'TScolor_code' ]
" }}}
"}}}

" vim: foldmethod=marker
