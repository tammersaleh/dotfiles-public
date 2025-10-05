# frozen_string_literal: true
require 'command_kit'

class Cmd < CommandKit::Command

  usage '[OPTIONS] [-o OUTPUT] FILE'

  option :count, short: '-c',
                 value: {
                   type: Integer,
                   default: 1
                 },
                 desc: "Number of times"

  option :output, short: '-o',
                  value: {
                    type: String,
                    usage: 'FILE'
                  },
                  desc: "Optional output file"

  option :verbose, short: '-v', desc: "Increase verbose level" do
    @verbose += 1
  end

  argument :file, required: true,
                  usage: 'FILE',
                  desc: "Input file"

  examples [
    '-o path/to/output.txt path/to/input.txt',
    '-v -c 2 -o path/to/output.txt path/to/input.txt',
  ]

  description 'Example command'

  def initialize(**kwargs)
    super(**kwargs)

    @verbose = 0
  end

  def run(file)
    puts "count=#{options[:count].inspect}"
    puts "output=#{options[:output].inspect}"
    puts "file=#{file.inspect}"
    puts "verbose=#{@verbose.inspect}"
  end
end
