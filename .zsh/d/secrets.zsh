# Secrets from 1Password, cached in the login keychain by `envsec sync` https://github.com/tammersaleh/envsec
#
# Over ssh the login keychain is locked: securityd unlocks it per audit
# session, and sshd starts a new one. Unlock it here (one password prompt per
# ssh session) so `envsec env` can read the bundle. A wrong password exits 51
# and leaves it locked, so re-check and re-prompt, three tries. Ctrl-C stops.
if [[ -n $SSH_CONNECTION && -t 0 ]]; then
  local _envsec_kc=~/Library/Keychains/login.keychain-db _envsec_try
  for _envsec_try in 1 2 3; do
    /usr/bin/security show-keychain-info "$_envsec_kc" >/dev/null 2>&1 && break
    /usr/bin/security unlock-keychain "$_envsec_kc"
    (( $? == 130 )) && break
  done
  unset _envsec_kc _envsec_try
fi
eval "$(envsec env)"
