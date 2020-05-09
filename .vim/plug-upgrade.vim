#!/usr/local/bin/vim -S

source $HOME/.vim/plugins.vim
PlugClean!
close
PlugUpgrade
exe 'PlugSnapshot! '.fnameescape($HOME.'/.vim/plug-snapshot.vim')
close
PlugUpdate

