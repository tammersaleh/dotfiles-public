fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit && compinit
autoload -Uz +X bashcompinit && bashcompinit

zstyle ':completion:*' verbose yes
zstyle ':completion:*' history-search-backward yes
zstyle ':completion:*' history-search-forward yes
# <tab> to expand aliases
zstyle ':completion:*' completer _expand_alias _complete _ignored
