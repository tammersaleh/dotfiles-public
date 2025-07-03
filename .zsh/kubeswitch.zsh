# kubeswitch
__has switch
source <(switcher init zsh)
alias ks=switch
source <(switch completion zsh)

k() {
  [[ -v KUBECONFIG ]] || switch
  kubectl "$@"
}

