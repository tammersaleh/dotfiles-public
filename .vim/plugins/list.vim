call plug#begin(expand('$XDG_DATA_HOME') . '/vim/plugged')

if has('python3')
  " Force python3 support before loading other plugins
  " https://robertbasic.com/blog/force-python-version-in-vim/
  "
  " Then, silently load python3 to get around imp deprecation warning:
  " https://github.com/vim/vim/issues/3117
  silent! python3 1
endif

" Languages & syntax
Plug 'https://github.com/Matt-Deacalion/vim-systemd-syntax'
Plug 'https://github.com/cakebaker/scss-syntax.vim'
Plug 'https://github.com/cespare/vim-toml'
Plug 'https://github.com/ekalinin/Dockerfile.vim'
Plug 'https://github.com/elzr/vim-json'
Plug 'https://github.com/fatih/vim-go'
Plug 'https://github.com/hail2u/vim-css3-syntax'
Plug 'https://github.com/hashivim/vim-terraform'
Plug 'https://github.com/pangloss/vim-javascript'
Plug 'https://github.com/plasticboy/vim-markdown'
Plug 'https://github.com/dkarter/bullets.vim' " Better markdown bullets
Plug 'https://github.com/tmhedberg/SimpylFold'  " Better python folding
Plug 'https://github.com/davidhalter/jedi-vim'  " Better python code completion
Plug 'https://github.com/raimon49/requirements.txt.vim' " Python requirements.txt support
Plug 'https://github.com/vim-ruby/vim-ruby'
Plug 'https://github.com/vim-scripts/jQuery'
Plug 'https://github.com/tpope/vim-rails'
Plug 'https://github.com/tpope/vim-git'
Plug 'https://github.com/aliou/bats.vim'
Plug 'https://github.com/kevinoid/vim-jsonc' " Json with comments
Plug 'https://github.com/rust-lang/rust.vim'

" General
Plug 'https://github.com/justinmk/vim-dirvish'          " Betterer netrw
Plug 'https://github.com/kana/vim-smartword'            " make `w` better.
Plug 'https://github.com/airblade/vim-gitgutter'        " Show git signs in gutter
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
Plug 'https://github.com/itchyny/lightline.vim'         " Simple status line
Plug 'https://github.com/itchyny/vim-gitbranch'         " Used for lightline
Plug 'https://github.com/dbakker/vim-projectroot'       " Used for lightline
" Plug 'https://github.com/ervandew/supertab'             " Tab does autocomplete
"
Plug 'https://github.com/Shougo/deoplete.nvim'
Plug 'https://github.com/roxma/nvim-yarp'
Plug 'https://github.com/roxma/vim-hug-neovim-rpc'

Plug 'https://github.com/w0rp/ale'                      " Linting and fixing                    
Plug 'https://github.com/TaDaa/vimade'                  " Fade the inactive windows
Plug 'https://github.com/romainl/vim-qf'                " Better quickfix/location windows
Plug 'https://github.com/ap/vim-templates'              " Templates in ~/.vim/templates
Plug 'https://github.com/junegunn/fzf'
Plug 'https://github.com/junegunn/fzf.vim'

Plug 'https://github.com/tpope/vim-endwise'
Plug 'https://github.com/jiangmiao/auto-pairs'
Plug 'https://github.com/alvan/vim-closetag'

" Color theme
Plug 'https://github.com/morhetz/gruvbox'
Plug 'https://github.com/rafi/awesome-vim-colorschemes'

Plug 'https://github.com/vim-scripts/icalendar.vim' " Added by add-plugin

call plug#end()
