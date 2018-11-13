# Safeguards.  Disable by SCPing a `.disable_tmux` file into `$HOME`, don't run
# locally, and don't run if we don't have tmux.
if [[ "$(hostname -s)" == "tardis" ]] || [[ -f .disable_tmux ]] || ! command -v tmux 2>&1 > /dev/null; then
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
      tmux -2 a -t $unattached_tmux_session
    fi
    # Exit after tmux session ends.
    exit
  fi
fi
