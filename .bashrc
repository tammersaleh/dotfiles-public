### variables {{{
export CLICOLOR=1
export HISTCONTROL="ignoredups"
export HISTSIZE="2000"
export LSCOLORS=dxFxCxDxBxegedabagacad

export EDITOR="vim"
export VISUAL="vim"
export PAGER=less
export BLOCKSIZE=K
export PARINIT='w72jrT4bgqR B=.,?_A_a Q=_s>|'
export LC_CTYPE=en_US.UTF-8
export VIM_APP_DIR=/Applications

export LESS="-X -M -E -R"

export PATH="$HOME/bin/$(uname):$HOME/bin:$PATH"

export PS4='$ '

export TERM=xterm-256color

# }}}

### window_title {{{
# https://gist.github.com/phette23/5270658
if [ "$ITERM_SESSION_ID" ]; then
  export PROMPT_COMMAND='echo -ne "\033];${PWD##*/}\007" '"$PROMPT_COMMAND"
fi

# }}}

### aliases {{{
alias chmod='chmod -v'
alias cp='cp -i'
alias mv='mv -i'
alias c="cd .."
alias ls="gls -ohF --color=auto"
alias t="tree -C"
alias cidr=sipcalc
alias lk="/Volumes/keys/load"
alias grep="grep --color=auto"
alias cg='cd "$(git rev-parse --show-toplevel)"'
alias html="pup"
alias pyconsole="pipenv run ptpython"
alias grammarly="open -a Grammarly"
alias vi="TERM=xterm-256color-italic vi"

# }}}

### shopts {{{
shopt -s checkwinsize
shopt -s histappend
shopt -s no_empty_cmd_completion
shopt -s globstar

# }}}

### aws {{{
complete -C aws_completer aws

# }}}

### chrome {{{
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

# }}}

### coreutils {{{
export PATH="$PATH:/usr/local/opt/coreutils/libexec/gnubin"

# }}}

### direnv {{{
alias da="direnv allow"
alias de="vi .envrc && direnv allow"

# }}}

### docker {{{
DOCKER_ETC=/Applications/Docker.app/Contents/Resources/etc

if [[ -d $DOCKER_ETC ]]; then
  . "$DOCKER_ETC/docker.bash-completion"
  . "$DOCKER_ETC/docker-machine.bash-completion"
  . "$DOCKER_ETC/docker-compose.bash-completion"
fi

# }}}

### git {{{
alias git=hub
alias g=git
complete -o default -o nospace -F _git g

# }}}

### go {{{
export GOPATH=$HOME
export GOBIN="$GOPATH/$(uname -s)"

# }}}

### google_cloud_sdk {{{
GCP_PATH=/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk

if [[ -d $GCP_PATH ]]; then
  . "$GCP_PATH/path.bash.inc"
  . "$GCP_PATH/completion.bash.inc"
fi

# }}}

### homebrew {{{
export PATH=/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:$PATH
export PATH=/home/linuxbrew/.linuxbrew/sbin:/usr/local/sbin:$PATH
export MANPATH=/home/linuxbrew/.linuxbrew/man:/usr/local/man:$MANPATH
export HOMEBREW_NO_AUTO_UPDATE=1

# }}}

### httpie {{{
alias https='http --default-scheme=https'

# }}}

### kubernetes {{{
which kubectl >/dev/null && source <(kubectl completion bash)
which helm >/dev/null    && source <(helm completion bash)
which stern >/dev/null   && source <(stern --completion bash)

# }}}

### node {{{
export PATH=/usr/local/share/npm/bin:$PATH

# }}}

### postgresql {{{
export PATH=/Applications/Postgres.app/Contents/Versions/9.4/bin:$PATH

# }}}

### python {{{
# export PATH="/usr/local/opt/python@2/bin:$PATH"
export PYTHONDONTWRITEBYTECODE=1

alias pip=pip3

# https://hackercodex.com/guide/python-development-environment-on-mac-osx/
export PIP_CONFIG_FILE=$HOME/.config/pip/pip.conf
gpip(){
   PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
}

# https://github.com/kennethreitz/pipenv
# eval "$(pipenv --completion)" # Wow, that's slow...

export PYTEST_ADDOPTS="--color=yes"

# }}}

### bundler {{{
alias bi="bundle install --binstubs .bundle/bin"

# }}}

### rails {{{
export RACK_ENV=development

# }}}

### rbenv {{{
eval "$(rbenv init -)"

# }}}

### ruby_optimizations {{{
# export RUBY_HEAP_MIN_SLOTS=1000000
export RUBY_HEAP_SLOTS_INCREMENT=1000000
export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
export RUBY_GC_MALLOC_LIMIT=1000000000
export RUBY_HEAP_FREE_MIN=500000

# }}}

### rust {{{
PATH=$PATH:$HOME/.cargo/bin

# }}}

### shellcheck {{{
export SHELLCHECK_OPTS="-e SC2155"

# }}}

### slack {{{

alias slack="slack-term -config ~/.config/slack-term.json"
# }}}

### ssh {{{
alias ssh="TERM=xterm-color ssh"

# }}}

### terraform {{{
alias tf=terraform
# }}}

### tmux {{{
#if [ ! -z "$PS1" ]; then
#   tmux list-sessions 2>/dev/null
#fi

_tmux_complete_session() {
  local IFS=$'\n'
  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -W "$(tmux -q list-sessions | cut -f 1 -d ':')" -- "${cur}") )
}
complete -F _tmux_complete_session tm

# }}}

### vagrant {{{
export VAGRANT_VMWARE_CLONE_DIRECTORY=/tmp/vagrant_machines/
export VAGRANT_DEFAULT_PROVIDER=vmware_fusion
alias vssh="vagrant ssh"
alias va=vagrant

# }}}

### completion {{{
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
[ -f /home/linuxbrew/.linuxbrew/etc/bash_completion ] && . /home/linuxbrew/.linuxbrew/etc/bash_completion

# }}}

### z_direnv {{{
eval "$(direnv hook bash)"

# }}}

source "$HOME/.bash/prompt"
