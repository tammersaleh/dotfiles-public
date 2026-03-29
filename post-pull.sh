#!/usr/bin/env bash

set -euo pipefail
shopt -s inherit_errexit

trap 'echo "$0 failed at line $LINENO: $BASH_COMMAND"' ERR
[[ -v DEBUG ]] && set -x

~/packages/go

~/.config/nvim/install-plugins.sh

curl -sSLo ~/.zsh/completions/_claude https://raw.githubusercontent.com/wbingli/zsh-claudecode-completion/refs/heads/main/_claude

go install github.com/BRO3886/ical/cmd/ical@latest

