# Secrets from 1Password, cached in the login keychain by `envsec sync` https://github.com/tammersaleh/envsec
#
# Over ssh the login keychain reports locked: securityd tracks unlock state
# per audit session, and sshd starts a new one. While the console session has
# the keychain unlocked, `unlock-keychain` accepts any passphrase (even empty)
# and just attaches this session, so try that silently first. Only when the
# keychain is truly locked (console logged out) is the passphrase checked;
# then prompt, three tries. Ctrl-C stops.
#
# Talk to /dev/tty directly: the powerlevel10k instant prompt redirects stdin
# and stdout while .zshrc runs, so `-t 0` is false here.
if [[ -n $SSH_CONNECTION ]]; then
  local _envsec_kc=~/Library/Keychains/login.keychain-db _envsec_try
  if ! /usr/bin/security show-keychain-info "$_envsec_kc" >/dev/null 2>&1 &&
     ! /usr/bin/security unlock-keychain -p "" "$_envsec_kc" >/dev/null 2>&1 &&
     { : </dev/tty; } 2>/dev/null; then
    for _envsec_try in 1 2 3; do
      /usr/bin/security unlock-keychain "$_envsec_kc" </dev/tty >/dev/tty 2>&1 && break
      (( $? == 130 )) && break
    done
  fi
  unset _envsec_kc _envsec_try
fi
eval "$(envsec env)"
