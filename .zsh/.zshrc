### Powerlevel10k Start {{{
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
############ }}}
### Helpers {{{

__has() { whence $1 > /dev/null; }

__running() { pgrep -x "$1" > /dev/null; }

__prependmanpath() {
  [[ -d $1 ]] || return
  echo "$MANPATH" | grep -Eq "(^|:)$1($|:)" && return
  export MANPATH="$1:$MANPATH"
}

__prependpath() {
  [[ -d $1 ]] || return
  echo "$PATH" | grep -Eq "(^|:)$1($|:)" && return
  export PATH="$1:$PATH"
}

__source_if_exists() {
  [[ -f $1 ]] || return
  source "$1"
}

############ }}}
### Variables {{{

__prependpath /home/linuxbrew/.linuxbrew/bin
__prependpath /usr/local/bin
__prependpath /home/linuxbrew/.linuxbrew/sbin
__prependpath /usr/local/sbin
# Kitty was installed via:
# sudo ./installer.sh dest=/opt launch=n
__prependpath /opt/kitty.app/bin
__prependmanpath /home/linuxbrew/.linuxbrew/man
__prependmanpath /usr/local/man

__prependpath /usr/local/opt/coreutils/libexec/gnubin
__prependmanpath /usr/local/opt/coreutils/libexec/gnuman
__prependpath /usr/local/opt/findutils/libexec/gnubin
__prependmanpath /usr/local/opt/findutils/libexec/gnuman
__prependpath /usr/local/opt/gnu-tar/libexec/gnubin
__prependmanpath /usr/local/opt/gnu-tar/libexec/gnuman

__prependpath /usr/local/share/npm/bin
__prependpath /Applications/Postgres.app/Contents/Versions/9.4/bin
__prependpath /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin/
__prependpath /usr/local/opt/macvim/MacVim.app/Contents/MacOS/
__prependpath /usr/local/opt/gnu-getopt/bin
__prependpath /usr/local/opt/ruby/bin

__prependpath "$HOME/.local/bin"

__prependpath "$HOME/bin/$(uname)"
__prependpath "$HOME/bin"

export XDG_DATA_HOME=$HOME/.local/share
tty -s && export DIRENV_LOG_FORMAT="$(tput setaf 010)$(tput dim)%s$(tput sgr0)"
export BOTO_CONFIG=/dev/null

export CLICOLOR=1
export LS_COLORS
# shellcheck disable=SC2046
eval $(dircolors ~/.dircolors)

export EDITOR="vim"
export VISUAL="vim"
export PAGER=less
export BLOCKSIZE=K
export PARINIT='w72jrT4bgqR B=.,?_A_a Q=_s>|'
export LC_CTYPE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export VIM_APP_DIR=/Applications

export LESS="-FRMX --tabs 4"
export LESSOPEN="|lesspipe.sh %s"
export LESS_ADVANCED_PREPROCESSOR=1

if __has bat; then
  export BAT_CONFIG_FILE=~/.config/bat/config
  export MANPAGER="sh -c 'col -b | bat -l man -p'"
  export MANROFFOPT="-c"
  export HOMEBREW_BAT=true
fi

export PS4="\n$ "

export RUBY_HEAP_SLOTS_INCREMENT=1000000
export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
export RUBY_GC_MALLOC_LIMIT=1000000000
export RUBY_HEAP_FREE_MIN=500000
export RACK_ENV=development

export SHELLCHECK_OPTS='-e SC2155 -e SC1090'

export VAGRANT_VMWARE_CLONE_DIRECTORY=/tmp/vagrant_machines/
export VAGRANT_DEFAULT_PROVIDER=vmware_fusion

export HOMEBREW_NO_AUTO_UPDATE=1

export GOPATH=$HOME
export GOBIN="$GOPATH/bin/$(uname -s)"

export PIP_CONFIG_FILE=$HOME/.config/pip/pip.conf
export PYTEST_ADDOPTS="--color=yes"
export PYTHONDONTWRITEBYTECODE=1
export CLOUDSDK_PYTHON=$(which python3)

export TERMINFO=~/.terminfo

export AWS_VAULT_BACKEND=pass
export AWS_VAULT_PASS_PREFIX=aws-vault

export HUB_PROTOCOL=ssh
export MOSH_TITLE_NOPREFIX=true

# For the Dockers!
export UID
export GID=$(id -g)
export DOCKER_BUILDKIT=1

export HISTFILE="$HOME/.local/share/zsh/history"
export HISTSIZE=10000000
export SAVEHIST=10000000

setopt appendhistory
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.

__source_if_exists "$HOME/.secret_vars_and_aliases"

