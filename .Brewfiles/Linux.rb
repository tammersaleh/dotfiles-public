tap "linuxbrew/extra"
tap "wata727/tflint"

brew "bfg"                           # Remove large files or passwords from Git history like git-filter-branch
brew "curl"                          # Get a file from an HTTP, HTTPS or FTP server
brew "dateutils"                     # Tools to manipulate dates with a focus on financial data
brew "dep"                           # Go dependency management tool
brew "gcc"                           # The GNU Compiler Collection
brew "grip"                          # GitHub Markdown previewer
brew "parallel"                      # Shell command parallelization utility
brew "python@3.9"                    # Interpreted, interactive, object-oriented programming language
brew "upx"
brew "yamllint"                      # Linter for YAML files
brew "yq"                            # Process YAML documents from the CLI
brew "zsh"                           # UNIX shell (command interpreter)

instance_eval(File.read("common.rb"))

# vim: ft=ruby
