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

  context "run with no arguments" do
    it "must exit with error" do
      expect(subject.main([])).to eq(1)
    end
  end

  context "run with -o output file" do
    let(:file)   { "myfile" }
    let(:output) { "myoutput" }

    it "must exit clean" do
      expect(subject.main(["-o", output, file])).to eq(0)
    end
  end
end
