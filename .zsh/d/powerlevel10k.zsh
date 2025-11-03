__source_if_exists $HOME/.zsh/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.zsh/.p10k.zsh.
[[ -f ~/.zsh/.p10k.zsh ]] && source ~/.zsh/.p10k.zsh

function prompt_aws_vault() {
  [[ ! -v AWS_VAULT ]] && return
  local name=${AWS_VAULT:u}
  p10k segment -f yellow -b blue -t ${name//[-_]/ }
}

typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  dir                     # current directory
  aws_vault
  vcs                     # git status
  prompt_char             # prompt symbol
)
typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=red
typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=white
typeset -g POWERLEVEL9K_CONTEXT_REMOTE_SUDO_FOREGROUND=red
typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=white
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
