stty -ixon -ixoff < $TTY
umask 027
ulimit -n 10000
