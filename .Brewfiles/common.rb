tap "github/gh"
tap "homebrew/bundle"
tap "homebrew/core"
tap "netlify/netlifyctl"
tap "romkatv/powerlevel10k"
tap "dopplerhq/cli"
tap "superfly/tap"
tap "heroku/brew"

brew "automake"                      # Tool for generating GNU Standards-compliant Makefiles
brew "awscli"                        # Official Amazon AWS command-line interface
brew "bash"                          # Bourne-Again SHell, a UNIX command interpreter
brew "bash-completion@2"             # Common bash-completion libraries
brew "bat"                           # Clone of cat(1) with syntax highlighting and Git integration
brew "cmake"                         # Cross-platform make
brew "coreutils"                     # GNU File, Shell, and Text utilities
brew "ctags"                         # Reimplementation of ctags(1)
brew "diff-so-fancy"                 # Good-lookin' diffs with diff-highlight and more
brew "direnv"                        # Load/unload environment variables based on $PWD
brew "doppler" # doppler.com
brew "entr"                          # Run arbitrary commands when files change
brew "exiftool"                      # Perl lib for reading and writing EXIF metadata
brew "ffmpeg"                        # Play, record, convert, and stream audio and video
brew "fzf"  # used by vim finder
brew "gh"                            # GitHub command-line tool
brew "git"                           # Distributed revision control system
brew "git-crypt"                     # Enable transparent encryption/decryption of files in a git repo
brew "git-delta"
brew "git-lfs"                       # Git extension for versioning large files
brew "gnupg"                         # GNU Pretty Good Privacy (PGP) package
brew "go"                            # Open source programming language to build simple/reliable/efficient software
brew "gron"                          # Make JSON greppable
brew "heroku"                        # Add GitHub support to git on the command-line
brew "httpie"                        # User-friendly cURL replacement (command-line HTTP client)
brew "hub"  # Used for campus
brew "imagemagick"                   # Tools and libraries to manipulate images in many formats
brew "jq"                            # Lightweight and flexible command-line JSON processor
brew "lazygit"
brew "lesspipe"                      # Input filter for the pager less
brew "libpq", force: true # Used to get libpq and force linked to get psql cli in PATH
brew "libxslt"                       # C XSLT library for GNOME
brew "netlify/netlifyctl/netlifyctl" # CLI to interact with netlify.com
brew "node"                          # Platform built on V8 to build network applications
brew "pandoc"                        # Swiss-army knife of markup format conversion
brew "pass"                          # Password manager
brew "pdftk-java"
brew "powerlevel10k"
brew "pstree"                        # Show ps output as a tree
brew "rbenv"                         # Ruby version manager
brew "rclone"
brew "sassc"                         # Wrapper around libsass that helps to create command-line apps
brew "shellcheck"                    # Static analysis and lint tool, for (ba)sh scripts
brew "socat"                         # netcat on steroids
brew "stow"  # Used by dotfiles
brew "terraform"
brew "tflint"                        # Terraform linter
brew "the_silver_searcher"           # Code-search similar to ack
brew "tmux"                          # Terminal multiplexer
brew "tree"                          # Display directories as trees (with optional color/HTML output)
brew "vim"                           # Vi 'workalike' with many additional features
brew "watch"                         # Executes a program periodically, showing output fullscreen
brew "wget"                          # Internet file retriever
brew "xz"                            # General-purpose data compression with high compression ratio
brew "yarn"
brew "zlib"                          # General-purpose lossless data-compression library
brew "zsh"

# brew "cfssl"                         # CloudFlare's PKI toolkit
# brew "consul"                        # Tool for service discovery, monitoring and configuration
# brew "elinks"                        # Text mode web browser
# brew "flyctl"                        # Fly.io
# brew "helm"                          # The Kubernetes package manager
# brew "kube-ps1"                      # Kubernetes prompt info for bash and zsh
# brew "kubectx"                       # Tool that can switch between kubectl contexts easily and create aliases
# brew "kubernetes-cli"                # Kubernetes command-line interface
# brew "links"                         # Lynx-like WWW browser that supports tables, menus, etc.
# brew "lynx"                          # Text-based web browser
# brew "mosh"                          # Remote terminal application
# brew "noti"                          # Trigger notifications when a process completes
# brew "stern"                         # Tail multiple Kubernetes pods & their containers
# brew "vale"                          # Prose Linter https://docs.errata.ai/vale

# vim: ft=ruby
