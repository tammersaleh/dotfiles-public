# Secrets from 1Password, cached in the login keychain by `envsec sync` https://github.com/tammersaleh/envsec
#
# Over ssh the login keychain is locked: securityd unlocks it per audit
# session, and sshd starts a new one. Unlock it here (one password prompt per
# ssh session) so `envsec env` can read the bundle.
if [[ -n $SSH_CONNECTION && -t 0 ]]; then
  local _envsec_kc=~/Library/Keychains/login.keychain-db
  if ! /usr/bin/security show-keychain-info "$_envsec_kc" >/dev/null 2>&1; then
    /usr/bin/security unlock-keychain "$_envsec_kc"
  fi
  unset _envsec_kc
fi
eval "$(envsec env)"
