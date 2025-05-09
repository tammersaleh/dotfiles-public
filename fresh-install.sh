#!/usr/bin/env bash

set -Eeuo pipefail
trap 'echo "$0 failed at line $LINENO: $BASH_COMMAND"' ERR
[[ -v DEBUG ]] && set -x

HOMEBREW_PREFIX=/opt/homebrew/
HBBIN=$HOMEBREW_PREFIX/bin
PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
  
main() {
  [[ $# -eq 3 ]] || usage "Expected 3 arguments, got $#"
  username=$1
  token=$2
  keypath=$3
  [[ -f $keypath ]] || usage "Can't read $keypath"

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew install stow git git-lfs git-crypt

  mkdir -p ~/dotfiles
  cd ~/dotfiles

  $HBBIN/git clone "https://${username}:${token}@github.com/tammersaleh/dotfiles-public.git" public
  $HBBIN/git clone "https://${username}:${token}@github.com/tammersaleh/dotfiles-private.git" private
  cd public 
  $HBBIN/git lfs fetch 
  $HBBIN/git lfs checkout
  cd -
  cd private 
  $HBBIN/git crypt unlock "$keypath"
  ./public/bin/dotfiles install
  cd -
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
