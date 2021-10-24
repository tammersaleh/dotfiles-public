#!/usr/bin/env bash

set -euo pipefail
shopt -s inherit_errexit

trap 'echo "$0 failed at line $LINENO: $BASH_COMMAND"' ERR
[[ -v DEBUG ]] && set -x

echo "Installing Brewfile"
~/.Brewfiles/go

echo "Syncing vim plugins"
~/.vim/plugins/install
