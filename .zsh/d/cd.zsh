setopt AUTO_PUSHD                # Automatically push directories onto the stack
setopt PUSHD_IGNORE_DUPS         # Don't push duplicate directories
setopt PUSHD_SILENT              # Don't print directory stack after pushd/popd

alias c="cd .."
alias cg='d=$(git rev-parse --show-cdup) && [[ -n "$d" ]] && cd "$d"'

function mcd() {
  mkdir -p $1 && cd $1
}
compdef _cd mcd

if __has bat; then
  # https://stackoverflow.com/a/3964198/9932792
  function head_readme() {
      emulate -L zsh
      if [[ -f README.md ]]; then
        bat --style=grid --line-range=:9 --italic-text=always --paging=never README.md
      fi
  }
  chpwd_functions=(${chpwd_functions[@]} "head_readme")
fi

