#!/usr/bin/env bash

set -euo pipefail
shopt -s inherit_errexit

trap 'echo "$0 failed at line $LINENO: $BASH_COMMAND"' ERR
[[ -v DEBUG ]] && set -x

echo "Syncing vim plugins"
~/.vim/plug-install.sh

echo "Installing Brewfile"
brew bundle install --cleanup --force
