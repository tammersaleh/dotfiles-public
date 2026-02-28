alias chmod='chmod -v'
alias cp='cp -i'
alias mv='mv -i'
alias ls="gls -ohFA --color=auto"
alias ll="gls -ohF  --color=auto"
alias diff="diff --color=auto"
alias grep="grep --color=auto"
__has gsed && alias sed=gsed
__has bat && alias cat="bat --pager=never"

alias chrome='"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"'

alias dr="doppler run --"

alias dush=dust # Better du -sh

alias lines="wc -l"
alias chars="wc -c"

boop () {
  local last="$?"
  if [[ "$last" == '0' ]]; then
    sfx good
  else
    sfx bad
  fi
  $(exit "$last")
}

git-cdwt () {
  cd "$(git worktree list | fzf | awk '{print $1}')"
}

cc() {
  if [[ -v NVIM ]]; then
    # Already in a neovim terminal, just run claude directly
    [ -v DEBUG ] && echo "In nvim already, running claude"
    claude "$@"
  else
    # Not in nvim, launch nvim with terminal and run claude
    [ -v DEBUG ] && echo "Launching nvim with claude"
    nvim -c "terminal claude $*"
  fi
}
