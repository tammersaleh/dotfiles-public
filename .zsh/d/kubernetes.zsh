alias kubectl=kubecolor
compdef kubecolor=kubectl

alias ky="kubectl get -o yaml"
alias kj="kubectl get -o json"
alias kw="kubectl get -o wide"
alias kg="kubectl get"
alias kd="kubectl describe"

# kubeswitch
source <(switcher init zsh)
source <(switch completion zsh)

k() {
  if [[ $1 == "s" ]]; then
    shift
    [[ $# -eq 0 ]] && { switch; switch ns; } || switch "$@"
  elif [[ $1 == "ns" ]]; then
    [[ -v KUBECONFIG ]] || switch
    shift
    switch ns "$@"
  else
    [[ -v KUBECONFIG ]] || switch
    kubectl "$@"
  fi
}
compdef k=kubectl
