export PAGER=less
export LESS="-FRMX --tabs 4"
export LESSOPEN="|lesspipe.sh %s"
export LESS_ADVANCED_PREPROCESSOR=1

if __has bat; then
  export BAT_CONFIG_FILE=~/.config/bat/config
  export MANPAGER="sh -c 'col -b | bat -l man -p'"
  export MANROFFOPT="-c"
fi
