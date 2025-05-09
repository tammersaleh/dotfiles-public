#!/usr/bin/env bash

set -Eeuo pipefail

HOMEBREW_PREFIX=/opt/homebrew/
HBBIN=$HOMEBREW_PREFIX/bin
  
main() {
  [[ $# -eq 3 ]] || usage "Expected 3 arguments, got $#"
  username=$1
  token=$2
  keypath=$3
  [[ -f $keypath ]] || usage "Can't read $keypath"

  if [[ ! -d $HOMEBREW_PREFIX ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
  fi
  PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
  brew install stow git git-lfs git-crypt bash

  mkdir -p ~/dotfiles
  cd ~/dotfiles

  [[ -d public ]] || git clone "https://${username}:${token}@github.com/tammersaleh/dotfiles-public.git" public
  [[ -d private ]] || git clone "https://${username}:${token}@github.com/tammersaleh/dotfiles-private.git" private
  
  (
    cd public 
    git lfs install
    git lfs fetch 
    git lfs checkout
    cd -
  )

  (
    cd private 
    git crypt unlock "$keypath"
    cd -
  )
  rm -f ~/.gitconfig # Was only used by git lfs, and conflicts with dotfiles

  ./public/bin/dotfiles install

  ~/brewfiles/go

  echo "All done!  Start a new shell and check it out!"
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