####################### }}}
### Settings {{{
for terminfo_file in ~/.terminfo-sources/*.terminfo; do
  tic -x -o ~/.terminfo "$terminfo_file"
done
stty -ixon -ixoff < $TTY
umask 027
############# }}}
### Aliases & Functions {{{

alias chmod='chmod -v'
alias cp='cp -i'
alias mv='mv -i'
alias c="cd .."
alias ls="gls -ohF  --color=auto"
alias la="gls -ohFa --color=auto"
alias diff="diff --color=auto"
alias grep="grep --color=auto"
alias cidr=sipcalc
alias cg='d=$(git rev-parse --show-cdup) && [[ -n "$d" ]] && cd "$d"'
alias grammarly="open -a Grammarly"
alias chrome='"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"'
alias da="direnv allow"
alias de="vi .envrc && direnv allow"
alias git=hub
alias g=git
alias https='http --default-scheme=https'
alias html="pup"
alias pyconsole="pipenv run ptpython"
alias pip=pip3
alias dush=dust # Better du -sh
alias k=kubectl
alias :q=exit

__has gsed && alias sed=gsed
__has bat && alias less="bat"
__has bat && alias cat="bat --pager=never"

gpip(){
  # https://hackercodex.com/guide/python-development-environment-on-mac-osx/
  PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
}

if __has bat; then
  # Print the top of the README.md file when changing to a directory.
  cd() {
    # shellcheck disable=SC2164
    builtin cd "$@"
    ret=$?
    if [[ $ret -eq 0 ]]; then
      [[ -f README.md ]] && bat --style=grid --line-range=:9 --italic-text=always --paging=never README.md
      true
    else
      return $ret
    fi
  }
fi

journal() {
  local day=today
  if [[ $1 == "yesterday" ]]; then
    shift
    day=yesterday
  fi
  local file="$HOME/Dropbox/journal/$(date -d $day +%F).md"

  if [[ ! -f "$file" ]]; then
    echo "# $(date +'%A, %B %-d, %Y')" > "$file"
  fi

  if [[ $# -eq 0 ]]; then
    v "$file"
  else
    echo       >> "$file"
    echo "$*"  >> "$file"
  fi
}
alias j=journal

fixssh() {
  # shellcheck disable=SC2046
  eval $(tmux show-env -s | grep '^SSH_')
}

tmux-detach() {
  my_id="$(echo "$TMUX_PANE" | cut -c 2-)"
  for id in $(tmux "ls" -F '#{session_name}' | grep -vx "$my_id"); do
    echo "detaching $id"
    tmux detach-client -s "$id"
  done
  exit
}

############### }}}
### Completions {{{
#
# https://github.com/zsh-users/zsh-completions/blob/master/zsh-completions-howto.org
#
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit 
# The below isn't working for some reason, so gitignored the .zcompdump file.
compinit -d "$HOME/.local/share/zsh/compdump"
autoload bashcompinit 
bashcompinit

DOCKER_ETC=/Applications/Docker.app/Contents/Resources/etc
__source_if_exists "$DOCKER_ETC/docker.zsh-completion"
__source_if_exists "$DOCKER_ETC/docker-machine.zsh-completion"
__source_if_exists "$DOCKER_ETC/docker-compose.zsh-completion"

__has aws_completer && complete -C aws_completer aws
__has kubectl       && source <(kubectl completion zsh)
__has kubectl       && compdef k=kubectl
__has helm          && source <(helm completion zsh)
__has stern         && source <(stern --completion zsh)
__has aws-vault     && source <(aws-vault --completion-script-zsh)
__has fly           && source <(fly completion --shell zsh)
__has fly           && compdef ci=fly

compdef g=git
compdef av=exec

################# }}}
### Hooks & Daemons {{{
__has rbenv  && eval "$(rbenv init -)"
__has direnv && eval "$(direnv hook zsh)"

if [[ -x ~/.dropbox-dist/dropboxd ]] && ! __running dropbox; then
  echo "Restarting Dropbox..."
  nohup ~/.dropbox-dist/dropboxd >> ~/.dropbox-dist/dropboxd.log &
fi
# }}}
### Vim Mode {{{
# http://stratus3d.com/blog/2017/10/26/better-vi-mode-in-zshell/
# https://dougblack.io/words/zsh-vi-mode.html
# Better searching in command mode
bindkey -v
bindkey -M vicmd '?' history-incremental-search-backward
bindkey -M vicmd '/' history-incremental-search-forward

# Beginning search with j/k
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -M vicmd "k" up-line-or-beginning-search
bindkey -M vicmd "j" down-line-or-beginning-search

# Make Vi mode transitions faster (KEYTIMEOUT is in hundredths of a second)
export KEYTIMEOUT=1

# https://www.reddit.com/r/vim/comments/7wj81e/you_can_get_vim_bindings_in_zsh_and_bash/du3tx3z/
# ci"
autoload -U select-quoted
zle -N select-quoted
for m in visual viopp; do
  for c in {a,i}{\',\",\`}; do
    bindkey -M $m $c select-quoted
  done
done

# ci{, ci(
autoload -U select-bracketed
zle -N select-bracketed
for m in visual viopp; do
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $m $c select-bracketed
  done
done

# surround
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -a cs change-surround
bindkey -a ds delete-surround
bindkey -a ys add-surround
bindkey -M visual S add-surround
#}}}
### Local Config {{{
__source_if_exists "$HOME/.zsh/$(uname -s).zsh"
#}}}
### Powerlevel10k Finish {{{
source $ZDOTDIR/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.zsh/.p10k.zsh.
[[ ! -f ~/.zsh/.p10k.zsh ]] || source ~/.zsh/.p10k.zsh

function prompt_aws_vault() {
  [[ ! -v AWS_VAULT ]] && return
  local name=${AWS_VAULT:u}
  p10k segment -f yellow -b blue -t ${name//[-_]/ }
}

POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS="${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS#context}"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS+=("context" "aws_vault")
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  context
  dir                     # current directory
  aws_vault
  vcs                     # git status
  prompt_char             # prompt symbol
)
# Context color when running with privileges.
typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=red
# typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=red
# Context color in SSH without privileges.
typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=white
# typeset -g POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND=yellow
typeset -g POWERLEVEL9K_CONTEXT_REMOTE_SUDO_FOREGROUND=red
# typeset -g POWERLEVEL9K_CONTEXT_REMOTE_SUDO_BACKGROUND=red
# Default context color (no privileges, no SSH).
typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=white
# typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=yellow
#}}}
source $ZDOTDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# vim: foldmethod=marker ft=zsh
