# Secrets from 1Password, cached in the login keychain by `envsec sync`.
# `envsec env` prints `export` lines for every 1Password field tagged for the
# shell. xtrace is off for the eval (the expanded argument is the secrets) and
# restored on return by localoptions. https://github.com/tammersaleh/envsec
__load_secrets() {
  setopt localoptions noxtrace
  (( $+commands[envsec] )) && eval "$(envsec env)"
}
__load_secrets
unfunction __load_secrets
