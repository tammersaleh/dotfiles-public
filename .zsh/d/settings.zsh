stty -ixon -ixoff < $TTY
umask 027
ulimit -n 10000

setopt NUMERIC_GLOB_SORT         # Sort numbers numerically not lexically
setopt NO_CASE_GLOB              # Case insensitive globbing
setopt INTERACTIVE_COMMENTS      # Allow # comments in interactive shell
