export HUB_PROTOCOL=ssh
export GH_NO_UPDATE_NOTIFIER="this is set to stop gh from letting us know about new version."

# https://stackoverflow.com/questions/30542491/push-force-with-lease-by-default
g() {
  if [[ $1 == 'push' && ( $@ == *'--force'* || $@ == *' -f'*) && $@ != *'-with-lease'* ]]; then
    echo 'Hey stupid, use --force-with-lease instead'
  else
    command hub "$@"
  fi
}

compdef g=git
