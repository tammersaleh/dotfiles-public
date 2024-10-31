# frozen_string_literal: true

brew 'curl'                          # Get a file from an HTTP, HTTPS or FTP server
brew 'dateutils'                     # Tools to manipulate dates with a focus on financial data
brew 'dep'                           # Go dependency management tool
brew 'gcc'                           # The GNU Compiler Collection
brew 'grip'                          # GitHub Markdown previewer
brew 'upx'
brew 'yamllint'                      # Linter for YAML files

instance_eval(File.read('common.rb'))

# vim: ft=ruby
