#!vim -S

source $HOME/.vim/plugins.vim
PlugClean!
close
PlugUpgrade
source $HOME/.vim/plugins.vim
exe 'PlugSnapshot! '.fnameescape($HOME.'/.vim/plug-snapshot.vim')
close
PlugUpdate
quit
quit

