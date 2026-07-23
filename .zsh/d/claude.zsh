# https://code.claude.com/docs/en/agent-teams
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
export CLAUDE_CODE_HIDE_ACCOUNT_INFO=1
alias cw="cd ~/brain/cw && cl"
cl() {
  if [[ -v NVIM ]]; then
    # Already in a neovim terminal, just run claude directly
    [ -v DEBUG ] && echo "In nvim already, running claude"
    claude "$@"
  else
    # Not in nvim, launch nvim with terminal and run claude
    [ -v DEBUG ] && echo "Launching nvim with claude"
    nvim -c "terminal claude $*"
  fi
}
