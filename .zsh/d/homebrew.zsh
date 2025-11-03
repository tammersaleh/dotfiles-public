for package in man-db coreutils findutils gnu-tar gawk gnu-getopt ruby; do
  __prependpath    /opt/homebrew/opt/$package/libexec/gnubin
  __prependmanpath /opt/homebrew/opt/$package/libexec/gnuman
  __prependpath    /opt/homebrew/opt/$package/libexec/bin
  __prependmanpath /opt/homebrew/opt/$package/libexec/man
  __prependpath    /opt/homebrew/opt/$package/bin
  __prependmanpath /opt/homebrew/opt/$package/man
done

__prependpath    /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin/
__prependpath    /opt/homebrew/opt/macvim/MacVim.app/Contents/MacOS/
__prependpath    /opt/homebrew/bin
__prependpath    /opt/homebrew/sbin
__prependmanpath /opt/homebrew/share/man
__prependpath    /opt/homebrew/share/npm/bin

# To make psql work and to allow bundler to find libpq
export PATH="$(brew --prefix libpq)/bin:$PATH"
export LDFLAGS="-L$(brew --prefix libpq)/lib"
export CPPFLAGS="-I$(brew --prefix libpq)/include"

eval "$(brew shellenv)"

export HOMEBREW_BAT=true
