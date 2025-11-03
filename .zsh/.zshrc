# Enable Powerlevel10k instant prompt. Must stay close to the top of ~/.zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

__has() { whence $1 > /dev/null; }

__running() { pgrep -x "$1" > /dev/null; }

__prependmanpath() {
  [[ -d "$1" ]] || return
  echo "$MANPATH" | grep -Eq "(^|:)$1($|:)" && return
  export MANPATH="$1:$MANPATH"
}

__prependpath() {
  [[ -d "$1" ]] || return
  echo "$PATH" | grep -Eq "(^|:)$1($|:)" && return
  export PATH="$1:$PATH"
}

__source_if_exists() {
  [[ -f "$1" ]] || return
  source "$1"
}

__source_if_exists "$HOME/.zsh/$(uname -s).zsh"

# Track which d/* files have been sourced to avoid duplicates
typeset -a D_FILES_SOURCED

source_d_file() {
  local pattern="$1"

  # Expand glob if needed
  for filepath in $~pattern; do
    [[ -f "$filepath" ]] || continue

    # Skip if already sourced
    (( ${D_FILES_SOURCED[(I)$filepath]} )) && continue

    source "$filepath"
    D_FILES_SOURCED+=("$filepath")
  done
}

# Load files in specific order to handle dependencies
source_d_file "$HOME/.zsh/d/homebrew.zsh"    # Must be first (sets up PATH for brew and GNU tools)
source_d_file "$HOME/.zsh/d/completions.zsh" # Must be before any compdef/complete usage
source_d_file "$HOME/.zsh/d/*"               # Load remaining files

# This must come at the end of the .zshrc file 🤷
__source_if_exists $(brew --prefix)/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# vim: foldmethod=marker ft=zsh
