#!/usr/bin/env bash

set -Eeuo pipefail

HOMEBREW_PREFIX=/opt/homebrew/
PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
  
main() {
  [[ $# -eq 3 ]] || usage "Expected 3 arguments, got $#"
  username=$1
  token=$2
  keypath=$3
  [[ -f $keypath ]] || usage "Can't read $keypath"

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
  brew install stow git git-lfs git-crypt

  mkdir -p ~/dotfiles
  cd ~/dotfiles

  git clone "https://${username}:${token}@github.com/tammersaleh/dotfiles-public.git" public
  git clone "https://${username}:${token}@github.com/tammersaleh/dotfiles-private.git" private
  
  cd public 
  git lfs install
  git lfs fetch 
  git lfs checkout
  cd -
  rm ~/.gitconfig

  cd private 
  git crypt unlock "$keypath"
  cd -

  ./public/bin/dotfiles install
}

usage() {
  [[ $# -gt 0 ]] && echo "  ERROR: $*"
  local me=$(basename "$0")
  cat <<-EOF

  USAGE: $me GITHUB_USERNAME GITHUB_TOKEN PATH_TO_KEY_FILE

  Installs homebrew and downloads and installs the public and private
  git repos.

    $me tammersaleh gh_token_string ~/key
	EOF
  exit 1
}

main "$@"
