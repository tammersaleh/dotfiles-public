alias chmod='chmod -v'
alias cp='cp -i'
alias mv='mv -i'
alias ls="gls -ohF  --color=auto"
alias la="gls -ohFa --color=auto"
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

