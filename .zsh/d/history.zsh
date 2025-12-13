export HISTFILE="$HOME/.local/share/zsh/history"
mkdir -p "$(dirname $HISTFILE)"
export HISTSIZE=10000000
export SAVEHIST=10000000
setopt INC_APPEND_HISTORY        # Write to file immediately when cmds entered
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks from commands before saving.
setopt HIST_FCNTL_LOCK           # Use proper file locking for history file.
