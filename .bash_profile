# Safeguards.  Disable by SCPing a `.disable_tmux` file into `$HOME` and don't
# run if we don't have tmux.

if [[ -f .disable_tmux ]] || ! command -v tmux > /dev/null; then
  . ~/.bashrc
else
  if [[ -v TMUX ]]; then
    # We're already in tmux.  Carry on.
    . ~/.bashrc
  else
    unattached_tmux_session=$(tmux ls -F "#{session_attached}:#{session_name}" | grep -E '^0:' | cut -f 2 -d : | head -n 1)
    if [[ -z "$unattached_tmux_session" ]]; then
      # There are no unattached tmux sessions.  Create a new one.
      tmux -2
    else
      # There are unattached tmux sessions.  Reattach.
      tmux -2 a -t "$unattached_tmux_session"
    fi
    # Exit after tmux session ends.
    exit
  fi
fi

# https://github.com/mykeels/slack-theme-cli
