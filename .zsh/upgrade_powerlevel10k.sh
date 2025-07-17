#!/usr/bin/env bash

set -Eeuo pipefail
shopt -s inherit_errexit
trap 'echo "$0 failed at line $LINENO: $BASH_COMMAND"' ERR
[[ -v DEBUG ]] && set -x

SRC=https://github.com/romkatv/powerlevel10k
main() {
  [[ $# -eq 1 ]] && usage

  TARGET=~/.zsh/powerlevel10k
  git clone --depth=1 "$SRC".git "$TARGET".new
  rm -rf "$TARGET".new/.git
  rm -rf $TARGET
  mv "$TARGET".new $TARGET
}

usage() {
  [[ $# -gt 0 ]] && echo "  ERROR: $*"
  local me=$(basename "$0")
  cat <<-EOF

  USAGE: $me

  Deletes and re-clones the latest powerlevel10k from $SRC

  Homebrew isn't kept up to date, so this is "better."
	EOF
  exit 1
}

main "$@"
