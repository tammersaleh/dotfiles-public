#!/usr/bin/env ruby

# Complete rake tasks script for bash
# Save it somewhere and then add
# complete -C path/to/script -o default rake
# to your ~/.bashrc
# Nicholas Seckar <nseckar@gmail.com>
# Saimon Moore <saimon@webtypes.com>
# http://www.webtypes.com/2006/03/31/rake-completion-script-that-handles-namespaces

exit 0 unless File.file?(File.join(Dir.pwd, 'Rakefile'))
exit 0 unless /^rake\b/ =~ ENV["COMP_LINE"]

after_match = $'
task_match = (after_match.empty? || after_match =~ /\s$/) ? nil : after_match.split.last
tasks = `rake --silent --tasks`.split("\n")[1..-1].collect {|line| line.split[1]}
tasks = tasks.select {|t| /^#{Regexp.escape task_match}/ =~ t} if task_match

# handle namespaces
if task_match =~ /^([-\w:]+:)/
  upto_last_colon = $1
  after_match = $'
  tasks = tasks.collect { |t| (t =~ /^#{Regexp.escape upto_last_colon}([-\w:]+)$/) ? "#{$1}" : t }
end

puts tasks
exit 0
