tap "linuxbrew/extra"
tap "wata727/tflint"

brew "bfg"                           # Remove large files or passwords from Git history like git-filter-branch
brew "certbot"                       # Tool to obtain certs from Let's Encrypt and autoenable HTTPS
brew "cppcheck"                      # Static analysis of C and C++ code
brew "curl"                          # Get a file from an HTTP, HTTPS or FTP server
brew "dateutils"                     # Tools to manipulate dates with a focus on financial data
brew "dep"                           # Go dependency management tool
brew "docker"                        # Pack, ship and run any application as a lightweight container
brew "dust"                          # More intuitive version of du in rust
brew "emacs"                         # GNU Emacs text editor
brew "gcc"                           # The GNU Compiler Collection
brew "grip"                          # GitHub Markdown previewer
brew "micro"                         # Modern and intuitive terminal-based text editor
brew "parallel"                      # Shell command parallelization utility
brew "pass"                          # Password manager
brew "perl"                          # Highly capable, feature-rich programming language
brew "python@3.9"                    # Interpreted, interactive, object-oriented programming language
brew "upx"
brew "vim"                           # Vi 'workalike' with many additional features
brew "yamllint"                      # Linter for YAML files
brew "yq"                            # Process YAML documents from the CLI
brew "zsh"                           # UNIX shell (command interpreter)

instance_eval(File.read("common.rb"))

# vim: ft=ruby
