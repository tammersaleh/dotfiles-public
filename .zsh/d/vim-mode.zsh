# http://stratus3d.com/blog/2017/10/26/better-vi-mode-in-zshell/
# https://dougblack.io/words/zsh-vi-mode.html
# Better searching in command mode
bindkey -v
bindkey -M vicmd '?' history-incremental-search-forward
bindkey -M vicmd '/' history-incremental-search-backward

# Beginning search with j/k
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -M vicmd "k" up-line-or-beginning-search
bindkey -M vicmd "j" down-line-or-beginning-search

# Make Vi mode transitions faster (KEYTIMEOUT is in hundredths of a second)
export KEYTIMEOUT=1

# https://www.reddit.com/r/vim/comments/7wj81e/you_can_get_vim_bindings_in_zsh_and_bash/du3tx3z/
# ci"
autoload -U select-quoted
zle -N select-quoted
for m in visual viopp; do
  for c in {a,i}{\',\",\`}; do
    bindkey -M $m $c select-quoted
  done
done

# ci{, ci(
autoload -U select-bracketed
zle -N select-bracketed
for m in visual viopp; do
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $m $c select-bracketed
  done
done

# cs ds ys S
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -a cs change-surround
bindkey -a ds delete-surround
bindkey -a ys add-surround
bindkey -M visual S add-surround

# Don't highlight pasted text
zle_highlight=('paste:none')

# Fix bug when typing <Shift-Enter> through the neovim :terminal
# which deletes the current commandline
noop() { }
zle -N noop
bindkey '^[[13;2u' noop
bindkey -M vicmd '^[[13;2u' noop

alias :q=exit

