# frozen_string_literal: true

require "cmd"
require "spec_helper"
require "stringio"

RSpec.describe Cmd do
  subject do
    described_class.new(stdin: stdin, stdout: stdout, stderr: stderr, env: env)
  end

  let(:stdin)  { StringIO.new }
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }
  let(:env)    { ENV }

  # testing with raw options/arguments
  describe "#main" do
    context "when executed with no arguments" do
      it "must exit with error" do
        expect(subject.main([])).to eq(-1)
      end
    end

    context "when executed with -o OUTPUT" do
      # let(:file)   { ... }
      # let(:output) { ... }

      before { subject.main(["-o", output, file]) }

      # it "must create the output file" do
      #
      # end
    end
  end
end
