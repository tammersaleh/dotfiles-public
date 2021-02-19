#!/usr/bin/env bash

vim \
  -es \
  -u "$HOME/.vim/vimrc" \
  -c "source $HOME/.vim/plug-snapshot.vim" \
  -c "qall"
