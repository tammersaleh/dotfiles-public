#!/usr/bin/env bash

set -Eeuo pipefail
shopt -s inherit_errexit
trap 'echo "$0 failed at line $LINENO: $BASH_COMMAND"' ERR
[[ -v DEBUG ]] && set -x

main() {
  [[ $# -eq 0 ]] || usage "Expected no arguments, got $#"

  echo "Removing unreferenced plugins"
  nvim --headless "+Lazy! clean" +qa

  echo "Updating plugins to locked versions"
  nvim --headless "+Lazy! install" +qa
}

usage() {
  [[ $# -gt 0 ]] && echo "  ERROR: $*"
  local me=$(basename "$0")
  cat <<EOF

  Syncs Lazy.nvim plugins to locked versions, uninstalling unreferenced ones.

  USAGE: $me

    $me 
EOF
  exit 1
}

main "$@"
