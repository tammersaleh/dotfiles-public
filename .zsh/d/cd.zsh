alias c="cd .."
alias cg='d=$(git rev-parse --show-cdup) && [[ -n "$d" ]] && cd "$d"'

function cmk() {
    mkdir -p $1 && cd $1
}

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

