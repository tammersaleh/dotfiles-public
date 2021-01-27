#!/usr/bin/env bash

set -euo pipefail
shopt -s inherit_errexit

echo "Syncing vim plugins"
~/.vim/plug-install.sh

echo "Installing Brewfile"
brew bundle install --cleanup --force
