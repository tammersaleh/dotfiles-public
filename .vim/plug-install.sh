#!/usr/bin/env bash

vim \
  -es \
  -c "source $HOME/.vim/plug-snapshot.vim" \
  -c "qall"
