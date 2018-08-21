# vim: foldmethod=marker

### Helpers {{{

prepend_manpath() {
  [[ -d $1 ]] || return
  echo "$MANPATH" | grep -Eq "(^|:)$1($|:)" && return
  export MANPATH="$1:$MANPATH"
}

prepend_path() {
  [[ -d $1 ]] || return
  echo "$PATH" | grep -Eq "(^|:)$1($|:)" && return
  export PATH="$1:$PATH"
}

source_if_exists() {
  [[ -f $1 ]] || return
  source $1
}

############# }}}
### Variables {{{

prepend_path "$HOME/bin/$(uname)"
prepend_path "$HOME/bin"

prepend_path /home/linuxbrew/.linuxbrew/bin
prepend_path /usr/local/bin
prepend_path /home/linuxbrew/.linuxbrew/sbin
prepend_path /usr/local/sbin
prepend_manpath /home/linuxbrew/.linuxbrew/man
prepend_manpath /usr/local/man

prepend_path /usr/local/opt/coreutils/libexec/gnubin
prepend_manpath /usr/local/opt/coreutils/libexec/gnuman

prepend_path /usr/local/share/npm/bin
prepend_path /Applications/Postgres.app/Contents/Versions/9.4/bin

prepend_path /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin/

export CLICOLOR=1
export HISTCONTROL="ignoredups"
export HISTSIZE="2000"
export LS_COLORS
eval $(dircolors ~/.dircolors)

export EDITOR="vim"
export VISUAL="vim"
export PAGER=less
export BLOCKSIZE=K
export PARINIT='w72jrT4bgqR B=.,?_A_a Q=_s>|'
export LC_CTYPE=en_US.UTF-8
export VIM_APP_DIR=/Applications

export LESS="-X -M -E -R"

export PS4='$ '

export TERM=xterm-256color

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

source_if_exists "$HOME/.bash/secret_variables"

# https://gist.github.com/phette23/5270658
if [ "$ITERM_SESSION_ID" ]; then
  export PROMPT_COMMAND='echo -ne "\033];${PWD##*/}\007" '"$PROMPT_COMMAND"
fi

####################### }}}
### Aliases & Functions {{{

alias chmod='chmod -v'
alias cp='cp -i'
alias mv='mv -i'
alias c="cd .."
alias ls="gls -ohF --color=auto"
alias cidr=sipcalc
alias lk="/Volumes/keys/load"
alias grep="grep --color=auto"
alias cg='cd "$(git rev-parse --show-toplevel)"'
alias html="pup"
alias pyconsole="pipenv run ptpython"
alias grammarly="open -a Grammarly"
alias vi="TERM=xterm-256color-italic vi"
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
alias da="direnv allow"
alias de="vi .envrc && direnv allow"
alias git=hub
alias g=git
alias https='http --default-scheme=https'
alias pip=pip3

alias slack="slack-term -config ~/.config/slack-term.json"
alias ssh="TERM=xterm-color ssh"
alias tf=terraform

gpip(){
  # https://hackercodex.com/guide/python-development-environment-on-mac-osx/
   PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
}

v() {
  # https://github.com/vim/vim/blob/master/runtime/doc/terminal.txt
  # <Esc>]51;["drop", "filename"]<07>
  echo -ne "\033]51;[\"drop\", \"$PWD/$1\"]\007"
}

############### }}}
### Completions {{{

source_if_exists /usr/local/etc/bash_completion
source_if_exists /home/linuxbrew/.linuxbrew/etc/bash_completion

complete -o default -o nospace -F _git g
complete -C aws_completer aws

docker_etc=/Applications/Docker.app/Contents/Resources/etc
source_if_exists "$docker_etc/docker.bash-completion"
source_if_exists "$docker_etc/docker-machine.bash-completion"
source_if_exists "$docker_etc/docker-compose.bash-completion"

source_if_exists /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc
source_if_exists "$HOME/.bash/terraform-completion"

command -v kubectl >/dev/null && source <(kubectl completion bash)
command -v helm >/dev/null    && source <(helm completion bash)
command -v stern >/dev/null   && source <(stern --completion bash)

################# }}}
### Shell Options {{{

shopt -s checkwinsize
shopt -s histappend
shopt -s no_empty_cmd_completion
shopt -s globstar

########## }}}
### Prompt {{{

source_if_exists "$HOME/.bash/prompt"

################# }}}
### Special Hooks {{{

eval "$(rbenv init -)"
eval "$(direnv hook bash)"

# }}}
