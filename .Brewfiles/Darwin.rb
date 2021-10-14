tap "garethr/kubeval"
tap "homebrew/cask"
tap "homebrew/cask-fonts"
tap "homebrew/cask-versions"
tap "keith/formulae"
tap "sachaos/todoist"
tap "tylerbrock/saw"
tap "universal-ctags/universal-ctags"

brew "aspell"                     # Spell checker with better logic than ispell
brew "autoconf"                   # Automatic configure script builder
brew "bzip2"                      # Freely available high-quality data compressor
brew "diffutils"
brew "gdb"                        # GNU debugger
brew "gettext", link: true        # GNU internationalization (i18n) and localization (l10n) library
brew "gnu-tar"                    # GNU version of the tar archiving utility
brew "libnotify"                  # Library that sends desktop notifications to a notification daemon
brew "macvim"                     # GUI for vim, made for macOS
brew "moreutils"
brew "openssl"                    # SSL/TLS cryptography library
brew "openssl@1.1"                # Cryptography and SSL/TLS Toolkit
brew "peco"                       # Simplistic interactive filtering tool
brew "python"                     # Interpreted, interactive, object-oriented programming language
brew "readline"                   # Library for command-line editing
brew "reattach-to-user-namespace" # Reattach process (e.g., tmux) to background
brew "ruby-build"                 # Install various Ruby versions and implementations
brew "s3cmd"                      # Command-line tool for the Amazon S3 service
brew "sachaos/todoist/todoist"    # Todoist CLI client
brew "sipcalc"                    # Advanced console-based IP subnet calculator
brew "speedtest-cli"              # Command-line interface for https://speedtest.net bandwidth tests
brew "sqlite"                     # Command-line interface for SQLite
brew "svn"                        # Required for source-sans-pro
brew "tylerbrock/saw/saw"         # Fast, multipurpose tool for AWS CloudWatch Logs
brew "unixodbc"                   # ODBC 3 connectivity for UNIX
brew "upx"                        # Compress/expand executable files
brew "vault"                      # Secures, stores, and tightly controls access to secrets
brew "watchman"                   # Watch files and take action when they change
brew "yasm"                       # Modular BSD reimplementation of NASM

cask "aws-vault"
cask "font-hack-nerd-font"
cask "font-source-sans-pro"
cask "google-cloud-sdk"
cask "rectangle"
cask "wkhtmltopdf"

instance_eval(File.read("common.rb"))

# vim: ft=ruby
