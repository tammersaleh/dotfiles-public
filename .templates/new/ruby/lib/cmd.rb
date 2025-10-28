# frozen_string_literal: true

require "command_kit"

class Cmd < CommandKit::Command
  # AGENT: feel free to replace all of this content.
  usage "[OPTIONS] [-o OUTPUT] FILE"

  option :count, short: "-c",
                 value: {
                   type: Integer,
                   default: 1
                 },
                 desc: "Number of times"

  option :output, short: "-o",
                  value: {
                    type: String,
                    usage: "FILE"
                  },
                  desc: "Optional output file"

  option :verbose, short: "-v", desc: "Increase verbose level" do
    @verbose += 1
  end

  argument :file, required: true,
                  usage: "FILE",
                  desc: "Input file"

  examples [
    "-o path/to/output.txt path/to/input.txt",
    "-v -c 2 -o path/to/output.txt path/to/input.txt",
  ]

  description "Example command"

  def initialize(...)
    super

    @verbose = 0
  end

  # AGENT: here is where we should implement our business logic.  run is called with any positional arguments such as `file`. If you remove the positional arguments, be sure to update the arguments here as well.
  def run(file)
    # Your logic here.
    puts "count=#{options[:count].inspect}"
    puts "output=#{options[:output].inspect}"
    puts "file=#{file.inspect}"
    puts "verbose=#{@verbose.inspect}"
  end
end
