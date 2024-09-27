tap 'dopplerhq/cli'
tap 'github/gh'
tap 'heroku/brew'
tap 'homebrew/bundle'
tap 'romkatv/powerlevel10k'
tap 'superfly/tap'
tap 'spacelift-io/spacelift'

brew 'automake'                      # Tool for generating GNU Standards-compliant Makefiles
brew 'awscli'                        # Official Amazon AWS command-line interface
brew 'bash'                          # Bourne-Again SHell, a UNIX command interpreter
brew 'bash-completion@2'             # Common bash-completion libraries
brew 'bat'                           # Clone of cat(1) with syntax highlighting and Git integration
brew 'bat-extras'
brew 'bfg'
brew 'cmake'                         # Cross-platform make
brew 'coreutils'                     # GNU File, Shell, and Text utilities
brew 'ctags'                         # Reimplementation of ctags(1)
brew 'diff-so-fancy'                 # Good-looking diffs with diff-highlight and more
brew 'direnv'                        # Load/unload environment variables based on $PWD
brew 'doppler' # doppler.com
brew 'efm-langserver'                # Trying this out with vim
brew 'elinks'                        # For lesspipe
brew 'entr'                          # Run arbitrary commands when files change
brew 'exa'
brew 'exiftool'                      # Perl lib for reading and writing EXIF metadata
brew 'fd'                            # Used by nvim treesitter
brew 'ffmpeg'                        # Play, record, convert, and stream audio and video
brew 'fzf'                           # used by vim finder
brew 'gh'                            # GitHub command-line tool
brew 'git'                           # Distributed revision control system
brew 'git-crypt'                     # Enable transparent encryption/decryption of files in a git repo
brew 'git-delta'
brew 'git-lfs'                       # Git extension for versioning large files
brew 'gnupg'                         # GNU Pretty Good Privacy (PGP) package
brew 'go'                            # Open source programming language to build simple/reliable/efficient software
brew 'gomplate'                      # For https://github.com/superorbital/infrastructure/blob/main/students/generate
brew 'gron'                          # Make JSON greppable
brew 'heroku'                        # Add GitHub support to git on the command-line
brew 'hub'                           # Used for campus
brew 'id3v2'                         # For lesspipe
brew 'imagemagick'                   # Tools and libraries to manipulate images in many formats
brew 'jq'                            # Lightweight and flexible command-line JSON processor
brew 'lazygit'
brew 'lesspipe'                      # Input filter for the pager less
brew 'libpq', force: true            # Used to get libpq and force linked to get psql cli in PATH
brew 'libxslt'                       # C XSLT library for GNOME
brew 'mediainfo'                     # For lesspipe
brew 'neovim', args: ['HEAD']
brew 'neovim-remote'
brew 'node'                          # Platform built on V8 to build network applications
brew 'pandoc'                        # Swiss-army knife of markup format conversion
brew 'parallel'                      # GNU Parallel
brew 'pass'                          # Password manager
brew 'pdftk-java'
brew 'powerlevel10k'
brew 'pstree'                        # Show ps output as a tree
brew 'python'                        # Interpreted, interactive, object-oriented programming language
brew 'rbenv'                         # Ruby version manager
brew 'rclone'
brew 'ripgrep'                       # Needed by vim treesitter
brew 'ruby-build'                    # Install various Ruby versions and implementations
brew 'ruff'                          # Python linting
brew 's3cmd'                         # Command-line tool for the Amazon S3 service
brew 'sassc'                         # Wrapper around libsass that helps to create command-line apps
brew 'shellcheck'                    # Static analysis and lint tool, for bash scripts
brew 'shfmt'                         # Shell fmt
brew 'sipcalc'                       # Advanced console-based IP subnet calculator
brew 'socat'                         # netcat on steroids
brew 'spacectl'
brew 'speedtest-cli'                 # Command-line interface for https://speedtest.net bandwidth tests
brew 'sqlite'                        # Command-line interface for SQLite
brew 'stow'                          # Used by dotfiles
brew 'terraform'
brew 'tflint'                        # Terraform linter
brew 'the_silver_searcher'           # Code-search similar to ack
brew 'tmux'                          # Terminal multiplexer
brew 'tree'                          # Display directories as trees (with optional color/HTML output)
brew 'vim'                           # Vi 'workalike' with many additional features
brew 'watch'                         # Executes a program periodically, showing output fullscreen
brew 'wget'                          # Internet file retriever
brew 'xpdf'                          # For lesspipe
brew 'xz'                            # General-purpose data compression with high compression ratio
brew 'yarn'
brew 'yq'
brew 'zlib'                          # General-purpose lossless data-compression library
brew 'zsh'
brew 'man-db'                        # Avoid "This manpage is not compatible with mandoc(1) and might display incorrectly" errors

cask 'font-codicon'                  # VSCode font icons
cask 'google-cloud-sdk'

# vim: ft=ruby
