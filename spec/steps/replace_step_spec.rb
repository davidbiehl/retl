require "spec_helper"
require_relative "handlers_context"

describe Retl::ReplaceStep do 
  include_context :steps
  subject { Retl::StepHandler.new Retl::ReplaceStep.new(step) }
  let(:step) { Proc.new { |data, context| 5 } }

  it "replaces data" do 
    subject.push_in(data, context)

    expect(subject.output).to eq([5])
  end

  it_behaves_like "a step"
end