tap 'homebrew/cask'
tap 'homebrew/cask-fonts'
tap 'homebrew/cask-versions'

brew 'aspell'                     # Spell checker with better logic than ispell
brew 'autoconf'                   # Automatic configure script builder
brew 'bzip2'                      # Freely available high-quality data compressor
brew 'diffutils'
brew 'gawk'
brew 'gettext', link: true        # GNU internationalization (i18n) and localization (l10n) library
brew 'gnu-sed'
brew 'gnu-tar'                    # GNU version of the tar archiving utility
brew 'moreutils'
brew 'openssl'                    # SSL/TLS cryptography library
brew 'openssl@1.1'                # Cryptography and SSL/TLS Toolkit
brew 'libnotify'                  # Library that sends desktop notifications to a notification daemon
brew 'pinentry-mac'
brew 'readline'                   # Library for command-line editing
brew 'rsync'
brew 'switchaudio-osx'            # Used in ~/bin/audio to switch between mics 

cask '1password-cli'
cask 'aws-vault'
cask 'font-fira-code-nerd-font'
cask 'font-meslo-lg-nerd-font'
cask 'font-hack-nerd-font'
cask 'font-source-sans-3'
cask 'google-cloud-sdk'
cask 'wkhtmltopdf'

instance_eval(File.read('common.rb'))

# vim: ft=ruby
