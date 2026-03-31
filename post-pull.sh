#!/usr/bin/env bash

set -euo pipefail
shopt -s inherit_errexit

trap 'echo "$0 failed at line $LINENO: $BASH_COMMAND"' ERR
[[ -v DEBUG ]] && set -x

cd "$(dirname "$0")"

~/packages/go

~/.config/nvim/install-plugins.sh

__git_add_and_commit_if_changed() {
  file=$1
  message=$2
  if git diff --quiet -- "$file"; then
    git add "$file" && git commit -m "$message"
  fi
}

curl -sSLo ~/.zsh/completions/_claude https://raw.githubusercontent.com/wbingli/zsh-claudecode-completion/refs/heads/main/_claude
__git_add_and_commit_if_changed .zsh/completions/_claude "Updated claude completions"

go install github.com/BRO3886/ical/cmd/ical@latest
__git_add_and_commit_if_changed bin/Darwin/ical "Updated ical cli"

