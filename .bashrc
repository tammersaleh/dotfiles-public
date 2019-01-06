# vim: foldmethod=marker

### Helpers {{{

__has() {
  command -v "$1" > /dev/null
}

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
### Terminfo {{{
# Enable italics in xterm-256color
{
  infocmp -1 xterm-256color
  echo -e "\tsitm=\\E[3m,\n\tritm=\\E[23m,\tMs@,";
} > /tmp/xterm-256color.terminfo
tic -x /tmp/xterm-256color.terminfo
rm /tmp/xterm-256color.terminfo

############# }}}
### Variables {{{

__prependpath /home/linuxbrew/.linuxbrew/bin
__prependpath /usr/local/bin
__prependpath /home/linuxbrew/.linuxbrew/sbin
__prependpath /usr/local/sbin
__prependmanpath /home/linuxbrew/.linuxbrew/man
__prependmanpath /usr/local/man

__prependpath /usr/local/opt/coreutils/libexec/gnubin
__prependmanpath /usr/local/opt/coreutils/libexec/gnuman

__prependpath /usr/local/share/npm/bin
__prependpath /Applications/Postgres.app/Contents/Versions/9.4/bin
__prependpath /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin/
__prependpath /usr/local/opt/macvim/MacVim.app/Contents/MacOS/

__prependpath "$HOME/.local/bin"

__prependpath "$HOME/bin/$(uname)"
__prependpath "$HOME/bin"

export CLICOLOR=1
export HISTCONTROL="ignoredups"
export HISTSIZE="2000"
export LS_COLORS
eval $(TERM=xterm dircolors ~/.dircolors)

export EDITOR="vim"
export VISUAL="vim"
export PAGER=less
export BLOCKSIZE=K
export PARINIT='w72jrT4bgqR B=.,?_A_a Q=_s>|'
export LC_CTYPE=en_US.UTF-8
export VIM_APP_DIR=/Applications

export LESS="-FRMX --tabs 4"
export LESSOPEN="|lesspipe.sh %s"
export LESS_ADVANCED_PREPROCESSOR=1

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
export AWS_SDK_LOAD_CONFIG=true # Load _both_ ~/.aws/credentials and ~/.aws/config
__source_if_exists "$HOME/.bash/secret_variables"

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
alias chrome='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
alias da="direnv allow"
alias de="vi .envrc && direnv allow"
alias git=hub
alias g=git
alias https='http --default-scheme=https'
alias pip=pip3

alias slack="slack-term -config ~/.config/slack-term.json"
alias ssh="TERM=xterm-color ssh"
alias tf=terraform
alias :q=exit

__has bat && alias less="bat --style=changes"

function gpip(){
  # https://hackercodex.com/guide/python-development-environment-on-mac-osx/
  PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
}

if __has bat; then
  # Print the top of the README.md file when changing to a directory.
  function cd() { 
    set -e
    builtin cd "$@"
    set +e
    [[ -f README.md ]] && bat --style=numbers --line-range=:9 --italic-text=always --paging=never README.md
  }
fi

############### }}}
### Completions {{{

__source_if_exists /usr/local/etc/bash_completion
__source_if_exists /home/linuxbrew/.linuxbrew/etc/bash_completion

complete -o default -o nospace -F _git g
complete -C aws_completer aws

docker_etc=/Applications/Docker.app/Contents/Resources/etc
__source_if_exists "$docker_etc/docker.bash-completion"
__source_if_exists "$docker_etc/docker-machine.bash-completion"
__source_if_exists "$docker_etc/docker-compose.bash-completion"

__source_if_exists /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc
__source_if_exists "$HOME/.bash/terraform-completion"

__has kubectl && source <(kubectl completion bash)
__has helm    && source <(helm completion bash)
__has stern   && source <(stern --completion bash)

################# }}}
### Shell Options {{{

shopt -s checkwinsize
shopt -s histappend
shopt -s no_empty_cmd_completion
shopt -s globstar
shopt -s checkjobs

########## }}}
### Prompt {{{

__source_if_exists "$HOME/.bash/prompt"

################# }}}
### Hooks {{{
__has rbenv  && eval "$(rbenv init -)"
__has direnv && eval "$(direnv hook bash)"
__source_if_exists ~/.asdf/asdf.sh
__source_if_exists ~/.asdf/completion/asdf.bash
# }}}
