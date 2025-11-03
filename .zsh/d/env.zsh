export XDG_DATA_HOME=$HOME/.local/share

export CLICOLOR=1
export LS_COLORS
# shellcheck disable=SC2046
eval $(dircolors ~/.dircolors)

export BLOCKSIZE=K
export PARINIT='w72jrT4bgqR B=.,?_A_a Q=_s>|'
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export PS4="\n$ "

export SHELLCHECK_OPTS='-e SC2155 -e SC1090'

# Stop tar from creating ._ files
export COPYFILE_DISABLE=1

__prependpath   '/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/'
__prependpath    /Applications/Postgres.app/Contents/Versions/9.4/bin

__prependpath "$HOME/bin/$(uname)"
__prependpath "$HOME/bin"

__source_if_exists "$HOME/.secret_vars_and_aliases"
