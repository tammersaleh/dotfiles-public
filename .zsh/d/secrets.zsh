# Secrets from 1Password, cached in the login keychain by `envsec sync`.
# Prints `export` lines for every 1Password field tagged for the shell.
# Never run under xtrace: the eval argument is the secrets.
# https://github.com/tammersaleh/envsec
(( $+commands[envsec] )) && eval "$(envsec env)"
